module ApplicationHelper
  def button_close (args = {})
    render :partial => "/shared/button_close", :locals => {:id => args[:id]}
  end

  def shortener email
    if email.length < 20
      email
    else
      email.slice(0,19) +'...'
    end
  end
end
