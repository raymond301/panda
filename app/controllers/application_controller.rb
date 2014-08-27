class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?

  autocomplete :user, :username

  helper_method :user_annotations, :user_enrichments, :user_group, :user_bad_gene_files, :flash_class, :is_stand_alone

  def user_annotations
    current_user.my_annotations_or_group_annotaitons
  end

  def user_enrichments
    Enrichment.where(originator_id: current_user.id)
  end

  def user_group
    if current_user.current_group_id == 0
        return nil
    else
      Group.find(current_user.current_group_id) rescue nil
    end
  end

  #def user_bad_gene_files
  #  Dir.glob('tmp/*_'+current_user.id.to_s+'.txt') #.map{|f| File.basename( f, ".*") }
  #end

  def flash_class(level)
    #raise level.inspect
    case level
      when :notice then "alert-success"
      when :error then "alert-danger"
      when :alert then "alert-warning"
    end
  end

  def is_stand_alone
    if User.all().size.to_i > 2
      return false
    else
      return true
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit :username, :email, :password, :password_confirmation
    end
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :password, :remember_me) }
  end

end
