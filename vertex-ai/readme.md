# Vertex AI Demo: Sentiment Analysis of Customer Reviews  

### **Objective**  
Demonstrate how to use **Vertex AI** AutoML to train a sentiment analysis model that classifies customer reviews as positive or negative.

---

## **Prerequisites**  
1. **Google Cloud Account** (Free tier works).  
2. **Google Cloud Project** (Vertex AI enabled).  
3. **Google Cloud CLI** installed (optional).  
4. Basic dataset: Simple CSV file with two columns:
   - `Text` - customer review text.
   - `Sentiment` - label (0 for negative, 1 for positive).

---

## **Step 1: Setup Google Cloud Project**  
1. Go to the **Google Cloud Console** → **Vertex AI**.  
2. Enable **Vertex AI API**.  
3. Create or use an existing **Google Cloud Storage (GCS)** bucket for storing datasets and models.  

---

## **Step 2: Prepare the Dataset**  
1. Create a simple CSV file `sentiment_dataset.csv` like below:

```csv
Text,Sentiment
"The product was great!",1
"Terrible experience with the service.",0
"I love this item. Highly recommend!",1
"Not worth the money.",0
"Excellent quality and fast delivery!",1
```

2. Upload the CSV file to your **GCS bucket**:
   - Go to **Cloud Storage** → Upload file into a bucket.

---

## **Step 3: Create AutoML Sentiment Analysis Model**  
1. Go to **Vertex AI** → **Datasets** → **Create Dataset**.  
2. Select **Text** as the dataset type.  
3. Import the dataset from your **GCS bucket** (select the uploaded CSV).  
4. Map the `Sentiment` column as the target column.  
5. Once imported, click **Train New Model**.  
6. Select **AutoML** → **Train** with default options.  
7. Wait for training to complete (~10-30 minutes).

---

## **Step 4: Deploy the Model**  
1. Once training is complete, go to **Models** → select the trained model.  
2. Click **Deploy to Endpoint**.  
3. Vertex AI will create an endpoint for predictions.

---

## **Step 5: Test the Model**  
1. Go to the deployed model's endpoint.  
2. Use the **Test Endpoint** option.  
3. Provide a sample review as input, like:

   ```json
   {
     "instances": [{"Text": "This is an amazing product!"}]
   }
   ```

4. The model will return a **sentiment score** (e.g., 1 for positive).

---

## **Conclusion**  
Showed:
1. Uploading a dataset into Vertex AI.  
2. Training a model using AutoML with a simple CSV.  
3. Deploying the model and testing it with real-world input.  

---

### **Real-World Value**  
This example solves a basic customer review classification problem, often used in business settings to identify positive and negative feedback.
