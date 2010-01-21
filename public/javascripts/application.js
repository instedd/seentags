function toggle(id) {
  var elem = $('#' + id);
  elem.toggle('fast');
}

function delete_report_set(id, name) {
  if (confirm('Are you sure you want to delete the Report Set ' + name + '?')) {
    window.location = '/report_set/' + id + '/delete';
  }
}

var understood = {};
var current_report = 0;
var just_cancelled = 0;

$(function() {
  $('.understood').click(function() {
    var id = $(this).parent('tr').attr('id');
    id = id.substr(7);
    
    // If the user clicked 'cancel' we receive this event
    // but we don't want to start editing again
    if (id == just_cancelled) {
      just_cancelled = 0;
      return;
    }
    correct_report(id);
  });
});

function correct_report(id) {
    var content = $("#report-" + id + " .understood span");
    if (content.hasClass("correcting"))
      return;
      
    if (current_report) {
      cancel_correction(current_report);
      current_report = 0;
    }
      
    var text = $.trim(content.text());
      
    understood[id] = text;
    
    content.addClass("correcting");
    content.contents().replaceWith(
      '<input type="text" value="' + text.replace('"', '&quot;') + '" style="width:440px"/> ' + 
      '<button onclick="save_correction(' + id + ')">Correct</button> ' + 
      '<button onclick="cancel_correction(' + id + ')">Cancel</button>');
    
    var input = content.contents('input');
    input.focus();
    input.keydown(function(event) { 
      autocomplete_report(input, id, event);
    });
    
    current_report = id;
}

function save_correction(id) {
  var text = $("#report-" + id + " .understood input").val();
  
  $.post('/report/' + id + '/correct',
    {text: text},
    function(data) {
      window.location = location;
    });
    
  current_report = 0;
}

function cancel_correction(id) {
  var content = $("#report-" + id + " .understood span");
  content.text(understood[id]);
  content.removeClass("correcting");
  
  just_cancelled = id;
  current_report = 0;
  return false;
}

function autocomplete_report(input, id, event) {
  switch(event.keyCode) {
    case 13:
      save_correction(id);
      break;
    case 27:
      cancel_correction(id);
      break;
  }
}