"use client";

import React, { useRef, useEffect, useState } from 'react';
import * as Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { MetricData } from '@/components/Dashboard/types/dashboard_types';

// Enhanced interface for scatter chart data points
interface ScatterDataPoint {
  x: number; // District position (0-9, sorted by value)
  y: number; // HVI value
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
    
    // Create categories for X-axis (districts sorted by value)
    const categories = sortedData.map(item => `District ${item.district}`);
    
    // Transform data into scatter plot format
    // X-axis will be district position (0-9), Y-axis will be the HVI value
    const chartData: ScatterDataPoint[] = sortedData.map((item, index) => ({
      x: index, // Position in sorted order as X coordinate (0 = highest value)
      y: item.value, // HVI value as Y coordinate
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
          text: "Council District"
        },
        categories: categories,
        min: 0,
        max: categories.length - 1,
        tickInterval: 1,
        labels: {
          style: {
            fontSize: '10px'
          }
        },
        startOnTick: true,
        endOnTick: true,
        tickPositions: Array.from({length: categories.length}, (_, i) => i)
      },
      yAxis: {
        title: {
          text: xAxisTitle,
          style: {
            transition: 'none'
          }
        },
        startOnTick: false,
        endOnTick: false,
        tickPositions: (() => {
          // Get min and max from the data
          const values = chartData.map(d => d.y);
          const dataMin = Math.min(...values);
          const dataMax = Math.max(...values);
          const range = dataMax - dataMin;
          const padding = range * 0.01; // 1% padding
          
          // Create specific tick positions with padding
          return [
            dataMin + padding,    // Low position
            dataMax - padding     // High position
          ];
        })(),
        labels: {
          formatter: function() {
            const values = chartData.map(d => d.y);
            const dataMin = Math.min(...values);
            const dataMax = Math.max(...values);
            const range = dataMax - dataMin;
            const padding = range * 0.01;
            
            const value = typeof this.value === 'number' ? this.value : parseFloat(this.value as string);
            
            if (Math.abs(value - (dataMin + padding)) < 0.01) {
              return 'Low';
            } else if (Math.abs(value - (dataMax - padding)) < 0.01) {
              return 'High';
            } else {
              return '';
            }
          },
          style: {
            fontSize: '12px'
          }
        },
        tickLength: 0, // Remove tick marks
        lineWidth: 0,  // Remove axis line
        gridLineWidth: 0, // Remove grid lines
        plotLines: [{
          value: cityAvg,
          color: "#707070",
          dashStyle: "ShortDash",
          width: 2,
          label: {
            text: 'City Average', // Keep just "City Average" without the number
            align: "left",
            verticalAlign: "middle",
            rotation: 0,
            x: 5,
            style: {
              color: "#707070", 
            }, 
          },
          zIndex: 25
        }]
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
          animation: {
            duration: 150,
            easing: 'linear'
          },
          dataLabels: {
            enabled: false // Disable data labels completely
          },
          jitter: {
            x: 0.1 // Add slight horizontal jitter to prevent overlap
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
