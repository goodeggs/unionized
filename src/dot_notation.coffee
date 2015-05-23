module.exports = class DotNotation
  @bracketNotationToDotNotation: (pathString) ->
    pathString.replace /\[(.+?)\]/g, '.$1'
  constructor: (pathString) ->
    pathString = DotNotation.bracketNotationToDotNotation(pathString)
    [pathString, @first, @rest] = pathString.match /^(.+?)(?:\.(.*))?$/
  param: ->
    if @isArrayLength()
      @first.substring(0, @first.length - 2)
    else
      @first
  childPathString: -> @rest
  isArrayLength: -> @first.match /\[\]$/
  isLeaf: -> not @childPathString()

