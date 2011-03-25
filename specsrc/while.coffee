backburner = require('backburner')
#{Promise} = require 'backburner-promise'
{Task} = backburner

describe 'backburner.while', ->
    beforeEach ->
        @addMatchers {
            toBeATask: ->
                this.actual instanceof Task
            }

    it 'should accept a function and optional config and return a runnable Task', ->
        fn = ->
        context = {}
        task = backburner.while fn, fn, context
        expect(task).toBeATask()
        expect(task._context).toBe context
        expect(task._runnable).toBe true

    it 'should loop as expected', ->
        testFn = ->
            @i < 1
        bodyFn = ->
            @i += 1
        context =
            i: 0
        task = backburner.while testFn, bodyFn, context
        task.then ->
           expect(@i).toBe 1

    it 'should do what I want', ->
        testFn = ->
            throw 'foo'
            console.log @i
            @i < 10
        bodyFn = ->
            @i += 1
        context =
            i: 0
        task = backburner.while testFn, bodyFn, context
        task._tickFn()
        task.then ->
           expect(@i).toBe 10
