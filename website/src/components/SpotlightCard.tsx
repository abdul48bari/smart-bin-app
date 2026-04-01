'use client';
import { useRef, ReactNode, useState } from 'react';

interface SpotlightCardProps {
  children: ReactNode;
  className?: string;
  spotlightColor?: string;
}

export default function SpotlightCard({
  children,
  className = '',
  spotlightColor = 'rgba(255,255,255,0.08)',
}: SpotlightCardProps) {
  const divRef = useRef<HTMLDivElement>(null);
  const [hovered, setHovered] = useState(false);
  const [pos, setPos] = useState({ x: '50%', y: '50%' });

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!divRef.current) return;
    const rect = divRef.current.getBoundingClientRect();
    setPos({ x: `${e.clientX - rect.left}px`, y: `${e.clientY - rect.top}px` });
  };

  return (
    <div
      ref={divRef}
      onMouseMove={handleMouseMove}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className={`relative overflow-hidden ${className}`}
    >
      <div
        className="pointer-events-none absolute inset-0 transition-opacity duration-500"
        style={{
          background: `radial-gradient(circle at ${pos.x} ${pos.y}, ${spotlightColor}, transparent 80%)`,
          opacity: hovered ? 1 : 0,
        }}
      />
      {children}
    </div>
  );
}
