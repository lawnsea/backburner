{describeTaskPromise} = require('task')

{Task, spawn} = require('backburner')

describe 'backburner.spawn', ->
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
            p = spawn fn
            return [p, (-> resolve = true), (-> reject = true)]
        , 'The result of spawn()'
