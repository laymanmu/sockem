
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

    connect(parms[:ws])       if parms[:ws]
    change_room(parms[:room]) if parms[:room]
  end

  def connect(ws)
    @ws = ws

    @ws.onopen do |handshake|
      @is_connected = true
      puts "#{@name} connected"
      send(:msg, "welcome, #{@name}")
    end

    @ws.onmessage do |msg|
      @inbox << msg
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
      @data[:room_id] = nil
    end
  end

  def send(msgtype, msg)
    data = "({'type':'#{msgtype}','msg':'#{msg}'})"
    @outbox << data
  end

  def update
    puts " #{@name}, #{@is_connected}, #{@outbox.length}"
    if @is_connected
      @outbox.each do |json|
        @ws.send(json)
      end
      @outbox = []
    end
    @inbox.each do |input|
      parms      = input.split(/\s+/)
      command    = parms.shift
      parmstring = parms.join(" ")
      case command
      when "say"
        @room.broadcast(:msg, "#{@name} says #{parmstring}")
      when "exits"
        rooms = @db.all(:room).collect { |room| room.name }
        send(:exits, rooms.join(", "))
      when "look"
        send(:msg, @room.name)
      when "move"
        rooms = @db.all(:room).select { |room| room.name == parmstring }
        if rooms[0]
          change_room(rooms[0])
        else
          send(:msg, "no room found named #{parmstring}")
        end
      else
        send(:msg, "unknown command: #{input}")
      end
    end
    @inbox = []
  end
end
