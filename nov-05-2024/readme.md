# **Configure Load Balancer and Autoscaling Instance Group**

---

## **Objective**

1. Deploy an instance template to automatically install a web server (Apache).  
2. Configure a **managed instance group** with autoscaling enabled (scaling between 1 to 5 instances).  
3. Set up a **Load Balancer** to distribute incoming traffic across instances.  
4. Use **CPU load** and **network traffic** as scaling metrics.

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:
   - A GCP project with billing enabled.  
   - Install and initialize the `gcloud` CLI:
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable monitoring.googleapis.com
   gcloud services enable logging.googleapis.com
   ```

3. **IAM Permissions**:
   Ensure you have permissions to create instance templates, instance groups, and load balancers.

---

## **Step 1: Create an Instance Template**

The instance template will define the VM configuration and include a startup script to install **Apache**.

1. **Create the Template**:
   ```bash
   gcloud compute instance-templates create web-server-template \
       --machine-type=e2-micro \
       --image-family=ubuntu-2204-lts \
       --image-project=ubuntu-os-cloud \
       --tags=http-server \
       --metadata=startup-script='#!/bin/bash
       apt-get update
       apt-get install -y apache2
       echo "<h1>Welcome to Apache Server - Instance $(hostname)</h1>" > /var/www/html/index.html
       systemctl start apache2
       systemctl enable apache2'
   ```

---

## **Step 2: Create a Managed Instance Group (MIG) with Autoscaling**

1. **Create the Managed Instance Group**:
   ```bash
   gcloud compute instance-groups managed create web-server-group \
       --base-instance-name=web-server \
       --template=web-server-template \
       --size=1 \
       --zone=us-central1-a
   ```

2. **Set Up Autoscaling**:  
   Configure autoscaling based on **CPU utilization** and **network traffic**.

   ```bash
   gcloud compute instance-groups managed set-autoscaling web-server-group \
       --zone=us-central1-a \
       --max-num-replicas=5 \
       --min-num-replicas=1 \
       --target-cpu-utilization=0.6 \
       --target-load-balancing-utilization=0.8 \
       --cool-down-period=60
   ```

   **Explanation**:
   - `--max-num-replicas=5`: Maximum number of instances.  
   - `--min-num-replicas=1`: Minimum number of instances.  
   - `--target-cpu-utilization=0.6`: Scale when CPU load exceeds 60%.  
   - `--target-load-balancing-utilization=0.8`: Scale when network traffic exceeds 80% of the VM's capacity.  
   - `--cool-down-period=60`: Wait time before re-evaluating scaling.

---

## **Step 3: Configure Firewall Rules**

Allow HTTP traffic to the instance group.

```bash
gcloud compute firewall-rules create allow-http \
    --network=default \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server
```

---

## **Step 4: Configure the Load Balancer**

1. **Create a Health Check**:
   ```bash
   gcloud compute health-checks create http http-health-check \
       --port=80 \
       --request-path="/"
   ```

2. **Create a Backend Service**:
   Link the health check to the managed instance group.

   ```bash
   gcloud compute backend-services create web-backend-service \
       --protocol=HTTP \
       --health-checks=http-health-check \
       --global
   ```

   Add the instance group to the backend service:

   ```bash
   gcloud compute backend-services add-backend web-backend-service \
       --instance-group=web-server-group \
       --instance-group-zone=us-central1-a \
       --global
   ```

3. **Create a URL Map**:
   ```bash
   gcloud compute url-maps create web-url-map \
       --default-service=web-backend-service
   ```

4. **Create a Target HTTP Proxy**:
   ```bash
   gcloud compute target-http-proxies create web-http-proxy \
       --url-map=web-url-map
   ```

5. **Create a Global Forwarding Rule**:
   ```bash
   gcloud compute forwarding-rules create web-forwarding-rule \
       --global \
       --target-http-proxy=web-http-proxy \
       --ports=80
   ```

---

## **Step 5: Verify the Load Balancer and Autoscaling**

1. **Get the Load Balancer's IP Address**:
   ```bash
   gcloud compute forwarding-rules list --global
   ```

   - Look for the **"IP Address"** field.

2. Open the **Load Balancer IP** in a browser:  
   ```
   http://<LOAD_BALANCER_IP>
   ```

3. **Test Autoscaling**:  
   Simulate high CPU load or network traffic to trigger autoscaling:
   - SSH into a VM in the instance group:
     ```bash
     gcloud compute ssh web-server-<ID> --zone=us-central1-a
     ```
   - Run the following command to simulate high CPU load:
     ```bash
     yes > /dev/null &
     ```

4. Monitor scaling activity:
   ```bash
   gcloud compute instance-groups managed describe web-server-group --zone=us-central1-a
   ```

   The group size will increase as per the configured autoscaling rules.

---

## **Step 6: Cleanup**

1. **Delete the Managed Instance Group**:
   ```bash
   gcloud compute instance-groups managed delete web-server-group --zone=us-central1-a
   ```

2. **Delete the Load Balancer**:
   ```bash
   gcloud compute forwarding-rules delete web-forwarding-rule --global
   gcloud compute target-http-proxies delete web-http-proxy
   gcloud compute url-maps delete web-url-map
   gcloud compute backend-services delete web-backend-service --global
   gcloud compute health-checks delete http-health-check
   ```

3. **Delete Firewall Rules**:
   ```bash
   gcloud compute firewall-rules delete allow-http
   ```

4. **Delete the Instance Template**:
   ```bash
   gcloud compute instance-templates delete web-server-template
   ```

---

## **Summary**

1. An **instance template** was created to deploy VMs with Apache installed via a startup script.  
2. A **managed instance group (MIG)** was configured to autoscale between 1 and 5 instances based on **CPU utilization** and **network traffic**.  
3. A **Load Balancer** was set up to distribute traffic across the autoscaling instances.  
4. Scaling behavior was tested, and the setup ensures high availability and performance.

The Load Balancer will now automatically handle traffic while the instance group scales as needed! 🎉