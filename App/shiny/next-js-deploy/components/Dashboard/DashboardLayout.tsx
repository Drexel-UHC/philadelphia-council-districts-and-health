"use client";

import { useEffect, useState } from "react";
import { SelectMetric } from "@/components/Dashboard/Components/SelectMetric";

// Define the type for our metadata
interface MetricMetadata {
  var_label: string;
  var_def: string;
  source: string;
  year: string;
  var_name: string;
  ylabs: string;
}

export default function DashboardLayout() {
  const [healthData, setHealthData] = useState<MetricMetadata[]>([]);
  const [loading, setLoading] = useState(true);
  // const [selectedMetric, setSelectedMetric] = useState<string | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        const response = await fetch('./data/df_metadata.json');
        const data = await response.json();
        console.log("Fetched data:", data);
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
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <SelectMetric data={healthData} />
              
       
     
          
     
        </div>
      )}
    </section>
  );
}