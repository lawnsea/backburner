{exec} = require 'child_process'

task 'test', 'Run all tests', ->
    exec 'cake build && node specs.js', (err, stdout, stderr) ->
        console.log stdout + stderr

task 'clean', 'Clean the working directory in the usual manner', ->
    exec 'rm -rf lib', (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'build', 'Build project from src/*.coffee to lib/*.js', ->
    exec 'coffee --compile --output lib/ src/', (err, stdout, stderr) ->
        console.log stdout + stderr
    exec 'coffee --compile --output spec/ specsrc/', (err, stdout, stderr) ->
        console.log stdout + stderr

