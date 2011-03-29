trackCalls = (fn) ->
    fn ?= ->
    return ->
        arguments.callee.called = true
        return fn.apply this, arguments

exports.trackCalls = trackCalls
