"use client"

import * as React from "react";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { MetricMetadata } from '@/components/Dashboard/types/dashboard_types';

// Interface for component props
interface SelectMetricProps {
  data?: MetricMetadata[];
  onSelectMetric?: (metricData: MetricMetadata | null) => void;
}

// Fallback data if none is provided
const defaultMetrics = [
  {
    var_label: "Median Age",
    var_def: "Median age of residents",
    source: "ACS 5-year",
    year: "2022",
    var_name: "district_median_age_total",
    ylabs: "Age"
  },
  {
    var_label: "Active Business Licenses",
    var_def: "Count of Licenses",
    source: "Open Data Philly",
    year: "2020-2024",
    var_name: "total_active_licenses_norentals",
    ylabs: "Count of Licenses"
  }
];

export function SelectMetric({ data, onSelectMetric }: SelectMetricProps = {}) {
  // Use provided data or fall back to default metrics
  const metrics = data || defaultMetrics;
  
  // Find the college graduate metric if it exists in the data
  const collegeGradMetric = React.useMemo(() => {
    return metrics.find(metric => 
      metric.var_label.toLowerCase().includes("college graduate") || 
      metric.var_name.toLowerCase().includes("college") || 
      metric.var_name.toLowerCase().includes("grad")
    );
  }, [metrics]);

  // Default value to college graduate metric if found
  const defaultValue = collegeGradMetric?.var_name || "";

  // Handle value change
  const handleValueChange = (value: string) => {
    if (onSelectMetric) {
      const selectedMetric = metrics.find(metric => metric.var_name === value) || null;
      onSelectMetric(selectedMetric);
    }
  };

  // Set default selection on initial load
  React.useEffect(() => {
    if (defaultValue && onSelectMetric) {
      const initialMetric = metrics.find(metric => metric.var_name === defaultValue) || null;
      if (initialMetric) {
        onSelectMetric(initialMetric);
      }
    }
  }, [defaultValue, metrics, onSelectMetric]);

  return (
    <div className="p-4 border rounded bg-red-600">
      <Select defaultValue={defaultValue} onValueChange={handleValueChange}>
        <SelectTrigger className="w-[400px] bg-white">
          <SelectValue placeholder="Select health metric..." />
        </SelectTrigger>
        
        {/* We use a custom SelectContent with position prop for item-aligned behavior */}
        <SelectContent 
          position="item-aligned"
          sideOffset={5}
          className="z-50"
        >
          <SelectGroup>
            {metrics.map((metric) => (
              <SelectItem key={metric.var_name} value={metric.var_name}>
                {metric.var_label}
              </SelectItem>
            ))}
          </SelectGroup>
        </SelectContent>
      </Select>
    </div>
  );
}