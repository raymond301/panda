module GroupsHelper

    def memberList
      ### Add multiple column feature for lists that get very large!
      html='<ul>'
      @group.all_usernames.each_with_index do |u,i|
        html += "<li>#{u}</li>"
      end
      return html +='</ul>'
    end

    def annotationList
      html='<ul>'
      @group.annotation_collections.each_with_index do |a,i|
        html += "<li>#{a.name}&nbsp#{image_tag(a.icon(:tiny))}</li>"
      end
      return html +='</ul>'
    end

end
