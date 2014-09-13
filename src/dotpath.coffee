_ = require './helpers'

getPointer = (object, pathArray, init = no, last = null) ->
  pointer = object
  for component, index in pathArray
    unless _.isObject(pointer[component])
      return unless init
      nextComponent = pathArray[index + 1] ? last
      pointer[component] = if _.isNumber(nextComponent) then [] else {}
    pointer = pointer[component]
  pointer

getPathArray = (pathString) ->
  pathString.match(/(\w+)/g).map (substr) ->
    if substr.match(/^\d+$/) then parseInt(substr) else substr

getSubpaths = (pathString) ->
  rebuildPath = []
  subPaths = []
  for component in getPathArray pathString
    rebuildPath.push component
    subPaths.push rebuildPath.join '.'
  subPaths

module.exports = dotpath =
  get: (object, pathString) ->
    getPointer object, getPathArray pathString

  set: (object, pathString, value, init = yes) ->
    pathArray = getPathArray pathString
    end = pathArray.pop()
    pointer = getPointer object, pathArray, init, end
    pointer[end] = value

  clear: (object, pathString) ->
    delete dotpath.get object, pathString

  containsSubpath: (obj, pathString) ->
    keys = Object.keys obj
    for subpath in getSubpaths(pathString)
      return true if subpath in keys
