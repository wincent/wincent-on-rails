/**
 * @jsx React.DOM
 */
"use strict";

var React               = require("React"),
    ReactStyle          = require("ReactStyle"),
    TagPill             = require("../TagPill/TagPill.js"),
    TagInput            = require("../TagInput/TagInput.js"),
    TagWidgetStyleRules = require("../TagWidget/TagWidgetStyleRules.js");

ReactStyle.addRules(TagWidgetStyleRules);

var TagWidget = React.createClass({
  getInitialState: function() {
    return { data: ['foo', 'bar', 'foo.bar'] };
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

  handleTagInput: function(newTag) {
    newTag = newTag
      .trim()
      .toLowerCase()
      .replace(/ +/g, '.')           // spaces become dots
      .replace(/[^a-z0-9.]+/gi, ''); // all other illegal chars get eaten

    // NOTE: might want to provide better feedback for the edge case where the
    // entire thing gets eaten
    if (newTag.length) {
      this.state.data.push(newTag);
      this.setState(this.state);
    }
  },

  render: function() {
    return (
      <div className={TagWidgetStyleRules.tagWidget}
           onClick={this.handleClick}>
        {this.state.data.map(function(s) { return <TagPill name={s} />; })}
        <TagInput ref="tagInput"
                  onTagInput={this.handleTagInput} />
      </div>
    );
  },
});

module.exports = TagWidget;
