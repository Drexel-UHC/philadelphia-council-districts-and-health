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

  // Text section as a JSX element
  const text = (
    <div className="mb-8">
      <h1 className="text-3xl font-bold mb-4 pb-2 border-b border-gray-300">How to Use:</h1>
      <p>To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city.</p>
    </div>
  );

  // Selection section as a JSX element
  const selectionSection = loading ? (
    <div className="p-4 bg-gray-100 rounded">Loading dashboard data...</div>
  ) : (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div className="bg-white p-4 rounded-md shadow-sm">
        <h3 className="text-lg font-semibold mb-3">Select Health Metric</h3>
        <SelectMetric
          data={metadata}
          onSelectMetric={setSelectedMetric}
        />
      </div>

      <div className="md:col-span-2 bg-white p-4 rounded-md shadow-sm">
        {selectedMetric ? (
          <div>
            <h3 className="text-xl font-bold mb-2">{selectedMetric.var_label}</h3>
            <p className="text-gray-600 mb-4">{selectedMetric.var_def}</p>
            <div className="bg-gray-50 p-3 rounded mb-4 text-sm">
              <div className="grid grid-cols-2 gap-x-4 gap-y-2">
                <div><span className="font-medium">Source:</span> {selectedMetric.source}</div>
                <div><span className="font-medium">Year:</span> {selectedMetric.year}</div>
                <div><span className="font-medium">Unit:</span> {selectedMetric.ylabs}</div>
              </div>
            </div>
          </div>
        ) : (
          <div className="h-full flex items-center justify-center text-gray-500">
            <p>Please select a health metric to view details</p>
          </div>
        )}
      </div>
    </div>
  );
  
 

  // Clean return statement with abstracted sections
  return (
    <section id="dashboard" className="mb-12">
      {text}
      {selectionSection}
     
    </section>
  );
}