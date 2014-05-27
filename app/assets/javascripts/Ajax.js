'use strict';

var $ = require('jquery');
var Keys = require('./Keys');

var escapeHTML = require('./escapeHTML');

var Ajax = {
  init: function() {
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
        if (event.keyCode === Keys.RETURN) {
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
                Ajax.clearFlash();
              })
              .fail(function(req) {
                Ajax.insertFlash('error', req.responseText);
              })
              .always(function() {
                spinner.stop();
                $hidden.remove();
              });
          }
        } else if (event.keyCode === Keys.ESCAPE) {
          $el = $(this).blur();
          $el.html($el.data('original-content'));
        }
      });

    $(document).on('change', 'input[data-ajax], select[data-ajax]', function(event) {
      var $element   = $(event.currentTarget),
          serialized = $element.serialize(),
          $form      = $element.closest('form'),
          $method    = $form.find('input[name=_method]'),
          spinner    = new Wincent.Spinner($form, 'small');

      // special-case handling for checkboxes (which the browser won't serialize
      // if unchecked)
      if (serialized) {
        serialized = $element.add($method).serialize();
      } else {
        // likely an unchecked checkbox; Rails provides us with a hidden sibling
        // in this case
        var hidden  = 'input[type=hidden][name="' + $element.attr('name') + '"]',
            $hidden = $element.siblings(hidden);

        serialized = $hidden.add($method).serialize();
      }

      // must only disable after serializing
      $element.prop('disabled', true);

      $.ajax({
        url      : $form.attr('action'),
        type     : 'post',
        dataType : 'json',
        data     : serialized
      })
        .done(function(json) {
          Ajax.clearFlash();

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
          Ajax.insertFlash('error', req.responseText);

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
  },

  insertFlash: function(cssClass, msg) {
    $('#ajax-flash')
      .append($('<div/>', { 'class': cssClass, html: escapeHTML(msg) }))
      .show();
  },

  clearFlash: function() {
    $('#ajax-flash')
      .fadeOut('slow', function() { $(this).hide(); })
      .empty();
  },

  commentForm: function(url) {
    var commentSelector = '#comment-form',
        $commentDiv = $(commentSelector),
        $anchor = $commentDiv.find('a').attr('href', '#comment-form');
    var click = function() {
      $anchor.off('click').addClass('disabled');
      var spinner = new Wincent.Spinner(commentSelector, 'small');
      Ajax.clearFlash();
      $.ajax({
        url       : url,
        type      : 'get',
        dataType  : 'html',
        success   : function(html) {
          Ajax.clearFlash();
          $commentDiv.append(html).find('.links').hide();
        },
        error: function(req) {
          Ajax.insertFlash('error', req.responseText);
          $anchor.on('click', click);
        },
        complete: function() {
          spinner.stop();
          $anchor.removeClass('disabled');
        }
      });
    }
    $anchor.on('click', click);
  },

  setupPreviewLink: function(options) {
    $('<a href="#"><i class="fa fa-refresh"></i></a>')
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
            Ajax.clearFlash();
          },
          'error': function(req) {
            Ajax.insertFlash('error', req.responseText);
          },
          'complete': function() { spinner.stop(); }
        });
        return false;
      });
  },

  observeField: function(options) {
    // defaults
    var $field = options['field'] || $('#' + options['kind'] + '_' + options['fieldName']),
        interval = (options['interval'] || 30) * 1000,
        before = options['before'] || function() { $('#preview_spinner').show(); },
        success = options['success'] || function(html) {
          $('#preview').html(html).syntaxHighlight();
          Ajax.clearFlash();
        },
        error = options['error'] || function(req) {
          Ajax.insertFlash('error', req.responseText);
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
};

module.exports = Ajax;
