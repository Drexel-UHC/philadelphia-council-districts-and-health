import type { Metadata } from "next";
import { Lato } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/sonner";
import Script from 'next/script';

// Use Lato font with Latin subset
const lato = Lato({
  weight: ['400', '700', '900'],  // Include the weights you need
  subsets: ["latin"],
  display: 'swap',
});

export const metadata: Metadata = {
  title: "Philadelphia Council Districts Health Dashboard",
  description: "Explore health metrics across Philadelphia city council districts",
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
