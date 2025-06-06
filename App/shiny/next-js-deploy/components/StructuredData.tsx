export default function StructuredData() {
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "WebApplication",
    "name": "Philadelphia Council District Health Dashboard",
    "description": "Interactive dashboard exploring health outcomes and social determinants of health across Philadelphia's 10 City Council Districts",
    "url": "https://drexel-uhc.github.io/philadelphia-council-districts-and-health",
    "applicationCategory": "HealthApplication",
    "operatingSystem": "Web Browser",
    "offers": {
      "@type": "Offer",
      "price": "0",
      "priceCurrency": "USD"
    },
    "creator": {
      "@type": "Organization",
      "name": "Drexel Urban Health Collaborative",
      "url": "https://drexel.edu/uhc/",
      "parentOrganization": {
        "@type": "EducationalOrganization",
        "name": "Drexel University Dornsife School of Public Health"
      }
    },
    "about": [
      {
        "@type": "Place",
        "name": "Philadelphia",
        "geo": {
          "@type": "GeoCoordinates",
          "latitude": "39.9526",
          "longitude": "-75.1652"
        }
      },
      {
        "@type": "Thing",
        "name": "Health Disparities",
        "description": "Differences in health outcomes across geographic and demographic groups"
      },
      {
        "@type": "Thing", 
        "name": "Social Determinants of Health",
        "description": "Conditions in environments where people live, learn, work, and play that affect health outcomes"
      }
    ],
    "audience": {
      "@type": "Audience",
      "audienceType": ["City Council Members", "Public Health Officials", "Researchers", "Community Members", "Policy Makers"]
    },
    "keywords": ["Philadelphia health data", "city council districts", "health disparities", "social determinants", "public health", "health equity"],
    "inLanguage": "en-US",
    "isAccessibleForFree": true
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(structuredData) }}
    />
  );
}
