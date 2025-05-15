import Image from "next/image";

export default function Footer() {
  return (
    <footer className="mt-8 pt-6 border-t border-gray-300">
      <div className="container mx-auto px-4">
        <div className="relative h-24">
          <div className="absolute left-5">
            <a href="https://drexel.edu/uhc/" target="_blank" rel="noopener noreferrer">
              <Image
                src="/logo.png"
                alt="Drexel UHC Logo"
                width={200}
                height={80}
                className="w-auto h-20"
                priority
              />
            </a>
          </div>
        </div>
      </div>
    </footer>
  );
}