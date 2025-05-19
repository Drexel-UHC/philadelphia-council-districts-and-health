import Image from "next/image";
import { Facebook, Instagram, Youtube, Linkedin } from "lucide-react";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";

export default function Footer() {
  return (
    <footer className="mt-8 pt-6 border-t border-gray-300">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row justify-between items-center">
          {/* Logo on the left */}
          <div className="mb-6 md:mb-0">
            <a href="https://drexel.edu/uhc/" target="_blank" rel="noopener noreferrer">
              <Image
                src="./logo.png"
                alt="Drexel UHC Logo"
                width={200}
                height={80}
                className="w-auto h-20"
                priority
              />
            </a>
          </div>
          
          {/* Social links on the right */}
          <div className="text-center md:text-right">
            <p className="text-sm font-medium mb-2">Follow UHC:</p>
            <ul className="flex space-x-4 items-center">
              <li>                    
                <a 
                  href="https://www.facebook.com/DrexelUHC/" 
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="Facebook"
                  className="block"
                >
                  <Avatar className="h-8 w-8 bg-[#07294D] hover:opacity-90 transition-opacity">
                    <AvatarFallback className="text-white">
                      <Facebook size={16} className="text-white" />
                    </AvatarFallback>
                  </Avatar>
                  <span className="sr-only">Facebook</span>
                </a>
              </li>
              
              <li>                    
                <a 
                  href="https://www.instagram.com/drexeluhc" 
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="Instagram"
                  className="block"
                >
                  <Avatar className="h-8 w-8 bg-[#07294D] hover:opacity-90 transition-opacity">
                    <AvatarFallback className="text-white">
                      <Instagram size={16} className="text-white" />
                    </AvatarFallback>
                  </Avatar>
                  <span className="sr-only">Instagram</span>
                </a>
              </li>
              
              <li>                    
                <a 
                  href="https://www.youtube.com/@urbanhealthcollaborative8928" 
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="YouTube"
                  className="block"
                >
                  <Avatar className="h-8 w-8 bg-[#07294D] hover:opacity-90 transition-opacity">
                    <AvatarFallback className="text-white">
                      <Youtube size={16} className="text-white" />
                    </AvatarFallback>
                  </Avatar>
                  <span className="sr-only">YouTube</span>
                </a>
              </li>
              
              <li>                    
                <a 
                  href="https://www.linkedin.com/company/drexel-urban-health-collaborative/" 
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="LinkedIn"
                  className="block"
                >
                  <Avatar className="h-8 w-8 bg-[#07294D] hover:opacity-90 transition-opacity">
                    <AvatarFallback className="text-white">
                      <Linkedin size={16} className="text-red" />
                    </AvatarFallback>
                  </Avatar>
                  <span className="sr-only">LinkedIn</span>
                </a>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </footer>
  );
}