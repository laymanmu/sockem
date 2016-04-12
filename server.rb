#!/usr/bin/env ruby
require_relative 'sockem'

host  = '127.0.0.1'
port  = '8080'

seconds_between_ticks = 5

db     = Database.instance
lobby  = db.create(:room, {:name=>"The Lobby",  :desc=>'A small lobby with a couch'})
office = db.create(:room, {:name=>"The Office", :desc=>'A small office with a desk'})
lobby.add_exit(:north, office)
office.add_exit(:south, lobby)

EM.run {
  puts "listening to: #{host}:#{port}"

  EM::WebSocket.run(:host=>host, :port=>port, :debug=>false) do |ws|
    client = db.create(:client, {:ws=>ws, :room=>lobby})
    actor  = Actor.new(client)
  end

  EM::PeriodicTimer.new(seconds_between_ticks) do
    puts "  tick"
    db.all(:client).each do |client|
      client.update
    end
    db.all(:room).each do |room|
      room.update
    end
    $stdout.flush
  end
}
