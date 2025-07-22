#!/bin/bash

set -x

# output in /var/log/cloud-init-output.log

# wait for subscription registration to complete
while ! subscription-manager status; do
    echo "Waiting for RHSM registration..."
    sleep 10
done

# install prereqs
dnf install -y podman

export JFROG_HOME=/opt/artifactory
mkdir -p $JFROG_HOME/var/etc
mkdir -p $JFROG_HOME/postgres
mkdir -p $JFROG_HOME/haproxy

mkdir -p /var/lib/containers/tmp
export TMPDIR=/var/lib/containers/tmp

cat <<EOF >$JFROG_HOME/var/etc/system.yaml
shared:
  database:
    driver: org.postgresql.Driver
    type: postgresql
    url: jdbc:postgresql://artifactory.${base_domain}:5432/artifactory
    username: artifactory
    password: password
  extraJavaOpts: "-Xms2g -Xmx4g"
observability:
    consumption:
        allow: ""
EOF

chown -R 1030:1030 $JFROG_HOME/var
chown 999 $JFROG_HOME/postgres

firewall-cmd --permanent --add-port=8082/tcp
firewall-cmd --permanent --add-port=8443/tcp
firewall-cmd --reload

cd $JFROG_HOME

cat <<EOF > haproxy/san.cnf
[req]
default_bits  = 4096
distinguished_name = req_distinguished_name
req_extensions = req_ext
x509_extensions = v3_req
prompt = no

[req_distinguished_name]
countryName = US
stateOrProvinceName = N/A
localityName = N/A
organizationName = Self-signed certificate
commonName = artifactory.${base_domain}: Self-signed certificate

[req_ext]
subjectAltName = @alt_names

[v3_req]
subjectAltName = @alt_names
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature

[alt_names]
IP.1 = 192.168.252.8
DNS.1 = artifactory.${base_domain}
EOF

openssl req -x509 -newkey rsa:4096 -nodes -days 730 -keyout haproxy/artifactory.key.pem -out haproxy/artifactory.crt.pem -config haproxy/san.cnf

cat <<EOF > haproxy/haproxy.cfg
global
  log         127.0.0.1 local2
  maxconn     4096
  daemon
  tune.ssl.default-dh-param 2048
defaults
  mode                    http
  log                     global
  option                  httplog
  option                  forwardfor
  option                  dontlognull
  option                  http-server-close
  option                  redispatch
  retries                 3
  timeout http-request    10s
  timeout queue           1m
  timeout connect         5000
  timeout client          50000
  timeout server          50000
  timeout http-keep-alive 10s
  timeout check           10s
  maxconn                 4000
  errorfile 400 /usr/local/etc/haproxy/errors/400.http
  errorfile 403 /usr/local/etc/haproxy/errors/403.http
  errorfile 408 /usr/local/etc/haproxy/errors/408.http
  errorfile 500 /usr/local/etc/haproxy/errors/500.http
  errorfile 502 /usr/local/etc/haproxy/errors/502.http
  errorfile 503 /usr/local/etc/haproxy/errors/503.http
  errorfile 504 /usr/local/etc/haproxy/errors/504.http
frontend stats
  bind *:1936
  mode            http
  log             global
  maxconn 10
  stats enable
  stats hide-version
  stats refresh 30s
  stats show-node
  stats show-desc Stats for ocp4 cluster
  stats auth admin:artifactory
  stats uri /stats

frontend registry
  bind *:8443 ssl crt /usr/local/etc/haproxy/server.bundle.pem
  mode http
  option forwardfor
  #http-request replace-pathq /v2(.*$) /artifactory/api/docker/docker/v22/\1
  http-request add-header X-Forwarded-Proto https if { ssl_fc }
  option forwardfor header X-Real-IP
  default_backend jfrog_backend

backend jfrog_backend
  mode http
  server artifactory 192.168.252.8:8082
EOF

chown -R 100:100 $JFROG_HOME/haproxy
chmod 644 $JFROG_HOME/haproxy/artifactory.*

sysctl net.ipv4.ip_unprivileged_port_start=0 

podman pod create \
  --network=host \
  --dns=192.168.252.8 \
  --name artifactory \
  --hostname artifactory.${base_domain}

podman run -d --pod artifactory --name artifactory-postgres \
  -e POSTGRES_USER=artifactory \
  -e POSTGRES_PASSWORD=password \
  -e POSTGRES_DATABASE=artifactory \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -v $${PWD}/postgres:/var/lib/postgresql/data:Z \
  docker.io/library/postgres:latest

podman run -d --pod artifactory --name artifactory-app \
  -v  $${PWD}/var/:/var/opt/jfrog/artifactory:Z \
  releases-docker.jfrog.io/jfrog/artifactory-jcr:latest

podman run -d --pod artifactory \
  --name=artifactory-haproxy \
  --cap-add NET_ADMIN \
  -v  $${PWD}/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:Z \
  -v  $${PWD}/haproxy/artifactory.crt.pem:/usr/local/etc/haproxy/server.bundle.pem:Z \
  -v  $${PWD}/haproxy/artifactory.key.pem:/usr/local/etc/haproxy/server.bundle.pem.key:Z \
  docker.io/library/haproxy:latest

cd /usr/lib/systemd/system

podman generate systemd --files --name --new artifactory
systemctl enable --now pod-artifactory.service


TIMEOUT=90  # seconds
INTERVAL=2  # seconds
ELAPSED=0

while ! curl -k --silent --fail "https://localhost:8443" > /dev/null; do
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
  if [ "$ELAPSED" -ge "$TIMEOUT" ]; then
    echo "Timeout reached after $TIMEOUT seconds. https://localhost:8443 is still not available."
    exit 1
  fi
done

sleep $INTERVAL

%{ if accept_license }
# accept EULA
curl -k -XPOST -u admin:password https://localhost:8443/artifactory/ui/jcr/eula/accept

sleep $INTERVAL
%{ endif }

# disable backups
cat <<EOF >$PWD/artifactory.config.import.yml
backups:
  backup-daily:
    enabled: false
  backup-weekly:
    enabled: false
EOF

curl -k -u admin:password \
  -X PATCH https://localhost:8443/artifactory/api/system/configuration \
  -H "Content-type: application/yaml" \
  --data-binary @artifactory.config.import.yml

sleep $INTERVAL

# change admin password
curl -k -X POST -u admin:password \
  -H "Content-type: application/json" \
  -d '{
    "userName": "admin",
    "oldPassword": "password",
    "newPassword1": "${artifactory_password}",
    "newPassword2": "${artifactory_password}"
  }' \
  https://localhost:8443/artifactory/api/security/users/authorization/changePassword