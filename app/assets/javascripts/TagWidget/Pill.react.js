'use strict';

import React from 'react';
import cx from 'classnames';

export default class Pill extends React.Component {
  handleClick(event) {
    event.stopPropagation();
    this.props.onTagSelect(this.props.name);
  }

  handleDelete(event) {
    this.props.onTagDelete(this.props.name);
    event.preventDefault();
  }

  handleDragStart(event) {
    // will require a shim for this; see:
    // https://developer.mozilla.org/en-US/docs/DOM/element.classList
    event.target.classList.add(TagPillStyleRules.dragging);
  }

  handleDragEnd(event) {
    event.target.classList.remove(TagPillStyleRules.dragging);
  }

  render() {
    const classes = cx({
      duplicate: this.props.isDuplicate,
      pending: this.props.isPending,
      selected: this.props.isSelected,
      tagPill: true,
    });

    return (
      <span
        className={classes}
        draggable="true"
        onClick={this.handleClick.bind(this)}
        onDragEnd={this.handleDragEnd.bind(this)}
        onDragStart={this.handleDragStart.bind(this)}>
        {this.props.name}
        <a href="#" onClick={this.handleDelete.bind(this)}>&times;</a>
      </span>
    );
  }
}
