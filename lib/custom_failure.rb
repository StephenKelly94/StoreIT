class CustomFailure < Devise::FailureApp
  def redirect_url
    root_path
  end

  def respond
    if http_auth?
      http_auth
    else
      flash[:notice] = I18n.t(:unauthenticated, :scope => [:devise, :failure])
      redirect
    end
  end

end
