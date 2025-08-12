"use client";

import React from 'react';
import { MetricData } from '@/components/Dashboard/types/dashboard_types';

// Define interfaces for chart props
interface ChartDotProps {
  data: MetricData[];
  onHover?: (district: string | null) => void;
  registerHighlightFunction?: (highlightFn: (district: string | null) => void) => void;
}

export const ChartDot: React.FC<ChartDotProps> = ({ 
  data, 
  onHover,
  registerHighlightFunction
}) => {
  // For now, just show a placeholder for dot plot charts
  // This will be implemented later with actual dot plot logic
  
  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[400px] bg-gray-100">
        <p>No chart data available</p>
      </div>
    );
  }

  // Extract common properties from first data item for display
  const firstItem = data[0];
  const varLabel = firstItem.var_label;
  const subtitle = firstItem.var_def;
  const sourceYear = firstItem.source_year;

  return (
    <div className="flex flex-col items-center justify-center h-[400px] bg-gray-50 border-2 border-dashed border-gray-300 rounded-lg">
      <div className="text-center max-w-md px-4">
        <h3 className="text-xl font-bold mb-2">{varLabel}</h3>
        <p className="text-sm text-gray-600 mb-4">{subtitle}</p>
        <p className="text-lg text-gray-700 mb-2">
          The Heat Vulnerability Index (HVI) is a composite measure that summarizes key indicators 
          associated with negative health outcomes due to extreme heat exposure. The HVI scale ranges 
          from negative to positive values, which represent areas of very low to very high vulnerability.
        </p>
        <p className="text-sm text-gray-600">
          Because of this range, a choropleth map, rather than a bar graph, is best suited to 
          effectively convey patterns of heat-related health risk across geographic areas.
        </p>
        <div className="mt-4 text-xs text-gray-500">
          Source: {sourceYear}
        </div>
      </div>
    </div>
  );
};

export default ChartDot;
