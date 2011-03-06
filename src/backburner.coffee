###
Backburner

(c) 2011 Lon Ingram
All rights reserved until I decide on a license
###

backburner = {}

backburner.Task = class Task
    constructor: (@fn, config) ->
        config ?= {}
        @_context = if config.context? then config.context else {}
        @_runnable = config.runnable == true

    start: ->
        @_runnable = yes

    stop: ->
        @_runnable = no

backburner.spawn = ->
    throw 'Not implemented.'

backburner.while = ->
    throw 'Not implemented.'

(exports ? this).backburner = backburner
