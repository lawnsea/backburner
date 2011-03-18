{Deferred} = require('backburner-deferred')

describe 'Interface', ->
    deferred = promise = 42

    beforeEach ->
        deferred = new Deferred
        promise = deferred.promise()
        @addMatchers {
            toBeAFunction: ->
                this.actual instanceof Function
            }
    it 'both should provide then', ->
        expect(deferred.then).toBeAFunction()
        expect(promise.then).toBeAFunction()
    it 'both should provide done', ->
        expect(deferred.done).toBeAFunction()
        expect(promise.done).toBeAFunction()
    it 'both should provide fail', ->
        expect(deferred.fail).toBeAFunction()
        expect(promise.fail).toBeAFunction()
    it 'both should provide isResolved', ->
        expect(deferred.isResolved).toBeAFunction()
        expect(promise.isResolved).toBeAFunction()
    it 'both should provide isRejected', ->
        expect(deferred.isRejected).toBeAFunction()
        expect(promise.isRejected).toBeAFunction()
