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
* a simple scheduler
  * this might be more easily testable if we break it out as a separate file
  * first cut scheduler does round-robin with no priorities
  * Tasks should be assigned a unique id and added to the scheduler's task pool
  * scheduler should start automatically if a task is added and it isn't running
* spawn should return a TaskPromise
  * not testable until we implement a scheduler
* write actual working tests for while
* fix while to call @thisTask.<deferredfn>
