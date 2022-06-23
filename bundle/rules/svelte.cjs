const { sass } = require('svelte-preprocess-sass')
const { reactivePreprocess } = require('svelte-reactive-preprocessor')
const { alias } = require('../resolve.cjs')

module.exports = mode => {
  const prod = mode === 'production'
  const dev = !prod
  return [
    {
      test: /\.svelte$/,
      type: 'javascript/auto',
      use: [
        {
          loader: 'svelte-loader',
          options: {
            compilerOptions: {
              dev,
            },
            hotReload: dev,
            // Only emit in production to get the page to reload on style change in development
            emitCss: prod,
            preprocess: {
              // Should only set `script` if enabled
              ...reactivePreprocess({ enabled: dev }),
              style: sass({
                importer: [
                  resolveScssAlias,
                ],
              }),
            }
          },
        }
      ],
    },
    {
      // Required to prevent errors from Svelte on Webpack 5+
      // as recommended by https://github.com/sveltejs/svelte-loader#usage
      test: /node_modules\/svelte\/.*\.mjs$/,
      resolve: {
        fullySpecified: false
      }
    }
  ])
}

// Inspired by https://github.com/sveltejs/svelte-preprocess/issues/97#issuecomment-551842456
const resolveScssAlias = path => {
  if (path[0] !== '#') return path
  const segment = path.split('/')[0]
  return {
    file: path.replace(segment, alias[segment])
  }
}
