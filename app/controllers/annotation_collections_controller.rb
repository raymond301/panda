class AnnotationCollectionsController < ApplicationController
  before_action :set_annotation_collection, only: [:show, :edit, :update, :destroy]
  require 'tempfile'

  # GET /annotation_collections
  # GET /annotation_collections.json
  def index
    @annotation_collections = AnnotationCollection.all
  end

  # GET /annotation_collections/1
  # GET /annotation_collections/1.json
  def show
  end

  # GET /annotation_collections/new
  def new
    #@annotation_collection = AnnotationCollection.new
  end

  # GET /annotation_collections/new
  def new_w_file
    if params[:file].blank?
      flash[:error] = 'No File Specified!'
      render action: 'new'
    else

      @tmp = Rails.root.join('tmp', params[:file].original_filename)
      FileUtils.mv params[:file].tempfile.path, @tmp

      @header, @previewLines = AnnotationCollection.preview(@tmp)
      @short_name = File.basename( @tmp, ".*" ).gsub(/[\s+]/, '_')

        if @header.empty?
          flash[:error] = 'Missing Header (1st line must start with "#") in File'
           render action: 'new'

      end

      @availableIcons = Dir.glob('app/assets/images/icons/*').map{ |i| i.sub!('app/assets/images/','')}
    end

  end

  # GET /annotation_collections/1/edit
  def edit
  end

  # POST /annotation_collections
  # POST /annotation_collections.json
  def create
    @annotation_collection = AnnotationCollection.new(name: params['feature_name'], originator_id: current_user.id)
    @annotation_collection.icon = File.open(Rails.root.join('app', 'assets', 'images', params['icon']), 'r')

    respond_to do |format|
      if @annotation_collection.save
        tmpFile = @annotation_collection.load_from_file(params['tmpFile'])
        @annotation_collection.set_pathway_counts

        ## enable each new annotation right away.
        cookies["annotation_ids_#{@annotation_collection.id}"] = "true"
        if(!tmpFile.nil?)
          badFileLink = view_context.link_to('Unmapped Annotation File', :controller => 'dashboard', :action => 'download_tmp', :filename => tmpFile).to_s
          format.html { redirect_to :root, notice: 'Annotation was successfully assigned. However some rows did not contain recognized Gene Symbols, the complete list is available Here: '+badFileLink }
        else
          format.html { redirect_to :root }
        end
        format.json { render action: 'show', status: :created, location: @annotation_collection }
      else
        format.html { render action: 'index' }
        format.json { render json: @annotation_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /annotation_collections/1
  # PATCH/PUT /annotation_collections/1.json
  def update
    respond_to do |format|
      if @annotation_collection.update(annotation_collection_params)
        format.html { redirect_to @annotation_collection, notice: 'Annotation collection was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @annotation_collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /annotation_collections/1
  # DELETE /annotation_collections/1.json
  def destroy
    PathwayMap.where(:annotation_collection_id => @annotation_collection.id).destroy_all
    PathwayCount.where(:countable_type=> 'AnnotationCollection', :countable_id => @annotation_collection.id).destroy_all
    @annotation_collection.destroy

    respond_to do |format|
      format.html { redirect_to :root }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_annotation_collection
      @annotation_collection = AnnotationCollection.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def annotation_collection_params
      params[:annotation_collection]
    end
end
