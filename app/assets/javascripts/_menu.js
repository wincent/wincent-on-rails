// Copyright 2013 Wincent Colaiuta. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

(function() {
  'use strict';

  Wincent.Menu = Class.subclass({
    appSelector        : '.app',
    menuButtonSelector : '.menu-icon',
    menuSelector       : '.menu',
    viewportSelector   : '.viewport',

    init: function() {
      this.$menu     = $(this.menuSelector);
      this.$viewport = $(this.viewportSelector);
      this.$app      = $(this.appSelector)
        .on('click', this.close.bind(this))
        .on('transitionend oTransitionEnd webkitTransitionEnd', // IE/Moz, Opera, WebKit
            this.handleTransitionEnd.bind(this));

      $(this.menuButtonSelector)
        .on('click', this.handleMenuButtonClick.bind(this));
    },

    handleMenuButtonClick: function(evt) {
      this.toggle();

      // if app content is too short, don't want slideout animation to get cropped
      this.$app.css('min-height', $(window).height() + 'px');

      // must stop propagation here as well, otherwise our $app click event will
      // trigger and we'll immediately close the menu again
      return false;
    },

    toggle: function() {
      this[this.$viewport.hasClass('menu-open') ? 'close' : 'open']();
    },

    open: function() {
      this.$menu.removeClass('hide');
      this.$viewport.addClass('menu-open').removeClass('menu-closed');
    },

    close: function() {
      this.$viewport.removeClass('menu-open');
    },

    handleTransitionEnd: function(evt) {
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
  });
})();
