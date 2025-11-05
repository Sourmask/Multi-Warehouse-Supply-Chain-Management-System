import React, { useState } from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Home from "./pages/Home";
import ProductPage from "./pages/ProductPage";
import OrderSuccess from "./pages/OrderSuccess";
import StockerPortal from "./pages/StockerPortal";
import PackerPortal from "./pages/PackerPortal";
import Login from "./pages/Login";

function App() {
  const [currentUser, setCurrentUser] = useState(null);

  return (
    <Router>
      <Navbar currentUser={currentUser} />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/product/:id" element={<ProductPage />} />
        <Route path="/order-success" element={<OrderSuccess />} />
        <Route path="/stocker" element={<StockerPortal />} />
        <Route path="/packer" element={<PackerPortal />} />
        <Route path="/login" element={<Login setCurrentUser={setCurrentUser} />} />
      </Routes>
      <Footer />
    </Router>
  );
}

export default App;
