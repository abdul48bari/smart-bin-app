import type { Metadata } from 'next'
import { GeistSans } from 'geist/font/sans'
import { GeistMono } from 'geist/font/mono'
import { Outfit } from 'next/font/google'
import './globals.css'

const outfit = Outfit({
  subsets: ['latin'],
  variable: '--font-outfit',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Reclevo — Smart Waste, Smarter Future',
  description: 'AI-powered smart garbage bin that automatically sorts waste into 5 categories. Real-time monitoring, analytics, and voice control.',
  openGraph: {
    title: 'Reclevo — Smart Waste, Smarter Future',
    description: 'AI-powered smart garbage bin that automatically sorts waste into 5 categories.',
    type: 'website',
  },
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={`dark ${GeistSans.variable} ${GeistMono.variable} ${outfit.variable}`}>
      <body className="grain">
        {children}
      </body>
    </html>
  )
}
