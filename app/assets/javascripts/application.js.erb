// Copyright 2008-2011 Wincent Colaiuta. All rights reserved.
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
  var getCookie = function(name) {
    var cookies = document.cookie.split('; ');
    for (var i = 0; i < cookies.length; i++) {
      var c = cookies[i];
      var pos = c.indexOf('=');
      var n = c.substring(0, pos);
      if (n === name) {
        return c.substring(pos + 1);
      }
    }
    return null;
  }

  // name (String), value (String or null), expiry (seconds or null)
  var setCookie = function(name, value, expiry) {
    var cookieString = escape(name) + '=' + escape(value || '') + ';'
    if (expiry) {
      var d = new Date();
      d.setTime(d.getTime() + (1000 * parseInt(expiry)));
      cookieString = cookieString + ' expires=' + d.toGMTString() + ';'
    }
    cookieString = cookieString + ' path=/;'
    return document.cookie = cookieString;
  }

  var deleteCookie = function(name) {
    // set value to empty and expiry to yesterday
    return setCookie(name, null, -86400);
  }

  var setUpLoginLogoutLinks = function() {
    var user = getCookie('user_id');
    if (user === null || user === '') {
      $('#logout').remove();
    }
    else {
      $('#login').remove();
    }
  }

  var insertFlash = function(css, msg) {
    if (msg) {
      $('#cacheable-flash').append($('<div/>', { 'class': css, html: msg }));
    }
  }

  var displayCacheableFlash = function() {
    var flash = getCookie('flash');
    if (flash) {
      flash = unescape(flash).replace(/\+/g, ' ');
      flash = eval('flash = ' + flash + ';');
      insertFlash('error', flash.error);
      insertFlash('notice', flash.notice);
      deleteCookie('flash');
    }
  }

  $.fn.relativizeDates = function() {
    var dateFromUTCString = function(s) {
      var m = s.match(/(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}) UTC/);

      // use an explicit radix to avoid misinterpretation as hex due to possible
      // leading 0 on all fields except for year
      return m ?
        new Date(Date.UTC(parseInt(m[1]),
              parseInt(m[2], 10) - 1, // Date.UTC expects zero-based month numbers (0-11)
              parseInt(m[3], 10),
              parseInt(m[4], 10),
              parseInt(m[5], 10),
              parseInt(m[6], 10)))
        : new Date; // fall back to current time if regex failed
    }

    this.find('.relative-date')
      .removeClass('relative-date')
      .addClass('relativized-date')
      .each(function(i) {
      var result  = this.innerHTML;
      var now     = new Date;
      var then    = dateFromUTCString(result);
      var dist    = now.getTime() - then.getTime();
      var months  = new Array('January', 'February',
          'March', 'April', 'May', 'June', 'July',
          'August', 'September', 'October', 'November',
          'December');
      var seconds = Math.round((dist / 1000));
      if (seconds < 0) {
        result = 'in the future';
      }
      else if (seconds === 0) {
        result = 'now';
      }
      else if (seconds < 60) {
        result = 'a few seconds ago';
      }
      else if (seconds < 120) {
        result = 'a minute ago';
      }
      else if (seconds < 180) {
        result = 'a couple of minutes ago';
      }
      else if (seconds < 300) { // 5 minutes
        result = 'a few minutes ago';
      }
      else if (seconds < 3600) { // 60 minutes
        result = Math.round(seconds / 60) + ' minutes ago';
      }
      else if (seconds < 7200) {
        result = 'an hour ago';
      }
      else if (seconds < 86400) { // 24 hours
        result = Math.round(seconds / 3600) + ' hours ago';
      }
      else {
        var days = Math.round(seconds / 86400);
        if (days === 1) {
          result = 'yesterday';
        }
        else if (days <= 7) {
          result = days + ' days ago';
        }
        else {
          var weeks = Math.round(days / 7);
          if (weeks === 1) {
            result = 'a week ago';
          }
          else if (weeks <= 6) {
            result = weeks + ' weeks ago';
          }
          else {
            result = then.toLocaleDateString();
          }
        }
      }
      this.title = then.toLocaleString();
      this.innerHTML = result;
    });

    return this;
  }

  $.fn.syntaxHighlight = function()
  {
    var styles = {};
    styles['c-syntax'] = {
      'preprocessor':     /^\s*#.*/m, // without m (multi-line) mode, ^ anchors at start of string
      'comment':          /\/\/.*|\/\*([^\*]|\*(?!\/))*\*\//,
      'string-literal':   /("(<a .+?a>|[^"\\]|\\.)*"|'([^'\\]|\\.)?')/,
      'keyword':          /\b(_Bool|bool|char|const|int|long|short|struct|typedef|unsigned|void)\b/,
      'statement':        /\b(break|case|continue|default|do|else|for|goto|if|return|sizeof|static|switch|while)\b/,
      'boolean':          /\b(true|false)\b/,
      'numeric-literal':  /\b(0[xX][a-fA-F0-9]+|\d+(\.\d+f?)?)\b/
    };

    // for Git diffs and patches
    styles['diff-syntax'] = {
      'skip-header':  /^(---|\+\+\+) .*/m,
      'deleted':      /^-.*/m,
      'added':        /^\+.*/m,
      'hunk-header':  /^@@ -\d+(,\d+) \+\d+(,\d+) @@.*/m
    };

    // Objective-C is based on C with some overrides
    styles['objc-syntax'] = $.extend({}, styles['c-syntax'], {
      'keyword': /\b(_Bool|BOOL|bool|char|const|int|long|short|struct|typedef|unsigned|void)\b/,
      'boolean': /\b(YES|NO|true|false)\b/
    });

    styles['ruby-syntax'] = {
      // could almost make these default rules
      'skip-anchor':      /<a .+?a>/,  // don't mangle HTML tags ("a" tags)
      'skip-entities':    /&\w+;/,     // or entities
      'comment':          /#.*/,
      'string-literal':   /("(<a .+?a>|[^"\\]|\\.)*"|'(<a .+?a>|[^'\\]|\\.)*')/,
      'keyword':          /\b(begin|break|catch|class|continue|def|else|end|for|if|include|load|module|raise|redo|require|rescue|retry|then|throw|unless|until|while|yield)\b/,
      'statement':        /\b(private|protected|public)\b/,
      'boolean':          /\b(true|false)\b/,
      'constant':         /\b[A-Z][a-zA-Z0-9_]*\b/,
      'namespace':        /::/, // no CSS for this; just to stop false positives for the symbol rule
      'identifier':       /(\$|@{1,2})[a-z_][a-zA-Z0-9_]*\b/, // or to be zealous, add: |\b[a-z][a-zA-Z0-9_]*\b
      'symbol':           /:[a-zA-Z_][a-zA-Z0-9_]*\b/,
      'numeric-literal':  /\b(0[xX][a-fA-F0-9]+(_[a-fA-F0-9]+)*|0[bB][0-1]+(_[0-1]+)*|[0-9]+(_[0-9]+)*(\.[0-9]+(_[0-9]+)*)?)\b/
    };

    // syntax coloring for a transcript of a shell session
    // for syntax coloring of a shell script see "bash-syntax"
    styles['shell-syntax'] = {
      'output':           /^[^#\$\n].*/m, // no CSS
      'constant':         /(\\\n|.)+/m    // the command
    };

    var highlightText = function(text, rules)
    {
      if (!rules)
        return text;

      var output    = '';
      while (text !== '') {
        // iterate through rules, leftmost match wins
        // in case of tie, first matching rule wins (earlier rules have priority)
        var leftmost  = null;
        var apply     = null;
        for (var rule in rules) {
          var match = text.match(rules[rule]);
          if (match && ((leftmost && match.index < leftmost) || !leftmost)) {
            leftmost    = match.index;
            match.rule  = rule;
            apply       = match;
            if (leftmost === 0) {
              break;
            }
          }
        }
        if (apply) {
          var start_span = '<span class="' + apply.rule + '-syntax">';
          var end_span = '</span>';
          if (apply.rule.match(/^skip-/)) {
            start_span = '';
            end_span = '';
          }
          output = output + text.substring(0, apply.index) + start_span + apply[0] + end_span;
          text = text.substring(apply.index + apply[0].length);
        }
        else {
          output = output + text;
          break;
        }
      }
      return output;
    }

    this.find("pre[class$=syntax][class!=highlighted]").each(function(i) {
      // do the syntax-highlighting
      var rules = styles[$(this).attr('class')];
      var content = highlightText(this.innerHTML, rules);

      // line-numbering
      var span = '<span class="line-number"></span>';
      var lines = content.split('\n');
      this.innerHTML = span + lines.join('\n' + span);

      // guard against repeated highlighting
      $(this).addClass('highlighted');
    });

    return this;
  };

  var setUpSearchLink = function() {
    $('#search-link').click(function () {
      $('#search_box').toggle().focus();
      return false;
    });
  }

  // if the URL includes a fragment identifier (ie. #foo)
  // then add the "active-fragment" class to the corresponding element
  var highlightActiveFragment = function() {
    var frag = window.location.hash;
    if (frag.length >= 2)
      $(frag).addClass('active-fragment');
  }

  $(document).ready(function() {
    setUpLoginLogoutLinks();
    setUpSearchLink();
    displayCacheableFlash();
    highlightActiveFragment();

    $('body')
      .syntaxHighlight()
      .relativizeDates();

    // set up "confirm" dialogs
    $('input[data-confirm]').live('click', function() {
      return confirm($(this).attr('data-confirm'));
    });

    $('form[data-remote]').live('submit', function(event) {
      var form = $(this);
      var submits = form.find('input[type=submit]');
      if (submits.hasClass('disabled')) {
        return false;
      }
      submits.addClass('disabled');
      $.ajax({
        url: form.attr('action') + '.js',
        type: 'post',
        data: form.serialize(),
        error: function() { alert('Form submission failed'); },
        complete: function() { submits.removeClass('disabled'); }
      });
      event.preventDefault();
    });

    // set up "popup" links
    $('a[data-popup]').live('click', function() {
      window.open(this.href, null, $(this).attr('data-popup'));
      return false;
    });
  });
})();
