"use client";

import React, { useState } from 'react';
import { Button } from "@/components/ui/button"; 
import { Copy, Check } from "lucide-react";
import { toast } from "sonner";
import { MetricMetadata } from '@/components/Dashboard/types/dashboard_types';

interface ShareButtonProps {
  selectedMetric: MetricMetadata | null;
  sectionId?: string;
}

export const ShareButton: React.FC<ShareButtonProps> = ({ 
  selectedMetric,
  sectionId = 'dashboard'
}) => {
  const [copied, setCopied] = useState(false);
  
  // Don't render anything if no metric is selected
  if (!selectedMetric) return null;
  
  // Function to generate and copy a shareable link with the current metric
  const copyShareableLink = () => {
    // Construct the full URL with the current metric
    const url = new URL(window.location.href);
    url.searchParams.set('metric', selectedMetric.var_name);
    url.hash = sectionId;
    
    // Copy to clipboard
    navigator.clipboard.writeText(url.toString());
    
    // Show success message
    toast.success("Link copied to clipboard", {
      description: url.toString(),
      position: "bottom-right",
      duration: 3000,
    });
    
    // Update copied state
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };
  
  return (
    <Button 
      variant="outline" 
      size="sm"
      onClick={copyShareableLink}
      className="flex items-center gap-2  "
    >
      {copied ? (
        <>
          <Check className="h-4 w-4" />
          <span>Copied!</span>
        </>
      ) : (
        <>
          <Copy className="h-4 w-4" />
          <span>Share</span>
        </>
      )}
    </Button>
  );
};

export default ShareButton;
