"use client"

import * as React from "react";
import * as Popover from "@radix-ui/react-popover";
import { Check, ChevronsUpDown, Search } from "lucide-react";
import { cn } from "@/lib/utils";

// Command components built directly with Radix UI
const Command = ({
  className,
  children,
  ...props
}: {
  className?: string;
  children: React.ReactNode;
  // Replace [key: string]: any with a more specific type
  [key: string]: unknown;
}) => (
  <div 
    className={cn(
      "flex flex-col overflow-hidden rounded-md bg-white text-gray-950", 
      className
    )}
    {...props}
  >
    {children}
  </div>
);

const CommandInput: React.FC<React.InputHTMLAttributes<HTMLInputElement> & { className?: string }> = ({ className, ...props }) => (
  <div className="flex items-center border-b px-3">
    <Search className="mr-2 h-4 w-4 shrink-0 opacity-50" />
    <input
      className={cn(
        "flex h-10 w-full rounded-md bg-transparent py-3 text-sm outline-none placeholder:text-gray-500 disabled:cursor-not-allowed disabled:opacity-50",
        className
      )}
      {...props}
    />
  </div>
);

const CommandList: React.FC<React.HTMLAttributes<HTMLDivElement> & { className?: string }> = ({ className, children, ...props }) => (
  <div
    className={cn("max-h-[300px] overflow-y-auto", className)}
    {...props}
  >
    {children}
  </div>
);

const CommandEmpty: React.FC<React.HTMLAttributes<HTMLDivElement> & { className?: string }> = ({ className, ...props }) => (
  <div
    className={cn("py-6 text-center text-sm text-gray-500", className)}
    {...props}
  />
);

const CommandGroup: React.FC<React.HTMLAttributes<HTMLDivElement> & { className?: string }> = ({ 
  className, 
  children, 
  ...props 
}) => (
  <div
    className={cn(
      "overflow-hidden p-1",
      className
    )}
    {...props}
  >
    {children}
  </div>
);

// For CommandItem component
interface CommandItemProps extends React.HTMLAttributes<HTMLDivElement> {
  className?: string;
  onSelect: () => void;
  children: React.ReactNode;
}

const CommandItem: React.FC<CommandItemProps> = ({ 
  className, 
  onSelect, 
  children, 
  ...props 
}) => (
  <div
    className={cn(
      "relative flex cursor-pointer select-none items-center rounded-sm px-2 py-1.5 text-sm outline-none hover:bg-gray-100 data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
      className
    )}
    onClick={onSelect}
    {...props}
  >
    {children}
  </div>
);

// Interface for metadata format
interface MetricMetadata {
  var_label: string;
  var_def: string;
  source: string;
  year: string;
  var_name: string;
  ylabs: string;
}

interface SelectMetricProps {
  data?: MetricMetadata[];
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

export function SelectMetric({ data }: SelectMetricProps = {}) {
  const [open, setOpen] = React.useState(false);
  const [value, setValue] = React.useState("");
  const [searchQuery, setSearchQuery] = React.useState("");
  const contentRef = React.useRef<HTMLDivElement>(null);
  const triggerRef = React.useRef<HTMLButtonElement>(null);
  const listId = React.useId();

  // Use provided data or fall back to default metrics
  const metrics = data || defaultMetrics;

  const filteredMetrics = React.useMemo(() => {
    if (!searchQuery) return metrics;
    
    return metrics.filter((metric) =>
      metric.var_label.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [searchQuery, metrics]);

  return (
    <div className="relative p-4">
      <Popover.Root open={open} onOpenChange={setOpen}>
        <Popover.Trigger asChild>
          <button 
            ref={triggerRef}
            className="flex w-[300px] justify-between items-center px-4 py-2 border rounded bg-white"
            aria-expanded={open}
            role="combobox"
            aria-controls={listId}
            aria-haspopup="listbox"
          >
            {value 
              ? metrics.find((metric) => metric.var_name === value)?.var_label
              : "Select health metric..."}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </button>
        </Popover.Trigger>
        
        <Popover.Portal forceMount>
          <Popover.Content 
            ref={contentRef}
            className="bg-white rounded shadow-md w-[300px] p-0 transition-none" 
            sideOffset={5}
            side="bottom"
            align="start"
            style={{ 
              animation: 'none',
              transformOrigin: 'var(--radix-popover-content-transform-origin)',
              opacity: open ? 1 : 0,
              transition: 'opacity 150ms ease-out'
            }}
          >
            <Command>
              <CommandInput 
                placeholder="Search health metrics..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
              <CommandList id={listId}>
                {filteredMetrics.length === 0 && (
                  <CommandEmpty>No metrics found.</CommandEmpty>
                )}
                <CommandGroup>
                  {filteredMetrics.map((metric) => (
                    <CommandItem
                      key={metric.var_name}
                      onSelect={() => {
                        setValue(metric.var_name === value ? "" : metric.var_name);
                        setOpen(false);
                        setSearchQuery("");
                      }}
                    >
                      <Check
                        className={cn(
                          "mr-2 h-4 w-4",
                          value === metric.var_name ? "opacity-100" : "opacity-0"
                        )}
                      />
                      <div>
                        <div className="font-medium">{metric.var_label}</div>
                        <div className="text-xs text-gray-500">{metric.source} ({metric.year})</div>
                      </div>
                    </CommandItem>
                  ))}
                </CommandGroup>
              </CommandList>
            </Command>
          </Popover.Content>
        </Popover.Portal>
      </Popover.Root>
    </div>
  );
}