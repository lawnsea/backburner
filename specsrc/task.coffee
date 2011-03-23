{describeDeferred, describePromise} = require('deferred')

{backburner} = require('backburner')
{Deferred} = require('backburner-deferred')

Task = backburner.Task

describeTaskPromise = (promiseFactory, name) ->
    [promise, resolveFn, rejectFn] = promiseFactory()
    name ?= promise.constructor.name
    describe name + ' implements TaskPromise and ', ->
        describePromise ->
            return promiseFactory()
exports.describeTaskPromise = describeTaskPromise

describe 'backburner.Task', ->
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

    describe 'promise', ->
            beforeEach ->
                fn = ->
                task = new Task fn

            describeTaskPromise ->
                    fn = ->
                    task = new Task fn
                    return [task.promise(), (-> task.resolve()), (-> task.reject())]
                , 'The result of Task.promise()'

