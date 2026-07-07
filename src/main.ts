import { VueQueryPlugin } from '@tanstack/vue-query'
import { MotionPlugin } from '@vueuse/motion'
import { createPinia } from 'pinia'
import { createApp } from 'vue'

import App from '@/App.vue'
import { i18n } from '@/i18n'
import { router } from '@/router'

import '@/styles/main.css'

const app = createApp(App)

app.use(createPinia())
app.use(router)
app.use(i18n)
app.use(VueQueryPlugin)
app.use(MotionPlugin)

app.mount('#app')
