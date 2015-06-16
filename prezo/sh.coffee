module.exports = (sh) ->
  require('child_process').exec(sh).stdout.pipe(process.stdout)
