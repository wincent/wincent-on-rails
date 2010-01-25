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

var global_spinner_counter = 0;

function escapeHTML(html) {
  return html
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function insertAJAXFlash(css_class, msg) {
  $('#ajax-flash')
    .append($('<div/>', { 'class': css_class, html: escapeHTML(msg) }))
    .show();
  alert('worked');
}

function clearAJAXFlash() {
  $('#ajax-flash').fadeOut('slow', function() { $(this).hide(); });
}

function ajax_comment_form(url) {
  var comment_div = $('#comment-form');
  var anchor = comment_div.find('a');
  anchor.attr('href', '#comment-form');
  var click = function() {
    anchor.unbind('click');
    var spinner_id = 'spinner_' + global_spinner_counter++;
    comment_div.append('<img alt="Spinner" id="' + spinner_id + '" class="spinner" src="/images/spinner.gif" />');
    var spinner = comment_div.find('#' + spinner_id);
    spinner.show();
    $.ajax({
      'url': url,
      'type': 'get',
      'dataType': 'html',
      'success': function(html) {
        clearAJAXFlash();
        comment_div.html(html);
      },
      'error': function(req) {
        insertAJAXFlash('error', req.responseText);
        spinner.remove();
        anchor.click(click);
      }
    });
  }
  anchor.click(click);
}

function edit_in_place(selector, class_name, attribute_name, url) {
  var model = $(selector); // could be many
  model.each(function(i) {
    var model_id = $(this).attr('id'); // issue_22
    var record_id = model_id.match(/_(\d+)$/)[1]; // 22
    var field_id = $('#' + model_id + '_' + attribute_name); // issue_22_summary
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
        $.ajax({
          'url': url + record_id,
          'type': 'post',
          'dataType': 'json',
          'data': '_method=put&' + class_name + '[' + attribute_name + ']=' +
            encodeURIComponent(value),
          'success': function(json) {
            field_id.text(json[class_name][attribute_name]);
            field_id.removeClass('ajax_error');
            clearAJAXFlash();
          },
          'error': function(req) {
            field_id.text(value);
            field_id.addClass('ajax_error');
            insertAJAXFlash('error', req.responseText);
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
  });
}

function ajax_check_box(selector, class_name, attribute_name, url) {
  var model_id = $(selector).attr('id'); // issue_22
  var record_id = model_id.match(/_(\d+)$/)[1]; // 22
  var field_id = $('#' + model_id + '_' + attribute_name); // issue_22_public
  var field_text = field_id.text(); // eg. true, false
  var spinner_id = 'spinner_' + global_spinner_counter++;
  var new_contents = '<input id="' + class_name + '_' + attribute_name +
    '" name="' + class_name + '[' + attribute_name + ']" type="checkbox">' +
    '<img alt="Spinner" id="' + spinner_id + '" class="spinner" src="/images/spinner.gif" />';
  field_id.html(new_contents);
  var check_box_id = field_id.find('input');
  if (field_text == 'true') {
    check_box_id.attr('checked', 'checked');
    }
  var old_attr = check_box_id.attr('checked');
  check_box_id.change(function() {
    var spinner = field_id.find('#' + spinner_id);
    spinner.show();
    $.ajax({
      'url': url + record_id,
      'type': 'post',
      'dataType': 'json',
      'data': '_method=put&' + class_name + '[' + attribute_name + ']=' +
        check_box_id.attr('checked'),
      'success': function(json) {
        old_attr = check_box_id.attr('checked');
        clearAJAXFlash();
      },
      'error': function(req) {
        check_box_id.attr('checked', old_attr);
        insertAJAXFlash('error', req.responseText);
      },
      'complete': function() {
        spinner.hide();
      }
    });
  });
}

function ajax_select(selector, class_name, attribute_name, options, include_blank, url) {
  var model_id = $(selector).attr('id'); // issue_22
  var record_id = model_id.match(/_(\d+)$/)[1]; // 22
  var field_id = $('#' + model_id + '_' + attribute_name); // issue_22_status
  var field_text = field_id.text(); // eg. New, Open, Closed
  var spinner_id = 'spinner_' + global_spinner_counter++;
  var new_contents = '<select id="' + class_name + '_' + attribute_name + '" name="' + class_name + '[' + attribute_name + ']">';
  if (include_blank) {
    new_contents = new_contents + '<option value=""></option>';
  }
  var selection_found = false;

  // helper function to reduce duplication below
  function option_tag(opt) {
    var tag = '';
    for (var i = 0; i < opt.length; i++) {
      if (field_text == opt[i][0]) {
        tag = tag + '<option value="' + opt[i][1] + '" selected="selected">' + opt[i][0] + '</option>';
        selection_found = true;
      } else {
        tag = tag + '<option value="' + opt[i][1] + '">' + opt[i][0] + '</option>';
      }
    }
    return tag;
  };

  if (options.length > 0 && options[0].length >= 2 && (options[0][1] instanceof Array))
  {
    // we have an array of arrays of arrays: this is the optgroup case
    for (var i = 0; i < options.length; i++) {
      new_contents = new_contents + '<optgroup label="' + options[i][0] + '">';
      new_contents = new_contents + option_tag(options[i][1]);
      new_contents = new_contents + '</optgroup>';
    }
  }
  else { // non-optgroup case
    new_contents = new_contents + option_tag(options);
  }
  new_contents = new_contents + '</select><img alt="Spinner" id="' + spinner_id + '" class= "spinner" src="/images/spinner.gif" />';
  field_id.html(new_contents);
  var select_id = field_id.find('select');
  if (!selection_found) {
    if (!include_blank) {
      alert('failed to find selection');
      return; // programmer error! bail
    } else {
      // if none of the options match, eg "no product", must be the "blank" option
      select_id.find('option:first').attr('selected', 'selected');
    }
  }
  var old_val = field_id.find('select option:selected').text();
  select_id.change(function() {
    var spinner = field_id.find('#' + spinner_id);
    spinner.show();
    $.ajax({
      'url': url + record_id,
      'type': 'post',
      'dataType': 'json',
      'data': '_method=put&' + class_name + '[' + attribute_name + ']=' +
        select_id.val(),
      'success': function(json) {
        old_val = field_id.find('select option:selected').text();
        clearAJAXFlash();
      },
      'error': function(req) {
        select_id.val(old_val);
        insertAJAXFlash('error', req.responseText);
      },
      'complete': function() {
        spinner.hide();
      }
    });
  });
}

function setup_preview_link(options) {
  $('#preview_link').append('<a href="#"><img src="/images/update.png" alt="refresh" /></a>' +
    '<img id="preview_spinner" src="/images/spinner.gif" alt="spinner" />');
  $('#preview_link a').click(function() {
    $('#preview_spinner').show();
    var data = [];
    var max = options['include'].length;
    for (var i = 0; i < max; i++) {
      var included = $('#' + options['kind'] + '_' +
        options['include'][i]).val();
      data.push(options['include'][i] +'=' + encodeURIComponent(included));
    }
    $.ajax({
      'url': options['url'],
      'type': 'post',
      'dataType': 'html',
      'data': data.join('&'),
      'success': function(html) {
        $('#preview').html(html);
        clearAJAXFlash();
      },
      'error': function(req) {
        insertAJAXFlash('error', req.responseText);
      },
      'complete': function() { $('#preview_spinner').hide(); }
    });
    return false;
  });
}

function observe_field(options) {
  // defaults
  var field = options['field'] ||
    $('#' + options['kind'] + '_' + options['fieldName']);
  var interval = (options['interval'] || 30) * 1000;
  var before = options['before'] || function() { $('#preview_spinner').show(); };
  var success = options['success'] || function(html) {
    $('#preview').html(html);
    clearAJAXFlash();
  };
  var error = options['error'] || function(req) {
    insertAJAXFlash('error', req.responseText);
  };
  var complete = options['complete'] || function() { $('#preview_spinner').hide(); };

  if (typeof window.observed_field_contents == 'undefined')
    window.observed_field_contents = {};
  window.observed_field_contents[field.attr('id')] = field.val();
  setInterval(function() {
    var new_content = field.val();
    var old_content =
      window.observed_field_contents[field.attr('id')];
    if (new_content != old_content) {
      before();
      var data = options['fieldName'] + '=' + encodeURIComponent(new_content);
      if (options['include']) {
        var max = options['include'].length;
        for (var i = 0; i < max; i++) {
          var included = $('#' + options['kind'] + '_' +
            options['include'][i]).val();
          data += '&' + options['include'][i] +'=' +
            encodeURIComponent(included);
        }
      }
      $.ajax({
        'url': options['url'],
        'type': 'post',
        'dataType': 'html',
        'data': data,
        'success': function(html) { success(html); },
        'error': function(req) { error(req); },
        'complete': function() {
          complete();
          // regardless of success/failure, only try to submit once
          window.observed_field_contents[field.attr('id')] = new_content;
        }
      });
    }
  }, interval);
}
