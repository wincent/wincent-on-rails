'use strict';

var $ = require('jquery');

class Menu {
  constructor() {
    this.appSelector        = '.app';
    this.menuButtonSelector = '.menu-icon';
    this.menuSelector       = '.menu';
    this.viewportSelector   = '.viewport';
    this.$menu     = $(this.menuSelector);
    this.$viewport = $(this.viewportSelector);
    this.$app      = $(this.appSelector)
      .on('click', this.close.bind(this))
      .on('transitionend oTransitionEnd webkitTransitionEnd', // IE/Moz, Opera, WebKit
          this.handleTransitionEnd.bind(this));

    $(this.menuButtonSelector)
      .on('click', this.handleMenuButtonClick.bind(this));
  }

  handleMenuButtonClick(event) {
    this.toggle();

    // if app content is too short, don't want slideout animation to get cropped
    this.$app.css('min-height', $(window).height() + 'px');

    // must stop propagation here as well, otherwise our $app click event will
    // trigger and we'll immediately close the menu again
    return false;
  }

  toggle() {
    this[this.$viewport.hasClass('menu-open') ? 'close' : 'open']();
  }

  open() {
    this.$menu.removeClass('hide');
    this.$viewport.addClass('menu-open').removeClass('menu-closed');
  }

  close() {
    this.$viewport.removeClass('menu-open');
  }

  handleTransitionEnd(event) {
    // Work around some subtle WebKit bugs triggered by transition and
    // translateX. If we just remove the "menu-open" class we get broken
    // scrolling behavior and blank space to the right of the content area.
    //
    // Instead, we wait until the transition is over and then hide the menu,
    // which fixes the scrolling problem, and set the position of the content
    // by applying a class, which fixes the blank space.
    if (!this.$viewport.hasClass('menu-open')) {
      this.$menu.addClass('hide');
      this.$viewport.addClass('menu-closed');
    }
  }
}

module.exports = Menu;
