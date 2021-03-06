{describeTaskPromise} = require('task')
{trackCalls} = require('spec-utils')
WAIT_TIME = 1000

backburner = require('backburner')

describe 'backburner.while', ->
    backburner.killAll()
    afterEach ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            bodyFn = ->
            testFn = ->
                if reject
                    throw 'done'
                return not resolve
            p = backburner.while testFn, bodyFn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'

    it 'should call the loop test with the provided context', ->
        context = {}
        testFn = trackCalls ->
            expect(this).toBe context
            @thisTask.resolve()
        bodyFn = ->

        p = backburner.while testFn, bodyFn, context
        waitsFor (-> p.isResolved()), 'testFn was never called', WAIT_TIME

    it 'should call the loop body if the loop test returns true', ->
        testFn = ->
            return true
        bodyFn = trackCalls()
        p = backburner.while testFn, bodyFn
        waitsFor (-> bodyFn.called), 'bodyFn was never called', WAIT_TIME
        runs ->
            expect(bodyFn.called).toBe true

    it 'should not call the loop body if the loop test returns false', ->
        called = false
        testFn = trackCalls ->
            return false
        bodyFn = trackCalls()
        p = backburner.while testFn, bodyFn
        p.done (e) ->
            expect(bodyFn.called).not.toBe true
        waitsFor (-> testFn.called), 'testFn was never called', WAIT_TIME

    it 'should call the loop body with the provided context', ->
        context = {}
        testFn = ->
            return true
        bodyFn = trackCalls ->
            expect(this).toBe context
            @thisTask.resolve()

        p = backburner.while testFn, bodyFn, context
        waitsFor (-> p.isResolved()), 'bodyFn was never called', WAIT_TIME

    it 'should resolve if the loop test returns false', ->
        testFn = trackCalls ->
            return false
        bodyFn = ->
        p = backburner.while testFn, bodyFn
        waitsFor (-> testFn.called), 'testFn was never called', WAIT_TIME
        runs ->
            expect(p.isResolved()).toBe true

    it 'should not resolve or reject if the loop test returns true', ->
        testFn = ->
            return true
        bodyFn = trackCalls()
        p = backburner.while testFn, bodyFn
        waitsFor (-> bodyFn.called), 'bodyFn was never called', WAIT_TIME
        runs ->
            expect(p.isResolved()).not.toBe true
            expect(p.isRejected()).not.toBe true

    it 'should rejectWith the passed context and pass the error if the loop test throws', ->
        context = {}
        testFn = trackCalls ->
            throw 42
        bodyFn = ->
        p = backburner.while testFn, bodyFn, context
        p.fail (e) ->
            expect(e).toBe 42
            expect(this).toBe context
        waitsFor (-> testFn.called), 'testFn was never called', WAIT_TIME
        runs ->
            expect(p.isRejected()).toBe true

    it 'should rejectWith the passed context and pass the error if the loop body throws', ->
        context = {}
        testFn = trackCalls ->
            return true
        bodyFn = ->
            throw 42
        p = backburner.while testFn, bodyFn, context
        p.fail (e) ->
            expect(e).toBe 42
            expect(this).toBe context
        waitsFor (-> testFn.called), 'testFn was never called', WAIT_TIME
        runs ->
            expect(p.isRejected()).toBe true

    it 'should behave as expected in a simple loop', ->
        context =
            i: 0
        testFn = ->
            @i < 23
        bodyFn = ->
            @i += 1
        p = backburner.while testFn, bodyFn, context
        p.done (e) ->
            expect(@i).toBe 23
        waitsFor p.isResolved

