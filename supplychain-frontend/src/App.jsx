import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Footer from "./components/Footer";
import Home from "./pages/Home";
import ProductPage from "./pages/ProductPage";
import OrderSuccess from "./pages/OrderSuccess";

function App() {
  return (
    <Router>
      <Navbar />
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/product/:id" element={<ProductPage />} />
        <Route path="/order-success" element={<OrderSuccess />} />
      </Routes>
      <Footer />
    </Router>
  );
}

export default App;

// import React from "react";
// import Navbar from "./components/Navbar";
// import Footer from "./components/Footer";
// import Home from "./pages/Home";

// function App() {
//   return (
//     <div className="min-h-screen bg-grey-50">
//       <Navbar />
//       <Home />
//       <Footer />
//     </div>
//   );
// }

// export default App;