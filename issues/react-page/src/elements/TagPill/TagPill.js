/**
 * @jsx React.DOM
 */
"use strict";

var React             = require("React"),
    ReactStyle        = require("ReactStyle"),
    TagPillStyleRules = require("./TagPillStyleRules");

ReactStyle.addRules(TagPillStyleRules);

var TagPill = React.createClass({
  getInitialState: function() {
    return {};
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  render: function() {
    return (
      <span className={TagPillStyleRules.tagPill}>
        {this.props.name}
      </span>
    );
  }
});

module.exports = TagPill;
