'use client'

import { useState, useRef } from 'react'
import { motion, useInView } from 'framer-motion'
import { Wifi } from 'lucide-react'
import {
  siTensorflow,
  siGoogle,
  siFirebase,
  siGooglecloud,
  siNodedotjs,
  siFlutter,
  siNextdotjs,
} from 'simple-icons'

// ─── SimpleIcon renderer — uses official Simple Icons SVG paths ───────────────

function SimpleIcon({
  icon,
  size = 20,
  color,
}: {
  icon: { path: string; hex: string }
  size?: number
  color?: string
}) {
  return (
    <svg
      role="img"
      viewBox="0 0 24 24"
      xmlns="http://www.w3.org/2000/svg"
      width={size}
      height={size}
      fill={color ?? `#${icon.hex}`}
      style={{ display: 'block' }}
    >
      <path d={icon.path} />
    </svg>
  )
}

// ─── Hardware SVG Schematic Illustrations ─────────────────────────────────────

function RpiSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 120 90" fill="none" className="w-full h-full">
      <rect x="10" y="14" width="88" height="62" rx="5" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      {Array.from({ length: 13 }, (_, i) => (
        <g key={i}>
          <rect x={12 + i * 6.2} y="9" width="4" height="7" rx="1" fill={color} opacity="0.9" />
          <rect x={12 + i * 6.2} y="6" width="4" height="5" rx="1" fill={color} opacity="0.4" />
        </g>
      ))}
      <rect x="32" y="26" width="38" height="32" rx="4" stroke={color} strokeWidth="2" fill={`${color}1a`} />
      <text x="51" y="40" textAnchor="middle" fill={color} fontSize="7.5" fontFamily="monospace" fontWeight="bold">RPi 5</text>
      <text x="51" y="50" textAnchor="middle" fill={color} fontSize="5" fontFamily="monospace" opacity="0.5">BCM2712</text>
      {[0, 1, 2, 3, 4].map(i => (
        <g key={i}>
          <line x1="32" y1={30 + i * 6} x2="24" y2={30 + i * 6} stroke={color} strokeWidth="1" opacity="0.25" />
          <line x1="70" y1={30 + i * 6} x2="78" y2={30 + i * 6} stroke={color} strokeWidth="1" opacity="0.25" />
        </g>
      ))}
      <rect x="96" y="18" width="10" height="10" rx="1.5" stroke={color} strokeWidth="1.5" fill="none" />
      <rect x="96" y="31" width="10" height="10" rx="1.5" stroke={color} strokeWidth="1.5" fill="none" />
      <rect x="96" y="50" width="10" height="13" rx="1.5" stroke={color} strokeWidth="1.5" fill="none" />
      <rect x="12" y="73" width="12" height="5" rx="1" stroke={color} strokeWidth="1.2" fill="none" />
      <rect x="27" y="73" width="12" height="5" rx="1" stroke={color} strokeWidth="1.2" fill="none" />
      <rect x="44" y="73" width="10" height="5" rx="2.5" stroke={color} strokeWidth="1.2" fill="none" />
      <rect x="80" y="26" width="5" height="7" rx="1" stroke={color} strokeWidth="1" fill="none" opacity="0.4" />
      <rect x="80" y="37" width="5" height="7" rx="1" stroke={color} strokeWidth="1" fill="none" opacity="0.4" />
    </svg>
  )
}

function CameraSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 100 90" fill="none" className="w-full h-full">
      <rect x="15" y="12" width="70" height="52" rx="7" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      <circle cx="50" cy="38" r="22" stroke={color} strokeWidth="2" fill={`${color}08`} />
      <circle cx="50" cy="38" r="16" stroke={color} strokeWidth="1.5" fill={`${color}10`} />
      <circle cx="50" cy="38" r="10" stroke={color} strokeWidth="1.5" fill={`${color}18`} />
      <circle cx="50" cy="38" r="5.5" fill={color} opacity="0.45" />
      <circle cx="50" cy="38" r="2.5" fill={color} opacity="0.7" />
      <circle cx="44" cy="32" r="3" fill="white" opacity="0.35" />
      <circle cx="46" cy="34" r="1.2" fill="white" opacity="0.2" />
      {([[20, 17], [85, 17], [20, 59], [85, 59]] as [number, number][]).map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="2.5" stroke={color} strokeWidth="1" fill="none" opacity="0.4" />
      ))}
      <rect x="44" y="63" width="12" height="16" rx="2" fill={color} opacity="0.18" stroke={color} strokeWidth="1" />
      {[46, 50, 54].map(x => (
        <line key={x} x1={x} y1="63" x2={x} y2="79" stroke={color} strokeWidth="0.8" opacity="0.4" />
      ))}
      <rect x="35" y="78" width="30" height="6" rx="2" stroke={color} strokeWidth="1.2" fill={`${color}0c`} />
      {[39, 44, 49, 54, 59].map(x => (
        <rect key={x} x={x} y="81" width="2.5" height="4" rx="0.5" fill={color} opacity="0.6" />
      ))}
    </svg>
  )
}

function UltrasonicSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 110 90" fill="none" className="w-full h-full">
      <rect x="10" y="46" width="90" height="32" rx="4" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      <ellipse cx="33" cy="46" rx="16" ry="19" stroke={color} strokeWidth="2" fill={`${color}12`} />
      <ellipse cx="33" cy="46" rx="10" ry="12" stroke={color} strokeWidth="1.5" fill={`${color}1e`} />
      <circle cx="33" cy="46" r="4" fill={color} opacity="0.4" />
      <ellipse cx="77" cy="46" rx="16" ry="19" stroke={color} strokeWidth="2" fill={`${color}12`} />
      <ellipse cx="77" cy="46" rx="10" ry="12" stroke={color} strokeWidth="1.5" fill={`${color}1e`} />
      <circle cx="77" cy="46" r="4" fill={color} opacity="0.4" />
      <path d="M 14 33 Q 33 20 52 33" stroke={color} strokeWidth="1.5" fill="none" opacity="0.55" strokeDasharray="3 3" />
      <path d="M  8 23 Q 33  6 58 23" stroke={color} strokeWidth="1.2" fill="none" opacity="0.35" strokeDasharray="3 3" />
      <path d="M 58 33 Q 77 20 96 33" stroke={color} strokeWidth="1.5" fill="none" opacity="0.55" strokeDasharray="3 3" />
      <path d="M 52 23 Q 77  6 102 23" stroke={color} strokeWidth="1.2" fill="none" opacity="0.35" strokeDasharray="3 3" />
      <text x="33" y="49" textAnchor="middle" fill={color} fontSize="8" fontFamily="monospace" fontWeight="bold" opacity="0.8">T</text>
      <text x="77" y="49" textAnchor="middle" fill={color} fontSize="8" fontFamily="monospace" fontWeight="bold" opacity="0.8">R</text>
      {[22, 38, 72, 88].map(x => (
        <rect key={x} x={x - 2} y="74" width="5" height="9" rx="1" fill={color} opacity="0.8" />
      ))}
      <text x="55" y="62" textAnchor="middle" fill={color} fontSize="5.5" fontFamily="monospace" opacity="0.4">HC-SR04</text>
    </svg>
  )
}

function GasSensorSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 100 90" fill="none" className="w-full h-full">
      <rect x="10" y="54" width="80" height="28" rx="4" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      <path d="M 16 56 Q 16 10 50 10 Q 84 10 84 56" stroke={color} strokeWidth="2" fill={`${color}0e`} />
      <path d="M 26 56 Q 26 22 50 22 Q 74 22 74 56" stroke={color} strokeWidth="1.2" fill={`${color}08`} opacity="0.8" />
      {Array.from({ length: 5 }, (_, row) =>
        Array.from({ length: 7 }, (_, col) => {
          const cx = 22 + col * 9.5, cy = 50 - row * 8
          const dx = (cx - 50) / 26, dy = (cy - 56) / 38
          return dx * dx + dy * dy < 1 ? (
            <circle key={`${row}-${col}`} cx={cx} cy={cy} r="2.2" fill={color} opacity={0.12 + row * 0.07} />
          ) : null
        })
      )}
      <circle cx="50" cy="36" r="13" stroke={color} strokeWidth="2.5" fill="none" opacity="0.75" />
      <circle cx="50" cy="36" r="7.5" stroke={color} strokeWidth="2" fill={`${color}14`} opacity="0.9" />
      <circle cx="50" cy="36" r="3.5" fill={color} opacity="0.55" />
      {[20, 34, 66, 80].map((x, i) => (
        <g key={i}>
          <line x1={x} y1="54" x2={x} y2="44" stroke={color} strokeWidth="2" opacity="0.65" />
          <rect x={x - 3} y="78" width="6" height="8" rx="1" fill={color} opacity="0.8" />
        </g>
      ))}
      <text x="50" y="68" textAnchor="middle" fill={color} fontSize="5.5" fontFamily="monospace" opacity="0.4">MQ Series</text>
    </svg>
  )
}

function MoistureSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 90 100" fill="none" className="w-full h-full">
      <rect x="20" y="6" width="50" height="32" rx="4" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      <rect x="30" y="13" width="30" height="15" rx="3" stroke={color} strokeWidth="1.2" fill={`${color}14`} />
      <text x="45" y="23" textAnchor="middle" fill={color} fontSize="5.5" fontFamily="monospace" opacity="0.7">LM393</text>
      {[26, 36, 54, 64].map(x => (
        <rect key={x} x={x - 2} y="1" width="5" height="8" rx="1" fill={color} opacity="0.85" />
      ))}
      <rect x="28" y="36" width="11" height="50" rx="4" stroke={color} strokeWidth="2" fill={`${color}10`} />
      <path d="M 28 82 Q 28 90 33 90 Q 38 90 39 82" stroke={color} strokeWidth="2" fill={`${color}20`} />
      <rect x="51" y="36" width="11" height="50" rx="4" stroke={color} strokeWidth="2" fill={`${color}10`} />
      <path d="M 51 82 Q 51 90 56 90 Q 61 90 62 82" stroke={color} strokeWidth="2" fill={`${color}20`} />
      {[40, 47, 54, 61, 68].map(y => (
        <g key={y}>
          <line x1="30" y1={y} x2="37" y2={y} stroke={color} strokeWidth="1" opacity="0.25" />
          <line x1="53" y1={y} x2="60" y2={y} stroke={color} strokeWidth="1" opacity="0.25" />
        </g>
      ))}
      {[48, 58, 68].map((y, i) => (
        <ellipse key={y} cx="45" cy={y} rx="2" ry="3" fill={color} opacity={0.2 + i * 0.1} />
      ))}
    </svg>
  )
}

function PwmMotorSVG({ color }: { color: string }) {
  return (
    <svg viewBox="0 0 120 90" fill="none" className="w-full h-full">
      {/* Motor cylindrical body (side view) */}
      <rect x="30" y="18" width="62" height="54" rx="27" stroke={color} strokeWidth="2" fill={`${color}0c`} />
      {/* Left end cap */}
      <ellipse cx="30" cy="45" rx="6" ry="27" stroke={color} strokeWidth="1.5" fill={`${color}14`} />
      {/* Right end cap / shaft housing */}
      <ellipse cx="92" cy="45" rx="6" ry="27" stroke={color} strokeWidth="1.5" fill={`${color}14`} />
      {/* Output shaft */}
      <rect x="95" y="41" width="20" height="8" rx="4" stroke={color} strokeWidth="1.5" fill={`${color}20`} />
      <circle cx="115" cy="45" r="5" stroke={color} strokeWidth="1.2" fill="none" opacity="0.55" />
      {/* Armature winding arcs inside body */}
      {[-12, -6, 0, 6, 12].map((offset, i) => (
        <path key={i}
          d={`M ${55 + offset} 26 Q ${57 + offset} 45 ${55 + offset} 64`}
          stroke={color} strokeWidth="1.2" fill="none" opacity={0.18 + i * 0.03} />
      ))}
      {/* Center hub circle */}
      <circle cx="61" cy="45" r="12" stroke={color} strokeWidth="1.5" fill={`${color}10`} opacity="0.8" />
      <circle cx="61" cy="45" r="5"  fill={color} opacity="0.4" />
      {/* Left wire terminals */}
      <rect x="8"  y="36" width="24" height="6" rx="3" stroke={color} strokeWidth="1.5" fill={`${color}10`} />
      <rect x="8"  y="48" width="24" height="6" rx="3" stroke={color} strokeWidth="1.5" fill={`${color}10`} />
      {/* Terminal connectors */}
      <circle cx="8"  cy="39" r="2.5" fill={color} opacity="0.7" />
      <circle cx="8"  cy="51" r="2.5" fill={color} opacity="0.7" />
      {/* PWM signal waveform above terminals */}
      <polyline
        points="8,26 8,20 13,20 13,26 18,26 18,20 23,20 23,26 28,26"
        stroke={color} strokeWidth="1.3" fill="none" opacity="0.75" strokeLinecap="round" strokeLinejoin="round" />
      <text x="4" y="16" fill={color} fontSize="4.5" fontFamily="monospace" opacity="0.55">PWM</text>
      {/* Mounting feet */}
      <rect x="38" y="70" width="10" height="7" rx="2" stroke={color} strokeWidth="1" fill={`${color}10`} />
      <rect x="73" y="70" width="10" height="7" rx="2" stroke={color} strokeWidth="1" fill={`${color}10`} />
      <text x="61" y="84" textAnchor="middle" fill={color} fontSize="5" fontFamily="monospace" opacity="0.35">DC Motor</text>
    </svg>
  )
}

