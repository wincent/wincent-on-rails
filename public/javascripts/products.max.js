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

/* a cache of pre-loaded lightbox images */
var global_lightbox_images = [];

/* set up lightbox */
function lightbox(thumbnail) {

  /* add "expand" widget */
  var link = thumbnail.parent();
  link.wrap('<div class="lightbox-wrapper"></div>');
  link.prepend('<img class="widget" src="/images/dashboard-expand.png" />');

  /* start preloading image on mouseenter */
  link.mouseenter(function() {
    var image;
    for (i = 0; i < global_lightbox_images.length; i++) {
      image = global_lightbox_images[i];
      if (image.attr('src') == link.attr('href'))
        return; /* already been here for this image */
    }
    image = $('<img />').attr('src', link.attr('href')).load(function() {
    });
    global_lightbox_images.push(image);

    /* add hidden div
     * add hidden spinner
     * add hidden div inside
     */
  });

  /* show lightbox on click */
  var click = function() {
    var frame = $('<div id="lightbox-spinner-frame">' +
      '<img id="lightbox-spinner" alt="spinner" src="/images/spinner-large.gif" />' +
      '</div>');
    link.append(frame);
    frame.show();
    link.unbind('click');
    link.click(function() { return false; });
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
}

$(document).ready(function() {
  $('.lightbox').each(function () {
    lightbox($(this))
  });
});
