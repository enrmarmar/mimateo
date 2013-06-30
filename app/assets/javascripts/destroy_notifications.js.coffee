$(document).ready ->
  $(".notification .close").click ->
    request = $.get "/notifications/" + $(this).attr('id') + "/destroy"
  $("#complete-task").click ->
    request = $.get "/task/" + $(".task_id").attr('id') + "/complete"
    request.done ->
      $("#task_status").replaceWith("Tarea completada") if request.getResponseHeader("X-Message-Type") is "notice"