function label(){
  string = $("#label_input")[0].value
  $.ajax({
    type: "POST",
    url: "/label",
    data: { data: string }
  })
  .done(function( msg ) {
    $("#label_output").text(JSON.stringify(msg))
  });
}
