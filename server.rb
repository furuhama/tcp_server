# frozen_string_literal: true

require 'socket'

host = '127.0.0.1'
port = 8080
backlog = 5

sock = TCPServer.new(host, port)
sock.listen backlog

def run_server(sock)
  3.times do |i|
    begin
      puts "#{Process.pid}:#{i}: Selecting..."
      ios, _ = IO.select [sock]
      if io = ios.first.accept_nonblock
        puts "#{Process.pid}:#{i}: Accepted"
        puts io
        io.write "accepted\n"
        io.close
        puts "#{Process.pid}:#{i}: closed"
      else
        "#{Process.pid}:#{i}: Accept failed"
      end
    rescue SystemCallError => e
      pp e
      puts "#{Process.pid}:#{i}: syscall error"
    end
  end

  sock.close
  puts "#{Process.pid}: exited"
end

child_pids = []

2.times do
  dupped_sock = sock.dup
  child_pids << fork do
    run_server(dupped_sock)
  end
end

puts 'forked'

child_pids.each do |pid|
  Process.waitpid(pid)
end

sock.close

puts 'exited'
