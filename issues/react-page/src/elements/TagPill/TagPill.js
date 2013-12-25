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
