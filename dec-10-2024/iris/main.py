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
    """HTML page with Bootstrap styled buttons to send POST requests for different flowers."""
    body = (
        "<html>"
        "<head>"
        "<link href='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css' rel='stylesheet' />"
        "<style>"
        "body {"
        "    font-family: 'Helvetica Neue', sans-serif;"
        "    background-color: #f8f9fa;"
        "}"
        "h1 {"
        "    color: #343a40;"
        "    font-size: 2.5rem;"
        "    font-weight: 600;"
        "    margin-bottom: 30px;"
        "}"
        "button {"
        "    font-size: 1.2rem;"
        "    padding: 15px 30px;"
        "    border-radius: 12px;"
        "    border: none;"
        "    transition: background-color 0.3s, transform 0.2s;"
        "}"
        "button:hover {"
        "    transform: scale(1.05);"
        "}"
        "button:focus {"
        "    outline: none;"
        "    box-shadow: 0 0 0 0.25rem rgba(38, 143, 255, 0.5);"
        "}"
        "#prediction {"
        "    font-size: 1.5rem;"
        "    font-weight: 500;"
        "    color: #495057;"
        "    background-color: #fff;"
        "    padding: 20px;"
        "    border-radius: 8px;"
        "    box-shadow: 0 2px 15px rgba(0, 0, 0, 0.1);"
        "    margin-top: 30px;"
        "    max-width: 500px;"
        "    width: 100%;"
        "    text-align: center;"
        "}"
        "</style>"
        "</head>"
        "<body class='d-flex flex-column justify-content-center align-items-center' style='height: 100vh;'>"
        
        "<div class='container text-center'>"
        "<h1>Flower Prediction API</h1>"
        
        # Buttons for multiple predefined flowers
        "<div class='d-grid gap-2 col-8 col-md-6 mx-auto'>"
        "<button class='btn btn-success' onclick='predict([5.1, 3.5, 1.4, 0.2])'>Predict Setosa</button>"
        "<button class='btn btn-primary' onclick='predict([6.3, 3.3, 6.0, 2.5])'>Predict Virginica</button>"
        "<button class='btn btn-info' onclick='predict([5.7, 2.8, 4.5, 1.3])'>Predict Versicolor</button>"
        "</div>"
        
        "<p id='prediction'></p>"
        
        "<script src='https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js'></script>"
        "<script>"
        "function predict(features) {"
        "    fetch('/api', {"
        "        method: 'POST',"
        "        headers: { 'Content-Type': 'application/json' },"
        "        body: JSON.stringify({ 'feature': features })"
        "    })"
        "    .then(response => response.json())"
        "    .then(data => {"
        "        document.getElementById('prediction').innerText = 'Prediction: ' + data.prediction;"
        "    })"
        "    .catch(error => {"
        "        document.getElementById('prediction').innerText = 'Error: ' + error.message;"
        "    });"
        "}"
        "</script>"
        
        "</body>"
        "</html>"
    )
    return body




@app.route('/api', methods=['POST'])
def predict():
    try:
        # Get the data from the POST request
        data = request.get_json(force=True)
        
        # Ensure data is in the correct format
        features = data.get('feature')
        if not features or len(features) == 0:
            return jsonify({"error": "Invalid input, 'feature' key is required."}), 400
        
        # Predict the result
        prediction = model.predict([features])
        
        # Return the prediction as a JSON response
        result = labels.get(prediction[0], "Unknown")  # Getting the corresponding label
        return jsonify({"prediction": result})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
