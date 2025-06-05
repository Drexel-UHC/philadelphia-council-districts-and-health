import React from "react";
import Image from "next/image";

const CoverPhoto = () => {
  return (
    <section style={{ position: "relative", width: "100%", height: "260px", marginBottom: "2rem" }}>
      <Image
        src="/cover_photo.jpg"
        alt="Philadelphia Skyline"
        fill
        style={{
          objectFit: "cover",
          filter: "brightness(0.7)",
          zIndex: 0,
        }}
        priority
        sizes="100vw"
      />
      <div
        style={{
          position: "absolute",
          top: 0,
          left: 0,
          width: "100%",
          height: "100%",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          zIndex: 1,
        }}
      >
        <h1
          style={{
            color: "#fff",
            fontSize: "2.2rem",
            fontWeight: 600,
            textAlign: "center",
            textShadow: "0 2px 12px rgba(0,0,0,0.5)",
            background: "rgba(0,0,0,0.15)",
            padding: "0.5rem 1.5rem",
            borderRadius: "0.5rem",
            maxWidth: "90%",
          }}
        >
          Health of Philadelphia City Council Districts
        </h1>
      </div>
    </section>
  );
};

export default CoverPhoto;
