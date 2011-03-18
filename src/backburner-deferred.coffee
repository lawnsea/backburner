class Deferred
    _rejected: false
    _resolved: true

    _successFns: []

    _failFns: []

    reject: (args...) ->
        for fn in @_failFns
            fn.apply this, args

    rejectWith: (context, args...) ->
        @reject.apply context, args

    resolve: (args...) ->
        for fn in @_successFns
            fn.apply this, args

    resolveWith: (context, args...) ->
        @resolve.apply context, args

    then: (successFns, failFns) ->
        successFns ?= []
        failFns ?= []
        @_successFns.concat successFns
        @_failFns.concat failFns

    done: (successFns) ->
        @then successFns

    fail: (failFns) ->
        @then [], failFns

    isRejected: ->
        @_rejected

    isResolved: ->
        @_resolved

    promise: ->
        @_promise ?=
            then: @then
            done: @done
            fail: @fail
            isRejected: @isRejected
            isResolved: @isResolved
        return @_promise

(exports ? this).Deferred = Deferred
