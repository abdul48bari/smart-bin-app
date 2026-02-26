'use client'

import { useState, useEffect, useRef } from 'react'
import Spline from '@splinetool/react-spline'
import { motion } from 'framer-motion'

export default function SmartBin3D() {
  const [loaded, setLoaded] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    if (!containerRef.current) return
    const container = containerRef.current

    const fixCanvas = () => {
      const canvas = container.querySelector('canvas')
      if (!canvas) return

      canvas.style.touchAction = 'pan-y pinch-zoom'

      canvas.addEventListener('wheel', (e) => {
        e.preventDefault()
        e.stopPropagation()
        // Re-dispatch on window so Lenis picks it up natively
        window.dispatchEvent(new WheelEvent('wheel', {
          deltaX: e.deltaX,
          deltaY: e.deltaY,
          deltaMode: e.deltaMode,
          bubbles: false,
          cancelable: false,
        }))
      }, { capture: true, passive: false })
    }

    const observer = new MutationObserver(fixCanvas)
    observer.observe(container, { childList: true, subtree: true })
    fixCanvas()

    return () => observer.disconnect()
  }, [loaded])

  return (
    <>
      {!loaded && (
        <div className="absolute inset-0 flex items-center justify-center z-0">
          <div className="relative">
            <div className="w-12 h-12 rounded-full border-2 border-accent/20 border-t-accent animate-spin" />
          </div>
        </div>
      )}

      <motion.div
        ref={containerRef}
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: loaded ? 1 : 0, scale: loaded ? 1 : 0.95 }}
        transition={{ duration: 1.5, ease: [0.16, 1, 0.3, 1] }}
        className="absolute z-0"
        style={{ inset: '-10%' }}
      >
        <Spline
          scene="https://prod.spline.design/3repb8sob4FE1tei/scene.splinecode"
          onLoad={() => setLoaded(true)}
          style={{ width: '100%', height: '100%' }}
        />
      </motion.div>
    </>
  )
}
