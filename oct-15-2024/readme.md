
# **Deploy VM, Google Cloud SQL, and Connect with PHP**

---

## **Objective**  
1. Deploy a VM instance that runs an Apache and PHP server.  
2. Deploy a Google Cloud SQL instance (MySQL).  
3. Use a PHP script on the VM to connect to the Cloud SQL database and display demo content.

---

## **Prerequisites**

1. **Google Cloud Platform Setup**:  
   - Ensure billing is enabled on your GCP project.  
   - Install and initialize the `gcloud` CLI:  
     ```bash
     gcloud init
     ```

2. **Enable Required APIs**:  
   Enable the Compute Engine and Cloud SQL APIs:  
   ```bash
   gcloud services enable compute.googleapis.com sqladmin.googleapis.com
   ```

3. **IAM Permissions**:  
   Ensure you have sufficient permissions to create VM instances and Cloud SQL instances.

---

## **Step 1: Create a Google Cloud SQL Instance**

Create a **Cloud SQL MySQL instance**:

1. **Using `gcloud` CLI**:  
   ```bash
   gcloud sql instances create my-sql-instance \
       --tier=db-f1-micro \
       --region=us-central1 \
       --database-version=MYSQL_8_0
   ```

2. **Set a Root Password**:  
   ```bash
   gcloud sql users set-password root --host=% --instance=my-sql-instance --password=root123
   ```

3. **Create a Database and Table**:  
   Use the Cloud SQL command-line client to access the instance:  
   ```bash
   gcloud sql connect my-sql-instance --user=root
   ```
   Run the following SQL commands to create a database and table:
   ```sql
   CREATE DATABASE demo_db;
   USE demo_db;
   CREATE TABLE users (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100));
   INSERT INTO users (name) VALUES ('John Doe'), ('Jane Smith');
   ```

---

## **Step 2: Create a VM Instance with PHP and Apache**

1. **Startup Script to Install Apache and PHP**:  
   Create a file `startup-script.sh` with the following content:

   ```bash
   #!/bin/bash
   apt-get update
   apt-get install -y apache2 php libapache2-mod-php php-mysql curl

   # Start Apache service
   systemctl start apache2
   systemctl enable apache2

   # Create a PHP file to connect to Cloud SQL
   cat <<EOF > /var/www/html/index.php
   <?php
   \$db_host = 'YOUR_CLOUD_SQL_IP';
   \$db_user = 'root';
   \$db_password = 'root123';
   \$db_name = 'demo_db';

   // Connect to Cloud SQL
   \$conn = new mysqli(\$db_host, \$db_user, \$db_password, \$db_name);
   if (\$conn->connect_error) {
       die("Connection failed: " . \$conn->connect_error);
   }

   // Fetch data
   \$result = \$conn->query("SELECT * FROM users");
   if (\$result->num_rows > 0) {
       echo "<h1>Demo Content from Cloud SQL</h1>";
       while (\$row = \$result->fetch_assoc()) {
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
   ```

   Replace `YOUR_CLOUD_SQL_IP` with the **public IP** of the Cloud SQL instance.

---

2. **Deploy the VM Instance**:  

Run the following `gcloud` command to create a VM instance with the startup script:

```bash
gcloud compute instances create apache-php-vm \
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

1. Allow HTTP traffic to the VM using firewall rules:

```bash
gcloud compute firewall-rules create allow-http \
    --direction=INGRESS \
    --action=ALLOW \
    --rules=tcp:80 \
    --target-tags=http-server
```

---

## **Step 4: Configure Cloud SQL to Allow Connections**

1. **Add the VM's Public IP to the Cloud SQL Authorized Networks**:

   Retrieve the **external IP** of the VM:
   ```bash
   gcloud compute instances list
   ```

   Add the IP to Cloud SQL authorized networks:
   ```bash
   gcloud sql instances patch my-sql-instance \
       --authorized-networks=<VM_EXTERNAL_IP>
   ```

---

## **Step 5: Test the Setup**

1. Open the **external IP** of the VM in a browser:  
   ```
   http://<VM_EXTERNAL_IP>
   ```

2. You should see the PHP page displaying data fetched from Google Cloud SQL:

```
Demo Content from Cloud SQL
ID: 1 - Name: John Doe
ID: 2 - Name: Jane Smith
```

---

## **Step 6: Cleanup**

1. **Delete the VM Instance**:  
   ```bash
   gcloud compute instances delete apache-php-vm --zone=us-central1-a
   ```

2. **Delete the Cloud SQL Instance**:  
   ```bash
   gcloud sql instances delete my-sql-instance
   ```

---

## **Summary**

1. **Cloud SQL** is created and configured to host a MySQL database.  
2. A **VM instance** is deployed with Apache, PHP, and a startup script to create a PHP file.  
3. The PHP script connects to the **Cloud SQL instance** and displays demo content fetched from a database table.  
4. HTTP access is configured using firewall rules.
