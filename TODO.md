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
* add a scheduler.break method

Sprint 1
========
* add cslib and jslib folders to hold submodules
* add underscore as a submodule and remove node_modules
* refactor to use RequireJS
  * change Cakefile to use r.js and a bootstrap script for the tests
  * change Cakefile to build for the browser with require's build tool
* refactor to provide an export(object) fn to each compiled module that does the right thing
  * node: export (symbols) -> exports[k] = v for own k, v in symbols
  * browser: export (symbols) -> root.backburner ?= {}; then as above
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
