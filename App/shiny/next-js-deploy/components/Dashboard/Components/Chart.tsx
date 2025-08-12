"use client";

import React from 'react';
import { MetricData } from '@/components/Dashboard/types/dashboard_types';
import ChartBar from './ChartBar';
import ChartDot from './ChartDot';

// Define interfaces for chart props
interface ChartProps {
  data: MetricData[];
  onHover?: (district: string | null) => void;
  registerHighlightFunction?: (highlightFn: (district: string | null) => void) => void;
}

export const Chart: React.FC<ChartProps> = ({ 
  data, 
  onHover,
  registerHighlightFunction
}) => {
  // Early return if no data
  if (data.length === 0) {
    return (
      <div className="flex items-center justify-center h-[400px] bg-gray-100">
        <p>No chart data available</p>
      </div>
    );
  }

  // Determine chart type based on variable name
  const varName = data[0]?.var_name;

  // Route to appropriate chart component
  if (varName === "weighted_hvi") {
    return (
      <ChartDot 
        data={data}
        onHover={onHover}
        registerHighlightFunction={registerHighlightFunction}
      />
    );
  }

  // Default to bar chart for all other variables
  return (
    <ChartBar 
      data={data}
      onHover={onHover}
      registerHighlightFunction={registerHighlightFunction}
    />
  );
};

export default Chart;