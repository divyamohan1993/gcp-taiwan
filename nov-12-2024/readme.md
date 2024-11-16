### Documentation: Setting Up a Public Load Balancer with Internal Backend Instances

#### Objective:
This guide explains how to set up a **public HTTP(S) load balancer** that exposes a public IP address while ensuring that the backend instances remain secure with **internal IPs only**. The load balancer is configured to autoscale between 1 and 5 instances based on CPU utilization of 60%.

---

### Key Concepts:
1. **Public Load Balancer**:
   - A globally accessible load balancer with a public IP address.
   - Handles traffic from the internet and routes it to the backend instances.
2. **Internal-Only Backend Instances**:
   - Instances only have internal IPs for security, ensuring they are not directly accessible from the internet.
3. **Autoscaling**:
   - Automatically adjusts the number of backend instances based on CPU usage.
   - Minimum of 1 instance and maximum of 5 instances.

---

### Script for Setup

```bash
#!/bin/bash

# Step 1: Create an instance template with Apache setup (internal IP only)
gcloud compute instance-templates create apache-template \
    --machine-type=e2-micro \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt update && apt install -y apache2
      systemctl start apache2
      echo "<html><body><h1>Apache Server on $(hostname)</h1></body></html>" > /var/www/html/index.html' \
    --no-address

# Step 2: Create a managed instance group
gcloud compute instance-groups managed create apache-group \
    --template=apache-template \
    --size=1 \
    --zone=asia-east1-a

# Step 3: Set up autoscaling
gcloud compute instance-groups managed set-autoscaling apache-group \
    --zone=asia-east1-a \
    --min-num-replicas=1 \
    --max-num-replicas=5 \
    --target-cpu-utilization=0.6

# Step 4: Create a health check (HTTP for external load balancer)
gcloud compute health-checks create http apache-health-check \
    --request-path="/" \
    --port=80

# Step 5: Create a backend service for the load balancer
gcloud compute backend-services create apache-backend \
    --protocol=HTTP \
    --health-checks=apache-health-check \
    --global

# Step 6: Add the instance group to the backend service
gcloud compute backend-services add-backend apache-backend \
    --instance-group=apache-group \
    --instance-group-zone=asia-east1-a \
    --global

# Step 7: Create a URL map for routing traffic to the backend service
gcloud compute url-maps create apache-url-map \
    --default-service=apache-backend

# Step 8: Create an HTTP target proxy
gcloud compute target-http-proxies create apache-http-proxy \
    --url-map=apache-url-map

# Step 9: Create a global forwarding rule to assign a public IP to the load balancer
gcloud compute forwarding-rules create apache-lb \
    --global \
    --target-http-proxy=apache-http-proxy \
    --ports=80

# Step 10: Display the public IP of the load balancer
echo "Fetching the public IP of the load balancer..."
gcloud compute forwarding-rules list --filter="name=apache-lb" --format="value(IPAddress)"
```

---

### Usage Instructions:
1. **Save the Script**:
   - Copy the above script into a file named `setup.sh`.
2. **Make the Script Executable**:
   - Run the following command:
     ```bash
     chmod +x setup.sh
     ```
3. **Run the Script**:
   - Execute the script:
     ```bash
     ./setup.sh
     ```

---

### Expected Output:
- After running the script, the public IP of the load balancer will be displayed:
  ```bash
  Fetching the public IP of the load balancer...
  <PUBLIC_IP_ADDRESS>
  ```
- You can visit the Apache HTML page by navigating to `http://<PUBLIC_IP_ADDRESS>` in a web browser.

---

### Key Features:
1. **Public Access**:
   - The load balancer can be accessed from anywhere in the world.
2. **Secure Backend**:
   - Instances are only reachable via the load balancer due to their internal IPs.
3. **Dynamic Autoscaling**:
   - The number of instances adjusts automatically between 1 and 5 based on the CPU utilization.

---

### Notes for Students:
- **Scaling Behavior**: Start with a single instance and increase load to observe autoscaling in action.
- **Monitoring**: Use the **Google Cloud Console** to monitor instance creation and CPU usage.
- **Cost Management**: Delete resources when not in use to avoid charges (refer to the deletion script below).

---

### Deletion Script:
To clean up all resources created by the setup script, use the following script:

```bash
#!/bin/bash

# Step 1: Delete the forwarding rule
gcloud compute forwarding-rules delete apache-lb --global --quiet

# Step 2: Delete the HTTP target proxy
gcloud compute target-http-proxies delete apache-http-proxy --quiet

# Step 3: Delete the URL map
gcloud compute url-maps delete apache-url-map --quiet

# Step 4: Remove the instance group from the backend service
gcloud compute backend-services remove-backend apache-backend \
    --instance-group=apache-group \
    --instance-group-zone=asia-east1-a \
    --global --quiet

# Step 5: Delete the backend service
gcloud compute backend-services delete apache-backend --global --quiet

# Step 6: Delete the health check
gcloud compute health-checks delete apache-health-check --quiet

# Step 7: Delete the managed instance group
gcloud compute instance-groups managed delete apache-group --zone=asia-east1-a --quiet

# Step 8: Delete the instance template
gcloud compute instance-templates delete apache-template --quiet

echo "All resources have been deleted successfully."
```

### Usage Instructions for Deletion:
1. Save the script as `delete.sh`.
2. Make it executable:
   ```bash
   chmod +x delete.sh
   ```
3. Run the script:
   ```bash
   ./delete.sh
   ```

---