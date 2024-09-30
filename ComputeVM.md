# Compute Engine - VM Instance - By Lakshika Tanwar
---
## Method 1 - Using GUI
We create the VM Instance using the GUI exploring N and E Seies machines.

## Method 2 - Using Google Cloud Console

### The following code is from our instance which we created using GUI. We used its --project and --service-account value and replaced those in the command provided by faculty.

```
gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=us-central1-f --machine-type=g1-small --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server,lb-health-check --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240830,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
```

---
### The following is the code provided by faculty with the above values replaced:

gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=asia-east1-c --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240720,mode=rw,size=10,type=projects/golden-sentry-430013-j5/zones/asia-east1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any

We ran the above code in 'console' of gc.

Command to directly create from console.