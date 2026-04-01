'use client';
import { motion } from 'framer-motion';
import { useEffect, useRef, useState } from 'react';

interface BlurTextProps {
  text: string;
  delay?: number;
  className?: string;
  animateBy?: 'words' | 'chars';
  direction?: 'top' | 'bottom';
  threshold?: number;
}

export default function BlurText({
  text = '',
  delay = 120,
  className = '',
  animateBy = 'words',
  direction = 'bottom',
  threshold = 0.1,
}: BlurTextProps) {
  const elements = animateBy === 'words' ? text.split(' ') : text.split('');
  const [inView, setInView] = useState(false);
  const ref = useRef<HTMLParagraphElement>(null);

  useEffect(() => {
    if (!ref.current) return;
    const observer = new IntersectionObserver(
      ([entry]) => { if (entry.isIntersecting) { setInView(true); observer.disconnect(); } },
      { threshold }
    );
    observer.observe(ref.current);
    return () => observer.disconnect();
  }, [threshold]);

  const from = { filter: 'blur(10px)', opacity: 0, y: direction === 'top' ? -30 : 30 };
  const to = { filter: 'blur(0px)', opacity: 1, y: 0 };

  return (
    <p ref={ref} className={className} style={{ display: 'flex', flexWrap: 'wrap', gap: '0.25em' }}>
      {elements.map((seg, i) => (
        <motion.span
          key={i}
          className="inline-block"
          initial={from}
          animate={inView ? to : from}
          transition={{ duration: 0.5, delay: (i * delay) / 1000, ease: 'easeOut' }}
        >
          {seg}
        </motion.span>
      ))}
    </p>
  );
}
