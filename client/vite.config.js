import { defineConfig } from 'vite'
import { resolve } from 'path'

export default defineConfig({
  server: {
    port: 3002,
    proxy: {
      '/api': 'http://localhost:3001'
    }
  },
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'src/pages/index.html'),
        exercises: resolve(__dirname, 'src/pages/exercises.html'),
        profile: resolve(__dirname, 'src/pages/profile.html'),
        notfound: resolve(__dirname, 'src/pages/404.html')
      }
    },
    outDir: 'dist',
    emptyOutDir: true
  }
})