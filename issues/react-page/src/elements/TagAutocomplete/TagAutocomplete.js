/**
 * @jsx React.DOM
 */
"use strict";

var React                     = require("React"),
    ReactStyle                = require("ReactStyle"),
    TagAutocompleteStyleRules = require("./TagAutocompleteStyleRules");

ReactStyle.addRules(TagAutocompleteStyleRules);

var TagAutocomplete = React.createClass({
  handleClick: function(event) {
    this.props.onTagPush(event.target.innerHTML);
  },

  handleMouseEnter: function(event) {
    // something weird here: mouseOver, mouseExit etc don't appear to fire, and
    // "mouseEnter" events are only useful if we unpack them as below (because
    // the nativeEvent here appears to be a mouseOut event); not at all clear
    // that this will work cross-browser
    this.props.onTagSelect(event.nativeEvent.toElement);
  },

  render: function() {
    var completions = this.props.completions.map(function(completion, i) {
      if (this.props.selectedIdx === i) {
        var className = TagAutocompleteStyleRules.selected;
      }
      return (
        <li className={className}
            onClick={this.handleClick}
            onMouseEnter={this.handleMouseEnter}>
          {completion}
        </li>
      );
    }.bind(this));

    var className = TagAutocompleteStyleRules.tagAutocomplete +
      (this.props.completions.length ? ' ' + TagAutocompleteStyleRules.active : '');

    return (
      <div className={className}>
        <ul>
          {completions}
        </ul>
      </div>
    );
  }
});

module.exports = TagAutocomplete;
