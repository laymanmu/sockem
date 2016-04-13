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

def log(msg)
  Controller.instance.log(msg, :server)
end

EM.run {
  log("listening to: #{host}:#{port}")

  EM::WebSocket.run(:host=>host, :port=>port, :debug=>false) do |ws|
    db.create(:actor, {:ws=>ws, :room=>lobby})
  end

  EM::PeriodicTimer.new(seconds_between_ticks) do
    db.all(:actor).each do |actor|
      log("updating: #{actor.name}")
      actor.update
    end
  end

  EM::PeriodicTimer.new(1) do
    $stdout.flush
  end
}
