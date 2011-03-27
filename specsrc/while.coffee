{describeTaskPromise} = require('task')
WAIT_TIME = 50

backburner = require('backburner')

callTrackingFn = ->
    return ->
        arguments.callee.called = true

describe 'backburner.while', ->
    beforeEach = ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            loopFn = ->
            testFn = ->
                if reject
                    throw 'done'
                return not resolve
            p = backburner.while testFn, loopFn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'The result of while()'

    it 'should call the loop body if the loop test returns true', ->
        testFn = ->
            return true
        bodyFn = callTrackingFn()
        p = backburner.while testFn, bodyFn
        p.fail (e) ->
            expect(bodyFn.called).toBe true
        waits WAIT_TIME

    it 'should resolve if the loop test returns false', ->
        testFn = ->
            return false
        bodyFn = ->
        resolved = false
        p = backburner.while testFn, bodyFn
        p.done (e) ->
            resolved = true
        waits WAIT_TIME
        runs ->
            expect(resolved).toBe true

    it 'should reject and pass the error if the loop test throws', ->
        testFn = ->
            throw 42
        bodyFn = ->
        p = backburner.while testFn, bodyFn
        p.fail (e) ->
            expect(e).toBe 42
        waits WAIT_TIME

    it 'should reject and pass the error if the loop body throws', ->
        testFn = ->
            return true
        bodyFn = ->
            throw 42
        p = backburner.while testFn, bodyFn
        p.fail (e) ->
            expect(e).toBe 42
        waits WAIT_TIME
