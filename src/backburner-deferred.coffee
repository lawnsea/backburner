{_} = require 'underscore'

class Deferred
    _rejected: false
    _resolved: false

    _successFns: []

    _failFns: []

    reject: (args...) ->
        @rejectWith.apply this, [this].concat args

    rejectWith: (context, args...) ->
        if @_rejected or @_resolved
            return
        @_rejected = true
        @_resolved = false
        @_thenContext = context
        @_thenArgs = args
        for fn in @_failFns
            fn.apply context, args

    resolve: (args...) ->
        @resolveWith.apply this, [this].concat args

    resolveWith: (context, args...) ->
        if @_rejected or @_resolved
            return
        @_rejected = false
        @_resolved = true
        @_thenContext = context
        @_thenArgs = args
        for fn in @_successFns
            fn.apply context, args

    then: (successFns, failFns) ->
        successFns ?= []
        failFns ?= []
        successFns = if _.isArray(successFns) then successFns else [successFns]
        failFns = if _.isArray(failFns) then failFns else [failFns]
        if @_rejected or @_resolved
            fns = if @_resolved then successFns else failFns
            for fn in fns
                fn.apply @_thenContext, @_thenArgs
        else
            @_successFns = @_successFns.concat successFns
            @_failFns = @_failFns.concat failFns

    done: (successFns) ->
        @then successFns

    fail: (failFns) ->
        @then [], failFns

    isRejected: ->
        @_rejected

    isResolved: ->
        @_resolved

    promise: ->
        that = this
        @_promise ?=
            then: (successFns, failFns) ->
                that.then successFns, failFns
            done: (successFns) ->
                that.done successFns
            fail: (failFns) ->
                that.fail failFns
            isRejected: ->
                that.isRejected()
            isResolved: ->
                that.isResolved()
        return @_promise

root.backburner ?= {}
root.backburner.Deferred = Deferred
if exports?
    exports.Deferred = Deferred