// ─── Data ─────────────────────────────────────────────────────────────────────

const HARDWARE = [
  {
    id: 'rpi5',
    name: 'Raspberry Pi 5',
    role: 'Main Controller',
    description: 'System brain — runs the AI classification model, coordinates all hardware, and pushes events to Firebase over WiFi.',
    color: '#22c55e',
    Svg: RpiSVG,
  },
  {
    id: 'camera',
    name: 'Camera Module',
    role: 'Visual Input',
    description: 'Captures waste items entering the bin. Frames are fed to TensorFlow Lite for real-time classification.',
    color: '#6366f1',
    Svg: CameraSVG,
  },
  {
    id: 'ultrasonic',
    name: 'Ultrasonic Sensors',
    role: 'Fill Detection',
    description: 'HC-SR04 sensors measure distance in each sub-bin. Triggers BIN_FULL events when fill threshold is reached.',
    color: '#10B981',
    Svg: UltrasonicSVG,
  },
  {
    id: 'gas',
    name: 'Gas Sensors',
    role: 'Hazard Detection',
    description: 'MQ-series sensors detect harmful gases. Alerts fire when concentration exceeds 500 PPM threshold.',
    color: '#ef4444',
    Svg: GasSensorSVG,
  },
  {
    id: 'moisture',
    name: 'Moisture Detectors',
    role: 'Moisture Monitoring',
    description: 'Resistive probes monitor wet waste in organic compartments. Alerts fire at ≥70% moisture level.',
    color: '#38bdf8',
    Svg: MoistureSVG,
  },
  {
    id: 'pwm',
    name: 'PWM Motors',
    role: 'Auto-Sorting',
    description: 'PWM-controlled DC motors physically route each classified waste item to its correct sub-bin compartment.',
    color: '#F59E0B',
    Svg: PwmMotorSVG,
  },
]

const SOFTWARE_LAYERS = [
  {
    id: 'ai',
    label: 'AI / ML',
    subtitle: 'On-device inference',
    color: '#8B5CF6',
    items: [
      { name: 'TensorFlow Lite', desc: 'Real-time waste image classification',    si: siTensorflow, iconColor: undefined },
      { name: 'MobileNetV2',     desc: 'Optimised CNN model running on-device',   si: siGoogle,     iconColor: undefined },
    ],
  },
  {
    id: 'cloud',
    label: 'Cloud Backend',
    subtitle: 'Real-time data layer',
    color: '#FF7043',
    items: [
      { name: 'Firebase Firestore', desc: 'Real-time bin data sync',           si: siFirebase,    iconColor: undefined },
      { name: 'Cloud Functions',    desc: 'IoT event ingestion API',            si: siNodedotjs,   iconColor: undefined },
      { name: 'Firebase Auth',      desc: 'Secure admin authentication',        si: siGooglecloud, iconColor: undefined },
    ],
  },
  {
    id: 'apps',
    label: 'Applications',
    subtitle: 'User-facing layer',
    color: '#22c55e',
    items: [
      { name: 'Flutter App',     desc: 'Admin dashboard, analytics & voice control', si: siFlutter,    iconColor: undefined },
      { name: 'Next.js Website', desc: 'Marketing & public presence',                si: siNextdotjs,  iconColor: '#ffffff' },
    ],
  },
]

