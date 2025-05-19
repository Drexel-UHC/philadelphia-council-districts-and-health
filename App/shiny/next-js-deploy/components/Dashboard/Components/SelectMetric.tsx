"use client"

import * as React from "react"
import { Check, ChevronsUpDown } from "lucide-react"
import { cn } from "@/lib/utils"
import { Button } from "@/components/ui/button"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { MetricMetadata } from '@/components/Dashboard/types/dashboard_types'
import "./styles.css";
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

  const [open, setOpen] = React.useState(false)
  const [value, setValue] = React.useState(defaultValue)

  // Handle value change
  React.useEffect(() => {
    if (onSelectMetric && value) {
      const selectedMetric = metrics.find(metric => metric.var_name === value) || null;
      onSelectMetric(selectedMetric);
    }
  }, [value, metrics, onSelectMetric]);

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
    <div className="p-4 ">
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-[400px] justify-between bg-white border-gray-200 text-left font-normal"
          >
            {value
              ? metrics.find((metric) => metric.var_name === value)?.var_label
              : "Select health metric..."}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent
          className="PopoverContent w-[400px] "
          align="start"
          sideOffset={0}
          alignOffset={0}
          side="bottom"  // Add this line to ensure proper positioning behavior
          avoidCollisions={true}
        >
          <Command>
            <CommandInput placeholder="Search health metrics..." />
            <CommandList>
              <CommandEmpty>No metrics found.</CommandEmpty>
              <CommandGroup>
                {metrics.map((metric) => (
                  <CommandItem
                    key={metric.var_name}
                    value={metric.var_name}
                    onSelect={(currentValue) => {
                      setValue(currentValue === value ? "" : currentValue)
                      setOpen(false)
                    }}
                  >
                    <Check
                      className={cn(
                        "mr-2 h-4 w-4",
                        value === metric.var_name ? "opacity-100" : "opacity-0"
                      )}
                    />
                    {metric.var_label}
                  </CommandItem>
                ))}
              </CommandGroup>
            </CommandList>
          </Command>
        </PopoverContent>
      </Popover>
    </div>
  );
}