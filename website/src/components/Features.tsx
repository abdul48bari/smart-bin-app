'use client'

import { useRef, useState, useEffect } from 'react'
import { motion, useMotionValue, useTransform, useSpring, AnimatePresence } from 'framer-motion'
import { FEATURES } from '@/lib/constants'

// Unique animated backgrounds for each card
function CardBackground({ color, type }: { color: string; type: number }) {
  if (type === 0) {
    // Animated bar chart for Analytics
    return (
      <div className="absolute bottom-0 right-0 w-48 h-36 opacity-10 pointer-events-none">
        <div className="flex items-end gap-2 h-full pb-4 pr-4">
          {[60, 85, 45, 90, 70, 95, 55].map((h, i) => (
            <motion.div
              key={i}
              className="flex-1 rounded-t-sm"
              style={{ backgroundColor: color }}
              initial={{ height: '10%' }}
              animate={{ height: `${h}%` }}
              transition={{ duration: 1.2, delay: i * 0.1, repeat: Infinity, repeatType: 'reverse', ease: 'easeInOut' }}
            />
          ))}
        </div>
      </div>
    )
  }
  if (type === 1) {
    // Animated camera scan grid for AI Classification
    return (
      <div className="absolute inset-0 opacity-[0.06] pointer-events-none overflow-hidden">
        <svg className="absolute inset-0 w-full h-full" viewBox="0 0 200 200">
          <defs>
            <pattern id={`grid-${color.replace('#', '')}`} width="20" height="20" patternUnits="userSpaceOnUse">
              <path d="M 20 0 L 0 0 0 20" fill="none" stroke={color} strokeWidth="0.5" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill={`url(#grid-${color.replace('#', '')})`} />
          <motion.rect
            x="60" y="60" width="80" height="80"
            fill="none" stroke={color} strokeWidth="1.5"
            strokeDasharray="8 4"
            animate={{ rotate: [0, 90, 180, 270, 360] }}
            transition={{ duration: 8, repeat: Infinity, ease: 'linear' }}
            style={{ originX: '100px', originY: '100px' }}
          />
        </svg>
      </div>
    )
  }
  if (type === 2) {
    // Neural network nodes for Smart Analytics
    return (
      <div className="absolute inset-0 opacity-[0.08] pointer-events-none overflow-hidden">
        <svg className="absolute inset-0 w-full h-full" viewBox="0 0 200 200">
          {[[40, 80], [40, 120], [100, 60], [100, 100], [100, 140], [160, 80], [160, 120]].map(([cx, cy], i) => (
            <motion.circle
              key={i} cx={cx} cy={cy} r="5" fill={color}
              animate={{ r: [5, 7, 5], opacity: [0.6, 1, 0.6] }}
              transition={{ duration: 2, delay: i * 0.3, repeat: Infinity }}
            />
          ))}
          {[[0, 1], [0, 2], [1, 3], [2, 3], [2, 4], [3, 5], [3, 6], [4, 5], [4, 6]].map(([a, b], i) => {
            const nodes = [[40, 80], [40, 120], [100, 60], [100, 100], [100, 140], [160, 80], [160, 120]]
            return (
              <motion.line key={i} x1={nodes[a][0]} y1={nodes[a][1]} x2={nodes[b][0]} y2={nodes[b][1]}
                stroke={color} strokeWidth="0.8"
                animate={{ opacity: [0.3, 0.8, 0.3] }}
                transition={{ duration: 2, delay: i * 0.2, repeat: Infinity }}
              />
            )
          })}
        </svg>
      </div>
    )
  }
  if (type === 3) {
    // Sound wave for Voice
    return (
      <div className="absolute bottom-0 right-0 w-40 h-24 opacity-10 pointer-events-none overflow-hidden">
        <div className="flex items-center gap-[3px] h-full px-4">
          {[20, 45, 70, 95, 60, 80, 40, 90, 55, 75, 35, 65].map((h, i) => (
            <motion.div
              key={i}
              className="w-[3px] flex-shrink-0 rounded-full"
              style={{ backgroundColor: color }}
              animate={{ height: [`${h * 0.3}%`, `${h}%`, `${h * 0.3}%`] }}
              transition={{ duration: 0.8, delay: i * 0.07, repeat: Infinity, ease: 'easeInOut' }}
            />
          ))}
        </div>
      </div>
    )
  }
  if (type === 4) {
    // Notification bell rings for Alerts
    return (
      <div className="absolute top-4 right-4 opacity-[0.08] pointer-events-none">
        {[0, 1, 2].map(i => (
          <motion.div
            key={i}
            className="absolute rounded-full border-2"
            style={{ borderColor: color, width: 40 + i * 28, height: 40 + i * 28, top: -(i * 14), left: -(i * 14) }}
            animate={{ scale: [1, 1.3, 1], opacity: [0.8, 0, 0.8] }}
            transition={{ duration: 2, delay: i * 0.4, repeat: Infinity }}
          />
        ))}
      </div>
    )
  }
  // Shield hexagon pattern for Security
  return (
    <div className="absolute inset-0 opacity-[0.05] pointer-events-none overflow-hidden">
      <svg className="absolute right-0 bottom-0 w-40 h-40" viewBox="0 0 100 100">
        <polygon points="50,5 95,27.5 95,72.5 50,95 5,72.5 5,27.5" fill="none" stroke={color} strokeWidth="1.5" />
        <polygon points="50,18 82,34 82,66 50,82 18,66 18,34" fill="none" stroke={color} strokeWidth="1" />
        <polygon points="50,32 70,42 70,58 50,68 30,58 30,42" fill={color} fillOpacity="0.3" stroke="none" />
      </svg>
    </div>
  )
}

