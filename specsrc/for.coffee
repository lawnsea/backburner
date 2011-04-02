{describeTaskPromise} = require('task')
{trackCalls} = require('spec-utils')
WAIT_TIME = 1000

backburner = require('backburner')

describe 'backburner.for', ->
    backburner.killAll()
    afterEach ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            setupFn = ->
            testFn = ->
                if reject
                    throw 'done'
                return not resolve
            iterateFn = ->
            bodyFn = ->
            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'

    describe 'accepts a setup function', ->
        afterEach ->
            backburner.killAll()

        it 'should be called before any other functions', ->
            setupFn = trackCalls ->
                expect(testFn.called).not.toBe true
                expect(iterateFn.called).not.toBe true
                expect(bodyFn.called).not.toBe true
            testFn = trackCalls()
            iterateFn = trackCalls()
            bodyFn = trackCalls()

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> setupFn.called), 'setupFn to be called', WAIT_TIME

        it 'should be called exactly once', ->
            setupFn = trackCalls()
            testFn = trackCalls ->
                return true
            iterateFn = trackCalls()
            bodyFn = trackCalls()

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> testFn.called), 'testFn to be called', WAIT_TIME
            runs ->
                delete setupFn.called
            waitsFor (-> testFn.called), 'testFn to be called again', WAIT_TIME
            runs ->
                expect(setupFn.called).not.toBe true

        it 'should be called with the provided context', ->
            context = {}
            setupFn = trackCalls ->
                expect(this).toBe context
            fn = ->

            p = backburner.for setupFn, fn, fn, fn, context
            waitsFor (-> setupFn.called), 'setupFn to be called', WAIT_TIME

        it 'should rejectWith the correct context and pass the error if it throws', ->
            e = 'foo'
            context = {}
            setupFn = trackCalls ->
                throw e
            fn = ->

            p = backburner.for setupFn, fn, fn, fn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

    describe 'accepts a test function', ->
        afterEach ->
            backburner.killAll()

        it 'should be called after setup and before other functions', ->
            setupFn = trackCalls()
            testFn = trackCalls ->
                expect(setupFn.called).toBe true
                expect(iterateFn.called).not.toBe true
                expect(bodyFn.called).not.toBe true
            iterateFn = trackCalls()
            bodyFn = trackCalls()

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> testFn.called), 'testFn to be called', WAIT_TIME

        it 'should be called with the provided context', ->
            context = {}
            testFn = trackCalls ->
                expect(this).toBe context
            fn = ->

            p = backburner.for fn, testFn, fn, fn, context
            waitsFor (-> testFn.called), 'testFn to be called', WAIT_TIME

        it 'should not resolve or reject if it returns true', ->
            testFn = trackCalls ->
                return true
            fn = ->

            p = backburner.for fn, testFn, fn, fn
            waitsFor (-> testFn.called), 'testFn to be called', WAIT_TIME
            runs ->
                expect(p.isResolved()).not.toBe true
                expect(p.isRejected()).not.toBe true

        it 'should resolveWith the provided context immediately if it does not return true', ->
            context = {}
            testFn = trackCalls()
            iterateFn = trackCalls()
            bodyFn = trackCalls()
            fn = ->

            p = backburner.for fn, testFn, iterateFn, bodyFn, context
            p.done ->
                expect(this).toBe context
            waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
            runs ->
                expect(iterateFn.called).not.toBe true
                expect(bodyFn.called).not.toBe true

        it 'should rejectWith the correct context and pass the error if it throws', ->
            e = 'foo'
            context = {}
            testFn = trackCalls ->
                throw e
            fn = ->

            p = backburner.for fn, testFn, fn, fn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

        it 'should be called after the iterate function', ->
            setupFn = trackCalls()
            testFn = trackCalls ->
                return true
            iterateFn = trackCalls()
            bodyFn = trackCalls()

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> testFn.called), 'testFn to be called', WAIT_TIME
            waitsFor (-> testFn.called), 'testFn to be called again', WAIT_TIME
            runs ->
                expect(iterateFn.called).toBe true

    describe 'accepts an iterate function', ->
        afterEach ->
            backburner.killAll()

        it 'should be called after all other functions', ->
            setupFn = trackCalls()
            testFn = trackCalls ->
                true
            iterateFn = trackCalls ->
                expect(setupFn.called).toBe true
                expect(testFn.called).toBe true
                expect(bodyFn.called).toBe true
            bodyFn = trackCalls()

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> iterateFn.called), 'iterateFn to be called', WAIT_TIME

        it 'should be called with the provided context', ->
            context = {}
            iterateFn = trackCalls ->
                expect(this).toBe context
            fn = ->
                true

            p = backburner.for fn, fn, iterateFn, fn, context
            waitsFor (-> iterateFn.called), 'iterateFn to be called', WAIT_TIME

        it 'should rejectWith the correct context and pass the error if it throws', ->
            e = 'foo'
            context = {}
            iterateFn = trackCalls ->
                throw e
            fn = ->
                true

            p = backburner.for fn, fn, iterateFn, fn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

    describe 'accepts a body function', ->
        afterEach ->
            debugger
            backburner.killAll()

        it 'should be called after setup and test and before the iterate function', ->
            setupFn = trackCalls()
            testFn = trackCalls ->
                true
            iterateFn = trackCalls()
            bodyFn = trackCalls ->
                expect(setupFn.called).toBe true
                expect(testFn.called).toBe true
                expect(iterateFn.called).not.toBe true

            p = backburner.for setupFn, testFn, iterateFn, bodyFn
            waitsFor (-> bodyFn.called), 'bodyFn to be called', WAIT_TIME

        it 'should be called with the provided context', ->
            context = {}
            bodyFn = trackCalls ->
                expect(this).toBe context
            fn = ->
                true

            p = backburner.for fn, fn, fn, bodyFn, context
            waitsFor (-> bodyFn.called), 'bodyFn to be called', WAIT_TIME

        it 'should rejectWith the correct context and pass the error if it throws', ->
            e = 'foo'
            context = {}
            bodyFn = trackCalls ->
                throw e
            fn = ->
                true

            p = backburner.for fn, fn, fn, bodyFn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

    it 'should behave as expected in a simple loop', ->
        context =
            callCount: 0
        setupFn = ->
            @i = 0
        testFn = ->
            return @i < 10
        iterateFn = ->
            @i++
        bodyFn = ->
            @callCount++

        p = backburner.for setupFn, testFn, iterateFn, bodyFn, context
        p.done ->
            expect(@callCount).toBe 10
        waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
