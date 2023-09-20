const { jestConfig } = require("./jest.config.js");
module.exports = {
  testRunner: "jest",
  coverageAnalysis: "off",
  timeoutMS: 60000,
  dryRunTimeoutMinutes: 20,
  concurrency: 7,
  tempDirName: "stryker-tmp",
  mutate: [
    "force-app/main/default/lwc/**/*.js",
    "!force-app/main/default/lwc/**/__tests__/*.*",
    "!force-app/main/default/lwc/**/__tests__/**/*.*"
  ],
  reporters: ["html", "progress", "dots", "clear-text"],
  thresholds: { high: 90, low: 85, break: 90 },
  mutator: {
    "excludedMutations": ["OptionalChaining"]
  },
  jest: {
    projectType: "custom",
    config: jestConfig,
    enableFindRelatedTests: true
  }
};