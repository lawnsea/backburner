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
            fn = ->
                if resolve
                    @thisTask.resolve()
                else if reject
                    @thisTask.reject()
            p = backburner.reduce a, fn
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

            p = backburner.reduce [23], bodyFn, 42, context
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME

        it 'should be called with the passed array', ->
            a = [42, 23]
            bodyFn = trackCalls (prev, curr, i, a2) ->
                expect(a2).toBe a
                @thisTask.resolve()

            p = backburner.reduce a, bodyFn
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

        it 'should be called with the passed object', ->
            o =
                foo: 'bar'
                fiz: 'biz'
            bodyFn = trackCalls (prev, curr, k, o2) ->
                expect(o2).toBe o
                @thisTask.resolve()

            p = backburner.reduce o, bodyFn
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

        describe 'and if called with an initial value', ->
            it 'should pass it as prev and the first element of a passed array as curr', ->
                a = [23, 42]
                bodyFn = trackCalls (prev, curr) ->
                    expect(prev).toBe 1337
                    expect(curr).toBe a[0]
                    @thisTask.resolve()

                p = backburner.reduce a, bodyFn, 1337
                waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

            it 'should pass it as prev and the first element of a passed object as curr', ->
                # XXX: this test depends on the implementation detail of how we
                # generate the keys to iterate over
                o =
                    a: 1
                    b: 2
                    c: 3
                keys = (k for k of o)
                bodyFn = trackCalls (prev, curr) ->
                    expect(prev).toBe 42
                    expect(curr).toBe o[keys[0]]
                    @thisTask.resolve()

                p = backburner.reduce o, bodyFn, 42
                waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

            it 'should resolve immediately and return it if passed an empty object or array', ->
                a = []
                o = {}
                bodyFn = trackCalls()
                p = backburner.reduce a, bodyFn, 42
                p.done (result) ->
                    expect(result).toBe 42
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

                runs ->
                    expect(bodyFn.called).not.toBe true
                    delete bodyFn.called
                    p = backburner.reduce o, bodyFn, 42
                    p.done (result) ->
                        expect(result).toBe 42
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

                runs ->
                    expect(bodyFn.called).not.toBe true

            it 'should be called with each value of a passed array, in order', ->
                a = [23, 42, 'fiz', 'biz']
                context =
                    i: 0
                bodyFn = trackCalls (prev, curr) ->
                    expect(curr).toBe a[@i]
                    @i++

                p = backburner.reduce a, bodyFn, 1337, context
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

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
                bodyFn = trackCalls (prev, curr) ->
                    k = keys[@i]
                    expect(seen[k]).toBe false
                    seen[k] = true
                    expect(curr).toBe o[k]
                    @i++

                p = backburner.reduce o, bodyFn, 42, context
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
                runs ->
                    expect(seen[k]).toBe true for k of o

        describe 'and if called without an initial value', ->
            it 'should pass the first and second elements of the passed array as prev and curr', ->
                a = [23, 42]
                bodyFn = trackCalls (prev, curr) ->
                    expect(prev).toBe a[0]
                    expect(curr).toBe a[1]
                    @thisTask.resolve()

                p = backburner.reduce a, bodyFn
                waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

            it 'should pass the first and second keys of the passed object as prev and curr', ->
                # XXX: this test depends on the implementation detail of how we
                # generate the keys to iterate over
                o =
                    a: 1
                    b: 2
                    c: 3
                keys = (k for k of o)
                bodyFn = trackCalls (prev, curr) ->
                    expect(prev).toBe o[keys[0]]
                    expect(curr).toBe o[keys[1]]
                    @thisTask.resolve()

                p = backburner.reduce o, bodyFn
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

            it 'should throw a TypeError if passed an empty object or array', ->
                bodyFn = trackCalls()
                fn = ->
                    backburner.reduce [], bodyFn
                expect(fn).toThrow(
                    TypeError('Reduce of empty array with no initial value'))
                fn = ->
                    backburner.reduce {}, bodyFn
                expect(fn).toThrow(
                    TypeError('Reduce of empty object with no initial value'))

            it 'should resolve immediately and return it if passed an object or array with only 
            one key or element', ->
                a = [42]
                o = { foo: 'bar' }
                bodyFn = trackCalls()
                p = backburner.reduce a, bodyFn
                p.done (result) ->
                    expect(result).toBe 42
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

                runs ->
                    expect(bodyFn.called).not.toBe true
                    delete bodyFn.called
                    p = backburner.reduce o, bodyFn
                    p.done (result) ->
                        expect(result).toBe 'bar'
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME

                runs ->
                    expect(bodyFn.called).not.toBe true

            it 'should be called with each value of a passed array, in order', ->
                a = [23, 42, 'fiz', 'biz']
                context =
                    i: 1
                bodyFn = trackCalls (prev, curr) ->
                    expect(curr).toBe a[@i]
                    @i++

                p = backburner.reduce a, bodyFn, undefined, context
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
                runs ->
                    expect(bodyFn.called).toBe true

            it 'should be called with each value of a passed object', ->
                o =
                    a: 1
                    b: 2
                    c: 3
                keys = (k for k of o)
                seen = {}
                seen[k] = false for k of o
                context =
                    i: 1
                bodyFn = trackCalls (prev, curr) ->
                    k = keys[@i]
                    expect(seen[k]).toBe false
                    seen[k] = true
                    expect(curr).toBe o[k]
                    @i++

                p = backburner.reduce o, bodyFn, undefined, context
                waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
                runs ->
                    expect(seen[k]).toBe true for k in keys[1..]

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

            p = backburner.reduce a, bodyFn, 42, context
            p.fail (err) ->
                expect(@).toBe context
                expect(err).toBe e
                expect(a[0]).toBe true
                expect(a[1]).toBe false
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

        it 'should pass the result as the first argument when resolving', ->
            context = {}
            a = (n for n in [1..10])
            bodyFn = (prev, curr, i, a2) ->
                return prev + curr

            p = backburner.reduce a, bodyFn, 42, context
            p.done (result) ->
                sum = 42
                sum += i for i in [1..10]
                expect(this).toBe context
                expect(result).toBe sum
            waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME

    it 'should behave as expected when passed a simple fn and array', ->
        a = (x for x in [1..10])
        bodyFn = (prev, curr, i, a2) ->
            return prev + curr
        p = backburner.reduce a, bodyFn, 'foo'
        p.done (result) ->
            sum = 'foo'
            sum += x for x in [1..10]
            expect(result).toBe sum
        waitsFor (-> p.isResolved()), 'the task to resolve', WAIT_TIME
