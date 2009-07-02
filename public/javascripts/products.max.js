// Copyright 2009 Wincent Colaiuta. All rights reserved.
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

var global_pending_lightbox_image = null;

/* set up lightbox */
function lightbox(thumbnail) {

  /* add "expand" widget */
  var link = $(thumbnail).parent();
  link.wrap('<div class="lightbox-wrapper"></div>');
  link.prepend('<img class="widget expand" src="/images/dashboard-expand.png" />');

  /* start preloading image on mouseenter */
  link.mouseenter(function() {
    /* will store the preloaded image as a property in the thumbnail DOM element */
    if (thumbnail.fullsized)
        return; /* already been here for this image */
    var image = $('<img />').attr('src', link.attr('href'));
    $(image).load(function() {
      image.loaded = true;
      if (global_pending_lightbox_image == image) {
        show_image(image);
      }
    });
    thumbnail.fullsized = image;
  });

  /* show lightbox on click */
  var click = function() {
    show_spinner();
    dim_expand_widgets();

    /* ignore multiple clicks for all lightboxes */
    $('.lightbox').each(function () {
      $(this).parent().each(function () {
        $(this).unbind('click').click(function() { return false; });
      });
    });

    if (thumbnail.fullsized.loaded)
      show_image(thumbnail.fullsized);
    else
      global_pending_lightbox_image = thumbnail.fullsized;
    return false;
  }
  link.click(click);

  /* hide lightbox on second click */
  var unclick = function() {

    return false;
  }

  /*
   * on click, show spinner and load image (if image not loaded yet)
   * background will be dark black, semi-transparent
   * will probably have rounded corners
   * then zoom out to show image
   * show close box
   * clicking on image also closes box
   * show "title" attribute as caption (white text on transparent dark background?)
   */

  function show_image(image) {
    /* if spinner on screen, hide it */
    $('#lightbox-spinner-frame').hide();
    var frame = $('#lightbox-image-frame');
    if (frame.length == 0) {
      /* add frame to DOM if not present already */
      frame = $('<div id="lightbox-image-frame"></div>');
      frame.append(image);
      $('#content').prepend(frame);
    }
  };

  function show_spinner() {
    if ($('#lightbox-spinner-frame').length == 0)
      /* don't add spinner more than once */
      $(document.body).append($('<div id="lightbox-spinner-frame">' +
        '<img id="lightbox-spinner" alt="spinner" src="/images/spinner-large.gif" />' +
        '</div>'));
    $('#lightbox-spinner-frame').show();
  };

  function dim_expand_widgets() {
    $('.widget.expand').each(function() {
      $(this).removeClass('opaque').addClass('translucent');
    })
  };

  function undim_expand_widgets() {
    $('.widget.expand').each(function() {
      $(this).removeClass('translucent').addClass('opaque');
    })
  };
}

$(document).ready(function() {
  $('.lightbox').each(function () {
    lightbox(this)
  });
});
