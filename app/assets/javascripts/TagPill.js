'use strict';

var React = require('react/addons');

var cx = React.addons.classSet;

var TagPill = React.createClass({
  handleClick: function(event) {
    event.stopPropagation();
    this.props.onTagSelect(this.props.name);
  },

  handleDelete: function(event) {
    this.props.onTagDelete(this.props.name);
    return false;
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
    var classes = cx({
      '.tagPill': true,
      '.duplicate': this.props.isDuplicate,
      '.pending': this.props.isPending,
      '.selected': this.props.isSelected
    });

    return (
      <span
        className={classes}
        draggable="true"
        onClick={this.handleClick}
        onDragStart={this.handleDragStart}
        onDragEnd={this.handleDragEnd}>
        {this.props.name}
        <a href="#" onClick={this.handleDelete}>&times;</a>
      </span>
    );
  }
});

module.exports = TagPill;
