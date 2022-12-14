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
