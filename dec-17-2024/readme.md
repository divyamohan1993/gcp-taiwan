# Building, Containerizing, and Deploying a Machine Learning Model on GCP with Terraform

## Prerequisites

1. **GCP Account and Project**:  
   Ensure that you have a Google Cloud Platform (GCP) account and a GCP project created. Note down your project ID (e.g., `industrial-glow-437012-i4`).

2. **Cloud Shell**:  
   It is highly recommended to use the GCP Cloud Shell environment for this tutorial. The Cloud Shell has essential tools such as `gcloud`, `docker`, `terraform`, and `git` pre-installed.

3. **Service Account Credentials**:  
   Ensure you have a service account key file (e.g., `mySA.json`) for authentication. This can be generated via the GCP Console. Save the JSON file in your working directory in Cloud Shell.

4. **Enable Required Services**:  
   Make sure the following services are enabled in your GCP project:  
   - Container Registry / Artifact Registry  
   - Compute Engine  
   - Cloud Storage  
   - Cloud SQL (if you follow the database creation steps)

   To enable services, run:
   ```bash
   gcloud services enable containerregistry.googleapis.com \
       run.googleapis.com \
       compute.googleapis.com \
       sqladmin.googleapis.com \
       storage.googleapis.com
   ```

---

## Section 1: Preparing the Machine Learning Model and Application

1. **Create the Required Files**:  
   In Cloud Shell, create the necessary files:
   ```bash
   touch client2.py client.py Dockerfile main.py requirements.txt train_model.py
   ```
   
   These commands create empty files. We will populate them with code in the following steps.
   
2. **Populate `train_model.py`**:  
   Copy and paste the following code into `train_model.py`:
   ```python
   # -*- coding: utf-8 -*-
   import pickle
   from sklearn import datasets
   from sklearn.model_selection import train_test_split
   from sklearn import tree

   # Load the Iris dataset
   iris = datasets.load_iris()
   x = iris.data
   y = iris.target

   # Training the model
   x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=.25)
   classifier = tree.DecisionTreeClassifier()
   classifier.fit(x_train, y_train)

   # Export the trained model
   model_name = 'model.pkl'
   print("finished training and dump the model as {0}".format(model_name))
   pickle.dump(classifier, open(model_name, 'wb'))
   ```

3. **Populate `requirements.txt`**:  
   Paste the following into `requirements.txt`:
   ```
   scikit-learn
   flask
   requests
   ```

4. **Populate `main.py` (Flask Application)**:  
   Copy and paste the following into `main.py`:
   ```python
   import pickle
   from flask import Flask, request, jsonify

   app = Flask(__name__)

   # Load the model
   model = pickle.load(open('model.pkl', 'rb'))
   labels = {
     0: "versicolor",
     1: "setosa",
     2: "virginica"
   }

   @app.route("/", methods=["GET"])
   def index():
       """Basic HTML response."""
       body = (
           "<html>"
           "<body style='padding: 10px;'>"
           "<h1>Welcome to my Flask API</h1>"
           "</body>"
           "</html>"
       )
       return body

   @app.route('/api', methods=['POST'])
   def predict():
       # Get the data from the POST request
       data = request.get_json(force=True)
       predict = model.predict(data['feature'])
       return jsonify(predict[0].tolist())

   if __name__ == '__main__':
       app.run(debug=True, host='0.0.0.0', port=8080)
   ```

5. **Populate `Dockerfile`**:  
   Copy and paste the following into `Dockerfile`:
   ```dockerfile
   FROM python:3.9
   WORKDIR /app
   ADD . /app
   RUN pip install -r requirements.txt
   EXPOSE 8080
   CMD ["python", "main.py"]
   ```

6. **Populate `client2.py` (Testing Client)**:  
   Copy and paste the following into `client2.py`:
   ```python
   # -*- coding: utf-8 -*-
   import requests

   # Test Feature
   url = 'http://127.0.0.1:8080/api'
   feature = [[5.8, 4.0, 1.2, 0.2]]
   labels = {
     0: "setosa",
     1: "versicolor",
     2: "virginica"
   }

   r = requests.post(url, json={'feature': feature})
   print(labels[r.json()])
   ```

7. **Train the Model**:
   Run the training script:
   ```bash
   python3 train_model.py
   ```
   
   This will produce `model.pkl` in your current directory.

---

## Section 2: Building and Running the Docker Image Locally

1. **Build the Docker Image Locally**:
   ```bash
   docker build -t mywww:1.0 .
   ```
   
2. **Run the Docker Container Locally**:
   ```bash
   docker run -d -p 8080:80 mywww:1.0
   ```

   At this point, you should be able to access the application by visiting `http://127.0.0.1:8080` in Cloud Shell’s web preview or from a local environment if you are forwarding ports.

---

## Section 3: Pushing the Docker Image to GCP Artifact Registry

