'use client'

import { useState, useEffect } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Menu, X, ArrowRight, Instagram, Linkedin } from 'lucide-react'
import { NAV_LINKS, DEMO_APP_URL } from '@/lib/constants'

export default function Navbar() {
  const [scrolled, setScrolled] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const [scrollProgress, setScrollProgress] = useState(0)

  useEffect(() => {
    const onScroll = () => {
      setScrolled(window.scrollY > 20)
      const total = document.documentElement.scrollHeight - window.innerHeight
      setScrollProgress(total > 0 ? (window.scrollY / total) * 100 : 0)
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    return () => window.removeEventListener('scroll', onScroll)
  }, [])

  return (
    <>
      <motion.nav
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.8, ease: [0.16, 1, 0.3, 1] }}
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-500 border-b ${scrolled
            ? 'bg-neutral-950/70 backdrop-blur-2xl border-white/5'
            : 'bg-transparent border-transparent'
          }`}
      >
        {/* Scroll progress bar — top edge */}
        <div
          className="absolute top-0 left-0 right-0 h-[2px] z-10 pointer-events-none"
          style={{ background: 'rgba(0,0,0,0)' }}
        >
          <motion.div
            className="h-full"
            style={{
              width: `${scrollProgress}%`,
              background: 'linear-gradient(90deg, #6366f1, #8B5CF6, #22c55e)',
            }}
            transition={{ duration: 0 }}
          />
        </div>

        <div className="max-w-7xl mx-auto px-6 h-16 flex items-center justify-between">
          {/* Logo — clean text */}
          <a href="#" className="group relative overflow-hidden inline-flex items-center">
            <span
              className="text-xl font-display font-black tracking-tight select-none"
              style={{ letterSpacing: '-0.03em' }}
            >
              <span className="text-accent transition-colors duration-300 group-hover:text-accent-light">R</span>
              <span className="text-white">eclevo</span>
            </span>
            {/* Shimmer sweep */}
            <span
              className="absolute inset-0 pointer-events-none -translate-x-full group-hover:translate-x-full transition-transform duration-700"
              style={{
                background: 'linear-gradient(90deg, transparent, rgba(255,255,255,0.15), transparent)',
              }}
            />
          </a>

          {/* Desktop Nav */}
          <div className="hidden md:flex items-center gap-1">
            {NAV_LINKS.map((link) => (
              <a
                key={link.href}
                href={link.href}
                className="px-4 py-2 text-sm text-neutral-400 hover:text-white transition-colors duration-300 rounded-lg hover:bg-white/5"
              >
                {link.label}
              </a>
            ))}
          </div>

          {/* Right side — socials + CTA */}
          <div className="hidden md:flex items-center gap-2">
            <a href="https://www.instagram.com/recl.evo" target="_blank" rel="noopener noreferrer" className="social-icon" aria-label="Instagram">
              <Instagram className="w-4 h-4" />
            </a>
            <a href="https://linkedin.com" target="_blank" rel="noopener noreferrer" className="social-icon" aria-label="LinkedIn">
              <Linkedin className="w-4 h-4" />
            </a>
            <div className="w-px h-4 bg-neutral-800 mx-1" />
            <a
              href={DEMO_APP_URL}
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-2 px-5 py-2 rounded-full bg-white text-neutral-900 text-sm font-semibold transition-all duration-300 hover:shadow-lg hover:shadow-white/10 hover:-translate-y-0.5"
            >
              Try Demo
              <ArrowRight className="w-3.5 h-3.5" />
            </a>
          </div>

          {/* Mobile hamburger */}
          <div className="flex items-center md:hidden">
            <button
              onClick={() => setMobileOpen(!mobileOpen)}
              className="w-10 h-10 flex items-center justify-center rounded-lg hover:bg-white/10 transition-colors"
              aria-label="Toggle menu"
            >
              {mobileOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>
      </motion.nav>

      {/* Mobile drawer */}
      <AnimatePresence>
        {mobileOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setMobileOpen(false)}
              className="fixed inset-0 z-40 bg-black/20 backdrop-blur-sm md:hidden"
            />
            <motion.div
              initial={{ opacity: 0, x: '100%' }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: '100%' }}
              transition={{ type: 'spring', damping: 30, stiffness: 300 }}
              className="fixed right-0 top-0 bottom-0 w-72 z-50 bg-neutral-950 border-l border-neutral-800 md:hidden"
            >
              <div className="flex flex-col p-8 pt-20 gap-2">
                {NAV_LINKS.map((link) => (
                  <a
                    key={link.href}
                    href={link.href}
                    onClick={() => setMobileOpen(false)}
                    className="text-lg font-medium text-neutral-300 hover:text-accent transition-colors py-2"
                  >
                    {link.label}
                  </a>
                ))}
                <div className="divider my-4" />
                <a
                  href={DEMO_APP_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="btn-primary justify-center mt-2"
                >
                  Try Demo App
                  <ArrowRight className="w-4 h-4" />
                </a>
                <div className="flex items-center gap-3 mt-4">
                  <a href="https://www.instagram.com/recl.evo" target="_blank" rel="noopener noreferrer" className="social-icon" aria-label="Instagram">
                    <Instagram className="w-4 h-4" />
                  </a>
                  <a href="https://linkedin.com" target="_blank" rel="noopener noreferrer" className="social-icon" aria-label="LinkedIn">
                    <Linkedin className="w-4 h-4" />
                  </a>
                </div>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  )
}
