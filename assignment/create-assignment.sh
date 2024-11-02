#!/bin/bash

# Step 1: VPC Network Creation
echo "Creating VPC networks..."
gcloud compute networks create myvpc1 --subnet-mode=custom
gcloud compute networks create myvpc2 --subnet-mode=custom

# Step 2: Create Subnets within Each VPC
echo "Creating subnets..."
gcloud compute networks subnets create myvpc1-subnet \
  --network=myvpc1 \
  --region=asia-east1 \
  --range=10.0.1.0/24

gcloud compute networks subnets create myvpc2-subnet \
  --network=myvpc2 \
  --region=asia-east1 \
  --range=192.168.1.0/24

# Step 3: VPC Peering
echo "Setting up VPC peering..."
gcloud compute networks peerings create myvpc1-to-myvpc2 \
  --network=myvpc1 \
  --peer-network=myvpc2

gcloud compute networks peerings create myvpc2-to-myvpc1 \
  --network=myvpc2 \
  --peer-network=myvpc1

# Step 4: Create Firewall Rules for VPCs
echo "Creating firewall rules..."
gcloud compute firewall-rules create myvpc1-allow-icmp --network=myvpc1 --allow=icmp
gcloud compute firewall-rules create myvpc1-allow-ssh --network=myvpc1 --allow=tcp:22
gcloud compute firewall-rules create myvpc1-allow-http --network=myvpc1 --allow=tcp:80

gcloud compute firewall-rules create myvpc2-allow-mysql --network=myvpc2 --allow=tcp:3306
gcloud compute firewall-rules create myvpc2-allow-ssh --network=myvpc2 --allow=tcp:22

# Step 5: Create Database VM with MariaDB Configuration
echo "Creating database VM in myvpc2 and configuring MariaDB..."

# Create the startup script for configuring MariaDB on the database VM
cat << 'EOF' > mysql-setup.sh
#!/bin/bash

# Update system and install MariaDB server
sudo apt update
sudo apt install -y mariadb-server
sudo systemctl start mariadb

# Configure MariaDB to listen on all interfaces
sudo sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb

# Allow time for MariaDB to fully start
sleep 5

# Set up MariaDB root user, clear unnecessary users/databases, and grant remote access
sudo mysql <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '12345678';
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON example_db.* TO 'root'@'10.0.1.%' IDENTIFIED BY '12345678';
FLUSH PRIVILEGES;
SQL

# Create database, table, and insert initial data
sudo mysql -uroot -p12345678 <<SQL
CREATE DATABASE example_db;
USE example_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO users (name, email) VALUES
('Lakshika', 'lakshika@dmj.one'),
('dmj', 'contact@dmj.one'),
('Kycee', 'kycee@nwu.tw'),
('Aarav', 'aarav@gmail.com'),
('Vivaan', 'vivaan@dmj.one'),
('Diya', 'diya@edu.in'),
('Saanvi', 'saanvi@india.org'),
('Advika', 'advika@service.in'),
('Mei', 'mei@taipei.tw'),
('Jia', 'jia@dmj.one'),
('Rui', 'rui@nwu.tw'),
('Shan', 'shan@twmail.com'),
('Wei', 'wei@taiwan.com'),
('Anvi', 'anvi@edu.in'),
('Aryan', 'aryan@inmail.com'),
('Yu', 'yu@taipei.tw'),
('Chen', 'chen@service.tw'),
('Rakesh', 'rakesh@inmail.com'),
('Suhani', 'suhani@edu.org'),
('Nisha', 'nisha@dmj.in'),
('Vikram', 'vikram@domain.in'),
('Ting', 'ting@taipei.com.tw'),
('Lin', 'lin@dmj.tw');
SQL
EOF

# Create the database VM and pass the setup script
gcloud compute instances create database-vm \
  --zone=asia-east1-a \
  --machine-type=e2-micro \
  --subnet=myvpc2-subnet \
  --tags=mysql-server \
  --metadata-from-file startup-script=mysql-setup.sh

echo "Database setup script created and applied to database-vm."

