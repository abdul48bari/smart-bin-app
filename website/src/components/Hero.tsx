'use client'

import { useEffect, useRef } from 'react'
import { motion } from 'framer-motion'
import dynamic from 'next/dynamic'
import { ArrowRight, ArrowDown } from 'lucide-react'
import { DEMO_APP_URL, STATS } from '@/lib/constants'
import { gsap } from 'gsap'
import Aurora from './Aurora'
import DecryptedText from './DecryptedText'

const SmartBin3D = dynamic(() => import('./SmartBin3D'), { ssr: false })

const WASTE_CATEGORIES = [
  { name: 'Plastic', color: '#6366f1' },
  { name: 'Paper', color: '#10B981' },
  { name: 'Organic', color: '#d97706' },
  { name: 'Cans', color: '#F59E0B' },
  { name: 'Mixed', color: '#8B5CF6' },
]

const STAT_COLORS = ['#22c55e', '#6366f1', '#10B981']

export default function Hero() {
  const headingRef = useRef<HTMLHeadingElement>(null)

  useEffect(() => {
    if (!headingRef.current) return
    const words = headingRef.current.querySelectorAll('.word')
    gsap.fromTo(
      words,
      { y: 80, opacity: 0, rotateX: -40 },
      {
        y: 0,
        opacity: 1,
        rotateX: 0,
        duration: 1,
        stagger: 0.08,
        ease: 'power3.out',
        delay: 0.3,
      }
    )
  }, [])

  return (
    <section className="relative min-h-screen flex items-center overflow-hidden">
      {/* Aurora background */}
      <Aurora colorStops={['#3A1C71', '#00d4ff', '#22c55e']} amplitude={1.2} blend={0.6} speed={0.4} />

      {/* Spline 3D model */}
      <SmartBin3D />

      {/* Gradient overlays */}
      <div className="absolute inset-0 z-[1] pointer-events-none bg-gradient-to-r from-[#09090b]/90 via-[#09090b]/50 to-transparent" />
      <div className="absolute bottom-0 left-0 right-0 h-40 z-[1] pointer-events-none bg-gradient-to-t from-[#09090b] to-transparent" />

      {/* Content */}
      <div className="relative z-[2] max-w-7xl mx-auto px-6 w-full pointer-events-none pt-20">
        <div className="max-w-2xl">
          {/* Label */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
          >
            <span className="section-label">AI-Powered Waste Management</span>
          </motion.div>

          {/* Heading — DecryptedText reveal */}
          <h1
            ref={headingRef}
            className="text-display-xl font-display font-extrabold mt-6"
            style={{ perspective: '600px' }}
          >
            <DecryptedText
              text="Smart Waste,"
              animateOn="view"
              sequential={true}
              speed={35}
              className="text-white"
              encryptedClassName="text-green-400/30"
            />
            <br />
            <DecryptedText
              text="Smarter Future."
              animateOn="view"
              sequential={true}
              speed={35}
              className="gradient-text"
              encryptedClassName="text-green-400/30"
            />
          </h1>

          {/* Subtitle */}
          <motion.p
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            className="text-lg text-neutral-400 max-w-md mt-6 leading-relaxed"
          >
            Reclevo uses AI and camera technology to automatically classify and sort waste into 5 categories — making recycling effortless.
          </motion.p>

          {/* Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 1.0 }}
            className="flex flex-wrap gap-4 mt-10"
          >
            <a
              href={DEMO_APP_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="pointer-events-auto btn-primary"
            >
              Try Demo App
              <ArrowRight className="w-4 h-4" />
            </a>
            <a href="#about" className="pointer-events-auto btn-secondary">
              Learn More
              <ArrowDown className="w-4 h-4" />
            </a>
          </motion.div>

          {/* Waste category pills */}
          <motion.div
            initial={{ opacity: 0, y: 16 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.7, delay: 1.2 }}
            className="flex flex-wrap items-center gap-2 mt-8 pointer-events-auto"
          >
            <span className="text-[10px] font-mono text-neutral-700 uppercase tracking-widest mr-1">Sorts:</span>
            {WASTE_CATEGORIES.map((cat, i) => (
              <motion.div
                key={cat.name}
                initial={{ opacity: 0, scale: 0.85 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 1.25 + i * 0.06, duration: 0.3 }}
                className="flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-mono uppercase tracking-wider"
                style={{
                  color: cat.color,
                  backgroundColor: `${cat.color}12`,
                  border: `1px solid ${cat.color}25`,
                }}
              >
                <span className="w-1 h-1 rounded-full flex-shrink-0" style={{ backgroundColor: cat.color }} />
                {cat.name}
              </motion.div>
            ))}
          </motion.div>
        </div>

        {/* Stats row — enhanced */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 1.5 }}
          className="mt-20 pointer-events-auto"
        >
          <div className="flex items-stretch gap-0 w-fit">
            {STATS.map((stat, i) => (
              <div
                key={i}
                className={`flex flex-col px-8 md:px-12 ${i > 0 ? 'border-l border-neutral-800/60' : ''}`}
              >
                <div
                  className="text-3xl md:text-5xl font-display font-extrabold leading-none tabular-nums"
                  style={{
                    color: STAT_COLORS[i],
                    textShadow: `0 0 40px ${STAT_COLORS[i]}40`,
                  }}
                >
                  {stat.value}{stat.suffix}
                </div>
                <div className="text-[10px] font-mono uppercase tracking-[0.2em] text-neutral-600 mt-2">
                  {stat.label}
                </div>
                {/* Colored underline accent */}
                <div
                  className="h-[2px] w-8 rounded-full mt-3"
                  style={{ backgroundColor: STAT_COLORS[i], opacity: 0.5 }}
                />
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2.2, duration: 1 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 z-[2]"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
          className="w-6 h-10 rounded-full border-2 border-neutral-700/60 flex justify-center pt-2"
        >
          <div className="w-1 h-2 rounded-full bg-neutral-600" />
        </motion.div>
      </motion.div>
    </section>
  )
}
