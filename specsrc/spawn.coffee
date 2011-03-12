{backburner} = require('backburner')
{Task, spawn} = backburner

describe 'backburner.spawn', ->
    beforeEach ->
        @addMatchers {
            toBeATask: ->
                this.actual instanceof Task
            }

    it 'should accept a function and optional config and return a runnable Task', ->
        fn = ->
        context = {}
        task = spawn fn, { context: context }
        expect(task).toBeATask()
        expect(task._tickFn).toBe fn
        expect(task._context).toBe context
        expect(task._runnable).toBe true
