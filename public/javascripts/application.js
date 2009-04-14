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

jQuery(document).ready(function() {
  setUpLoginLogoutLinks();
  displayCacheableFlash();
  relativizeDates();
});
