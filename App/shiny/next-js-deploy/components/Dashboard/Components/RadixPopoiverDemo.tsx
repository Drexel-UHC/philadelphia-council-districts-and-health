"use client"

import * as React from "react";
import * as Popover from "@radix-ui/react-popover";

export function RadixPopoverDemo() {
  const [open, setOpen] = React.useState(false);
  const contentRef = React.useRef<HTMLDivElement>(null);
  const triggerRef = React.useRef<HTMLButtonElement>(null);
  const [origin, setOrigin] = React.useState('');

  // Debug the transform origin
  React.useEffect(() => {
    if (open && contentRef.current) {
      const transformOrigin = getComputedStyle(contentRef.current)
        .getPropertyValue('--radix-popover-content-transform-origin');
      setOrigin(transformOrigin);
    }
  }, [open]);

  return (
    <div className="relative p-4">
      
      <Popover.Root open={open} onOpenChange={setOpen}>
        <Popover.Trigger asChild>
          <button 
            ref={triggerRef}
            className="px-4 py-2 border rounded bg-white"
          >
           Radix UI Popover Test 2
          </button>
        </Popover.Trigger>
        {/* Use forceMount to ensure the content is always rendered */}
        <Popover.Portal forceMount>
          <Popover.Content 
            ref={contentRef}
            className="bg-white p-4 rounded shadow-md w-64 transition-none" 
            sideOffset={5}
            side="bottom"
            align="start"
            style={{ 
              // Disable transition
              animation: 'none',
              // Force transform origin
              transformOrigin: 'var(--radix-popover-content-transform-origin)',
              // Start with opacity 0 and fade in
              opacity: open ? 1 : 0,
              // Instant transition for position but fade in for opacity
              transition: 'opacity 150ms ease-out'
            }}
          >
            <div>This is popover content</div>
            
            {/* Debug info */}
            <div className="mt-4 p-2 bg-gray-100 text-xs">
              <div>Transform origin: {origin}</div>
            </div>
          </Popover.Content>
        </Popover.Portal>
      </Popover.Root>
    </div>
  );
}