import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { globSync } from 'glob';

const entries = globSync([
  'web/themes/custom/**/*.{ts,tsx}',
  'web/modules/custom/**/*.{ts,tsx}',
]);

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  build: {
    manifest: true,
    emptyOutDir: true,
    rollupOptions: {
      input: entries,
      output: {
        dir: 'web/libraries',
        entryFileNames: `[name].js`,
        chunkFileNames: `chunks/[name].[hash].js`,
        assetFileNames: `[name].[ext]`,
      },
    },
  },
})
