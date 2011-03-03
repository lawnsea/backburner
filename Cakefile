{exec} = require 'child_process'

task 'clean', 'Clean the working directory in the usual manner', ->
    exec 'rm -rf lib', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
    exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

