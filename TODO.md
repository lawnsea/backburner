Unsorted
========
These are tasks and ideas that haven't been put somewhere else

* liberal use of asserts and logging
* Keep a record of which tasks have been scheduled recently for debugging purposes
* Log to console
* Consider adding support for more sophisticated scheduling algorithms as plugins
  * Pluggable scheduler?
* add a scheduler.break method
  * this might make more sense as a config attr: 
    { breakOn: [ fn () { return something.is(broke); }] }

Sprint 1
========
* support join semantics as implemented by herman's task.js
  * then(fn) - spawn and join
* review current task.js API and look for chances to be closer to it
* should spawn also accept a Task?
* write inline documentation
* create project page on github
  * document public API
  * post tests and run in
    * IE
    * FF
    * Chrome
  * write a few simple demos
  * reserve the domain? meh.

Sprint 2
========
* implement underscore collection fns
* Build for:
  * npm
  * Node.js
  * Dojo
  * DHTML
  * YUI
  * jQuery
* refactor to use RequireJS
  * change Cakefile to use r.js and a bootstrap script for the tests
  * change Cakefile to build for the browser with require's build tool
* refactor to provide an export(object) fn to each compiled module that does the right thing
  * node: export (symbols) -> exports[k] = v for own k, v in symbols
  * browser: export (symbols) -> root.backburner ?= {}; then as above
* fix wording of waitsFor strings
