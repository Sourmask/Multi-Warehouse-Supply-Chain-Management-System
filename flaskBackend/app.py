from flask import Flask
from flask_cors import CORS
from routes.orders import orders_bp
from routes.products import products_bp 

app = Flask(__name__)

# Explicitly allow frontend origin
CORS(app, resources={r"/*": {"origins": "*"}})

# Register blueprints
app.register_blueprint(orders_bp)
app.register_blueprint(products_bp) 

if __name__ == "__main__":
    app.run(debug=True, port=5050)

