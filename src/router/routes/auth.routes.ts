import type { RouteRecordRaw } from 'vue-router'

export const authRoutes: RouteRecordRaw[] = [
  {
    path: '/auth',
    component: () => import('@/layouts/AuthLayout.vue'),
    meta: { guestOnly: true },
    children: [
      {
        path: 'login',
        name: 'auth-login',
        component: () => import('@/pages/auth/LoginPage.vue'),
      },
      {
        path: 'register',
        name: 'auth-register',
        component: () => import('@/pages/auth/RegisterPage.vue'),
      },
      {
        path: 'forgot-password',
        name: 'auth-forgot-password',
        component: () => import('@/pages/auth/ForgotPasswordPage.vue'),
      },
      {
        path: 'reset-password',
        name: 'auth-reset-password',
        component: () => import('@/pages/auth/ResetPasswordPage.vue'),
        meta: { guestOnly: false },
      },
    ],
  },
]
