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

  handleDelete: function(event) {
    event.preventDefault();
    this.props.onTagDelete(this.props.name);
  },

  handleDragStart: function(event) {
    // will require a shim for this; see:
    // https://developer.mozilla.org/en-US/docs/DOM/element.classList
    event.target.classList.add(TagPillStyleRules.dragging);
  },

  handleDragEnd: function(event) {
    event.target.classList.remove(TagPillStyleRules.dragging);
  },

  render: function() {
    return (
      <span className={TagPillStyleRules.tagPill}
            draggable="true"
            onDragStart={this.handleDragStart}
            onDragEnd={this.handleDragEnd}>
        {this.props.name}
        <a href="#" onClick={this.handleDelete}>&times;</a>
      </span>
    );
  }
});

module.exports = TagPill;
