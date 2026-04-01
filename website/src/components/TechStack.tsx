'use client'

import { useRef, useState } from 'react'
import { motion, useInView } from 'framer-motion'
import ScrollReveal from './ScrollReveal'
import { TECH_STACK } from '@/lib/constants'
import SpotlightCard from './SpotlightCard'

// Live monitoring metrics per tech
const TECH_METRICS: Record<string, {
  primary: number
  primaryLabel: string
  status: string
  statusColor: string
  stats: Array<{ label: string; value: string }>
}> = {
  'AI & ML': {
    primary: 99.2,
    primaryLabel: 'Classification Accuracy',
    status: 'INFERENCE',
    statusColor: '#22c55e',
    stats: [{ label: 'LATENCY', value: '<100ms' }, { label: 'CLASSES', value: '5' }, { label: 'MODEL', value: 'CNN' }],
  },
  'IoT Hardware': {
    primary: 97.4,
    primaryLabel: 'Sensor Uptime',
    status: 'ACTIVE',
    statusColor: '#22c55e',
    stats: [{ label: 'SENSORS', value: '6' }, { label: 'MCU', value: 'RPi 4' }, { label: 'CONN', value: 'Wi-Fi' }],
  },
  'Cloud': {
    primary: 99.9,
    primaryLabel: 'API Uptime',
    status: 'LIVE',
    statusColor: '#22c55e',
    stats: [{ label: 'REGION', value: 'US-C' }, { label: 'FNS', value: '2' }, { label: 'DB', value: 'NoSQL' }],
  },
  'Mobile App': {
    primary: 100,
    primaryLabel: 'Build Passing',
    status: 'DEPLOYED',
    statusColor: '#22c55e',
    stats: [{ label: 'TARGETS', value: '×3' }, { label: 'BUILD', value: 'v1.0' }, { label: 'VOICE', value: 'STT/TTS' }],
  },
}

export default function TechStack() {
  return (
    <section id="tech" className="py-14 md:py-20 relative overflow-hidden">
      {/* Static ambient */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-0 right-1/3 w-[500px] h-[500px] rounded-full blur-[120px] opacity-[0.045]"
          style={{ background: 'radial-gradient(circle, #8B5CF6 0%, transparent 70%)' }}
        />
        <div
          className="absolute bottom-0 left-0 w-[400px] h-[400px] rounded-full blur-[100px] opacity-[0.04]"
          style={{ background: 'radial-gradient(circle, #22c55e 0%, transparent 70%)' }}
        />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        <ScrollReveal>
          <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-4 mb-10">
            <div className="max-w-2xl">
              <span className="section-label">Technology</span>
              <h2 className="text-display-lg font-display font-extrabold mt-4">
                Powered by{' '}
                <span className="gradient-text">cutting-edge</span>
                {' '}technology.
              </h2>
            </div>
            <p className="text-neutral-300 text-base max-w-xs leading-relaxed">
              Four live systems — from Raspberry Pi sensors to cloud and your pocket.
            </p>
          </div>
        </ScrollReveal>

        {/* Dashboard monitor grid — 4-up on xl, 2x2 on md */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
          {TECH_STACK.map((tech, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 32 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: i * 0.09, ease: [0.16, 1, 0.3, 1] }}
            >
              <MonitorPanel tech={tech} metrics={TECH_METRICS[tech.category]!} />
            </motion.div>
          ))}
        </div>

        {/* Footer timestamp strip */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ delay: 0.5, duration: 0.6 }}
          className="flex items-center gap-4 mt-6"
        >
          <div className="h-px flex-1 bg-neutral-800/60" />
          <span className="text-[10px] font-mono text-neutral-700 uppercase tracking-widest whitespace-nowrap">
            RECLEVO SYSTEM MONITOR — ALL SYSTEMS NOMINAL
          </span>
          <div className="h-px flex-1 bg-neutral-800/60" />
        </motion.div>
      </div>
    </section>
  )
}

