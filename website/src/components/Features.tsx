'use client'

import { useRef, useState, useEffect, useCallback } from 'react'
import { motion, AnimatePresence, useInView } from 'framer-motion'
import { ArrowRight } from 'lucide-react'
import { FEATURES } from '@/lib/constants'
import SpotlightCard from './SpotlightCard'

const FEATURE_EXTRAS: Record<number, string[]> = {
  0: ['5 sub-bins', 'Live stream', 'Fill alerts'],
  1: ['99.2% accuracy', '5 categories', 'Real-time'],
  2: ['Collection trends', 'Efficiency score', 'Impact metrics'],
  3: ['Hands-free', 'Multi-language', 'Always-on'],
  4: ['Battery detected', 'Gas sensors', 'Moisture alerts'],
  5: ['Firebase Auth', 'Encrypted data', '99.9% uptime'],
}

const ROTATION_MS = 3200

export default function Features() {
  const [active, setActive] = useState(0)
  const [paused, setPaused] = useState(false)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)
  const sectionRef = useRef<HTMLDivElement>(null)
  const isInView = useInView(sectionRef, { once: false, margin: '-150px' })

  // Auto-rotation — stops when paused or section not in view
  const startRotation = useCallback(() => {
    if (intervalRef.current) clearInterval(intervalRef.current)
    intervalRef.current = setInterval(() => {
      setActive(prev => (prev + 1) % FEATURES.length)
    }, ROTATION_MS)
  }, [])

  const stopRotation = useCallback(() => {
    if (intervalRef.current) clearInterval(intervalRef.current)
    intervalRef.current = null
  }, [])

  useEffect(() => {
    if (!paused && isInView) {
      startRotation()
    } else {
      stopRotation()
    }
    return stopRotation
  }, [paused, isInView, startRotation, stopRotation])

  return (
    <section id="features" className="py-14 md:py-20 relative overflow-hidden" ref={sectionRef}>
      {/* Ambient orbs — gated by isInView */}
      <div className="absolute inset-0 pointer-events-none">
        {isInView && (
          <>
            <motion.div
              className="absolute top-[-80px] left-1/4 w-[600px] h-[600px] rounded-full blur-3xl opacity-[0.06]"
              style={{ background: 'radial-gradient(circle, #6366f1 0%, transparent 70%)' }}
              animate={{ scale: [1, 1.08, 1] }}
              transition={{ duration: 14, repeat: Infinity, ease: 'easeInOut' }}
            />
            <motion.div
              className="absolute bottom-[-80px] right-1/4 w-[500px] h-[500px] rounded-full blur-3xl opacity-[0.06]"
              style={{ background: 'radial-gradient(circle, #22c55e 0%, transparent 70%)' }}
              animate={{ scale: [1, 1.12, 1] }}
              transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut', delay: 3 }}
            />
          </>
        )}
        <svg className="absolute inset-0 w-full h-full opacity-[0.028]" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="featureDots" x="0" y="0" width="28" height="28" patternUnits="userSpaceOnUse">
              <circle cx="1" cy="1" r="1.2" fill="currentColor" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#featureDots)" className="text-white" />
        </svg>
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-10"
        >
          <div className="max-w-2xl">
            <span className="section-label">Features</span>
            <h2 className="text-display-lg font-display font-extrabold mt-4">
              Everything you need to{' '}
              <span className="gradient-text">manage waste</span>
              {' '}intelligently.
            </h2>
          </div>
          <p className="text-neutral-300 text-base leading-relaxed max-w-xs">
            Six powerful capabilities working in harmony — from AI to real-time alerts.
          </p>
        </motion.div>

        {/* Desktop: Interactive Feature Explorer */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, delay: 0.1, ease: [0.16, 1, 0.3, 1] }}
          className="hidden lg:flex rounded-3xl overflow-hidden border border-neutral-800/60 min-h-[540px]"
          style={{ backgroundColor: 'rgba(14, 14, 16, 0.8)' }}
          onMouseEnter={() => setPaused(true)}
          onMouseLeave={() => setPaused(false)}
        >
          {/* Left: Feature List */}
          <div className="w-[320px] flex-shrink-0 border-r border-neutral-800/60 flex flex-col">
            {FEATURES.map((feature, i) => (
              <FeatureListItem
                key={i}
                feature={feature}
                index={i}
                isActive={active === i}
                onSelect={() => setActive(i)}
                isLast={i === FEATURES.length - 1}
              />
            ))}

            {/* Dot progress indicator */}
            <div className="flex items-center gap-2 px-6 py-4 border-t border-neutral-800/50 mt-auto">
              {FEATURES.map((f, i) => (
                <button
                  key={i}
                  onClick={() => setActive(i)}
                  className="transition-all duration-300"
                  style={{
                    width: active === i ? '16px' : '6px',
                    height: '6px',
                    borderRadius: '3px',
                    backgroundColor: active === i ? f.color : 'rgba(255,255,255,0.12)',
                  }}
                />
              ))}
              <span className="ml-auto text-[9px] font-mono text-neutral-700 uppercase tracking-widest">
                {paused ? 'PAUSED' : 'AUTO'}
              </span>
            </div>
          </div>

          {/* Right: Feature Detail Panel */}
          <div className="flex-1 relative overflow-hidden">
            {/* Linear timer bar — resets on each new active, hidden when paused */}
            <div className="absolute top-0 left-0 right-0 h-[2px] z-20 overflow-hidden">
              {!paused && (
                <motion.div
                  key={`timer-${active}`}
                  className="h-full origin-left"
                  style={{ backgroundColor: FEATURES[active].color }}
                  initial={{ scaleX: 0 }}
                  animate={{ scaleX: 1 }}
                  transition={{ duration: ROTATION_MS / 1000, ease: 'linear' }}
                />
              )}
            </div>

            <AnimatePresence mode="wait">
              <motion.div
                key={active}
                initial={{ opacity: 0, y: 18 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -10 }}
                transition={{ duration: 0.3, ease: [0.16, 1, 0.3, 1] }}
                className="absolute inset-0"
              >
                <FeaturePanel feature={FEATURES[active]} index={active} />
              </motion.div>
            </AnimatePresence>
          </div>
        </motion.div>

        {/* Mobile: Card Grid */}
        <div className="lg:hidden grid grid-cols-1 sm:grid-cols-2 gap-4">
          {FEATURES.map((feature, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 24 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.07 }}
            >
              <MobileFeatureCard feature={feature} index={i} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

function FeatureListItem({
  feature,
  index,
  isActive,
  onSelect,
  isLast,
}: {
  feature: typeof FEATURES[number]
  index: number
  isActive: boolean
  onSelect: () => void
  isLast: boolean
}) {
  return (
    <button
      onClick={onSelect}
      onMouseEnter={onSelect}
      className={`relative flex items-center gap-4 px-6 py-5 w-full text-left ${!isLast ? 'border-b border-neutral-800/50' : ''}`}
      style={{ minHeight: '72px' }}
    >
      {/* Active left accent */}
      <motion.div
        className="absolute left-0 top-3 bottom-3 w-[2.5px] rounded-r-full"
        style={{ backgroundColor: feature.color }}
        animate={{ scaleY: isActive ? 1 : 0, opacity: isActive ? 1 : 0 }}
        transition={{ duration: 0.22, ease: 'easeOut' }}
      />

      {/* Background wash */}
      <motion.div
        className="absolute inset-0 pointer-events-none"
        animate={{ opacity: isActive ? 1 : 0 }}
        style={{ background: `linear-gradient(90deg, ${feature.color}0a 0%, transparent 75%)` }}
        transition={{ duration: 0.28 }}
      />

      {/* Number */}
      <span
        className="text-[11px] font-mono font-bold w-5 shrink-0 transition-colors duration-200"
        style={{ color: isActive ? feature.color : '#3a3a3a' }}
      >
        {String(index + 1).padStart(2, '0')}
      </span>

      {/* Icon */}
      <div
        className="w-7 h-7 rounded-md flex items-center justify-center shrink-0 transition-all duration-200"
        style={{
          backgroundColor: isActive ? `${feature.color}18` : 'transparent',
          border: `1px solid ${isActive ? feature.color + '30' : 'transparent'}`,
        }}
      >
        <feature.icon
          className="w-3.5 h-3.5 transition-colors duration-200"
          style={{ color: isActive ? feature.color : '#4a4a4a' }}
        />
      </div>

      {/* Title */}
      <span
        className="text-sm font-display font-semibold flex-1 leading-tight transition-colors duration-200"
        style={{ color: isActive ? '#f5f5f5' : '#737373' }}
      >
        {feature.title}
      </span>

      {/* Arrow */}
      <motion.div
        animate={{ x: isActive ? 0 : -6, opacity: isActive ? 1 : 0 }}
        transition={{ duration: 0.2 }}
        className="shrink-0"
      >
        <ArrowRight className="w-3.5 h-3.5" style={{ color: feature.color }} />
      </motion.div>
    </button>
  )
}

function FeaturePanel({ feature, index }: { feature: typeof FEATURES[number]; index: number }) {
  const extras = FEATURE_EXTRAS[index] ?? []

  return (
    <div className="relative h-full flex flex-col p-10 xl:p-14 overflow-hidden">
      <div
        className="absolute inset-0 pointer-events-none"
        style={{
          background: `radial-gradient(ellipse 55% 45% at 85% 25%, ${feature.color}0d 0%, transparent 65%)`,
        }}
      />

      {/* Large ghosted number */}
      <div
        className="absolute right-8 top-6 font-display font-black leading-none select-none pointer-events-none"
        style={{ fontSize: 'clamp(80px, 12vw, 160px)', color: feature.color, opacity: 0.04 }}
      >
        {String(index + 1).padStart(2, '0')}
      </div>

      {/* Tag */}
      <div className="relative z-10">
        <span
          className="inline-flex px-3 py-1.5 rounded-full text-[11px] font-mono font-bold uppercase tracking-widest"
          style={{
            color: feature.color,
            backgroundColor: `${feature.color}14`,
            border: `1px solid ${feature.color}28`,
          }}
        >
          {feature.tag}
        </span>
      </div>

      {/* Main content */}
      <div className="relative z-10 flex flex-col justify-center flex-1 mt-6">
        {/* Icon orb */}
        <div className="relative self-start mb-6">
          <div
            className="absolute inset-0 rounded-2xl blur-2xl"
            style={{ backgroundColor: feature.color, opacity: 0.22, transform: 'scale(1.6)' }}
          />
          <div
            className="relative w-16 h-16 rounded-2xl flex items-center justify-center"
            style={{
              background: `linear-gradient(135deg, ${feature.color}30 0%, ${feature.color}0e 100%)`,
              border: `1.5px solid ${feature.color}38`,
            }}
          >
            <feature.icon className="w-8 h-8" style={{ color: feature.color }} />
          </div>
        </div>

        <h3
          className="text-display-md font-display font-extrabold text-white leading-tight"
          style={{ letterSpacing: '-0.025em' }}
        >
          {feature.title}
        </h3>

        <p className="text-neutral-300 text-lg leading-relaxed mt-4 max-w-md">
          {feature.description}
        </p>

        {extras.length > 0 && (
          <div className="flex flex-wrap gap-2 mt-8">
            {extras.map((label, i) => (
              <motion.span
                key={label}
                initial={{ opacity: 0, y: 8 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: i * 0.07, duration: 0.3 }}
                className="px-3.5 py-1.5 rounded-full text-[12px] font-mono font-medium"
                style={{
                  color: feature.color,
                  backgroundColor: `${feature.color}10`,
                  border: `1px solid ${feature.color}22`,
                }}
              >
                {label}
              </motion.span>
            ))}
          </div>
        )}
      </div>

      <div
        className="relative z-10 h-px mt-8 rounded-full"
        style={{
          background: `linear-gradient(90deg, ${feature.color}55 0%, ${feature.color}12 55%, transparent 100%)`,
        }}
      />
    </div>
  )
}

function MobileFeatureCard({ feature, index }: { feature: typeof FEATURES[number]; index: number }) {
  const [hovered, setHovered] = useState(false)

  return (
    <SpotlightCard spotlightColor="rgba(99,102,241,0.15)" className="rounded-2xl">
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      className="relative rounded-2xl p-6 overflow-hidden transition-all duration-300"
      style={{
        backgroundColor: hovered ? `${feature.color}07` : '#0f0f11',
        border: `1px solid ${hovered ? feature.color + '28' : 'rgba(255,255,255,0.06)'}`,
      }}
    >
      <div
        className="absolute inset-0 pointer-events-none transition-opacity duration-300"
        style={{
          background: `radial-gradient(circle at 70% 20%, ${feature.color}09 0%, transparent 60%)`,
          opacity: hovered ? 1 : 0.5,
        }}
      />
      <div className="relative z-10">
        <div className="flex items-center justify-between mb-4">
          <span
            className="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest"
            style={{
              color: feature.color,
              backgroundColor: `${feature.color}14`,
              border: `1px solid ${feature.color}25`,
            }}
          >
            {feature.tag}
          </span>
          <span className="text-[10px] font-mono font-bold opacity-20" style={{ color: feature.color }}>
            {String(index + 1).padStart(2, '0')}
          </span>
        </div>
        <div
          className="w-11 h-11 rounded-xl flex items-center justify-center mb-4 transition-all duration-300"
          style={{
            background: `linear-gradient(135deg, ${feature.color}25 0%, ${feature.color}08 100%)`,
            border: `1.5px solid ${feature.color}30`,
          }}
        >
          <feature.icon className="w-5 h-5" style={{ color: feature.color }} />
        </div>
        <h3 className="text-base font-display font-bold text-white mb-2">{feature.title}</h3>
        <p className="text-neutral-500 text-sm leading-relaxed">{feature.description}</p>
      </div>
    </div>
    </SpotlightCard>
  )
}
