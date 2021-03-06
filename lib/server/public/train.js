var el = {}
var feedbackQueue = []
var feedbackIndex = 0
var currentString = ""
var currentTags = []
var selStart = null
var selEnd = null

function addTraining(){
  start = selStart
  end = selEnd
  str = $("#training_input").val().substring(start, end)
  label = $("#training_label").val()
  $("#training_label").val("")

  // ruby .. operator is inclusive, substring is not
  statement = {
    start: start,
    end: end - 1,
    string: str,
    tag: label
  }

  currentTags.push(statement)
  updateLabelList()
}

function updateLabelList(){
  $("#output").text("")
  _.each(currentTags, function(tag, i){
    $("#output").append("<li>" +
                        '<button onclick="removeTag(' + i + ')">x</button>  '  +
                        "(" + tag.start + ", " + (tag.end) + "): " +
                        tag.string + " - " + tag.tag +
                        "</li>")
  })
}

function removeTag(num){
  currentTags.splice(parseInt(num), 1)
  updateLabelList()
}

function updateSelected(){
  el = $("#training_input")
  selStart = el[0].selectionStart
  selEnd = el[0].selectionEnd
  str = el.val().substring(selStart, selEnd)
  $("#selected").text("Selected: " + str)
}

function submitTraining(){
  obj = {
    string: currentString,
    tags: currentTags
  }
  obj["class"] = $("#training_class").val()

  $.post("/add_sequence", obj, function(){
    feedbackQueue.splice(feedbackIndex, 1)
    currentTags = []
    displayCurrentFeedback()
    updateServerFeedbackQueue()
  })
}

function tagsString(tags){
  return _.map(tags, function(tag) {
    return "(" + tag.start + ", " + tag.end + "): " + tag.string + " - " + tag.tag
  })
}

function clearFields(){
  $("#training_input").val("")
  $("#training_class").val("")
  $("#training_label").val("")
}

function clearOutput(){
  $("#output").text("")
}

function displayCurrentFeedback(){
  var displayIndex = Math.min(feedbackIndex + 1, feedbackQueue.length)
  $("#feedback-count").text(displayIndex + " / " + feedbackQueue.length)
  clearFields()
  clearOutput()

  if(feedbackQueue.length > 0){
    current = feedbackQueue[feedbackIndex]
    currentString = current.string
    $("#training_class").val(current["class"])
    $("#training_input").val(current.string)

    _.each(current.tags, function(tag){
      currentTags.push(tag)
    })
    updateLabelList()
  }
}

function updateServerFeedbackQueue(){
  obj = {
    data: feedbackQueue
  }
  $.post("/update_feedback_queue", obj)
}

function nextFeedback(){
  if(feedbackIndex < feedbackQueue.length - 1) {
    feedbackIndex ++
  }
  else {
    feedbackIndex = feedbackQueue.length - 1
  }

  displayCurrentFeedback()
}

function prevFeedback(){
  if(feedbackIndex > 0) {
    feedbackIndex --
  }
  else {
    feedbackIndex == 0
  }

  displayCurrentFeedback()
}

function skipFeedback(){
  feedbackQueue.splice(feedbackIndex, 1)
  displayCurrentFeedback()
  updateServerFeedbackQueue()
}

function confirmFeedback(){
  current = feedbackQueue[feedbackIndex]
  currentString = current.string
  currentTags = current.tags
  submitTraining()
}

function getFeedbackQueue(){
  $.get("/feedback_queue", function(data){
    feedbackQueue = data
    feedbackIndex = 0
    displayCurrentFeedback();
  })
}

$(document).ready( function(){
    $("#training_input").blur(function() {
      updateSelected()
    })


    $.get('/list_tags', function(data){
      $( "#training_label" ).autocomplete({
        source: data
      });
    })

    $.get('/list_classes', function(data){
      $( "#training_class" ).autocomplete({
        source: data
      });
    })

    getFeedbackQueue()
} )
