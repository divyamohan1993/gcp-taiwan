### Step 1: VPC Network Creation
To create the networks, use the following commands.

#### Command to create VPCs in GCP CLI
```bash
# Create myvpc1
gcloud compute networks create myvpc1 --subnet-mode=custom

# Create myvpc2
gcloud compute networks create myvpc2 --subnet-mode=custom
```

### Step 2: Create Subnets within Each VPC
Create a new subnet for `myvpc1` and `myvpc2`.

```bash
# Create subnet in myvpc1
gcloud compute networks subnets create myvpc1-subnet \
  --network=myvpc1 \
  --region=asia-east1 \
  --range=10.0.1.0/24

# Create subnet in myvpc2
gcloud compute networks subnets create myvpc2-subnet \
  --network=myvpc2 \
  --region=asia-east1 \
  --range=192.168.1.0/24
```

### Step 3: VPC Peering
Since you have successfully set up VPC peering, ensure the following command is used to peer `myvpc1` and `myvpc2` if needed.

```bash
# Peer myvpc1 to myvpc2
gcloud compute networks peerings create myvpc1-to-myvpc2 \
  --network=myvpc1 \
  --peer-network=myvpc2

# Peer myvpc2 to myvpc1
gcloud compute networks peerings create myvpc2-to-myvpc1 \
  --network=myvpc2 \
  --peer-network=myvpc1
```

### Step 4: Create Firewall Rules for VPCs

To allow necessary traffic within and between the networks, set up the firewall rules as follows.

#### Command to allow ICMP, SSH, and HTTP in myvpc1
```bash
# Allow ICMP in myvpc1
gcloud compute firewall-rules create myvpc1-allow-icmp \
  --network=myvpc1 \
  --allow=icmp

# Allow SSH in myvpc1
gcloud compute firewall-rules create myvpc1-allow-ssh \
  --network=myvpc1 \
  --allow=tcp:22

# Allow HTTP in myvpc1
gcloud compute firewall-rules create myvpc1-allow-http \
  --network=myvpc1 \
  --allow=tcp:80
```

#### Command to allow traffic on port 3306 for MySQL (or port 9000 as per the rule you created in `myvpc2`)
```bash
# Allow MySQL access in myvpc2
gcloud compute firewall-rules create myvpc2-allow-mysql \
  --network=myvpc2 \
  --allow=tcp:3306

# Allow SSH in myvpc2 
gcloud compute firewall-rules create myvpc2-allow-ssh --network=myvpc2 --allow=tcp:22
```

### Step 5: Create VM Instances

#### Create Database instance in myvpc2
You can either create a VM with MySQL or a Cloud SQL instance.

##### VM with MySQL (cheaper) - Manual Method
```bash
# Create Database VM in myvpc2
gcloud compute instances create database-vm \
  --zone=asia-east1-a \
  --machine-type=e2-micro \
  --subnet=myvpc2-subnet \
  --tags=mysql-server
```

Then, install MySQL on this VM:
```bash
sudo apt update
sudo apt install mariadb-server -y
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo mysql_secure_installation
```

##### VM with MySQL (cheaper) - Automatic Method

**Create the `mysql-setup.sh` Script** in Cloud Shell:
```bash
cat << 'EOF' > mysql-setup.sh
#!/bin/bash
# Update packages
sudo apt update

# Install MariaDB server
sudo apt install -y mariadb-server

# Start MariaDB service
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Secure MariaDB installation with predefined password
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345678';"
sudo mysql -e "DELETE FROM mysql.user WHERE User='';"
sudo mysql -e "DROP DATABASE IF EXISTS test;"
sudo mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Create a new database and table with dummy data
sudo mysql -uroot -p12345678 -e "
CREATE DATABASE example_db;
USE example_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (name, email) VALUES
('Alice', 'alice@example.com'),
('Bob', 'bob@example.com'),
('Charlie', 'charlie@example.com');
"
EOF
```

This script performs the following actions:
- **Updates the package list**.
- **Installs MariaDB** instead of MySQL.
- **Starts and enables MariaDB** to start on boot.
- **Secures MariaDB** with:
   - Setting the root password to `12345678`.
   - Removing anonymous users and test databases.
    
**Run the VM Creation Command** with the Startup Script:
   ```bash
   gcloud compute instances create database-vm \
     --zone=asia-east1-a \
     --machine-type=e2-micro \
     --subnet=myvpc2-subnet \
     --tags=mysql-server \
     --metadata-from-file startup-script=mysql-setup.sh
   ```

**Verify Installation**:
   - SSH into the VM to check if MariaDB is installed and configured:
     ```bash
     gcloud compute ssh database-vm --zone=asia-east1-a
     ```
   - Test the connection to MariaDB:
     ```bash
     sudo mysql -u root -p
     ```
   - Use `12345678` as the password to confirm that everything was set up correctly.

This script will automatically install and configure MariaDB on the VM creation, with no additional manual steps required!

