/*
   Copyright 2008-2009 Wincent Colaiuta.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU Affero General Public License as
   published by the Free Software Foundation, either version 3 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU Affero General Public License for more details.

   You should have received a copy of the GNU Affero General Public
   License along with this program.  If not, see
   <http://www.gnu.org/licenses/>.

   A copy of the GNU Affero General Public License is also available
   at <https://wincent.com/javascripts/agpl-3.0.txt>
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
    var now = new Date();
    expiry = now.setTime(now.getTime() + 1000 * parseInt(expiry));
    cookieString = cookieString + ' expires=' + expiry.toGMTString() + ';'
  }
  cookieString = cookieString + ' path=/;'
  return document.cookie = cookieString;
}

function deleteCookie(name) {
  return setCookie(name, null, null);
}

function setUpLoginLogoutLinks()
{
  var user = getCookie('user_id');
  if (user == null || user == '')
    $('logout').hide();
  else
    $('login').hide();
}

function relativizeDate(element)
{
  var result  = element.innerHTML;
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
  element.title = element.innerHTML;
  element.innerHTML = result;
}

document.observe("dom:loaded", function() {
  setUpLoginLogoutLinks();
  $$('.relative-date').each(function(elem, idx) { relativizeDate(elem) });
});
