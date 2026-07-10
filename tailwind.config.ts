import type { Config } from 'tailwindcss'

export default {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{vue,ts}'],
  theme: {
    extend: {
      colors: {
        brand: {
          50: 'rgb(var(--color-brand-50) / <alpha-value>)',
          100: 'rgb(var(--color-brand-100) / <alpha-value>)',
          200: 'rgb(var(--color-brand-200) / <alpha-value>)',
          300: 'rgb(var(--color-brand-300) / <alpha-value>)',
          400: 'rgb(var(--color-brand-400) / <alpha-value>)',
          500: 'rgb(var(--color-brand-500) / <alpha-value>)',
          600: 'rgb(var(--color-brand-600) / <alpha-value>)',
          700: 'rgb(var(--color-brand-700) / <alpha-value>)',
          800: 'rgb(var(--color-brand-800) / <alpha-value>)',
          900: 'rgb(var(--color-brand-900) / <alpha-value>)',
          950: 'rgb(var(--color-brand-950) / <alpha-value>)',
        },
        accent: {
          50: 'rgb(var(--color-accent-50) / <alpha-value>)',
          100: 'rgb(var(--color-accent-100) / <alpha-value>)',
          200: 'rgb(var(--color-accent-200) / <alpha-value>)',
          300: 'rgb(var(--color-accent-300) / <alpha-value>)',
          400: 'rgb(var(--color-accent-400) / <alpha-value>)',
          500: 'rgb(var(--color-accent-500) / <alpha-value>)',
          600: 'rgb(var(--color-accent-600) / <alpha-value>)',
          700: 'rgb(var(--color-accent-700) / <alpha-value>)',
        },
        success: {
          50: 'rgb(var(--color-success-50) / <alpha-value>)',
          100: 'rgb(var(--color-success-100) / <alpha-value>)',
          500: 'rgb(var(--color-success-500) / <alpha-value>)',
          600: 'rgb(var(--color-success-600) / <alpha-value>)',
          700: 'rgb(var(--color-success-700) / <alpha-value>)',
        },
        surface: {
          DEFAULT: 'rgb(var(--color-surface) / <alpha-value>)',
          raised: 'rgb(var(--color-surface-raised) / <alpha-value>)',
          sunken: 'rgb(var(--color-surface-sunken) / <alpha-value>)',
        },
        border: {
          DEFAULT: 'rgb(var(--color-border) / <alpha-value>)',
        },
      },
      fontFamily: {
        sans: ['"Inter Variable"', '"Inter"', 'system-ui', 'sans-serif'],
        display: [
          '"Space Grotesk Variable"',
          '"Space Grotesk"',
          '"Inter Variable"',
          'system-ui',
          'sans-serif',
        ],
      },
      borderRadius: {
        xl: '0.875rem',
        '2xl': '1.5rem',
        '3xl': '1.75rem',
      },
      boxShadow: {
        soft: '0 1px 2px 0 rgb(15 23 42 / 0.04), 0 8px 24px -8px rgb(15 23 42 / 0.10)',
        'soft-lg': '0 4px 8px 0 rgb(15 23 42 / 0.04), 0 16px 40px -12px rgb(15 23 42 / 0.16)',
        'glow-accent': '0 0 0 1px rgb(245 158 11 / 0.4), 0 8px 24px -8px rgb(245 158 11 / 0.35)',
        'glow-brand': '0 0 0 1px rgb(79 70 229 / 0.3), 0 12px 32px -8px rgb(79 70 229 / 0.4)',
      },
      keyframes: {
        blob: {
          '0%, 100%': { transform: 'translate(0, 0) scale(1)' },
          '33%': { transform: 'translate(4%, -6%) scale(1.08)' },
          '66%': { transform: 'translate(-3%, 4%) scale(0.95)' },
        },
        marquee: {
          '0%': { transform: 'translateX(0)' },
          '100%': { transform: 'translateX(-50%)' },
        },
        'gradient-pan': {
          '0%, 100%': { backgroundPosition: '0% 50%' },
          '50%': { backgroundPosition: '100% 50%' },
        },
        float: {
          '0%, 100%': { transform: 'translateY(0) rotate(-1.5deg)' },
          '50%': { transform: 'translateY(-14px) rotate(1deg)' },
        },
        'pulse-soft': {
          '0%, 100%': { opacity: '0.55', transform: 'scale(1)' },
          '50%': { opacity: '0.15', transform: 'scale(1.12)' },
        },
        'stamp-pop': {
          '0%': { transform: 'scale(1)' },
          '40%': { transform: 'scale(1.18)' },
          '100%': { transform: 'scale(1)' },
        },
        'stamp-fall': {
          '0%': { transform: 'translateY(-120px) rotate(-30deg) scale(0.85)', opacity: '0' },
          '55%': { opacity: '1' },
          '100%': { transform: 'translateY(0) rotate(-8deg) scale(1)', opacity: '1' },
        },
        'particle-burst': {
          '0%': { transform: 'translate(0, 0) scale(1)', opacity: '1' },
          '100%': {
            transform: 'translate(var(--particle-x, 40px), var(--particle-y, -40px)) scale(0)',
            opacity: '0',
          },
        },
        'card-glow-pulse': {
          '0%, 100%': { boxShadow: '0 0 0 0 rgb(245 158 11 / 0)' },
          '50%': { boxShadow: '0 0 0 10px rgb(245 158 11 / 0.15)' },
        },
      },
      animation: {
        blob: 'blob 14s ease-in-out infinite',
        marquee: 'marquee 32s linear infinite',
        'gradient-pan': 'gradient-pan 8s ease infinite',
        float: 'float 6s ease-in-out infinite',
        'pulse-soft': 'pulse-soft 2.6s ease-in-out infinite',
        'stamp-pop': 'stamp-pop 0.5s cubic-bezier(0.34, 1.56, 0.64, 1)',
        'stamp-fall': 'stamp-fall 0.7s cubic-bezier(0.34, 1.56, 0.64, 1) forwards',
        'particle-burst': 'particle-burst 0.6s ease-out forwards',
        'card-glow-pulse': 'card-glow-pulse 1.1s ease-out',
      },
    },
  },
  plugins: [],
} satisfies Config
