"use client"

import * as React from "react";
import * as Popover from "@radix-ui/react-popover";

export function RadixPopoverDemo() {
  const [open, setOpen] = React.useState(false);
  const contentRef = React.useRef<HTMLDivElement>(null);
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
    <div className="relative ">
      <Popover.Root open={open} onOpenChange={setOpen}>
        <Popover.Trigger asChild>
          <button className="px-4 py-2 border rounded bg-white">
            Click me
          </button>
        </Popover.Trigger>
        <Popover.Portal>
          <Popover.Content 
            ref={contentRef}
            className="bg-white p-4 rounded shadow-md w-64"
            sideOffset={5}
            style={{
              transformOrigin: 'var(--radix-popover-content-transform-origin)'
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