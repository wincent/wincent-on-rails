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
