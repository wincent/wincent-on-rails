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
      return <li key={i}>{completion}</li>;
    });

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
