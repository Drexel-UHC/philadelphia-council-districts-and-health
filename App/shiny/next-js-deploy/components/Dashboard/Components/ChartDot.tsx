"use client";

import React, { useRef, useEffect, useState } from 'react';
import * as Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { MetricData } from '@/components/Dashboard/types/dashboard_types';

// Enhanced interface for scatter chart data points
interface ScatterDataPoint {
  x: number; // HVI value
  y: number; // District position (0-9, sorted by value)
  valueFormatted: string;
  district: string;
  color?: string;
  id: string;
}

// Define interfaces for chart props
interface ChartDotProps {
  data: MetricData[];
  onHover?: (district: string | null) => void;
  registerHighlightFunction?: (highlightFn: (district: string | null) => void) => void;
}

export const ChartDot: React.FC<ChartDotProps> = ({ 
  data, 
  onHover,
  registerHighlightFunction
}) => {
  // Use a key value to force complete re-render when data changes
  const [key, setKey] = useState<number>(0);
  
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  
  // Set up the chart options
  const [chartOptions, setChartOptions] = useState<Highcharts.Options>({});

  // Create a ref to store the onHover callback
  const onHoverRef = React.useRef(onHover);
  
  // Update the ref when onHover changes, without causing re-renders
  React.useEffect(() => {
    onHoverRef.current = onHover;
  }, [onHover]);

  // Create a function to highlight a specific district
  const highlightDistrict = React.useCallback((district: string | null) => {
    if (!chartComponentRef.current || !chartComponentRef.current.chart || data.length === 0) {
      return;
    }
    
    const chart = chartComponentRef.current.chart;
    
    // Update each point's color based on highlighted district
    if (chart.series[0]) {
      chart.series[0].points.forEach((point) => {
        // @ts-expect-error - Highcharts typing issue with custom properties
        const pointDistrict = point.district;
        const newColor = district === pointDistrict ? "#6666FF" : "#CCCCCC";
        
        // Only update if color actually changed
        if (point.color !== newColor) {
          point.update({ color: newColor }, false); // false = don't redraw yet
        }
      });
      
      // Redraw the chart with all updates
      chart.redraw();
    }
  }, [data, chartComponentRef]);

  // Register the highlight function with the parent component
  useEffect(() => {
    if (registerHighlightFunction) {
      registerHighlightFunction(highlightDistrict);
    }
  }, [registerHighlightFunction, highlightDistrict]);

  // Process data and update chart options when data changes
  useEffect(() => {
    if (data.length === 0) return;
    
    // Sort the data by value in descending order (highest to lowest)
    const sortedData = [...data].sort((a, b) => b.value - a.value);
    
    // Extract common properties from first data item
    const firstItem = sortedData[0];
    const varLabel = firstItem.var_label;
    const varName = firstItem.var_name;
    const cityAvg = firstItem.city_avg;
    const sourceYear = firstItem.source_year;
    const xAxisTitle = firstItem.ylabs; // HVI values will be on X-axis
    const subtitle = firstItem.var_def;
    
    // Create categories for Y-axis (districts sorted by value)
    const categories = sortedData.map(item => `District ${item.district}`);
    
    // Transform data into scatter plot format
    // X-axis will be the HVI value, Y-axis will be district position (0-9)
    const chartData: ScatterDataPoint[] = sortedData.map((item, index) => ({
      x: item.value, // HVI value as X coordinate
      y: index, // Position in sorted order as Y coordinate (0 = highest value)
      valueFormatted: item.value_clean,
      district: item.district,
      // Use a default color (not based on highlighted district)
      color: "#CCCCCC",
      id: item.district
    }));

    // Create chart options for horizontal scatter plot
    const options: Highcharts.Options = {
      chart: {
        type: "scatter",
        height: 400,
        style: {
          transition: 'none'
        }
      },
      title: {
        text: varLabel,
        margin: 10,
        style: {
          fontSize: '20px',
          fontWeight: 'bold'
        }  
      },
      subtitle: {
        text: subtitle 
      },
      xAxis: {
        title: {
          text: xAxisTitle
        },
        labels: {
          style: {
            fontSize: '10px'
          }
        },
        plotLines: [{
          value: cityAvg,
          color: "#707070",
          dashStyle: "ShortDash",
          width: 2,
          label: {
            text: `City Average: ${cityAvg.toFixed(2)}`,
            align: "left",
            verticalAlign: "top",
            rotation: 0, // Horizontal text
            x: 5, // Offset to the right of the line
            style: {
              color: "#707070", 
            }, 
          },
          zIndex: 25
        }]
      },
      yAxis: {
        title: {
          text: "Council District",
          style: {
            transition: 'none'
          }
        },
        categories: categories,
        min: 0,
        max: categories.length - 1,
        tickInterval: 1,
        reversed: false, // Highest values at top
        labels: {
          style: {
            fontSize: '10px'
          }
        },
        startOnTick: true,
        endOnTick: true,
        tickPositions: Array.from({length: categories.length}, (_, i) => i)
      },
      plotOptions: {
        scatter: {
          marker: {
            radius: 8,
            states: {
              hover: {
                enabled: true,
                lineColor: '#333333'
              }
            }
          },
          dataLabels: {
            enabled: true,
            format: "{point.valueFormatted}",
            style: {
              fontSize: '10px'
            }
          },
          jitter: {
            y: 0.1 // Add slight vertical jitter to prevent overlap
          },
          // Add point events for hover tracking
          point: {
            events: {
              // Handle mouseOver event using the ref to avoid re-renders
              mouseOver: function() {
                if (onHoverRef.current) {
                  // @ts-expect-error - Highcharts typing issue with 'this'
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
        }
      },
      tooltip: {
        headerFormat: '',
        pointFormat: '<span style="color:{point.color}">\u25CF</span> <b>District {point.district}:</b> {point.valueFormatted}<br/>',
        hideDelay: 0,     // Remove delay when hiding tooltip 
        animation: false,  // Disable tooltip animation
        snap: 0           // Remove snap
      },
      exporting: {
        enabled: true,
        filename: `philly-council-scatter-${varName}`
      },
      credits: {
        enabled: true,
        text: sourceYear,
        style: {
          fontSize: '9px',
        }
      },
      series: [{
        name: varLabel,
        type: "scatter",
        showInLegend: false,
        data: chartData
      }] as Highcharts.SeriesOptionsType[]
    };
    
    setChartOptions(options);
    
    // Increment key to force a complete re-render of the chart component
    setKey(prevKey => prevKey + 1);
    
  }, [data]);

  // If no data or options not yet set, show placeholder
  if (data.length === 0 || Object.keys(chartOptions).length === 0) {
    return (
      <div className="flex items-center justify-center h-[400px] bg-gray-100">
        <p>No chart data available</p>
      </div>
    );
  }

  return (
    <div className="chart-container">
      <HighchartsReact
        key={key} // This forces a full re-render
        highcharts={Highcharts}
        options={chartOptions}
        ref={chartComponentRef}
      />
    </div>
  );
};

export default ChartDot;
