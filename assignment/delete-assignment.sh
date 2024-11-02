#!/bin/bash

echo "Delete Forwarding Rule"
gcloud compute forwarding-rules delete http-content-rule --global --quiet

echo "Delete Target HTTP Proxy"
gcloud compute target-http-proxies delete http-lb-proxy --quiet

echo "Delete URL Map"
gcloud compute url-maps delete http-url-map --quiet

echo "Delete Backend Service"
gcloud compute backend-services delete http-backend-service --global --quiet

echo "Delete Health Check"
gcloud compute health-checks delete http-basic-check --quiet

echo "Delete Instance Group"
gcloud compute instance-groups unmanaged delete http-servers-group --zone=asia-east1-a --quiet

echo "Delete VM Instances"
gcloud compute instances delete http-server-1 http-server-2 database-vm --zone=asia-east1-a --quiet

echo "Delete Firewall Rules for myvpc1"
gcloud compute firewall-rules delete myvpc1-allow-icmp myvpc1-allow-ssh myvpc1-allow-http --quiet

echo "Delete Firewall Rules for myvpc2"
gcloud compute firewall-rules delete myvpc2-allow-mysql myvpc2-allow-ssh --quiet

echo "Delete VPC Peering Connections"
gcloud compute networks peerings delete myvpc1-to-myvpc2 --network=myvpc1 --quiet
gcloud compute networks peerings delete myvpc2-to-myvpc1 --network=myvpc2 --quiet

echo "Delete Subnets"
gcloud compute networks subnets delete myvpc1-subnet --region=asia-east1 --quiet
gcloud compute networks subnets delete myvpc2-subnet --region=asia-east1 --quiet

echo "Delete VPC Networks"
gcloud compute networks delete myvpc1 --quiet
gcloud compute networks delete myvpc2 --quiet

echo "All resources have been deleted."
