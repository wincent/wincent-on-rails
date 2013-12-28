/**
 * @jsx React.DOM
 */
"use strict";

var React               = require("React"),
    ReactStyle          = require("ReactStyle"),
    TagAutocomplete     = require("../TagAutocomplete/TagAutocomplete.js"),
    TagInput            = require("../TagInput/TagInput.js"),
    TagPill             = require("../TagPill/TagPill.js"),
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
      this.state.data.push(newTag);
      this.setState(this.state);
    }
  },

  handleTagPop: function() {
    if (this.state.data.length) {
      this.state.data.pop();
      this.setState(this.state);
    }
  },

  handleTagDelete: function(name) {
    this.state.data.splice(this.state.data.indexOf(name), 1);
    this.setState(this.state);
  },

  render: function() {
    var tagPills = this.state.data.map(function(name) {
      return <TagPill name={name}
                      onTagDelete={this.handleTagDelete} />;
    }.bind(this));

    return (
      <div className={TagWidgetStyleRules.tagWidget}
           onClick={this.handleClick}
           onDragStart={this.handleDragStart} >
        {tagPills}
        <TagInput ref="tagInput"
                  onTagPush={this.handleTagPush}
                  onTagPop={this.handleTagPop} />
        <TagAutocomplete />
      </div>
    );
  },
});

module.exports = TagWidget;
