toString = Object::toString

module.exports = _ =
  isFunction: (value) ->
    typeof value is 'function'

  isObject: (value) ->
    !!(value and typeof value in ['function', 'object'])

  isNumber: (value) ->
    typeof value is 'number' or
    value and
    typeof value is 'object' and
    toString.call(value) is '[object Number]' or
    false

  isArray: (value) ->
    value and
    typeof value is 'object' and
    typeof value.length is 'number'
    toString.call(value) is '[object Array]' or
    false

  last: (array) ->
    array[array.length - 1]

  defer: (func, args...) ->
    throw new TypeError unless _.isFunction func
    setTimeout (-> func.apply undefined, args), 1

  asyncRepeat: (count, func, done) ->
    completed = 0
    output = new Array count
    errored = false
    for index in [0...count]
      func index, (err, value) ->
        return if errored
        if err?
          errored = true
          return done(err)
        completed += 1
        output[index] = value
        done(null, output) if completed is count
