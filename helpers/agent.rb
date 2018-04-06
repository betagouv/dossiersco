helpers do
  def agent
    Agent.find_by(identifiant: session[:identifiant])
  end
end