sleep 2

# Wait for database VM to be ready and fetch its internal IP
echo "Fetching internal IP for database VM..."
DATABASE_VM_IP=$(gcloud compute instances describe database-vm \
  --zone=asia-east1-a \
  --format="get(networkInterfaces[0].networkIP)")

# Step 6: Create HTTP Server Instances with Database Connection Configuration
echo "Creating HTTP server instances in myvpc1 with database VM IP..."

# Create the startup script for HTTP server instances
cat << EOF > http-server-setup.sh
#!/bin/bash
sudo apt update
sudo apt install -y apache2 php php-mysql
sudo systemctl start apache2
sudo mv /var/www/html/index.html /var/www/html/index.html.bak

# Create PHP file to connect to the MariaDB database and display data in Bootstrap cards
cat << 'PHP_EOF' | sudo tee /var/www/html/index.php
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Data</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container my-5">
        <h1 class="mb-4 text-center">User Data</h1>
        <div class="row row-cols-1 row-cols-md-3 g-4">
            <?php
            \$servername = "$DATABASE_VM_IP";
            \$username = "root";
            \$password = "12345678";
            \$dbname = "example_db";
            \$conn = new mysqli(\$servername, \$username, \$password, \$dbname);
            if (\$conn->connect_error) {
                die("Connection failed: " . \$conn->connect_error);
            }
            \$sql = "SELECT id, name, email, created_at FROM users";
            \$result = \$conn->query(\$sql);
            if (\$result->num_rows > 0) {
                while(\$row = \$result->fetch_assoc()) {
                    echo '<div class="col">';
                    echo '    <div class="card h-100">';
                    echo '        <div class="card-body">';
                    echo '            <h5 class="card-title">ID: ' . \$row["id"] . '</h5>';
                    echo '            <p class="card-text"><strong>Name:</strong> ' . \$row["name"] . '</p>';
                    echo '            <p class="card-text"><strong>Email:</strong> ' . \$row["email"] . '</p>';
                    echo '            <p class="card-text"><small class="text-muted">Created At: ' . \$row["created_at"] . '</small></p>';
                    echo '        </div>';
                    echo '    </div>';
                    echo '</div>';
                }
            } else {
                echo '<p class="text-center">No results found.</p>';
            }
            \$conn->close();
            ?>
        </div>
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.0/js/bootstrap.bundle.min.js"></script>
</body>
</html>
PHP_EOF
EOF

# Launch HTTP server instances with the startup script
for i in 1 2; do
  gcloud compute instances create http-server-$i \
    --zone=asia-east1-a \
    --machine-type=e2-micro \
    --subnet=myvpc1-subnet \
    --tags=http-server \
    --metadata-from-file startup-script=http-server-setup.sh
done

# Step 7: Configure Load Balancer
echo "Configuring load balancer..."
gcloud compute instance-groups unmanaged create http-servers-group --zone=asia-east1-a
gcloud compute instance-groups unmanaged add-instances http-servers-group --zone=asia-east1-a --instances=http-server-1,http-server-2

gcloud compute health-checks create http http-basic-check --port 80
gcloud compute backend-services create http-backend-service --protocol=HTTP --health-checks=http-basic-check --global
gcloud compute backend-services add-backend http-backend-service --instance-group=http-servers-group --instance-group-zone=asia-east1-a --global

gcloud compute url-maps create http-url-map --default-service=http-backend-service
gcloud compute target-http-proxies create http-lb-proxy --url-map=http-url-map

gcloud compute forwarding-rules create http-content-rule --global --target-http-proxy=http-lb-proxy --ports=80

echo "Removing script created internal setup files."
rm http-server-setup.sh
rm mysql-setup.sh

echo "Setup complete. Retrieving load balancer IP address..."
gcloud compute forwarding-rules describe http-content-rule --global --format="get(IPAddress)"
LOADBALANCER_IP=$(gcloud compute forwarding-rules describe http-content-rule --global --format="get(IPAddress)")

echo "Finished. Visit "$LOADBALANCER_IP" to continue"
