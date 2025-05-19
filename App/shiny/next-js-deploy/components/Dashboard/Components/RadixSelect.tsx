"use client"

import * as React from "react";
import * as Select from "@radix-ui/react-select";
import { CheckIcon, ChevronDownIcon, ChevronUpIcon } from "@radix-ui/react-icons";
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
      <Select.Root defaultValue={defaultValue} onValueChange={handleValueChange}>
        <Select.Trigger className="flex items-center justify-between rounded bg-white px-4 py-2 text-sm border border-gray-300 w-[400px] h-10">
          <Select.Value placeholder="Select health metric..." />
          <Select.Icon>
            <ChevronDownIcon />
          </Select.Icon>
        </Select.Trigger>
        
        <Select.Portal>
          <Select.Content 
            className="overflow-hidden bg-white rounded-md shadow-lg z-50"
            position="item-aligned"
            sideOffset={5}
          >
            {/* <Select.ScrollUpButton className="flex items-center justify-center h-6 bg-white text-gray-700 cursor-default">
              <ChevronUpIcon />
            </Select.ScrollUpButton> */}
            
            <Select.Viewport>
              {metrics.map((metric) => (
                <SelectItem key={metric.var_name} value={metric.var_name}>
                  {metric.var_label}
                </SelectItem>
              ))}
            </Select.Viewport>
            
            {/* <Select.ScrollDownButton className="flex items-center justify-center h-6 bg-white text-gray-700 cursor-default">
              <ChevronDownIcon />
            </Select.ScrollDownButton> */}
          </Select.Content>
        </Select.Portal>
      </Select.Root>
    </div>
  );
}

// Helper component for select items
const SelectItem = React.forwardRef<HTMLDivElement, Select.SelectItemProps>(
  ({ children, ...props }, forwardedRef) => {
    return (
      <Select.Item
        className="relative flex items-center px-8 py-2 text-sm rounded-sm hover:bg-gray-100 focus:bg-gray-100 focus:outline-none cursor-pointer"
        {...props}
        ref={forwardedRef}
      >
        <Select.ItemText>{children}</Select.ItemText>
        <Select.ItemIndicator className="absolute left-2 inline-flex items-center">
          <CheckIcon />
        </Select.ItemIndicator>
      </Select.Item>
    );
  }
);

SelectItem.displayName = 'SelectItem';