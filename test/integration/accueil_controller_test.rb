require 'test_helper'

class AccueilControllerTest < ActionDispatch::IntegrationTest

  def test_accueil
    get '/'
    assert response.parsed_body.include? 'Inscription'
  end

end
