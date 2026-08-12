assert('add_breakpoint') do
  client = DAP::Client.new('hoge', {})
  assert_equal 0, client.source_breakpoints.size
  client.add_breakpoint('hoge.c', 100)
  assert_equal 1, client.source_breakpoints.size
end

assert('delete_breakpoint') do
  client = DAP::Client.new('hoge', {})
  client.add_breakpoint('/foo/bar/hoge.c', 100)
  client.add_breakpoint('/foo/bar/hoge.c', 200)
  client.add_breakpoint('huga.c', 234)
  assert_equal 2, client.source_breakpoints.size
  assert_equal 2, client.source_breakpoints['/foo/bar/hoge.c'].size
  client.delete_breakpoint('huga.c', 234)
  assert_equal 2, client.source_breakpoints.size
  client.delete_breakpoint('hoge.c', 1)
  assert_equal 2, client.source_breakpoints.size
  client.delete_breakpoint('/foo/bar/hoge.c', 1000)
  assert_equal 2, client.source_breakpoints.size
  client.delete_breakpoint('/foo/bar/hoge.c', 100)
  assert_equal 1, client.source_breakpoints['/foo/bar/hoge.c'].size
end

assert('recv_message reads consecutive DAP messages') do
  reader, writer = IO.pipe
  client = DAP::Client.new('hoge', {})
  client.io = reader
  messages = [
    { 'seq' => 1, 'type' => 'event', 'event' => 'initialized' },
    { 'seq' => 2, 'type' => 'event', 'event' => 'stopped' }
  ]

  messages.each do |message|
    json = message.to_json
    writer.write "Content-Length: #{json.bytesize}\r\n\r\n#{json}"
  end

  _headers, first = client.recv_message
  _headers, second = client.recv_message

  assert_equal messages[0], first
  assert_equal messages[1], second
ensure
  reader.close unless reader.closed?
  writer.close unless writer.closed?
end
