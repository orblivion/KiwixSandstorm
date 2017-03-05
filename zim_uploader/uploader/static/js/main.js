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
    })

    // Initialize the jQuery File Upload widget:
    $('#fileupload').fileupload({
        // Uncomment the following to send cross-domain cookies:
        //xhrFields: {withCredentials: true},
        url: 'upload',
        maxChunkSize: 5 * 1024 * 1024,
        formData: function (form) {
            return form.serializeArray();
        }
    });

    // Enable iframe cross-domain access via redirect option:
    $('#fileupload').fileupload(
        'option',
        'redirect',
        window.location.href.replace(
            /\/[^\/]*$/,
            '/cors/result.html?%s'
        )
    );

    $('#fileupload').fileupload(
        'option', 'autoUpload', true
    );

    // Load existing files:
    $('#fileupload').addClass('fileupload-processing');
    $.ajax({
        // Uncomment the following to send cross-domain cookies:
        //xhrFields: {withCredentials: true},
        url: $('#fileupload').fileupload('option', 'url'),
        dataType: 'json',
        context: $('#fileupload')[0]
    }).always(function () {
        $(this).removeClass('fileupload-processing');
    }).done(function (result) {
        $(this).fileupload('option', 'done')
            .call(this, $.Event('done'), {result: result});
    });

});
