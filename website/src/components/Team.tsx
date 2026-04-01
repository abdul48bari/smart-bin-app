'use client'

import { useState, useEffect, useRef, useCallback } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { TEAM } from '@/lib/constants'

const ROLE_SKILLS: Record<string, string[]> = {
  'System Architect': ['Architecture', 'System Design', 'Review'],
  'Mobile & Web Developer': ['Flutter', 'Dart', 'Next.js', 'UI/UX'],
  'Backend Developer': ['Firebase', 'API', 'Database'],
  'Hardware Engineer': ['Electronics', 'Assembly', 'PCB'],
  'IoT Developer': ['Raspberry Pi', 'Python', 'Sensors'],
  'AI/ML Engineer': ['TensorFlow', 'CNN', 'Computer Vision'],
  'Data & AI Engineer': ['Datasets', 'Model Training', 'AI'],
}

const ROTATION_MS = 2600

export default function Team() {
  const [autoIndex, setAutoIndex] = useState(0)
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  // Paused when any row is hovered
  const paused = hoveredIndex !== null
  // The currently expanded member
  const expandedIndex = hoveredIndex !== null ? hoveredIndex : autoIndex

  const startRotation = useCallback(() => {
    if (intervalRef.current) clearInterval(intervalRef.current)
    intervalRef.current = setInterval(() => {
      setAutoIndex(prev => (prev + 1) % TEAM.length)
    }, ROTATION_MS)
  }, [])

  const stopRotation = useCallback(() => {
    if (intervalRef.current) clearInterval(intervalRef.current)
    intervalRef.current = null
  }, [])

  useEffect(() => {
    if (!paused) {
      startRotation()
    } else {
      stopRotation()
    }
    return stopRotation
  }, [paused, startRotation, stopRotation])

  return (
    <section id="team" className="py-14 md:py-20 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          className="flex flex-col md:flex-row md:items-end md:justify-between gap-6 mb-10"
        >
          <div>
            <span className="section-label">Team</span>
            <h2 className="text-display-lg font-display font-extrabold mt-4">
              The minds behind{' '}
              <span className="gradient-text">Reclevo.</span>
            </h2>
          </div>
          <div className="flex flex-col items-start md:items-end gap-2">
            <p className="text-neutral-300 text-sm max-w-xs leading-relaxed">
              7 engineers across hardware, AI, cloud, and mobile.
            </p>
            {/* Auto status pill */}
            <div className="flex items-center gap-2">
              <span
                className="w-1.5 h-1.5 rounded-full"
                style={{
                  backgroundColor: paused ? '#6366f1' : '#22c55e',
                  boxShadow: paused ? 'none' : '0 0 6px #22c55e',
                  animation: paused ? 'none' : 'pulse 2s infinite',
                }}
              />
              <span className="text-[10px] font-mono uppercase tracking-widest text-neutral-600">
                {paused ? 'Paused' : 'Auto-cycling'}
              </span>
            </div>
          </div>
        </motion.div>

        {/* Film credits masthead */}
        <div>
          <motion.div
            initial={{ scaleX: 0 }}
            whileInView={{ scaleX: 1 }}
            viewport={{ once: true }}
            transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
            className="h-px bg-neutral-800/70 origin-left"
          />

          {TEAM.map((member, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.07, ease: [0.16, 1, 0.3, 1] }}
            >
              <CreditRow
                member={member}
                index={i}
                isExpanded={expandedIndex === i}
                isPaused={paused}
                onHover={() => setHoveredIndex(i)}
                onLeave={() => setHoveredIndex(null)}
              />
            </motion.div>
          ))}

          <div className="h-px bg-neutral-800/70" />
        </div>
      </div>
    </section>
  )
}

