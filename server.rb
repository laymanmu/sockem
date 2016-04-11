#!/usr/bin/env ruby
require_relative 'sockem'

host  = '0.0.0.0'
port  = '8080'

seconds_between_ticks = 5

db     = Database.instance
lobby  = db.create(:room, {:name=>"The Lobby"})
office = db.create(:room, {:name=>"The Office"})

EM.run {
  puts "listening to: #{host}:#{port}"

  EM::WebSocket.run(:host=>host, :port=>port, :debug=>false) do |ws|
    db.create(:client, {:ws=>ws, :room=>lobby})
  end

  EM::PeriodicTimer.new(seconds_between_ticks) do
    puts "#{Time.now.strftime('%H:%M:%S')} tick..."

    db.all(:client).each do |client|
      client.update
    end
    db.all(:room).each do |room|
      room.update
    end
  end
}
