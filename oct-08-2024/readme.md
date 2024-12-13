
# **Deploy VM Instance with Apache, PHP, MariaDB, and Dynv6 Dynamic IP**

---

## **Objective**  
1. Deploy a VM that runs an Apache and PHP server using a **startup script**.  
2. Install **MariaDB** locally, create a table with sample data, and display it using PHP.  
3. Update the Dynv6 dynamic DNS hostname with the VM's external IP.

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:  
   - GCP project initialized and billing enabled.  
   - Install and initialize `gcloud`:  
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:  
   Enable the Compute Engine API.  
   ```bash
   gcloud services enable compute.googleapis.com
   ```

3. **Dynv6 Account**:  
   - Sign up at [dynv6](https://dynv6.com).  
   - Generate a **Dynv6 API token**.  
   - Create a **hostname** (e.g., `example.dynv6.net`).

---

## **Step 1: Create the Startup Script**

The startup script will:  
- Install **Apache**, **PHP**, and **MariaDB**.  
- Set up the MariaDB database with sample data.  
- Create a PHP file that fetches and displays content from the database.  
- Update the **Dynv6 hostname** with the VM's public IP.

### **Startup Script**  

Create a file `startup-script.sh` locally with the following content:

```bash
#!/bin/bash

# Update package list and install Apache, PHP, MariaDB
apt-get update
apt-get install -y apache2 php libapache2-mod-php mariadb-server php-mysql curl

# Start Apache and MariaDB services
systemctl start apache2
systemctl enable apache2
systemctl start mariadb
systemctl enable mariadb

# Configure MariaDB - Set root password and create database/table
mysql -e "UPDATE mysql.user SET Password=PASSWORD('root123') WHERE User='root';"
mysql -e "FLUSH PRIVILEGES;"
mysql -e "CREATE DATABASE demo_db;"
mysql -e "USE demo_db; CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));"
mysql -e "INSERT INTO users (name) VALUES ('John Doe'), ('Jane Smith');"

# Create PHP file to fetch data from MariaDB
cat <<EOF > /var/www/html/index.php
<?php
\$conn = new mysqli('localhost', 'root', 'root123', 'demo_db');
if (\$conn->connect_error) {
    die("Connection failed: " . \$conn->connect_error);
}
\$result = \$conn->query("SELECT * FROM users");
if (\$result->num_rows > 0) {
    echo "<h1>Demo Content from MariaDB</h1>";
    while(\$row = \$result->fetch_assoc()) {
        echo "ID: " . \$row["id"] . " - Name: " . \$row["name"] . "<br>";
    }
} else {
    echo "No data found.";
}
\$conn->close();
?>
EOF

# Restart Apache to apply changes
systemctl restart apache2

# Update Dynv6 Dynamic DNS with the public IP
PUBLIC_IP=$(curl -s ifconfig.me)
DYNV6_TOKEN="YOUR_DYNV6_TOKEN"
DYNV6_HOSTNAME="YOUR_DYNV6_HOSTNAME"

curl "https://dynv6.com/api/update?hostname=${DYNV6_HOSTNAME}&token=${DYNV6_TOKEN}&ipv4=${PUBLIC_IP}"

# Log Dynv6 update
echo "Dynv6 updated with IP: ${PUBLIC_IP}" >> /var/log/startup-script.log
```

**Replace**:  
- `YOUR_DYNV6_TOKEN` with your Dynv6 token.  
- `YOUR_DYNV6_HOSTNAME` with your Dynv6 hostname.

---

## **Step 2: Create the VM Instance**

Run the following command to deploy the VM instance with the startup script:

```bash
gcloud compute instances create apache-php-mariadb-vm \
    --zone=us-central1-a \
    --machine-type=e2-micro \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --tags=http-server \
    --metadata-from-file startup-script=startup-script.sh \
    --boot-disk-size=10GB
```

---

## **Step 3: Allow HTTP Traffic**

If HTTP traffic is not already allowed, create a firewall rule:

```bash
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --target-tags=http-server
```

---

## **Step 4: Verify the Deployment**

1. Find the external IP of your VM instance:  
   ```bash
   gcloud compute instances list
   ```

2. Open the IP address in a browser:  
   ```
   http://<EXTERNAL-IP>
   ```

3. You should see a **PHP page** displaying data fetched from MariaDB:

```
Demo Content from MariaDB
ID: 1 - Name: John Doe
ID: 2 - Name: Jane Smith
```

4. Verify that your Dynv6 hostname is updated:  
   Open your hostname URL:  
   ```
   http://example.dynv6.net
   ```

   This should show the same Apache-PHP page with the database content.

---

## **Step 5: Automate Dynv6 Updates (Optional)**

To keep the Dynv6 hostname updated in case the public IP changes, set up a **cron job**.

1. SSH into the VM:  
   ```bash
   gcloud compute ssh apache-php-mariadb-vm --zone=us-central1-a
   ```

2. Edit the cron jobs:  
   ```bash
   crontab -e
   ```

3. Add the following line to update the IP every 10 minutes:  
   ```bash
   */10 * * * * curl "https://dynv6.com/api/update?hostname=YOUR_DYNV6_HOSTNAME&token=YOUR_DYNV6_TOKEN&ipv4=$(curl -s ifconfig.me)"
   ```

---

## **Step 6: Cleanup**

To delete the VM instance when no longer needed:  
```bash
gcloud compute instances delete apache-php-mariadb-vm --zone=us-central1-a
```

---

## **Summary**

1. A VM instance is deployed that runs **Apache** and **PHP**.  
2. **MariaDB** is installed locally, and a database table is created with sample content.  
3. A PHP file is created to fetch and display the data.  
4. Dynv6 updates the dynamic DNS hostname with the VM's public IP, ensuring consistent access.