// ─── Main Component ────────────────────────────────────────────────────────────

export default function StackDiagram() {
  const [activeHw, setActiveHw] = useState<string | null>(null)
  const [activeTab, setActiveTab] = useState<'hardware' | 'software'>('hardware')
  const ref = useRef<HTMLDivElement>(null)
  const isInView = useInView(ref, { once: true, margin: '-80px' })

  const activeColor = HARDWARE.find(h => h.id === activeHw)?.color ?? '#22c55e'

  return (
    <section ref={ref} id="stack" className="py-28 relative overflow-hidden">

      {/* ── Circuit grid background ──────────────────────── */}
      <div className="absolute inset-0 pointer-events-none" style={{
        backgroundImage: `
          linear-gradient(rgba(34,197,94,0.028) 1px, transparent 1px),
          linear-gradient(90deg, rgba(34,197,94,0.028) 1px, transparent 1px)
        `,
        backgroundSize: '52px 52px',
      }} />
      <div className="absolute inset-0 pointer-events-none" style={{
        backgroundImage: `radial-gradient(circle, rgba(34,197,94,0.07) 1.2px, transparent 1.2px)`,
        backgroundSize: '52px 52px',
        backgroundPosition: '26px 26px',
      }} />
      <div className="absolute -top-48 -left-48 w-[500px] h-[500px] rounded-full pointer-events-none"
        style={{ background: 'radial-gradient(circle, rgba(99,102,241,0.07) 0%, transparent 70%)' }} />
      <div className="absolute -bottom-48 -right-48 w-[500px] h-[500px] rounded-full pointer-events-none"
        style={{ background: 'radial-gradient(circle, rgba(34,197,94,0.07) 0%, transparent 70%)' }} />

      <div className="max-w-7xl mx-auto px-6 relative z-10">

        {/* ── Section header ──────────────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.7, ease: [0.16, 1, 0.3, 1] }}
          className="text-center mb-16"
        >
          <span className="section-label">System Architecture</span>
          <h2 className="text-display-lg font-display font-extrabold mt-4">
            Hardware <span className="text-neutral-700">meets</span>{' '}
            <span className="gradient-text">Software.</span>
          </h2>
          <p className="text-neutral-400 max-w-xl mx-auto mt-5 text-base leading-relaxed">
            Six hardware components feed data into a three-layer cloud stack —
            all communicating in real time over WiFi.
          </p>
        </motion.div>

        {/* ── Mobile tab toggle ────────────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: 12 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.5, delay: 0.15 }}
          className="flex md:hidden mb-8 p-1 rounded-full border border-neutral-800 w-fit mx-auto"
        >
          {(['hardware', 'software'] as const).map(tab => (
            <button
              key={tab}
              onClick={() => setActiveTab(tab)}
              className="relative px-8 py-2.5 rounded-full text-xs font-mono uppercase tracking-widest transition-colors duration-200"
              style={{ color: activeTab === tab ? '#fff' : 'rgba(255,255,255,0.3)' }}
            >
              {activeTab === tab && (
                <motion.div layoutId="tab-pill"
                  className="absolute inset-0 rounded-full bg-neutral-800"
                  transition={{ type: 'spring', stiffness: 400, damping: 30 }}
                />
              )}
              <span className="relative z-10">{tab}</span>
            </button>
          ))}
        </motion.div>

        {/* ── Main two-panel layout ────────────────────────── */}
        <div className="flex flex-col md:flex-row gap-6 items-stretch">

          {/* ═══ HARDWARE PANEL ════════════════════════════ */}
          <motion.div
            initial={{ opacity: 0, x: -36 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className={`flex-1 flex-col ${activeTab === 'software' ? 'hidden md:flex' : 'flex'}`}
          >
            <div className="flex items-center gap-3 mb-6">
              <div className="h-px flex-1 bg-gradient-to-r from-transparent via-neutral-800 to-neutral-800" />
              <div className="flex items-center gap-2 px-4 py-2 rounded-full border border-neutral-800 bg-neutral-900/60">
                <div className="w-2 h-2 rounded-full bg-green-500" style={{ boxShadow: '0 0 8px #22c55e' }} />
                <span className="text-[11px] font-mono uppercase tracking-widest text-neutral-400">Hardware</span>
              </div>
              <div className="h-px flex-1 bg-gradient-to-l from-transparent via-neutral-800 to-neutral-800" />
            </div>

            <div className="grid grid-cols-2 gap-4 flex-1">
              {HARDWARE.map((hw, i) => {
                const isActive = activeHw === hw.id
                return (
                  <motion.div
                    key={hw.id}
                    initial={{ opacity: 0, y: 20 }}
                    animate={isInView ? { opacity: 1, y: 0 } : {}}
                    transition={{ duration: 0.5, delay: 0.3 + i * 0.07, ease: [0.16, 1, 0.3, 1] }}
                    onMouseEnter={() => setActiveHw(hw.id)}
                    onMouseLeave={() => setActiveHw(null)}
                    className="relative rounded-2xl border overflow-hidden cursor-default transition-all duration-300"
                    style={{
                      borderColor: isActive ? `${hw.color}55` : 'rgba(255,255,255,0.07)',
                      backgroundColor: isActive ? `${hw.color}08` : 'rgba(255,255,255,0.02)',
                      boxShadow: isActive ? `0 0 36px ${hw.color}14, inset 0 1px 0 ${hw.color}20` : 'none',
                    }}
                  >
                    <motion.div className="absolute top-0 left-0 w-20 h-20 pointer-events-none"
                      animate={{ opacity: isActive ? 1 : 0 }} transition={{ duration: 0.25 }}
                      style={{ background: `linear-gradient(135deg, ${hw.color}22 0%, transparent 65%)` }} />
                    <motion.div className="absolute bottom-0 left-0 right-0 h-px pointer-events-none"
                      animate={{ opacity: isActive ? 1 : 0 }}
                      style={{ background: `linear-gradient(90deg, transparent, ${hw.color}60, transparent)` }} />

                    <div className="h-[120px] flex items-center justify-center p-4 pt-5">
                      <hw.Svg color={hw.color} />
                    </div>

                    <div className="px-5 pb-5">
                      <div className="text-[10px] font-mono uppercase tracking-[0.25em] mb-1.5" style={{ color: hw.color }}>
                        {hw.role}
                      </div>
                      <div className="text-[15px] font-semibold text-white leading-snug tracking-tight">
                        {hw.name}
                      </div>
                      <p
                        className="overflow-hidden text-[12px] text-neutral-400 leading-relaxed"
                        style={{
                          maxHeight: isActive ? '80px' : '0',
                          opacity: isActive ? 1 : 0,
                          marginTop: isActive ? '10px' : '0',
                          transform: `translateY(${isActive ? 0 : 4}px)`,
                          transition: 'max-height 0.25s ease, opacity 0.2s ease, margin-top 0.25s ease, transform 0.2s ease',
                        }}
                      >
                        {hw.description}
                      </p>
                    </div>
                  </motion.div>
                )
              })}
            </div>
          </motion.div>

          {/* ═══ CENTER CONNECTOR — redesigned ════════════ */}
          <div className="hidden md:block w-20 relative flex-shrink-0">

            {/* Top line: hardware → node */}
            <div className="absolute left-1/2 -translate-x-1/2 top-[60px]"
              style={{
                width: 1,
                bottom: 'calc(50% + 32px)',
                background: `linear-gradient(to bottom, transparent, ${activeColor}70)`,
                transition: 'background 0.5s',
              }} />

            {/* Dots flowing IN (hardware → node): travel from top to just above center */}
            {[0, 1].map(i => (
              <motion.div
                key={`in-${i}-${activeColor}`}
                className="absolute rounded-full"
                style={{
                  width: 7, height: 7,
                  left: 'calc(50% - 3.5px)',
                  backgroundColor: activeColor,
                  boxShadow: `0 0 10px ${activeColor}, 0 0 20px ${activeColor}60`,
                }}
                animate={{
                  top: ['8%', '44%'],
                  opacity: [0, 0.9, 0.9, 0],
                  scale: [0.6, 1, 0.8, 0],
                }}
                transition={{
                  duration: 1.6,
                  delay: i * 1.7,
                  repeat: Infinity,
                  ease: [0.4, 0, 0.2, 1],
                }}
              />
            ))}

            {/* Center node — WiFi icon with breathing rings */}
            <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 z-10">
              {/* Breathing rings — 3 staggered */}
              {[0, 1, 2].map(i => (
                <motion.div
                  key={i}
                  className="absolute rounded-full border pointer-events-none"
                  style={{
                    inset: 0,
                    borderColor: activeColor,
                    borderWidth: 1,
                  }}
                  animate={{
                    scale: [1, 2.2 + i * 0.5],
                    opacity: [0.55, 0],
                  }}
                  transition={{
                    duration: 2.2,
                    delay: i * 0.65,
                    repeat: Infinity,
                    ease: 'easeOut',
                  }}
                />
              ))}
              {/* Icon circle */}
              <motion.div
                className="w-16 h-16 rounded-full border-2 flex items-center justify-center relative"
                animate={{
                  boxShadow: [
                    `0 0 16px ${activeColor}30, inset 0 0 12px ${activeColor}08`,
                    `0 0 32px ${activeColor}55, inset 0 0 20px ${activeColor}14`,
                    `0 0 16px ${activeColor}30, inset 0 0 12px ${activeColor}08`,
                  ],
                }}
                transition={{ duration: 2.5, repeat: Infinity, ease: 'easeInOut' }}
                style={{
                  borderColor: `${activeColor}55`,
                  backgroundColor: `${activeColor}12`,
                  transition: 'border-color 0.5s, background-color 0.5s',
                }}
              >
                <Wifi className="w-6 h-6 transition-colors duration-500" style={{ color: activeColor }} strokeWidth={1.5} />
              </motion.div>
            </div>

            {/* Dots flowing OUT (node → software): emerge from just below center */}
            {[0, 1].map(i => (
              <motion.div
                key={`out-${i}-${activeColor}`}
                className="absolute rounded-full"
                style={{
                  width: 7, height: 7,
                  left: 'calc(50% - 3.5px)',
                  backgroundColor: activeColor,
                  boxShadow: `0 0 10px ${activeColor}, 0 0 20px ${activeColor}60`,
                }}
                animate={{
                  top: ['56%', '92%'],
                  opacity: [0, 0.9, 0.9, 0],
                  scale: [0, 0.8, 1, 0.6],
                }}
                transition={{
                  duration: 1.6,
                  delay: 0.8 + i * 1.7,
                  repeat: Infinity,
                  ease: [0.4, 0, 0.2, 1],
                }}
              />
            ))}

            {/* Bottom line: node → software */}
            <div className="absolute left-1/2 -translate-x-1/2 bottom-[60px]"
              style={{
                width: 1,
                top: 'calc(50% + 32px)',
                background: `linear-gradient(to bottom, ${activeColor}70, transparent)`,
                transition: 'background 0.5s',
              }} />

            {/* Label */}
            <span
              className="absolute bottom-5 left-1/2 -translate-x-1/2 text-[8px] font-mono uppercase tracking-widest whitespace-nowrap transition-colors duration-500"
              style={{ color: `${activeColor}70` }}
            >
              WiFi
            </span>
          </div>

          {/* ═══ SOFTWARE PANEL ════════════════════════════ */}
          <motion.div
            initial={{ opacity: 0, x: 36 }}
            animate={isInView ? { opacity: 1, x: 0 } : {}}
            transition={{ duration: 0.7, delay: 0.2, ease: [0.16, 1, 0.3, 1] }}
            className={`flex-1 flex-col ${activeTab === 'hardware' ? 'hidden md:flex' : 'flex'}`}
          >
            <div className="flex items-center gap-3 mb-6">
              <div className="h-px flex-1 bg-gradient-to-r from-transparent via-neutral-800 to-neutral-800" />
              <div className="flex items-center gap-2 px-4 py-2 rounded-full border border-neutral-800 bg-neutral-900/60">
                <div className="w-2 h-2 rounded-full bg-indigo-400" style={{ boxShadow: '0 0 8px #6366f1' }} />
                <span className="text-[11px] font-mono uppercase tracking-widest text-neutral-400">Software</span>
              </div>
              <div className="h-px flex-1 bg-gradient-to-l from-transparent via-neutral-800 to-neutral-800" />
            </div>

            <div className="flex flex-col gap-4 flex-1">
              {SOFTWARE_LAYERS.map((layer, li) => (
                <motion.div
                  key={layer.id}
                  initial={{ opacity: 0, y: 20 }}
                  animate={isInView ? { opacity: 1, y: 0 } : {}}
                  transition={{ duration: 0.5, delay: 0.35 + li * 0.1, ease: [0.16, 1, 0.3, 1] }}
                  className="relative rounded-2xl border overflow-hidden"
                  style={{ borderColor: `${layer.color}25`, backgroundColor: `${layer.color}06` }}
                >
                  <div className="absolute top-0 left-0 right-0 h-px"
                    style={{ background: `linear-gradient(90deg, transparent, ${layer.color}50, transparent)` }} />

                  <div className="flex items-center gap-4 px-5 pt-5 pb-4">
                    <div className="w-1.5 h-10 rounded-full flex-shrink-0"
                      style={{ backgroundColor: layer.color, boxShadow: `0 0 12px ${layer.color}80` }} />
                    <div className="flex-1">
                      <div className="text-sm font-semibold text-white tracking-tight">{layer.label}</div>
                      <div className="text-xs font-mono text-neutral-500 uppercase tracking-widest mt-0.5">{layer.subtitle}</div>
                    </div>
                    <div className="text-xs font-mono tabular-nums px-3 py-1.5 rounded-full"
                      style={{ color: layer.color, backgroundColor: `${layer.color}14`, border: `1px solid ${layer.color}28` }}>
                      {String(li + 1).padStart(2, '0')}
                    </div>
                  </div>

                  <div className="mx-5 h-px mb-4" style={{ backgroundColor: `${layer.color}15` }} />

                  <div className="px-5 pb-5 flex flex-col gap-3">
                    {layer.items.map((item, ii) => (
                      <motion.div
                        key={item.name}
                        initial={{ opacity: 0, x: 12 }}
                        animate={isInView ? { opacity: 1, x: 0 } : {}}
                        transition={{ duration: 0.4, delay: 0.45 + li * 0.1 + ii * 0.07 }}
                        className="flex items-center gap-3.5"
                      >
                        {/* Brand icon container */}
                        <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 p-1.5"
                          style={{ backgroundColor: `${layer.color}14`, border: `1px solid ${layer.color}28` }}>
                          <SimpleIcon icon={item.si} size={22} color={item.iconColor} />
                        </div>
                        <div className="min-w-0 flex-1">
                          <div className="text-[13px] font-semibold text-neutral-200 leading-tight">{item.name}</div>
                          <div className="text-[11px] text-neutral-500 mt-0.5 leading-snug">{item.desc}</div>
                        </div>
                        <div className="w-2 h-2 rounded-full flex-shrink-0"
                          style={{ backgroundColor: layer.color, opacity: 0.5 }} />
                      </motion.div>
                    ))}
                  </div>
                </motion.div>
              ))}
            </div>
          </motion.div>
        </div>

        {/* ── Bottom stats strip ───────────────────────── */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6, delay: 0.75 }}
          className="mt-14 pt-10 border-t border-neutral-800/60 flex flex-wrap justify-center gap-10 md:gap-20"
        >
          {[
            { label: 'Hardware Components', value: '6',   color: '#22c55e' },
            { label: 'Software Services',   value: '7',   color: '#6366f1' },
            { label: 'Real-time Latency',   value: '<1s', color: '#10B981' },
            { label: 'Platforms',           value: '3',   color: '#F59E0B' },
          ].map((stat, i) => (
            <motion.div
              key={stat.label}
              initial={{ opacity: 0 }}
              animate={isInView ? { opacity: 1 } : {}}
              transition={{ duration: 0.4, delay: 0.8 + i * 0.07 }}
              className="flex flex-col items-center gap-1.5"
            >
              <span className="text-4xl font-display font-black tabular-nums"
                style={{ color: stat.color, textShadow: `0 0 30px ${stat.color}45` }}>
                {stat.value}
              </span>
              <span className="text-xs font-mono uppercase tracking-widest text-neutral-600">{stat.label}</span>
            </motion.div>
          ))}
        </motion.div>
      </div>
    </section>
  )
}
