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
}

export const Chart: React.FC<ChartProps> = ({ data }) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  
  // Set up the chart options
  const [chartOptions, setChartOptions] = useState<Highcharts.Options>({});

  // Process data and update chart options when data changes
  useEffect(() => {
    if (data.length === 0) return;
    
    // Sort the data by value in descending order
    // This emulates the R Shiny behavior: arrange(desc(value))
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
      // Transform data into Highcharts format, maintaining the sorted order
      const chartData: DataPoint[] = sortedData.map(item => ({
        y: item.value,
        valueFormatted: item.value_clean,
        district: item.district,
        color: "grey",
        id: item.district
      }));
      
      // Create complete chart options
      const options: Highcharts.Options = {
        chart: {
          type: "column",
          animation: true, // Enable animations for smoother updates
          events: {
            // This ensures proper redraw when data changes
            load: function() {
              this.redraw(true);
            }
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
            text: yAxisTitle
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
              duration: 500 // Faster animations for better responsiveness
            }
          }
        },
        tooltip: {
          headerFormat: '',
          pointFormat: '<span style="color:{point.color}">\u25CF</span> <b>District {point.district}:</b> {point.valueFormatted}<br/>'
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
        highcharts={Highcharts}
        options={chartOptions}
        ref={chartComponentRef}
      />
    </div>
  );
};

export default Chart;