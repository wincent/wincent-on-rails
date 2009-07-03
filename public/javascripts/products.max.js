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
  link.prepend('<img class="widget expand" alt="expand" title="Click to enlarge" src="/images/dashboard-expand.png" />');

  /* start preloading image on mouseenter */
  link.mouseenter(function() {
    /* will store the preloaded image as a property in the thumbnail DOM element */
    if (thumbnail.fullsized)
        return; /* already been here for this image */
    var image = $('<img />').attr('src', link.attr('href'));
    image.thumbnail = $(thumbnail); /* keep reference to "parent" thumbnail */
    image.attr('title', image.thumbnail.attr('title'));
    $(image).load(function() {
      image.loaded = true;
      if (global_pending_lightbox_image == image) {
        show_image(image);
      }
    });
    thumbnail.fullsized = image;
  });

  /* show lightbox on click */
  var click = function(e) {
    disable_expand_widgets();
    if (e.data.tag.fullsized.loaded)
      show_image(e.data.tag.fullsized);
    else {
      show_spinner();
      global_pending_lightbox_image = e.data.tag.fullsized;
    }
    return false;
  }
  link.bind('click', { tag: thumbnail }, click);

  function show_image(image) {
    /* if spinner on screen, hide it */
    $('#lightbox-spinner-frame').hide();
    if ($('#lightbox-image-frame').length == 0) {
      /* add frame to DOM if not present already */
      $('#content').prepend(
        $('<div id="lightbox-image-frame">' +
          '<a href="#" title="Click to dismiss" onclick="return false;">' +
          '<img class="widget close" src="/images/dashboard-close.png" />' +
          '</a>' +
          '<div id="lightbox-caption"></div>' +
          '</div>').append(image).click(function() {
            $('#lightbox-image-frame').fadeOut('def');
            enable_expand_widgets();
          })
      );
    }
    else {
      /* frame was already present, just have to swap in new image */
      $('#lightbox-image-frame').find('img').not('.widget').remove();
      $('#lightbox-image-frame').append(image);
    }

    /* update caption */
    $('#lightbox-caption').html(image.attr('title'));

    /* position lightbox relative to thumbnail before fading it in:
     * - center horizontally relative to middle of document
     * - center vertically relative to middle of thumbnail
     */
    var thumbnail_offset = image.thumbnail.offset();
    var anchor_top = thumbnail_offset.top + image.thumbnail.height() / 2;
    var image_top = anchor_top - (image[0].height / 2);
    if (image_top + image[0].height + 20 > $(document).height()) /* allow 20px padding */
      image_top = $(document).height() - (image[0].height + 85);
    if (image_top < 25)
      image_top = 25;
    var left = ($(document).width() / 2) - (image[0].width / 2);
    if (left < 25)
      left = 25;
    $('#lightbox-image-frame').css('top', image_top + 'px').css('left', left + 'px').fadeIn('def');
  };

  function show_spinner() {
    if ($('#lightbox-spinner-frame').length == 0)
      /* don't add spinner more than once */
      $(document.body).append($('<div id="lightbox-spinner-frame">' +
        '<img id="lightbox-spinner" alt="spinner" src="/images/spinner-large.gif" />' +
        '</div>'));
    $('#lightbox-spinner-frame').show();
  };

  function disable_expand_widgets() {
    $('.widget.expand').each(function() {
      $(this).removeClass('opaque').addClass('translucent');
    })
    $('.lightbox').each(function () {
      $(this).parent().unbind('click').click(function() { return false; });
    });

  };

  function enable_expand_widgets() {
    $('.widget.expand').each(function() {
      $(this).removeClass('translucent').addClass('opaque');
    })
    $('.lightbox').each(function() { $(this).parent().unbind('click').bind('click', { tag: this }, click); });
  };
}

$(document).ready(function() {
  $('.lightbox').each(function () {
    lightbox(this)
  });
});
