from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello():
    return '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello World - Lakshika</title>
    <!-- Bootstrap CSS via cdnjs -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container text-center mt-5">
        <h1 class="display-4">Hello, World!</h1>
        <p class="lead">I am <strong>Lakshika</strong>, a 21-year-old BTech CSE student at Shoolini University currently at NQU studying Cloud Computing and planning to explore more technologies like LangChain, app development, and more.</p>
        <a href="https://dmj.one" class="btn btn-primary">Explore My Journey</a>
    </div>

    <!-- Bootstrap JS via cdnjs -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
</body>
</html>
'''

if __name__ == "__main__":
    app.run(debug=True)