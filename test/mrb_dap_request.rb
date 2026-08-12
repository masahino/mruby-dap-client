assert('respond_to?') do
  client = DAP::Client.new('hoge', {})
  assert_equal true, client.respond_to?('attach')
  assert_equal false, client.respond_to?('hoge')
end
