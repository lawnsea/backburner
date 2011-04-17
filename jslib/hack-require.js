/*
 * This is a vicious hack to make the code work in the browser until I 
 * refactor to use RequireJS.
 */
(function () {
var root = this;

root.require = function (module) {
    if (module === 'underscore') {
        return { '_': root._ };
    }
    return root.backburner;
};
}).apply(this);
