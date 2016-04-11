
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
    @entities[id] = entity
  end

  def delete(id)
    @entities.delete(id)
  end

  def create(type, parms)
    parms[:id] = get_next_id
    case type
    when :room
      entity = Room.new(parms)
    when :client
      entity = Client.new(parms)
    end
    save(entity.id, entity)
    entity
  end

end
