import dynamic from 'next/dynamic'
import Navbar from '@/components/Navbar'
import Hero from '@/components/Hero'
import Marquee from '@/components/Marquee'
import About from '@/components/About'
import HowItWorks from '@/components/HowItWorks'
import Features from '@/components/Features'
import TechStack from '@/components/TechStack'
import AppPreview from '@/components/AppPreview'
import Team from '@/components/Team'
import Footer from '@/components/Footer'

const CursorFollower = dynamic(() => import('@/components/CursorFollower'), { ssr: false })
const SmoothScroll = dynamic(() => import('@/components/SmoothScroll'), { ssr: false })

export default function Home() {
  return (
    <main>
      <SmoothScroll />
      <CursorFollower />
      <Navbar />
      <Hero />
      <Marquee />
      <About />
      <HowItWorks />
      <Features />
      <TechStack />
      <AppPreview />
      <Team />
      <Footer />
    </main>
  )
}
