### Documentation: Creating an Autoscaling Managed Instance Group with an Internal Load Balancer

#### Objective:
This script demonstrates how to create an autoscaling managed instance group (1–3 instances) based on CPU utilization, with an internal load balancer to serve Apache HTML pages. 

---

### Script to Set Up Resources:

```bash
#!/bin/bash

# Step 1: Create an instance template with Apache setup
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
    --max-num-replicas=3 \
    --target-cpu-utilization=0.6

# Step 4: Create a health check
gcloud compute health-checks create http apache-health-check --port=80

# Step 5: Create an internal backend service
gcloud compute backend-services create apache-backend \
    --load-balancing-scheme=INTERNAL \
    --protocol=HTTP \
    --health-checks=apache-health-check \
    --region=asia-east1

# Step 6: Add instance group to backend service
gcloud compute backend-services add-backend apache-backend \
    --instance-group=apache-group \
    --instance-group-zone=asia-east1-a \
    --region=asia-east1

# Step 7: Create a URL map and HTTP proxy
gcloud compute url-maps create apache-url-map --default-service=apache-backend
gcloud compute target-http-proxies create apache-proxy --url-map=apache-url-map

# Step 8: Create a forwarding rule for the internal load balancer
gcloud compute forwarding-rules create apache-lb \
    --load-balancing-scheme=INTERNAL \
    --ports=80 \
    --region=asia-east1 \
    --target-http-proxy=apache-proxy \
    --subnet=default

# Step 9: Display the internal load balancer IP
echo "Fetching the internal load balancer IP..."
gcloud compute forwarding-rules list --filter="name=apache-lb" --format="value(IPAddress)"
```

---

### Usage Instructions:
1. **Save the Script**: Copy the above script into a file named `setup.sh`.
2. **Make it Executable**: Run the command:
   ```bash
   chmod +x setup.sh
   ```
3. **Run the Script**: Execute the script:
   ```bash
   ./setup.sh
   ```
4. **Observe the Output**: The script will display the internal load balancer's IP address once the setup is complete.

---

### What This Script Does:
1. **Instance Template**:
   - Creates an instance template with Apache installed and configured to serve a basic HTML page.
2. **Managed Instance Group**:
   - Sets up a managed instance group with autoscaling capabilities.
   - Autoscaling thresholds are configured to trigger when CPU usage exceeds 60%.
3. **Internal Load Balancer**:
   - Configures a load balancer that routes requests internally among the autoscaled instances.
4. **Health Check**:
   - Ensures instances are monitored for availability.
5. **IP Display**:
   - Outputs the IP address of the internal load balancer for easy access.

---