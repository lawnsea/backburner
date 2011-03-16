class Promise
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

(exports ? this).Promise = Promise