#### Create HTTP server instances in myvpc1
```bash
# First HTTP VM in myvpc1
gcloud compute instances create http-server-1 \
  --zone=asia-east1-a \
  --machine-type=e2-micro \
  --subnet=myvpc1-subnet \
  --tags=http-server \
  --metadata startup-script='#!/bin/bash
    # Update packages
    sudo apt update

    # Install Apache and PHP
    sudo apt install -y apache2 php php-mysql

    # Start and enable Apache
    sudo systemctl start apache2
    sudo systemctl enable apache2

    # Create PHP file to fetch data from MariaDB
    cat <<EOF | sudo tee /var/www/html/dbdata.php
    <?php
    \$servername = "database-vm-ip";  // Replace with actual internal IP of database-vm
    \$username = "root";
    \$password = "12345678";
    \$dbname = "example_db";

    // Create connection
    \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

    // Check connection
    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }

    // Fetch data
    \$sql = "SELECT id, name, email, created_at FROM users";
    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        // Output data of each row
        while(\$row = \$result->fetch_assoc()) {
            echo "ID: " . \$row["id"]. " - Name: " . \$row["name"]. " - Email: " . \$row["email"]. " - Created At: " . \$row["created_at"]. "<br>";
        }
    } else {
        echo "0 results";
    }

    \$conn->close();
    ?>
    EOF'

# Second HTTP VM in myvpc1
gcloud compute instances create http-server-2 \
  --zone=asia-east1-a \
  --machine-type=e2-micro \
  --subnet=myvpc1-subnet \
  --tags=http-server \
  --metadata startup-script='#!/bin/bash
    # Update packages
    sudo apt update

    # Install Apache and PHP
    sudo apt install -y apache2 php php-mysql

    # Start and enable Apache
    sudo systemctl start apache2
    sudo systemctl enable apache2

    # Create PHP file to fetch data from MariaDB
    cat <<EOF | sudo tee /var/www/html/dbdata.php
    <?php
    \$servername = "database-vm-ip";  // Replace with actual internal IP of database-vm
    \$username = "root";
    \$password = "12345678";
    \$dbname = "example_db";

    // Create connection
    \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

    // Check connection
    if (\$conn->connect_error) {
        die("Connection failed: " . \$conn->connect_error);
    }

    // Fetch data
    \$sql = "SELECT id, name, email, created_at FROM users";
    \$result = \$conn->query(\$sql);

    if (\$result->num_rows > 0) {
        // Output data of each row
        while(\$row = \$result->fetch_assoc()) {
            echo "ID: " . \$row["id"]. " - Name: " . \$row["name"]. " - Email: " . \$row["email"]. " - Created At: " . \$row["created_at"]. "<br>";
        }
    } else {
        echo "0 results";
    }

    \$conn->close();
    ?>
    EOF'
```

#### Check if the Apache Server has successfully installed and is running
```bash
gcloud compute ssh http-server-2 --zone=asia-east1-a --command="systemctl status apache2"
gcloud compute ssh http-server-2 --zone=asia-east1-a --command="systemctl status apache2"
```

#### Command to install HTTP server on both VMs (execute this on each VM via SSH if they were not running in previous step)
```bash
sudo apt update
sudo apt install -y apache2 php php-mysql
```
Then create the files manually to display the database table value.

### Step 6: Configure Load Balancer

1. **Create an Instance Group** with the HTTP server VMs in `myvpc1`.
   ```bash
   # Create an unmanaged instance group
   gcloud compute instance-groups unmanaged create http-servers-group \
     --zone=asia-east1-a

   # Add instances to the instance group
   gcloud compute instance-groups unmanaged add-instances http-servers-group \
     --zone=asia-east1-a \
     --instances=http-server-1,http-server-2
   ```

2. **Create a Health Check** for the HTTP servers.
   ```bash
   gcloud compute health-checks create http http-basic-check \
     --port 80
   ```

3. **Create a Backend Service** and attach the instance group.
   ```bash
   gcloud compute backend-services create http-backend-service \
     --protocol=HTTP \
     --health-checks=http-basic-check \
     --global

   # Add instance group to backend service
   gcloud compute backend-services add-backend http-backend-service \
     --instance-group=http-servers-group \
     --instance-group-zone=asia-east1-a \
     --global
   ```

4. **Create a URL Map and Target HTTP Proxy** for routing.
   ```bash
   gcloud compute url-maps create http-url-map \
     --default-service=http-backend-service

   gcloud compute target-http-proxies create http-lb-proxy \
     --url-map=http-url-map
   ```

5. **Create a Forwarding Rule** to route traffic to the HTTP proxy.
   ```bash
   gcloud compute forwarding-rules create http-content-rule \
     --global \
     --target-http-proxy=http-lb-proxy \
     --ports=80
   ```

6. **Get the IP address of the load balancer** which allows users to visit the content efficiently
   ```bash
   gcloud compute forwarding-rules describe http-content-rule --global
   ```
   

### Step 7: Testing the Setup
Once configured, test the Load Balancer's IP address to ensure it routes traffic correctly to the HTTP servers, and the servers can communicate with the database in `myvpc2`.
