'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import ScrollReveal from './ScrollReveal'
import { TECH_STACK } from '@/lib/constants'

export default function TechStack() {
  return (
    <section id="tech" className="py-28 md:py-40 relative overflow-hidden">
      {/* Ambient orbs */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-1/4 left-0 w-[500px] h-[500px] rounded-full blur-3xl opacity-[0.06]"
          style={{ background: 'radial-gradient(circle, #8B5CF6 0%, transparent 70%)' }}
        />
        <div
          className="absolute bottom-0 right-0 w-[400px] h-[400px] rounded-full blur-3xl opacity-[0.06]"
          style={{ background: 'radial-gradient(circle, #F59E0B 0%, transparent 70%)' }}
        />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <ScrollReveal>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-16">
            <div className="max-w-2xl">
              <span className="section-label">Technology</span>
              <h2 className="text-display-lg font-display font-extrabold mt-4">
                Powered by{' '}
                <span className="gradient-text">cutting-edge</span>
                {' '}technology.
              </h2>
            </div>
            <p className="text-neutral-400 text-sm max-w-xs leading-relaxed">
              A robust, modern stack built for scale, speed, and reliability.
            </p>
          </div>
        </ScrollReveal>

        <div className="grid md:grid-cols-2 gap-5">
          {TECH_STACK.map((tech, i) => (
            <ScrollReveal key={i} delay={i * 0.1}>
              <TechCard tech={tech} index={i} />
            </ScrollReveal>
          ))}
        </div>
      </div>
    </section>
  )
}

function TechCard({ tech, index }: { tech: typeof TECH_STACK[number]; index: number }) {
  const [isHovered, setIsHovered] = useState(false)

  return (
    <motion.div
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      whileHover={{ y: -5, scale: 1.01 }}
      transition={{ type: 'spring', stiffness: 350, damping: 22 }}
      className="relative rounded-2xl p-8 md:p-10 overflow-hidden group h-full"
    >
      {/* Background */}
      <div className="absolute inset-0 rounded-2xl bg-neutral-900 border border-neutral-800 transition-all duration-500 group-hover:border-neutral-700" />

      {/* Color wash */}
      <motion.div
        className="absolute inset-0 rounded-2xl pointer-events-none"
        animate={{ opacity: isHovered ? 1 : 0 }}
        style={{ background: `radial-gradient(circle at 30% 20%, ${tech.color}10 0%, transparent 65%)` }}
        transition={{ duration: 0.4 }}
      />

      {/* Top shimmer */}
      <div
        className="absolute top-0 left-0 right-0 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-500"
        style={{ background: `linear-gradient(90deg, transparent, ${tech.color}70, transparent)` }}
      />

      <div className="relative z-10 h-full flex flex-col gap-6">
        {/* Header row */}
        <div className="flex items-start justify-between">
          {/* Icon */}
          <div className="relative">
            <div
              className="absolute inset-0 rounded-xl blur-lg transition-opacity duration-500"
              style={{ backgroundColor: tech.color, opacity: isHovered ? 0.4 : 0.1, transform: 'scale(1.5)' }}
            />
            <div
              className="relative w-14 h-14 rounded-xl flex items-center justify-center transition-transform duration-500 group-hover:scale-110"
              style={{
                background: `linear-gradient(135deg, ${tech.color}25 0%, ${tech.color}0a 100%)`,
                border: `1.5px solid ${tech.color}30`,
                boxShadow: isHovered ? `0 8px 24px -4px ${tech.color}30` : 'none',
              }}
            >
              <tech.icon className="w-7 h-7" style={{ color: tech.color }} />
            </div>
          </div>

          {/* Category label — uses font-display for distinctive typography */}
          <div
            className="px-3 py-1.5 rounded-lg"
            style={{
              backgroundColor: `${tech.color}10`,
              border: `1px solid ${tech.color}20`,
            }}
          >
            <span
              className="text-[11px] font-display font-semibold uppercase tracking-[0.15em]"
              style={{ color: tech.color }}
            >
              {tech.category}
            </span>
          </div>
        </div>

        {/* Description */}
        <p className="text-neutral-400 text-[15px] leading-relaxed font-sans">
          {tech.description}
        </p>

        {/* Tech item chips — distinctive font treatment */}
        <div className="flex flex-wrap gap-2 mt-auto">
          {tech.items.map((item, j) => (
            <motion.span
              key={j}
              initial={{ opacity: 0, scale: 0.85 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 + j * 0.06, duration: 0.3 }}
              className="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-lg text-[13px] font-sans font-medium transition-all duration-300"
              style={{
                backgroundColor: isHovered ? `${tech.color}12` : 'transparent',
                color: isHovered ? tech.color : undefined,
                border: `1px solid ${isHovered ? tech.color + '30' : 'rgba(0,0,0,0.08)'}`,
              }}
            >
              <span
                className="w-1.5 h-1.5 rounded-full flex-shrink-0 transition-colors duration-300"
                style={{ backgroundColor: isHovered ? tech.color : '#94a3b8' }}
              />
              <span className="text-neutral-300">{item}</span>
            </motion.span>
          ))}
        </div>

        {/* Bottom accent */}
        <motion.div
          className="h-[2px] rounded-full mt-1"
          style={{ backgroundColor: tech.color }}
          animate={{ scaleX: isHovered ? 1 : 0, originX: 0 }}
          transition={{ duration: 0.4, ease: 'easeOut' }}
        />
      </div>
    </motion.div>
  )
}
