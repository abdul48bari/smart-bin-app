'use client'

import { motion } from 'framer-motion'
import { ArrowRight } from 'lucide-react'
import ScrollReveal from './ScrollReveal'
import { DEMO_APP_URL } from '@/lib/constants'

export default function AppPreview() {
  return (
    <section className="py-28 md:py-40 relative overflow-hidden">
      <div className="max-w-7xl mx-auto px-6">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Phone Mockup */}
          <ScrollReveal direction="left">
            <div className="flex justify-center">
              <motion.div
                animate={{ y: [0, -12, 0] }}
                transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
                className="relative"
              >
                {/* Phone frame */}
                <div className="w-[280px] h-[560px] rounded-[3rem] border-[6px] border-neutral-200 bg-neutral-900 shadow-[0_40px_100px_-20px_rgba(0,0,0,0.6)] overflow-hidden relative">
                  {/* Dynamic island */}
                  <div className="absolute top-2 left-1/2 -translate-x-1/2 w-28 h-7 bg-neutral-900 rounded-full z-10" />

                  {/* Screen content */}
                  <div className="w-full h-full bg-[#0f0f11] p-4 pt-12">
                    {/* App header */}
                    <div className="text-center mb-5">
                      <span className="text-accent font-display font-bold text-lg">Reclevo</span>
                      <div className="flex items-center justify-center gap-1.5 mt-1">
                        <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                        <span className="text-[10px] text-emerald-400 font-mono">ONLINE</span>
                      </div>
                    </div>

                    {/* Mini stat cards */}
                    <div className="grid grid-cols-3 gap-2 mb-4">
                      {[
                        { label: 'Peak', value: '78%', color: '#f59e0b' },
                        { label: 'Full', value: '2', color: '#ef4444' },
                        { label: 'Bins', value: '5', color: '#6366f1' },
                      ].map((card, i) => (
                        <div key={i} className="bg-white/[0.04] border border-white/[0.06] rounded-xl p-2.5 text-center">
                          <div className="text-base font-bold" style={{ color: card.color }}>{card.value}</div>
                          <div className="text-[9px] text-neutral-500 font-mono uppercase">{card.label}</div>
                        </div>
                      ))}
                    </div>

                    {/* Fill level bars */}
                    <div className="bg-white/[0.03] border border-white/[0.06] rounded-xl p-3.5 mb-3">
                      <div className="text-[10px] text-neutral-500 mb-3 font-mono uppercase tracking-wider">Fill Levels</div>
                      {[
                        { name: 'Plastic', pct: 72, color: '#6366f1' },
                        { name: 'Paper', pct: 45, color: '#10B981' },
                        { name: 'Organic', pct: 88, color: '#d97706' },
                        { name: 'Cans', pct: 31, color: '#F59E0B' },
                        { name: 'Mixed', pct: 56, color: '#8B5CF6' },
                      ].map((bar, i) => (
                        <div key={i} className="flex items-center gap-2 mb-2 last:mb-0">
                          <span className="text-[9px] text-neutral-500 w-11 font-mono">{bar.name}</span>
                          <div className="flex-1 h-1.5 bg-white/[0.06] rounded-full overflow-hidden">
                            <motion.div
                              initial={{ width: 0 }}
                              whileInView={{ width: `${bar.pct}%` }}
                              viewport={{ once: true }}
                              transition={{ duration: 1.2, delay: i * 0.12, ease: [0.16, 1, 0.3, 1] }}
                              className="h-full rounded-full"
                              style={{ backgroundColor: bar.color }}
                            />
                          </div>
                          <span className="text-[9px] text-neutral-500 w-7 text-right font-mono">{bar.pct}%</span>
                        </div>
                      ))}
                    </div>

                    {/* Bottom nav */}
                    <div className="absolute bottom-3 left-3 right-3 bg-white/[0.05] border border-white/[0.06] rounded-2xl p-2.5 flex justify-around">
                      {['Home', 'Bins', 'Stats', 'Profile'].map((tab, i) => (
                        <div key={i} className={`text-[9px] font-mono ${i === 0 ? 'text-accent' : 'text-neutral-600'}`}>
                          {tab}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>

                {/* Glow */}
                <div className="absolute -inset-12 bg-accent/20 rounded-full blur-[80px] -z-10" />
              </motion.div>
            </div>
          </ScrollReveal>

          {/* Text */}
          <ScrollReveal direction="right">
            <div>
              <span className="section-label">Mobile App</span>
              <h2 className="text-display-md font-display font-extrabold mt-4">
                Control at your fingertips.
              </h2>
              <p className="text-lg text-neutral-400 leading-relaxed mt-6">
                The Reclevo companion app gives you real-time visibility into every bin.
                Monitor fill levels, view analytics, receive alerts, and even use voice commands.
              </p>

              <div className="space-y-3 mt-8">
                {[
                  'Live fill level monitoring for all 5 sub-bins',
                  'Smart analytics with time-filtered charts',
                  'Voice assistant for hands-free queries',
                  'Instant alerts when bins need attention',
                  'Beautiful dark mode with glassmorphism UI',
                ].map((item, i) => (
                  <div key={i} className="flex items-center gap-3">
                    <div className="w-1.5 h-1.5 rounded-full bg-accent flex-shrink-0" />
                    <span className="text-sm text-neutral-400">{item}</span>
                  </div>
                ))}
              </div>

              <a
                href={DEMO_APP_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="btn-primary mt-10"
              >
                Try the Web Demo
                <ArrowRight className="w-4 h-4" />
              </a>
            </div>
          </ScrollReveal>
        </div>
      </div>
    </section>
  )
}
