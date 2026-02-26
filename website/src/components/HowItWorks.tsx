'use client'

import { useRef, useEffect, useState } from 'react'
import { motion, useMotionValue, useSpring, useInView } from 'framer-motion'
import { gsap } from 'gsap'
import { ScrollTrigger } from 'gsap/ScrollTrigger'
import { HOW_IT_WORKS_STEPS } from '@/lib/constants'

if (typeof window !== 'undefined') {
  gsap.registerPlugin(ScrollTrigger)
}

export default function HowItWorks() {
  const timelineRef = useRef<HTMLDivElement>(null)
  const lineRef = useRef<HTMLDivElement>(null)
  // lit[i] = true means the line has reached step i
  const [litSteps, setLitSteps] = useState<boolean[]>(
    new Array(HOW_IT_WORKS_STEPS.length).fill(false)
  )

  useEffect(() => {
    if (!lineRef.current || !timelineRef.current) return

    const ctx = gsap.context(() => {
      // Animate the line drawing itself
      gsap.fromTo(
        lineRef.current,
        { scaleY: 0 },
        {
          scaleY: 1,
          ease: 'none',
          scrollTrigger: {
            trigger: timelineRef.current,
            start: 'top 55%',
            end: 'bottom 55%',
            scrub: 0.8,
            // Fire as it progresses to light up nodes
            onUpdate: (self) => {
              const progress = self.progress
              const total = HOW_IT_WORKS_STEPS.length
              setLitSteps((prev) => {
                const next = [...prev]
                for (let i = 0; i < total; i++) {
                  // Each node is evenly spaced along the timeline
                  const threshold = (i + 0.5) / total
                  next[i] = progress >= threshold
                }
                return next
              })
            },
          },
        }
      )
    })

    return () => ctx.revert()
  }, [])

  return (
    <section id="how-it-works" className="py-28 md:py-40 relative overflow-hidden">
      {/* Ambient bg */}
      <div className="absolute inset-0 pointer-events-none">
        <div
          className="absolute top-1/4 right-0 w-[500px] h-[500px] rounded-full opacity-[0.04] dark:opacity-[0.06] blur-3xl"
          style={{ background: 'radial-gradient(circle, #8B5CF6 0%, transparent 70%)' }}
        />
        <div
          className="absolute bottom-0 left-0 w-[400px] h-[400px] rounded-full opacity-[0.03] dark:opacity-[0.05] blur-3xl"
          style={{ background: 'radial-gradient(circle, #10B981 0%, transparent 70%)' }}
        />
      </div>

      <div className="max-w-7xl mx-auto px-6 relative z-10">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8, ease: 'easeOut' }}
          className="max-w-3xl mb-20 md:mb-28"
        >
          <span className="section-label">Process</span>
          <h2 className="text-display-lg font-display font-extrabold mt-4">
            From throw to sort
            <br />
            <span className="gradient-text">in seconds.</span>
          </h2>
          <p className="mt-5 text-neutral-500 dark:text-neutral-400 text-lg max-w-xl leading-relaxed">
            Our five-step intelligent pipeline handles everything automatically — just toss your waste and walk away.
          </p>
        </motion.div>

        {/* Timeline */}
        <div ref={timelineRef} className="relative">

          {/* ─── Track rail (behind everything) ─── */}
          <div
            className="absolute left-6 md:left-1/2 top-0 bottom-0 w-px -translate-x-px pointer-events-none"
            style={{ zIndex: 0, backgroundColor: 'rgba(100,100,120,0.12)' }}
          >
            {/* The animated fill line */}
            <div
              ref={lineRef}
              className="absolute top-0 left-0 w-full origin-top"
              style={{
                height: '100%',
                transformOrigin: 'top center',
                background: 'linear-gradient(180deg, #6366f1 0%, #8B5CF6 30%, #14B8A6 65%, #10B981 100%)',
              }}
            />
          </div>

          {/* Steps */}
          <div className="space-y-12 md:space-y-0">
            {HOW_IT_WORKS_STEPS.map((step, i) => (
              <TimelineStep
                key={i}
                step={step}
                index={i}
                isRight={i % 2 === 0}
                isLit={litSteps[i]}
              />
            ))}
          </div>
        </div>
      </div>
    </section>
  )
}

