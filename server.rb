require 'socket'
require_relative 'cypher.rb'
require 'digest/sha1'

class Server
  def bye(connection)
    connection.puts "Bye!"
    Thread.stop
  end

  def encrypt(connection, msg, key)
    hashed_key = Digest::SHA1.hexdigest(key)
    m = Cypher.generate_min_from_key(key)
    n = Cypher.generate_max_from_key(key, m)
    crypted_msg = Cypher.encrypt(msg, m, n)
    connection.puts crypted_msg
  end

  def hello(connection)
    connection.puts 'HELLO QWEQWE'
  end

  def decrypt(connection, msg, key)
    hashed_key = Digest::SHA1.hexdigest(key)
    m = Cypher.generate_min_from_key(key)
    n = Cypher.generate_max_from_key(key, m)
    decrypted_msg = Cypher.decrypt(msg, m, n)
    connection.puts decrypted_msg
  end

  def initialize(socket_address, socket_port)
    @server_socket = TCPServer.open(socket_port, socket_address)

    @commands = %w[hello bye encrypt decrypt]
    @connections_details = {}
    @connected_clients = {}

    @connections_details[:server] = @server_socket
    @connections_details[:clients] = @connected_clients

    puts 'Started server.........'
    run
  end

  def registration(connection)
    registered = false
    while registered == false
    command = connection.gets.chomp.split(' ')
    variant = command[1]
    puts "Command = #{command}"
    puts "Variant = #{variant}"

      if command[0].downcase != 'hello'
        connection.puts "Sorry but you can't use any commands unless you registered"
      elsif command.length != 2
        connection.puts 'Wrong number of arguments'
      elsif !@connections_details[:clients][variant].nil?
        connection.puts 'This user already connected'
      else
        registered = true
        connection.puts "Hello variant #{variant}! You may use commands now."
        @connections_details[:clients][variant] = connection
      end
    end
  end

  def parse_commands(connection)
    loop do
      params = []
      message = connection.gets.chomp.split(' ')

      next unless @commands.include? message[0]

        operation = message.slice(0)
        message = message.drop(1)
        params_val = method(operation.to_s).arity
        # connection.puts "operation: #{operation}"
        # connection.puts "params_val: #{params_val}"

        # connection.puts "----------------------------------"
        i = 0
        params << connection
        while i < params_val
          params << message[i]
          i += 1
        end

        params = params.compact
        puts "Operation: #{operation}"
        puts "PARAMS: #{params}"
        
        send(operation, *params)
    end
  end

  def run
    loop do
      client_connection = @server_socket.accept
      Thread.start(client_connection) do |conn| # open thread for each accepted connection
        conn.puts "Hello! If you want to use commands you must register with 'hello X' command"
        conn.puts "Where 'X' is your variant number"

        registration(conn)
        parse_commands(conn)
      end
    end.join
  end
end

Server.new(8080, 'localhost')
