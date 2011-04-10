{trackCalls} = require('spec-utils')
WAIT_TIME = 1000

{Deferred} = require('backburner-deferred')

describePromise = (promiseFactory, name) ->
    [promise, resolveFn, rejectFn] = promiseFactory()
    name ?= promise.constructor.name
    if name isnt ''
        name += ' '
    describe name + 'implements Promise', ->
        describe 'and provides then', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register success callbacks', ->
                successFn1 = trackCalls()
                successFn2 = trackCalls()
                failFn = trackCalls()

                promise.then [successFn1]
                promise.then [successFn2], [failFn]

                runs resolveFn
                waitsFor (-> promise.isResolved()), 'promise to resolve', WAIT_TIME
                runs ->
                    expect(successFn1.called).toBe true
                    expect(successFn2.called).toBe true

            it 'should call success callbacks immediately if resolved', ->
                successFn1 = trackCalls()
                successFn2 = trackCalls()
                failFn = trackCalls()

                runs resolveFn
                waitsFor (-> promise.isResolved()), 'promise to resolve', WAIT_TIME
                runs ->
                    promise.then [successFn1]
                    promise.then [successFn2], [failFn]

                    expect(successFn1.called).toBe true
                    expect(successFn2.called).toBe true
                    expect(failFn.called).not.toBe true

            it 'should register failure callbacks', ->
                successFn = trackCalls()
                failFn1 = trackCalls()
                failFn2 = trackCalls()

                promise.then [], [failFn1]
                promise.then [successFn], [failFn2]

                runs rejectFn
                waitsFor (-> promise.isRejected()), 'promise to reject', WAIT_TIME
                runs ->
                    expect(failFn1.called).toBe true
                    expect(failFn2.called).toBe true

            it 'should call failure callbacks immediately if rejected', ->
                successFn = trackCalls()
                failFn1 = trackCalls()
                failFn2 = trackCalls()

                runs rejectFn
                waitsFor (-> promise.isRejected()), 'promise to reject', WAIT_TIME
                runs ->
                    promise.then [], [failFn1]
                    promise.then [successFn], [failFn2]

                    expect(failFn1.called).toBe true
                    expect(failFn2.called).toBe true
                    expect(successFn.called).not.toBe true

        describe 'and provides done', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register success callbacks', ->
                successFn = trackCalls()

                promise.done [successFn]

                runs resolveFn
                waitsFor (-> promise.isResolved()), 'promise to resolve', WAIT_TIME
                runs ->
                    expect(successFn.called).toBe true

        describe 'and provides fail', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register failure callbacks', ->
                failFn = trackCalls()

                promise.fail [failFn]

                runs rejectFn
                waitsFor (-> promise.isRejected()), 'promise to reject', WAIT_TIME
                runs ->
                    expect(failFn.called).toBe true
    
        describe 'and provides isRejected', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should return false if neither rejected nor resolved', ->
                expect(promise.isRejected()).toBe false

            it 'should return false if resolved', ->
                runs resolveFn
                waitsFor (-> promise.isResolved()), 'promise to resolve', WAIT_TIME
                runs ->
                    expect(promise.isRejected()).toBe false

            it 'should return true if rejected', ->
                runs rejectFn
                waitsFor (-> promise.isRejected()), 'promise to reject', WAIT_TIME
                runs ->
                    expect(promise.isRejected()).toBe true
        
        describe 'and provides isResolved', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should return false if neither rejected nor resolved', ->
                expect(promise.isResolved()).toBe false

            it 'should return false if rejected', ->
                runs rejectFn
                waitsFor (-> promise.isRejected()), 'promise to reject', WAIT_TIME
                runs ->
                    expect(promise.isResolved()).toBe false

            it 'should return true if resolved', ->
                runs resolveFn
                waitsFor (-> promise.isResolved()), 'promise to resolve', WAIT_TIME
                runs ->
                    expect(promise.isResolved()).toBe true
exports.describePromise = describePromise

