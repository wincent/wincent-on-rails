'use strict';

var injectTagWidget = require('./injectTagWidget');

var Topics = {
  init: function() {
    injectTagWidget('topic');
  }
};

module.exports = Topics;
