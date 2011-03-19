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
* Pluggable scheduler
* should spawn also accept a Task?
* fix tests to read as English phrases

Sprint 1
========
* tests for Deferred
  * ensure that promise returns a promise
* Task.promise() should return a TaskPromise
* spawn should return a Task
* write actual working tests for while
* fix while to call @thisTask.<deferredfn>
* a simple scheduler
  * Tasks should be assigned a unique id and added to the scheduler's task pool
