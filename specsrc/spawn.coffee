{describeTaskPromise} = require('task')

{Task, spawn} = require('backburner')

describe 'backburner.spawn', ->
    beforeEach ->
        @addMatchers {
            toBeATask: ->
                this.actual instanceof Task
            }

    # Ok, so, TaskPromise won't let us resolve/reject it and spawn doesn't
    # give us a way to do so.  The solution is to use the tickFn to do so, 
    # but that requires the scheduler to work.  So... some of these tests
    # will fail until you implement a scheduler.
###
    describeTaskPromise ->
            reject = false
            resolve = false
            resolveFn = ->
                resolve = true
            rejectFn = ->
                reject = true
            fn = ->
                if reject
                    @reject()
                else if resolve
                    @resolve()

            promise = spawn fn
            return [promise, resolveFn, rejectFn]
        , 'The result of spawn()'
###
