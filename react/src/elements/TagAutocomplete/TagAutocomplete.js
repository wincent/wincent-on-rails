/**
 * @jsx React.DOM
 */
"use strict";

var React                     = require("React"),
    ReactStyle                = require("ReactStyle"),
    TagAutocompleteStyleRules = require("./TagAutocompleteStyleRules");

ReactStyle.addRules(TagAutocompleteStyleRules);

var TagAutocomplete = React.createClass({
  componentDidUpdate: function() {
    var menu      = this.getDOMNode(),
        selection = this.refs && this.refs.selected && this.refs.selected.getDOMNode();

    if (selection) {
      // is selection off the bottom of the scrollable area?
      var count = TagAutocompleteStyleRules.VISIBLE_AUTOCOMPLETE_ENTRIES,
          delta = selection.offsetTop -
                  (menu.scrollTop + count * selection.clientHeight);
      if (delta > 0) {
        menu.scrollTop += (delta + selection.clientHeight);
      }

      // is selection off the top of the scrollable area?
      delta = menu.scrollTop - selection.offsetTop;
      if (delta > 0) {
        menu.scrollTop -= delta;
      }
    }
  },

  handleClick: function(event) {
    this.props.onTagPush(event.target.innerHTML);
  },

  handleMouseEnter: function(event) {
    // at the moment React supports mouseEnter but not mouseOver (see:
    // https://github.com/facebook/react/issues/340); this is fine, as
    // mouseEnter is actually better, but it also explains why things look a
    // little weird here: we have to "unpack" the native event below, and it
    // appears to be a mouseOut event under the covers
    this.props.onAutocompleteSelect(event.nativeEvent.toElement);
  },

  render: function() {
    var completions = this.props.completions.map(function(completion, i) {
      if (this.props.selectedIdx === i) {
        return (
          <li
            className={TagAutocompleteStyleRules.selected}
            onClick={this.handleClick}
            onMouseEnter={this.handleMouseEnter}
            ref="selected">
            {completion}
          </li>
        );
      } else {
        return (
          <li onClick={this.handleClick} onMouseEnter={this.handleMouseEnter}>
            {completion}
          </li>
        );
      }
    }, this);

    var className = TagAutocompleteStyleRules.tagAutocomplete +
      (this.props.completions.length ? ' ' + TagAutocompleteStyleRules.active : '');

    return (
      <div className={className}>
        <ul>{completions}</ul>
      </div>
    );
  }
});

module.exports = TagAutocomplete;
