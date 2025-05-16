import Image from "next/image";
import logoImage from '../public/logo.png' 

export default function Header() {
  // Constants for reuse
  const UHC_URL = "https://drexel.edu/uhc/";
  const COLORS = {
    lightGray: "#a7a8aa",
    darkBlue: "#07294d"
  };
  
  // Development mode flag - set to false for production
  const isDev = false;
  
  // Debug border classes that only apply when isDev is true
  const debugBorder = isDev ? "border border-black" : "";

  // abstract the logo part of the header to an object here
  const logo = (
    <div className={`col-span-12 md:col-span-4 flex items-center justify-center h-full pt-4 ${debugBorder}`}>
      <a href={UHC_URL} target="_blank" rel="noopener noreferrer">
        <Image
          src={logoImage}
          alt="Drexel UHC Logo"
          width={400}
          height={50}
          className="w-[400px]"
          priority
        />
      </a>
    </div>
  );

  const link = (
    <div className={`col-span-12 md:col-span-4 flex flex-col items-center ${debugBorder}`}>
      <div>
        <span className={`text-[11px] text-[${COLORS.lightGray}]`}>Learn more</span>
        <br />
        <a
          href={UHC_URL}
          className = {`font-extrabold text-[${COLORS.darkBlue}] text-[18px]`}
      
        >
          {UHC_URL}
        </a>
      </div>
    </div>
  );

  return (
    <header className= {`${debugBorder}`}>
      <div className="grid grid-cols-12 items-center pt-1 pb-1">
        {logo}
        <div className="col-span-0 md:col-span-4"></div>
        {link}
      </div>
    </header>
  );
}
