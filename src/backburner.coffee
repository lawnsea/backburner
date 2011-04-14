###
Backburner
###
root = this

{Deferred} = require 'backburner-deferred'
{scheduler} = require 'backburner-scheduler'
{_} = require 'underscore'

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

    # Resolve this task
    resolve: (args...) ->
        return @resolveWith @_context, args...

    # Resolve this task with the provided context
    resolveWith: (context, args...) ->
        if @isRejected() or @isResolved()
            return
        r = super context, args...
        @kill()
        return r

    # Reject this task
    reject: (args...) ->
        return @rejectWith @_context, args...

    # Reject this task with the provided context
    rejectWith: (context, args...) ->
        if @isRejected() or @isResolved()
            return
        r = super context, args...
        @kill()
        return r

    # Return the TaskPromise for this Task
    promise: ->
        that = this
        if not @_promise?
            super()
            @_promise.kill = -> that.kill()
        return @_promise

    # Kill this task
    kill: ->
        scheduler.kill this

backburner.spawn = (fn, config) ->
    task = new Task fn, config
    task.start()
    scheduler.exec task
    return task.promise()

whileFn = ->
    try
        done = not @_whileTestFn()
    catch e
        @thisTask.rejectWith this, e

    if done
        @thisTask.resolveWith this
    else
        try
            @_whileBodyFn()
        catch e
            @thisTask.rejectWith this, e

backburner.while = (testFn, bodyFn, context) ->
    context ?= {}
    context._whileTestFn = testFn
    context._whileBodyFn = bodyFn
    backburner.spawn whileFn, { context: context }

forFn = ->
    try
        @_forBodyFn()
    catch e
        @thisTask.rejectWith this, e

    try
        @_forIterateFn()
    catch e
        @thisTask.rejectWith this, e

backburner.for = (setupFn, testFn, iterateFn, bodyFn, context) ->
    context ?= {}
    context._forIterateFn = iterateFn
    context._forBodyFn = bodyFn
    p = backburner.while testFn, forFn, context
    try
        setupFn.call context
    catch e
        context.thisTask.rejectWith context, e
    return p

eachArraySetupFn = ->
    @_index = 0
    @_len = @_v.length

eachArrayTestFn = ->
    @_index < @_len

eachArrayIterateFn = ->
    @_index++

eachArrayFn = ->
    if @_eachBodyFn(@_index, @_v[@_index]) is false
        @thisTask.rejectWith this

eachObjectSetupFn = ->
    @_index = 0
    @_keys = _.keys @_v
    @_len = @_keys.length

eachObjectTestFn = ->
    @_index < @_len

eachObjectIterateFn = ->
    @_index++

eachObjectFn = ->
    k = @_keys[@_index]
    if @_eachBodyFn(k, @_v[k]) is false
        @thisTask.rejectWith this

backburner.each = (v, bodyFn, context) ->
    # XXX: we're assuming that v is unmodified after this call, document that
    context ?= {}
    context._v = v
    context._eachBodyFn = bodyFn
    if _.isArray v
        p = backburner.for eachArraySetupFn,
            eachArrayTestFn,
            eachArrayIterateFn,
            eachArrayFn,
            context
    else
        p = backburner.for eachObjectSetupFn,
            eachObjectTestFn,
            eachObjectIterateFn,
            eachObjectFn,
            context
    return p

backburner.killAll = ->
    scheduler.killAll()

root.backburner ?= {}
root.backburner[k] = v for own k, v of backburner
if exports?
    exports[k] = v for own k, v of backburner
