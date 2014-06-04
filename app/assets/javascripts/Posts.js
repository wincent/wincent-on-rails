'use strict';

var injectTagWidget = require('./injectTagWidget');

var Posts = {
  init: function() {
    injectTagWidget('post');
  }
};

module.exports = Posts;
