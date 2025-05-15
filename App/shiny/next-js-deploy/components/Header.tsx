import Image from "next/image";

export default function Header() {
  // Constants for reuse
  const UHC_URL = "https://drexel.edu/uhc/";
  const COLORS = {
    lightGray: "#a7a8aa",
    darkBlue: "#07294d"
  };

  // abstract the logo part of the header to an object here
  const logo = (
    <div className="col-span-12 md:col-span-4 flex items-center justify-center h-full pt-4">
      <a href={UHC_URL} target="_blank" rel="noopener noreferrer">
        <Image
          src="/logo.png"
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
    <div className="col-span-12 md:col-span-4 flex flex-col items-center">
      <div>
        <span className={`text-[11px] text-[${COLORS.lightGray}]`}>Learn more</span>
        <br />
        <a
          target="_blank"
          rel="noopener noreferrer"
          className={`text-[16px] font-[900] text-[${COLORS.darkBlue}] no-underline`}
          href={UHC_URL}
        >
          {UHC_URL}
        </a>
      </div>
    </div>
  );

  return (
    <header>
      <div className="grid grid-cols-12 items-center p-[5px]">
        {logo}
        <div className="col-span-0 md:col-span-4"></div>
        {link}
      </div>
    </header>
  );
}
