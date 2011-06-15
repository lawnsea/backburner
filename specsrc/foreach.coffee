{describeTaskPromise} = require 'task'
{describeIterationMethod} = require 'iteration'
{trackCalls} = require 'spec-utils'
WAIT_TIME = 1000

_ = require 'underscore'

backburner = require 'backburner'

describe 'backburner.forEach', ->
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
            p = backburner.forEach a, fn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'

    describe 'accepts a body function', ->
        afterEach ->
            backburner.killAll()

        describeIterationMethod backburner.forEach, 'which'

        # XXX: are we sure this what we want to do?
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

            p = backburner.forEach a, bodyFn, context
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
        p = backburner.forEach a, bodyFn, context
        p.done ->
            sum = 0
            sum += x for x in [1..10]
            expect(@sum).toBe sum
        waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
