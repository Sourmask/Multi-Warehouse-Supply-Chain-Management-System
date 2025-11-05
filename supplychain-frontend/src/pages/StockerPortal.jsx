import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

const BASE_URL = "http://localhost:5050/api/stocker";

const StockerPortal = () => {
  const [jobs, setJobs] = useState([]);
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const storedUser = JSON.parse(localStorage.getItem("user"));
  const employeeId = storedUser?.id;
  const role = storedUser?.role;

  // Block non-stockers
  useEffect(() => {
    if (!storedUser) {
      navigate("/login");
      return;
    }
    if (role !== "Stocker") {
      alert("Access denied. This page is for Stockers only.");
      navigate("/");
    }
  }, [storedUser, role, navigate]);

  useEffect(() => {
    fetchJobs();
  }, []);

  const fetchJobs = async () => {
    setLoading(true);
    try {
      const res = await fetch(`${BASE_URL}/jobs/${employeeId}`);
      const data = await res.json();
      setJobs(data);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const handleTake = async (wq_id) => {
    const res = await fetch(`${BASE_URL}/take`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ employee_id: employeeId, wq_id }),
    });
    const data = await res.json();
    alert(data.message || data.error);
    fetchJobs();
  };

  const handleComplete = async (wq_id) => {
    const res = await fetch(`${BASE_URL}/complete`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ employee_id: employeeId, wq_id }),
    });
    const data = await res.json();
    alert(data.message || data.error);
    fetchJobs();
  };

  return (
    <div className="p-6 bg-gray-100 min-h-screen">
      <div className="flex justify-between items-center mb-4">
        <h2 className="text-2xl font-bold">Stocker Portal</h2>
        <button
          onClick={fetchJobs}
          className="bg-blue-500 hover:bg-blue-600 text-white px-4 py-2 rounded"
        >
          Refresh Jobs
        </button>
      </div>

      {loading ? (
        <p>Loading jobs...</p>
      ) : jobs.length === 0 ? (
        <p className="text-gray-500">No jobs available.</p>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {jobs.map((job) => (
            <div key={job.wq_id} className="bg-white shadow-lg rounded-xl p-4">
              <h3 className="text-lg font-semibold mb-2">
                Order #{job.order_id}
              </h3>
              <p><strong>Warehouse:</strong> {job.warehouse_name}</p>
              <p><strong>Customer:</strong> {job.user_name}</p>
              <p><strong>Pincode:</strong> {job.pincode}</p>

              <div className="mt-3 flex gap-2">
                {job.assigned_employee === null && (
                  <button
                    className="bg-yellow-400 hover:bg-yellow-500 text-white px-3 py-1 rounded"
                    onClick={() => handleTake(job.wq_id)}
                  >
                    Take Job
                  </button>
                )}
                {job.assigned_employee === employeeId && (
                  <button
                    className="bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded"
                    onClick={() => handleComplete(job.wq_id)}
                  >
                    Mark Picked
                  </button>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default StockerPortal;
