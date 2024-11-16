### Step 1: VPC Network Creation

1. Go to **VPC Network** in the Google Cloud Console.
2. Click **Create VPC Network**.
3. Name the network **myvpc1**, set the **Subnet Mode** to **Custom**.
4. Repeat to create **myvpc2** with **Custom** mode.

---

### Step 2: Create Subnets

1. Inside **myvpc1**, click **Add Subnet**.
   - Name: **myvpc1-subnet**
   - Region: **asia-east1**
   - IP range: **10.0.1.0/24**
2. Repeat for **myvpc2**:
   - Name: **myvpc2-subnet**
   - Region: **asia-east1**
   - IP range: **192.168.1.0/24**

---

### Step 3: VPC Peering

1. Go to **VPC Network Peering**.
2. Click **Create Connection** and set:
   - Network: **myvpc1**
   - Peer Network: **myvpc2**
3. Repeat with:
   - Network: **myvpc2**
   - Peer Network: **myvpc1**

---

### Step 4: Create Firewall Rules

1. Go to **Firewall Rules** and click **Create Firewall Rule**.
2. For **myvpc1**:
   - **myvpc1-allow-icmp**: Allow ICMP.
   - **myvpc1-allow-ssh**: Allow TCP:22.
   - **myvpc1-allow-http**: Allow TCP:80.
3. For **myvpc2**:
   - **myvpc2-allow-mysql**: Allow TCP:3306.
   - **myvpc2-allow-ssh**: Allow TCP:22.

---

### Step 5: Create Database VM and Configure MariaDB

1. Go to **Compute Engine > VM Instances** and click **Create Instance**.
2. Set:
   - Name: **database-vm**
   - Zone: **asia-east1-a**
   - Machine type: **e2-micro**
   - Network/Subnet: **myvpc2-subnet**
3. Under **Management > Automation**, add this script as a **Startup Script**:
   ```bash
   #!/bin/bash
   sudo apt update
   sudo apt install -y mariadb-server
   sudo systemctl start mariadb
   sudo sed -i 's/^bind-address\s*=.*$/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
   sudo systemctl restart mariadb
   sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '12345678';"
   sudo mysql -e "CREATE DATABASE example_db;"
   # Additional setup steps from the script as needed
   ```
4. **Create** the VM.

---

### Step 6: Create HTTP Server Instances with Database Connection

1. Go to **Compute Engine > VM Instances** and click **Create Instance**.
2. Create two instances:
   - Name: **http-server-1** and **http-server-2**
   - Zone: **asia-east1-a**
   - Machine type: **e2-micro**
   - Network/Subnet: **myvpc1-subnet**
3. Use the following **Startup Script** for each HTTP server:
   ```bash
   #!/bin/bash
   sudo apt update
   sudo apt install -y apache2 php php-mysql
   sudo systemctl start apache2
   sudo bash -c 'cat > /var/www/html/index.php' << 'EOF'
   <!-- HTML and PHP code here to connect to database and display data -->
   EOF
   ```

---

### Step 7: Configure Load Balancer

1. Go to **Compute Engine > Instance Groups** and click **Create Instance Group**.
2. Set:
   - Name: **http-servers-group**
   - Zone: **asia-east1-a**
3. Add **http-server-1** and **http-server-2** to the group.

---

### Step 8: Health Check

1. Go to **Health Checks** in Network Services.
2. Click **Create Health Check**:
   - Name: **http-basic-check**
   - Protocol: **HTTP**
   - Port: **80**

---

### Step 9: Create Backend Service

1. Go to **Backend Services** in Network Services.
2. Click **Create Backend Service** and set:
   - Name: **http-backend-service**
   - Protocol: **HTTP**
   - Health check: **http-basic-check**
3. Attach **http-servers-group** to the backend.

---

### Step 10: URL Map and HTTP Proxy

1. Go to **URL Maps** and create a map:
   - Name: **http-url-map**
   - Default backend service: **http-backend-service**
2. Go to **Target HTTP Proxies** and create a proxy:
   - Name: **http-lb-proxy**
   - URL map: **http-url-map**

---

### Step 11: Forwarding Rule

1. Go to **Forwarding Rules** and create:
   - Name: **http-content-rule**
   - Target: **http-lb-proxy**
   - Port: **80**

---

### Step 12: Retrieve Load Balancer IP

1. Return to **Forwarding Rules** to see the IP address for **http-content-rule**.