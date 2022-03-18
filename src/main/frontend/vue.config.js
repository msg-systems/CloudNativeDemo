process.env.VUE_APP_VERSION = process.env.VERSION;

module.exports = {
  pages: {
    index: {
      entry: 'src/main.ts',
      title: 'CN-App',
    },
  },
  devServer: {
    proxy: {
      '^/': {
        target: 'http://localhost:8910',
        changeOrigin: true,
      },
    },
  },
};
