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
    Array.isArray value

  last: (array) ->
    array[array.length - 1]

  ## [bb] ??
  defer: (args..., done) ->
    throw new TypeError('`defer` requires a callback') unless _.isFunction done
    args = [null, args...] # callback without an error
    setTimeout (-> done.apply undefined, args), 1

  times: (count, func) ->
    func(index) for index in [0...count]

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
