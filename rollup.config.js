import generatePackageJson from 'rollup-plugin-generate-package-json';
import copy from 'rollup-plugin-copy';

export default {
  input: 'dist/esm/index.js',
  output: {
    file: 'dist/plugin.js',
    globals: {
      '@capacitor/core': 'capacitorExports',
    },
    sourcemap: true,
  },
  plugins: [
    generatePackageJson({
      baseContents: ({ scripts, ...pkg }) => pkg,
    }),
    copy({
      targets: [
        { src: 'ios', dest: 'dist' },
        { src: 'android', dest: 'dist' },
        { src: '*.podspec', dest: 'dist' },
        { src: 'README.md', dest: 'dist' },
      ],
    }),
  ],
};
