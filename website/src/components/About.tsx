'use client'

import { useEffect, useRef, useState } from 'react'
import { motion, useInView } from 'framer-motion'
import { Recycle, Target, Leaf, TrendingDown } from 'lucide-react'
import ScrollReveal from './ScrollReveal'
import { IMPACT_STATS } from '@/lib/constants'

function AnimatedCounter({ value, suffix = '', prefix = '', decimals = 0 }: { value: number; suffix?: string; prefix?: string; decimals?: number }) {
  const [count, setCount] = useState(0)
  const ref = useRef<HTMLSpanElement>(null)
  const inView = useInView(ref, { once: true })

  useEffect(() => {
    if (!inView) return
    const duration = 2000
    const steps = 60
    const increment = value / steps
    let current = 0
    const timer = setInterval(() => {
      current += increment
      if (current >= value) {
        setCount(value)
        clearInterval(timer)
      } else {
        setCount(current)
      }
    }, duration / steps)
    return () => clearInterval(timer)
  }, [inView, value])

  return (
    <span ref={ref}>
      {prefix}{decimals > 0 ? count.toFixed(decimals) : Math.round(count)}{suffix}
    </span>
  )
}

export default function About() {
  return (
    <section id="about" className="py-28 md:py-40 relative">
      <div className="max-w-7xl mx-auto px-6">
        {/* Problem section header */}
        <ScrollReveal>
          <div className="max-w-3xl">
            <span className="section-label">The Problem</span>
            <h2 className="text-display-lg font-display font-extrabold mt-4">
              The world generates{' '}
              <span className="gradient-text">2 billion tonnes</span>
              {' '}of waste annually. Only 13% gets recycled.
            </h2>
          </div>
        </ScrollReveal>

        {/* Bento grid stats */}
        <div className="grid md:grid-cols-3 gap-4 mt-16">
          {IMPACT_STATS.map((stat, i) => (
            <ScrollReveal key={i} delay={i * 0.1}>
              <div className="bento-card p-8 md:p-10 group">
                <div className="text-5xl md:text-6xl font-display font-extrabold text-white counter-glow">
                  <AnimatedCounter value={stat.value} suffix={stat.suffix} prefix={stat.prefix} decimals={stat.value % 1 !== 0 ? 2 : 0} />
                </div>
                <p className="text-neutral-400 mt-3 text-sm">{stat.label}</p>
                <div className="absolute top-4 right-4 w-8 h-8 rounded-full bg-red-500/10 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                  <TrendingDown className="w-4 h-4 text-red-500" />
                </div>
              </div>
            </ScrollReveal>
          ))}
        </div>

        {/* Solution section */}
        <div className="grid lg:grid-cols-2 gap-20 items-center mt-32">
          <ScrollReveal>
            <div>
              <span className="section-label">The Solution</span>
              <h3 className="text-display-md font-display font-extrabold mt-4">
                Meet Reclevo
              </h3>
              <p className="text-lg text-neutral-400 leading-relaxed mt-6">
                An AI-powered smart garbage bin that takes the guesswork out of recycling.
                Just throw your trash in — our camera and machine learning system identifies the waste type
                and automatically sorts it into the correct compartment.
              </p>
              <p className="text-lg text-neutral-400 leading-relaxed mt-4">
                Combined with a real-time monitoring app, waste collectors know exactly which bins need
                attention, reducing unnecessary trips and maximizing efficiency.
              </p>
            </div>
          </ScrollReveal>

          <ScrollReveal direction="right">
            <div className="space-y-3">
              {[
                { icon: Recycle, title: 'Automatic Sorting', desc: '5 waste categories sorted without human intervention', color: '#14b8a6' },
                { icon: Target, title: '99% Accuracy', desc: 'AI-powered classification with near-perfect precision', color: '#6366f1' },
                { icon: Leaf, title: 'Eco Impact', desc: 'Reduce contamination and increase recycling rates', color: '#10b981' },
              ].map((item, i) => (
                <motion.div
                  key={i}
                  whileHover={{ x: 6 }}
                  transition={{ type: 'spring', stiffness: 400, damping: 20 }}
                  className="flex items-start gap-4 p-5 rounded-2xl border border-transparent hover:border-neutral-800 hover:bg-neutral-900/50 transition-all duration-300"
                >
                  <div
                    className="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${item.color}12` }}
                  >
                    <item.icon className="w-5 h-5" style={{ color: item.color }} />
                  </div>
                  <div>
                    <h4 className="font-semibold text-white">{item.title}</h4>
                    <p className="text-sm text-neutral-400 mt-0.5">{item.desc}</p>
                  </div>
                </motion.div>
              ))}
            </div>
          </ScrollReveal>
        </div>
      </div>
    </section>
  )
}
