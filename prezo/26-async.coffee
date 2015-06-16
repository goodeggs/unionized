unionized = require 'unionized'
fs = require 'fs'

sourceCodeFactory = unionized.factory
  src: unionized.async (cb) -> fs.readFile(__filename, encoding: 'utf-8', cb)

sourceCodeFactory.createAsync (err, val) ->
  console.log val.src
  # (WOO, THIS IS A QUINE!)
