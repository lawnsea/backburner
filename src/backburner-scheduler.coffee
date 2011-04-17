root = this
taskpool = []
taskindex = {}
handle = null
curTask = 0
nextTaskId = 0
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
    until taskpool[curTask].isRunnable()
        nextTask()
        if curTask is startTask
            return scheduleLoopFn()
    taskpool[curTask].tick()
    scheduleLoopFn()
    if taskpool.length > 0
        nextTask()

exec = (task) ->
    task.__schedulerId = nextTaskId
    taskindex[nextTaskId] = taskpool.length
    taskpool.push task
    nextTaskId++
    if not running and autostart
        start()

start = ->
    running = true
    scheduleLoopFn()

stop = ->
    running = false
    unscheduleLoopFn()

kill = (tasks...) ->
    for task in tasks
        if not task.__schedulerId?
            # TODO: think about throwing here instead of failing silently
            continue
        i = taskindex[task.__schedulerId]
        taskpool.splice i, 1
        delete taskindex[task.__schedulerId]
        delete task.__schedulerId

        for own id, index of taskindex
            if index > i
                taskindex[id]--

        if curTask >= taskpool.length
            curTask = 0

        # TODO: decide on a place to define a constant for this
        task.reject 'killed'
        
killAll = ->
    taskpool = []
    taskindex = {}
    curTask = 0
    if autostart
        stop()

scheduler =
    exec: exec
    start: start
    stop: stop
    kill: kill
    killAll: killAll
    isRunning: ->
        running is true
    autostart: (newAutostart) ->
        autostart = newAutostart is true
        return autostart
    period: (newPeriod) ->
        if newPeriod instanceof Number and newPeriod >= 0
            period = newPeriod
        return period

root.backburner ?= {}
root.backburner.scheduler = scheduler
if exports?
    exports.scheduler = scheduler