function MonitorPanel({
  tech,
  metrics,
}: {
  tech: typeof TECH_STACK[number]
  metrics: typeof TECH_METRICS[string]
}) {
  const [hovered, setHovered] = useState(false)
  const ref = useRef<HTMLDivElement>(null)
  const inView = useInView(ref, { once: true })

  const processId = tech.category.toUpperCase().replace(/[\s&]/g, '_')

  return (
    <SpotlightCard spotlightColor="rgba(0,212,255,0.12)" className="rounded-2xl">
    <motion.div
      ref={ref}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      whileHover={{ y: -5 }}
      transition={{ type: 'spring', stiffness: 350, damping: 25 }}
      className="relative flex flex-col rounded-2xl overflow-hidden h-full cursor-default"
      style={{
        backgroundColor: '#0c0c0e',
        border: `1px solid ${hovered ? tech.color + '40' : 'rgba(255,255,255,0.06)'}`,
        boxShadow: hovered ? `0 0 40px -8px ${tech.color}28` : 'none',
        transition: 'border-color 0.3s ease, box-shadow 0.3s ease',
      }}
    >
      {/* Color wash */}
      <motion.div
        className="absolute inset-0 pointer-events-none"
        animate={{ opacity: hovered ? 1 : 0 }}
        transition={{ duration: 0.4 }}
        style={{
          background: `radial-gradient(ellipse 80% 50% at 50% 0%, ${tech.color}0e 0%, transparent 70%)`,
        }}
      />

      {/* Top shimmer */}
      <motion.div
        className="absolute top-0 left-0 right-0 h-[1.5px] pointer-events-none"
        animate={{ opacity: hovered ? 1 : 0 }}
        style={{ background: `linear-gradient(90deg, transparent, ${tech.color}90, transparent)` }}
      />

      <div className="relative z-10 flex flex-col flex-1 p-6">
        {/* Header row — process ID + status dot */}
        <div className="flex items-center justify-between mb-5">
          <span className="text-[9px] font-mono text-neutral-700 uppercase tracking-[0.3em] leading-none">
            {processId}
          </span>
          <div className="flex items-center gap-1.5">
            <span
              className="w-1.5 h-1.5 rounded-full flex-shrink-0"
              style={{
                backgroundColor: metrics.statusColor,
                boxShadow: hovered ? `0 0 6px ${metrics.statusColor}` : 'none',
                transition: 'box-shadow 0.3s ease',
                animation: 'pulse 2.5s ease-in-out infinite',
              }}
            />
            <span
              className="text-[9px] font-mono uppercase tracking-widest transition-colors duration-300"
              style={{ color: hovered ? metrics.statusColor : '#333333' }}
            >
              {metrics.status}
            </span>
          </div>
        </div>

        {/* Primary metric */}
        <div className="mb-1">
          <div className="flex items-baseline justify-between mb-2">
            <span
              className="text-[10px] font-mono uppercase tracking-wider transition-colors duration-300"
              style={{ color: hovered ? tech.color : '#3a3a3a' }}
            >
              {metrics.primaryLabel}
            </span>
            <span
              className="text-xl font-display font-black tabular-nums leading-none"
              style={{ color: tech.color }}
            >
              {metrics.primary}%
            </span>
          </div>
          {/* Animated bar */}
          <div
            className="h-[6px] rounded-full overflow-hidden"
            style={{ backgroundColor: 'rgba(255,255,255,0.04)' }}
          >
            <motion.div
              className="h-full rounded-full"
              style={{ backgroundColor: tech.color }}
              initial={{ width: 0 }}
              animate={{ width: inView ? `${metrics.primary}%` : 0 }}
              transition={{ duration: 1.8, delay: 0.3, ease: [0.16, 1, 0.3, 1] }}
            />
          </div>
        </div>

        {/* Icon + Category + Description */}
        <div className="flex items-start gap-3 mt-5 mb-5">
          <div
            className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 transition-all duration-300"
            style={{
              backgroundColor: hovered ? `${tech.color}1a` : 'rgba(255,255,255,0.03)',
              border: `1.5px solid ${hovered ? tech.color + '38' : 'rgba(255,255,255,0.06)'}`,
            }}
          >
            <tech.icon
              className="w-[18px] h-[18px] transition-colors duration-300"
              style={{ color: hovered ? tech.color : '#404040' }}
            />
          </div>
          <div className="min-w-0">
            <h3 className="font-display font-bold text-white text-base leading-tight">
              {tech.category}
            </h3>
            <p className="text-[11px] text-neutral-400 mt-0.5 leading-snug line-clamp-2">
              {tech.description}
            </p>
          </div>
        </div>

        {/* Tech chips */}
        <div className="flex flex-wrap gap-1.5 mb-5">
          {tech.items.map((item, j) => (
            <span
              key={j}
              className="text-[10px] font-mono px-2 py-1 rounded-md transition-all duration-200"
              style={{
                color: hovered ? tech.color : '#404040',
                backgroundColor: hovered ? `${tech.color}0e` : 'rgba(255,255,255,0.025)',
                border: `1px solid ${hovered ? tech.color + '20' : 'rgba(255,255,255,0.04)'}`,
              }}
            >
              {item}
            </span>
          ))}
        </div>

        {/* Secondary stats grid — bottom of card */}
        <div
          className="grid grid-cols-3 gap-2 pt-4 mt-auto"
          style={{ borderTop: `1px solid ${hovered ? tech.color + '18' : 'rgba(255,255,255,0.04)'}` }}
        >
          {metrics.stats.map((s, j) => (
            <div key={j}>
              <span className="block text-[8px] font-mono uppercase tracking-widest text-neutral-700 mb-0.5">
                {s.label}
              </span>
              <span
                className="block text-xs font-mono font-semibold tabular-nums transition-colors duration-300"
                style={{ color: hovered ? tech.color : '#555555' }}
              >
                {s.value}
              </span>
            </div>
          ))}
        </div>
      </div>
    </motion.div>
    </SpotlightCard>
  )
}
