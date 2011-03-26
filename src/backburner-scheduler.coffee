taskpool = []
handle = null
curTask = 0
period = 5
running = false
autostart = true

scheduleLoopFn = ->
    handle = setTimeout loopFn, period

unscheduleLoopFn = ->
    clearTimeout handle
    handle = null

nextTask = ->
    curTask++
    curTask %= taskpool.length

loopFn = ->
    if taskpool.length < 1
        return scheduleLoopFn()
        
    startTask = curTask
    while not taskpool[curTask].isRunnable()
        nextTask()
        if curTask is startTask
            return scheduleLoopFn()
    taskpool[curTask].tick()
    scheduleLoopFn()
    nextTask()

exec = (task) ->
    taskpool.push task
    if not running and autostart
        start()

start = ->
    running = true
    scheduleLoopFn()

stop = ->
    running = false

(exports ? this).scheduler =
    exec: exec
    start: start
    stop: stop
    isRunning: ->
        running is true
    autostart: (newAutostart) ->
        autostart = newAutostart is true
        return autostart
    period: (newPeriod) ->
        if newPeriod instanceof Number and newPeriod >= 0
            period = newPeriod
        return period
