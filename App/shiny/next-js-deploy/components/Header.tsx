import Image from 'next/image';
import Link from 'next/link';

export default function Header() {
  return (
    <header className="flex justify-between items-center w-full bg-white shadow-sm p-4">
      <div className="flex items-center gap-4">
        <Image
          src="/philly-logo.png"
          alt="Philadelphia Logo"
          width={60}
          height={60}
          priority
        />
        <h1 className="text-xl font-bold">Philadelphia Council Districts and Health</h1>
      </div>

      <nav>
        <ul className="flex gap-6">
          <li>
            <Link href="/" className="hover:text-blue-600 transition-colors">
              Home
            </Link>
          </li>
          <li>
            <Link href="/map" className="hover:text-blue-600 transition-colors">
              Map
            </Link>
          </li>
          <li>
            <Link href="/about" className="hover:text-blue-600 transition-colors">
              About
            </Link>
          </li>
        </ul>
      </nav>
    </header>
  );
}