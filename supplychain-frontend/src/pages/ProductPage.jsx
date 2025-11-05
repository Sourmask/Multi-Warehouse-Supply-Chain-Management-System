import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import axios from "axios";

function ProductPage() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [product, setProduct] = useState(null);
  const [selectedSize, setSelectedSize] = useState(null);
  const [stock, setStock] = useState(null);
  const [loading, setLoading] = useState(true);

  const storedUser = JSON.parse(localStorage.getItem("user"));
  const user_id = storedUser?.id; // or storedUser?.user_id depending on your DB

  useEffect(() => {
    if (!user_id) {
      navigate("/login");
      return;
    }

    const fetchProduct = async () => {
      try {
        const res = await axios.get(`http://localhost:5050/api/products/${id}`);
        setProduct(res.data);
        setSelectedSize(res.data.sizes[0]);
      } catch (err) {
        console.error("Error fetching product:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchProduct();
  }, [id, user_id, navigate]);

  useEffect(() => {
    if (!selectedSize) return;
    const fetchStock = async () => {
      try {
        const res = await axios.get(
          `http://localhost:5050/api/stock/${selectedSize.product_id}`
        );
        setStock(res.data.quantity_available);
      } catch (err) {
        console.error("Error fetching stock:", err);
      }
    };
    fetchStock();
  }, [selectedSize]);

  const handleBuyNow = async () => {
    if (!selectedSize) return;

    try {
      await axios.post("http://localhost:5050/api/buy", {
        user_id,
        product_id: selectedSize.product_id,
        size: selectedSize.size,
        price: selectedSize.price,
      });

      navigate("/order-success");
    } catch (err) {
      console.error("Error placing order:", err);
      alert("Something went wrong while placing the order.");
    }
  };

  const getStockStatus = () => {
    if (stock === null) return "Loading...";
    if (stock === 0)
      return <span className="text-red-600 font-medium">Out of Stock</span>;
    if (stock <= 10)
      return <span className="text-orange-500 font-medium">Low Stock</span>;
    return <span className="text-green-600 font-medium">In Stock</span>;
  };

  if (loading) return <div className="p-8">Loading...</div>;
  if (!product) return <div className="p-8 text-red-500">Product not found.</div>;

  return (
    <div className="p-8 bg-gray-50 min-h-screen flex flex-col md:flex-row gap-10 justify-center items-start">
      <div className="p-6 rounded-lg shadow-md w-full md:w-1/2 flex justify-center bg-[#E3E6EB]">
        <img src={product.image_url} alt={product.name} className="w-80 h-80 object-contain" />
      </div>

      <div className="flex flex-col w-full md:w-1/2">
        <h1 className="text-3xl font-bold text-gray-800">{product.name}</h1>
        <p className="text-gray-600 mt-2">{product.description}</p>

        <div className="mt-4">
          <p className="font-semibold text-gray-700 mb-2">Select Size:</p>
          <div className="flex gap-3">
            {product.sizes.map((s) => (
              <button
                key={s.product_id}
                onClick={() => setSelectedSize(s)}
                className={`px-3 py-1 border rounded transition ${
                  selectedSize?.product_id === s.product_id
                    ? "bg-blue-500 text-white"
                    : "bg-white"
                }`}
              >
                {s.size}
              </button>
            ))}
          </div>
        </div>

        <p className="text-blue-600 font-bold mt-6 text-2xl">
          ₹{selectedSize?.price}
        </p>

        <div className="mt-2">{getStockStatus()}</div>

        <button
          onClick={handleBuyNow}
          disabled={stock === 0}
          className={`mt-6 px-6 py-3 rounded text-white text-lg font-semibold transition ${
            stock === 0 ? "bg-gray-400 cursor-not-allowed" : "bg-green-600 hover:bg-green-700"
          }`}
        >
          Buy Now
        </button>
      </div>
    </div>
  );
}

export default ProductPage;
