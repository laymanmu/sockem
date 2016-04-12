
class Actor

  def initialize(client)
    @client = client
    client.set_actor(self)
    init_commands
  end

  def init_commands
    @commands = Hash.new

    # help:
    @commands[:help] = Proc.new do |command|
      @client.send(:msg, "commands: #{@commands.keys.sort.join(', ')}")
    end

    # exits:
    @commands[:exits] = Proc.new do |parms|
      @client.send(:msg, "exits: #{@client.room.exit_names.join(', ')}")
    end

    # say:
    @commands[:say] = Proc.new do |parms|
      @client.send(:msg, "#{@client.name} says: #{parms}")
    end

    # look:
    @commands[:look] = Proc.new do |parms|
      @client.sendData(:room, @client.room.to_json)
    end

    # move:
    @commands[:move] = Proc.new do |parms|
      room = @client.room.exits[parms]
      if room
        @client.change_room(room)
      else
        @client.send(:msg, "no room found at #{parms}")
      end
    end
  end

  def handle_command(command, parms)
    if @commands.keys.include?(command)
      @commands[command].call(parms)
    else
      @client.send(:msg, "unknown command: #{command}")
    end
  end
end
