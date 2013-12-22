// Copyright 2009-2013 Wincent Colaiuta. All rights reserved.
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

function escapeHTML(html) {
  return html
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function insertAJAXFlash(cssClass, msg) {
  $('#ajax-flash')
    .append($('<div/>', { 'class': cssClass, html: escapeHTML(msg) }))
    .show();
}

function clearAJAXFlash() {
  $('#ajax-flash')
    .fadeOut('slow', function() { $(this).hide(); })
    .empty();
}

function ajaxCommentForm(url) {
  var commentSelector = '#comment-form',
      $commentDiv = $(commentSelector),
      $anchor = $commentDiv.find('a').attr('href', '#comment-form');
  var click = function() {
    $anchor.off('click').addClass('disabled');
    var spinner = new Wincent.Spinner(commentSelector, 'small');
    clearAJAXFlash();
    $.ajax({
      url       : url,
      type      : 'get',
      dataType  : 'html',
      success   : function(html) {
        clearAJAXFlash();
        $commentDiv.append(html).find('.links').hide();
      },
      error: function(req) {
        insertAJAXFlash('error', req.responseText);
        $anchor.on('click', click);
      },
      complete: function() {
        spinner.stop();
        $anchor.removeClass('disabled');
      }
    });
  }
  $anchor.on('click', click);
}

function editInPlace(selector, className, attributeName, url) {
  var model = $(selector); // could be many
  model.each(function(i) {
    var modelId = $(this).attr('id'), // issue_22
        recordId = modelId.match(/_(\d+)$/)[1], // 22
        $fieldId = $('#' + modelId + '_' + attributeName); // issue_22_summary
    function highlight() { $fieldId.addClass('highlight'); }
    function unhighlight() { $fieldId.removeClass('highlight'); }
    function clickFunction() {
      $fieldId.off('mousenter mouseleave'); // remove 'hover' handlers
      var fieldText = $fieldId.text();
      unhighlight();
      $fieldId.attr('title', 'Click outside to abort editing')
        .html('<form action="javascript:void(0)" style="display:inline;"><input type="text" value="' +
          escapeHTML(fieldText) +
          '"></form>')
        .find('input')[0].select();
      $fieldId.off('dblclick')
        .find('input').on('blur', function() {
          $fieldId.text(fieldText)
            .on('dblclick', clickFunction)
            .on('mouseenter', highlight)
            .on('mouseleave', unhighlight);
        }).end()
        .find('form').on('submit', function() {
          var value = $fieldId.find('input').val();
          $fieldId.text('saving...');
          $.ajax({
            'url': url + recordId,
            'type': 'post',
            'dataType': 'json',
            'data': '_method=put&' + className + '[' + attributeName + ']=' +
              encodeURIComponent(value),
            'success': function(json) {
              $fieldId.text(json[className][attributeName])
                .removeClass('ajax_error');
              clearAJAXFlash();
            },
            'error': function(req) {
              $fieldId.text(value).addClass('ajax_error');
              insertAJAXFlash('error', req.responseText);
            },
            'complete': function() {
              $fieldId
                .on('mousenter', highlight)
                .on('mouseleave', unhighlight)
                .on('dblclick', clickFunction);
            }
          });
        });
    }
    $fieldId.attr('title', 'Double-click to edit')
      .on('dblclick', clickFunction)
      .on('mouseenter', highlight)
      .on('mouseleave', unhighlight);
  });
}

(function() {
  var RETURN_KEY = 13,
      ESCAPE_KEY = 27;

  $(document)
    .on('dblclick', '[data-editable]', function(event) {
      $el = $(this).addClass('editing');
      $el.data('original-content', $el.html());
      $el[0].contentEditable = 'true';
      $el.focus();
    })
    .on('blur', '[data-editable]', function() {
      $el = $(this).removeClass('editing');
      $el[0].contentEditable = 'false';
    })
    .on('keydown', '[data-editable]', function(event) {
      if (event.keyCode === RETURN_KEY) {
        event.preventDefault();
        $el = $(this).blur();
        if ($el.html() !== $el.data('original-content')) {
          var $form   = $el.closest('form'),
              $method = $form.find('input[name=_method]'),
              spinner = new Wincent.Spinner($form, 'small'),
              $hidden = $('<input>', {
                type: 'hidden',
                name: $(this).data('name'),
                value: $el.text().trim()
              }).appendTo($form);

          $.ajax({
            url  : $form.attr('action'),
            type : 'post',
            data : $hidden.add($method).serialize(),
            dataType : 'json'
          })
            .done(function(json) {
              clearAJAXFlash();
            })
            .fail(function(req) {
              insertAJAXFlash('error', req.responseText);
            })
            .always(function() {
              spinner.stop();
              $hidden.remove();
            });
        }
      } else if (event.keyCode === ESCAPE_KEY) {
        $el = $(this).blur();
        $el.html($el.data('original-content'));
      }
    });

  $(document).on('change', 'input[data-ajax], select[data-ajax]', function(event) {
    var $element  = $(event.currentTarget),
        $form     = $element.closest('form'),
        $method   = $form.find('input[name=_method]'),
        data      = $element.add($method).serialize(),
        spinner   = new Wincent.Spinner($form, 'small');

    // must only disable after serializing
    $element.prop('disabled', true);

    $.ajax({
      url      : $form.attr('action'),
      type     : 'post',
      dataType : 'json',
      data     : data
    })
      .done(function(json) {
        clearAJAXFlash();

        if ($element.is('select')) {
          // make sure we can identify the selected option if a subsequent change
          // ends up triggering the `fail()` function (note the difference between
          // finding the currently selected element using `:selected` here the
          // previously selected element using `option[seleted]` below)
          $element.find(':selected')
            .attr('selected', 'selected')
            .siblings()
            .removeAttr('selected');
        }
      })
      .fail(function(req) {
        insertAJAXFlash('error', req.responseText);

        // revert element to initial state, if appropriate
        if ($element.is('input[type=checkbox]')) {
          $element.prop('checked', !$element.prop('checked'));
        } else if ($element.is('select')) {
          var previousSelection = $element.find('option[selected]').val();
          $element.val(previousSelection);
        }
      })
      .always(function() {
        spinner.stop();
        $element.prop('disabled', false);
      });
  });
})();

function setupPreviewLink(options) {
  $('<a href="#"><i class="icon-refresh"></i></a>')
    .appendTo('#preview_link')
    .on('click', function() {
      var spinner = new Wincent.Spinner('#preview_link', 'small');
      var data = [],
          max = options['include'].length;
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
          $('#preview').html(html).syntaxHighlight();
          clearAJAXFlash();
        },
        'error': function(req) {
          insertAJAXFlash('error', req.responseText);
        },
        'complete': function() { spinner.stop(); }
      });
      return false;
    });
}

function observeField(options) {
  // defaults
  var $field = options['field'] || $('#' + options['kind'] + '_' + options['fieldName']),
      interval = (options['interval'] || 30) * 1000,
      before = options['before'] || function() { $('#preview_spinner').show(); },
      success = options['success'] || function(html) {
        $('#preview').html(html).syntaxHighlight();
        clearAJAXFlash();
      },
      error = options['error'] || function(req) {
        insertAJAXFlash('error', req.responseText);
      },
      complete = options['complete'] || function() { $('#preview_spinner').hide(); };

  if (typeof window.observed_field_contents === 'undefined')
    window.observed_field_contents = {};
  window.observed_field_contents[$field.attr('id')] = $field.val();
  setInterval(function() {
    var new_content = $field.val(),
        old_content = window.observed_field_contents[$field.attr('id')];
    if (new_content !== old_content) {
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
        'success': success,
        'error': error,
        'complete': function() {
          complete();
          // regardless of success/failure, only try to submit once
          window.observed_field_contents[$field.attr('id')] = new_content;
        }
      });
    }
  }, interval);
}
