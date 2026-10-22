const { defineConfig } = require("cypress");
module.exports = defineConfig({
  video: true,
  e2e: {
    specPattern: "integration/*",
    baseUrl: "http://127.0.0.1:8888",
    fixturesFolder: "fixtures",
    supportFile: false,
  },
});
