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
  onHover?: (district: string | null) => void; // Add the onHover callback prop
  highlightedDistrict?: string | null; // Add prop to receive highlighted district
}

interface GeoJsonFeature {
  type: string;
  properties: {
    district: string;
    [key: string]: string | number | boolean | object | null | undefined; // Allow for additional properties
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
  data = [],
  onHover,
  highlightedDistrict = null
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

  // Create a ref to store the onHover callback
  const onHoverRef = React.useRef(onHover);
  
  // Update the ref when onHover changes, without causing re-renders
  React.useEffect(() => {
    onHoverRef.current = onHover;
  }, [onHover]);
  
  // Update map options when data or geoJson changes
  useEffect(() => {
    if (!geoJson || data.length === 0) return;
    
    // Get first item to extract metadata
    const selectedMetric = data[0];
    const varName = selectedMetric.var_name;
    
    // Calculate min and max values for color axis
    const values = data.map(d => d.value);
    const min = Math.min(...values);
    const max = Math.max(...values);

    // Apply global animation settings
    Highcharts.setOptions({
      plotOptions: {
        series: {
          animation: false
        }
      }
    });
    
    // Create map options with all animations disabled
    const options: Highcharts.Options = {
      chart: {
        map: geoJson,
        height: 500,
        animation: false,
        style: {
          transition: 'none'
        }
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
      plotOptions: {
        series: {
          animation: false,
          point: {
            events: {
              // Handle mouseOver event using the ref to avoid re-renders
              mouseOver: function() {
                if (onHoverRef.current) {
                  // @ts-ignore - Highcharts typing issue with 'this'
                  onHoverRef.current(this.district);
                }
              },
              // Handle mouseOut event using the ref to avoid re-renders
              mouseOut: function() {
                if (onHoverRef.current) {
                  onHoverRef.current(null);
                }
              }
            }
          }
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
      tooltip: {
        useHTML: true,
        headerFormat: '',
        pointFormat: '<span style="font-size:13px"><b>District {point.district}</b>: {point.value_clean}</span>'
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
          allowOverlap: true, // Prevent positioning animations
          format: '{point.district}',
          style: {
            transition: 'none' // Override Tailwind's transitions
          }
        }
      }] as Highcharts.SeriesOptionsType[]
    };
    
    // Special case for Heat Vulnerability Index
    if (varName === "weighted_hvi") {
      // Custom colorAxis with special labels for HVI
      options.colorAxis = {
        min: min,
        max: max,
        stops: [
          [0, '#EFEFFF'],
          [0.5, '#4444BB'],
          [1, '#000066']
        ],
        labels: {
          formatter: function() {
            // @ts-ignore - 'this' context in Highcharts formatter
            if (this.value === this.axis.min) {
              return 'Low';
            } else if (this.value === this.axis.max) {
              return 'High';
            } else {
              return '';  // Hide other labels
            }
          },
          style: {
            fontSize: '12px',
            textOverflow: 'none'
          },
          useHTML: true
        }
      };
      
      // For HVI, set proper legend title to show "Heat Vulnerability Index"
      options.legend = {
        enabled: true,
        title: {
          text: 'Heat Vulnerability Index' // Explicitly set the correct title for HVI
        },
        navigation: {
          animation: false
        }
      };
    } else {
      // Regular colorAxis and legend for other variables
      options.colorAxis = {
        min: min,
        max: max,
        stops: [
          [0, '#EFEFFF'],
          [0.5, '#4444BB'],
          [1, '#000066']
        ]
      };
      
      options.legend = {
        enabled: true,
        title: {
          text: selectedMetric?.ylabs || 'Health Index'
        },
        valueDecimals: 1,
        valueSuffix: selectedMetric?.ylabs ? ` ${selectedMetric.ylabs}` : '%',
        navigation: {
          animation: false
        }
      };
    }
    
    setMapOptions(options);
  }, [geoJson, data, title]); // Remove onHover from dependencies
  
  // Update highlighted district when changes without re-rendering the entire map
  useEffect(() => {
    // Only run this if chart is already rendered and data exists
    if (chartComponentRef.current && chartComponentRef.current.chart && data.length > 0) {
      const chart = chartComponentRef.current.chart;
      
      // Update each point's color based on highlighted district
      if (chart.series[0] && chart.series[0].points) {
        chart.series[0].points.forEach((point) => {
          // @ts-ignore - district property exists on map points
          const district = point.district || point.properties?.district;
          
          if (district) {
            if (highlightedDistrict === district) {
              // Highlight this district
              point.setState('hover');
            } else {
              // Reset this district
              point.setState('');
            }
          }
        });
      }
    }
  }, [highlightedDistrict, data]);
  
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
      <style jsx>{`
        :global(.map-container *) {
          transition: none !important;
          animation: none !important;
        }
      `}</style>
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