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
    // at the moment React supports mouseEnter but not mouseOver (see:
    // https://github.com/facebook/react/issues/340); this is fine, as
    // mouseEnter is actually better, but it also explains why things look a
    // little weird here: we have to "unpack" the native event below, and it
    // appears to be a mouseOut event under the covers
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
