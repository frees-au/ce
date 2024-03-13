const { defineConfig } = require("cypress");
module.exports = defineConfig({
  video: true,
  e2e: {
    specPattern: "integration/*",
    baseUrl: "https://fs-web.ddev.site",
    fixturesFolder: "fixtures",
    supportFile: false,
  },
});
