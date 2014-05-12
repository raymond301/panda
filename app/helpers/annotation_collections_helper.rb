module AnnotationCollectionsHelper


  def imagePickerSelect(list)
    #raise image_path(list[0]).inspect
    selectHTML='<select name="icon" class="image-picker show-html"><option value=""></option>'
    list.map{|e|
      absPath="#{request.protocol}#{request.host_with_port}#{asset_path(e)}"
      selectHTML+='<option data-img-src="'+absPath+'" value="'+e+'">'+
          e.split("/")[-1].camelcase+
          '</option>'
    }
    selectHTML+='</select>'
    return  selectHTML

  end

end
