$(document).ajaxComplete (event, request) ->
  msg = request.getResponseHeader("X-Message")
  alert_type = ''
  alert_type = 'alert-error' unless request.getResponseHeader("X-Message-Type").indexOf("warning") is -1
  alert_type = 'alert-error' unless request.getResponseHeader("X-Message-Type").indexOf("error") is -1
  $("#flash_hook").replaceWith("
    <div id='flash_hook'>
      <div class='alert " + alert_type + "'>
        <button type='button' class='close' data-dismiss='alert'>&times;</button>
        " + msg + "
      </div>
    </div>"
  ) if msg
  $("#flash_hook").replaceWith("<div id='flash_hook'></div>") unless msg