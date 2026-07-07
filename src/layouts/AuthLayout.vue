<script setup lang="ts"></script>

<template>
  <div
    class="relative flex min-h-screen items-center justify-center overflow-hidden bg-surface px-4 py-12"
  >
    <div
      class="pointer-events-none absolute -top-32 left-[10%] h-[28rem] w-[28rem] animate-blob rounded-full bg-brand-400/20 blur-3xl dark:bg-brand-500/15"
    />
    <div
      class="pointer-events-none absolute bottom-[-8rem] right-[8%] h-[26rem] w-[26rem] animate-blob rounded-full bg-accent-300/20 blur-3xl [animation-delay:4s] dark:bg-accent-400/10"
    />

    <RouterView />
  </div>
</template>
