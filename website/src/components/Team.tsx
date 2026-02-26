'use client'

import { useRef, useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { TEAM } from '@/lib/constants'

// Role-specific skill tags for back of card
const ROLE_SKILLS: Record<string, string[]> = {
  'System Architect': ['Architecture', 'System Design', 'Review'],
  'Mobile Developer': ['Flutter', 'Dart', 'UI/UX'],
  'Backend Developer': ['Firebase', 'API', 'Database'],
  'Hardware Engineer': ['Electronics', 'Assembly', 'PCB'],
  'IoT Developer': ['Raspberry Pi', 'Python', 'Sensors'],
  'AI/ML Engineer': ['TensorFlow', 'CNN', 'Computer Vision'],
  'Data & AI Engineer': ['Datasets', 'Model Training', 'AI'],
}

// Role-specific emoji
const ROLE_EMOJI: Record<string, string> = {
  'System Architect': '🏗️',
  'Mobile Developer': '📱',
  'Backend Developer': '⚙️',
  'Hardware Engineer': '🔧',
  'IoT Developer': '🤖',
  'AI/ML Engineer': '🧠',
  'Data & AI Engineer': '📊',
}

export default function Team() {
  return (
    <section id="team" className="py-28 md:py-40 relative overflow-hidden">
      {/* Constellation background */}
      <ConstellationBackground />

      {/* Ambient orbs */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-0 left-1/3 w-[600px] h-[600px] rounded-full opacity-[0.05] blur-3xl"
          style={{ background: 'radial-gradient(circle, #6366f1 0%, transparent 70%)' }}
        />
        <div
          className="absolute bottom-0 right-1/4 w-[500px] h-[500px] rounded-full opacity-[0.05] blur-3xl"
          style={{ background: 'radial-gradient(circle, #10B981 0%, transparent 70%)' }}
        />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="flex flex-col md:flex-row md:items-end md:justify-between gap-6 mb-16 md:mb-20"
        >
          <div className="max-w-2xl">
            <span className="section-label">Team</span>
            <h2 className="text-display-lg font-display font-extrabold mt-4">
              The minds behind{' '}
              <span className="gradient-text">Reclevo.</span>
            </h2>
          </div>
          <div className="flex flex-col gap-1 md:text-right">
            <span
              className="text-[80px] md:text-[100px] font-display font-extrabold leading-none select-none"
              style={{
                background: 'linear-gradient(135deg, #6366f1 0%, #14B8A6 100%)',
                WebkitBackgroundClip: 'text',
                WebkitTextFillColor: 'transparent',
                backgroundClip: 'text',
                opacity: 0.15,
              }}
            >
              7
            </span>
            <p className="text-neutral-400 text-sm leading-relaxed max-w-xs md:ml-auto">
              A passionate team of engineers building the future of smart waste management.
            </p>
          </div>
        </motion.div>

        {/* Hint text */}
        <motion.p
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="text-xs font-mono text-neutral-600 uppercase tracking-widest mb-8 flex items-center gap-2"
        >
          <span className="inline-block w-4 h-px bg-neutral-700" />
          Hover to reveal role details
        </motion.p>

        {/* Top row - 3 */}
        <div className="grid md:grid-cols-3 gap-5 mb-5">
          {TEAM.slice(0, 3).map((member, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.08 }}
            >
              <TeamCard member={member} />
            </motion.div>
          ))}
        </div>

        {/* Bottom row - 4 */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {TEAM.slice(3).map((member, i) => (
            <motion.div
              key={i + 3}
              initial={{ opacity: 0, y: 40 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: (i + 3) * 0.08 }}
            >
              <TeamCard member={member} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

function TeamCard({ member }: { member: typeof TEAM[number] }) {
  const [isFlipped, setIsFlipped] = useState(false)
  const skills = ROLE_SKILLS[member.role] ?? []
  const emoji = ROLE_EMOJI[member.role] ?? '⭐'

  return (
    <div
      className="relative h-[260px] cursor-pointer"
      style={{ perspective: '1200px' }}
      onMouseEnter={() => setIsFlipped(true)}
      onMouseLeave={() => setIsFlipped(false)}
    >
      <motion.div
        className="relative w-full h-full"
        style={{ transformStyle: 'preserve-3d' }}
        animate={{ rotateY: isFlipped ? 180 : 0 }}
        transition={{ type: 'spring', stiffness: 260, damping: 28 }}
      >
        {/* === FRONT === */}
        <div
          className="absolute inset-0 rounded-2xl overflow-hidden"
          style={{ backfaceVisibility: 'hidden', WebkitBackfaceVisibility: 'hidden' }}
        >
          <div className="w-full h-full relative p-6 text-center flex flex-col items-center justify-center bg-neutral-900 border border-neutral-800 rounded-2xl">
            {/* Glow bg */}
            <div
              className="absolute inset-0 rounded-2xl opacity-[0.06] transition-opacity duration-300"
              style={{ background: `radial-gradient(circle at 50% 30%, ${member.color} 0%, transparent 60%)` }}
            />

            {/* Avatar */}
            <div className="relative mb-4">
              {/* Pulse rings */}
              <motion.div
                className="absolute inset-[-8px] rounded-2xl"
                style={{ border: `1px solid ${member.color}30` }}
                animate={{ scale: [1, 1.15, 1], opacity: [0.5, 0, 0.5] }}
                transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut' }}
              />
              <motion.div
                className="absolute inset-[-16px] rounded-2xl"
                style={{ border: `1px solid ${member.color}20` }}
                animate={{ scale: [1, 1.2, 1], opacity: [0.3, 0, 0.3] }}
                transition={{ duration: 3, repeat: Infinity, ease: 'easeInOut', delay: 0.5 }}
              />

              <div
                className="w-16 h-16 rounded-2xl flex items-center justify-center text-white font-display font-bold text-lg relative z-10"
                style={{
                  background: `linear-gradient(135deg, ${member.color} 0%, ${member.color}cc 100%)`,
                  boxShadow: `0 8px 30px -4px ${member.color}50`,
                }}
              >
                {member.initials}
              </div>
            </div>

            <h3 className="text-lg font-display font-bold text-white">
              {member.name}
            </h3>
            <p className="text-xs font-mono uppercase tracking-wider mt-1" style={{ color: member.color }}>
              {member.role}
            </p>
            <p className="text-neutral-400 text-sm mt-3 leading-relaxed text-center px-2">
              {member.description}
            </p>

            {/* Bottom line */}
            <div
              className="absolute bottom-0 left-0 right-0 h-[2px] rounded-full"
              style={{
                background: `linear-gradient(90deg, transparent, ${member.color}60, transparent)`,
              }}
            />

            {/* Flip hint */}
            <div className="absolute top-3 right-3 opacity-30">
              <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                <path d="M3 2v6h6M21 22v-6h-6M3 13a9 9 0 0 0 15 6.7M21 11A9 9 0 0 0 6 4.3" />
              </svg>
            </div>
          </div>
        </div>

        {/* === BACK === */}
        <div
          className="absolute inset-0 rounded-2xl overflow-hidden"
          style={{
            backfaceVisibility: 'hidden',
            WebkitBackfaceVisibility: 'hidden',
            transform: 'rotateY(180deg)',
          }}
        >
          <div
            className="w-full h-full flex flex-col items-center justify-center p-6 rounded-2xl text-center"
            style={{
              background: `linear-gradient(135deg, ${member.color}18 0%, ${member.color}08 100%)`,
              border: `1px solid ${member.color}30`,
            }}
          >
            <span className="text-4xl mb-3">{emoji}</span>
            <h3
              className="text-xl font-display font-bold mb-1"
              style={{ color: member.color }}
            >
              {member.name}
            </h3>
            <p className="text-xs font-mono uppercase tracking-widest text-neutral-400 mb-5">
              {member.role}
            </p>

            {/* Skill tags */}
            <div className="flex flex-wrap gap-2 justify-center">
              {skills.map((skill, j) => (
                <motion.span
                  key={j}
                  initial={{ opacity: 0, scale: 0.7 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: j * 0.07, duration: 0.3 }}
                  className="px-3 py-1 rounded-full text-[10px] font-mono font-semibold uppercase tracking-wider"
                  style={{
                    backgroundColor: `${member.color}20`,
                    color: member.color,
                    border: `1px solid ${member.color}30`,
                  }}
                >
                  {skill}
                </motion.span>
              ))}
            </div>

            {/* Glow line */}
            <div
              className="absolute bottom-0 left-0 right-0 h-[2px] rounded-full"
              style={{ backgroundColor: member.color }}
            />
          </div>
        </div>
      </motion.div>
    </div>
  )
}

// Constellation dots background
function ConstellationBackground() {
  const canvasRef = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    if (!ctx) return

    let animId: number

    const resize = () => {
      canvas.width = canvas.offsetWidth
      canvas.height = canvas.offsetHeight
    }
    resize()
    window.addEventListener('resize', resize)

    const dots: { x: number; y: number; vx: number; vy: number; r: number }[] = []
    const COUNT = 55

    for (let i = 0; i < COUNT; i++) {
      dots.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.25,
        vy: (Math.random() - 0.5) * 0.25,
        r: Math.random() * 1.5 + 0.5,
      })
    }

    const draw = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      const dotColor = 'rgba(255,255,255,0.15)'
      const lineColor = 'rgba(255,255,255,0.04)'

      dots.forEach(d => {
        d.x += d.vx
        d.y += d.vy
        if (d.x < 0) d.x = canvas.width
        if (d.x > canvas.width) d.x = 0
        if (d.y < 0) d.y = canvas.height
        if (d.y > canvas.height) d.y = 0

        ctx.beginPath()
        ctx.arc(d.x, d.y, d.r, 0, Math.PI * 2)
        ctx.fillStyle = dotColor
        ctx.fill()
      })

      for (let i = 0; i < dots.length; i++) {
        for (let j = i + 1; j < dots.length; j++) {
          const dx = dots[i].x - dots[j].x
          const dy = dots[i].y - dots[j].y
          const dist = Math.sqrt(dx * dx + dy * dy)
          if (dist < 120) {
            ctx.beginPath()
            ctx.moveTo(dots[i].x, dots[i].y)
            ctx.lineTo(dots[j].x, dots[j].y)
            ctx.strokeStyle = lineColor
            ctx.lineWidth = 1
            ctx.stroke()
          }
        }
      }

      animId = requestAnimationFrame(draw)
    }

    draw()

    return () => {
      cancelAnimationFrame(animId)
      window.removeEventListener('resize', resize)
    }
  }, [])

  return (
    <canvas
      ref={canvasRef}
      className="absolute inset-0 w-full h-full pointer-events-none"
    />
  )
}
