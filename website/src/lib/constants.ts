import { Cpu, Cloud, Smartphone, Trash2, Camera, Brain, ArrowDownToLine, BarChart3, Mic, Bell, Shield, Blocks, Server, Wrench, Database } from 'lucide-react'

export const NAV_LINKS = [
  { label: 'About', href: '#about' },
  { label: 'Process', href: '#how-it-works' },
  { label: 'Features', href: '#features' },
  { label: 'Technology', href: '#tech' },
  { label: 'Team', href: '#team' },
]

export const DEMO_APP_URL = 'https://smart-bin-app-eta.vercel.app'

export const STATS = [
  { value: 5, label: 'Waste Categories', suffix: '' },
  { value: 99, label: 'Sort Accuracy', suffix: '%' },
  { value: 24, label: 'Monitoring', suffix: '/7' },
]

export const IMPACT_STATS = [
  { value: 2.01, label: 'Billion tonnes of waste generated yearly', suffix: 'B', prefix: '' },
  { value: 33, label: 'Of waste is not managed properly', suffix: '%', prefix: '' },
  { value: 13, label: 'Of waste is recycled globally', suffix: '%', prefix: 'Only ' },
]

export const HOW_IT_WORKS_STEPS = [
  {
    icon: Trash2,
    title: 'Throw Trash',
    description: 'Simply dispose your waste into the Reclevo bin — no sorting needed on your end.',
    color: '#22c55e',
    number: '01',
  },
  {
    icon: Camera,
    title: 'Camera Detects',
    description: 'A built-in camera captures the waste item as it enters the bin.',
    color: '#6366f1',
    number: '02',
  },
  {
    icon: Brain,
    title: 'AI Classifies',
    description: 'Our AI model identifies the waste type — plastic, paper, organic, cans, or mixed.',
    color: '#8B5CF6',
    number: '03',
  },
  {
    icon: ArrowDownToLine,
    title: 'Auto-Sorts',
    description: 'The bin automatically routes each item to its correct compartment.',
    color: '#10B981',
    number: '04',
  },
  {
    icon: Smartphone,
    title: 'Data to App',
    description: 'Fill levels, analytics, and alerts are sent to the Reclevo app in real time.',
    color: '#F59E0B',
    number: '05',
  },
]

export const FEATURES = [
  {
    icon: BarChart3,
    title: 'Real-Time Monitoring',
    description: 'Track fill levels of every sub-bin live. Know exactly when bins need emptying.',
    color: '#22c55e',
    tag: 'Analytics',
  },
  {
    icon: Camera,
    title: 'AI Classification',
    description: 'Camera-powered waste detection classifies trash into 5 categories automatically.',
    color: '#6366f1',
    tag: 'AI/ML',
  },
  {
    icon: Brain,
    title: 'Smart Analytics',
    description: 'Insights on waste patterns, collection efficiency, and environmental impact.',
    color: '#8B5CF6',
    tag: 'Insights',
  },
  {
    icon: Mic,
    title: 'Voice Assistant',
    description: 'Ask about bin status, fill levels, and alerts — completely hands-free.',
    color: '#10B981',
    tag: 'Voice',
  },
  {
    icon: Bell,
    title: 'Instant Alerts',
    description: 'Get notified when bins are full or hardware issues arise. Never miss a pickup.',
    color: '#F59E0B',
    tag: 'Alerts',
  },
  {
    icon: Shield,
    title: 'Secure & Reliable',
    description: 'Firebase authentication, encrypted data transfer, and 99.9% uptime guarantee.',
    color: '#ef4444',
    tag: 'Security',
  },
]

export const TECH_STACK = [
  {
    category: 'AI & ML',
    icon: Brain,
    items: ['TensorFlow Lite', 'Image Classification', 'Real-time Detection'],
    color: '#8B5CF6',
    description: 'Neural networks trained on waste imagery for instant classification',
  },
  {
    category: 'IoT Hardware',
    icon: Cpu,
    items: ['Raspberry Pi', 'Ultrasonic Sensors', 'Camera Module'],
    color: '#F59E0B',
    description: 'Custom hardware assembly with precision sensors and controllers',
  },
  {
    category: 'Cloud',
    icon: Cloud,
    items: ['Firebase Firestore', 'Cloud Functions', 'Authentication'],
    color: '#6366f1',
    description: 'Serverless backend with real-time sync and secure API endpoints',
  },
  {
    category: 'Mobile App',
    icon: Smartphone,
    items: ['Flutter', 'Cross-Platform', 'Voice Control'],
    color: '#22c55e',
    description: 'Beautiful cross-platform app with voice assistant integration',
  },
]

export const TEAM = [
  {
    name: 'Abdul Bari',
    role: 'Mobile App Developer',
    description: 'Full UI/UX design and Flutter mobile application development for both Android and iOS platforms. Helped build the Reclevo website and guided the hardware team with code framework implementation.',
    initials: 'AB',
    color: '#22c55e',
    icon: Smartphone,
  },
  {
    name: 'Asim',
    role: 'Backend & Web Developer',
    description: 'Firebase backend connectivity, REST API integration, voice command feature in the app, and designed and built the Reclevo marketing website (with support from Abdul Bari) and helped with AI model dataset collection.',
    initials: 'AS',
    color: '#8B5CF6',
    icon: Server,
  },
  {
    name: 'Mohammed Amer',
    role: 'System Architect',
    description: 'System architecture design, component diagrams, test plan design, and test case execution. Performed User Acceptance Testing (UAT) of the Reclevo smart bin application.',
    initials: 'AM',
    color: '#6366f1',
    icon: Blocks,
  },
  {
    name: 'Danish',
    role: 'AI/ML Engineer',
    description: 'Custom dataset collection, developed the production training and classification pipeline, and evaluation of the waste detection model. Testing AI detection and real time application updates.',
    initials: 'DN',
    color: '#10B981',
    icon: Brain,
  },
  {
    name: 'Ishita',
    role: 'Project Lead & Hardware Engineer',
    description: 'Overall project coordination and strategist to lead group to meet deadlines, requirements analysis, hardware assembly of the Reclevo Smart Bin prototype.',
    initials: 'IS',
    color: '#F59E0B',
    icon: Wrench,
  },
  {
    name: 'Nathan',
    role: 'IoT & Systems Developer',
    description: 'Raspberry Pi control software, hardware-software bridging, and overall system integration (with team support). Helped with marketing poster designing and proofread all documents before submissions.',
    initials: 'NT',
    color: '#ef4444',
    icon: Cpu,
  },
  {
    name: 'Arham',
    role: 'AI/ML Engineer',
    description: 'Developed the initial MobileNetV2 training script and software implementation of the detection and classification pipeline on the Raspberry Pi. Marketing poster designing and posting.',
    initials: 'AR',
    color: '#ec4899',
    icon: Database,
  },
]

export const CATEGORY_COLORS: Record<string, string> = {
  plastic: '#E8703A', // Orange
  paper: '#4E80EE',   // Blue
  organic: '#D4A017', // Yellow
  cans: '#6B7280',    // Gray
  mixed: '#8B5CF6',   // Purple
}
