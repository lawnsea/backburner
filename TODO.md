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
* Pluggable scheduler?
* should spawn also accept a Task?
* fix tests to read as English phrases
* should we wrap tickFns to prevent their execution if the task believes itself to be killed or stopped?
  * one way, wrap the tickFn.  return true if runnable, else return false
    * the problem with that is that the scheduler should call isRunnable first
    * so, maybe we throw?

Sprint 1
========
* write actual working tests for while
* fix tests to clean up their tasks using killAll
* implement Task.kill
  * Tasks should kill themselves when resolved or rejected
* rename while as whilst
  * or, instead just import it as awhile and similary for for: afor, etc
* create test utils module with callTrackingFn, etc.
* look at using underscore
