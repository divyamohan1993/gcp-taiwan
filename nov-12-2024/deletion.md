### Documentation: Deletion Script for Cleaning Up Resources

#### Objective:
This script removes all resources created by the setup script, ensuring a clean state in your Google Cloud project. The deletion script is essential for maintaining a clean Google Cloud environment, particularly after testing or temporary deployments.

---

### Deletion Script:

```bash
#!/bin/bash

# Step 1: Delete the forwarding rule
gcloud compute forwarding-rules delete apache-lb --region=asia-east1 --quiet

# Step 2: Delete the HTTP proxy
gcloud compute target-http-proxies delete apache-proxy --quiet

# Step 3: Delete the URL map
gcloud compute url-maps delete apache-url-map --quiet

# Step 4: Remove the instance group from the backend service
gcloud compute backend-services remove-backend apache-backend \
    --instance-group=apache-group \
    --instance-group-zone=asia-east1-a \
    --region=asia-east1 --quiet

# Step 5: Delete the backend service
gcloud compute backend-services delete apache-backend --region=asia-east1 --quiet

# Step 6: Delete the health check
gcloud compute health-checks delete apache-health-check --quiet

# Step 7: Delete the managed instance group
gcloud compute instance-groups managed delete apache-group --zone=asia-east1-a --quiet

# Step 8: Delete the instance template
gcloud compute instance-templates delete apache-template --quiet

echo "All resources have been deleted."
```

---

### Explanation of Steps:
1. **Forwarding Rule**:
   - Deletes the forwarding rule for the internal load balancer.
2. **HTTP Proxy**:
   - Deletes the HTTP proxy used by the load balancer.
3. **URL Map**:
   - Deletes the URL map that routes requests to backend services.
4. **Backend Service**:
   - Removes the instance group from the backend service and deletes the backend service.
5. **Health Check**:
   - Deletes the HTTP health check used to monitor the VM instances.
6. **Managed Instance Group**:
   - Deletes the managed instance group responsible for autoscaling.
7. **Instance Template**:
   - Deletes the instance template used to define VM configurations.

---

### Usage Instructions:
1. **Save the Script**:
   - Copy the above script into a file named `delete.sh`.
2. **Make it Executable**:
   - Run the command:
     ```bash
     chmod +x delete.sh
     ```
3. **Execute the Script**:
   - Run the script to delete all resources:
     ```bash
     ./delete.sh
     ```

---

### Key Features:
- **Automated Cleanup**:
  - Removes all resources created during setup.
- **Ensures No Residual Costs**:
  - Prevents unnecessary charges by deleting unused resources.
- **Quiet Execution**:
  - The `--quiet` flag suppresses confirmation prompts for seamless operation.

---