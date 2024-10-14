# Google Cloud Project Creation
- Project number: 9649******63
- Project ID: industrial-glow-******-i4

We then explored various services provided by the Google Cloud.



# Compute Engine - VM Instance - By Lakshika Tanwar
**Prerequisite:**
- *Creation of Google Cloud Project*
- *Guidance from faculty and https://cloud.google.com/sdk/docs/install#deb*

---
## Method 1 - Using GUI
We create the VM Instance using the GUI exploring N and E Series machines. We ssh on to the Ubuntu 20.04 LTS instance we created and explored its capabilities. We also saw how to ssh to the instance directly using google console.

The following code is used to ssh the vm using google cloud console with the name as VM_NAME(replace with suitable name), and zone as asia-east1-c(replace as applicable)
```
cloud compute ssh VM_NAME --project=replace_withyour_project_id --zone=asia-east1-c
```

We also learnt how to add startup script through GUI. 

## Method 2 - Using Google Cloud Console

### The following code is from our instance which we created using GUI. We used its --project and --service-account value and replaced those in the command provided by faculty.

```
gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=us-central1-f --machine-type=g1-small --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server,lb-health-check --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240830,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
```

---
### The following is the code provided by faculty with the above values replaced:
```
gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=asia-east1-c --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240720,mode=rw,size=10,type=projects/golden-sentry-430013-j5/zones/asia-east1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
```

We ran the above code in 'console' of gc. Once the Machine was deployed we used the following code to run the repository update and install apache2. Further, we created the index.html and deployed it live using public IP. (For some reason unknown the page was not accessible even with correct permissions).
```
apt update
apt -y install apache2
cat <<EOF > /var/www/html/index.html
<html><body><p>Linux startup script added directly. $(hostname -f) </p></body></html>
```

---
Once deployed, we can use the following code to access the list of VM's deployed. 
```
gcloud  compute  instances list
```

---

The following command creates the instance with VM_NAME(replace with suitable name) with the image as debain intead of Ubuntu as we used above. This command has an startup sript attached which runs the repo update -. installs apache2 -> and creates a badix index.html page which can be accessed by opening vm's public ip.

```
gcloud compute instances create VM_NAME \
  --image-project=debian-cloud \
  --image-family=debian-10 \
  --metadata=startup-script='#! /bin/bash
  apt update
  apt -y install apache2
  cat <<EOF > /var/www/html/index.html
  <html><body><p>Linux startup script added directly.</p></body></html>
  EOF'
```

--- 
We were guided on how to integrate OpenAI key and make a project - https://python.langchain.com/docs/integrations/llms/openai/ which can be accessed using https://platform.openai.com/api-keys

---


### Deploying a website to dynv6.net

#### Using startup script from GUI

While creating a VM:
- Open advanced settings -> Network -> Add Network tags 'http-server' and 'https-server'
- Management -> Under Automations, paste the following script.

```
#! /bin/bash
 apt update
 apt -y install apache2
 cat <<EOF > /var/www/html/index.html
 <html><body><p>Linux startup script added directly. $(hostname -I) </p></body></html>
```

Create and deploy the VM after above changes have been made.

We create our account on dynv6.com. In the dashboard, we attach the external IP we get from the vm to a dynamic address that has been created by us.

The website is then deployed to that custom address we created, herein, http://lakshikatanwar.dynv6.net

#### Using buckets to hold static resources and linking it to compute instance to host directly as folder of website

Linking different vm + ping them - DIY

#### Creating budget for monitering credit usage with predefined scoping.
 DIY - Give details for notes

#### SSH to instance 2 from within instance 1. 

We created connection between the two instances through SSH. For this example we will use  myweb1 with internal ip 10.140.0.10 (host) to access mygcp1 with 10.140.0.11 as internal ip (guest). 

Steps:

- Update password of root user for both instance to your password using command `sudo passwd root`. 
- Escalate the priveledge by `su` command, i.e. enter to superuser or root user and enter the password which you just created.
- Ping each other to confirm they can 'talk' to each other.
- If we attemp to ssh now, it will give error as we dont have proper keys
- 
  
