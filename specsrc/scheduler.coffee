{scheduler} = require 'backburner-scheduler'
{Task} = require 'backburner'

callTrackingFn = ->
    return ->
        arguments.callee.called = true

describe 'Scheduler', ->
    describe 'provides exec and', ->
        it 'should execute passed Tasks when runnable', ->
            fn1 = callTrackingFn()
            task1 = new Task fn1, runnable: true
            fn2 = callTrackingFn()
            task2 = new Task fn2

            runs ->
                scheduler.exec task1
                scheduler.exec task2
            waits 2 * scheduler.period()
            runs ->
                expect(fn1.called).toBe true
            runs ->
                task2.start()
            waits 2 * scheduler.period()
            runs ->
                expect(fn2.called).toBe true

        it 'should not execute passed Tasks when not runnable', ->
            fn1 = callTrackingFn()
            task1 = new Task fn1, runnable: true
            fn2 = callTrackingFn()
            task2 = new Task fn2

            runs ->
                scheduler.exec task1
                scheduler.exec task2
            waits 2 * scheduler.period()
            runs ->
                expect(fn2.called).not.toBe true
            runs ->
                delete fn1.called
                task1.stop()
            waits 2 * scheduler.period()
            runs ->
                expect(fn1.called).not.toBe true
