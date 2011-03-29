{trackCalls} = require('spec-utils')

{scheduler} = require 'backburner-scheduler'
{Task} = require 'backburner'

describe 'Scheduler', ->
    beforeEach ->
        scheduler.autostart true
    describe 'provides exec and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should execute passed Tasks when runnable', ->
            fn1 = trackCalls()
            task1 = new Task fn1, runnable: true
            fn2 = trackCalls()
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
            fn1 = trackCalls()
            task1 = new Task fn1, runnable: true
            fn2 = trackCalls()
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

        it 'should start the scheduler when a task is added if autostart is true', ->
            fn = trackCalls()
            task = new Task fn, runnable: true
            
            scheduler.stop()
            scheduler.autostart true
            scheduler.exec task
            expect(scheduler.isRunning()).toBe true

        it 'should not start the scheduler when a task is added if autostart is false', ->
            fn = trackCalls()
            task = new Task fn, runnable: true
            
            scheduler.stop()
            scheduler.autostart false
            scheduler.exec task
            expect(scheduler.isRunning()).not.toBe true

    describe 'provides kill and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should kill any tasks passed to it', ->
            fn1 = trackCalls()
            task1 = new Task fn1, runnable: true
            fn2 = trackCalls()
            task2 = new Task fn2, runnable: true

            runs ->
                scheduler.exec task1
                scheduler.exec task2
            waits 2 * scheduler.period()
            runs ->
                scheduler.kill task1, task2
                delete fn1.called
                delete fn2.called
            waits 2 * scheduler.period()
            runs ->
                expect(fn1.called).not.toBe true
                expect(fn2.called).not.toBe true

        it 'should not kill any tasks not passed to it', ->
            fn1 = trackCalls()
            task1 = new Task fn1, runnable: true
            fn2 = trackCalls()
            task2 = new Task fn2, runnable: true

            runs ->
                scheduler.exec task1
                scheduler.exec task2
            waits 2 * scheduler.period()
            runs ->
                delete fn1.called
                delete fn2.called
                scheduler.kill task1
            waits 4 * scheduler.period()
            runs ->
                expect(fn2.called).toBe true

    describe 'provides killAll and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should kill all tasks', ->
            fn1 = trackCalls()
            task1 = new Task fn1, runnable: true
            fn2 = trackCalls()
            task2 = new Task fn2, runnable: true

            runs ->
                scheduler.exec task1
                scheduler.exec task2
            waits 2 * scheduler.period()
            runs ->
                scheduler.killAll()
                delete fn1.called
                delete fn2.called
            waits 2 * scheduler.period()
            runs ->
                expect(fn1.called).not.toBe true
                expect(fn2.called).not.toBe true

        it 'should stop the scheduler if autostart is true', ->
            scheduler.start()
            scheduler.killAll()
            expect(scheduler.isRunning()).not.toBe true

        it 'should not stop the scheduler if autostart is false', ->
            scheduler.autostart(false)
            scheduler.start()
            scheduler.killAll()
            expect(scheduler.isRunning()).toBe true

    describe 'provides start and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should start the scheduler', ->
            scheduler.start()
            expect(scheduler.isRunning()).toBe true

    describe 'provides stop and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should stop the scheduler', ->
            scheduler.stop()
            expect(scheduler.isRunning()).toBe false

    describe 'provides isRunning and', ->
        beforeEach ->
            scheduler.killAll()

        it 'should return true if the scheduler is running', ->
            scheduler.start()
            expect(scheduler.isRunning()).toBe true

        it 'should return false if the scheduler is not running', ->
            scheduler.stop()
            expect(scheduler.isRunning()).toBe false
