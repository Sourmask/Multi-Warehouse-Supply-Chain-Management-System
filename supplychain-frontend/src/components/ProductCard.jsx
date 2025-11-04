import React from "react";
import { useNavigate } from "react-router-dom";

function ProductCard({ product }) {
  const navigate = useNavigate();

  return (
    <div
      className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition cursor-pointer"
      onClick={() => navigate(`/product/${product.id}`)}
    >
      <img
        src={product.image}
        alt={product.name}
        className="w-full h-64 object-contain bg-gray-100"
      />
      <div className="p-4">
        <h2 className="text-lg font-semibold text-gray-800">{product.name}</h2>
        <p className="text-gray-500 text-sm mt-1">{product.description}</p>
        <p className="text-blue-600 font-bold mt-2">₹{product.price}</p>
      </div>
    </div>
  );
}

export default ProductCard;
