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
        maxChunkSize: 10 * 1024 * 1024,
        recalculateProgress: false, // try to reduce unnecessary processing
        formData: function (form) {
            return form.serializeArray();
        }
    });

    var kiwixCheck = function() {
        $.ajax({method: 'GET', url: '/kiwix/'})
          .fail(function() {
            setTimeout(kiwixCheck, 100)
          })
          .done(function() {
            if ($('#kiwix-do-redirect').length) {
              window.location = '/kiwix/';
            } else {
              $('#kiwix-link').removeClass('hidden')
              $('#kiwix-waiting').addClass('hidden')
              $('#fileupload').addClass('hidden')
            }
          })
    }

    function setProgress(soFar, total) {
        var percentage
        var soFarMegs
        var totalMegs

        if (total === undefined || soFar === undefined) {
            soFarMegs = 0
            totalMegs = '?'
            percentage = '?'
        } else {
            soFarMegs = Math.round(soFar / (1024 ** 2) )
            totalMegs = Math.round(total / (1024 ** 2) )
            percentage = (100 * soFar / total).toPrecision(5)
        }

        $('#upload-progress-percentage').html(percentage)
        $('#upload-progress-sofarmegs').html(soFarMegs)
        $('#upload-progress-totalmegs').html(totalMegs)
    }
    function getResponseError(response) {
        var responseJSON
        if (response.jqXHR.responseJSON)
            responseJSON = response.jqXHR.responseJSON
        else {
            try{
                responseJSON = JSON.parse(response.jqXHR.responseText);
            }
            catch (error){
                return "Unkown Error: " + response.jqXHR.responseText;
            }
        }
        return responseJSON.files[0].error
    }

    var lastUploadedBytes
    var tries
    var MAX_TRIES = 10
    $('#fileupload')
        .bind('fileuploaddone', function (e, data) {
            $('#slide-done').removeClass('hidden')
            $('#slide-upload').addClass('hidden')
            $('#slide-intro').addClass('hidden')
            $('#slide-download').addClass('hidden')

            $('#upload-progress').hide()
            setTimeout(kiwixCheck, 1)
        })
        .bind('fileuploadadd', function (e, data) {
            $('#upload-progress .cancel').off('click')
            $('#upload-progress .cancel').on('click', function(e){e.preventDefault(); data.abort()})
            lastUploadedBytes = 0
            tries = MAX_TRIES
        })
        .bind('fileuploadsend', function (e, data) {
            $('#upload-error').hide()
            $('#upload-progress').show()
            setProgress()
            $('#upload-interface').addClass('hidden')
        })
        .bind('fileuploadfail', function (e, data) {
            $('#upload-progress').hide()
            if(data.response().textStatus != 'abort') {
                $('#upload-error').show()
                $('#upload-error-text').html(getResponseError(data.response()))

                data.uploadedBytes = lastUploadedBytes
                if (tries >= 1) {
                    setTimeout(data.submit.bind(data), 1000 * ((11 - tries) ** 2))
                    tries = tries - 1
                }
            }
            $('#upload-interface').removeClass('hidden')
            return
        })
        .bind('fileuploadchunkdone', function (e, data) {
            var file = JSON.parse(data.result).files[0]
            tries = MAX_TRIES
            lastUploadedBytes = file['size']
            setProgress(file['size'], file['total_size'])
        })

    if ($('#kiwix-do-redirect').length) {
      setTimeout(kiwixCheck, 1)
    }
});
