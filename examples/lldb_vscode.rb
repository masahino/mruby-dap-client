server_command = 'lldb-vscode'

client = DAP::Client.new(server_command)

# run server and send initialize
client.start_debug_adapter({ 'adapterID' => 'lldb-vscode' }) do |ret|
  puts 'response of initialize'
  puts JSON.pretty_generate ret
  client.update_adapter_capabilities(ret)
end

client.launch({ 'name' => 'mruby-dap', 'type' => 'lldb-vscode', 'program' => 'a.out', 'StopOnEntry' => true }) do |ret|
  puts JSON.pretty_generate ret
end

client.setFunctionBreakpoints({ 'breakpoints' => [DAP::Type::FunctionBreakpoint.new('main')] }) do |ret|
  puts 'response of setFunctionBreakpoints'
  puts JSON.pretty_generate ret
end

source = DAP::Type::Source.new('test.c')
bp = DAP::Type::SourceBreakpoint.new(13, 1)
client.setBreakpoints({ 'source' => source, 'lines' => [13], 'breakpoints' => [bp] }) do |ret|
  puts 'response of setBreakpoints'
  puts JSON.pretty_generate ret
end

client.configurationDone do |ret|
  puts JSON.pretty_generate ret
end

puts '----------'
puts client.recv_buffer

event = client.wait_message
puts JSON.pretty_generate event

client.threads do |ret|
  puts JSON.pretty_generate ret
end

client.breakpointLocations do |ret|
  puts JSON.pretty_generate ret
end

thread_id = event['body']['threadId']
client.stepIn({ 'threadId' => thread_id }) do |ret|
  puts JSON.pretty_generate ret
end

client.source do |ret|
  puts JSON.pretty_generate ret
end

client.stop_adapter do |ret|
  puts JSON.pretty_generate ret
end