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
  
  // Add function to get correct base URL for GitHub Pages
  const getBaseUrl = () => {
    // Check if we're running in a browser environment
    if (typeof window === 'undefined') return '';
    
    // For GitHub Pages, we need to include the repository name in the path
    // Look for "philadelphia-council-districts-and-health" in the current location
    const url = window.location.href;
    const repoName = '/philadelphia-council-districts-and-health/';
    
    if (url.includes('github.io') && url.includes(repoName)) {
      // We're on GitHub Pages, return the full base path
      const ghPagesBase = url.substring(0, url.indexOf(repoName) + repoName.length);
      return ghPagesBase;
    }
    
    // Default for local development
    return window.location.origin + window.location.pathname;
  };
  
  // Don't render anything if no metric is selected
  if (!selectedMetric) return null;
  
  // Function to generate and copy a shareable link with the current metric
  const copyShareableLink = () => {
    // Get the proper base URL (handle GitHub Pages)
    const baseUrl = getBaseUrl();
    
    // Construct the URL properly with base URL and query parameters
    const fullUrl = `${baseUrl}?metric=${selectedMetric.var_name}#${sectionId}`;
    
    // Copy to clipboard
    navigator.clipboard.writeText(fullUrl);
    
    // Show success message
    toast.success("Link copied to clipboard", {
      description: fullUrl,
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
      className="flex items-center gap-2"
    >
      {copied ? (
        <>
          <Check className="h-4 w-4" />
          <span>Copied!</span>
        </>
      ) : (
        <>
          <Copy className="h-4 w-4" />
          <span>Share Link</span>
        </>
      )}
    </Button>
  );
};

export default ShareButton;
