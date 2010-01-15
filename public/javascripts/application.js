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

function correct_report(id) {
    var content = $("#report-" + id + " .understood");
    if (content.hasClass("correcting"))
      return;
      
    understood[id] = content.text();
    
    content.addClass("correcting");    
    content.contents().replaceWith(
      '<input onkeydown="if (event.keyCode == 13) { save_correction(' + id + '); }"  type="text" value="' + content.text().replace('"', '&quot;') + '" style="width:440px"/> ' + 
      '<button onclick="save_correction(' + id + ')">Correct</button> ' + 
      '<button onclick="cancel_correction(' + id + ')">Cancel</button>');
}

function save_correction(id) {
  var text = $("#report-" + id + " .understood input").val();
  
  $.post('/report/' + id + '/correct',
    {text: text},
    function(data) {
      window.location = location;
    });
}

function cancel_correction(id) {
    var content = $("#report-" + id + " .understood");
    content.text(understood[id]);
    content.removeClass("correcting");
}