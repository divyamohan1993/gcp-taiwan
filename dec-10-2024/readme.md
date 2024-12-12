<!-- - deployed cloud run functions which connects to google sql via ip and makes changes to table
- deployed cloud run functions which moves file from one bucket to another if file size exceeds a limit. 
- deployed app engine - iris prediction (first deploy default if no app is deployed)
- deployed app engine - flask application -->


# **1. Deploy Cloud Run Functions Connected to Google SQL via IP**

### **Objective**  
Deploy a Cloud Run service that connects to a Google Cloud SQL instance via its IP and updates a specific table.

### **Prerequisites**  
1. Enable required APIs:  
   ```bash
   gcloud services enable run.googleapis.com sqladmin.googleapis.com
   ```
2. Create a Cloud SQL instance (MySQL/PostgreSQL):  
   ```bash
   gcloud sql instances create my-sql-instance --tier=db-f1-micro --region=us-central1
   ```
3. Create a database and table inside Cloud SQL:
   - Use **Cloud Shell** or a client like MySQL Workbench.  
   ```sql
   CREATE DATABASE mydatabase;
   USE mydatabase;
   CREATE TABLE students (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), age INT);
   INSERT INTO students (name, age) VALUES ('John Doe', 21);
   ```

### **Code**

#### `main.py`
```python
import os
import pymysql
from flask import Flask, jsonify

app = Flask(__name__)

def connect_to_db():
    connection = pymysql.connect(
        host=os.environ['DB_HOST'],  # Public IP of Cloud SQL
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD'],
        database=os.environ['DB_NAME'],
    )
    return connection

@app.route("/")
def update_table():
    try:
        connection = connect_to_db()
        with connection.cursor() as cursor:
            sql = "UPDATE students SET age = age + 1 WHERE name = 'John Doe'"
            cursor.execute(sql)
            connection.commit()
        return jsonify({"message": "Table updated successfully"})
    except Exception as e:
        return jsonify({"error": str(e)})
```

#### `Dockerfile`
```Dockerfile
FROM python:3.9
WORKDIR /app
COPY . /app
RUN pip install flask pymysql
CMD ["python", "main.py"]
```

### **Deployment Steps**
1. **Build and Deploy Cloud Run:**
   - Replace environment variables and IP:
   ```bash
   DB_HOST=<PUBLIC_IP_OF_SQL_INSTANCE>
   DB_USER=<YOUR_USERNAME>
   DB_PASSWORD=<YOUR_PASSWORD>
   DB_NAME=mydatabase

   gcloud builds submit --tag gcr.io/PROJECT-ID/sql-updater
   gcloud run deploy sql-updater-service \
      --image gcr.io/PROJECT-ID/sql-updater \
      --add-cloudsql-instances PROJECT-ID:us-central1:my-sql-instance \
      --update-env-vars DB_HOST=$DB_HOST,DB_USER=$DB_USER,DB_PASSWORD=$DB_PASSWORD,DB_NAME=$DB_NAME \
      --allow-unauthenticated
   ```
2. Verify the endpoint in Cloud Run.

---

# **2. Deploy Cloud Run Function to Move Files Between Buckets**

### **Objective**  
Move files from one bucket to another if the file size exceeds a limit.

### **Prerequisites**  
1. Enable necessary APIs:
   ```bash
   gcloud services enable run.googleapis.com storage.googleapis.com
   ```
2. Create two buckets:
   ```bash
   gsutil mb gs://source-bucket-name
   gsutil mb gs://destination-bucket-name
   ```

### **Code**

#### `main.py`
```python
from google.cloud import storage
from flask import Flask, jsonify

app = Flask(__name__)
storage_client = storage.Client()

SOURCE_BUCKET = "source-bucket-name"
DEST_BUCKET = "destination-bucket-name"
SIZE_LIMIT = 1000000  # 1 MB in bytes

@app.route("/")
def move_large_files():
    source_bucket = storage_client.bucket(SOURCE_BUCKET)
    dest_bucket = storage_client.bucket(DEST_BUCKET)

    blobs = source_bucket.list_blobs()
    for blob in blobs:
        if blob.size > SIZE_LIMIT:
            blob.copy_to_bucket(dest_bucket)
            blob.delete()
    return jsonify({"message": "Files moved successfully"})
```

#### `Dockerfile`
```Dockerfile
FROM python:3.9
WORKDIR /app
COPY . /app
RUN pip install google-cloud-storage flask
CMD ["python", "main.py"]
```

### **Deployment Steps**
1. Build and deploy:
   ```bash
   gcloud builds submit --tag gcr.io/PROJECT-ID/move-files
   gcloud run deploy move-files-service \
      --image gcr.io/PROJECT-ID/move-files \
      --allow-unauthenticated
   ```

---

# **3. Deploy App Engine for Iris Prediction**

### **Objective**  
Deploy a basic App Engine application for Iris species prediction.

### **Prerequisites**  
1. Enable App Engine:
   ```bash
   gcloud app create --region=us-central
   ```
2. Install libraries:
   ```bash
   pip install flask scikit-learn
   ```

### **Code**

#### `app.yaml`
```yaml
runtime: python39
entrypoint: gunicorn -b :$PORT main:app
```

#### `main.py`
```python
import numpy as np
from flask import Flask, request, jsonify
from sklearn.datasets import load_iris
from sklearn.linear_model import LogisticRegression

app = Flask(__name__)

iris = load_iris()
model = LogisticRegression(max_iter=200)
model.fit(iris.data, iris.target)

@app.route("/", methods=["POST"])
def predict():
    input_data = request.json['data']
    prediction = model.predict([input_data])
    return jsonify({"prediction": iris.target_names[prediction[0]]})
```

### **Deployment Steps**
1. Deploy to App Engine:
   ```bash
   gcloud app deploy app.yaml
   ```
2. Send test data:
   ```bash
   curl -X POST https://<YOUR-APP-URL> -H "Content-Type: application/json" -d '{"data": [5.1, 3.5, 1.4, 0.2]}'
   ```

---

# **4. Deploy App Engine for a Flask Application**

### **Objective**  
Deploy a simple Flask application to App Engine.

### **Code**

#### `app.yaml`
```yaml
runtime: python39
entrypoint: python main.py
```

#### `main.py`
```python
from flask import Flask

app = Flask(__name__)

@app.route("/")
def home():
    return "Hello, App Engine!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
```

### **Deployment Steps**
1. Deploy to App Engine:
   ```bash
   gcloud app deploy
   ```
2. Open the URL:
   ```bash
   gcloud app browse
   ```

