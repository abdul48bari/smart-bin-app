'use client'

import { useEffect, useRef, useState, useCallback } from 'react'

export default function CursorFollower() {
  const outerRef = useRef<HTMLDivElement>(null)
  const innerRef = useRef<HTMLDivElement>(null)
  const [visible, setVisible] = useState(false)
  const [hovering, setHovering] = useState(false)
  const [clicking, setClicking] = useState(false)
  const mouse = useRef({ x: 0, y: 0 })
  const outer = useRef({ x: 0, y: 0 })
  const raf = useRef<number>(0)

  const animate = useCallback(() => {
    outer.current.x += (mouse.current.x - outer.current.x) * 0.12
    outer.current.y += (mouse.current.y - outer.current.y) * 0.12

    if (outerRef.current) {
      outerRef.current.style.transform = `translate(${outer.current.x - 20}px, ${outer.current.y - 20}px)`
    }
    if (innerRef.current) {
      innerRef.current.style.transform = `translate(${mouse.current.x - 4}px, ${mouse.current.y - 4}px)`
    }

    raf.current = requestAnimationFrame(animate)
  }, [])

  useEffect(() => {
    if (typeof window === 'undefined') return
    if (window.matchMedia('(pointer: coarse)').matches) return

    setVisible(true)

    const handleMove = (e: MouseEvent) => {
      mouse.current.x = e.clientX
      mouse.current.y = e.clientY
    }

    const handleDown = () => setClicking(true)
    const handleUp = () => setClicking(false)

    window.addEventListener('mousemove', handleMove, { passive: true })
    window.addEventListener('mousedown', handleDown)
    window.addEventListener('mouseup', handleUp)
    raf.current = requestAnimationFrame(animate)

    const onEnter = () => setHovering(true)
    const onLeave = () => setHovering(false)

    const attach = () => {
      document.querySelectorAll('a, button, [role="button"], input, textarea, .cursor-hover').forEach((el) => {
        el.addEventListener('mouseenter', onEnter)
        el.addEventListener('mouseleave', onLeave)
      })
    }

    attach()
    const observer = new MutationObserver(attach)
    observer.observe(document.body, { childList: true, subtree: true })

    return () => {
      window.removeEventListener('mousemove', handleMove)
      window.removeEventListener('mousedown', handleDown)
      window.removeEventListener('mouseup', handleUp)
      cancelAnimationFrame(raf.current)
      observer.disconnect()
    }
  }, [animate])

  if (!visible) return null

  const outerSize = clicking ? 24 : hovering ? 60 : 40
  const innerSize = clicking ? 4 : hovering ? 10 : 8

  return (
    <>
      <div
        ref={outerRef}
        className="fixed top-0 left-0 pointer-events-none z-[9999] mix-blend-difference"
        style={{ willChange: 'transform' }}
      >
        <div
          className="rounded-full border border-white/70 transition-all duration-300 ease-out"
          style={{
            width: outerSize,
            height: outerSize,
            opacity: hovering ? 1 : 0.35,
            marginLeft: (40 - outerSize) / 2,
            marginTop: (40 - outerSize) / 2,
          }}
        />
      </div>
      <div
        ref={innerRef}
        className="fixed top-0 left-0 pointer-events-none z-[9999] mix-blend-difference"
        style={{ willChange: 'transform' }}
      >
        <div
          className="rounded-full bg-white transition-all duration-150"
          style={{
            width: innerSize,
            height: innerSize,
            marginLeft: (8 - innerSize) / 2,
            marginTop: (8 - innerSize) / 2,
          }}
        />
      </div>
    </>
  )
}
