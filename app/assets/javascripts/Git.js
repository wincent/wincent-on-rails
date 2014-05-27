'use strict';

var $ = require('jquery');

function toggle($el, other) {
  if ($el.is(':visible')) {
    $el.hide();
  } else {
    $el.show();
  }

  if (other) { // 'next' or 'prev'
    toggle($el[other]());
  }
}

var Git = {
  init: function() {
    $(document)
      // clicking on the abbreviated subject shows the entire commit message
      .on('click', '.commit .subject', function(event) {
        event.preventDefault();
        toggle($(this), 'next');
      })

      // clicking on the full commit message toggles back to the abbreviated
      .on('click', '.commits pre.message', function(event) {
        event.preventDefault();
        toggle($(this), 'prev');
      });
  }
}

module.exports = Git;
