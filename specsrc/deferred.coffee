{Deferred} = require('backburner-deferred')

describe 'Deferreds and their promises', ->
    describe 'their interface', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }
        it 'should provide then', ->
            expect(deferred.then).toBeAFunction()
            expect(promise.then).toBeAFunction()
        it 'should provide done', ->
            expect(deferred.done).toBeAFunction()
            expect(promise.done).toBeAFunction()
        it 'should provide fail', ->
            expect(deferred.fail).toBeAFunction()
            expect(promise.fail).toBeAFunction()
        it 'should provide isResolved', ->
            expect(deferred.isResolved).toBeAFunction()
            expect(promise.isResolved).toBeAFunction()
        it 'should provide isRejected', ->
            expect(deferred.isRejected).toBeAFunction()
            expect(promise.isRejected).toBeAFunction()

    describe 'then', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }
        
        it 'should register callbacks on deferreds', ->
            successFn1 = ->
            successFn2 = ->
            failFn1 = ->
            failFn2 = ->

            deferred.then [successFn1]
            deferred.then [], [failFn1]
            deferred.then [successFn2], [failFn2]

            expect(successFn1 in deferred._successFns).toBe true
            expect(successFn2 in deferred._successFns).toBe true
            expect(failFn1 in deferred._failFns).toBe true
            expect(failFn2 in deferred._failFns).toBe true

        it 'should register callbacks on promises', ->
            successFn1 = ->
            successFn2 = ->
            failFn1 = ->
            failFn2 = ->

            promise.then [successFn1]
            promise.then [], [failFn1]
            promise.then [successFn2], [failFn2]

            expect(successFn1 in deferred._successFns).toBe true
            expect(successFn2 in deferred._successFns).toBe true
            expect(failFn1 in deferred._failFns).toBe true
            expect(failFn2 in deferred._failFns).toBe true

    describe 'done', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }
        
        it 'should register callbacks on deferreds', ->
            successFn = ->

            deferred.done [successFn]

            expect(successFn in deferred._successFns).toBe true

        it 'should register callbacks on promises', ->
            successFn = ->

            promise.done [successFn]

            expect(successFn in deferred._successFns).toBe true

    describe 'fail', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }
        
        it 'should register callbacks on deferreds', ->
            failFn = ->
            deferred.fail [failFn]
            expect(failFn in deferred._failFns).toBe true

        it 'should register callbacks on promises', ->
            failFn = ->
            promise.fail [failFn]
            expect(failFn in deferred._failFns).toBe true
    
    describe 'isRejected', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

        it 'should return false if neither rejected nor resolved', ->
            expect(deferred.isRejected()).toBe false
            expect(promise.isRejected()).toBe false

        it 'should return false if resolved', ->
            deferred.resolve()
            expect(deferred.isRejected()).toBe false
            expect(promise.isRejected()).toBe false

        it 'should return true if rejected', ->
            deferred.reject()
            expect(deferred.isRejected()).toBe true
            expect(promise.isRejected()).toBe true
    
    describe 'isResolved', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

        it 'should return false if neither rejected nor resolved', ->
            expect(deferred.isResolved()).toBe false
            expect(promise.isResolved()).toBe false

        it 'should return false if rejected', ->
            deferred.reject()
            expect(deferred.isResolved()).toBe false
            expect(promise.isResolved()).toBe false

        it 'should return true if resolved', ->
            deferred.resolve()
            expect(deferred.isResolved()).toBe true
            expect(promise.isResolved()).toBe true

    describe 'reject', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

        it 'should have no effect if already resolved', ->
            deferred.resolve()
            deferred.reject()
            expect(deferred.isResolved()).toBe true
            expect(promise.isResolved()).toBe true
            expect(deferred.isRejected()).toBe false
            expect(promise.isRejected()).toBe false

        it 'should be idempotent', ->
            deferred.reject()
            expect(deferred.isResolved()).toBe false
            expect(promise.isResolved()).toBe false
            expect(deferred.isRejected()).toBe true
            expect(promise.isRejected()).toBe true
            deferred.reject()
            expect(deferred.isResolved()).toBe false
            expect(promise.isResolved()).toBe false
            expect(deferred.isRejected()).toBe true
            expect(promise.isRejected()).toBe true

    describe 'rejectWith', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

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

    describe 'resolve', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

        it 'should have no effect if already rejected', ->
            deferred.reject()
            deferred.resolve()
            expect(deferred.isResolved()).toBe false
            expect(promise.isResolved()).toBe false
            expect(deferred.isRejected()).toBe true
            expect(promise.isRejected()).toBe true

        it 'should be idempotent', ->
            deferred.resolve()
            expect(deferred.isResolved()).toBe true
            expect(promise.isResolved()).toBe true
            expect(deferred.isRejected()).toBe false
            expect(promise.isRejected()).toBe false
            deferred.resolve()
            expect(deferred.isResolved()).toBe true
            expect(promise.isResolved()).toBe true
            expect(deferred.isRejected()).toBe false
            expect(promise.isRejected()).toBe false

    describe 'resolveWith', ->
        deferred = promise = 42

        beforeEach ->
            deferred = new Deferred
            promise = deferred.promise()
            @addMatchers {
                toBeAFunction: ->
                    this.actual instanceof Function
                }

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
            deferred.resolve expectedArgs...
