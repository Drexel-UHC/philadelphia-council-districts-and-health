"use client";

import React, { useRef, useEffect, useState } from 'react';
import Highcharts from "highcharts/esm/highcharts.js";
import HighchartsReact from 'highcharts-react-official';
import "highcharts/esm/modules/map.js";
import { MetricData } from '@/components/Dashboard/types/dashboard_types';

// Define interfaces for map props and data
interface MapProps {
  title?: string;
  data?: MetricData[]; // Match Chart component prop name
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

export const Map: React.FC<MapProps> = ({ 
  title = "Philadelphia Health Index by District",
  data = []
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  const [mapOptions, setMapOptions] = useState<Highcharts.Options | null>(null);
  const [geoJson, setGeoJson] = useState<GeoJsonCollection | null>(null);

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
      } catch (error) {
        console.error("Error loading map data:", error);
      }
    };

    loadGeoJson();
  }, []);

  // Update map options when data or geoJson changes
  useEffect(() => {
    if (!geoJson || data.length === 0) return;
    
    // Get first item to extract metadata
    const selectedMetric = data[0];
    
    // Calculate min and max values for color axis
    const values = data.map(d => d.value);
    const min = Math.min(...values);
    const max = Math.max(...values);
    
    // Create map options with all animations disabled
    const options: Highcharts.Options = {
      chart: {
        map: geoJson,
        // height: 500,
        animation: false
        // Disable all animations at the chart level
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
      plotOptions: {
        series: {
          animation: false
        },
        map: {
          animation: false,
          // Ensure no animations for states like hover
          states: {
            hover: {
              animation: {
                duration: 0
              }
            },
            inactive: {
              animation: {
                duration: 0
              }
            },
            select: {
              animation: {
                duration: 0
              }
            }
          }
        }
      },
      legend: {
        enabled: true,
        title: {
          text: selectedMetric?.ylabs || 'Health Index'
        },
        valueDecimals: 1,
        valueSuffix: selectedMetric?.ylabs ? ` ${selectedMetric.ylabs}` : '%',
        // Disable legend animations
        navigation: {
          animation: false
        },
        // Additional animation disabling for legend
        itemStyle: {
          // animation: false // 'animation' is not a valid property for itemStyle
        },
        itemHoverStyle: {
          // animation: false // 'animation' is not a valid property for itemHoverStyle
        }
        // Removed invalid 'animation' property from legend options
      },
      series: [{
        type: 'map',
        // Disable animation at series level
        animation: false,
        name: selectedMetric?.var_label,
        data: data.map(d => ({
          district: d.district,
          value: d.value,
          value_clean: d.value_clean
        })),
        joinBy: ['district', 'district'],
        states: {
          hover: {
            color: '#a4edba',
            animation: {
              duration: 0
            }
          },
          inactive: {
            animation: {
              duration: 0
            }
          },
          select: {
            animation: {
              duration: 0
            }
          }
        },
        dataLabels: {
          enabled: true,
          // Disable animation for data labels
          animation: false,
          defer: false,
          format: '{point.district}'
        } 
      }] as Highcharts.SeriesOptionsType[]
    };
    
    // Apply global animation settings
    Highcharts.setOptions({
      plotOptions: {
        series: {
          animation: false
        }
      }
    });
    
    setMapOptions(options);
  }, [geoJson, data, title]);
 
 
  
  // Show "Select Metric" message if no data or options
  if (!mapOptions || data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[500px] bg-gray-100 rounded-md">
        <div className="text-center">
          <p className="text-lg font-medium text-gray-600">Select a Metric</p>
          <p className="text-sm text-gray-500 mt-2">Choose a health metric to view the map</p>
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