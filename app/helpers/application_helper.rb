module ApplicationHelper

  def javascript_exists?(script)
    script = "#{Rails.root}/app/assets/javascripts/#{params[:controller]}.js"
    File.exists?(script)
  end

  def htmlRowFromArray(arr, hd)
    if hd
      return '<tr><th>'+arr.join('</th><th>')+'</th></tr>'
    else
      return '<tr><td>'+arr.join('</td><td>')+'</td></tr>'
    end
  end
end
