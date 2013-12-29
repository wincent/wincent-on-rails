/**
 * @jsx React.DOM
 */
"use strict";

var React                     = require("React"),
    ReactStyle                = require("ReactStyle"),
    TagAutocompleteStyleRules = require("./TagAutocompleteStyleRules");

ReactStyle.addRules(TagAutocompleteStyleRules);

var TagAutocomplete = React.createClass({
  getInitialState: function() {
    return {};
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  render: function() {
    var completions = this.props.completions.map(function(completion, i) {
      if (this.props.selectedIdx === i) {
        var className = TagAutocompleteStyleRules.selected;
      }
      return <li key={i} className={className}>{completion}</li>;
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
