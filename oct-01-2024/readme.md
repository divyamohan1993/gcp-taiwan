# **Deploy a VM with Apache Server via Startup Script and Dynv6 Dynamic IP**

## **Objective**  
1. Deploy a VM instance that automatically runs an Apache server using a startup script.  
2. Use **Dynv6** to bind the VM's external IP to a dynamic DNS name for consistent access.

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:  
   - GCP project initialized with billing.  
   - `gcloud` CLI installed and configured:  
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:  
   Enable the Compute Engine API.  
   ```bash
   gcloud services enable compute.googleapis.com
   ```

3. **Dynv6 Account**:  
   - Create an account at [dynv6](https://dynv6.com).  
   - Generate a **token** for dynamic DNS updates.  
   - Create a **dynv6 hostname** (e.g., `example.dynv6.net`).

---

## **Step 1: Create a VM Instance with a Startup Script**

The startup script will:
- Update the package list.
- Install and start Apache HTTP server.
- Update the Dynv6 dynamic DNS with the instance's public IP.

### **Startup Script**

Create a `startup-script.sh` file locally with the following content:

```bash
#!/bin/bash
# Update packages and install Apache
apt-get update
apt-get install -y apache2 curl

# Start Apache service
systemctl start apache2
systemctl enable apache2

# Fetch public IP of the VM
PUBLIC_IP=$(curl -s ifconfig.me)

# Update Dynv6 dynamic DNS
DYNV6_TOKEN="YOUR_DYNV6_TOKEN"
DYNV6_HOSTNAME="YOUR_DYNV6_HOSTNAME"

curl "https://dynv6.com/api/update?hostname=${DYNV6_HOSTNAME}&token=${DYNV6_TOKEN}&ipv4=${PUBLIC_IP}"

# Add log entry
echo "Dynv6 updated with IP: ${PUBLIC_IP}" >> /var/log/startup-script.log
```

Replace:  
- `YOUR_DYNV6_TOKEN` with your Dynv6 token.  
- `YOUR_DYNV6_HOSTNAME` with your Dynv6 hostname (e.g., `example.dynv6.net`).

---

### **Deploy the VM**

Run the following `gcloud` command to create the VM:

```bash
gcloud compute instances create apache-dynv6-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server \
    --metadata-from-file startup-script=startup-script.sh \
    --boot-disk-size=10GB
```

---

## **Step 2: Allow HTTP Traffic**

If not already enabled, add a firewall rule to allow HTTP traffic.

### **Using gcloud CLI**
```bash
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --target-tags=http-server
```

---

## **Step 3: Verify Apache and Dynv6 Configuration**

1. **Apache Verification**:
   - Find the **external IP** of the instance:
     ```bash
     gcloud compute instances list
     ```
   - Open the IP in a browser:  
     `http://<EXTERNAL-IP>`  
   - The default Apache server page should load.

2. **Dynv6 DNS Update**:  
   - Go to your Dynv6 hostname URL:  
     `http://example.dynv6.net`  
   - It should point to your VM's Apache server.

---

## **Step 4: Automate Dynv6 Updates (Optional)**

To ensure the Dynv6 hostname stays updated even after a VM restart, add a **cron job** to periodically update the DNS.

1. SSH into the VM:
   ```bash
   gcloud compute ssh apache-dynv6-vm --zone=us-central1-a
   ```

2. Edit the cron jobs:
   ```bash
   crontab -e
   ```

3. Add the following line to run the Dynv6 update script every 10 minutes:
   ```bash
   */10 * * * * curl "https://dynv6.com/api/update?hostname=YOUR_DYNV6_HOSTNAME&token=YOUR_DYNV6_TOKEN&ipv4=$(curl -s ifconfig.me)"
   ```

---

## **Cleanup (Optional)**  
To delete the VM instance:  
```bash
gcloud compute instances delete apache-dynv6-vm --zone=us-central1-a
```

---

## **Summary**  
- A VM instance is created and runs an Apache server using a startup script.  
- The script automatically updates the Dynv6 dynamic DNS with the VM's external IP.  
- Dynv6 provides consistent hostname access even when the VM restarts or its IP changes.

Now, your Apache server is accessible via the Dynv6 dynamic hostname!