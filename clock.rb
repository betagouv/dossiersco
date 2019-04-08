require 'clockwork'
require 'active_support/time' # Allow numeric durations (eg: 1.minutes)

module Clockwork
  handler do |job|
    puts "Running #{job}"
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end


  if ENV['RAILS_ENV'] == 'demo'
    every(5.minutes, 'reload demo db') do
      puts 'reload demo data'
      `rails db:drop db:schema:load db:seed:demo`
      puts 'end of data reloading'
    end
  end
  #every(10.seconds, 'frequent.job')
  #every(3.minutes, 'less.frequent.job')
  #every(1.hour, 'hourly.job')

  #every(1.day, 'midnight.job', :at => '00:00')
end

