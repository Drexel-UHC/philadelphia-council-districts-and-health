import type { Metadata } from "next";
import { Lato } from "next/font/google";  // Changed from Inter to Lato
import "./globals.css";

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
          <div className="container mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6 lg:py-8 flex-grow transition-all duration-300">
            {children}
          </div>
        </div>
      </body>
    </html>
  );
}
