backburner = require('backburner')

describe 'backburner interface', ->
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
