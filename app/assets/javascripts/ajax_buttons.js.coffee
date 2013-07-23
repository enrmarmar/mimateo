$(document).ready ->
  $(".notification .close").click ->
    request = $.get "/notifications/" + $(this).attr('id') + "/destroy"
    request.done ->
      document.location.reload(true) if request.getResponseHeader("Reload") == "true"
  $("#complete-task").click ->
    request = $.get "/task/" + $(".task_id").attr('id') + "/complete"
    request.done ->
      $("#task_status").replaceWith("Tarea completada") if request.getResponseHeader("X-Message-Type") is "notice"
  $("#postpone-task").click ->
    request = $.get "/task/" + $(".task_id").attr('id') + "/postpone"
    request.done ->
      tomorrow = new Date() + 1
      $("#task_status").html("Pendiente para: mañana " + "<button id='complete-task' class='btn btn-mini' data-toggle='tooltip-complete-task' title='Marcar tarea como completada'><i class='icon-ok'></i></button>")
