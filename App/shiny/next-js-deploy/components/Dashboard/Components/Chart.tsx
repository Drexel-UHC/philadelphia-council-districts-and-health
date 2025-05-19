"use client";

import React, { useRef, useEffect, useState } from 'react';
import * as Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';
import { MetricData } from '@/components/Dashboard/types/dashboard_types';

// Enhanced interface for chart data points
interface DataPoint {
  y: number;
  valueFormatted: string;
  district: string;
  color?: string;
  id: string;
}

// Define interfaces for chart props
interface ChartProps {
  data: MetricData[];
  onHover?: (district: string | null) => void;
  // Remove highlightedDistrict prop
  // highlightedDistrict?: string | null;
  
  // Add a function to register the highlight function
  registerHighlightFunction?: (highlightFn: (district: string | null) => void) => void;
}

export const Chart: React.FC<ChartProps> = ({ 
  data, 
  onHover,
  // highlightedDistrict = null,
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
    
    // Skip for Heat Vulnerability Index
    const varName = data[0]?.var_name;
    if (varName === "weighted_hvi") return;
    
    // Get the sorted data (to match the chart's data order)
    const sortedData = [...data].sort((a, b) => b.value - a.value);
    
    // Update each point's color based on highlighted district
    if (chart.series[0]) {
      chart.series[0].points.forEach((point, index) => {
        const pointDistrict = sortedData[index].district;
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
    
    // Sort the data by value in descending order
    const sortedData = [...data].sort((a, b) => b.value - a.value);
    
    // Extract common properties from first data item
    const firstItem = sortedData[0];
    const varLabel = firstItem.var_label;
    const varName = firstItem.var_name;
    const cityAvg = firstItem.city_avg;
    const sourceYear = firstItem.source_year;
    const yAxisTitle = firstItem.ylabs;
    const subtitle = firstItem.var_def;
    
    // Get sorted categories (districts)
    const categories = sortedData.map(item => item.district);
    
    // Check if it's the weighted_hvi variable
    const isHeatVulnerabilityIndex = varName === "weighted_hvi";
    
    if (isHeatVulnerabilityIndex) {
      // Simple message chart for HVI
      setChartOptions({
        title: {
          text: varLabel
        },
        subtitle: {
          text: "Heat Vulnerability Index is shown on map"
        },
        credits: {
          enabled: true,
          text: sourceYear
        },
        series: []
      });
    } else {
      // Transform data into Highcharts format with default colors
      const chartData: DataPoint[] = sortedData.map(item => ({
        y: item.value,
        valueFormatted: item.value_clean,
        district: item.district,
        // Use a default color (not based on highlighted district)
        color: "#CCCCCC",
        id: item.district
      }));
      
      // Create chart options
      const options: Highcharts.Options = {
        chart: {
          type: "column",
          style: {
            transition: 'none'
          }
        },
        title: {
          text: varLabel
        },
        subtitle: {
          text: subtitle
        },
        xAxis: {
          categories: categories,
          title: {
            text: "Council District"
          }
        },
        yAxis: {
          title: {
            text: yAxisTitle,
            style: {
              transition: 'none'
            }
          },
          
          min: 0,
          plotLines: [{
            value: cityAvg,
            color: "#707070",
            dashStyle: "ShortDash",
            width: 2,
            label: {
              text: `City Average: ${cityAvg.toFixed(1)}`,
              align: "right",
              style: {
                color: "#707070"
              }
            },
            zIndex: 5
          }]
        },
        plotOptions: {
          column: {
            dataLabels: {
              enabled: true,
              format: "{point.valueFormatted}"
            },
            borderWidth: 0,
            pointPadding: 0.1,
            animation: {
              duration: 150,
              // Use a linear easing function for constant animation speed
              easing: 'linear'
            },
            
            // Add point events for hover tracking
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
          }
        },
        tooltip: {
          headerFormat: '',
          pointFormat: '<span style="color:{point.color}">\u25CF</span> <b>District {point.district}:</b> {point.valueFormatted}<br/>',
          hideDelay: 0,     // Remove delay when hiding tooltip 
          animation: false,  // Disable tooltip animation
          // followPointer: true, // Make tooltip follow the pointer more closely
          snap: 0           // Remove sn
        },
        exporting: {
          enabled: true,
          filename: `philly-council-chart-${varName}`
        },
        credits: {
          enabled: true,
          text: sourceYear
        },
        series: [{
          name: varLabel,
          type: "column",
          showInLegend: false,
          data: chartData
        }] as Highcharts.SeriesOptionsType[]
      };
      
      setChartOptions(options);
    }
    
    // Increment key to force a complete re-render of the chart component
    setKey(prevKey => prevKey + 1);
    
  }, [data]); // Remove highlightedDistrict from dependencies

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
        key={key} // This is the key change - forces a full re-render
        highcharts={Highcharts}
        options={chartOptions}
        ref={chartComponentRef}
      />
    </div>
  );
};

export default Chart;