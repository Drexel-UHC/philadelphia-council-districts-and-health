// import Image from "next/image";
// import Link from "next/link";
import Header from "@/components/Header";
import Intro from "@/components/Intro";
import DashboardLayout from "@/components/Dashboard/DashboardLayout";
import Outro from "@/components/Outro";
import Footer from "@/components/Footer";
import CoverPhoto from "@/components/CoverPhoto";

export default function Home() {
  return (
    <>
      <Header />
      <CoverPhoto />
      <Intro />
      <DashboardLayout />
      <Outro />
      <Footer />
      {/* 
      <main className="flex-1 container mx-auto">
        
       
      </main>

       */}
    </>
  );
}
