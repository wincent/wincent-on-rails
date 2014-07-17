/**
 * @jsx React.DOM
 */

'use strict';

var $ = require('jquery');
var React = require('react/addons');
var TagWidget = require('./TagWidget.react');

/**
 * Temporary means of injecting this React widget into a rendered page.
 *
 * Will most likely change once we have server-side rendering.
 */
var injectTagWidget = function(modelName) {
  var $input = $(`#${modelName}_pending_tags`);
  if ($input.length) {
    var val = $input.val();
    var $div = $('<div />');
    $input.replaceWith($div);

    React.renderComponent(
      <TagWidget
        pendingTags={val}
        resourceName={`${modelName}[pending_tags]`}
      />,
      $div[0]
    );
  }
};

module.exports = injectTagWidget;
