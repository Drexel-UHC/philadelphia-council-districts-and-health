import React from "react";
import Image from "next/image";

const CoverPhoto = () => {
  return (
    <section className="relative w-full h-[260px] mt-5 ">
      <Image
        src="./cover_photo.jpg"
        alt="Philadelphia Skyline"
        fill
        className="object-cover brightness-70 z-0"
        priority
        sizes="100vw"
      />
      <div className="absolute inset-0 flex items-center justify-center z-10">
        <h1 className="text-white text-[2.2rem] font-semibold text-center shadow-lg bg-black/15 px-6 py-2 rounded-lg max-w-[90%]">
          Philadelphia Council District Health Dashboard
        </h1>
      </div>
    </section>
  );
};

export default CoverPhoto;
