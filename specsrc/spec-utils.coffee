root = this
trackCalls = (fn) ->
    fn ?= ->
    return ->
        arguments.callee.called = true
        return fn.apply this, arguments

root.backburner ?= {}
root.backburner.trackCalls = trackCalls
if exports?
    exports.trackCalls = trackCalls
