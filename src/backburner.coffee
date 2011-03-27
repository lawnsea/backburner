###
Backburner

(c) 2011 Lon Ingram
All rights reserved until I decide on a license
###
{Deferred} = require 'backburner-deferred'
{scheduler} = require 'backburner-scheduler'
backburner = {}

# A Backburner Task represents some chunk of work that needs to be done
backburner.Task = class Task extends Deferred
    # Construct a new Task
    #
    # - **fn** The function that will do this Task's work.  Required.  A reference
    #          to this Task is made available in fn as this.thisTask
    # - **config** Optional configuration object
    #   - **config.context** An object that will be the value of *this* in **fn**
    #   - **config.runnable** If true, the task can be scheduled immediately
    constructor: (fn, config) ->
        #@then()
        if not fn? then throw 'Task requires a function to call on each tick'
        config ?= {}
        @_context = if config.context? then config.context else {}
        @_context.thisTask = this
        @_runnable = config.runnable == true
        @_tickFn = fn

    # Returns true if this task is runnable
    isRunnable: ->
        return @_runnable is true

    # Make this task runnable
    start: ->
        @_runnable = yes
        return this

    # Make this task unrunnable
    stop: ->
        @_runnable = no
        return this

    # Run this task's tick function once
    tick: ->
        @_tickFn.call @_context
        return this

    # Return the TaskPromise for this Task
    promise: ->
        if not @_promise?
            super
            # TODO: join and kill
        return @_promise

backburner.spawn = (fn, config) ->
    task = new Task fn, config
    task.start()
    scheduler.exec task
    return task.promise()

whileFn = ->
    try
        done = not @_loopTestFn()
    catch e
        @rejectWith this, e

    if done
        @resolveWith this
    else
        try
            @_loopBodyFn
        catch e
            @rejectWith this, e

backburner.while = (loopTestFn, loopBodyFn, context) ->
    context ?= {}
    context._loopTestFn = loopTestFn
    context._loopBodyFn = loopBodyFn
    backburner.spawn whileFn, { context: context }

(exports ? this).Task = backburner.Task
(exports ? this).spawn = backburner.spawn
(exports ? this).while = backburner.while
