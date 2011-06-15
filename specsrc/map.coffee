{describeTaskPromise} = require 'task'
{describeIterationMethod} = require 'iteration'
{trackCalls} = require 'spec-utils'
WAIT_TIME = 1000

_ = require 'underscore'

backburner = require 'backburner'

describe 'backburner.map', ->
    backburner.killAll()
    afterEach ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            a = (n for n in [1..10])
            fn = ->
                if resolve
                    @thisTask.resolve()
                else if reject
                    @thisTask.reject()
            p = backburner.map a, fn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'

    describe 'accepts a body function', ->
        afterEach ->
            backburner.killAll()

        describeIterationMethod backburner.map, 'which'

        it 'should store the return value of the body function in the appropriate array element', ->
            context = {}
            a = (n for n in [1..10])
            bodyFn = (i, x, a2) ->
                return x + 1

            p = backburner.map a, bodyFn, context
            p.done (result) ->
                expect(this).toBe context
                expect(result[i]).toBe(i + 2) for i in [0..9]
            waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME

        it 'should store the return value of the body function in the appropriate object key', ->
            context = {}
            o =
                foo: 'bar'
                fiz: 'biz'
            bodyFn = (k, s, o2) ->
                return s.toUpperCase()

            p = backburner.map o, bodyFn, context
            p.done (result) ->
                expect(this).toBe context
                expect(result[k]).toBe(k + 2) for k in o
            waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
