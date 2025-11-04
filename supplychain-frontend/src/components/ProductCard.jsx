function ProductCard({ product }) {
  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition">
      <img
        src={product.image || "/placeholder.jpg"}
        alt={product.name}
        className="w-full aspect-square object-contain bg-gray-100"
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
