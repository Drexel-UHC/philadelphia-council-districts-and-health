"use client";

import React, { useEffect, useState, useRef, Suspense } from "react";
import { useSearchParams, usePathname } from "next/navigation";
import { SelectMetric } from "@/components/Dashboard/Components/SelectMetric";
import { Chart } from "@/components/Dashboard/Components/Chart";
import { Map } from "@/components/Dashboard/Components/Map";
import { MetricData, MetricMetadata } from '@/components/Dashboard/types/dashboard_types';
import { AnchorHeading } from "@/components/ui/anchor-heading";
import { ShareButton } from "@/components/Dashboard/Components/ShareButton";

// Define the interface for the hovered district state
interface HoveredDistrictState {
  district: string | null;
  activeComponent: "chart" | "map" | null;
}

// Create a client component that uses the search params
function DashboardContent() {
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

  // Create a ref to hold the Chart component's highlight function
  const chartHighlightRef = useRef<((district: string | null) => void) | null>(null);

  // Access search params and router for URL manipulation
  const searchParams = useSearchParams();
  // const router = useRouter();
  const pathname = usePathname();
  
  // Fetch initial data
  useEffect(() => {
    async function fetchData() {
      try {
        const response_metadata = await fetch('./data/df_metadata.json');
        const metadata = await response_metadata.json();
        setMetadata(metadata);
        
        const response_data = await fetch('./data/df_data.json');
        const data = await response_data.json();

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
    } else {
      setFilteredData([]);
    }
  }, [selectedMetric, data]);

  // Add a new function to get the correct base URL for both local and GitHub Pages environments
  const getBaseUrl = () => {
    // Check if we're running in a browser environment
    if (typeof window === 'undefined') return '';
    
    // For GitHub Pages, we need to include the repository name in the path
    // Look for "philadelphia-council-districts-and-health" in the current location
    const url = window.location.href;
    const repoName = '/philadelphia-council-districts-and-health/';
    
    if (url.includes('github.io') && url.includes(repoName)) {
      // We're on GitHub Pages, return the full base path
      const ghPagesBase = url.substring(0, url.indexOf(repoName) + repoName.length);
      return ghPagesBase;
    }
    
    // Default to the current path for local development
    return window.location.pathname;
  };

  // Modified function to handle metric selection and update URL
  const handleMetricSelect = (metric: MetricMetadata | null) => {
    // Update the local state with the new metric
    setSelectedMetric(metric);
    
    // Get the appropriate base URL
    const baseUrl = getBaseUrl();
    
    // Update URL with the selected metric, but use browser history API for GitHub Pages
    if (metric) {
      // Instead of using router.replace which can cause page reloads
      const params = new URLSearchParams(searchParams.toString());
      params.set('metric', metric.var_name);
      
      // Use history.pushState with the right base URL
      window.history.pushState(
        { metric: metric.var_name },
        '',
        `${baseUrl}?${params.toString()}`
      );
    } else {
      // Remove the metric parameter if no metric is selected
      const params = new URLSearchParams(searchParams.toString());
      params.delete('metric');
      
      // Use history.pushState with the right base URL
      window.history.pushState(
        { metric: null },
        '',
        `${baseUrl}?${params.toString()}`
      );
    }
  };
  
  // Listen for popstate events (when user navigates with browser back/forward buttons)
  useEffect(() => {
    const handlePopState = () => {
      // Check URL parameters after navigation
      const params = new URLSearchParams(window.location.search);
      const metricParam = params.get('metric');
      
      if (metricParam && metadata.length > 0) {
        const metricFromUrl = metadata.find(m => m.var_name === metricParam);
        if (metricFromUrl) {
          setSelectedMetric(metricFromUrl);
        }
      } else if (metadata.length > 0) {
        // Set default if no metric in URL after navigation
        const defaultMetric = metadata.find(m => m.var_name === 'hs_grad_pct');
        if (defaultMetric) {
          setSelectedMetric(defaultMetric);
        }
      }
    };

    // Add event listener for browser navigation
    window.addEventListener('popstate', handlePopState);
    
    // Remove event listener on cleanup
    return () => {
      window.removeEventListener('popstate', handlePopState);
    };
  }, [metadata]);
  
  // Effect to initialize state from URL parameters or set default
  useEffect(() => {
    // Only run after metadata is loaded
    if (metadata.length === 0) return;
    
    // Get the metric from URL parameters
    const metricParam = searchParams.get('metric');
    
    if (metricParam) {
      // Find the corresponding metric metadata from URL
      const metricFromUrl = metadata.find(m => m.var_name === metricParam);
      
      if (metricFromUrl && (!selectedMetric || selectedMetric.var_name !== metricParam)) {
        // Set the selected metric based on URL
        setSelectedMetric(metricFromUrl);
      }
    } else if (!selectedMetric) {
      // If no metric parameter and no metric selected yet, set the default (hs_grad_pct)
      const defaultMetric = metadata.find(m => m.var_name === 'hs_grad_pct');
      
      if (defaultMetric) {
        // Set the default metric
        setSelectedMetric(defaultMetric);
        
        // Get the appropriate base URL
        const baseUrl = getBaseUrl();
        
        // Update URL using history API instead of router.replace
        const params = new URLSearchParams(searchParams.toString());
        params.set('metric', defaultMetric.var_name);
        window.history.replaceState(
          { metric: defaultMetric.var_name },
          '',
          `${baseUrl}?${params.toString()}`
        );
      }
    }
  }, [searchParams, metadata, selectedMetric, pathname]);
  
  // Text section as a JSX element
  const text = (
    <div className="mb-8">
      <AnchorHeading
        id="dashboard-intro"
        className="text-3xl font-bold mb-4 pb-2 border-b border-gray-300"
      >
        How to Use:
      </AnchorHeading>
      <p>To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city.</p>
    </div>
  );

  // Modified selection section with share button and explicit selectedMetric prop
  const selectionSection = loading ? (
    <div className="p-4 bg-gray-100 rounded">Loading dashboard data...</div>
  ) : (
      <div>
        <p className="pb-1 font-bold">Select a health metric:</p>
        <div className="grid grid-cols-12 gap-6 items-center">

          <div className="col-span-12 sm:col-span-8 ">
            <SelectMetric
              data={metadata}
              onSelectMetric={handleMetricSelect}
              selectedMetric={selectedMetric}
            />
          </div>

            <div className="hidden sm:col-span-2 md:col-start-11 md:flex justify-center md:justify-end">
              <ShareButton selectedMetric={selectedMetric} />
            </div>

        </div>
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
    // Update the hoveredDistrict state
    setHoveredDistrict({ 
      district, 
      activeComponent: district ? "map" : null 
    });
    
    // Directly call the chart highlight function if available
    if (chartHighlightRef.current) {
      chartHighlightRef.current(district);
    }
  }, []);
  
  // Extract just the district id for highlighting
  const highlightedDistrictId = hoveredDistrict?.district || null;
  
  // Return the dashboard content
  return (
    <>
      {text}
      {selectionSection} 
      <div className="mt-8 grid grid-cols-12 gap-6">
        <div className="col-span-12 md:col-span-7 bg-white rounded-md shadow-sm p-4">
          <Chart 
            data={filteredData} 
            onHover={chartHoverHandler}
            registerHighlightFunction={(fn) => {
              chartHighlightRef.current = fn;
            }}
          />
        </div>
        <div className="col-span-12 md:col-span-5 bg-white rounded-md shadow-sm p-4">
          <Map 
            data={filteredData} 
            onHover={mapHoverHandler}
            highlightedDistrict={hoveredDistrict.activeComponent === "chart" ? highlightedDistrictId : null}
          />
        </div>
      </div>
    </>
  );
}

// Main dashboard component with Suspense boundary
export default function DashboardLayout() {
  return (
    <section id="how-to-use" className="mb-12">
      <Suspense fallback={
        <div className="flex items-center justify-center h-[400px]">
          <div className="text-center">
            <p className="text-lg font-medium">Loading dashboard...</p>
            <p className="text-sm text-gray-500 mt-2">Please wait while we prepare the data</p>
          </div>
        </div>
      }>
        <DashboardContent />
      </Suspense>
    </section>
  );
}