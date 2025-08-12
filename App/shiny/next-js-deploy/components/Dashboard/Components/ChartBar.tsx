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
interface ChartBarProps {
  data: MetricData[];
  onHover?: (district: string | null) => void;
  registerHighlightFunction?: (highlightFn: (district: string | null) => void) => void;
}

export const ChartBar: React.FC<ChartBarProps> = ({ 
  data, 
  onHover,
  registerHighlightFunction
}) => {
  // Mobile state detection
  const [isMobile, setIsMobile] = useState(false);
  
  // 1. Variable configs ------
  // Variables to disable data labels on all devices
  const alwaysDisableDataLabels: string[] = [
    "pct_pi",
    "district_lack_kitch_pct",    // Lack Complete Kitchen
    "district_lack_plumb_pct",    // Lack Complete Plumbing
    "district_median_age_total"   // Median Age
  ];
  
  // Variables to disable data labels on mobile only
  const mobileDisableDataLabels: string[] = [
    "total_active_licenses_norentals", // Total Active Licenses (No Rentals)
    "total_active_licenses_rentalsonly", // Total Active Licenses (Rentals Only)
    "pct_violations",             // Code Violations
    "less_than_hs_pct",          // Education: Less than High School
    "hs_grad_pct",              // Education: High School Graduate
    "college_grad_pct",           // Education: College Graduate
    "some_college_pct",           // Education: Some College
    "pct_owner",                  // Homeowners
    "district_lack_kitch_pct",    // Lack Complete Kitchen (also in desktop list)
    "district_lack_plumb_pct",    // Lack Complete Plumbing (also in desktop list)
    "district_median_age_total",  // Median Age (also in desktop list)
    "median_hh_income_district",  // Median Household Income
    "pct_native",                 // Race and Ethnicity: Native American
    "pct_pi",                     // Race and Ethnicity: Pacific Islander
    "pct_renter"                  // Renters
  ];

  // Use a key value to force complete re-render when data changes
  const [key, setKey] = useState<number>(0);
  
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  
  // Set up the chart options
  const [chartOptions, setChartOptions] = useState<Highcharts.Options>({});

  // Create a ref to store the onHover callback
  const onHoverRef = React.useRef(onHover);
  
  // Mobile detection effect
  useEffect(() => {
    const checkMobile = () => {
      setIsMobile(window.innerWidth < 768);
    };
    
    checkMobile();
    window.addEventListener('resize', checkMobile);
    
    return () => window.removeEventListener('resize', checkMobile);
  }, []);
  
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

    // Edge case y-axis max overrides
    let yAxisMax: number | undefined = undefined;
    if (["district_lack_kitch_pct", "district_lack_plumb_pct"].includes(varName)) {
      yAxisMax = 10;
    } else if (["pct_native", "pct_pi"].includes(varName)) {
      yAxisMax = 1;
    }

    // Transform data into Highcharts format with default colors  
    const chartData: DataPoint[] = sortedData.map(item => ({
      y: item.value,
      valueFormatted: item.value_clean,
      district: item.district,
      // Use a default color (not based on highlighted district)
      color: "#CCCCCC",
      id: item.district
    }));

    // 2. Chart options  ----------
    const options: Highcharts.Options = {
      chart: {
        type: "column",
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
        categories: categories,
        title: {
          text: "Council District"
        },
        // Force all labels to show and rotate them for mobile
        labels: {
          style: {
            fontSize: '10px'
          },
          // Force all labels to show, don't skip any
          step: 1
        },
        // Ensure all ticks are shown
        tickInterval: 1,
        // Prevent automatic label optimization that hides labels
        allowDecimals: false
      },
      yAxis: {
        title: {
          text: yAxisTitle,
          style: {
            transition: 'none'
          }
        },
        min: 0,
        max: yAxisMax,
        plotLines: [{
          value: cityAvg,
          color: "#707070",
          dashStyle: "ShortDash",
          width: 2,
          label: {
            text: `City Average: ${cityAvg.toFixed(1)}`,
            align: "right",
            style: {
              color: "#707070", 
            }, 
          },
          zIndex: 25
        }]
      },
      plotOptions: {
        column: {
          dataLabels: {
            enabled: !alwaysDisableDataLabels.includes(varName) && 
                    !(isMobile && mobileDisableDataLabels.includes(varName)),
            allowOverlap: true,  // Enable collision detection
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
        filename: `philly-council-chart-${varName}`
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
        type: "column",
        showInLegend: false,
        data: chartData
      }] as Highcharts.SeriesOptionsType[]
    };
    
    setChartOptions(options);
    
    // Increment key to force a complete re-render of the chart component
    setKey(prevKey => prevKey + 1);
    
  }, [data, isMobile]);

  // If no data or options not yet set, show placeholder
  if (data.length === 0 || Object.keys(chartOptions).length === 0) {
    return (
      <div className="flex items-center justify-center h-[400px] bg-gray-100">
        <p>No chart data available</p>
      </div>
    );
  }

  // 3. Render chart ------- 
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

export default ChartBar;
