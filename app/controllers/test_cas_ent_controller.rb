require 'net/http'

class TestCasEntController < ApplicationController

  def new
    render layout: false
  end

  def retour_ent
    puts "-" * 20
    puts "RETOUR ENT"
    puts params.inspect

    ticket = params[:ticket]


    url = "https://preprod-paris.opendigitaleducation.com/cas/serviceValidate?service=https%3A%2F%2Fdossiersco-demo.scalingo.io%2Fretour-ent&ticket=#{ticket}"

    puts url
    url = URI.parse(url)
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
        http.request(req)
    }
    puts res.body
    puts "-" * 20

    render plain: "OK ENT : #{res.body}"
  end

  def from_ent
    puts "-" * 20
    puts "from ENT"
    puts "-" * 20
    redirect_to 'https://preprod-paris.opendigitaleducation.com/cas/login?service=https%3A%2F%2Fdossiersco-demo.scalingo.io%2Fretour-ent'
  end
end
