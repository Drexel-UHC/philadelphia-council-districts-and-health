"use client";

import { useEffect, useState } from "react";
import { SelectMetric } from "@/components/Dashboard/Components/SelectMetric";

export default function DashboardLayout() {
  const [healthData, setHealthData] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch('/data/df_metadata.json');
        const data = await response.json();
        setHealthData(data);
      } catch (error) {
        console.error("Error loading data:", error);
      } finally {
        setLoading(false);
      }
    }
    
    fetchData();
  }, []);

  return (
    <section id="dashboard" className="mb-12">
      <h2 className="text-2xl font-bold mb-6">Interactive Dashboard</h2>
      {loading ? (
        <div className="p-4 bg-gray-100 rounded">Loading dashboard data...</div>
      ) : (
        <>
          <SelectMetric />
          {/* Other components using the data */}
        </>
      )}
    </section>
  );
}