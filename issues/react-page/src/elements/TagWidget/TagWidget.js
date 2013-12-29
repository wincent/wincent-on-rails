/**
 * @jsx React.DOM
 */
"use strict";

var React               = require("React"),
    ReactStyle          = require("ReactStyle"),
    TagAutocomplete     = require("../TagAutocomplete/TagAutocomplete"),
    TagInput            = require("../TagInput/TagInput"),
    TagPill             = require("../TagPill/TagPill"),
    TagWidgetStyleRules = require("../TagWidget/TagWidgetStyleRules");

var UP_KEY_CODE        = 38, // previous autocomplete suggestion
    DOWN_KEY_CODE      = 40; // next autocomplete suggestion

ReactStyle.addRules(TagWidgetStyleRules);

var TagWidget = React.createClass({
  getInitialState: function() {
    return { tags: ['foo', 'bar', 'foo.bar'] };
  },

  componentDidMount: function() {
  },

  componentWillUnmount: function() {
  },

  handleClick: function(event) {
    // if outside of input area, focus input
    var tagInput = this.refs.tagInput.getDOMNode();
    if (event.target !== tagInput) {
      tagInput.focus();
    }
  },

  handleKeyDown: function(event) {
    var keyCode        = event.keyCode,
        maxSelectedIdx = 4, // TODO: put real value here
        oldSelectedIdx = this.state.autocompleteSelectedIdx,
        newSelectedIdx;

    if (typeof oldSelectedIdx === "undefined" &&
        typeof maxSelectedIdx !== "undefined" &&
        keyCode === DOWN_KEY_CODE) {
      newSelectedIdx = 0;
    } else if (keyCode === UP_KEY_CODE && oldSelectedIdx > 0) {
      newSelectedIdx = oldSelectedIdx - 1;
    } else if (keyCode === DOWN_KEY_CODE && oldSelectedIdx < maxSelectedIdx) {
      newSelectedIdx = oldSelectedIdx + 1;
    } else {
      return;
    }

    event.preventDefault();
    this.state.autocompleteSelectedIdx = newSelectedIdx;
    this.setState(this.state);
  },

  // called whenever the child TagInput component is used to add a new tag
  handleTagPush: function(newTag) {
    newTag = newTag
      .trim()
      .toLowerCase()
      .replace(/ +/g, '.')           // spaces become dots
      .replace(/[^a-z0-9.]+/gi, ''); // all other illegal chars get eaten

    // NOTE: might want to provide better feedback for the edge case where the
    // entire thing gets eaten
    if (newTag.length) {
      this.state.tags.push(newTag);
      this.setState(this.state);
    }
  },

  handleTagPop: function() {
    if (this.state.tags.length) {
      this.state.tags.pop();
      this.setState(this.state);
    }
  },

  handleTagDelete: function(name) {
    this.state.tags.splice(this.state.tags.indexOf(name), 1);
    this.setState(this.state);
  },

  render: function() {
    var tagPills = this.state.tags.map(function(name) {
      return <TagPill name={name}
                      onTagDelete={this.handleTagDelete} />;
    }.bind(this));

    return (
      <div className={TagWidgetStyleRules.tagWidget}
           onClick={this.handleClick}
           onDragStart={this.handleDragStart}
           onKeyDown={this.handleKeyDown}>
        {tagPills}
        <TagInput ref="tagInput"
                  onTagPush={this.handleTagPush}
                  onTagPop={this.handleTagPop} />
        <TagAutocomplete selectedIdx={this.state.autocompleteSelectedIdx} />
      </div>
    );
  },
});

module.exports = TagWidget;