export default function Features() {
  return (
    <section id="features" className="py-28 md:py-40 relative overflow-hidden">
      {/* Ambient orbs */}
      <div className="absolute inset-0 pointer-events-none">
        <motion.div
          className="absolute top-[-100px] left-1/4 w-[700px] h-[700px] rounded-full blur-3xl opacity-[0.07]"
          style={{ background: 'radial-gradient(circle, #6366f1 0%, transparent 70%)' }}
          animate={{ scale: [1, 1.1, 1], x: [0, 30, 0] }}
          transition={{ duration: 12, repeat: Infinity, ease: 'easeInOut' }}
        />
        <motion.div
          className="absolute bottom-[-100px] right-1/4 w-[600px] h-[600px] rounded-full blur-3xl opacity-[0.07]"
          style={{ background: 'radial-gradient(circle, #14B8A6 0%, transparent 70%)' }}
          animate={{ scale: [1, 1.15, 1], x: [0, -20, 0] }}
          transition={{ duration: 10, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
        />
        {/* Dot grid */}
        <svg className="absolute inset-0 w-full h-full opacity-[0.035]" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="featureDots2" x="0" y="0" width="28" height="28" patternUnits="userSpaceOnUse">
              <circle cx="1" cy="1" r="1.2" fill="currentColor" />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#featureDots2)" className="text-white" />
        </svg>
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-6 mb-14"
        >
          <div className="max-w-2xl">
            <span className="section-label">Features</span>
            <h2 className="text-display-lg font-display font-extrabold mt-4">
              Everything you need to{' '}
              <span className="gradient-text">manage waste</span>
              {' '}intelligently.
            </h2>
          </div>
          <p className="text-neutral-400 text-base leading-relaxed max-w-xs">
            Six powerful capabilities working together — from AI to alerts.
          </p>
        </motion.div>

        {/* Bento Grid — Row 1: Analytics (tall) + AI + Smart Analytics */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {/* Card 0: Analytics — tall left col */}
          <motion.div
            className="lg:row-span-2 min-h-[280px] lg:min-h-[520px]"
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0 }}
          >
            <BentoCard feature={FEATURES[0]} index={0} tall />
          </motion.div>

          {/* Cards 1 & 2: normal top-right */}
          {[1, 2].map((fi, i) => (
            <motion.div
              key={fi}
              className="min-h-[250px]"
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: (i + 1) * 0.09 }}
            >
              <BentoCard feature={FEATURES[fi]} index={fi} />
            </motion.div>
          ))}

          {/* Card 3: Voice — wide, spans 2 cols on lg, natural height */}
          <motion.div
            className="md:col-span-2 lg:col-span-2 min-h-[280px]"
            initial={{ opacity: 0, y: 50 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.36 }}
          >
            <BentoCard feature={FEATURES[3]} index={3} wide />
          </motion.div>

          {/* Cards 4 & 5: normal bottom */}
          {[4, 5].map((fi, i) => (
            <motion.div
              key={fi}
              className="min-h-[250px]"
              initial={{ opacity: 0, y: 50 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: (i + 4) * 0.09 }}
            >
              <BentoCard feature={FEATURES[fi]} index={fi} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

function BentoCard({
  feature,
  index,
  tall = false,
  wide = false,
}: {
  feature: typeof FEATURES[number]
  index: number
  tall?: boolean
  wide?: boolean
}) {
  const ref = useRef<HTMLDivElement>(null)
  const [isHovered, setIsHovered] = useState(false)

  const mouseX = useMotionValue(0)
  const mouseY = useMotionValue(0)
  const rotateX = useSpring(useTransform(mouseY, [-0.5, 0.5], [6, -6]), { stiffness: 300, damping: 30 })
  const rotateY = useSpring(useTransform(mouseX, [-0.5, 0.5], [-6, 6]), { stiffness: 300, damping: 30 })
  // Spotlight: track mouse position for per-card radial highlight
  const spotX = useMotionValue(50)
  const spotY = useMotionValue(50)

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!ref.current) return
    const rect = ref.current.getBoundingClientRect()
    const x = (e.clientX - rect.left) / rect.width
    const y = (e.clientY - rect.top) / rect.height
    mouseX.set(x - 0.5)
    mouseY.set(y - 0.5)
    spotX.set(x * 100)
    spotY.set(y * 100)
  }

  const handleMouseLeave = () => {
    mouseX.set(0)
    mouseY.set(0)
    spotX.set(50)
    spotY.set(50)
    setIsHovered(false)
  }

  return (
    <motion.div
      ref={ref}
      onMouseMove={handleMouseMove}
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={handleMouseLeave}
      style={{ perspective: '1200px', height: '100%' }}
    >
      <motion.div
        style={{ rotateX, rotateY, transformStyle: 'preserve-3d', height: '100%' }}
        className="relative rounded-2xl overflow-hidden group cursor-pointer h-full"
      >
        {/* Base layer */}
        <div
          className="absolute inset-0 rounded-2xl transition-all duration-500"
          style={{
            background: isHovered
              ? `linear-gradient(135deg, ${feature.color}10 0%, ${feature.color}05 100%)`
              : 'var(--bento-bg)',
            backgroundColor: '#111113',
          }}
        />

        {/* Border */}
        <div
          className="absolute inset-0 rounded-2xl border transition-all duration-500 pointer-events-none"
          style={{
            borderColor: isHovered ? `${feature.color}40` : 'rgba(255,255,255,0.07)',
          }}
        />

        {/* Mouse spotlight */}
        <motion.div
          className="absolute inset-0 rounded-2xl pointer-events-none opacity-0 group-hover:opacity-100 transition-opacity duration-300"
          style={{
            background: useTransform(
              [spotX, spotY],
              ([x, y]) =>
                `radial-gradient(circle 180px at ${x}% ${y}%, ${feature.color}18 0%, transparent 70%)`
            ),
          }}
        />

        {/* Unique card background illustration */}
        <CardBackground color={feature.color} type={index} />

        {/* Top shimmer line */}
        <div
          className="absolute top-0 left-0 right-0 h-px opacity-0 group-hover:opacity-100 transition-opacity duration-500"
          style={{
            background: `linear-gradient(90deg, transparent 0%, ${feature.color}80 50%, transparent 100%)`,
          }}
        />

        {/* Content */}
        <div className={`relative z-10 flex flex-col h-full p-7 ${tall ? 'gap-4' : 'gap-3'}`}>
          {/* Top: tag + number */}
          <div className="flex items-center justify-between">
            <span
              className="px-2.5 py-1 rounded-full text-[10px] font-mono font-bold uppercase tracking-widest"
              style={{
                color: feature.color,
                backgroundColor: `${feature.color}15`,
                border: `1px solid ${feature.color}25`,
              }}
            >
              {feature.tag}
            </span>
            <span
              className="text-xs font-mono font-bold opacity-20 select-none"
              style={{ color: feature.color }}
            >
              {String(index + 1).padStart(2, '0')}
            </span>
          </div>

          {/* Icon */}
          <motion.div
            animate={{ scale: isHovered ? 1.1 : 1 }}
            transition={{ type: 'spring', stiffness: 350, damping: 22 }}
            className="relative self-start"
          >
            {/* Glow bloom */}
            <div
              className="absolute inset-0 rounded-xl blur-lg transition-all duration-500"
              style={{
                backgroundColor: feature.color,
                opacity: isHovered ? 0.5 : 0.15,
                transform: 'scale(1.6)',
              }}
            />
            <div
              className="relative w-14 h-14 rounded-xl flex items-center justify-center"
              style={{
                background: `linear-gradient(135deg, ${feature.color}30 0%, ${feature.color}10 100%)`,
                border: `1.5px solid ${feature.color}35`,
                boxShadow: isHovered ? `0 8px 32px -4px ${feature.color}40` : 'none',
              }}
            >
              <feature.icon className="w-6 h-6" style={{ color: feature.color }} />
            </div>
          </motion.div>

          {/* Title + description */}
          <div className="mt-auto">
            <h3
              className={`font-display font-bold text-white mb-2 ${tall ? 'text-2xl' : 'text-xl'}`}
            >
              {feature.title}
            </h3>
            <p
              className={`text-neutral-400 leading-relaxed ${tall ? 'text-base' : 'text-sm'}`}
            >
              {feature.description}
            </p>
          </div>

          {/* Bottom: animated progress bar on tall cards */}
          {tall && (
            <div className="mt-2">
              <div className="flex justify-between text-[10px] font-mono text-neutral-400 mb-1">
                <span>Accuracy</span>
                <span style={{ color: feature.color }}>99.2%</span>
              </div>
              <div className="h-1.5 rounded-full bg-neutral-800 overflow-hidden">
                <motion.div
                  className="h-full rounded-full"
                  style={{ backgroundColor: feature.color }}
                  initial={{ width: '0%' }}
                  whileInView={{ width: '99.2%' }}
                  viewport={{ once: true }}
                  transition={{ duration: 1.5, ease: 'easeOut', delay: 0.3 }}
                />
              </div>
            </div>
          )}

          {/* Wide card extra: stat pills */}
          {wide && (
            <div className="flex flex-wrap gap-2 mt-1">
              {['Hands-free', 'Multi-language', 'Always-on'].map((label) => (
                <span
                  key={label}
                  className="px-3 py-1 rounded-full text-[11px] font-medium"
                  style={{
                    backgroundColor: `${feature.color}12`,
                    color: feature.color,
                    border: `1px solid ${feature.color}20`,
                  }}
                >
                  {label}
                </span>
              ))}
            </div>
          )}
        </div>

        {/* Bottom border accent */}
        <motion.div
          className="absolute bottom-0 left-4 right-4 h-[2px] rounded-full"
          style={{ backgroundColor: feature.color }}
          initial={{ scaleX: 0, originX: 0 }}
          animate={{ scaleX: isHovered ? 1 : 0 }}
          transition={{ duration: 0.4, ease: 'easeOut' }}
        />

        {/* Scan-line sweep */}
        <AnimatePresence>
          {isHovered && (
            <motion.div
              key="scanline"
              className="absolute left-0 right-0 h-[1.5px] pointer-events-none"
              style={{
                background: `linear-gradient(90deg, transparent, ${feature.color}90, transparent)`,
                zIndex: 20,
              }}
              initial={{ top: '0%', opacity: 0 }}
              animate={{ top: ['0%', '100%'], opacity: [0, 1, 0] }}
              exit={{ opacity: 0 }}
              transition={{ duration: 0.7, ease: 'easeInOut' }}
            />
          )}
        </AnimatePresence>
      </motion.div>
    </motion.div>
  )
}
