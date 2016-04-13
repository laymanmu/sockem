
class Controller
  include Singleton

  def log(msg, type=:info)
    stamp = Time.now.strftime('%H:%M:%S')
    puts "#{stamp} #{type} #{msg}"
  end

end
