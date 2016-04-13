
class Client
  attr_reader :id, :type, :name, :is_connected, :ws, :room

  def initialize(ws)
    @is_connected = false
    @inbox        = []
    @outbox       = []
    @db           = Database.instance
    @id           = @db.get_next_id
    connect(ws)
  end

  def connect(ws)
    @ws = ws

    @ws.onopen do |handshake|
      log("connected")
      @is_connected = true
      process_outbox
      process_inbox
    end

    @ws.onmessage do |msg|
      log("got msg: #{msg}")
      @inbox << msg
      process_inbox
    end

    @ws.onclose do
      log("disconnected")
      @is_connected = false
      @actor.die if @actor
    end

    @ws.onerror do |e|
      backtrace = e.backtrace.join("\n")
      log("error: #{e.message}\n #{backtrace}")
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
    if @is_connected and not @actor.nil?
      @inbox.each do |msg|
        parts = msg.partition(/\s+/)
        log("process_inbox sending command: #{parts}")
        @actor.handle_command(parts.first.to_sym, parts.last)
      end
      @inbox = []
    else
      log("process_inbox skip. count: #{@inbox.length}. cnct? #{@is_connected}, actor? #{!@actor.nil?}")
    end
  end

  def process_outbox
    if @is_connected
      @outbox.each do |msg|
        log("process_outbox sending msg: #{msg}")
        @ws.send(msg)
      end
      @outbox = []
    else
      log("process_outbox skip. count: #{@outbox.length}")
    end
  end

  def set_actor(actor)
    log("set_actor: #{actor.name}")
    @actor = actor
  end

  def log(msg)
    type = "client#{@id}"
    Controller.instance.log(msg, type)
  end

end
