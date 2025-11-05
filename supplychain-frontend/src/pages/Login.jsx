import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

function Login({ setCurrentUser }) {
  const [userType, setUserType] = useState("user");
  const [emailOrId, setEmailOrId] = useState("");
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();

    try {
      console.log("Logging in as:", userType, emailOrId);

      if (userType === "user") {
        const res = await axios.post("http://localhost:5050/login/user", {
          email: emailOrId,
        });

        console.log("User response:", res.data);

        setCurrentUser(res.data);
        localStorage.setItem("user", JSON.stringify(res.data));

        navigate("/");
      } else {
        const emp_id = parseInt(emailOrId, 10);
        if (!emp_id) {
          alert("Enter valid employee ID");
          return;
        }

        const res = await axios.post("http://localhost:5050/login/employee", {
          emp_id: emp_id,
        });

        console.log("Employee response:", res.data);
        const employee = res.data;

        if (employee.role === "Stocker" || employee.role === "Packer") {
          setCurrentUser(employee);
          localStorage.setItem("user", JSON.stringify(employee));

          // ✅ redirect based on role
          if (employee.role === "Stocker") navigate("/stocker");
          else if (employee.role === "Packer") navigate("/packer");

        } else {
          alert("Only Stockers/Packers can login here.");
        }
      }
    } catch (err) {
      console.error(err);
      alert(err.response?.data?.error || "Login failed");
    }
  };

  return (
    <div className="flex justify-center items-center min-h-screen bg-gray-100">
      <form
        onSubmit={handleLogin}
        className="bg-white p-8 rounded shadow-md w-96 flex flex-col gap-4"
      >
        <h2 className="text-2xl font-bold text-gray-800 mb-4">Login</h2>

        <div className="flex gap-4">
          <label>
            <input
              type="radio"
              value="user"
              checked={userType === "user"}
              onChange={() => setUserType("user")}
            />{" "}
            User
          </label>
          <label>
            <input
              type="radio"
              value="employee"
              checked={userType === "employee"}
              onChange={() => setUserType("employee")}
            />{" "}
            Employee
          </label>
        </div>

        {userType === "user" ? (
          <input
            type="email"
            placeholder="Email"
            value={emailOrId}
            onChange={(e) => setEmailOrId(e.target.value)}
            required
            className="border p-2 rounded w-full"
          />
        ) : (
          <input
            type="number"
            placeholder="Employee ID"
            value={emailOrId}
            onChange={(e) => setEmailOrId(e.target.value)}
            required
            className="border p-2 rounded w-full"
          />
        )}

        <button
          type="submit"
          className="bg-blue-600 text-white py-2 rounded hover:bg-blue-700"
        >
          Login
        </button>
      </form>
    </div>
  );
}

export default Login;
