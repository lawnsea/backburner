class Deferred
    _rejected: false
    _resolved: false

    _successFns: []

    _failFns: []

    reject: (args...) ->
        @_rejected = true
        @_resolved = false
        for fn in @_failFns
            fn.apply this, args

    rejectWith: (context, args...) ->
        @reject.apply context, args

    resolve: (args...) ->
        @_rejected = false
        @_resolved = true
        for fn in @_successFns
            fn.apply this, args

    resolveWith: (context, args...) ->
        @resolve.apply context, args

    then: (successFns, failFns) ->
        successFns ?= []
        failFns ?= []
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

(exports ? this).Deferred = Deferred
