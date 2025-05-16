"use client";

import React, { useRef, useEffect, useState } from 'react';
import Highcharts from "highcharts/esm/highcharts.js";
import HighchartsReact from 'highcharts-react-official';
import "highcharts/esm/modules/map.js";

// Define interfaces for map props and data
interface MapProps {
  title?: string;
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
  };
  geometry: {
    type: string;
    coordinates: number[][][];
  };
}

interface GeoJsonCollection {
  type: string;
  features: GeoJsonFeature[];
}

// Generate random data for the districts
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
  title = "Philadelphia Health Index by District"
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  const [isLoading, setIsLoading] = useState(true);
  // const [geoJson, setGeoJson] = useState<GeoJsonCollection | null>(null);
  // const [healthData, setHealthData] = useState<DistrictData[]>([]);
  const [mapOptions, setMapOptions] = useState<Highcharts.Options | null>(null);

  // Load GeoJSON data and create map options
  useEffect(() => {
    const loadMapData = async () => {
      try {
        // Fetch the GeoJSON file from public directory
        const response = await fetch('./data/geojson_districts.json');
        if (!response.ok) {
          throw new Error(`Error loading GeoJSON: ${response.status}`);
        }
        
        // Parse the GeoJSON data
        const data: GeoJsonCollection = await response.json();
        // setGeoJson(data);
        
        // Generate random health data
        const districtData = generateRandomHealthData();
        // setHealthData(districtData);
        
        // Create map options
        const options: Highcharts.Options = {
          chart: {
            map: data,
            height: 500
          },
          title: {
            text: title
          },
          subtitle: {
            text: 'Health metrics across Philadelphia council districts'
          },
          credits: {
            enabled: true,
            text: 'Source: Simulated data (2025)'
          },
          mapNavigation: {
            enabled: true,
            buttonOptions: {
              verticalAlign: 'bottom'
            }
          },
          colorAxis: {
            min: 0,
            max: 100,
            stops: [
              [0, '#EFEFFF'],
              [0.5, '#4444BB'],
              [1, '#000066']
            ]
          },
          legend: {
            title: {
              text: 'Health Index (%)'
            },
            valueDecimals: 1,
            valueSuffix: '%'
          },
          series: [{
            type: 'map',
            name: 'Health Index',
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
        setIsLoading(false);
      } catch (error) {
        console.error("Error loading map data:", error);
      }
    };

    loadMapData();
  }, [title]);

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