function CreditRow({
  member,
  index,
  isExpanded,
  isPaused,
  onHover,
  onLeave,
}: {
  member: typeof TEAM[number]
  index: number
  isExpanded: boolean
  isPaused: boolean
  onHover: () => void
  onLeave: () => void
}) {
  const skills = ROLE_SKILLS[member.role] ?? []
  const Icon = member.icon

  return (
    <div
      onMouseEnter={onHover}
      onMouseLeave={onLeave}
      className="relative border-b border-neutral-800/40 overflow-hidden cursor-default"
    >
      {/* Auto-progress timer bar at bottom of row — resets each cycle */}
      <div className="absolute bottom-0 left-0 right-0 h-[1.5px] overflow-hidden">
        {isExpanded && !isPaused && (
          <motion.div
            key={`${index}-timer`}
            className="h-full origin-left"
            style={{ backgroundColor: member.color }}
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ duration: ROTATION_MS / 1000, ease: 'linear' }}
          />
        )}
      </div>

      {/* Full-row color sweep */}
      <motion.div
        className="absolute inset-0 pointer-events-none"
        animate={{ opacity: isExpanded ? 1 : 0 }}
        transition={{ duration: 0.4 }}
        style={{
          background: `linear-gradient(105deg, ${member.color}0c 0%, ${member.color}04 30%, transparent 60%)`,
        }}
      />

      {/* Left accent bar */}
      <motion.div
        className="absolute left-0 top-0 bottom-0 w-[2px]"
        style={{ backgroundColor: member.color, transformOrigin: 'bottom' }}
        animate={{ scaleY: isExpanded ? 1 : 0 }}
        initial={{ scaleY: 0 }}
        transition={{ duration: 0.35, ease: [0.16, 1, 0.3, 1] }}
      />

      {/* Primary row — name + index + role */}
      <div className="flex items-baseline gap-4 md:gap-8 py-6 md:py-8 pl-4 md:pl-5 pr-2">
        {/* Index */}
        <motion.span
          className="text-xs font-mono tabular-nums flex-shrink-0 hidden sm:block"
          animate={{ color: isExpanded ? member.color : 'rgba(255,255,255,0.1)' }}
          transition={{ duration: 0.25 }}
        >
          {String(index + 1).padStart(2, '0')}
        </motion.span>

        {/* Name — hero element */}
        <motion.h3
          className="flex-1 font-display font-black leading-none tracking-tight"
          animate={{ color: isExpanded ? '#ffffff' : '#b5b5b5' }}
          transition={{ duration: 0.22 }}
          style={{ fontSize: 'clamp(1.75rem, 4.5vw, 3.5rem)', letterSpacing: '-0.025em' }}
        >
          <motion.span
            animate={{ color: isExpanded ? member.color : 'inherit' }}
            transition={{ duration: 0.22 }}
          >
            {member.name[0]}
          </motion.span>
          {member.name.slice(1)}
        </motion.h3>

        {/* Role + Icon */}
        <div className="flex items-center gap-3 flex-shrink-0">
          <motion.span
            className="text-[10px] md:text-[11px] font-mono uppercase tracking-[0.2em] leading-tight text-right"
            animate={{ color: isExpanded ? member.color : '#2e2e2e' }}
            transition={{ duration: 0.25 }}
          >
            {member.role}
          </motion.span>
          <motion.div
            animate={{ rotate: isExpanded ? 12 : 0, color: isExpanded ? member.color : '#1e1e1e' }}
            transition={{ type: 'spring', stiffness: 350, damping: 18 }}
          >
            <Icon className="w-4 h-4 md:w-5 md:h-5 flex-shrink-0" strokeWidth={1.5} />
          </motion.div>
        </div>
      </div>

      {/* Expandable detail */}
      <AnimatePresence>
        {isExpanded && (
          <motion.div
            initial={{ height: 0, opacity: 0 }}
            animate={{ height: 'auto', opacity: 1 }}
            exit={{ height: 0, opacity: 0 }}
            transition={{ duration: 0.32, ease: [0.16, 1, 0.3, 1] }}
            className="overflow-hidden"
          >
            <div className="flex flex-wrap items-start gap-6 md:gap-10 pb-7 pl-4 md:pl-[calc(2rem+1px)] pr-4">
              <p className="text-neutral-300 text-sm leading-relaxed max-w-sm">
                {member.description}
              </p>
              <div className="flex flex-wrap gap-2">
                {skills.map((skill, j) => (
                  <motion.span
                    key={j}
                    initial={{ opacity: 0, scale: 0.9 }}
                    animate={{ opacity: 1, scale: 1 }}
                    transition={{ delay: j * 0.05, duration: 0.2 }}
                    className="px-3 py-1.5 rounded-full text-[11px] font-mono uppercase tracking-wider"
                    style={{
                      color: member.color,
                      backgroundColor: `${member.color}0e`,
                      border: `1px solid ${member.color}25`,
                    }}
                  >
                    {skill}
                  </motion.span>
                ))}
              </div>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </div>
  )
}