function TimelineStep({
  step,
  index,
  isRight,
  isLit,
}: {
  step: typeof HOW_IT_WORKS_STEPS[number]
  index: number
  isRight: boolean
  isLit: boolean
}) {
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })
  const [isHovered, setIsHovered] = useState(false)

  const mouseX = useMotionValue(0)
  const mouseY = useMotionValue(0)
  const rotateX = useSpring(mouseY, { stiffness: 200, damping: 25 })
  const rotateY = useSpring(mouseX, { stiffness: 200, damping: 25 })

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!ref.current) return
    const rect = ref.current.getBoundingClientRect()
    const x = ((e.clientX - rect.left) / rect.width - 0.5) * 8
    const y = -((e.clientY - rect.top) / rect.height - 0.5) * 8
    mouseX.set(x)
    mouseY.set(y)
  }

  const handleMouseLeave = () => {
    mouseX.set(0)
    mouseY.set(0)
    setIsHovered(false)
  }

  const active = isLit || isHovered

  return (
    <div
      ref={ref}
      className={`relative flex items-center gap-0 md:gap-8 ${isRight ? 'md:flex-row' : 'md:flex-row-reverse'
        } pl-16 md:pl-0`}
    >
      {/* Content card */}
      <div
        className={`w-full md:w-[calc(50%-48px)] ${isRight ? 'md:text-right md:pr-8' : 'md:text-left md:pl-8'
          }`}
      >
        <motion.div
          onMouseMove={handleMouseMove}
          onMouseEnter={() => setIsHovered(true)}
          onMouseLeave={handleMouseLeave}
          style={{ rotateX, rotateY, perspective: 1000 }}
          animate={{
            opacity: isInView ? 1 : 0,
            x: isInView ? 0 : isRight ? -60 : 60,
          }}
          transition={{ duration: 0.7, delay: 0.15, ease: 'easeOut' }}
          className={`relative rounded-2xl p-7 overflow-hidden group cursor-pointer ${isRight ? 'md:ml-auto' : 'md:mr-auto'
            }`}
        >
          {/* Base bg */}
          <div
            className="absolute inset-0 rounded-2xl transition-all duration-500"
            style={{
              backgroundColor: active ? `${step.color}08` : undefined,
              background: active
                ? `linear-gradient(135deg, ${step.color}10 0%, ${step.color}04 100%)`
                : undefined,
              border: `1px solid ${active ? step.color + '35' : 'rgba(0,0,0,0.08)'}`,
            }}
          />
          <div
            className="absolute inset-0 dark:block hidden rounded-2xl transition-all duration-500"
            style={{
              backgroundColor: '#111113',
              border: `1px solid ${active ? step.color + '35' : 'rgba(255,255,255,0.07)'}`,
            }}
          />
          <div
            className="absolute inset-0 rounded-2xl pointer-events-none transition-opacity duration-600"
            style={{
              background: `radial-gradient(circle at 50% 0%, ${step.color}12 0%, transparent 70%)`,
              opacity: active ? 1 : 0,
            }}
          />

          {/* Top shimmer when lit */}
          {active && (
            <div
              className="absolute top-0 left-0 right-0 h-px pointer-events-none"
              style={{
                background: `linear-gradient(90deg, transparent, ${step.color}80, transparent)`,
              }}
            />
          )}

          <div
            className={`relative z-10 flex flex-col ${isRight ? 'md:items-end md:text-right' : 'items-start text-left'
              }`}
          >
            {/* Step number */}
            <span
              className="font-display font-extrabold text-6xl leading-none select-none mb-2 transition-all duration-500"
              style={{
                color: active ? `${step.color}50` : 'rgba(0,0,0,0.05)',
              }}
            >
              {step.number}
            </span>

            <h3 className="text-xl md:text-2xl font-display font-bold text-neutral-900 dark:text-white mb-2">
              {step.title}
            </h3>
            <p className="text-neutral-500 dark:text-neutral-400 text-sm md:text-base leading-relaxed">
              {step.description}
            </p>

            {/* Accent bar */}
            <motion.div
              className={`mt-5 h-[2px] rounded-full ${isRight ? 'md:self-end' : 'self-start'}`}
              style={{ backgroundColor: step.color }}
              animate={{ width: active ? '80px' : '32px' }}
              transition={{ duration: 0.5, ease: 'easeOut' }}
            />
          </div>
        </motion.div>
      </div>

      {/* ─── Center node ─── z-index 10 so it's always ABOVE the line ─── */}
      <div
        className="absolute left-0 md:relative md:left-auto md:flex-shrink-0 flex items-center justify-center"
        style={{ zIndex: 10 }}
      >
        <motion.div
          animate={{
            opacity: isInView ? 1 : 0,
            scale: isInView ? 1 : 0.4,
          }}
          transition={{ duration: 0.55, delay: 0.2, type: 'spring', stiffness: 200 }}
          className="relative"
        >
          {/* Outer glow bloom — only when lit, MUCH MORE INTENSE */}
          <motion.div
            className="absolute rounded-full pointer-events-none"
            animate={{
              opacity: active ? 1 : 0,
              scale: active ? 1.3 : 0.5,
            }}
            transition={{ duration: 0.6 }}
            style={{
              inset: '-24px',
              borderRadius: '50%',
              background: `radial-gradient(circle, ${step.color}70 0%, ${step.color}40 35%, transparent 70%)`,
              filter: 'blur(16px)',
            }}
          />

          {/* Pulse ring — active when lit */}
          <motion.div
            className="absolute rounded-full pointer-events-none"
            style={{
              inset: '-6px',
              border: `2px solid ${step.color}50`,
            }}
            animate={
              active
                ? { scale: [1, 1.5, 1], opacity: [0.7, 0, 0.7] }
                : { scale: 1, opacity: 0 }
            }
            transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut' }}
          />

          {/* Second pulse ring offset */}
          <motion.div
            className="absolute rounded-full pointer-events-none"
            style={{
              inset: '-4px',
              border: `1.5px solid ${step.color}30`,
            }}
            animate={
              active
                ? { scale: [1, 1.35, 1], opacity: [0.5, 0, 0.5] }
                : { scale: 1, opacity: 0 }
            }
            transition={{ duration: 2, repeat: Infinity, ease: 'easeInOut', delay: 0.6 }}
          />

          {/* Icon circle — changes appearance when lit, MUCH BRIGHTER */}
          <motion.div
            className="w-12 h-12 md:w-16 md:h-16 rounded-full flex items-center justify-center relative"
            animate={{
              boxShadow: active
                ? `0 0 0 4px ${step.color}60, 0 0 50px ${step.color}70, 0 0 80px ${step.color}40`
                : `0 0 0 1px ${step.color}20`,
              scale: active ? 1.08 : 1,
            }}
            transition={{ duration: 0.5 }}
            style={{
              background: active
                ? `radial-gradient(circle, ${step.color} 0%, ${step.color}90 100%)`
                : `linear-gradient(135deg, ${step.color}18 0%, ${step.color}08 100%)`,
              border: `2px solid ${active ? step.color : step.color + '25'}`,
            }}
          >
            <step.icon
              className="w-5 h-5 md:w-6 md:h-6 transition-all duration-500"
              style={{
                color: active ? '#ffffff' : `${step.color}80`,
                filter: active ? `drop-shadow(0 0 12px ${step.color}) drop-shadow(0 0 24px ${step.color}80)` : 'none',
              }}
            />
          </motion.div>
        </motion.div>
      </div>

      {/* Empty half for zigzag */}
      <div className="hidden md:block w-[calc(50%-48px)]" />
    </div>
  )
}
