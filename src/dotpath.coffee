getPointer = (object, pathArray, init = no) ->
  pointer = object
  for component in pathArray
    if init and typeof pointer[component] isnt 'object'
      pointer[component] = {}
    pointer = pointer[component]
  pointer

getPathArray = (pathString) ->
  pathString.split '.'

module.exports = dotpath =
  get: (object, pathString) ->
    getPointer object, getPathArray pathString

  set: (object, pathString, value, init = yes) ->
    pathArray = getPathArray pathString
    end = pathArray.pop()
    pointer = getPointer object, pathArray, init
    pointer[end] = value

  clear: (object, pathString) ->
    delete dotpath.get object, pathString

  subpaths: (pathString) ->
    rebuildPath = []
    subPaths = []
    for component in getPathArray pathString
      rebuildPath.push component
      subPaths.push rebuildPath.join '.'
    subPaths
