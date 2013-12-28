/**
 * @jsx React.DOM
 */
"use strict";

var React                     = require("React"),
    ReactStyle                = require("ReactStyle"),
    TagAutocompleteStyleRules = require("./TagAutocompleteStyleRules");

ReactStyle.addRules(TagAutocompleteStyleRules);

var TagAutocomplete = React.createClass({
  getInitialState: function() {
    return {};
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  render: function() {
    return (
      <div className={TagAutocompleteStyleRules.tagAutocomplete}>
        <ul>
          <li>test content</li>
          <li>test content</li>
          <li>test content</li>
          <li>test content</li>
          <li>test content</li>
        </ul>
      </div>
    );
  }
});

module.exports = TagAutocomplete;
