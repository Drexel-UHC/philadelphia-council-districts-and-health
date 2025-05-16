"use client";

import React, { useRef, useEffect, useState } from 'react';
import Highcharts from "highcharts/esm/highcharts.js";
import HighchartsReact from 'highcharts-react-official';
import "highcharts/esm/modules/map.js";

// Define interfaces for map props
interface MapProps {
  title?: string;
}

export const Map: React.FC<MapProps> = ({ 
  title = "Philadelphia Districts"
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  const [mapLoaded, setMapLoaded] = useState(false);
  
  // Set up the chart options
  const [mapOptions, setMapOptions] = useState<Highcharts.Options>({
    chart: {
      type: 'map',
      height: 400
    },
    title: {
      text: title
    },
    credits: {
      enabled: false
    },
    series: [{
      type: 'map',
      name: 'District',
      nullColor: '#DADADA',
      dataLabels: {
        enabled: true
      },
      data: []
    }] as Highcharts.SeriesOptionsType[]
  });

  useEffect(() => {
    // Simply mark as loaded since we're importing the map module directly
    setMapLoaded(true);
  }, []);

  // Show loading indicator until map is ready
  if (!mapLoaded) {
    return (
      <div className="flex items-center justify-center h-[400px] bg-gray-100">
        <p>Loading map...</p>
      </div>
    );
  }

  return (
    <div className="map-container">
      <HighchartsReact
        highcharts={Highcharts}
        options={mapOptions}
        constructorType={"mapChart"}
        ref={chartComponentRef}
      />
    </div>
  );
};

// Example map component with minimal configuration
export const MapExample: React.FC = () => {
  return (
    <div className="p-4 bg-white rounded-lg shadow-md">
      <Map title="Philadelphia Council Districts" />
    </div>
  );
};

export default Map;