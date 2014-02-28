var el = {}
var selected = []
function addTraining(){
  start = el.selectionStart
  end = el.selectionEnd
  str = el.value.substring(start, end)
  label = $("#training_label")[0].value

  statement = {
    start: start,
    end: end,
    string: str,
    tag: label
  }

  selected.push(statement)

  $("#output").append("(" + start + ", " + end + ") " + str + " - " + label + "<br>")
}

function updateSelected(){
  el = $("#training_input")[0]
  start = el.selectionStart
  end = el.selectionEnd
  str = el.value.substring(start, end)
  $("#selected").text("Selected: " + str)
}

function submitTraining(){
  // stringify selected and post to add_sequence route
}

function getFeedbackQueue(){
  
}

$(document).ready( function(){
    $("#training_input").blur(function() {
      updateSelected()
    })

    // load training queue from server
} )
