# Google Cloud Project Creation
- Project number: 9649******63
- Project ID: industrial-glow-******-i4

Exploration and learning of various services provided by the Google Cloud.

# Compute Engine - VM Instance - By Lakshika Tanwar
**Prerequisite:**
- *Creation of Google Cloud Project*
- *Guidance from faculty and https://cloud.google.com/sdk/docs/install#deb*

---
## Method 1 - Using GUI
We create the VM Instance using the GUI exploring N and E Series machines. We ssh on to the Ubuntu 20.04 LTS instance we created and explored its capabilities. We also saw how to ssh to the instance directly using google console.

The following code is used to ssh the vm using google cloud console with the name as VM_NAME(replace with suitable name), and zone as asia-east1-c(replace as applicable)
```
cloud compute ssh VM_NAME --project=replace_withyour_project_id --zone=asia-east1-c
```

We also learnt how to add startup script through GUI. 

## Method 2 - Using Google Cloud Console

### The following code is from our instance which we created using GUI. We used its --project and --service-account value and replaced those in the command provided by faculty.

```
gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=us-central1-f --machine-type=g1-small --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server,https-server,lb-health-check --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20240830,mode=rw,size=10,type=pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
```

---
### The following is the code provided by faculty with the above values replaced:
```
gcloud compute instances create myvm1 --project=industrial-glow-437012-i4 --zone=asia-east1-c --machine-type=e2-medium --network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default --maintenance-policy=MIGRATE --provisioning-model=STANDARD --service-account=964926729963-compute@developer.gserviceaccount.com --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/trace.append --tags=http-server --create-disk=auto-delete=yes,boot=yes,device-name=myvm1,image=projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240720,mode=rw,size=10,type=projects/golden-sentry-430013-j5/zones/asia-east1-c/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --labels=goog-ec-src=vm_add-gcloud --reservation-affinity=any
```

We ran the above code in 'console' of gc. Once the Machine was deployed we used the following code to run the repository update and install apache2. Further, we created the index.html and deployed it live using public IP. (For some reason unknown the page was not accessible even with correct permissions).
```
apt update
apt -y install apache2
cat <<EOF > /var/www/html/index.html
<html><body><p>Linux startup script added directly. $(hostname -f) </p></body></html>
```

---
Once deployed, we can use the following code to access the list of VM's deployed. 
```
gcloud  compute  instances list
```

---

The following command creates the instance with VM_NAME(replace with suitable name) with the image as debain intead of Ubuntu as we used above. This command has an startup sript attached which runs the repo update -. installs apache2 -> and creates a badix index.html page which can be accessed by opening vm's public ip.

```
gcloud compute instances create VM_NAME \
  --image-project=debian-cloud \
  --image-family=debian-10 \
  --metadata=startup-script='#! /bin/bash
  apt update
  apt -y install apache2
  cat <<EOF > /var/www/html/index.html
  <html><body><p>Linux startup script added directly.</p></body></html>
  EOF'
```

--- 
We were guided on how to integrate OpenAI key and make a project - https://python.langchain.com/docs/integrations/llms/openai/ which can be accessed using https://platform.openai.com/api-keys

---


### Deploying a website to dynv6.net

#### Using startup script from GUI

While creating a VM:
- Open advanced settings -> Network -> Add Network tags 'http-server' and 'https-server'
- Management -> Under Automations, paste the following script.

```
#! /bin/bash
 apt update
 apt -y install apache2 php libapache2-mod-php php-mysql mariadb-client
 cat <<EOF > /var/www/html/index.html
 <html><body><p>Linux startup script added directly. $(hostname -I) </p></body></html>
```

Create and deploy the VM after above changes have been made.

We create our account on dynv6.com. In the dashboard, we attach the external IP we get from the vm to a dynamic address that has been created by us.

The website is then deployed to that custom address we created, herein, http://lakshikatanwar.dynv6.net

#### Using buckets to hold static resources and linking it to compute instance to host directly as folder of website

Linking different vm + ping them - DIY

#### Creating budget for monitering credit usage with predefined scoping.
 DIY - Give details for notes

#### SSH to instance 2 from within instance 1. 

We created connection between the two instances through SSH. For this example we will use  myweb1 with internal ip 10.140.0.10 (host) to access mygcp1 with 10.140.0.11 as internal ip (guest). 

Steps:

- Update password of root user for both instance to your password using command `sudo passwd root`. 
- Escalate the priveledge by `su` command, i.e. enter to superuser or root user and enter the password which you just created.
- Ping each other to confirm they can 'talk' to each other.
- If we attemp to ssh now, it will give error as we dont have proper keys
- 
  
