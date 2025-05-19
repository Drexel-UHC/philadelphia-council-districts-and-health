"use client";

import React, { useEffect, useState } from "react";
import { SelectMetric } from "@/components/Dashboard/Components/SelectMetric";
import { Chart } from "@/components/Dashboard/Components/Chart";
import { Map } from "@/components/Dashboard/Components/Map";
import { MetricData, MetricMetadata } from '@/components/Dashboard/types/dashboard_types';

// Define the interface for the hovered district state
interface HoveredDistrictState {
  district: string | null;
  activeComponent: "chart" | "map" | null;
}

export default function DashboardLayout() {
  const [metadata, setMetadata] = useState<MetricMetadata[]>([]);
  const [data, setData] = useState<MetricData[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedMetric, setSelectedMetric] = useState<MetricMetadata | null>(null);
  const [filteredData, setFilteredData] = useState<MetricData[]>([]);
  
  // Add new state for tracking hovered district
  const [hoveredDistrict, setHoveredDistrict] = useState<HoveredDistrictState>({
    district: null,
    activeComponent: null
  });

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
      const filtered = data
        .filter(item => item.var_name === selectedMetric.var_name)
        .sort((a, b) => b.value - a.value);
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
        <SelectMetric
          data={metadata}
          onSelectMetric={setSelectedMetric}
        /> 
     
    </div>
  );
  
  // Text section showing the hovered district information
  const hoveredDistrictInfo = (
    <div className="mt-4 p-3 bg-blue-50 rounded-md border border-blue-200">
      <h3 className="text-lg font-medium mb-1">Currently Hovering:</h3>
      {hoveredDistrict.district ? (
        <p>
          District <span className="font-bold">{hoveredDistrict.district}</span> 
          {hoveredDistrict.activeComponent && (
            <span className="ml-2 text-gray-600">
              (via {hoveredDistrict.activeComponent === "chart" ? "Chart" : "Map"})
            </span>
          )}
        </p>
      ) : (
        <p className="text-gray-500">Hover over a district on the map or chart to see details</p>
      )}
    </div>
  );
  
  // Create a memoized hover handler for the Chart to prevent re-renders
  const chartHoverHandler = React.useCallback((district: string | null) => {
    setHoveredDistrict({ 
      district, 
      activeComponent: district ? "chart" : null 
    });
  }, []);
  
  // Create a memoized hover handler for the Map to prevent re-renders
  const mapHoverHandler = React.useCallback((district: string | null) => {
    setHoveredDistrict({ 
      district, 
      activeComponent: district ? "map" : null 
    });
  }, []);
  
  // Clean return statement with abstracted sections
  return (
    <section id="dashboard" className="mb-12">
      {text}
      {selectionSection}
      {hoveredDistrictInfo} {/* Add the hoveredDistrict info section */}
      <div className="mt-8 grid grid-cols-12 gap-6">
        <div className="col-span-12 md:col-span-7 bg-white rounded-md shadow-sm p-4">
          <Chart 
            data={filteredData} 
            onHover={chartHoverHandler}
          />
        </div>
        <div className="col-span-12 md:col-span-5 bg-white rounded-md shadow-sm p-4">
          <Map 
            data={filteredData} 
            onHover={mapHoverHandler}
          />
        </div>
      </div>
    </section>
  );
}