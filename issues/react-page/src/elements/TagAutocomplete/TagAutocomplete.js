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
    return { completions: ['git', 'javascript', 'os.x', 'rails', 'security'] };
  },

  componentDidMount: function() {
  },

  componentWillMount: function() {
  },

  render: function() {
    var completions = this.state.completions.map(function(completion, i) {
      if (this.props.selectedIdx === i) {
        var className = TagAutocompleteStyleRules.selected;
      }
      return <li key={i} className={className}>{completion}</li>;
    }.bind(this));

    return (
      <div className={TagAutocompleteStyleRules.tagAutocomplete}>
        <ul>
          {completions}
        </ul>
      </div>
    );
  }
});

module.exports = TagAutocomplete;
