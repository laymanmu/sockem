
class Actor
  attr_reader :id, :type, :name, :room

  def initialize(parms)
    @id     = parms[:id]
    @type   = :client
    @name   = "actor#{@id}"
    @client = Client.new(parms[:ws])
    @client.set_actor(self)
    @disconnected = false;
    init_commands
    enter_room(parms[:room])
  end

  def init_commands
    @commands = Hash.new

    # help:
    @commands[:help] = Proc.new do |command|
      send(:msg, "commands: #{@commands.keys.sort.join(', ')}")
    end

    # exits:
    @commands[:exits] = Proc.new do |parms|
      send(:msg, "exits: #{@room.exit_names.join(', ')}")
    end

    # say:
    @commands[:say] = Proc.new do |parms|
      send(:msg, "#{@name} says: #{parms}")
    end

    # look:
    @commands[:look] = Proc.new do |parms|
      sendData(:room, @room.to_json)
    end

    # move:
    @commands[:move] = Proc.new do |parms|
      room = @room.exits[parms]
      room.nil? ? send(:msg, "no room found #{parms}") : enter_room(room)
    end
  end

  def handle_command(command, parms)
    if @commands.keys.include?(command)
      log("handle_command found command: #{command} parms: #{parms}")
      @commands[command].call(parms)
    else
      log("handle_command: unknown command: #{command} parms: #{parms}")
      send(:msg, "unknown command: #{command}")
    end
  end

  def enter_room(room)
    log("enter_room: #{room.name}")
    @room.leave(self) if @room
    @room = room
    @room.enter(self)
  end

  def update
    log("update")
    @client.process_inbox
    @client.process_outbox
    die if not @client.is_connected
  end

  def send(msgtype, msg)
    log("send msgtype: #{msgtype} msg: #{msg}")
    @client.send(msgtype, msg)
  end

  def sendData(msgtype, data)
    log("sendData msgtype: #{msgtype}: data: #{data}")
    @client.sendData(msgtype, data)
  end

  def die
    log("die")
    @room.leave(self)
    Database.instance.delete(@id)
  end

  def log(msg)
    Controller.instance.log(msg, :actor)
  end

end
