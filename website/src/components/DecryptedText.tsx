'use client';
import { useEffect, useState, useRef, useMemo, useCallback } from 'react';

interface DecryptedTextProps {
  text: string;
  speed?: number;
  maxIterations?: number;
  sequential?: boolean;
  revealDirection?: 'start' | 'end' | 'center';
  characters?: string;
  className?: string;
  encryptedClassName?: string;
  parentClassName?: string;
  animateOn?: 'hover' | 'view' | 'click';
}

export default function DecryptedText({
  text,
  speed = 50,
  maxIterations = 10,
  sequential = true,
  revealDirection = 'start',
  characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz!@#$%^&*',
  className = '',
  encryptedClassName = '',
  parentClassName = '',
  animateOn = 'view',
}: DecryptedTextProps) {
  const [displayText, setDisplayText] = useState(text);
  const [isAnimating, setIsAnimating] = useState(false);
  const [revealedIndices, setRevealedIndices] = useState(new Set<number>());
  const [hasAnimated, setHasAnimated] = useState(false);
  const containerRef = useRef<HTMLSpanElement>(null);
  const availableChars = useMemo(() => characters.split(''), [characters]);

  const shuffleText = useCallback((original: string, revealed: Set<number>) => {
    return original.split('').map((char, i) => {
      if (char === ' ') return ' ';
      if (revealed.has(i)) return original[i];
      return availableChars[Math.floor(Math.random() * availableChars.length)];
    }).join('');
  }, [availableChars]);

  const triggerDecrypt = useCallback(() => {
    setRevealedIndices(new Set());
    setIsAnimating(true);
  }, []);

  useEffect(() => {
    if (!isAnimating) return;
    let pointer = 0;
    const interval = setInterval(() => {
      setRevealedIndices(prev => {
        if (sequential) {
          if (prev.size < text.length) {
            const next = revealDirection === 'end' ? text.length - 1 - prev.size : prev.size;
            const updated = new Set(prev);
            updated.add(next);
            setDisplayText(shuffleText(text, updated));
            return updated;
          } else {
            clearInterval(interval);
            setIsAnimating(false);
            setDisplayText(text);
            return prev;
          }
        } else {
          pointer++;
          setDisplayText(shuffleText(text, prev));
          if (pointer >= maxIterations) {
            clearInterval(interval);
            setIsAnimating(false);
            setDisplayText(text);
          }
          return prev;
        }
      });
    }, speed);
    return () => clearInterval(interval);
  }, [isAnimating, text, speed, maxIterations, sequential, revealDirection, shuffleText]);

  useEffect(() => {
    if (animateOn !== 'view') return;
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !hasAnimated) { triggerDecrypt(); setHasAnimated(true); }
      });
    }, { threshold: 0.1 });
    if (containerRef.current) observer.observe(containerRef.current);
    return () => observer.disconnect();
  }, [animateOn, hasAnimated, triggerDecrypt]);

  useEffect(() => { setDisplayText(text); }, [text]);

  return (
    <span ref={containerRef} className={parentClassName}
      onMouseEnter={animateOn === 'hover' ? triggerDecrypt : undefined}>
      <span aria-hidden="true">
        {displayText.split('').map((char, i) => (
          <span key={i} className={revealedIndices.has(i) || (!isAnimating && hasAnimated) ? className : encryptedClassName}>
            {char}
          </span>
        ))}
      </span>
    </span>
  );
}
