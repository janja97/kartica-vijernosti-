<script setup lang="ts"></script>

<template>
  <main
    class="relative flex min-h-screen flex-col items-center justify-center overflow-hidden px-6 text-center"
  >
    <div
      class="pointer-events-none absolute left-1/2 top-1/3 h-[26rem] w-[26rem] -translate-x-1/2 animate-blob rounded-full bg-brand-400/20 blur-3xl dark:bg-brand-500/15"
    />

    <p class="relative text-gradient text-7xl font-bold tracking-tight sm:text-8xl">404</p>
    <h1 class="relative mt-4 font-display text-xl font-semibold text-slate-900 dark:text-white">
      Ova stranica ne postoji
    </h1>
    <p class="relative mt-2 max-w-sm text-sm text-slate-500 dark:text-slate-400">
      Stranica koju tražiš je premještena ili nikad nije postojala.
    </p>

    <RouterLink
      to="/"
      class="relative mt-8 rounded-lg bg-brand-600 px-6 py-3 text-sm font-semibold text-white shadow-lg shadow-brand-600/25 transition-transform duration-200 hover:-translate-y-0.5 hover:bg-brand-700"
    >
      Natrag na početnu
    </RouterLink>
  </main>
</template>
