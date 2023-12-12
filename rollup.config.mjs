import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

export default [
  {
    input: "tables/application.js",
    output: [
      {
        name: "tables",
        file: "app/assets/builds/katalyst/tables.esm.js",
        format: "esm",
      },
      {
        file: "app/assets/builds/katalyst/tables.js",
        format: "es",
      },
    ],
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  },
  {
    input: "tables/application.js",
    output: {
      file: "app/assets/builds/katalyst/tables.min.js",
      format: "es",
      sourcemap: true,
    },
    context: "window",
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      terser({
        mangle: true,
        compress: true
      })
    ],
    external: ["@hotwired/stimulus", "@hotwired/turbo-rails"]
  }
]
