import React from "react";
import { Link, useNavigate } from "react-router-dom";

function Navbar({ currentUser }) {
  const navigate = useNavigate();

  return (
    <nav className="bg-blue-600 text-white p-4 flex justify-between items-center">
      <h1 className="text-xl font-semibold">SCMS</h1>
      
      <div>
        {!currentUser ? (
          <button
            className="bg-white text-blue-600 px-3 py-1 rounded hover:bg-gray-100"
            onClick={() => navigate("/login")}
          >
            Login
          </button>
        ) : (
          <div className="flex gap-4 items-center">
            <span className="font-medium">{currentUser.name}</span>
            <button
              className="bg-white text-blue-600 px-3 py-1 rounded hover:bg-gray-100"
              onClick={() => navigate("/order-history")}
            >
              Order History
            </button>
          </div>
        )}
      </div>
    </nav>
  );
}

export default Navbar;
