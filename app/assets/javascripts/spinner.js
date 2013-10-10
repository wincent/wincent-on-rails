(function() {
  "use strict";

  // Simple wrapper for spin.js
  Wincent.Spinner = Class.subclass({
    settings: {
      base: {
        corners : 1,
        hwacell : true,
        rotate  : 0,
        speed   : 1,
        trail   : 60
      },
      large: {
        length : 7,
        lines  : 13,
        radius : 10,
        width  : 4
      },
      small: {
        length : 3,
        lines  : 11,
        radius : 4,
        width  : 2
      }
    },

    init: function(targetSelector, size) {
      var $target = $(targetSelector),
          options = _.extend({}, this.settings.base, this.settings[size]);

      this.spinner = new Spinner(options).spin($target[0]);
    },

    stop: function() {
      this.spinner.stop();
    }
  });
})();
