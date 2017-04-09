/*
 * jQuery File Upload Plugin JS Example 8.9.1
 * (Edited for Kiwix-Sandstorm)
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2010, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/* global $, window */

$(function () {
    'use strict';

    // Hack jquery-file-uplodaer to send Content Range over POST
    // This is because as of this writing, Sandstorm.io does not support range headers
    $.widget('blueimp.fileupload', $.blueimp.fileupload, {
        _getFormData: function (options) {
            var formData = this._super(options)
            formData.push({name: 'contentRange', value: options.contentRange})
            return formData
        },
    });

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
        // Uncomment the following to send cross-domain cookies:
        //xhrFields: {withCredentials: true},
        autoUpload: true,
        url: 'upload',
        maxChunkSize: 5 * 1024 * 1024,
        formData: function (form) {
            return form.serializeArray();
        }
    });

    var kiwixCheck = function() {
        $.ajax({method: 'GET', url: '/kiwix/'})
          .fail(function() {
            console.log("not yet")
            setTimeout(kiwixCheck, 100)
          })
          .done(function() {
            console.log("okay done")
            if ($('#kiwix-do-redirect').length) {
              window.location = '/kiwix/';
            } else {
              $('#kiwix-link').removeClass('hidden')
              $('#kiwix-waiting').addClass('hidden')
              $('#fileupload').addClass('hidden')
            }
          })
    }

    $('#fileupload').bind('fileuploaddone', function (e, data) {
      $('#kiwix-waiting').removeClass('hidden')
      setTimeout(kiwixCheck, 1)
    })
    if ($('#kiwix-do-redirect').length) {
      setTimeout(kiwixCheck, 1)
    }
});
