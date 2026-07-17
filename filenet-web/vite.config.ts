import path from 'node:path';
import { defineConfig } from 'vite';
import wasm from 'vite-plugin-wasm';
import react from '@vitejs/plugin-react';
import tailwindcss from '@tailwindcss/vite';
import { VitePWA } from 'vite-plugin-pwa';

// https://vite.dev/config/
export default defineConfig({
  plugins: [
    react(),
    wasm(),
    tailwindcss(),
    VitePWA({
      registerType: 'autoUpdate',
      // Data comes from local SQLite via PowerSync, not fetch — the service
      // worker only needs to precache the app shell (JS/CSS/WASM/fonts), not
      // proxy or cache any API traffic.
      workbox: {
        // wa-sqlite's WASM chunks (2-2.5MB) exceed Workbox's 2MB default —
        // without this they're silently skipped from precaching, which would
        // break the app's ability to boot at all while offline.
        maximumFileSizeToCacheInBytes: 6 * 1024 * 1024,
        navigateFallback: '/index.html',
        navigateFallbackDenylist: [/^\/rest\//, /^\/auth\//, /^\/storage\//, /^\/powersync\//]
      },
      manifest: {
        name: 'File Net',
        short_name: 'File Net',
        description: 'Share and manage files with your organization — works offline.',
        theme_color: '#50006c',
        background_color: '#ffffff',
        display: 'standalone',
        start_url: '/',
        icons: [
          { src: '/icons/icon.png', sizes: '192x192', type: 'image/png' },
          { src: '/icons/icon.png', sizes: '512x512', type: 'image/png' }
        ]
      }
    })
  ],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  worker: {
    format: 'es'
  },
  optimizeDeps: {
    // Don't optimize these packages as they contain web workers and WASM files.
    // https://github.com/vitejs/vite/issues/11672#issuecomment-1415820673
    exclude: ['@journeyapps/wa-sqlite', '@powersync/web'],
    include: []
  }
});
