/**
 * @jsx React.DOM
 */

'use strict';

var $ = require('jquery');
var React = require('react/addons');
var TagWidget = require('./TagWidget');

var Issues = {
  init: function() {
    var $input = $('#issue_pending_tags');
    if ($input.length) {
      var val = $input.val().trim();
      var $div = $('<div />');
      $input.replaceWith($div);

      React.renderComponent(
        <TagWidget
          pendingTags={val.length ? val : null}
          resourceName="issue[pending_tags]"
        />,
        $div[0]
      );
    }
  }
};

module.exports = Issues;
