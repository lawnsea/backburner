###
Backburner

(c) 2011 Lon Ingram
All rights reserved until I decide on a license
###

{Promise} = require('promise')
backburner = {}

# A Backburner Task represents some chunk of work that needs to be done
backburner.Task = class Task extends Promise
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
        @_context = if config.context? then config.context else {}
        @_context.thisTask = this
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

backburner.spawn = (fn, config) ->
    task = new Task fn, config
    task.start()
    return task

whileFn = ->
    try
        done = not @loopTestFn()
    catch e
        @rejectWith this, e

    if done
        @resolveWith this
    else
        try
            @loopBodyFn
        catch e
            @resolveWith this, e

backburner.while = (loopTestFn, loopBodyFn, context) ->
    context ?= {}
    context.loopTestFn = loopTestFn
    context.loopBodyFn = loopBodyFn
    backburner.spawn whileFn, { context: context }

(exports ? this).backburner = backburner
