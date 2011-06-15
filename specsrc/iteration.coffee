root = this
root.backburner ?= {}

{trackCalls} = require 'spec-utils'
WAIT_TIME = 1000

backburner = require 'backburner'

describeIterationMethod = (method, name) ->
    if name isnt ''
        name += ' '
    describe name + 'mimics the ES5 Array iteration methods', ->
        afterEach ->
            backburner.killAll()

        it 'should be called with the provided context', ->
            context = {}
            bodyFn = trackCalls ->
                expect(this).toBe context
                @thisTask.resolve()
            fn = ->

            p = method [42], bodyFn, context
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

        it 'should be called with the passed array', ->
            a = [42]
            bodyFn = trackCalls (i, v, a2) ->
                expect(a2).toBe a
                @thisTask.resolve()
            fn = ->

            p = method a, bodyFn
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

        it 'should be called with the passed object', ->
            o =
                foo: 'bar'
            bodyFn = trackCalls (k, v, o2) ->
                expect(o2).toBe o
                @thisTask.resolve()
            fn = ->

            p = method o, bodyFn
            waitsFor (-> p.isResolved()), 'bodyFn to be called', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

        it 'should be called with each index and value of a passed array, in order', ->
            a = [23, 42, 'fiz', 'biz']
            context =
                i: 0
            bodyFn = trackCalls (i, v, a2) ->
                expect(i).toBe @i
                expect(v).toBe a[@i]
                @i++
            p = method a, bodyFn, context
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true

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
            p = method o, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(seen[k]).toBe true for k of o

        it 'should resolve immediately if passed an empty object or array', ->
            a = []
            o = {}
            bodyFn = trackCalls()
            p = method a, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).not.toBe true
                delete bodyFn.called
                p = method o, bodyFn
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).not.toBe true

        it 'should not call the body function with elements appended to the array later', ->
            a = [23, 42]
            seen = []
            bodyFn = trackCalls (i, v, a) ->
                seen[i] = v
            p = method a, bodyFn
            a.push 1337
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen[2]).not.toBe a[2]

        it 'should not call the body function with elements added to the object later', ->
            o =
                foo: 'bar'
                fiz: 'biz'
            seen = {}
            bodyFn = trackCalls (k, v, a) ->
                seen[k] = v
            p = method o, bodyFn
            o.frob = 'nard'
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen.frob).not.toBe o.frob

        it 'should not call the body function with elements deleted from the array', ->
            a = [23, 1337, 42]
            seen = []
            bodyFn = trackCalls (i, v, a) ->
                seen[i] = true
            p = method a, bodyFn
            delete a[1]
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen[1]).not.toBe true

        it 'should not call the body function with elements deleted from the object', ->
            o =
                foo: 'bar'
                fiz: 'biz'
                frob: 'nard'
            seen = {}
            bodyFn = trackCalls (k, v, a) ->
                seen[k] = true
            p = method o, bodyFn
            delete o.frob
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen.frob).not.toBe true

        it 'should reflect changes in value to array elements made before they are visited', ->
            a = [23, 1337, 42]
            seen = []
            bodyFn = trackCalls (i, v, a) ->
                seen[i] = v
            p = method a, bodyFn
            a[1] = 7331
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen[1]).toBe a[1]

        it 'should reflect changes in value to object elements made before they are visited', ->
            o =
                foo: 'bar'
                fiz: 'biz'
                frob: 'nard'
            seen = {}
            bodyFn = trackCalls (k, v, a) ->
                seen[k] = v
            p = method o, bodyFn
            o.frob = 'dran'
            waitsFor (-> p.isResolved()), 'task to resolve', WAIT_TIME
            runs ->
                expect(bodyFn.called).toBe true
                expect(seen.frob).toBe o.frob

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

            p = method a, bodyFn, context
            p.fail (err) ->
                expect(this).toBe context
                expect(err).toBe e
                expect(a[0]).toBe true
                expect(a[1]).toBe false
            waitsFor (-> p.isRejected()), 'the task to reject', WAIT_TIME

root.backburner.describeIterationMethod = describeIterationMethod
if exports?
    exports.describeIterationMethod = describeIterationMethod
