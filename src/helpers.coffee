module.exports = _ =
  last: (array) ->
    array[array.length - 1]
  isFunction: (value) ->
    typeof value is 'function'
  defer: (func, args...) ->
    throw new TypeError unless _.isFunction func
    setTimeout (-> func.apply undefined, args), 1
