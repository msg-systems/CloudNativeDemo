module.exports = {
  preset: '@vue/cli-plugin-unit-jest/presets/typescript-and-babel',
  moduleNameMapper: {
    // https://github.com/axios/axios/issues/5026
    "^axios$": "axios/dist/axios.js"
  }
};
