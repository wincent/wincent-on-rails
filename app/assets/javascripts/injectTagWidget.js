'use strict';

import React from 'react';
import TagWidget from './TagWidget.react';

/**
 * Temporary means of injecting this React widget into a rendered page.
 *
 * Will most likely change once we have server-side rendering.
 */
export default function injectTagWidget(modelName) {
  const input = document.getElementById(modelName + '_pending_tags');
  if (input) {
    const pendingTags = input.value;
    const div = document.createElement('div');
    input.parentNode.replaceChild(div, input);

    React.render(
      <TagWidget
        pendingTags={pendingTags}
        resourceName={`${modelName}[pending_tags]`}
      />,
      div
    );
  }
};
