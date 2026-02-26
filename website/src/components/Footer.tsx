'use client'

import { motion } from 'framer-motion'
import { ArrowRight, ArrowUpRight } from 'lucide-react'
import ScrollReveal from './ScrollReveal'
import { DEMO_APP_URL, NAV_LINKS } from '@/lib/constants'

export default function Footer() {
  return (
    <footer className="relative">
      {/* CTA Section */}
      <section className="py-28 md:py-40 relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-6">
          <ScrollReveal>
            <div className="bento-card p-12 md:p-20 text-center relative overflow-hidden">
              {/* Background gradient */}
              <div className="absolute inset-0 bg-gradient-to-br from-accent/10 via-transparent to-teal/10" />
              <div className="absolute top-0 left-1/2 -translate-x-1/2 w-96 h-96 bg-accent/10 rounded-full blur-[120px] -translate-y-1/2" />

              <div className="relative">
                <h2 className="text-display-lg font-display font-extrabold">
                  Ready to revolutionize<br />
                  <span className="gradient-text">waste management?</span>
                </h2>
                <p className="text-neutral-400 text-lg mt-6 max-w-lg mx-auto">
                  Experience the future of smart waste sorting. Try our demo app and see Reclevo in action.
                </p>
                <div className="flex flex-wrap justify-center gap-4 mt-10">
                  <a
                    href={DEMO_APP_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="btn-primary text-base px-8 py-4"
                  >
                    Launch Demo App
                    <ArrowRight className="w-5 h-5" />
                  </a>
                  <a
                    href="#about"
                    className="btn-secondary text-base px-8 py-4"
                  >
                    Learn More
                  </a>
                </div>
              </div>
            </div>
          </ScrollReveal>
        </div>
      </section>

      {/* Footer content */}
      <div className="border-t border-neutral-800/50">
        <div className="max-w-7xl mx-auto px-6 py-16">
          <div className="grid md:grid-cols-12 gap-12">
            {/* Brand */}
            <div className="md:col-span-5">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-accent flex items-center justify-center">
                  <span className="text-white font-display font-bold text-sm">R</span>
                </div>
                <span className="text-lg font-display font-bold tracking-tight">eclevo</span>
              </div>
              <p className="text-neutral-400 mt-4 text-sm leading-relaxed max-w-sm">
                AI-powered smart garbage bin that automatically sorts waste into 5 categories.
                Making recycling effortless for a sustainable future.
              </p>
            </div>

            {/* Links */}
            <div className="md:col-span-3">
              <h4 className="text-xs font-mono uppercase tracking-wider text-neutral-400 mb-4">Navigation</h4>
              <div className="space-y-3">
                {NAV_LINKS.map((link) => (
                  <a
                    key={link.href}
                    href={link.href}
                    className="block text-sm text-neutral-400 hover:text-white transition-colors link-underline w-fit"
                  >
                    {link.label}
                  </a>
                ))}
              </div>
            </div>

            {/* Resources */}
            <div className="md:col-span-4">
              <h4 className="text-xs font-mono uppercase tracking-wider text-neutral-400 mb-4">Resources</h4>
              <div className="space-y-3">
                <a
                  href={DEMO_APP_URL}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="flex items-center gap-1 text-sm text-neutral-400 hover:text-white transition-colors"
                >
                  Demo App <ArrowUpRight className="w-3 h-3" />
                </a>
                <span className="block text-sm text-neutral-400">
                  hello@reclevo.com
                </span>
                <span className="block text-sm text-neutral-400">
                  University Project
                </span>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="divider" />
        <div className="max-w-7xl mx-auto px-6 py-6 flex flex-col md:flex-row justify-between items-center gap-4">
          <p className="text-xs font-mono text-neutral-400">
            &copy; {new Date().getFullYear()} Reclevo. All rights reserved.
          </p>
          <p className="text-xs font-mono text-neutral-400">
            Built with passion for a cleaner future
          </p>
        </div>
      </div>
    </footer>
  )
}
