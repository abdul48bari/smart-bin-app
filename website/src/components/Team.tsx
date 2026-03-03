'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { TEAM } from '@/lib/constants'

const ROLE_SKILLS: Record<string, string[]> = {
  'System Architect': ['Architecture', 'System Design', 'Review'],
  'Mobile Developer': ['Flutter', 'Dart', 'UI/UX'],
  'Backend Developer': ['Firebase', 'API', 'Database'],
  'Hardware Engineer': ['Electronics', 'Assembly', 'PCB'],
  'IoT Developer': ['Raspberry Pi', 'Python', 'Sensors'],
  'AI/ML Engineer': ['TensorFlow', 'CNN', 'Computer Vision'],
  'Data & AI Engineer': ['Datasets', 'Model Training', 'AI'],
}

export default function Team() {
  return (
    <section id="team" className="py-28 md:py-40 relative overflow-hidden">
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

        {/* Top row - 3 */}
        <div className="grid md:grid-cols-3 gap-4 mb-4">
          {TEAM.slice(0, 3).map((member, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: i * 0.08 }}
            >
              <MemberCard member={member} index={i} />
            </motion.div>
          ))}
        </div>

        {/* Bottom row - 4 */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
          {TEAM.slice(3).map((member, i) => (
            <motion.div
              key={i + 3}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: (i + 3) * 0.08 }}
            >
              <MemberCard member={member} index={i + 3} />
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}

function MemberCard({ member, index }: { member: typeof TEAM[number]; index: number }) {
  const [isHovered, setIsHovered] = useState(false)
  const skills = ROLE_SKILLS[member.role] ?? []
  const Icon = member.icon
  const num = String(index + 1).padStart(2, '0')

  return (
    <motion.div
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
      whileHover={{ y: -4 }}
      transition={{ type: 'spring', stiffness: 400, damping: 25 }}
      className="relative group cursor-pointer"
    >
      {/* Card */}
      <div
        className="relative rounded-xl overflow-hidden transition-all duration-500"
        style={{
          backgroundColor: isHovered ? `${member.color}08` : '#111113',
          border: `1px solid ${isHovered ? member.color + '30' : 'rgba(255,255,255,0.06)'}`,
        }}
      >
        {/* Left accent bar */}
        <motion.div
          className="absolute top-0 left-0 w-[3px] rounded-r-full"
          style={{ backgroundColor: member.color }}
          animate={{ height: isHovered ? '100%' : '0%' }}
          transition={{ duration: 0.35, ease: [0.25, 0.46, 0.45, 0.94] }}
        />

        <div className="p-6">
          {/* Top row: Number + Icon */}
          <div className="flex items-center justify-between mb-6">
            <span
              className="text-[11px] font-mono font-semibold tracking-wider transition-colors duration-300"
              style={{ color: isHovered ? member.color : '#525252' }}
            >
              {num}
            </span>
            <motion.div
              animate={{ rotate: isHovered ? 8 : 0 }}
              transition={{ type: 'spring', stiffness: 300, damping: 20 }}
            >
              <Icon
                className="w-[18px] h-[18px] transition-colors duration-300"
                style={{ color: isHovered ? member.color : '#525252' }}
                strokeWidth={1.5}
              />
            </motion.div>
          </div>

          {/* Name — bold, large */}
          <h3 className="text-xl font-display font-bold text-white leading-tight">
            {member.name}
          </h3>

          {/* Role */}
          <p
            className="text-[11px] font-mono uppercase tracking-[0.2em] mt-1.5 transition-colors duration-300"
            style={{ color: isHovered ? member.color : '#737373' }}
          >
            {member.role}
          </p>

          {/* Divider */}
          <div
            className="h-px my-4 transition-all duration-500"
            style={{
              backgroundColor: isHovered ? `${member.color}25` : 'rgba(255,255,255,0.06)',
            }}
          />

          {/* Description */}
          <p className="text-neutral-500 text-[13px] leading-relaxed">
            {member.description}
          </p>

          {/* Skills */}
          <div className="flex flex-wrap gap-1.5 mt-4">
            {skills.map((skill, j) => (
              <motion.span
                key={j}
                initial={false}
                animate={{
                  opacity: isHovered ? 1 : 0.4,
                  y: isHovered ? 0 : 4,
                }}
                transition={{ delay: isHovered ? j * 0.04 : 0, duration: 0.2 }}
                className="text-[10px] font-mono uppercase tracking-wider px-2 py-0.5 rounded transition-colors duration-300"
                style={{
                  color: isHovered ? member.color : '#525252',
                  backgroundColor: isHovered ? `${member.color}10` : 'transparent',
                }}
              >
                {skill}
              </motion.span>
            ))}
          </div>
        </div>
      </div>
    </motion.div>
  )
}
