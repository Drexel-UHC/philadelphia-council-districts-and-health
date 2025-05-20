"use client";

import * as React from "react";
import { Check, ChevronsUpDown } from "lucide-react";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { MetricMetadata } from '@/components/Dashboard/types/dashboard_types'

// Interface for component props
interface SelectMetricProps {
  data: MetricMetadata[];
  onSelectMetric: (metric: MetricMetadata | null) => void;
  selectedMetric?: MetricMetadata | null;
}

export const SelectMetric: React.FC<SelectMetricProps> = ({ 
  data,
  onSelectMetric,
  selectedMetric
}) => {
  // State for popover open/close
  const [open, setOpen] = React.useState(false);
  
  // Set value based on selectedMetric from props (used for URL syncing)
  const [value, setValue] = React.useState(selectedMetric?.var_name || "");
  
  // Update value when selectedMetric changes (e.g., from URL params)
  React.useEffect(() => {
    if (selectedMetric) {
      setValue(selectedMetric.var_name);
    } else {
      setValue("");
    }
  }, [selectedMetric]);

  // Handle selection change
  const handleSelect = (selectedValue: string) => {
    setValue(selectedValue);
    setOpen(false);
    
    // Find the selected metric in the data
    const selected = data.find(metric => metric.var_name === selectedValue);
    
    // Call the parent's callback with the selected metric
    if (selected) {
      onSelectMetric(selected);
    }
  };

  return (
    <div className="space-y-2">
      <label htmlFor="metric-select" className="text-sm font-medium block">
        Select a Health Metric:
      </label>
      <Popover open={open} onOpenChange={setOpen}>
        <PopoverTrigger asChild>
          <Button
            id="metric-select"
            variant="outline"
            role="combobox"
            aria-expanded={open}
            className="w-full justify-between bg-white border-gray-200 text-left font-normal"
          >
            {value
              ? data.find((metric) => metric.var_name === value)?.var_label
              : "Select health metric..."}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </Button>
        </PopoverTrigger>
        <PopoverContent
          className="w-full max-w-[400px]"
          align="start"
          sideOffset={0}
          alignOffset={0}
          side="bottom"
          avoidCollisions={true}
        >
          <Command>
            <CommandInput placeholder="Search health metrics..." />
            <CommandList>
              <CommandEmpty>No metrics found.</CommandEmpty>
              <CommandGroup>
                {[...data]
                  .sort((a, b) => a.var_label.localeCompare(b.var_label))
                  .map((metric) => (
                    <CommandItem
                      key={metric.var_name}
                      value={metric.var_label} // Use var_label for searching/filtering
                      onSelect={() => handleSelect(metric.var_name)}
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
};

export default SelectMetric;