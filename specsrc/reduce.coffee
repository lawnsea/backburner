{describeTaskPromise} = require 'task'
{trackCalls} = require 'spec-utils'
WAIT_TIME = 1000

_ = require 'underscore'

backburner = require 'backburner'

describe 'backburner.reduce', ->
    backburner.killAll()
    afterEach ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            a = (n for n in [1..10])
            fn = (v) ->
                if resolve
                    @thisTask.resolve()
                else if reject
                    @thisTask.reject()
            p = backburner.reduce 42, a, fn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'

    describe 'accepts a body function', ->
        afterEach ->
            backburner.killAll()

        it 'should be called with the provided context', ->
            context = {}
            bodyFn = trackCalls ->
                expect(this).toBe context
                @thisTask.resolve()
            fn = ->

            p = backburner.reduce 42, [23], bodyFn, context
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME

        it 'should be called with each value of a passed array, in order', ->
            a = [23, 42, 'fiz', 'biz']
            context =
                i: 0
            bodyFn = trackCalls (currentValue, v) ->
                expect(v).toBe a[@i]
                @i++
            p = backburner.reduce 42, a, bodyFn, context
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

        it 'should be called with each value of a passed object', ->
            o =
                a: 1
                b: 2
                c: 3
            keys = (k for k of o)
            seen = {}
            seen[k] = false for k of o
            context =
                i: 0
            bodyFn = trackCalls (currentValue, v) ->
                k = keys[@i]
                expect(seen[k]).toBe false
                seen[k] = true
                expect(v).toBe o[k]
                @i++
            p = backburner.reduce 42, o, bodyFn, context
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(seen[k]).toBe true for k of o

        it 'should resolve immediately and return the initial value if passed an empty object or array', ->
            a = []
            o = {}
            bodyFn = trackCalls()
            p = backburner.reduce 42, a, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            p.done (result) ->
                expect(result).toBe 42
            runs ->
                expect(bodyFn.called).not.toBe true
                delete bodyFn.called
                p = backburner.reduce 42, o, bodyFn
                p.done (result) ->
                    expect(result).toBe 42
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).not.toBe true

        it 'should rejectWith the correct context and pass the error if the body fn throws', ->
            a = [false, false]
            e = 'foo'
            context =
                i: 0
            bodyFn = ->
                if @i > 0
                    throw e
                a[@i] = true
                @i++

            p = backburner.reduce 42, a, bodyFn, context
            p.fail (err) ->
                expect(@).toBe context
                expect(err).toBe e
                expect(a[0]).toBe true
                expect(a[1]).toBe false
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

        it 'should pass the result as the first argument when resolving', ->
            context = {}
            a = (n for n in [1..10])
            bodyFn = (currentValue, x) ->
                return currentValue + x

            p = backburner.reduce 42, a, bodyFn, context
            p.done (result) ->
                sum = 42
                sum += i for i in [1..10]
                expect(this).toBe context
                expect(result).toBe sum
            waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME

    it 'should behave as expected when passed a simple fn and array', ->
        a = (x for x in [1..10])
        bodyFn = (currentValue, v) ->
            return currentValue + v
        p = backburner.reduce 'foo', a, bodyFn
        p.done (result) ->
            sum = 'foo'
            sum += x for x in [1..10]
            expect(result).toBe sum
        waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
