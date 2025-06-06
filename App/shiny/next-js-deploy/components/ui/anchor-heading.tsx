"use client";

import React from 'react';
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import { LinkIcon } from "lucide-react";
import { toast } from "sonner";

interface AnchorHeadingProps {
  id: string;
  children: React.ReactNode;
  className?: string;
  as?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
  level?: 'h1' | 'h2' | 'h3' | 'h4' | 'h5' | 'h6';
}

export const AnchorHeading = ({ 
  id, 
  children, 
  className,
  as,
  level
}: AnchorHeadingProps) => {
  // Use level if provided, otherwise fall back to as, then default to h1
  const Component = level || as || 'h1';

  // Generate the slug from the ID
  const slug = id.toLowerCase().replace(/\s+/g, '-');

  // Function to copy the URL with the anchor to clipboard
  const copyAnchorLink = () => {
    const url = `${window.location.href.split('#')[0]}#${slug}`;
    navigator.clipboard.writeText(url);
    
    // Show toast notification
    toast("Link copied to clipboard", {
      description: url,
      position: "bottom-right",
      duration: 3000,
    });
  };

  return (
    <Component 
      id={slug}
      className={cn(
        "group relative flex items-center gap-2", 
        className
      )}
    >
      {children}
      <Button
        variant="ghost"
        size="icon"
        className="h-6 w-6 opacity-0 group-hover:opacity-100 transition-opacity duration-200 cursor-pointer"
        onClick={(e) => {
          e.preventDefault();
          window.history.pushState({}, '', `#${slug}`);
          copyAnchorLink();
        }}
        aria-label={`Copy link to ${typeof children === 'string' ? children : 'this section'}`}
      >
        <LinkIcon className="h-4 w-4" />
      </Button>
    </Component>
  );
};

export default AnchorHeading;
