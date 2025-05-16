"use client";

import React, { useRef, useEffect, useState } from 'react';
import Highcharts from "highcharts/esm/highcharts.js";
import HighchartsReact from 'highcharts-react-official';
import "highcharts/esm/modules/map.js";

// Define interfaces for map props
interface MapProps {
  title?: string;
}

// Simplified mock GeoJSON data for Philadelphia districts
const phillyDistrictsGeoJSON = {
  "type": "FeatureCollection",
  "features": [
    // District 1
    {
      "type": "Feature",
      "properties": {
        "district": "1"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.18, 39.92],
          [-75.14, 39.92],
          [-75.14, 39.95],
          [-75.18, 39.95],
          [-75.18, 39.92]
        ]]
      }
    },
    // District 2
    {
      "type": "Feature",
      "properties": {
        "district": "2"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.22, 39.92],
          [-75.18, 39.92],
          [-75.18, 39.95],
          [-75.22, 39.95],
          [-75.22, 39.92]
        ]]
      }
    },
    // District 3
    {
      "type": "Feature",
      "properties": {
        "district": "3"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.22, 39.95],
          [-75.18, 39.95],
          [-75.18, 39.98],
          [-75.22, 39.98],
          [-75.22, 39.95]
        ]]
      }
    },
    // District 4
    {
      "type": "Feature",
      "properties": {
        "district": "4"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.18, 39.95],
          [-75.14, 39.95],
          [-75.14, 39.98],
          [-75.18, 39.98],
          [-75.18, 39.95]
        ]]
      }
    },
    // District 5
    {
      "type": "Feature",
      "properties": {
        "district": "5"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.14, 39.95],
          [-75.10, 39.95],
          [-75.10, 39.98],
          [-75.14, 39.98],
          [-75.14, 39.95]
        ]]
      }
    },
    // District 6
    {
      "type": "Feature",
      "properties": {
        "district": "6"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.14, 39.92],
          [-75.10, 39.92],
          [-75.10, 39.95],
          [-75.14, 39.95],
          [-75.14, 39.92]
        ]]
      }
    },
    // District 7
    {
      "type": "Feature",
      "properties": {
        "district": "7"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.10, 39.92],
          [-75.06, 39.92],
          [-75.06, 39.95],
          [-75.10, 39.95],
          [-75.10, 39.92]
        ]]
      }
    },
    // District 8
    {
      "type": "Feature",
      "properties": {
        "district": "8"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.10, 39.95],
          [-75.06, 39.95],
          [-75.06, 39.98],
          [-75.10, 39.98],
          [-75.10, 39.95]
        ]]
      }
    },
    // District 9
    {
      "type": "Feature",
      "properties": {
        "district": "9"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.22, 39.98],
          [-75.18, 39.98],
          [-75.18, 40.01],
          [-75.22, 40.01],
          [-75.22, 39.98]
        ]]
      }
    },
    // District 10
    {
      "type": "Feature",
      "properties": {
        "district": "10"
      },
      "geometry": {
        "type": "Polygon",
        "coordinates": [[
          [-75.18, 39.98],
          [-75.14, 39.98],
          [-75.14, 40.01],
          [-75.18, 40.01],
          [-75.18, 39.98]
        ]]
      }
    }
  ]
};

// Generate random data for the 10 districts
const generateRandomData = () => {
  const data = [];
  for (let i = 1; i <= 10; i++) {
    data.push({
      district: i.toString(),
      value: Math.round(Math.random() * 100 * 10) / 10,
      value_clean: `${Math.round(Math.random() * 100 * 10) / 10}%`
    });
  }
  return data;
};

const mockData = generateRandomData();

export const Map: React.FC<MapProps> = ({ 
  title = "Philadelphia Districts Health Metrics"
}) => {
  // Create a reference to the chart component
  const chartComponentRef = useRef<HighchartsReact.RefObject>(null);
  const [mapLoaded, setMapLoaded] = useState(false);
  
  // Set up the chart options
  const [mapOptions, setMapOptions] = useState<Highcharts.Options>({
    chart: {
      map: phillyDistrictsGeoJSON,
      height: 400
    },
    title: {
      text: title
    },
    subtitle: {
      text: 'Health metrics across Philadelphia council districts'
    },
    credits: {
      enabled: true,
      text: 'Source: Simulated data (2025)'
    },
    mapNavigation: {
      enabled: true,
      buttonOptions: {
        verticalAlign: 'bottom'
      }
    },
    colorAxis: {
      min: 0,
      max: 100,
      stops: [
        [0, '#EFEFFF'],
        [0.5, '#4444BB'],
        [1, '#000066']
      ]
    },
    legend: {
      title: {
        text: 'Health Index (%)'
      },
      valueDecimals: 1,
      valueSuffix: '%'
    },
    series: [{
      type: 'map',
      name: 'Health Index',
      data: mockData.map(d => ({
        district: d.district,
        value: d.value,
        value_clean: d.value_clean
      })),
      joinBy: ['district', 'district'],
      states: {
        hover: {
          color: '#a4edba'
        }
      },
      dataLabels: {
        enabled: true,
        format: '{point.district}'
      }//,
      // tooltip: {
      //   useHTML: true,
      //   headerFormat: '',
      //   pointFormat: '<span style="font-size:13px"><b>District {point.district}</b>: {point.value_clean}</span>'
      // }
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
      <Map title="Philadelphia Health Index by District" />
    </div>
  );
};

export default Map;