### **1. Create VM with No Public IP**
1. **Login to GCP:**
   - Visit the [Google Cloud Console](https://console.cloud.google.com) and log in with your Google account.
2. **Access Compute Engine:**
   - In the navigation menu (hamburger icon on the top-left), go to **Compute Engine** > **VM Instances**.
   - If Compute Engine isn’t enabled, click **Enable API and Compute Engine** (it may take a few minutes to activate).
3. **Create a New VM:**
   - Click the blue **Create Instance** button at the top.
   - Fill out the following fields:
     - **Name**: Choose a name (e.g., `vm-no-public-ip`).
     - **Region and Zone**: Select your preferred region and zone (e.g., `us-central1`).
     - **Machine Configuration**:
       - Leave as default (e.g., `e2-micro`) for small workloads.
     - **Boot Disk**: Ensure `Debian 11` or another preferred OS is selected.
   - Scroll down to **Networking**:
     - Expand the section.
     - Under **Network interfaces**, click **Edit**.
     - **External IP**: Select **None**.
   - Leave other settings as default and click **Create**.
4. **Verify the VM is Created:**
   - After a few minutes, the VM will appear in the list. Its **External IP** column will say "None."

#### **Test:**
- Click the **SSH** button next to the VM name to open a web-based SSH terminal.
- Type `ping google.com` and press Enter. It will fail because the VM has no internet access.

---

### **2. Configure Cloud NAT for Outbound Traffic**
1. **Navigate to VPC Network:**
   - In the navigation menu, go to **VPC Network** > **NAT**.
2. **Create a Cloud NAT Gateway:**
   - Click the blue **Create NAT Gateway** button.
   - Fill out the details:
     - **Name**: Enter a name (e.g., `nat-gateway`).
     - **Region**: Select the same region where your VM is located.
     - **Network**: Select the default network or the one your VM uses.
     - **Subnetwork**: Choose **All Subnetworks** in the region.
     - **External IP Addresses**: Select "Auto-allocate External IP."
   - Click **Create**.
3. **Verify NAT Configuration:**
   - Go back to **Compute Engine** > **VM Instances**.
   - Click **SSH** for your VM again.
   - Type `ping google.com` and press Enter. This time, it should succeed.

---

### **3. Install and Verify the Ops Agent**
#### **Install Ops Agent via GUI:**
1. **Go to Monitoring:**
   - In the navigation menu, select **Monitoring**.
   - Navigate to the **Agents** tab.
2. **Install Agents:**
   - Locate **Ops Agent**.
   - Select your VM from the list and click **Install**. The agent will automatically install.

#### **Verify via SSH:**
1. Open the SSH terminal for your VM.
2. Run the following commands:
   - `top`: This displays a list of running processes, similar to a task manager.
   - `free -h`: This shows the system’s free and used memory.

---

### **4. Set Up Monitoring and Alerting**
#### **Create Alerting Policy:**
1. **Navigate to Monitoring:**
   - In the navigation menu, select **Monitoring** > **Alerting**.
2. **Create a Policy:**
   - Click the blue **Create Policy** button.
   - Add a condition:
     - Click **Add Condition**.
     - Under **Find Resource Type and Metric**, search for `apache.traffic`.
     - Select `apache.traffic` as the metric.
     - Set a **Rolling Window** to 1 minute.
     - Configure the **Trigger** to activate when the traffic exceeds `100 bytes/sec`.
   - Click **Save**.
3. **Set Notification Channel:**
   - Under **Notifications**, click **Add Notification Channel**.
   - Choose **Email**.
   - Enter your email address and click **Save**.
4. **Save the Policy:**
   - Review the policy and click **Create Policy**.

---

### **5. Install Apache and Collect Metrics**
1. **Install Apache on Your VM:**
   - Open the SSH terminal for your VM.
   - Run the following commands:
     ```bash
     sudo apt update
     sudo apt install apache2 -y
     ```
   - Start the Apache service:
     ```bash
     sudo systemctl start apache2
     ```
2. **Configure Ops Agent for Apache:**
   - In the **Monitoring** > **Agents** tab, find **Configuration** for Apache.
   - Follow the on-screen instructions to configure Apache monitoring.

---

### **6. Generate Apache Traffic and Trigger Alerts**
#### **Simulate Traffic:**
1. Open the SSH terminal for your VM.
2. Run the following command:
   ```bash
   for i in {1..100}; do curl http://localhost; done
   ```

#### **Trigger Alerts:**
1. Install a stress testing tool:
   ```bash
   sudo apt install stress -y
   ```
2. Run a stress test:
   ```bash
   stress --cpu 2 --timeout 60
   ```
3. Check the **Monitoring Dashboard** or your email for triggered alerts.

---

### **7. Latency Check**
1. **Monitor Latency:**
   - In **Monitoring**, go to **Dashboards**.
   - Add a new widget for **Latency**.
   - Observe the latency during the traffic generation.

---

### **8. Create Load Balancer**
#### **Set Up a Load Balancer:**
1. **Navigate to Network Services:**
   - In the navigation menu, go to **Network Services** > **Load Balancing**.
2. **Create Load Balancer:**
   - Click **Create Load Balancer**.
   - Select **HTTP(S) Load Balancer**.
3. **Configure the Backend:**
   - Create a **Backend Service**:
     - Click **Create Backend Service**.
     - Select your instance group or individual VM as the backend.
   - Set a **Health Check**:
     - Click **Create Health Check** and follow the steps to set up a basic health check.
4. **Configure the Frontend:**
   - Assign a static IP or allow auto-assigned.
   - Enable HTTP or HTTPS traffic.
5. **Review and Create:**
   - Review the setup and click **Create**.

---

### **Final Goal: Verify Alerts and Notifications**
1. Generate load on the VM (using Apache traffic or stress tests).
2. Monitor the **Dashboards** for metrics and latency.
3. Confirm that email notifications are triggered for your alerting policy.

<!-- Do all via gui.

Create vm with no public ip
ping google - it fails (no traffic access)
cloud nat config to give it access

Check observability after installing ops agent
ssh and use these to see the details
top // task manager
free -h // free memory

Monitering - Alerting - Edit notification - email
Google cloud quikstart link (Collect apache metrics quickstart) - Creation of ops agent to collect telemetry from app
Monitoring dashboard - review "apache gce overview"

Create alerting policy
add metric - apache traffic
rolling window - 1 min
configure trigger - threshold 100 B/s = next
notification channel (self conf) - create policy

generate curl traffic - code from quickstart

Go dashboard - Apache overview (fails)
Goal - Trigger some alert and check mail notification

triggered with cpu stress test.

Latency check. 

create load load balancer, its other requirements - all using gui -->
