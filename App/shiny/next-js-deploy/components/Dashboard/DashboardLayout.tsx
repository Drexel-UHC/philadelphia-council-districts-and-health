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
interface MetricData {
  district: string;           // Council district number as string (e.g., "1")
  var_name: string;           // Variable name/identifier
  value: number;              // Metric value (numeric)
  city_avg: number;           // City average for this metric
  var_label: string;          // Human-readable metric name
  var_def: string;            // Definition of the metric
  source: string;             // Data source
  year: string;               // Year of the data
  aggregation_notes: string;  // Notes about data aggregation
  cleaning_notes: string | null; // Notes about data cleaning, can be null
  ylabs: string;              // Y-axis label for charts
  district_int: number;       // District number as integer
  source_year: string;        // Combined source and year text
  value_clean: string;        // Formatted/cleaned value as string
}
export default function DashboardLayout() {
  const [metadata, setMetadata] = useState<MetricMetadata[]>([]);
  const [data, setData] = useState<MetricData[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedMetric, setSelectedMetric] = useState<MetricMetadata | null>(null);

  useEffect(() => {
    async function fetchData() {
      try {
        const response_metadata = await fetch('./data/df_metadata.json');
        const metadata = await response_metadata.json();
        setMetadata(metadata);
        const response_data = await fetch('./data/df_data.json');
        const data = await response_data.json();
        console.log("Data loaded:", data);
        setData(data);
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
            <SelectMetric 
              data={metadata} 
              onSelectMetric={setSelectedMetric} 
            />
            <div>
              <div> 
                {selectedMetric ? (
                  <div className="p-4 bg-gray-100 rounded-md">
                    {selectedMetric.var_label}
                  </div>
                ) : (
                  <p className="text-gray-500">No metric selected</p>
                )}
              </div>
            </div>
        </div>
      )}
    </section>
  );
}