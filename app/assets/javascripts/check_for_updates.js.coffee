$(document).ready ->
	check_for_updates = ->
	  request = $.get "/check_for_updates/" + $(".logo").attr('id')
	  request.done ->
	    document.location.reload(true) if request.getResponseHeader("Reload") == "true"
	interval = setInterval(check_for_updates, 5000)
	
	# TODO: Fix this, doesn't work
	$("input").focus = ->
		clearInterval(interval)
	$("input").blur = ->
		interval = setInterval(check_for_updates, 5000)