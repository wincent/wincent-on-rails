// Copyright 2013 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

(function() {
  "use strict";

  // based on listing 6.21 in John Resig & Bear Bibeault's "Secrets of a
  // JavaScript Ninja", with some temporary variables to make more explicit
  // some of the cleverness that's going on, and some additional checking added
  var canDecompileFunctions = /abc123/.test(function() { return abc123; }),
      superCallDetector     = canDecompileFunctions ? /\b_super\b/ : /.*/,
      isSettingUpSubclass   = false;

  Object.subclass = function extend(overrides) {
    isSettingUpSubclass = true;
    var superclass      = this.prototype,
        prototype       = new this();
    isSettingUpSubclass = false;

    for (var name in overrides) {
      var override            = overrides[name],
          superclassProperty  = superclass[name];

      // standard case: merge overrides into the prototype
      prototype[name] = overrides[name];

      // look for special cases
      if (typeof override === 'function') {
        if (typeof superclassProperty === 'function') {
          if (superCallDetector.test(override)) {
            // this is a function that overrides a function and (potentially,
            // depending on whether the browser supports decompilation) uses
            // _super()
            prototype[name] = (function(name, fn) {
              return function() {
                var originalSuper = this._super;

                try {
                  this._super = superclass[name];
                  return fn.apply(this, arguments);
                } finally {
                  this._super = originalSuper;
                }
              }
            })(name, overrides[name]);
          }
        } else if (canDecompileFunctions && superCallDetector.test(override)) {
          throw new ReferenceError("_super() called, but no implementation available");
        }
      }
    }

    function Class() {
      if (!isSettingUpSubclass && this.init) {
        this.init.apply(this, arguments);
      }
    }

    Class.prototype = prototype;
    Class.constructor = Class;
    Class.subclass = extend;
    return Class;
  };
})();
