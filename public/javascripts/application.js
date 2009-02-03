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
  element.innerHTML = result;
}

document.observe("dom:loaded", function() {
  setUpLoginLogoutLinks();
  $$('.relative-date').each(function(elem, idx) { relativizeDate(elem) });
});
