class PathwaysController < ApplicationController

  # GET /pathways
  # GET /pathways.json
  def index
    @pathways = PathwayMap.custom_pathway_counts(current_user.id)
  end

  # GET /pathways/1
  # GET /pathways/1.json
  def show
  end

  def cytoscape_help
  end

  # GET /pathways/new
  def new
    @new_xref = Time.now.to_s(:number)
  end

  # GET /pathways/1/edit
  def edit
    @image = PathwayImage.find_by_xref(params[:xref])
    @map = PathwayMap.find_all_by_xref(params[:xref])
  end

  # POST /pathways
  # POST /pathways.json
  def create
    res = Pathway.xml_upload(params[:file], params[:name], params[:xref], current_user.id)
    if !res.blank?
      flash[:error] = res
      render action: 'new'
      return
    end

    #### GRAB the associated image.
    dim = Paperclip::Geometry.from_file(params[:image].tempfile)
    pi = PathwayImage.new( xref: params[:xref], img_height: dim.height, img_width: dim.width )
    pi.background = params[:image]
    pi.save!

    respond_to do |format|
      format.html { redirect_to({:action=>'edit', :xref=>params[:xref]}, notice: 'Pathway was successfully created.') }
    end

  end

  # PATCH/PUT /pathways/1
  # PATCH/PUT /pathways/1.json
  def update
    map = PathwayMap.find_all_by_xref(params[:xref])
    map.each_with_index do |e, i|
      loci=(i+1).to_s
      e.update_attributes(:x=>params[:x_pos][loci].to_i, :y=>params[:y_pos][loci].to_i)
      e.save!
      #raise [params[:x_pos], params[:x_pos][loci], params[:y_pos][loci],e].inspect
    end

    respond_to do |format|
        format.html { redirect_to({:action=>'index'}, notice: 'Pathway positions were successfully updated.') }
        format.json { head :no_content }
    end
  end

  # DELETE /pathways/1
  # DELETE /pathways/1.json
  def destroy
    PathwayImage.find_by_xref(params[:xref]).destroy rescue nil
    PathwayMap.destroy_all(:xref => params[:xref])
    PathwayCount.destroy_all(:xref => params[:xref])
    respond_to do |format|
      format.html { redirect_to :action => 'index', alert: 'Pathway was removed.' }
      format.json { head :no_content }
    end
  end


end
