module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testTimeout: 30000,
  forceExit: true,
  maxWorkers: 1,
  modulePathIgnorePatterns: ["dist"],
};
