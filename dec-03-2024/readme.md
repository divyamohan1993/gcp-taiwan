# Google Cloud Run Functions: Step-by-Step Guide Using the GUI

This guide helps students create, deploy, and test Google Cloud Run functions entirely using the Google Cloud Console GUI. Follow the instructions to create a "Hello World" function and deploy a flower classification model using a machine learning repository. End with a task to apply your learning.

---

## Prerequisites
Before starting, ensure:
1. **Google Cloud Account**: Create or sign in to your Google Cloud account.
2. **Billing Enabled**: Activate billing to use Cloud Run services (you can use the free tier).
3. **Google Cloud Console**: Open [Google Cloud Console](https://console.cloud.google.com/) in your browser.

---

## 1. Creating a Cloud Run Function: "Hello World"

### Steps:

1. **Access Cloud Run**:
   - In the Google Cloud Console, search for **Cloud Run** in the top navigation bar.
   - Select **Cloud Run** and enable the service if prompted.

2. **Create Service**:
   - Click **Create Service**.
   - In the **Source** section, choose **Upload source code**.
   - Download the sample **"Hello World" Python app** provided in the course materials or use a zip file provided by your instructor.
   - Upload the zip file containing the code.

3. **Set Runtime and Configuration**:
   - Select the runtime environment (e.g., Python 3.9).
   - Set the **Region** (choose one close to you).
   - In **Authentication**, select **Allow unauthenticated invocations** to make the function accessible.

4. **Deploy**:
   - Review your settings and click **Deploy**.
   - Wait for the deployment process to complete.

5. **Test the Function**:
   - Once deployment is complete, click on the service name to view details.
   - Copy the provided URL and paste it into your browser.
   - You should see **"Hello, World!"** displayed.

---

## 2. Deploying the Flower Classification Model

### Steps:

1. **Clone and Modify Repository**:
   - Download or clone the repository [`gcp_serverless_ml`](https://github.com/saedhussain/gcp_serverless_ml) on your local machine. Ensure you review the materials if provided by your instructor.

2. **Create a Cloud Storage Bucket**:
   - Go to the **Storage** section in the Google Cloud Console.
   - Click **Create Bucket**.
   - Name your bucket (e.g., `flower-classifier-model`) and set the desired region.
   - Upload the model files (from the `model` folder in the repository) by clicking **Upload Files**.

3. **Set Up a New Cloud Run Service**:
   - Navigate back to **Cloud Run** in the Google Cloud Console.
   - Click **Create Service** and select **Upload source code**.
   - Upload the zip file for the repository or a folder containing the modified files.

4. **Configure Environment Variables**:
   - During the configuration process, add an environment variable to specify your bucket name. 
     - Click **Add Variable** and set the key as `BUCKET_NAME` and the value as your bucket name.

5. **Allow Unauthenticated Access**:
   - In the Authentication settings, select **Allow unauthenticated invocations** to enable public access to the service.

6. **Deploy the Service**:
   - Click **Deploy** and wait for the service to be deployed.

7. **Test the Model**:
   - Once deployed, copy the URL of the service.
   - Use tools like Postman or the **API Gateway** in the Cloud Console to send a test JSON payload:
     ```json
     {
       "sepal_length": 5.8,
       "sepal_width": 2.7,
       "petal_length": 5.1,
       "petal_width": 1.9
     }
     ```
   - The response should classify the flower as **Virginica**.

---

## Student Task
1. **Customize the Flower Classification Model**:
   - Modify the uploaded model to classify different datasets (e.g., handwritten digits or stock trends).
   - Re-deploy the model as a new Cloud Run service using the steps above.
   - Test the model with sample data and share the results.  

