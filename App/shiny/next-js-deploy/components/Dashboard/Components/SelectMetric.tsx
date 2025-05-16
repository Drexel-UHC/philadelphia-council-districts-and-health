"use client"

import * as React from "react";
import * as Popover from "@radix-ui/react-popover";
import { Check, ChevronsUpDown, Search } from "lucide-react";
import { cn } from "@/lib/utils";

// Command components built directly with Radix UI
const Command = ({ className, children, ...props }) => (
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

const CommandInput = ({ className, ...props }) => (
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

const CommandList = ({ className, children, ...props }) => (
  <div
    className={cn("max-h-[300px] overflow-y-auto", className)}
    {...props}
  >
    {children}
  </div>
);

const CommandEmpty = ({ className, ...props }) => (
  <div
    className={cn("py-6 text-center text-sm text-gray-500", className)}
    {...props}
  />
);

const CommandGroup = ({ className, children, ...props }) => (
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

const CommandItem = ({ className, onSelect, children, ...props }) => (
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

const frameworks = [
  { value: "next.js", label: "Next.js" },
  { value: "sveltekit", label: "SvelteKit" },
  { value: "nuxt.js", label: "Nuxt.js" },
  { value: "remix", label: "Remix" },
  { value: "astro", label: "Astro" }
];

export function SelectMetric() {
  const [open, setOpen] = React.useState(false);
  const [value, setValue] = React.useState("");
  const [searchQuery, setSearchQuery] = React.useState("");
  const contentRef = React.useRef<HTMLDivElement>(null);
  const triggerRef = React.useRef<HTMLButtonElement>(null);

  const filteredFrameworks = React.useMemo(() => {
    if (!searchQuery) return frameworks;
    
    return frameworks.filter((framework) =>
      framework.label.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [searchQuery]);

  return (
    <div className="relative p-4">
      <h3 className="mb-2">Radix UI Combobox</h3>
      
      <Popover.Root open={open} onOpenChange={setOpen}>
        <Popover.Trigger asChild>
          <button 
            ref={triggerRef}
            className="flex w-[200px] justify-between items-center px-4 py-2 border rounded bg-white"
            aria-expanded={open}
            role="combobox"
          >
            {value 
              ? frameworks.find((framework) => framework.value === value)?.label
              : "Select framework..."}
            <ChevronsUpDown className="ml-2 h-4 w-4 shrink-0 opacity-50" />
          </button>
        </Popover.Trigger>
        
        <Popover.Portal forceMount>
          <Popover.Content 
            ref={contentRef}
            className="bg-white rounded shadow-md w-[200px] p-0 transition-none" 
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
                placeholder="Search framework..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
              />
              <CommandList>
                {filteredFrameworks.length === 0 && (
                  <CommandEmpty>No framework found.</CommandEmpty>
                )}
                <CommandGroup>
                  {filteredFrameworks.map((framework) => (
                    <CommandItem
                      key={framework.value}
                      onSelect={() => {
                        setValue(framework.value === value ? "" : framework.value);
                        setOpen(false);
                        setSearchQuery("");
                      }}
                    >
                      <Check
                        className={cn(
                          "mr-2 h-4 w-4",
                          value === framework.value ? "opacity-100" : "opacity-0"
                        )}
                      />
                      {framework.label}
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