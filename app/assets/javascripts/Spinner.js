'use strict';

var $ = require('jquery');
var _ = require('underscore');
var SpinJS = require('spin.js');

var SETTINGS = {
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
};

/**
 * Simple wrapper for spin.js
 */
class Spinner {
  constructor(targetSelector, size) {
    var $target = $(targetSelector),
        options = _.extend({}, SETTINGS.base, SETTINGS[size]);

    this.spinner = new SpinJS(options).spin($target[0]);
  }

  stop() {
    this.spinner.stop();
  }

  // TODO: make this "declarative" data-spinner="large"?
  // still need to decide when to trigger it
}

module.exports = Spinner;
