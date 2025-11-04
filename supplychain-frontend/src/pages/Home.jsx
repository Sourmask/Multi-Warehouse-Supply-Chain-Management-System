import React, { useEffect, useState } from "react";
import ProductCard from "../components/ProductCard";
import axios from "axios";

function Home() {
  const [products, setProducts] = useState([]);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        const res = await axios.get("http://localhost:5050/api/products");

        const seen = new Set();
        const formatted = res.data
          .map((p) => ({
            id: p.id,
            name: p.name,
            description: p.description,
            price: parseFloat(p.price),
            image: p.image_url.startsWith("/") ? p.image_url : `/${p.image_url}`,
          }))
          .filter((p) => {
            if (seen.has(p.name)) return false;
            seen.add(p.name);
            return true;
          });

        setProducts(formatted);
        } catch (error) {
        console.error("Error fetching products:", error);
      }
    };

    fetchProducts();
  }, []);

  return (
    <div className="p-8 bg-gray-50 min-h-screen">
      <h1 className="text-2xl font-bold mb-6 text-gray-800">
        Available Products
      </h1>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
        {products.map((product) => (
          <ProductCard key={product.id} product={product} />
        ))}
      </div>
    </div>
  );
}

export default Home;



// import React, { useEffect, useState } from "react";
// import ProductCard from "../components/ProductCard";
// import axios from "axios";

// function Home() {
//   const [products, setProducts] = useState([]);

//   useEffect(() => {
//     const fetchProducts = async () => {
//       try {
//         const res = await axios.get("http://localhost:5050/api/products");

//         const formatted = res.data.map((p) => ({
//           id: p.id,
//           name: p.name,
//           description: p.description,
//           price: parseFloat(p.price),
//           image: `${window.location.origin}${p.image_url}`,
//         }));

//         setProducts(formatted);
//       } catch (error) {
//         console.error("Error fetching products:", error);
//       }
//     };

//     fetchProducts();
//   }, []);

//   return (
//     <div className="p-8 bg-gray-50 min-h-screen">
//       <h1 className="text-2xl font-bold mb-6 text-gray-800">
//         Available Products
//       </h1>

//       <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-6">
//         {products.map((product) => (
//           <ProductCard key={product.id} product={product} />
//         ))}
//       </div>
//     </div>
//   );
// }

// export default Home;
