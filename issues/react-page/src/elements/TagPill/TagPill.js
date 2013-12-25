/**
 * @jsx React.DOM
 */
"use strict";

var React = require("React");

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
      <span className="tag-pill">
        {this.props.name}
      </span>
    );
  }
});

module.exports = TagPill;
