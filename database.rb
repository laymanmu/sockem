
class Database
  include Singleton

  def initialize
    @next_id  = 0
    @entities = Hash.new
  end

  def get_next_id
    @next_id += 1
  end

  def find(id)
    @entities[id]
  end

  def all(type)
    @entities.values.select { |entity| entity.type == type }
  end

  def save(id, entity)
    log("save id: #{id} name: #{entity.name}")
    @entities[id] = entity
  end

  def delete(id)
    log("delete id: #{id} name: #{@entities[id].name}")
    @entities.delete(id)
  end

  def create(type, parms)
    parms[:id] = get_next_id
    case type
    when :room
      entity = Room.new(parms)
    when :actor
      entity = Actor.new(parms)
    end
    log("create type: #{type} name: #{entity.name}")
    save(entity.id, entity)
    entity
  end

  def log(msg)
    type = "db"
    Controller.instance.log(msg, type)
  end

end
