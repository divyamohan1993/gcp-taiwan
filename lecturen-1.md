Google Cloud `gcloud` shell script to create an autoscaling managed instance group with 1 to 3 VM instances, based on a 60% CPU load threshold, and map them to an internal load balancer to display their Apache HTML pages:

```bash
#!/bin/bash

# Variables
PROJECT_ID=$(gcloud config get-value project)
REGION="us-central1"
ZONE="us-central1-a"
INSTANCE_GROUP_NAME="apache-autoscale-group"
TEMPLATE_NAME="apache-template"
LB_NAME="internal-lb"
HEALTH_CHECK_NAME="apache-health-check"
BACKEND_SERVICE_NAME="apache-backend-service"

# Step 1: Create an instance template
gcloud compute instance-templates create $TEMPLATE_NAME \
    --region=$REGION \
    --machine-type=e2-medium \
    --image-family=debian-11 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt update
      apt install -y apache2
      systemctl start apache2
      echo "<html><body><h1>Welcome to $(hostname)</h1></body></html>" > /var/www/html/index.html' \
    --tags=http-server \
    --network=default \
    --no-address

# Step 2: Create a managed instance group
gcloud compute instance-groups managed create $INSTANCE_GROUP_NAME \
    --base-instance-name=apache-instance \
    --template=$TEMPLATE_NAME \
    --size=1 \
    --zone=$ZONE

# Step 3: Configure autoscaling
gcloud compute instance-groups managed set-autoscaling $INSTANCE_GROUP_NAME \
    --zone=$ZONE \
    --min-num-replicas=1 \
    --max-num-replicas=3 \
    --target-cpu-utilization=0.6 \
    --cool-down-period=60

# Step 4: Create a health check
gcloud compute health-checks create http $HEALTH_CHECK_NAME \
    --check-interval=10 \
    --timeout=5 \
    --unhealthy-threshold=2 \
    --healthy-threshold=2 \
    --port=80 \
    --request-path="/"

# Step 5: Create a backend service
gcloud compute backend-services create $BACKEND_SERVICE_NAME \
    --load-balancing-scheme=INTERNAL \
    --protocol=HTTP \
    --health-checks=$HEALTH_CHECK_NAME \
    --region=$REGION

# Step 6: Add the instance group to the backend service
gcloud compute backend-services add-backend $BACKEND_SERVICE_NAME \
    --instance-group=$INSTANCE_GROUP_NAME \
    --instance-group-zone=$ZONE \
    --region=$REGION

# Step 7: Create a URL map
gcloud compute url-maps create apache-url-map \
    --default-service=$BACKEND_SERVICE_NAME

# Step 8: Create an HTTP proxy
gcloud compute target-http-proxies create apache-http-proxy \
    --url-map=apache-url-map

# Step 9: Create a forwarding rule for the internal load balancer
gcloud compute forwarding-rules create $LB_NAME \
    --load-balancing-scheme=INTERNAL \
    --ports=80 \
    --region=$REGION \
    --target-http-proxy=apache-http-proxy \
    --subnet=default

echo "Load balancer and autoscaling instance group have been set up successfully."
```

### Steps in the Script:
1. **Instance Template**: Creates VMs with Apache installed, running a basic HTML page.
2. **Managed Instance Group**: Sets up the group of VMs for autoscaling.
3. **Autoscaling**: Configures autoscaling based on CPU utilization.
4. **Health Check**: Verifies VM health via HTTP on port 80.
5. **Backend Service**: Links the instance group to the load balancer.
6. **Load Balancer Configuration**: Sets up an internal HTTP load balancer with a forwarding rule.

### Usage:
1. Save the script as `setup.sh` and make it executable: `chmod +x setup.sh`.
2. Run the script: `./setup.sh`.

After running, the internal load balancer will distribute traffic across the VM instances based on CPU load and serve their Apache HTML pages.
