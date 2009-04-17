/*
   Copyright 2008-2009 Wincent Colaiuta. All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

   1. Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
   2. Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
   ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
   LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
   CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
   SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
   INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
   ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
   POSSIBILITY OF SUCH DAMAGE.
 */

function getCookie(name) {
  var cookies = document.cookie.split('; ');
  for (var i = 0; i < cookies.length; i++) {
    var c = cookies[i];
    var pos = c.indexOf('=');
    var n = c.substring(0, pos);
    if (n == name)
      return c.substring(pos + 1);
  }
  return null;
}

// name (String), value (String or null), expiry (seconds or null)
function setCookie(name, value, expiry) {
  var cookieString = escape(name) + '=' + escape(value || '') + ';'
  if (expiry) {
    var d = new Date();
    d.setTime(d.getTime() + (1000 * parseInt(expiry)));
    cookieString = cookieString + ' expires=' + d.toGMTString() + ';'
  }
  cookieString = cookieString + ' path=/;'
  return document.cookie = cookieString;
}

function deleteCookie(name) {
  // set value to empty and expiry to yesterday
  return setCookie(name, null, -86400);
}

function setUpLoginLogoutLinks()
{
  var user = getCookie('user_id');
  if (user == null || user == '')
    jQuery('#logout').hide();
  else
    jQuery('#login').hide();
}

function insertFlash(css, msg) {
  if (msg) {
    jQuery('#cacheable-flash').append('<div id="' + css + '">' + msg + '</div>');
  }
}

function displayCacheableFlash() {
  var flash = getCookie('flash');
  if (flash) {
    flash = unescape(flash).gsub(/\+/, ' ').evalJSON(true);
    insertFlash('error', flash.error);
    insertFlash('notice', flash.notice);
    deleteCookie('flash');
  }
}

function relativizeDates()
{
  jQuery('.relative-date').each(function(i) {
    var result  = this.innerHTML;
    var now     = new Date;
    var then    = new Date(result);
    var dist    = now.getTime() - then.getTime();
    var months  = new Array('January', 'February',
        'March', 'April', 'May', 'June', 'July',
        'August', 'September', 'October', 'November',
        'December');
    var seconds = (dist / 1000).round();
    if (seconds < 0) {
      result = 'in the future';
    } else if (seconds == 0) {
      result = 'now';
    } else if (seconds < 60) {
      result = 'a few seconds ago';
    } else if (seconds < 120) {
      result = 'a minute ago';
    } else if (seconds < 180) {
      result = 'a couple of minutes ago';
    } else if (seconds < 300) { // 5 minutes
      result = 'a few minutes ago';
    } else if (seconds < 3600) { // 60 minutes
      result = (seconds / 60).round() + ' minutes ago';
    } else if (seconds < 7200) {
      result = 'an hour ago';
    } else if (seconds < 86400) { // 24 hours
      result = (seconds / 3600).round() + ' hours ago';
    } else {
      var days = (seconds / 86400).round();
      if (days == 1) {
        result = 'yesterday';
      } else if (days <= 7) {
        result = days + ' days ago';
      } else {
        var weeks = (days / 7).round();
        if (weeks == 1) {
          result = 'a week ago';
        } else if (weeks <= 6) {
          result = weeks + ' weeks ago';
        } else {
          // %d %B %Y
          result = then.getDate() + ' ' + months[then.getMonth()] + ' ' + then.getFullYear();
        }
      }
    }
    this.title = this.innerHTML;
    this.innerHTML = result;
  });
}

function escapeHTML(html) {
  return html.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}

function edit_in_place(selector, class_name, attribute_name, url) {
  var model_id = jQuery(selector).attr('id'); /* issue_22 */
  var record_id = model_id.match(/_(\d+)$/)[1]; /* 22 */
  var field_id = jQuery('#' + model_id + '_' + attribute_name); /* issue_22_summary */
  function highlight() { field_id.addClass('highlight'); }
  function unhighlight() { field_id.removeClass('highlight'); }
  function clickFunction() {
    var field_text = field_id.text();
    field_id.unbind('mouseenter mouseleave');
    unhighlight();
    field_id.attr('title', 'Click outside to abort editing');
    field_id.html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' +
      escapeHTML(field_text) +
      '"></form>');
    field_id.find('input')[0].select();
    field_id.unbind('dblclick');
    field_id.find('input').blur(function() {
      field_id.text(field_text);
      field_id.dblclick(clickFunction);
      field_id.hover(highlight, unhighlight);
    });
    field_id.find('form').submit(function() {
      var value = field_id.find('input').val();
      field_id.text('saving...');
      jQuery.ajax({
        'url': url + record_id,
        'type': 'post',
        'dataType': 'json',
        'data': '_method=put&' + class_name + '[' + attribute_name + ']=' + encodeURIComponent(value) +
          '&authenticity_token=' + encodeURIComponent(window.authenticity_token),
        'success': function(json) {
          field_id.text(json[class_name][attribute_name]);
        },
        'error': function() {
          field_id.text(value);
          /* possibly add CSS error coloring here */
          alert('something went wrong');
        },
        'complete': function() {
          field_id.hover(highlight, unhighlight);
          field_id.dblclick(clickFunction);
        }
      });
    });
  }
  field_id.attr('title', 'Double-click to edit');
  field_id.dblclick(clickFunction);
  field_id.hover(highlight, unhighlight);
}

