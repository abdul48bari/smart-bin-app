'use client'

import { useEffect, useRef } from 'react'
import { motion } from 'framer-motion'
import dynamic from 'next/dynamic'
import { ArrowRight, ArrowDown } from 'lucide-react'
import { DEMO_APP_URL, STATS } from '@/lib/constants'
import { gsap } from 'gsap'

const SmartBin3D = dynamic(() => import('./SmartBin3D'), { ssr: false })

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
      {/* Spline 3D orb */}
      <SmartBin3D />

      {/* Gradient overlays */}
      <div className="absolute inset-0 z-[1] pointer-events-none bg-gradient-to-r from-[#09090b]/90 via-[#09090b]/40 to-transparent" />
      <div className="absolute bottom-0 left-0 right-0 h-32 z-[1] pointer-events-none bg-gradient-to-t from-[#09090b] to-transparent" />

      {/* Content */}
      <div className="relative z-[2] max-w-7xl mx-auto px-6 w-full pointer-events-none pt-20">
        <div className="max-w-2xl">
          {/* Label */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.1 }}
          >
            <span className="section-label">
              AI-Powered Waste Management
            </span>
          </motion.div>

          {/* Heading with word-by-word reveal */}
          <h1
            ref={headingRef}
            className="text-display-xl font-display font-extrabold mt-6"
            style={{ perspective: '600px' }}
          >
            {'Smart Waste,'.split(' ').map((word, i) => (
              <span key={i} className="word inline-block mr-[0.3em]" style={{ opacity: 0 }}>
                {word}
              </span>
            ))}
            <br />
            {'Smarter Future.'.split(' ').map((word, i) => (
              <span key={i + 10} className="word inline-block mr-[0.3em] gradient-text" style={{ opacity: 0 }}>
                {word}
              </span>
            ))}
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
            <a
              href="#about"
              className="pointer-events-auto btn-secondary"
            >
              Learn More
              <ArrowDown className="w-4 h-4" />
            </a>
          </motion.div>
        </div>

        {/* Stats row */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 1.2 }}
          className="mt-24"
        >
          <div className="pointer-events-auto flex items-center gap-12 md:gap-16">
            {STATS.map((stat, i) => (
              <div key={i} className="group">
                <div className="text-3xl md:text-4xl font-display font-extrabold text-white counter-glow">
                  {stat.value}{stat.suffix}
                </div>
                <div className="text-xs font-mono uppercase tracking-wider text-neutral-400 mt-1">
                  {stat.label}
                </div>
              </div>
            ))}
          </div>
        </motion.div>
      </div>

      {/* Scroll indicator */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 2, duration: 1 }}
        className="absolute bottom-8 left-1/2 -translate-x-1/2 z-[2]"
      >
        <motion.div
          animate={{ y: [0, 8, 0] }}
          transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
          className="w-6 h-10 rounded-full border-2 border-neutral-700 flex justify-center pt-2"
        >
          <div className="w-1 h-2 rounded-full bg-neutral-600" />
        </motion.div>
      </motion.div>
    </section>
  )
}
