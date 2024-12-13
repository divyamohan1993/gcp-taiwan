# **Deploy a VM Without Public IP and Configure Cloud Router for Internet Access**

---

## **Objective**

1. Deploy a **VM instance** without a public IP.  
2. Configure a **Cloud Router** with **Cloud NAT** to provide internet access to the VM for outbound connections (e.g., software updates).

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:  
   - Ensure billing is enabled.  
   - Install and initialize `gcloud` CLI:  
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable compute.googleapis.com
   gcloud services enable compute.googleapis.com
   ```

3. **IAM Permissions**:
   Ensure permissions to create VPC networks, subnets, firewall rules, and instances.

---

## **Step 1: Create a VPC Network and Subnet**

1. **Create a Custom VPC Network**:
   ```bash
   gcloud compute networks create private-vpc \
       --subnet-mode=custom
   ```

2. **Create a Subnet Without Public IP**:
   - Assign a subnet range (e.g., `10.0.0.0/24`) and **disable external IPs**.

   ```bash
   gcloud compute networks subnets create private-subnet \
       --network=private-vpc \
       --range=10.0.0.0/24 \
       --region=us-central1 \
       --no-public-ip
   ```

---

## **Step 2: Configure Cloud Router and Cloud NAT**

### **1. Create a Cloud Router**
A Cloud Router is required to manage Cloud NAT for dynamic routing.

```bash
gcloud compute routers create private-router \
    --network=private-vpc \
    --region=us-central1 \
    --asn=65000
```

### **2. Create a Cloud NAT**
Cloud NAT will provide internet access to VMs without public IPs.

```bash
gcloud compute routers nats create private-nat \
    --router=private-router \
    --region=us-central1 \
    --nat-all-subnet-ip-ranges \
    --auto-allocate-nat-external-ips
```

**Explanation**:
- `--nat-all-subnet-ip-ranges` allows NAT to handle traffic for all subnets in the VPC.
- `--auto-allocate-nat-external-ips` allocates external IPs for NAT dynamically.

---

## **Step 3: Create a VM Instance Without Public IP**

1. Deploy a VM in the `private-subnet` without an external IP:

```bash
gcloud compute instances create private-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --subnet=private-subnet \
    --no-address \
    --tags=private-vm \
    --boot-disk-size=10GB \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud
```

---

## **Step 4: Allow Firewall Rules for Internal and Internet Access**

1. **Allow SSH Access** to the VM from the internal network:
   ```bash
   gcloud compute firewall-rules create allow-internal-ssh \
       --network=private-vpc \
       --allow=tcp:22 \
       --source-ranges=10.0.0.0/24 \
       --target-tags=private-vm
   ```

2. **Allow Outbound Traffic for NAT** (default egress is allowed):  
   No additional rules are required for outbound NAT.

---

## **Step 5: Verify Internet Access**

1. **SSH into the VM**:  
   Use a **bastion host** or another VM with a public IP to SSH into the private VM.

   - **Example**: SSH using IAP (Identity-Aware Proxy):
     ```bash
     gcloud compute ssh private-vm --zone=us-central1-a --tunnel-through-iap
     ```

2. **Check Internet Access**:
   Run the following command to test outbound internet connectivity:

   ```bash
   curl -I http://google.com
   ```

   - If successful, you will see a response header indicating an HTTP `200 OK`.

---

## **Step 6: Cleanup**

1. **Delete the VM**:
   ```bash
   gcloud compute instances delete private-vm --zone=us-central1-a
   ```

2. **Delete the Cloud NAT and Router**:
   ```bash
   gcloud compute routers nats delete private-nat --router=private-router --region=us-central1
   gcloud compute routers delete private-router --region=us-central1
   ```

3. **Delete the VPC Network**:
   ```bash
   gcloud compute networks delete private-vpc
   ```

---

## **Summary**

1. A **custom VPC network** was created with a subnet (`10.0.0.0/24`) where external IPs were disabled.  
2. A **Cloud Router** with **Cloud NAT** was configured to enable outbound internet access for the private subnet.  
3. A **VM** without a public IP was deployed and verified for internet access using NAT.

This setup is ideal for secure environments where VMs do not require public IPs but need outbound access to update software or access internet resources. 🎉