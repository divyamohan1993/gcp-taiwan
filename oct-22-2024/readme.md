# **Deploy 2 VMs in Different Subnets, Configure MariaDB and Apache**

---

## **Objective**

1. Create two VMs:  
   - **VM-1**: Install **MariaDB** in subnet `192.*` (e.g., `192.168.1.0/24`).  
   - **VM-2**: Install **Apache** in subnet `10.*` (e.g., `10.0.1.0/24`).  

2. Configure firewalls and routes to allow connectivity between the VMs.  
3. Allow **VM-2** to connect to MariaDB running on **VM-1**.

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:
   - GCP project with billing enabled.  
   - Install and configure `gcloud` CLI:
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:
   ```bash
   gcloud services enable compute.googleapis.com
   ```

3. **IAM Permissions**:
   Ensure permissions to create VMs, VPC networks, subnets, and firewall rules.

---

## **Step 1: Create a VPC Network and Subnets**

1. **Create a VPC Network**:
   ```bash
   gcloud compute networks create custom-vpc --subnet-mode=custom
   ```

2. **Create Subnet-1 (192.*)**:
   ```bash
   gcloud compute networks subnets create subnet-192 \
       --network=custom-vpc \
       --range=192.168.1.0/24 \
       --region=us-central1
   ```

3. **Create Subnet-2 (10.*)**:
   ```bash
   gcloud compute networks subnets create subnet-10 \
       --network=custom-vpc \
       --range=10.0.1.0/24 \
       --region=us-central1
   ```

---

## **Step 2: Create Two VM Instances**

### **Create VM-1 (MariaDB Server in Subnet-192)**

```bash
gcloud compute instances create mariadb-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --subnet=subnet-192 \
    --metadata=startup-script='#! /bin/bash
        apt-get update
        apt-get install -y mariadb-server
        systemctl start mariadb
        systemctl enable mariadb
        mysql -e "CREATE DATABASE demo_db;"
        mysql -e "CREATE USER '\''apacheuser'\''@'\''10.0.1.%'\'' IDENTIFIED BY '\''password123'\'';"
        mysql -e "GRANT ALL PRIVILEGES ON demo_db.* TO '\''apacheuser'\''@'\''10.0.1.%'\'';"
        mysql -e "FLUSH PRIVILEGES;"
        echo "MariaDB setup complete."
    ' \
    --tags=mariadb-server \
    --boot-disk-size=10GB
```

---

### **Create VM-2 (Apache Server in Subnet-10)**

```bash
gcloud compute instances create apache-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --subnet=subnet-10 \
    --metadata=startup-script='#! /bin/bash
        apt-get update
        apt-get install -y apache2 php php-mysql
        systemctl start apache2
        systemctl enable apache2
        echo "<?php
        \$conn = new mysqli(\"192.168.1.2\", \"apacheuser\", \"password123\", \"demo_db\");
        if (\$conn->connect_error) { die(\"Connection failed: \" . \$conn->connect_error); }
        echo \"<h1>Data from MariaDB</h1>\";
        \$result = \$conn->query(\"SHOW DATABASES\");
        while (\$row = \$result->fetch_assoc()) {
            echo \"Database: \" . \$row[\"Database\"] . \"<br>\";
        }
        ?>" > /var/www/html/index.php
    ' \
    --tags=apache-server \
    --boot-disk-size=10GB
```

---

## **Step 3: Configure Firewall Rules**

1. **Allow MariaDB Traffic (Port 3306) to Subnet-10**:
   ```bash
   gcloud compute firewall-rules create allow-mariadb \
       --network=custom-vpc \
       --allow=tcp:3306 \
       --source-ranges=10.0.1.0/24 \
       --target-tags=mariadb-server
   ```

2. **Allow HTTP Traffic to Apache Server**:
   ```bash
   gcloud compute firewall-rules create allow-http \
       --network=custom-vpc \
       --allow=tcp:80 \
       --source-ranges=0.0.0.0/0 \
       --target-tags=apache-server
   ```

---

## **Step 4: Verify Connectivity**

1. **Find Internal IPs**:
   - List the instances:
     ```bash
     gcloud compute instances list
     ```
   - Note the **internal IP** of `mariadb-vm` (e.g., `192.168.1.2`).

2. **Test Apache Server**:
   - Open the **external IP** of `apache-vm` in a browser:
     ```
     http://<APACHE-VM-EXTERNAL-IP>
     ```
   - You should see the output confirming the connection to MariaDB and listing the databases:
     ```
     Data from MariaDB
     Database: demo_db
     ```

---

## **Step 5: Cleanup (Optional)**

1. **Delete VMs**:
   ```bash
   gcloud compute instances delete mariadb-vm apache-vm --zone=us-central1-a
   ```

2. **Delete Firewall Rules**:
   ```bash
   gcloud compute firewall-rules delete allow-mariadb allow-http
   ```

3. **Delete VPC Network**:
   ```bash
   gcloud compute networks delete custom-vpc
   ```

---

## **Summary**

1. **Two VMs** were created in different subnets:  
   - `mariadb-vm` (Subnet: 192.168.1.0/24) hosting **MariaDB**.  
   - `apache-vm` (Subnet: 10.0.1.0/24) hosting **Apache** with PHP.

2. **Firewall Rules** were configured to allow:  
   - Port `3306` for MariaDB from `10.*` subnet.  
   - Port `80` for HTTP access to Apache.

3. The **PHP script** on the Apache server successfully connected to the **MariaDB server** and displayed demo data.

Your setup is now complete! 🎉