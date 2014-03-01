var el = {}
var feedbackQueue = []
var feedbackIndex = 0
var currentString = ""
var currentTags = []

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

  currentTags.push(statement)

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
  obj = {
    string: currentString,
    tags: currentTags
  }
  obj["class"] = $("#training_class")[0].value

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

function displayCurrentFeedback(){
  $("#feedback-count").text((feedbackIndex + 1) + " / " + feedbackQueue.length)
  $("#training_class")[0].value = ""
  $("#training_input")[0].value = ""

  if(feedbackQueue.length > 0){
    current = feedbackQueue[feedbackIndex]
    currentString = current.string
    $("#feedback-display-string").text(current.string)
    $("#training_class").value = current["class"]
    $("#training_input").text(current.string)
    $("#output").text("Labels:")

    $("#feedback-display-labels-content").text("")
    _.each(tagsString(current.tags), function(tagString) {
      $("#feedback-display-labels-content").append(tagString + "<br/>")
    })
  }
  else {
    $("#feedback-display-string").text("<Nothing in feedback queue>")
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

    getFeedbackQueue()

    availableTags = ["tag1", "tag2"]
    $( "#training_label" ).autocomplete({
      source: availableTags
    });
} )
