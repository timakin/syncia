require 'filewatcher'
require 'logger'
require 'fileutils'

class Syncia
  def initialize(local_dir_path)
    @pid_file_path  = './.syncia.pid'
    @logger         = Logger.new(STDOUT)

    unless directory_exists?(local_dir_path)
      @logger.error directory_not_found_error
      return
    end

    @local_dir_path = local_dir_path
    @logger.info syncia_start
  end

  def set_remote_info(remote_user, remote_host)
    @remote_user = remote_user
    @remote_host = remote_host
    @remote_info = @remote_user + "@" + @remote_host
  end

  def set_remote_dir(remote_dir_path)
    @remote_dir_path = remote_dir_path
  end

  def run
    unless (@remote_info && @remote_dir_path)
      @logger.error set_remote_before_running_error
      return
    end

    daemonize
    begin
      Signal.trap(:TERM) { shutdown($$) }
      Signal.trap(:INT)  { shutdown($$) }
      execute
    rescue => ex
      @logger.error ex
    end
  end

  def shutdown(pid)
    @logger.close
    FileUtils.rm @pid_file_path
    Process.kill('KILL', pid)
  end

private
  def directory_exists?(directory)
    File.directory?(directory)
  end

  def execute
    FileWatcher.new("#{@local_dir_path}/**/*").watch do |filename, event|
      system(sync_command)
    end
  end

  def daemonize
    exit!(0) if Process.fork
    Process.setsid
    exit!(0) if Process.fork
    open_pid_file
  end

  def open_pid_file
    begin
      open(@pid_file_path, 'w') {|f| f << Process.pid } if @pid_file_path
    rescue => ex
      @logger.error "Could not open pid file (#@pid_file_path)"
      @logger.error "Error: #{ex}"
      @logger.error ex.backtrace * "\n"
    end
  end

  def sync_command
    "rsync -azr -e ssh #{@local_dir_path}/* #{@remote_info}:#{@remote_dir_path} --delete" 
  end

  def syncia_start
    "[Syncia] start ..."
  end

  def set_remote_before_running_error
    "Set a host infomation and a dir_path of your remote environment, before running." 
  end

  def directory_not_found_error
    "Directory not found."
  end
end
