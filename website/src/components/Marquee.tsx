'use client'

const WORDS = [
  'AI-Powered', 'Automatic Sorting', 'Real-Time Monitoring', '5 Categories',
  'Smart Analytics', 'Voice Control', 'Eco-Friendly', 'IoT Connected',
  'Camera Detection', 'Cloud Synced', 'Cross-Platform', 'Firebase Backend',
]

export default function Marquee() {
  return (
    <div className="py-5 overflow-hidden border-y border-neutral-800/50">
      <div className="animate-marquee flex whitespace-nowrap">
        {[...WORDS, ...WORDS, ...WORDS].map((word, i) => (
          <span key={i} className="flex items-center gap-6 mx-6 text-sm font-mono uppercase tracking-wider text-neutral-700">
            <span>{word}</span>
            <span className="w-1 h-1 rounded-full bg-accent/40" />
          </span>
        ))}
      </div>
    </div>
  )
}
