# **Deploy a VM Instance and Run Apache Server**

### **Objective**  
Deploy a Virtual Machine (VM) instance on Google Compute Engine and configure it to run an Apache HTTP server.

---

## **Prerequisites**
1. **Google Cloud Platform Setup**:  
   - Ensure you have a GCP account and a project set up.
   - Install and initialize the `gcloud` CLI:  
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:  
   - Compute Engine API must be enabled.  
     ```bash
     gcloud services enable compute.googleapis.com
     ```

3. **Billing Account**:  
   - A billing account must be linked to your project.

---

## **Step 1: Create a VM Instance**

### **Using Google Cloud Console (GUI)**
1. Go to the **Compute Engine** page:  
   [Compute Engine > VM Instances](https://console.cloud.google.com/compute/instances)

2. Click **"Create Instance"**.

3. Configure the VM:  
   - **Name**: `apache-server-vm`  
   - **Region**: Select your desired region, e.g., `us-central1`.  
   - **Machine Type**: `e2-micro` (Free tier eligible).  
   - **Boot Disk**: Ubuntu 22.04 LTS.  
     - Click "Change" under Boot Disk, select the **Ubuntu** image, and save.  
   - **Firewall**:  
     - Check the boxes for **Allow HTTP traffic** and **Allow HTTPS traffic**.

4. Click **Create**.

---

### **Using `gcloud` CLI**  
Run the following command to create a VM instance:

```bash
gcloud compute instances create apache-server-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server \
    --boot-disk-size=10GB
```

---

## **Step 2: SSH into the VM**

### **Using Google Cloud Console (GUI)**  
1. From the **VM Instances** page, find your instance.  
2. Click on **"SSH"** next to the instance name.

### **Using `gcloud` CLI**  
To SSH into your VM instance:  
```bash
gcloud compute ssh apache-server-vm --zone=us-central1-a
```

---

## **Step 3: Install Apache Web Server**

Once connected to the VM via SSH, run the following commands:

1. **Update the package lists**:  
   ```bash
   sudo apt update
   ```

2. **Install Apache**:  
   ```bash
   sudo apt install -y apache2
   ```

3. **Start the Apache server**:  
   ```bash
   sudo systemctl start apache2
   ```

4. **Enable Apache to start on boot**:  
   ```bash
   sudo systemctl enable apache2
   ```

5. **Verify Apache Installation**:  
   Open the external IP of your VM instance in a browser.  
   - Example: `http://<VM-EXTERNAL-IP>`  
   - You should see the default Apache welcome page.

---

## **Step 4: Configure Firewall Rules (If Required)**

If HTTP traffic is not allowed during VM creation, you can manually set up the firewall rules.

### **Using `gcloud` CLI**  
```bash
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --target-tags=http-server
```

### **Verify Firewall**  
- Revisit `http://<VM-EXTERNAL-IP>` to confirm that the Apache server is accessible.

---

## **Final Notes**  

- **To Stop the Apache Server**:  
   ```bash
   sudo systemctl stop apache2
   ```

- **To Restart the Apache Server**:  
   ```bash
   sudo systemctl restart apache2
   ```

- **To Delete the VM** (if not needed anymore):  
   ```bash
   gcloud compute instances delete apache-server-vm --zone=us-central1-a
   ```
