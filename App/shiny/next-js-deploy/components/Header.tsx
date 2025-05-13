import Image from "next/image";

export default function Header() {
  return (
    <header>
      <div className="grid grid-cols-12 items-center p-[5px] md:p-[35px] md:pr-[55px]">
        {/* Logo - takes 3 columns on mobile, 4 on medium screens */}
        <a
          href="https://drexel.edu/uhc/"
          target="_blank"
          rel="noopener noreferrer"
          className="col-span-12 md:col-span-4"
        >
          <Image
            src="/logo.png"
            alt="Drexel UHC Logo"
            width={400}
            height={50}
            className="w-[200px] sm:w-[400px] max-w-full"
            priority
          />
        </a>

        {/* Middle spacer - takes 5 columns on mobile, 4 on medium screens */}
        <div className="col-span-0 md:col-span-4"></div>

        {/* Learn more section - takes 4 columns consistently */}
        <div className="col-span-12 justify-self-start p-[23px]">
          <span className="text-[11px] text-[#a7a8aa]">Learn more</span>
          <br />
          <a
            target="_blank"
            rel="noopener noreferrer"
            className="text-[16px] font-[900] text-[#07294d] no-underline"
            href="https://drexel.edu/uhc/"
          >
            https://drexel.edu/uhc/
          </a>
        </div>
      </div>
    </header>
  );
}