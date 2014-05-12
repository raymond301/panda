module DashboardHelper

  def index_header
    arrows='<div style="width:14px;float:right;">'+image_tag("arrow_up_down.png")+'</div>'
    html='<thead><tr><th>Pathway Name'+arrows+'</th><th>Source'+arrows+'</th>'
#raise @counts.first[1].inspect
    if !@counts.blank?
      @counts.first[1].each do |c|
        if c.countable_type == 'Gene'
          html+='<th>Gene'+arrows+'</th>'
        elsif c.countable_type == 'AnnotationCollection' && !@ac[c.countable_id].nil?
          html+='<th>'+image_tag(@ac[c.countable_id][0].icon(:tiny))+'&nbsp;'+@ac[c.countable_id][0].name+arrows+'</th>'  rescue '<th>*</th>'
        elsif c.countable_type == 'Enrichment' && !@enrich[c.countable_id].nil?
          html+='<th>'+image_tag(@ac[@enrich[c.countable_id][0].annotation_collection_id][0].icon(:tiny), :style=>'border: 2px solid blue;')+'&nbsp;'+@enrich[c.countable_id][0].name+arrows+'</th>' rescue '<th>*</th>'
#          html+='<th>'+image_tag(@ac[c.countable_id][0].icon(:tiny), :style=>'border: 2px solid blue;')+'&nbsp;'+@enrich[c.countable_id][0].name+arrows+'</th>' #rescue '<th>*</th>'
        else
          html+='<th></th>'
        end
      end
    end
    html+='</tr></thead>'
    return html
  end


  def ac_by_id
    return Hash[*user_annotations.map { |x| [x.id, image_path(x.icon.url())] }.flatten].to_json
  end

end
