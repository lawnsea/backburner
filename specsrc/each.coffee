{describeTaskPromise} = require 'task'
{trackCalls} = require 'spec-utils'
WAIT_TIME = 1000

_ = require 'underscore'

backburner = require 'backburner'

describe 'backburner.each', ->
    backburner.killAll()
    afterEach ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            a = (n for n in [1..10])
            fn = (i, v) ->
                if resolve
                    @thisTask.resolve()
                else if reject
                    @thisTask.reject()
            p = backburner.each a, fn
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

            p = backburner.each [42], bodyFn, context
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME

        it 'should be called with each index and value of a passed array, in order', ->
            a = [23, 42, 'fiz', 'biz']
            context =
                i: 0
            bodyFn = trackCalls (i, v) ->
                expect(i).toBe @i
                expect(v).toBe a[@i]
                @i++
            p = backburner.each a, bodyFn, context
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

        it 'should be called with each key and value of a passed object', ->
            o =
                a: 1
                b: 2
                c: 3
            seen = {}
            seen[k] = false for k of o
            bodyFn = trackCalls (k, v) ->
                expect(k of o).toBe true
                expect(seen[k]).toBe false
                seen[k] = true
                expect(v).toBe o[k]
            p = backburner.each o, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(seen[k]).toBe true for k of o

        it 'should resolve immediately if passed an empty object or array', ->
            a = []
            o = {}
            bodyFn = trackCalls()
            p = backburner.each a, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).not.toBe true
                delete bodyFn.called
                p = backburner.each o, bodyFn
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

            p = backburner.each a, bodyFn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
                expect(a[0]).toBe true
                expect(a[1]).toBe false
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

        it 'should rejectWith the correct context and pass nothing if the body fn returns false', ->
            a = [false, false]
            e = 'foo'
            context =
                i: 0
            bodyFn = ->
                if @i > 0
                    return false
                a[@i] = true
                @i++

            p = backburner.each a, bodyFn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe undefined
                expect(a[0]).toBe true
                expect(a[1]).toBe false
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

    it 'should behave as expected when passed a simple fn and array', ->
        a = (x for x in [1..10])
        context =
            sum: 0
        bodyFn = (i, v) ->
            @sum += v
        p = backburner.each a, bodyFn, context
        p.done ->
            sum = 0
            sum += x for x in [1..10]
            expect(@sum).toBe sum
        waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
