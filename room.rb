

class Room
  attr_reader :id, :type, :name, :actors, :desc, :exits

  def initialize(parms)
    @id     = parms[:id]
    @type   = :room
    @name   = parms[:name]
    @desc   = parms[:desc]
    @actors = []
    @exits  = {}
  end

  def enter(actor)
    log("enter actor: #{actor.name}")
    @actors << actor
    broadcastData(:room, to_json)
  end

  def leave(actor)
    log("leave actor: #{actor.name}")
    @actors.delete(actor)
    broadcastData(:room, to_json)
  end

  def broadcast(msgtype, msg)
    log("broadcast msgtype: #{msgtype} msg: #{msg}")
    @actors.each { |actor| actor.send(msgtype, msg) }
  end

  def broadcastData(msgtype, data)
    log("broadcastData msgtype: #{msgtype} data: #{data}")
    @actors.each { |actor| actor.sendData(msgtype, data) }
  end

  def actor_names
    @actors.collect { |actor| actor.name }
  end

  def exit_names
    @exits.keys.sort
  end

  def add_exit(name, room)
    log("add_exit name: #{name} room: #{room.name}")
    @exits[name] = room
  end

  def remove_exit(name)
    log("remove_exit name: #{name}")
    @exits.delete(name)
  end

  def to_json
    {:name=>@name, :desc=>@desc, :actors=>actor_names, :exits=>exit_names}.to_json
  end

  def log(msg)
    type = "room#{@id}"
    Controller.instance.log(msg, type)
  end

end
