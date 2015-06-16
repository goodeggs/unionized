chalk = require 'chalk'

global.it = (name, fn) ->
  console.error "it #{chalk.blue name}"

  try
    fn()
  catch e
    console.error "  ⛔  #{chalk.red 'FAILED'}"
    console.error e.stack
    process.exit 1

  console.error "  ✔  #{chalk.green 'SUCCESS'}"

global.expect = require('chai').expect
