

class Room
  attr_reader :id, :type, :name, :clients

  def initialize(parms)
    @id      = parms[:id]
    @type    = :room
    @name    = parms[:name]
    @clients = []
  end

  def enter(client)
    broadcast(:msg, "#{client.name} has entered #{@name}")
    @clients << client
  end

  def leave(client)
    @clients.delete(client)
    broadcast(:msg, "#{client.name} has left #{@name}")
  end

  def broadcast(msgtype, msg)
    @clients.each { |client| client.send(msgtype, msg) }
  end

  def update
    puts "#{@name} is updating ..."
  end

end
