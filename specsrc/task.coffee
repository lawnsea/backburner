{describeDeferred, describePromise} = require('deferred')
{trackCalls} = require('spec-utils')
WAIT_TIME = 1000

{Task, spawn} = require('backburner')
{Deferred} = require('backburner-deferred')

describeTaskPromise = (promiseFactory, name) ->
    [promise, resolveFn, rejectFn] = promiseFactory()
    name ?= promise.constructor.name
    if name isnt ''
        name += ' '
    describe name + 'implements TaskPromise', ->
        describePromise ->
            return promiseFactory()
        , 'which'

    describe name + 'provides kill', ->
        # XXX: this test is implementation-specific, which is not the best, but I don't 
        #      know another way right now...
        it 'should kill the task in question', ->
            p = spawn ->
            p.kill()
            waitsFor (-> p.isRejected()), 'the task to be rejected', WAIT_TIME

exports.describeTaskPromise = describeTaskPromise

describe 'backburner.Task', ->
    # TODO: if anything public other than Task() returns a task, refactor as describeTask
    describeDeferred ->
        new Deferred
    , ''

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

    describe 'has config property "runnable"', ->
        it 'should default to false', ->
            task = new Task ->
            expect(task._runnable).toBe false

        it 'should be configurable', ->
            task = new Task (->), { runnable: false }
            expect(task._runnable).toBe false
            task = new Task (->), { runnable: true }
            expect(task._runnable).toBe true

    describe 'provides start', ->
        it 'should set _runnable to true', ->
            task = new Task ->
            task.start()
            expect(task._runnable).toBe true

    describe 'provides stop', ->
        it 'should set _runnable to false', ->
            task = new Task ->
            task.stop()
            expect(task._runnable).toBe false

    describe 'provides tick', ->
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

    describe 'provides resolve', ->
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

        it 'should kill the task in question', ->
            task = new Task ->
            task.kill = trackCalls()
            task.resolve()
            expect(task.kill.called).toBe true

    describe 'provides reject', ->
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

        it 'should kill the task in question', ->
            task = new Task ->
            task.kill = trackCalls()
            task.reject()
            expect(task.kill.called).toBe true

    describe 'provides promise', ->
            describeTaskPromise ->
                    fn = ->
                    task = new Task fn
                    return [task.promise(), (-> task.resolve()), (-> task.reject())]
                , 'which returns a promise that'
