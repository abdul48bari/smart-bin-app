'use client'

import { useEffect } from 'react'
import Lenis from '@studio-freight/lenis'

// Expose lenis instance globally so other components can use it
declare global {
  interface Window {
    lenis?: Lenis
  }
}

export default function SmoothScroll() {
  useEffect(() => {
    const lenis = new Lenis({
      duration: 1.2,
      easing: (t: number) => Math.min(1, 1.001 - Math.pow(2, -10 * t)),
      smoothWheel: true,
    })

    window.lenis = lenis

    function raf(time: number) {
      lenis.raf(time)
      requestAnimationFrame(raf)
    }
    requestAnimationFrame(raf)

    // Smooth scroll for anchor links
    const handleAnchorClick = (e: Event) => {
      const anchor = (e.currentTarget as HTMLAnchorElement)
      const href = anchor.getAttribute('href')
      if (!href || !href.startsWith('#')) return
      e.preventDefault()
      const target = document.querySelector(href)
      if (target) {
        lenis.scrollTo(target as HTMLElement, { offset: -80 })
      }
    }

    const attachAnchors = () => {
      document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
        anchor.addEventListener('click', handleAnchorClick)
      })
    }

    attachAnchors()
    // Re-attach on DOM changes (for dynamically added links)
    const observer = new MutationObserver(attachAnchors)
    observer.observe(document.body, { childList: true, subtree: true })

    return () => {
      observer.disconnect()
      lenis.destroy()
      delete window.lenis
    }
  }, [])

  return null
}
