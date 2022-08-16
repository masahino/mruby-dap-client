module DAP
  # adapter
  class Adapter
    attr_reader :command, :args, :capabilities

    MANDATORY_REQUESTS = [
      'launch', 'attach', 'disconnect', 'setBreakpoints',
      'continue', 'next', 'stepIn', 'stepOut', 'pause', 'stackTrace', 'scopes',
      'variables', 'source', 'threads', 'evaluate'
    ].freeze

    def initialize(command, args)
      @command = command
      @args = args
      @capabilities = {
        # The debug adapter supports the `configurationDone` request.
        'supportsConfigurationDoneRequest' => false,
        # The debug adapter supports function breakpoints.
        'supportsFunctionBreakpoints' => false,
        #  The debug adapter supports conditional breakpoints.
        'supportsConditionalBreakpoints' => false,
        # The debug adapter supports breakpoints that break execution after a
        # specified number of hits.
        'supportsHitConditionalBreakpoints' => false,
        # The debug adapter supports a (side effect free) evaluate request for data
        # hovers.
        'supportsEvaluateForHovers' => false,
        # Available exception filter options for the `setExceptionBreakpoints`
        # request.
        'exceptionBreakpointFilters' => [],
        # ExceptionBreakpointsFilter[];
        # The debug adapter supports stepping back via the `stepBack` and
        # `reverseContinue` requests.
        'supportsStepBack' => false,
        # The debug adapter supports setting a variable to a value.
        'supportsSetVariable' => false,
        # The debug adapter supports restarting a frame.
        'supportsRestartFrame' => false,
        # The debug adapter supports the `gotoTargets` request.
        # supportsGotoTargetsRequest?: boolean;
        # The debug adapter supports the `stepInTargets` request.
        'supportsStepInTargetsRequest' => false,
        # The debug adapter supports the `completions` request.
        'supportsCompletionsRequest' => false,
        # The set of characters that should trigger completion in a REPL. If not
        # specified, the UI should assume the `.` character.
        'completionTriggerCharacters' => [], # string[];
        # The debug adapter supports the `modules` request.
        'supportsModulesRequest' => false,
        # The set of additional module information exposed by the debug adapter.
        'additionalModuleColumns' => [], # ColumnDescriptor[];
        # Checksum algorithms supported by the debug adapter.
        'supportedChecksumAlgorithms' => [], # ChecksumAlgorithm[];
        # The debug adapter supports the `restart` request. In this case a client
        # should not implement `restart` by terminating and relaunching the adapter
        # but by calling the RestartRequest.
        'supportsRestartRequest' => false,
        # The debug adapter supports `exceptionOptions` on the
        # setExceptionBreakpoints request.
        'supportsExceptionOptions' => false,
        # The debug adapter supports a `format` attribute on the stackTraceRequest,
        # variablesRequest, and evaluateRequest.
        'supportsValueFormattingOptions' => false,
        # The debug adapter supports the `exceptionInfo` request.
        'supportsExceptionInfoRequest' => false,
        # The debug adapter supports the `terminateDebuggee` attribute on the
        # `disconnect` request.
        'supportTerminateDebuggee' => false,
        # The debug adapter supports the `suspendDebuggee` attribute on the
        # `disconnect` request.
        'supportSuspendDebuggee' => false,
        # The debug adapter supports the delayed loading of parts of the stack, which
        # requires that both the `startFrame` and `levels` arguments and the
        # `totalFrames` result of the `StackTrace` request are supported.
        'supportsDelayedStackTraceLoading' => false,
        # The debug adapter supports the `loadedSources` request.
        'supportsLoadedSourcesRequest' => false,
        # The debug adapter supports logpoints by interpreting the `logMessage`
        # attribute of the `SourceBreakpoint`.
        'supportsLogPoints' => false,
        # The debug adapter supports the `terminateThreads` request.
        'supportsTerminateThreadsRequest' => false,
        # The debug adapter supports the `setExpression` request.
        'supportsSetExpression' => false,
        # The debug adapter supports the `terminate` request.
        'supportsTerminateRequest' => false,
        # The debug adapter supports data breakpoints.
        'supportsDataBreakpoints' => false,
        # The debug adapter supports the `readMemory` request.
        'supportsReadMemoryRequest' => false,
        # The debug adapter supports the `writeMemory` request.
        'supportsWriteMemoryRequest' => false,
        # The debug adapter supports the `disassemble` request.
        'supportsDisassembleRequest' => false,
        # The debug adapter supports the `cancel` request.
        'supportsCancelRequest' => false,
        # The debug adapter supports the `breakpointLocations` request.
        'supportsBreakpointLocationsRequest' => false,
        # The debug adapter supports the `clipboard` context value in the `evaluate`
        # request.
        'supportsClipboardContext' => false,
        # The debug adapter supports stepping granularities (argument `granularity`)
        # for the stepping requests.
        'supportsSteppingGranularity' => false,
        # The debug adapter supports adding breakpoints based on instruction
        # references.
        'supportsInstructionBreakpoints' => false,
        # The debug adapter supports `filterOptions` as an argument on the
        # `setExceptionBreakpoints` request.
        'supportsExceptionFilterOptions' => false,
        # The debug adapter supports the `singleThread` property on the execution
        # requests (`continue`, `next`, `stepIn`, `stepOut`, `reverseContinue`,
        # `stepBack`).
        'supportsSingleThreadExecutionRequests' => false
      }
    end

    def update_capabilities(new_capabilities)
      @capabilities.merge!(new_capabilities)
    end

    def support_request?(command)
      return true if MANDATORY_REQUESTS.include?(command)

      supports = "supports#{command[0].upcase}#{command[1..-1]}Request"
      return true if @capabilities.key?(supports) && @capabilities[supports] == true

      supports = "supports#{command[0].upcase}#{command[1..-1]}"
      return true if @capabilities.key?(supports) && @capabilities[supports] == true

      case command
      when 'setExceptionBreakpoints'
        if @capabilities['exceptionBreakpointFilters'].size > 0
          true
        else
          false
        end
      when 'reverseContinue'
        if @capabilities['supportsStepBack']
          true
        else
          false
        end
      when 'goto'
        if @capabilities['supportsGotoTargetsRequest']
          true
        else
          false
        end
      else
        false
      end
    end
  end
end
