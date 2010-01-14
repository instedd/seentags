# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def js(name, js_function)    
    "<a href=\"javascript:void(0)\" onclick=\"#{js_function}\">#{name}</a>"  
  end 
end
