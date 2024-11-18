import { resolve } from 'path';

export default {
  build: {
    manifest: true,
    emptyOutDir: true,
    rollupOptions: {
      input: [
        "/src/js/main.js",
      ],
      // Remove the [hash] since Drupal will take care of that.
      output: {
        entryFileNames: `[name].js`,
        chunkFileNames: `chunks/[name].[hash].js`,
        assetFileNames: `[name].[ext]`,
      },
    },
  },
  resolve: {
    alias: {
      $images: resolve('./images')
    }
  },
}