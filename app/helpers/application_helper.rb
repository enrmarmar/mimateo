module ApplicationHelper
  def button_close (args = {})
    render :partial => "/shared/button_close", :locals => {:id => args[:id]}
  end

  def shortener word
    if word.length < 20
      word
    else
      word.slice(0,19) +'...'
    end
  end
end
