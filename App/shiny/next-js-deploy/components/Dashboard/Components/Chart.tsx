"use client";

import React, { useRef, useEffect, useState } from 'react';
import * as Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

// Define interfaces for chart props and series
interface ChartSeries {
  name?: string;
  data: number[];
  type?: "line" | "column" | "bar" | "area" | "pie" | "scatter" | "spline" | "areaspline" | "arearange" | "columnrange" | "gauge" | "boxplot" | "bubble" | "waterfall" | "polygon" | "funnel" | "pyramid" | "errorbar" | "variwide" | "treemap" | "heatmap" | "packedbubble" | "xrange" | "timeline";
}

interface ChartProps {
  title?: string;
  data?: ChartSeries[];
  categories?: string[];
}

export const Chart: React.FC<ChartProps> = ({ 
  title = "Sample Chart",
  data = [{ data: [1, 2, 3, 4, 5], type: "line" }],
  categories = ["A", "B", "C", "D", "E"] 
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  
  // Set up the chart options
  const [chartOptions, setChartOptions] = useState<Highcharts.Options>({
    title: {
      text: title
    },
    xAxis: {
      categories: categories
    },
    series: data.map(series => ({
      type: series.type || "line",
      name: series.name,
      data: series.data
    })) as Highcharts.SeriesOptionsType[],
    credits: {
      enabled: false
    }
  });

  // Update chart when props change
  useEffect(() => {
    setChartOptions({
      title: {
        text: title
      },
      xAxis: {
        categories: categories
      },
      series: data.map(series => ({
        type: series.type || "line",
        name: series.name,
        data: series.data
      })) as Highcharts.SeriesOptionsType[],
      credits: {
        enabled: false
      }
    });
  }, [title, data, categories]);

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

// Example usage component - you can use this to test the Chart component
export const ChartExample: React.FC = () => {
  const sampleData: ChartSeries[] = [
    {
      name: 'District Health Metrics',
      data: [29.9, 71.5, 106.4, 129.2, 144.0, 176.0, 135.6, 148.5, 216.4, 194.1],
      type: "line"
    }
  ];
  
  const categories = ["District 1", "District 2", "District 3", "District 4", "District 5", 
                       "District 6", "District 7", "District 8", "District 9", "District 10"];

  return (
    <div className="p-4 bg-white rounded-lg shadow-md">
      <Chart 
        title="Philadelphia Council Districts Health Metrics" 
        data={sampleData} 
        categories={categories} 
      />
    </div>
  );
};

// Default export is the basic Chart component
export default Chart;