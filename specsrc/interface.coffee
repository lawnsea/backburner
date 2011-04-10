backburner = require('backburner')

describe 'the backburner interface', ->
    beforeEach ->
        @addMatchers {
            toBeAFunction: ->
                this.actual instanceof Function
            }
    it 'should provide Task', ->
        expect(backburner.Task).toBeAFunction()
    it 'should provide spawn', ->
        expect(backburner.spawn).toBeAFunction()
    it 'should provide while', ->
        expect(backburner.while).toBeAFunction()
    it 'should provide for', ->
        expect(backburner.for).toBeAFunction()
    it 'should provide each', ->
        expect(backburner.each).toBeAFunction()
