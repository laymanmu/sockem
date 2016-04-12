

class Room
  attr_reader :id, :type, :name, :clients, :desc, :exits

  def initialize(parms)
    @id      = parms[:id]
    @type    = :room
    @name    = parms[:name]
    @desc    = parms[:desc]
    @clients = []
    @exits   = {}
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
  end

  def client_names
    @clients.collect { |client| client.name }
  end

  def exit_names
    @exits.keys.sort
  end

  def add_exit(name, room)
    @exits[name] = room
  end

  def remove_exit(name)
    @exits.delete(name)
  end

  def to_json
    {:name=>@name, :desc=>@desc, :clients=>client_names, :exits=>exit_names}.to_json
  end

end
