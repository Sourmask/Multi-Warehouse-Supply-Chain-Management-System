from flask import Flask
from flask_cors import CORS
from routes.products import products_bp 
from routes.buy import buy_bp
from routes.stocker import stocker_bp
from routes.packer import packer_bp
from routes.login import login_bp


app = Flask(__name__)

CORS(app)

# Register blueprints
app.register_blueprint(products_bp) 
app.register_blueprint(buy_bp)
app.register_blueprint(stocker_bp)
app.register_blueprint(packer_bp)
app.register_blueprint(login_bp, url_prefix="/login")


if __name__ == "__main__":
    app.run(debug=True, port=5050)

