import type { Metadata } from "next";
import { Lato } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";
import Script from 'next/script';
import StructuredData from "@/components/StructuredData";

// Use Lato font with Latin subset
const lato = Lato({
  weight: ['400', '700', '900'],  // Include the weights you need
  subsets: ["latin"],
  display: 'swap',
});

export const metadata: Metadata = {
  title: "Philadelphia Council District Health Dashboard | Drexel Urban Health Collaborative",
  description: "Interactive dashboard exploring health outcomes and social determinants of health across Philadelphia's 10 City Council Districts. Analyze data on income, education, housing, healthcare access, and demographics to understand health disparities and inform equitable policy decisions.",
  keywords: [
    "Philadelphia", 
    "city council districts", 
    "health disparities", 
    "social determinants of health", 
    "public health data", 
    "health equity", 
    "Philadelphia health outcomes",
    "income inequality",
    "education attainment", 
    "housing conditions",
    "healthcare access",
    "heat vulnerability",
    "Drexel Urban Health Collaborative",
    "policy analysis",
    "community health assessment"
  ],
  authors: [
    { name: "Amber Bolli" },
    { name: "Tamara Rushovich" }, 
    { name: "Ran Li" },
    { name: "Stephanie Hernandez" },
    { name: "Alina Schnake-Mahl" }
  ],
  creator: "Drexel Urban Health Collaborative",
  publisher: "Drexel University Dornsife School of Public Health",
  openGraph: {
    title: "Philadelphia Council District Health Dashboard",
    description: "Interactive data visualization showing health outcomes, demographics, and social determinants of health across Philadelphia's 10 City Council Districts. Empowering equitable policy decisions through actionable district-level health insights.",
    url: "https://drexel-uhc.github.io/philadelphia-council-districts-and-health",
    siteName: "Philadelphia Council District Health Dashboard",
    images: [
      {
        url: "https://drexel-uhc.github.io/philadelphia-council-districts-and-health/logo.png",
        width: 1200,
        height: 630,
        alt: "Philadelphia Council District Health Dashboard - Drexel Urban Health Collaborative",
      },
    ],
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Philadelphia Council District Health Dashboard",
    description: "Explore health disparities across Philadelphia's City Council Districts. Interactive maps and charts showing social determinants of health, demographics, and policy-relevant health data.",
    images: ["https://drexel-uhc.github.io/philadelphia-council-districts-and-health/logo.png"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${lato.className} bg-background transition-colors duration-300`}>
        <div className="flex flex-col min-h-screen">
          {/* Main content container with responsive padding and smooth transitions */}
          <div className="container mx-auto px-8 sm:px-12 lg:px-16 py-4 sm:py-6 lg:py-8 flex-grow transition-all duration-300">
            {children}
          </div>
        </div>
        {/* Add Sonner Toaster component */}
        <Toaster />
        <StructuredData />
        <>
          <Script
            src={`https://www.googletagmanager.com/gtag/js?id=G-CL437HPC84`}
            strategy="afterInteractive"
          />
          <Script id="google-analytics" strategy="afterInteractive">
            {`
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());
              gtag('config', 'G-CL437HPC84');
            `}
          </Script>
        </>

      </body>
    </html>
  );
}
