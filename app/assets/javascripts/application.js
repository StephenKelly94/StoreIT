// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-fileupload/basic

//= require turbolinks
//= require react
//= require react_ujs
//= require components
//= require bootstrap.min
//= require notify.min
//= require_tree .


// Taken from github for jquery file upload
// https://github.com/blueimp/jquery-file-upload/wiki/drop-zone-effects
$(document).bind('dragover', function (e)
{
    var dropZone = $('.dropzone'),
    foundDropzone;
    var found = false,
    node = e.target;
    do{
        if ($(node).hasClass('dropzone'))
        {
            found = true;
            foundDropzone = $(node);
            break;
        }
        node = node.parentNode;
    }while ((node != null) && dropZone.hasClass('hover'));
    dropZone.removeClass('hover');
    if (found)
    {
        foundDropzone.addClass('hover');
    }
});

$(document).bind('drop', function (e) {
    $('.dropzone').removeClass('hover');
});
