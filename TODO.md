Unsorted
========
These are tasks and ideas that haven't been put somewhere else

* Implement in Coffeescript
* Build for
  * Node.js
  * Dojo
* liberal use of asserts and logging
* Keep a record of which tasks have been scheduled recently for debugging purposes
* Log to console
* Consider adding support for more sophisticated scheduling algorithms as plugins
* Pluggable scheduler?
* should we wrap tickFns to prevent their execution if the task believes itself to be killed or stopped?
  * one way, wrap the tickFn.  return true if runnable, else return false
    * the problem with that is that the scheduler should call isRunnable first
    * so, maybe we throw?

Sprint 1
========
* fix tests to read as English phrases
* Build for
  * npm
  * DHTML
* for
  * for(setupFn, testFn, iterateFn, bodyFn)
* forEach
  * forEach(array|object, fn)

Sprint 2
========
* Build for
  * YUI
  * jQuery
* Support join semantics as implemented by herman's jstasks
* should spawn also accept a Task?
* rename while as whilst?
  * or, instead just import it as awhile and similary for for: afor, etc
* look at using underscore
