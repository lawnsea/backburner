Unsorted
========
These are tasks and ideas that haven't been put somewhere else

* Build for
  * Node.js
  * Dojo
* liberal use of asserts and logging
* Keep a record of which tasks have been scheduled recently for debugging purposes
* Log to console
* Consider adding support for more sophisticated scheduling algorithms as plugins
* Pluggable scheduler?

Sprint 1
========
* write tests to verify that fns passed to then after resolve/reject get the right args
* add a scheduler.break method
* each
  * each(array|object, fn)
  * should reject (?) if fn returns false
* figure out how to handle require() in the browser
  * you may be doing your exporting wrong
* write inline documentation
* create project page on github
  * document public API
  * post tests and run in
    * IE
    * FF
    * Chrome
  * write a few simple demos
* fix wording of waitsFor strings

Sprint 2
========
* Build for:
  * npm
  * DHTML
  * YUI
  * jQuery
* Support join semantics as implemented by herman's jstasks
* should spawn also accept a Task?
