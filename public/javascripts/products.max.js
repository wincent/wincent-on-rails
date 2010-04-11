// Copyright 2009-2010 Wincent Colaiuta. All rights reserved.
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

// set up lightbox
function lightbox(thumbnail) {

  // add "expand" widget
  var link = $(thumbnail).parent();
  link.wrap('<div class="lightbox-wrapper"></div>');
  link.prepend('<img class="widget expand" alt="expand" title="Click to enlarge" src="/images/dashboard-expand.png" />');

  // examine target href for type and params
  var href = link.attr('href');
  var is_image = !href.match(/\.mov(\?.*)?$/);
  var params = {};
  if (href.match(/(.+)\?(.+)$/)) {
    href = RegExp.$1; // strip off query component
    $.each(RegExp.$2.split('&'), function(idx, val) {
      var key_value_pair = val.split('=');
      params[key_value_pair[0]] = key_value_pair[1];
    });
  }

  // for images, start preloading on mouseenter
  if (is_image) {
    link.mouseenter(function() {
      // will store the preloaded image as a property in the thumbnail DOM element
      if (thumbnail.fullsized)
          return; // already been here for this image
      var image = $('<img />').attr('src', href);
      image.thumbnail = $(thumbnail); // keep reference to "parent" thumbnail
      image.attr('title', image.thumbnail.attr('title'));
      $(image).load(function() {
        image.loaded = true;
        if (global_pending_lightbox_image == image) {
          show_image(image);
        }
      });
      thumbnail.fullsized = image;
    });
  }
  else {
    // movie dimensions come from query string
    // or if no query string, from image thumbnail
    var width = parseInt(params['width'] || link.width());
    var height = parseInt(params['height'] || link.height()) + 16; // plus 16 pixels for controls
    var movie = $('<object/>', {
      classid: "clsid:02BF25D5-8C17-4B23-BC80-D3488ABDDC6B",
      codebase: "http://www.apple.com/qtactivex/qtplugin.cab",
      width: width,
      height: height
    })
    .append($('<param/>', { name: 'src', value: href }))
    .append($('<param/>', { name: 'autoplay', value: 'true' }))
    .append($('<embed/>', {
      src: href,
      width: width,
      height: height,
      type: 'quicktime/video',
      autoplay: 'true',
      pluginspage: 'http://www.apple.com/quicktime/download/'
    }));
    movie.thumbnail = $(thumbnail); // keep reference to "parent" thumbnail
    thumbnail.fullsized = movie;
  }

  // show lightbox on click
  var click = function(e) {
    disable_expand_widgets();
    if (is_image) {
      if (e.data.tag.fullsized.loaded)
        show_image(e.data.tag.fullsized);
      else {
        show_spinner();
        global_pending_lightbox_image = e.data.tag.fullsized;
      }
    }
    else
      show_movie(e.data.tag.fullsized);
    return false;
  }
  link.bind('click', { tag: thumbnail }, click);

  function show_movie(movie) {
    show_lightbox(movie);
  }

  function show_image(image) {
    show_lightbox(image);
  }

  function show_lightbox(content) {
    // if spinner on screen, hide it
    $('#lightbox-spinner-frame').hide();
    if ($('#lightbox-image-frame').length == 0) {
      // add frame to DOM if not present already
      $('#content').prepend(
        $('<div id="lightbox-image-frame">' +
          '<a href="#" title="Click to dismiss" onclick="return false;">' +
          '<img class="widget close" src="/images/dashboard-close.png" />' +
          '</a>' +
          '<div id="lightbox-caption"></div>' +
          '</div>').append(content).click(function() {
            $('#lightbox-image-frame').fadeOut('def');
            enable_expand_widgets();
          })
      );
    }
    else {
      // frame was already present, just have to swap in new content
      $('#lightbox-image-frame').find('img').not('.widget').remove();
      $('#lightbox-image-frame').append(content);
    }

    // update caption
    $('#lightbox-caption').html(content.attr('title'));

    // position lightbox relative to thumbnail before fading it in:
    // - center horizontally relative to middle of document
    // - center vertically relative to middle of thumbnail
    var thumbnail_offset = content.thumbnail.offset();
    var anchor_top = thumbnail_offset.top + content.thumbnail.height() / 2;
    var content_top = anchor_top - (content[0].height / 2);
    if (content_top + content[0].height + 20 > $(document).height()) // allow 20px padding
      content_top = $(document).height() - (content[0].height + 85);
    if (content_top < 25)
      content_top = 25;
    var left = ($(document).width() / 2) - (content[0].width / 2);
    if (left < 25)
      left = 25;
    $('#lightbox-image-frame').css('top', content_top + 'px').css('left', left + 'px').fadeIn('def');

    // if possible, scroll so that lightbox is centered within viewport
    var w_width = window.innerWidth;
    var w_height = window.innerHeight;
    var w_origin_x = window.pageXOffset;
    var w_origin_y = window.pageYOffset;
    if (typeof w_width == 'undefined' ||
        typeof w_height == 'undefined' ||
        typeof w_origin_x == 'undefined' ||
        typeof w_origin_y == 'undefined')
      return;
    var lightbox_center_x = left + content[0].width / 2;
    var lightbox_center_y = content_top + content[0].height / 2;
    var viewport_center_x = w_origin_x + w_width / 2;
    var viewport_center_y = w_origin_y + w_height / 2;
    w_origin_x -= viewport_center_x - lightbox_center_x;
    w_origin_y -= viewport_center_y - lightbox_center_y;
    if (w_origin_x < 0)
      w_origin_x = 0;
    else if (w_origin_x + w_width > $(document).width())
      w_origin_x = $(document).width() - w_width;
    if (w_origin_y < 0)
      w_origin_y = 0;
    else if (w_origin_y + w_height > $(document).height())
      w_origin_y = $(document).height() - w_height;
    $('html,body').animate({
      scrollLeft: w_origin_x,
      scrollTop: w_origin_y
    }, 'slow');
  };

  function show_spinner() {
    if ($('#lightbox-spinner-frame').length == 0)
      // don't add spinner more than once
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
