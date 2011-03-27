{Deferred} = require('backburner-deferred')
WAIT_TIME = 50

callTrackingFn = ->
    return ->
        arguments.callee.called = true

describePromise = (promiseFactory, name) ->
    [promise, resolveFn, rejectFn] = promiseFactory()
    name ?= promise.constructor.name
    describe name + ' implements Promise and ', ->
        describe 'provides then', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register success callbacks', ->
                successFn1 = callTrackingFn()
                successFn2 = callTrackingFn()
                failFn = callTrackingFn()

                promise.then [successFn1]
                promise.then [successFn2], [failFn]

                runs resolveFn
                waits WAIT_TIME
                runs ->
                    expect(successFn1.called).toBe true
                    expect(successFn2.called).toBe true

            it 'should register failure callbacks', ->
                successFn = callTrackingFn()
                failFn1 = callTrackingFn()
                failFn2 = callTrackingFn()

                promise.then [], [failFn1]
                promise.then [successFn], [failFn2]

                runs rejectFn
                waits WAIT_TIME
                runs ->
                    expect(failFn1.called).toBe true
                    expect(failFn2.called).toBe true

        describe 'provides done', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register success callbacks', ->
                successFn = callTrackingFn()

                promise.done [successFn]

                runs resolveFn
                waits WAIT_TIME
                runs ->
                    expect(successFn.called).toBe true

        describe 'provides fail', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should register failure callbacks', ->
                failFn = callTrackingFn()

                promise.fail [failFn]

                runs rejectFn
                waits WAIT_TIME
                runs ->
                    expect(failFn.called).toBe true
    
        describe 'provides isRejected', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should return false if neither rejected nor resolved', ->
                expect(promise.isRejected()).toBe false

            it 'should return false if resolved', ->
                runs resolveFn
                waits WAIT_TIME
                runs ->
                    expect(promise.isRejected()).toBe false

            it 'should return true if rejected', ->
                runs rejectFn
                waits WAIT_TIME
                runs ->
                    expect(promise.isRejected()).toBe true
        
        describe 'provides isResolved', ->
            beforeEach ->
                [promise, resolveFn, rejectFn] = promiseFactory()

            it 'should return false if neither rejected nor resolved', ->
                expect(promise.isResolved()).toBe false

            it 'should return false if rejected', ->
                runs rejectFn
                waits WAIT_TIME
                runs ->
                    expect(promise.isResolved()).toBe false

            it 'should return true if resolved', ->
                runs resolveFn
                waits WAIT_TIME
                runs ->
                    expect(promise.isResolved()).toBe true
exports.describePromise = describePromise

describePromise ->
        d = new Deferred
        return [d.promise(), (-> d.resolve()), (-> d.reject())]
    , 'The result of Deferred.promise()'

describeDeferred = (deferredFactory, name) ->
    deferred = deferredFactory()
    name ?= deferred.constructor.name
    describe name + ' implements Deferred and ', ->
        describePromise ->
            d = new Deferred
            return [d, (-> d.resolve()), (-> d.reject())]

        describe 'reject', ->
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

        describe 'rejectWith', ->
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

        describe 'resolve', ->
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

        describe 'resolveWith', ->
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

        describe 'promise', ->
            beforeEach ->
                deferred = deferredFactory()

            describePromise ->
                    d = new Deferred
                    return [d.promise(), (-> d.resolve()), (-> d.reject())]
                , 'The result of Deferred.promise()'

            it 'should always return the same promise', ->
                promise = deferred.promise()
                expect(deferred.promise()).toBe promise
exports.describeDeferred = describeDeferred

describeDeferred -> new Deferred
