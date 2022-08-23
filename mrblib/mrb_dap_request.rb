module DAP
  # send request message
  class Client
    def method_missing(name, *arguments, &block)
      send_request(name, *arguments, &block)
    end

    def respond_to_missing?(sym, _include_private)
      requests = [
        :configurationDone, :launch, :attach, :restart, :disconnect,
        :terminate, :breakpointLocations, :setBreakpoints,
        :setFunctionBreakpoints, :setExceptionBreakpoints,
        :dataBreakpointInfo, :setDataBreakpoints,
        :setInstructionBreakpoints, :continue, :next, :stepIn,
        :stepOut, :stepBack, :reverseContinue, :restartFrame,
        :goto, :pause, :stackTrace, :scopes, :variables,
        :setVariable, :source, :threads, :terminateThreads,
        :modules, :loadedSources, :evaluate, :setExpression,
        :stepInTargets, :gotoTargets, :completions, :exceptionInfo,
        :readMemory, :writeMemory, :disassemble
      ]
      requests.include?(sym)
    end

    def launch(arguments, &block)
      arguments['type'] = @initialize_arguments['adapterID'] if arguments['type'].nil?
      send_request('launch', arguments, &block)
    end
  end
end
