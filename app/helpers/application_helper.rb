module ApplicationHelper
  def js(name, js_function)
    "<a href=\"javascript:void(0)\" onclick=\"#{js_function}\">#{name}</a>".html_safe
  end
end
