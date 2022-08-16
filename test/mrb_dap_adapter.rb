assert('support_request?') do
  adapter = DAP::Adapter.new('hoge', {})
  assert_equal true, adapter.support_request?('launch')
  assert_equal false, adapter.support_request?('hoge')

  assert_equal false, adapter.support_request?('configurationDone')
  adapter.update_capabilities({ 'supportsConfigurationDoneRequest' => true })
  assert_equal true, adapter.support_request?('configurationDone')

  assert_equal false, adapter.support_request?('setExceptionBreakpoints')
  adapter.update_capabilities({ 'exceptionBreakpointFilters' => [1, 2, 3] })
  assert_equal true, adapter.support_request?('setExceptionBreakpoints')

  assert_equal false, adapter.support_request?('reverseContinue')
  adapter.update_capabilities({ 'supportsStepBack' => true })
  assert_equal true, adapter.support_request?('reverseContinue')

  assert_equal false, adapter.support_request?('restartFrame')
  adapter.update_capabilities({ 'supportsRestartFrame' => true })
  assert_equal true, adapter.support_request?('restartFrame')

  assert_equal false, adapter.support_request?('goto')
  adapter.update_capabilities({ 'supportsGotoTargetsRequest' => true })
  assert_equal true, adapter.support_request?('goto')

  assert_equal false, adapter.support_request?('setVariable')
  adapter.update_capabilities({ 'supportsSetVariable' => true })
  assert_equal true, adapter.support_request?('setVariable')

  assert_equal false, adapter.support_request?('setExpression')
  adapter.update_capabilities({ 'supportsSetExpression' => true })
  assert_equal true, adapter.support_request?('setExpression')

  #      when 'setExpression' && @capabilities['supportsSetExpression']
end