### MariaDB Installation and Configuration

To be used in tandem with an instance which will work as a webserver. Can be configured in single server. But in this scenerio we will use multiple instances.

Prerequisites:
- Create a new instance with any minimul default/Ubuntu 20.04LTS configuration, which will be used as database.

To install MariaDB on a Debian-based Google Cloud instance, follow the steps below. Here's a script that automates the process:

### Step 1: Update Package Information and Install MariaDB Server
```bash
sudo apt update
sudo apt install mariadb-server -y
```

### Step 2: Start and Enable MariaDB Service
```bash
sudo systemctl start mariadb
sudo systemctl enable mariadb
```

### Step 3: Secure the MariaDB Installation
```bash
sudo mysql_secure_installation
```
This will prompt to set the root password (123456), remove test databases, disable remote root login, and other security improvements. Follow the prompts as per your requirements.

### Step 4: Check the Status of MariaDB
You can verify the status of MariaDB with the following command:
```bash
sudo systemctl status mariadb
```

### Step 6: Login to mysql
You can now login and verify whether the installation and configration was successful
```bash
mysql -u root -p
```

### Optional Step: Open Firewall Ports (if necessary)
If you want to allow external access to MariaDB, ensure that port 3306 is open in your firewall settings.

```bash
sudo ufw allow 3306/tcp
```

Once installed configure the MariaDB instance running on `10.148.0.2` from another instance (`10.140.0.16`), by following these steps:

### Step 1: Ensure MariaDB is Configured for Remote Access on `10.148.0.2`
By default, MariaDB may only allow connections from `localhost`. To allow remote connections:

1. **Edit the MariaDB configuration file** on `10.148.0.2`:
    ```bash
    sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf
    ```    

2. **Find the following line**:
    ```bash
    bind-address = 127.0.0.1
    ```
    
3. **Change it to**:
    ```bash
    bind-address = 0.0.0.0
    ```    

4. **Restart MariaDB** to apply changes:
    ```bash
    sudo systemctl restart mariadb
    ```    

### Step 2: Grant Access to Remote IP
Login to the mysql ```mysql -u root -p``` from the MariaDB instance on `10.148.0.2`, run the following command to grant access to the root user from the IP `10.140.0.16`:

```sql
GRANT ALL PRIVILEGES ON *.* TO 'root'@'10.140.0.16' IDENTIFIED BY '123456' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### Step 3: Open the Required Port (3306) in the Firewall (optional)
If you're using a firewall on the `10.148.0.2` instance, you need to allow traffic on port `3306`:
```bash
sudo ufw allow 3306/tcp
```

### Step 4: Connect from `10.140.0.16`
On the second instance (`10.140.0.16`), use the `mysql` client to connect to the database on `10.148.0.2`:

```bash
mysql -h 10.148.0.2 -u root -p
```

Enter the password (`123456`) when prompted, and you should be connected to the MariaDB instance remotely.

### Note
Ensure that Google Cloud's firewall rules allow traffic between the instances on port 3306. You can configure this in the VPC network's firewall settings by allowing ingress/egress traffic on this port.


Once done, you can try connecting again to the IP of server instance (10.148.0.2) in this case:
```bash
mysql -h 10.148.0.2 -u root -p
```

Enter your password (`123456`), and you should be connected to the MariaDB server running on `10.148.0.2`.

### Connecting to database from server to fetch the test table we created. 

```php
<?php   
$servername="10.148.0.2";  // IP address where mariadb-server installed
$username="root";    // username
$password="123456"; // password 
$dbname="T1"; // database name 

$conn = new mysqli($servername, $username, $password, $dbname);  // we created a connection and stored it in conn variable

if($conn->connect_error){  // if there is error
    die("connection failed: " . $conn->connect_error); 
}
else{
    echo "connect OK!" . "<br>";  // else it will echo aka print connect ok and <br> line break krne ke liye.
}

$sql="select first_name, department from addrbook";  // this is an sql statemtnt which 
$result=$conn->query($sql);  // we run here query

if($result->num_rows>0){  // if the returned results have rows more than 0
    while($row=$result->fetch_assoc()){  // run this while loop for each row in such a way 
        echo "First Name: " . $row["first_name"] . "\t Department: " . $row["department"] . "<br>";  // that for each row it will iterate this and print First Name: first_name_of_that_row tabbed space dept dpt of row
    }
} else {
    echo "0 record";  // else it will say 0 record
}
?>
```

#### Copy the Files from instance to Buket directly.
```
gsutil cp filename.txt gs://bucket-name
```