describeDeferred = (deferredFactory, name) ->
    deferred = deferredFactory()
    name ?= deferred.constructor.name
    if name isnt ''
        name += ' '
    describe name + 'implements Deferred', ->
        describePromise ->
            d = new Deferred
            return [d, (-> d.resolve()), (-> d.reject())]
        , 'which'

        describe 'and provides reject', ->
            beforeEach ->
                deferred = deferredFactory()

            it 'should call rejectWith with context === the Deferred', ->
                expectedArgs = [23, 42, 'foo']
                deferred.rejectWith = (context, args...) ->
                    expect(context).toBe deferred
                    i = 0
                    for arg in args
                        expect(arg).toBe expectedArgs[i]
                        i++
                deferred.reject expectedArgs...

        describe 'and provides rejectWith', ->
            beforeEach ->
                deferred = deferredFactory()

            it 'should call all failure handlers', ->
                called = [false, false, false, false]
                fns = [
                    -> called[0] = true,
                    -> called[1] = true,
                    -> called[2] = true,
                    -> called[3] = true,
                ]
                deferred.fail fns[0..1]
                deferred.then [], fns[2..3]
                deferred.rejectWith {}

                for call in called
                    expect(call).toBe true

            it 'should not call success handlers', ->
                called = [false, false, false, false]
                fns = [
                    -> called[0] = true,
                    -> called[1] = true,
                    -> called[2] = true,
                    -> called[3] = true,
                ]
                deferred.done fns[0..1]
                deferred.then fns[2..3]
                deferred.rejectWith {}

                for call in called
                    expect(call).toBe false

            it 'should execute handlers with the correct context', ->
                context = {}
                deferred.fail (actualArgs...) ->
                    expect(this).toBe context
                deferred.rejectWith context

            it 'should pass args to handlers', ->
                expectedArgs = [23, 42, 'foo']
                deferred.fail (actualArgs...) ->
                    i = 0
                    for arg in actualArgs
                        expect(arg).toBe expectedArgs[i]
                        i++
                deferred.rejectWith {}, expectedArgs...

            it 'should have no effect if already resolved', ->
                deferred.resolveWith {}
                deferred.rejectWith {}
                expect(deferred.isResolved()).toBe true
                expect(deferred.isRejected()).toBe false

            it 'should be idempotent', ->
                deferred.rejectWith {}
                expect(deferred.isResolved()).toBe false
                expect(deferred.isRejected()).toBe true

                deferred.rejectWith {}
                expect(deferred.isResolved()).toBe false
                expect(deferred.isRejected()).toBe true

        describe 'and provides resolve', ->
            beforeEach ->
                deferred = deferredFactory()
            
            it 'should call resolveWith with context === the Deferred', ->
                expectedArgs = [23, 42, 'foo']
                deferred.resolveWith = (context, args...) ->
                    expect(context).toBe deferred
                    i = 0
                    for arg in args
                        expect(arg).toBe expectedArgs[i]
                        i++
                deferred.resolve expectedArgs...

        describe 'and provides resolveWith', ->
            beforeEach ->
                deferred = deferredFactory()

            it 'should call all success handlers', ->
                called = [false, false, false, false]
                fns = [
                    -> called[0] = true,
                    -> called[1] = true,
                    -> called[2] = true,
                    -> called[3] = true,
                ]
                deferred.done fns[0..1]
                deferred.then fns[2..3]
                deferred.resolveWith {}

                for call in called
                    expect(call).toBe true

            it 'should not call failure handlers', ->
                called = [false, false, false, false]
                fns = [
                    -> called[0] = true,
                    -> called[1] = true,
                    -> called[2] = true,
                    -> called[3] = true,
                ]
                deferred.fail fns[0..1]
                deferred.then [], fns[2..3]
                deferred.resolveWith {}

                for call in called
                    expect(call).toBe false

            it 'should execute handlers with the correct context', ->
                context = {}
                deferred.done (actualArgs...) ->
                    expect(this).toBe context
                deferred.resolveWith context

            # XXX: this should be a resolveWith test
            it 'should pass args to handlers', ->
                expectedArgs = [23, 42, 'foo']
                deferred.done (actualArgs...) ->
                    i = 0
                    for arg in actualArgs
                        expect(arg).toBe expectedArgs[i]
                        i++
                deferred.resolveWith {}, expectedArgs...

            it 'should have no effect if already rejected', ->
                deferred.rejectWith {}
                deferred.resolveWith {}
                expect(deferred.isResolved()).toBe false
                expect(deferred.isRejected()).toBe true

            it 'should be idempotent', ->
                deferred.resolveWith {}
                expect(deferred.isResolved()).toBe true
                expect(deferred.isRejected()).toBe false

                deferred.resolveWith {}
                expect(deferred.isResolved()).toBe true
                expect(deferred.isRejected()).toBe false

        describe 'and provides promise', ->
            beforeEach ->
                deferred = deferredFactory()

            describePromise ->
                    d = new Deferred
                    return [d.promise(), (-> d.resolve()), (-> d.reject())]
                , 'which returns a promise that'

            it 'should always return the same promise', ->
                promise = deferred.promise()
                expect(deferred.promise()).toBe promise
exports.describeDeferred = describeDeferred
