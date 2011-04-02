{describeTaskPromise} = require('task')

backburner = require('backburner')

describe 'backburner.spawn', ->
    backburner.killAll()
    afterEach = ->
        backburner.killAll()

    describeTaskPromise ->
            resolve = false
            reject = false
            fn = ->
                if resolve
                    @thisTask.resolve()
                    @thisTask.stop()
                else if reject
                    @thisTask.reject()
                    @thisTask.stop()
            p = backburner.spawn fn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'returns a promise that'
