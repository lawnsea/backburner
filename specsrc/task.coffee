{describeDeferred, describePromise} = require('deferred')

{Task} = require('backburner')
{Deferred} = require('backburner-deferred')

describeTaskPromise = (promiseFactory, name) ->
    [promise, resolveFn, rejectFn] = promiseFactory()
    name ?= promise.constructor.name
    describe name + ' implements TaskPromise and ', ->
        describePromise ->
            return promiseFactory()
exports.describeTaskPromise = describeTaskPromise

describe 'backburner.Task', ->
    # TODO: if anything public other than Task() returns a task, refactor as describeTask
    describeDeferred -> new Deferred

    it 'should require that the first argument to the constructor be a function', ->
        caught = false
        try
            new Task
        catch error
            caught = true
        expect(caught).toBe true

    it 'should provide access to itself in the context of the tick function', ->
        task = new Task ->
        expect(task._context.thisTask).toBe task
        task = new Task (->), {}
        expect(task._context.thisTask).toBe task

    describe 'runnable', ->
        it 'should default to false', ->
            task = new Task ->
            expect(task._runnable).toBe false

        it 'should be configurable', ->
            task = new Task (->), { runnable: false }
            expect(task._runnable).toBe false
            task = new Task (->), { runnable: true }
            expect(task._runnable).toBe true

    describe 'start', ->
        it 'should set _runnable to true', ->
            task = new Task ->
            task.start()
            expect(task._runnable).toBe true

    describe 'stop', ->
        it 'should set _runnable to false', ->
            task = new Task ->
            task.stop()
            expect(task._runnable).toBe false

    describe 'tick', ->
        it 'should call the function provided in the constructor', ->
            called = false
            fn = ->
                called = true
            task = new Task fn
            task.tick()
            expect(called).toBe true

        it 'should call the tick fn with the appropriate context', ->
            fn = ->
                expect(this).toBe task._context

            task = new Task fn
            task.tick()

    describe 'resolve', ->
        it 'should call success functions with the correct context', ->
            context = {}
            fn = ->
            task = new Task fn, {context: context}
            task.done ->
                expect(this).toBe context
            task.resolve()

        it 'should call success functions with the correct arguments', ->
            fn = ->
            task = new Task fn
            task.done (args...) ->
                expect(args[0]).toBe 23
                expect(args[1]).toBe 42
            task.resolve(23, 42)

    describe 'reject', ->
        it 'should call failure functions with the correct context', ->
            context = {}
            fn = ->
            task = new Task fn, {context: context}
            task.fail ->
                expect(this).toBe context
            task.reject()

        it 'should call failure functions with the correct arguments', ->
            fn = ->
            task = new Task fn
            task.fail (args...) ->
                expect(args[0]).toBe 23
                expect(args[1]).toBe 42
            task.reject(23, 42)

    describe 'promise', ->
            describeTaskPromise ->
                    fn = ->
                    task = new Task fn
                    return [task.promise(), (-> task.resolve()), (-> task.reject())]
                , 'The result of Task.promise()'

    #describe 'kill', ->

