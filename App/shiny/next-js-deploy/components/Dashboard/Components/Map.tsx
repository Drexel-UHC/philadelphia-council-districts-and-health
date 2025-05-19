"use client";

import React, { useRef, useEffect, useState } from 'react';
import Highcharts from "highcharts/esm/highcharts.js";
import HighchartsReact from 'highcharts-react-official';
import "highcharts/esm/modules/map.js";
import { MetricData, MetricMetadata } from '@/components/Dashboard/types/dashboard_types';

// Define interfaces for map props and data
interface MapProps {
  title?: string;
  data?: MetricData[]; // Match Chart component prop name
}

interface DistrictData {
  district: string;
  value: number;
  value_clean: string;
}

interface GeoJsonFeature {
  type: string;
  properties: {
    district: string;
    [key: string]: any; // Allow for additional properties
  };
  geometry: {
    type: string;
    coordinates: number[][][] | number[][][][] | number[]; // Handle different geometry types
  };
}

interface GeoJsonCollection {
  type: string;
  features: GeoJsonFeature[];
}

// Generate random data for the districts (keeping this as a fallback)
const generateRandomHealthData = (): DistrictData[] => {
  const districts = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
  return districts.map(district => {
    const value = Math.round(Math.random() * 100 * 10) / 10;
    return {
      district,
      value,
      value_clean: `${value}%`
    };
  });
};

export const Map: React.FC<MapProps> = ({ 
  title = "Philadelphia Health Index by District",
  data = []
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [mapOptions, setMapOptions] = useState<Highcharts.Options | null>(null);
  const [geoJson, setGeoJson] = useState<GeoJsonCollection | null>(null);

  // Process data to create district data
  const processMapData = (data: MetricData[]): DistrictData[] => {
    if (!data || data.length === 0) {
      return generateRandomHealthData(); // Fallback to random data
    }

    // Extract common properties
    const districts = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"];
    
    // Create a map of district to value for quick lookup
    const districtMap: Record<string, MetricData> = {};
    data.forEach(item => {
      if (item.district) {
        districtMap[item.district] = item;
      }
    });

    // Convert to DistrictData array
    return districts.map(district => {
      const item = districtMap[district];
      
      if (item) {
        return {
          district,
          value: item.value,
          value_clean: item.value_clean
        };
      }
      
      // Fallback for missing districts
      return {
        district,
        value: 0,
        value_clean: "0"
      };
    });
  };

  // Load GeoJSON data only once
  useEffect(() => {
    const loadGeoJson = async () => {
      try {
        // Fetch the GeoJSON file from public directory
        const response = await fetch('./data/geojson_districts.json');
        if (!response.ok) {
          throw new Error(`Error loading GeoJSON: ${response.status}`);
        }
        
        // Parse the GeoJSON data
        const data: GeoJsonCollection = await response.json();
        setGeoJson(data);
        setIsLoading(false);
      } catch (error) {
        console.error("Error loading map data:", error);
      }
    };

    loadGeoJson();
  }, []);

  // Update map options when data or geoJson changes
  useEffect(() => {
    if (!geoJson) return;
    
    // Process data to get district data
    const districtData = processMapData(data);
    
    // Get first item to extract metadata (if available)
    const selectedMetric = data.length > 0 ? data[0] : null;
    
    // Calculate min and max values for color axis
    const values = districtData.map(d => d.value);
    const min = Math.min(...values);
    const max = Math.max(...values);
    
    // Create map options
    const options: Highcharts.Options = {
      chart: {
        map: geoJson,
        height: 500
      },
      title: {
        text: selectedMetric?.var_label || title
      },
      subtitle: {
        text: selectedMetric?.var_def 
          ? `${selectedMetric.var_def} (${selectedMetric.source}, ${selectedMetric.year})` 
          : 'Health metrics across Philadelphia council districts'
      },
      credits: {
        enabled: true,
        text: `Source: ${selectedMetric?.source || 'Simulated data'} (${selectedMetric?.year || '2025'})`
      },
      mapNavigation: {
        enabled: false,
        enableMouseWheelZoom: false,
        enableTouchZoom: false,
        enableDoubleClickZoom: false,
        enableButtons: false
      },
      colorAxis: {
        min: min || 0,
        max: max || 100,
        stops: [
          [0, '#EFEFFF'],
          [0.5, '#4444BB'],
          [1, '#000066']
        ]
      },
      legend: {
        title: {
          text: selectedMetric?.ylabs || 'Health Index'
        },
        valueDecimals: 1,
        valueSuffix: selectedMetric?.ylabs ? ` ${selectedMetric.ylabs}` : '%'
      },
      series: [{
        type: 'map',
        name: selectedMetric?.var_label || 'Health Index',
        data: districtData.map(d => ({
          district: d.district,
          value: d.value,
          value_clean: d.value_clean
        })),
        joinBy: ['district', 'district'],
        states: {
          hover: {
            color: '#a4edba'
          }
        },
        dataLabels: {
          enabled: true,
          format: '{point.district}'
        } 
      }] as Highcharts.SeriesOptionsType[]
    };
    
    setMapOptions(options);
  }, [geoJson, data, title]);

  // Update chart when options change, without re-rendering the entire component
  useEffect(() => {
    if (chartComponentRef.current && mapOptions) {
      const chart = chartComponentRef.current.chart;
      
      // Update series data
      if (chart && chart.series[0]) {
        const districtData = processMapData(data);
        chart.series[0].setData(districtData.map(d => ({
          district: d.district,
          value: d.value,
          value_clean: d.value_clean
        })));
        
        // Update titles if there is data
        if (data.length > 0) {
          const selectedMetric = data[0];
          chart.setTitle(
            { text: selectedMetric?.var_label || title },
            { text: selectedMetric?.var_def 
              ? `${selectedMetric.var_def} (${selectedMetric.source}, ${selectedMetric.year})` 
              : 'Health metrics across Philadelphia council districts' 
            }
          );
          
          // Update color axis if it exists
          const colorAxis = chart.axes.find(axis => (axis as any).coll === 'colorAxis');
          if (colorAxis) {
            const values = districtData.map(d => d.value);
            const min = Math.min(...values);
            const max = Math.max(...values);
            colorAxis.update({
              min: min || 0,
              max: max || 100
            });
          }
        }
      }
    }
  }, [data, chartComponentRef]);

  // Show loading indicator until map data is ready
  if (isLoading || !mapOptions) {
    return (
      <div className="flex items-center justify-center h-[500px] bg-gray-100 rounded-md">
        <div className="text-center">
          <p className="text-lg font-medium text-gray-600">Loading map data...</p>
          <p className="text-sm text-gray-500 mt-2">Preparing Philadelphia district boundaries</p>
        </div>
      </div>
    );
  }

  return (
    <div className="map-container">
      <HighchartsReact
        highcharts={Highcharts}
        options={mapOptions}
        constructorType={"mapChart"}
        ref={chartComponentRef}
      />
    </div>
  );
};

// Example map component for easy usage
export const MapExample: React.FC = () => {
  return (
    <div className="p-4 bg-white rounded-md shadow-md">
      <Map title="Philadelphia Health Index by District" />
    </div>
  );
};

export default Map;