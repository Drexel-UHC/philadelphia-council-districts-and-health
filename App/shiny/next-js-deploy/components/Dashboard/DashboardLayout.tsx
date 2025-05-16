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
  const [filteredData, setFilteredData] = useState<MetricData[]>([]);

  // Fetch initial data
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

  // Filter data when selectedMetric changes (equivalent to R's filter function)
  useEffect(() => {
    if (selectedMetric && data.length > 0) {
      // This is equivalent to: df_data |> filter(var_name == 'selectedVarName')
      const filtered = data.filter(item => item.var_name === selectedMetric.var_name);
      setFilteredData(filtered);
      console.log("Filtered data:", filtered);
    } else {
      setFilteredData([]);
    }
  }, [selectedMetric, data]);

  return (
    <section id="dashboard" className="mb-12">
      <h1 className="text-3xl font-bold mb-4 pb-2 border-b-1 border-gray-300">How to Use:</h1>
      <p>To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city.</p>

      
      {loading ? (
        <div className="p-4 bg-gray-100 rounded">Loading dashboard data...</div>
      ) : (
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <SelectMetric
              data={metadata}
              onSelectMetric={setSelectedMetric}
            />
        
            {selectedMetric ? (
              <div>{selectedMetric.var_label}</div>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-500">
                <p>Please select a health metric to view details</p>
              </div>
            )}
            {filteredData ? (
                <div>
                {filteredData.map(item => `${item.district}: ${item.value}`).join(", ")}
                </div>
            ) : (
              <div className="h-full flex items-center justify-center text-gray-500">
                <p>No filtered Data</p>
              </div>
            )}
          </div>
      )}
    </section>
  );
}