require 'net/http'

URL_CAS = 'https://ent.parisclassenumerique.fr/cas'
if Rails.env.production?
  URL_RETOUR = CGI.escape('https://dossiersco.scalingo.io/retour-ent')
else
  URL_RETOUR = CGI.escape('https://dossiersco-demo.scalingo.io/retour-ent')
end


class AuthentificationCasEntController < ApplicationController

  def new
    render layout: false
  end

  def retour_cas
    puts "-" * 20
    puts "RETOUR CAS"
    puts params.inspect

    ticket = params[:ticket]


    url = "#{URL_CAS}/serviceValidate?service=#{URL_RETOUR}&ticket=#{ticket}"

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

  def appel_direct_ent
    puts "-" * 20
    puts "from ENT"
    puts "-" * 20
    redirect_to "#{URL_CAS}/login?service=#{URL_RETOUR}"
  end
end