1. **Configure Artifact Registry**:  
   Replace `industrial-glow-437012-i4` with your actual GCP project ID:
   ```bash
   gcloud auth configure-docker asia-east1-docker.pkg.dev
   ```

2. **Build the Image with GCP Artifact Registry Name**:  
   Use your correct project ID and repository name:
   ```bash
   docker build -t asia-east1-docker.pkg.dev/industrial-glow-437012-i4/mydocker/mywww:1.0 .
   ```

3. **Push the Image to Artifact Registry**:
   ```bash
   docker push asia-east1-docker.pkg.dev/industrial-glow-437012-i4/mydocker/mywww:1.0
   ```

   Make sure to adjust the project ID (`industrial-glow-437012-i4`) and repository (`mydocker`) as needed.

---

## Section 4: Deploying the Iris Model as a Docker Service

1. **Rebuild the Image for the Iris Model**:  
   For the iris model, change the Docker tag and repository name according to the instructions:
   ```bash
   docker build -t asia-east1-docker.pkg.dev/industrial-glow-437012-i4/test-iris/myiris:1.0 .
   ```

2. **Push the Iris Image to Artifact Registry**:
   ```bash
   docker push asia-east1-docker.pkg.dev/industrial-glow-437012-i4/test-iris/myiris:1.0
   ```

   Remember to change the project ID (`industrial-glow-437012-i4`) to your own project’s ID if different.

---

## Section 5: Deploying Compute Resources with Terraform

The following steps demonstrate how to use Terraform to provision resources on GCP.

1. **Create and Populate Terraform Configuration Files**:

   - `provider.tf`:
     ```hcl
     terraform {
       required_version = ">=1.0"
       required_providers {
         google = {
           source  = "hashicorp/google"
           version = ">= 4.40.0"
         }
       }
     }

     provider "google" {
       credentials = file("mySA.json")
       project     = "industrial-glow-437012-i4"
       region      = "asia-east1"
     }
     ```

     Make sure to replace `industrial-glow-437012-i4` with your project ID.

   - `main.tf` (for creating a Compute Engine instance):
     ```hcl
     resource "google_compute_instance" "example" {
       name         = "example-instance"
       machine_type = "e2-micro"
       zone         = "asia-east1-b"

       boot_disk {
         initialize_params {
           image = "projects/ubuntu-os-cloud/global/images/ubuntu-2204-jammy-v20240726"
         }
       }

       network_interface {
         network = "default"
         access_config {}
       }

       provisioner "local-exec" {
         command = "echo ${google_compute_instance.example.network_interface[0].network_ip} > ./ip_address_local_exec.txt"
       }
     }
     ```

   - Example variables file (`variables.tf`) (optional but recommended):
     ```hcl
     variable "GCP_PROJECT" {
       type        = string
       description = "GCP Project ID"
       default     = "industrial-glow-437012-i4"
     }

     variable "GCP_REGION" {
       type    = string
       default = "asia-east1"
     }
     ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Format, Validate, and Plan**:
   ```bash
   terraform fmt
   terraform validate
   terraform plan
   ```

4. **Apply the Terraform Configuration**:
   ```bash
   terraform apply -auto-approve
   ```
   
   This will create the Compute Engine instance defined in `main.tf`.

5. **Destroy the Resources (if needed)**:
   ```bash
   terraform destroy -auto-approve
   ```

---

## Section 6: Optional - Creating a Cloud SQL Instance

If you wish to create a Cloud SQL instance and database, use the following `main.tf` configuration (adjust the project, region, and db_name as needed):

```hcl
locals {
  allow_ips = ["0.0.0.0/0"]
}

resource "google_sql_database_instance" "instance" {
  name                = var.db_name
  database_version    = "MYSQL_5_7"
  deletion_protection = false

  settings {
    tier      = "db-f1-micro"
    disk_size = "10"

    ip_configuration {
      dynamic "authorized_networks" {
        for_each = local.allow_ips
        content {
          name  = "allow-all"
          value = authorized_networks.value
        }
      }
    }
  }
}

resource "google_sql_database" "this" {
  name     = var.db_name
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.instance.name
  password = "12345678"
}

output "db_ip" {
  value = google_sql_database_instance.instance.public_ip_address
}
```

Run:
```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply -auto-approve
```

---

## Section 7: Presentation Upload

1. **Upload Your Presentation File (PPT)**:
   Use the GCP Console UI or `gsutil` commands to upload your presentation. For example, to upload a file to a GCS bucket:
   ```bash
   gsutil cp presentation.pptx gs://your-bucket-name/
   ```

2. **Follow the Presentation Order**:
   Next week, you can start with the presentation according to the assigned order.

---

## Notes and Reminders

- Always remember to update your project ID in all code snippets from `industrial-glow-437012-i4` to your actual GCP project ID.
- Ensure that you have appropriate permissions for the services you are using.
- Double-check that your Docker and GCP configurations are correct before pushing images and deploying resources.

