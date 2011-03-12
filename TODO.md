Unsorted
========
These are tasks and ideas that haven't been put somewhere else

* Implement in Coffeescript
* Build for
  * Node.js
  * YUI
  * jQuery
  * Dojo
  * browser w/o framework
* TDD
* liberal use of asserts and logging
* Return an augmented promise
* Support join semantics as implemented by herman's jstasks
* Keep a record of which tasks have been scheduled recently for debugging purposes
* Log to console
* Consider adding support for more sophisticated scheduling algorithms as plugins

Sprint 1
========
* Implement:
  * backburner.while(loopTestFn, loopBodyFn, resultFn, context) -> backburner.Task
  * a simple scheduler
* should spawn also accept a Task?
* Task should support chaining
* Task should be a promise
* Tasks should be assigned a unique id and added to the scheduler's task pool
