###
Backburner

(c) 2011 Lon Ingram
All rights reserved until I decide on a license
###

backburner = {}

backburner.Task = class Task
    constructor: (@context) ->

backburner.spawn = ->
    throw 'Not implemented.'

backburner.while = ->
    throw 'Not implemented.'

(exports ? this).backburner = backburner