function ajax_check_box(selector, class_name, attribute_name, url) {
  var model_id = jQuery(selector).attr('id'); /* issue_22 */
  var record_id = model_id.match(/_(\d+)$/)[1]; /* 22 */
  var field_id = jQuery('#' + model_id + '_' + attribute_name); /* issue_22_public */
  var field_text = field_id.text(); /* eg. true, false */
  var new_contents = '<input id="' + class_name + '_' + attribute_name +
    '" name="' + class_name + '[' + attribute_name + ']" type="checkbox">' +
    '<img alt="Spinner" id="' + class_name + '_' + attribute_name +
    '_spinner" src="/images/spinner.gif" style="margin-left: 0.75em; display: none;" />';
  field_id.html(new_contents);
  var check_box_id = field_id.find('input');
  if (field_text == 'true') {
    check_box_id.attr('checked', 'checked');
    }
  var old_attr = check_box_id.attr('checked');
  check_box_id.change(function() {
    var spinner = field_id.find('#' + class_name + '_' + attribute_name + '_spinner');
    spinner.show();
    jQuery.ajax({
      'url': url + record_id,
      'type': 'post',
      'dataType': 'json',
      'data': '_method=put&' + class_name + '[' + attribute_name + ']=' +
        check_box_id.attr('checked') + '&authenticity_token=' +
        encodeURIComponent(window.authenticity_token),
      'success': function(json) {
        old_attr = check_box_id.attr('checked');
      },
      'error': function() {
        alert('something went wrong');
        check_box_id.attr('checked', old_attr);
      },
      'complete': function() {
        spinner.hide();
      }
    });
  });
}

function ajax_select(selector, class_name, attribute_name, options, include_blank, url) {
  var model_id = jQuery(selector).attr('id'); /* issue_22 */
  var record_id = model_id.match(/_(\d+)$/)[1]; /* 22 */
  var field_id = jQuery('#' + model_id + '_' + attribute_name); /* issue_22_status */
  var field_text = field_id.text(); /* eg. New, Open, Closed (first letter capitalized by humanize method) */
  var new_contents = '<select id="' + class_name + '_' + attribute_name + '" name="' + class_name + '[' + attribute_name + ']">';
  if (include_blank) {
    new_contents = new_contents + '<option value=""></option>';
  }
  var selection_found = false;
  for (var i = 0; i < options.length; i++) {
    if (field_text.toLowerCase() == options[i][0]) {
      new_contents = new_contents + '<option value="' + options[i][1] + '" selected="selected">' + options[i][0] + '</option>';
      selection_found = true;
    } else {
      new_contents = new_contents + '<option value="' + options[i][1] + '">' + options[i][0] + '</option>';
    }
  }
  new_contents = new_contents + '</select><img alt="Spinner" id="' + class_name + '_' + attribute_name + '_spinner" src="/images/spinner.gif" style="margin-left: 0.75em; display: none;" />';
  field_id.html(new_contents);
  var select_id = field_id.find('select');
  if (!selection_found) {
    if (!include_blank) {
      alert('option not found');
      /* will probably choose to fail silently here instead, or fall back and select first option */
    } else {
      /* if none of the options match, eg "no product", must be the "blank" option */
      select_id.find('option:first').attr('selected', 'selected');
    }
  }
  var old_val = field_id.find('select option:selected').text();
  select_id.change(function() {
    var spinner = field_id.find('#' + class_name + '_' + attribute_name + '_spinner');
    spinner.show();
    jQuery.ajax({
      'url': url + record_id,
      'type': 'post',
      'dataType': 'json',
      'data': '_method=put&' + class_name + '[' + attribute_name + ']=' + select_id.val() +
        '&authenticity_token=' + encodeURIComponent(window.authenticity_token),
      'success': function(json) {
        old_val = field_id.find('select option:selected').text();
      },
      'error': function() {
        alert('something went wrong');
        select_id.val(old_val);
      },
      'complete': function() {
        spinner.hide();
      }
    });
  });
}

jQuery(document).ready(function() {
  setUpLoginLogoutLinks();
  displayCacheableFlash();
  relativizeDates();
});
