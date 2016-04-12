
class Client
  attr_reader :id, :type, :name, :is_connected, :ws, :room

  def initialize(parms)
    @id   = parms[:id]
    @type = :client
    @name = "client#{@id}"
    @is_connected = false
    @inbox  = []
    @outbox = []
    @db     = Database.instance

    send(:msg, "welcome, #{@name}")
    connect(parms[:ws])       if parms[:ws]
    change_room(parms[:room]) if parms[:room]
  end

  def connect(ws)
    @ws = ws

    @ws.onopen do |handshake|
      @is_connected = true
      puts "#{@name} connected"
    end

    @ws.onmessage do |msg|
      @inbox << msg
      process_inbox
    end

    @ws.onclose do
      disconnect
    end

    @ws.onerror do |e|
      puts "#{@name} ws error: #{e.message}"
    end
  end

  def change_room(room)
    @room.leave(self) if @room
    @room = room
    @room.enter(self)
    send(:msg, "you entered #{@room.name}")
  end

  def disconnect
    @is_connected = false
    puts "#{@name} disconnected"
    if @room
      @room.leave(self)
      @room.broadcast("#{@name} disconnected")
      @room = nil
    end
  end

  def send(msgtype, msg)
    data = "{\"type\":\"#{msgtype}\",\"msg\":\"#{msg}\"}"
    @outbox << data
    process_outbox
  end

  def sendData(msgtype, data)
    msg = "{\"type\":\"#{msgtype}\",\"msg\":#{data}}"
    @outbox << msg
    process_outbox
  end

  def process_inbox
    if @is_connected
      @inbox.each do |msg|
        parts = msg.partition(/\s+/)
        handle_command(parts.first, parts.last)
      end
      @inbox = []
    end
  end

  def process_outbox
    if @is_connected
      @outbox.each { |msg| @ws.send(msg) }
      @outbox = []
    end
  end

  def update
    process_inbox
    process_outbox
  end

  def handle_command(command, parmstring="")
    case command
    when "say"
      @room.broadcast(:msg, "#{@name} says #{parmstring}")
    when "exits"
      rooms = @db.all(:room).collect { |room| room.name }
      send(:exits, rooms.join(", "))
    when "look"
      room = {:name=>@room.name, :desc=>@room.desc, :clients=>@room.client_names}
      sendData(:room, room.to_json)
    when "move"
      room = @db.all(:room).select { |room| room.name == parmstring }[0]
      if room
        change_room(rooms[0])
      else
        send(:msg, "no room found named #{parmstring}")
      end
    else
      send(:msg, "unknown command: #{input}")
    end
  end

end
