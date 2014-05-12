class DashboardController < ApplicationController
  require 'RMagick'
  before_filter :authenticate_user!

  def index
    if params[:gene]
      # search query
      @pathwayTable=PathwayMap.select_pathway_counts(params[:gene])
    else
      @pathwayTable=PathwayMap.pathway_counts
    end

    @ac=user_annotations.group_by(&:id)
    @enrich=Enrichment.where(originator_id: current_user.id).group_by(&:id)
    @counts=PathwayCount.where(:countable_id => [@ac.keys, @enrich.keys, 0].flatten).group_by(&:xref)

  end

  def pathway_map
    @pathwayMap = PathwayMap.get_my_map(params[:id])
    @image = PathwayImage.find_by_xref(@pathwayMap[0].xref)
  end

  def create_enrichment
      e=Enrichment.create(name: params[:name], annotation_collection_id: params[:annotation_collection_id], originator_id: current_user.id)
      Enrichment.calculate_enrichment_scores(e)
      redirect_to :root #, notice: 'Enrichment: '+e.name+' was successfully created.'
  end

  def destroy_enrichment
    e=Enrichment.find(params[:format])
    PathwayCount.where(:countable_type=> 'Enrichment', :countable_id => e.id).destroy_all
    e.destroy
    redirect_to :back
  end


  def options
  end

  def select_this_group
    current_user.update_attributes(:current_group_id => params[:current_group_id].first )
    current_user.save!

    redirect_to :back
  end

  def autocomplete_user_username
    @user = User.order(:username).where("username like ?", "#{params[:term]}%")
    render json: @user.map(&:username)
  end

  def download_tmp
    #raise params[:filename].inspect  tmp/filename
    send_file Rails.root.join(params[:filename])
  end

  def destroy_tmp
    File.delete(params[:filename])
    redirect_to :back
  end

  def create_icon
    newName = File.basename( params[:file].original_filename, ".*" )+'_'+current_user.id.to_s+File.extname(params[:file].original_filename)

    #raise  File.extname(params[:file].original_filename).inspect
    if File.extname(params[:file].original_filename) == '.gif'
      list = Magick::ImageList.new.from_blob(params[:file].read)
      list = list.coalesce
      list.each do |x|
        x.resize_to_fill!(25,25)
      end
    # Re-optimize the GIF frames
      list = list.optimize_layers( Magick::OptimizeLayer )
      File.open( Rails.root.join('app', 'assets', 'images', 'icons', newName ), 'wb') { |f| f.write list.to_blob }
    else
      image = Magick::Image.read(params[:file].tempfile.path).first
      image.change_geometry!("25x25") { |cols, rows, img|
        newimg = img.resize(cols, rows)
        newimg.write( Rails.root.join('app', 'assets', 'images', 'icons', newName ) )
      }
    end

    redirect_to :root, notice: 'Icon was successfully uploaded.'
  end

  def list_custom_icons
    if current_user.admin
      @icons = Dir.glob('app/assets/images/icons/*')
    else
      @icons = Dir.glob('app/assets/images/icons/*_'+current_user.id.to_s+'.*')
    end


  end

  def destroy_custom_icon
    File.delete(params[:fh])
    redirect_to :back, alert: 'Icon was removed.'
  end

  def adminView
    @users=User.all()
    @pathStats = PathwayMap.find_by_sql("SELECT source, COUNT(DISTINCT(xref)) AS cnt FROM pathway_maps GROUP BY source;")
  end
end
