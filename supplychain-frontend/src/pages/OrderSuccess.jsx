import React from "react";
import { useNavigate } from "react-router-dom";

function OrderSuccess() {
  const navigate = useNavigate();

  return (
    <div className="flex flex-col justify-center items-center min-h-screen bg-green-200">
      <h1 className="text-4xl font-bold text-green-900 mb-6">
        Order Successful.
      </h1>
      <button
        onClick={() => navigate("/")}
        className="px-6 py-3 bg-white text-green-700 font-semibold rounded shadow hover:bg-gray-100"
      >
        Return to Home
      </button>
    </div>
  );
}

export default OrderSuccess;
