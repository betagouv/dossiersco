require 'net/http'

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

  def retour_ent
    puts "-" * 20
    puts "RETOUR CAS"
    puts params.inspect

    ticket = params[:ticket]


    url = "https://preprod-paris.opendigitaleducation.com/cas/serviceValidate?service=https%3A%2F%2Fdossiersco-demo.scalingo.io%2Fretour-ent&ticket=#{ticket}"

    puts url
    url = URI.parse(url)
    puts url
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port, use_ssl: true) {|http|
        http.request(req)
        puts "req: #{req}"
    }
    puts res
    puts "-" * 20


  end
end
