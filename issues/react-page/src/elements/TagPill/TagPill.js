/**
 * @jsx React.DOM
 */
"use strict";

var React             = require("React"),
    ReactStyle        = require("ReactStyle"),
    TagPillStyleRules = require("./TagPillStyleRules");

var DRAG_OPACITY     = .4,
    STANDARD_OPACITY = 1;

ReactStyle.addRules(TagPillStyleRules);

var TagPill = React.createClass({
  getInitialState: function() {
    return {};
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  handleClose: function(event) {
    console.log("closing");
    event.preventDefault();
  },

  render: function() {
    return (
      <span className={TagPillStyleRules.tagPill}>
        {this.props.name}
        <a href="#" onClick={this.handleClose}>&times;</a>
      </span>
    );
  }
});

module.exports = TagPill;
