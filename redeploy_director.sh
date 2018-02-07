#!/bin/bash
rm creds.yml && rm state.json
unset BOSH_ENVIRONMENT
unset BOSH_CLIENT
unset BOSH_CLIENT_SECRET


bosh create-env ../bosh-deployment/bosh.yml \
--state ./state.json \
-o ../bosh-deployment/virtualbox/cpi.yml \
-o ../bosh-deployment/virtualbox/outbound-network.yml \
-o ../bosh-deployment/bosh-lite.yml \
-o ../bosh-deployment/bosh-lite-runc.yml \
-o ../bosh-deployment/jumpbox-user.yml \
-o ../bosh-deployment/local-dns.yml \
-o ../bosh-deployment/uaa.yml \
-o ../bosh-deployment/credhub.yml \
--vars-store ./creds.yml \
-v director_name="bosh-1" \
-v internal_ip=192.168.50.6 \
-v internal_gw=192.168.50.1 \
-v internal_cidr=192.168.50.0/24 \
-v outbound_network_name=NatNetwork


bosh alias-env bosh-1 -e 192.168.50.6 --ca-cert <(bosh int creds.yml --path /director_ssl/ca)
export BOSH_ENVIRONMENT=bosh-1
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`
sudo route add -net 10.244.0.0/16 192.168.50.6
bosh update-cloud-config bosh-lite-cloud-config.yml
bosh upload-stemcell https://bosh.io/d/stemcells/bosh-warden-boshlite-ubuntu-trusty-go_agent?v=3468.5 \
  --sha1 b95fac2b5d27a3c91b762b1df3747110b058a145
bosh upload-release https://bosh.io/d/github.com/cloudfoundry/dns-release --sha1 f43c79eea8115915f507ba3dd2936cb1ec33fdf4
