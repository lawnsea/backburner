###
Backburner

(c) 2011 Lon Ingram
All rights reserved until I decide on a license
###

backburner = {}

# A Backburner Task represents some chunk of work that needs to be done
backburner.Task = class Task
    # Construct a new Task
    #
    # - **fn** The function that will do this Task's work.  Required.  This Task is
    #          made available in fn as this.thisTask
    # - **config** Optional configuration object
    #   - **config.context** An object that will be the value of *this* in **fn**
    #   - **config.runnable** If true, the task can be scheduled immediately
    constructor: (fn, config) ->
        if not fn? then throw 'Task requires a function to call on each tick'
        config ?= {}
        @_context = if config.context? then config.context else { thisTask: this }
        @_runnable = config.runnable == true
        @_tickFn = fn

    # Make this task runnable
    start: ->
        @_runnable = yes

    # Make this task unrunnable
    stop: ->
        @_runnable = no

    # Run this task's tick function once
    tick: ->
        @_tickFn.call @_context

backburner.spawn = ->
    throw 'Not implemented.'

backburner.while = ->
    throw 'Not implemented.'

(exports ? this).backburner = backburner
