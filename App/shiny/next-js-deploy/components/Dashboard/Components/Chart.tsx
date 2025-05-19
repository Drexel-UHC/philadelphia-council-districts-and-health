"use client";

import React, { useRef, useEffect, useState } from 'react';
import * as Highcharts from 'highcharts';
import HighchartsReact from 'highcharts-react-official';

// Enhanced interface for chart data points
interface DataPoint {
  y: number;
  valueFormatted: string;
  district: string;
  color?: string;
  id: string;
}

// Define interfaces for chart props and series
interface ChartSeries {
  name?: string;
  data: number[] | DataPoint[];
  type?: "line" | "column" | "bar" | "area" | "pie" | "scatter" | "spline" | "areaspline" | "arearange" | "columnrange" | "gauge" | "boxplot" | "bubble" | "waterfall" | "polygon" | "funnel" | "pyramid" | "errorbar" | "variwide" | "treemap" | "heatmap" | "packedbubble" | "xrange" | "timeline";
  showInLegend?: boolean;
}

interface ChartProps {
  title?: string;
  subtitle?: string;
  data?: ChartSeries[];
  categories?: string[];
  yAxisTitle?: string;
  cityAverage?: number;
  sourceYear?: string;
  filename?: string;
  varName?: string;
}

export const Chart: React.FC<ChartProps> = ({ 
  title = "Sample Chart",
  subtitle = "",
  data = [{ data: [1, 2, 3, 4, 5], type: "line" }],
  categories = ["A", "B", "C", "D", "E"],
  yAxisTitle = "Value",
  cityAverage,
  sourceYear = "",
  filename = "chart-export",
  varName = ""
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  
  // Check if it's the weighted_hvi variable
  const isHeatVulnerabilityIndex = varName === "weighted_hvi";
  
  // Set up the chart options
  const [chartOptions, setChartOptions] = useState<Highcharts.Options>({});

  // Update chart when props change
  useEffect(() => {
    if (isHeatVulnerabilityIndex) {
      // Simple message chart for HVI
      setChartOptions({
        title: {
          text: title
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
      // Full chart with data
      const chartOptions: Highcharts.Options = {
        chart: {
          type: "column"
        },
        title: {
          text: title
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
          plotLines: cityAverage ? [{
            value: cityAverage,
            color: "#707070",
            dashStyle: "ShortDash",
            width: 2,
            label: {
              text: `City Average: ${cityAverage.toFixed(1)}`,
              align: "right",
              style: {
                color: "#707070"
              }
            },
            zIndex: 5
          }] : []
        },
        plotOptions: {
          column: {
            dataLabels: {
              enabled: true,
              format: "{point.valueFormatted}"
            },
            borderWidth: 0,
            pointPadding: 0.1
          }
        },
        tooltip: {
          headerFormat: '',
          pointFormat: '<span style="color:{point.color}">\u25CF</span> <b>District {point.district}:</b> {point.valueFormatted}<br/>'
        },
        exporting: {
          enabled: true,
          filename: filename
        },
        credits: {
          enabled: true,
          text: sourceYear
        },
        series: data.map(series => ({
          ...series,
          // If data is array of DataPoint, convert to Highcharts point objects
          data: Array.isArray(series.data) && typeof series.data[0] === "object"
            ? (series.data as DataPoint[]).map(point => ({
                y: point.y,
                color: point.color,
                district: point.district,
                valueFormatted: point.valueFormatted,
                id: point.id
              }))
            : series.data
        })) as Highcharts.SeriesOptionsType[]
      };
      
      setChartOptions(chartOptions);
    }
  }, [title, subtitle, data, categories, yAxisTitle, cityAverage, sourceYear, filename, isHeatVulnerabilityIndex, varName]);

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