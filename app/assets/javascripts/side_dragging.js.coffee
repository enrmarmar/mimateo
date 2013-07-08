$(document).ready ->

  # Invite by dragging tasks
  $("#tasks li").draggable
    helper: 'clone'
  $("#tasks_box").droppable
    accept: '#tasks li'
    drop: (event, ui) ->
      element = $(ui.draggable).clone()
      element.find("i.icon-exclamation-sign").remove()
      element.find("i.icon-envelope").remove()
      element.find("i.icon-bell").remove()
      element.find("i.icon-warning-sign").remove()
      element.children("a").append("<i class='icon-question-sign'></i>")
      element.draggable
        helper: 'clone'
        start: ->
          $("#tasks_drop_box").show()
          $(this).hide()
        stop: ->
          $("#tasks_drop_box").hide()
          $(this).show()
      request = $.get "/task/" + ui.draggable.attr('id') + "/invite/" + $(".contact_id").attr('id')
      request.done ->
        $("#tasks_box").append element if request.getResponseHeader("X-Message-Type") is "notice"
  
  # Invite by dragging contacts
  $("#contacts li").draggable
    helper: 'clone'
  $("#contacts_box").droppable
    accept: '#contacts li'
    drop: (event, ui) ->
      request = $.get "/task/" + $(".task_id").attr('id') + "/invite/" + ui.draggable.attr('id')
      request.done ->
        element = $(ui.draggable).clone()
        element.find("i.icon-exclamation-sign").remove()
        element.find("i.icon-envelope").remove()
        element.children("a").append("<i class='icon-question-sign'></i>")
        element.draggable
          helper: 'clone'
          start: ->
            $("#contacts_drop_box").show()
            $(this).hide()
          stop: ->
            $("#contacts_drop_box").hide()
            $(this).show()
        $("#contacts_box").append element if request.getResponseHeader("X-Message-Type") is "notice"
  
  # Uninvite by dragging contacts
  $("#contacts_drop_box").hide()
  $("#contacts_box li").draggable
    helper: 'clone'
    start: ->
      $("#contacts_drop_box").show()
      $(this).hide()
    stop: ->
      $("#contacts_drop_box").hide()
      $(this).show()
  $("#contacts_drop_box").droppable
    accept: '#contacts_box li'
    drop: (event, ui) ->
      request = $.get "/task/" + $(".task_id").attr('id') + "/uninvite/" + ui.draggable.attr('id')
      request.done ->
        $("#contacts_box li#" + ui.draggable.attr('id')).remove() if request.getResponseHeader("X-Message-Type") is "notice"

  # Uninvite by dragging tasks
  $("#tasks_drop_box").hide()
  $("#tasks_box li").draggable
    helper: 'clone'
    start: ->
      $("#tasks_drop_box").show()
      $(this).hide()
    stop: ->
      $("#tasks_drop_box").hide()
      $(this).show()
  $("#tasks_drop_box").droppable
    accept: '#tasks_box li'
    drop: (event, ui) ->
      request = $.get "/task/" + ui.draggable.attr('id') + "/uninvite/" + $(".contact_id").attr('id')
      request.done ->
        $("#tasks_box li#" + ui.draggable.attr('id')).remove() if request.getResponseHeader("X-Message-Type") is "notice"

  # Give bones by dragging to contacts
  $("#bone").draggable
    helper: 'clone'
  $("#contacts_box li").droppable
    accept: '#bone'
    drop: (event, ui) ->
      request = $.get "/task/" + $(".task_id").attr('id') + "/give/" + "1" + "/bones_to/" + $(this).attr('id')
      current_bones = parseInt($("#bones_given").html())
      $("#bones_given").html(current_bones + 1)
      