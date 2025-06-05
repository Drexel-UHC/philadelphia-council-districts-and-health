import { AnchorHeading } from "@/components/ui/anchor-heading";

export default function Intro() {
  return (
    <section id="intro" className="mb-12 pt-10">
      {/* Main heading section */}
      <div className="section mb-8">
        <AnchorHeading 
          id="health-of-philadelphia-city-council-districts" 
          className="text-2xl font-bold mb-4 pb-2 border-b-1 border-gray-300"
        >
          Health of Philadelphia City Council Districts
        </AnchorHeading>
        <p className="text-lg text-gray-700 mb-6">
          This dashboard leverages publicly available data from the US Census Bureau and Open Data Philly to examine important public health indicators for Philadelphia&apos;s 10 City Council Districts. The project aims to offer actionable knowledge that empowers city leaders and communities to address health inequities in their communities.
        </p>
      </div>

      {/* Introduction section */}
      <div className="section mb-8">
        <AnchorHeading
          id="intro"
          className="text-2xl font-bold mb-4 pb-2 border-b-1 border-gray-300"
          as="h2"
        >
        Introduction
        </AnchorHeading>
        <p className="mb-4">
          The health of Philadelphia residents varies drastically across the city – differences that reflect broader disparities in income, opportunity, and access to essential resources. These are not just personal choices made by the city&apos;s residents – they are shaped by federal, state and local laws and policies.
        </p>
        
        <p className="mb-4">
          This project takes a closer look at those conditions by analyzing publicly available data and mapping key health indicators and social determinants of health across all 10 Philadelphia City Council Districts. By doing this, we aim to provide a clearer picture of how politics and geography intersect to shape the health of Philadelphians.
        </p>
        
        <p className="mb-4">
          Our goal is to equip all 17 Philadelphia City Council members and the public with actionable, district-level insights that can guide and empower more equitable policy and investment into our city. By connecting this data to City Council Districts, we hope this project continues to grow and support effective policy solutions that can promote equality and better health for all Philadelphians.
        </p>
      </div>

      {/* Interactive elements section */}
      <div className="section mb-4">
        <p className="mb-2">
          <strong>Find your City Council District: </strong>
          <a 
            href="https://philacitycouncil.maps.arcgis.com/apps/instant/lookup/index.html?appid=9cf0fb3394914cd0a8a7f22ea1395d55"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 hover:underline"
          >
            using this Philadelphia City Council Tool
          </a>
        </p>
      </div>
    </section>
  );
}