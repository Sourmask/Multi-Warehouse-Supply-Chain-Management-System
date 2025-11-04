from flask import Flask
from flask_cors import CORS
from routes.orders import orders_bp
from routes.products import products_bp 
from routes.buy import buy_bp

app = Flask(__name__)

CORS(app)

# Register blueprints
app.register_blueprint(orders_bp)
app.register_blueprint(products_bp) 
app.register_blueprint(buy_bp)

if __name__ == "__main__":
    app.run(debug=True, port=5050)

