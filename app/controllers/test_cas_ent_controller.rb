class TestCasEntController < ApplicationController

  def new
    render layout: false
  end

  def retour_cas
    puts "-" * 20
    puts "RETOUR CAS"
    puts params.inspect
    puts "-" * 20
  end

end
