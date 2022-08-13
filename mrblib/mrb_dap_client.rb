module DAP
  # dap client
  class Client
    attr_accessor :recv_buffer, :request_buffer, :status, :io, :file_version, :logfile,
                  :adapter, :adapter_capabilities

    DEFAULT_INITIALIZE_ARGUMENTS = {
      # The ID of the client using this adapter.
      'clientID' => 'mruby-dap',
      # The human-readable name of the client using this adapter.
      'clientName' => 'mruby-dap',
      # The ID of the debug adapter.
      'adapterID' => 'unknown',
      # The ISO-639 locale of the client using this adapter, e.g. en-US or de-CH.
      'locale' => 'en-US',
      # If true all line numbers are 1-based (default).
      'linesStartAt1' => true,
      # If true all column numbers are 1-based (default).
      'columnsStartAt1' => true,
      # Determines in what format paths are specified. The default is `path`, which
      # is the native format.
      # Values': 'path', 'uri', etc.
      'pathFormat' => 'path',
      # Client supports the `type` attribute for variables.
      'supportsVariableType' => false,
      # Client supports the paging of variables.
      'supportsVariablePaging' => false,
      # Client supports the runInTerminal request.
      'supportsRunInTerminalRequest' => false,
      # Client supports memory references.
      'supportsMemoryReferences' => false,
      # Client supports progress reporting.
      'supportsProgressReporting' => false,
      # Client supports the invalidated event.
      'supportsInvalidatedEvent' => false,
      # Client supports the memory event.
      'supportsMemoryEvent' => false,
      # Client supports the `argsCanBeInterpretedByShell` attribute on the
      # `runInTerminal` request.
      'supportsArgsCanBeInterpretedByShell' => false
    }.freeze

    def initialize(command, options = {})
      args = options['args']
      args = [] if args.nil?
      @adapter = Adapter.new(command, args)
      @recv_buffer = []
      @request_buffer = {}
      @adapter_status = nil
      @adapter_capabilities = @adapter.capabilities
      @initialize_arguments = DEFAULT_INITIALIZE_ARGUMENTS.dup
      @io = nil
      @seq = 0
      @logfile = options['logfile']
      if @logilfe.nil?
        tmpdir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || ENV['USERPROFILE'] || '/tmp'
        @logfile = "#{tmpdir}/mruby_dap_'#{File.basename(command)}_#{$$}.log"
      end
      @status = :stop
    end

    def update_adapter_capabilities(capabilities)
      @adapter.update_capabilities(capabilities)
    end

    def make_seq
      @seq += 1
    end

    def recv_message
      headers = {}
      while (line = @io.gets)
        break if line == "\r\n"

        k, v = line.chomp.split(':')
        headers[k] = v.to_i if k == 'Content-Length'
      end
      message = ''
      message = JSON.parse(@io.read(headers['Content-Length'])) unless headers['Content-Length'].nil?

      [headers, message]
    end

    def wait_response(seq = nil)
      message = nil
      loop do
        headers, message = recv_message
        break if headers == {}

        if message['type'] == 'response' && seq == message['request_seq'].to_i
          @request_buffer.delete(seq)
          break
        else
          @recv_buffer.push(message)
        end
      end
      message
    end

    def wait_message
      _headers, message = recv_message
      message
    end

    def send_message(message)
      json_message = message.to_json
      header = 'Content-Length: ' + json_message.bytesize.to_s + "\r\n\r\n"
      begin
        @io.print header
        @io.print json_message
        true
      rescue Errno::ESPIPE
        false
      end
    end

    def create_request_message(command, arguments)
      seq = make_seq
      {
        'seq' => seq,
        'type' => 'request',
        'command' => command,
        'arguments' => arguments
      }
    end

    def send_request(command, arguments = {}, &block)
      message = create_request_message(command, arguments)
      seq = message['seq']
      ret = send_message(message)
      return nil if ret == false

      if block_given?
        resp = wait_response(seq)
        block.call(resp)
      else
        @request_buffer[message['seq']] = {
          message: message,
          block: block
        }
      end
      seq
    end

    def start_debug_adapter(arguments, &block)
      return unless @io.nil?

      command_str = "#{@adapter.command} #{@adapter.args.join(' ')}"
      log = File.open(@logfile, 'w')
      begin
        @io = IO.popen(command_str, 'rb+', err: log.fileno)
      rescue
        $stderr.puts 'error'
        return
      end
      @initialize_arguments.merge!(arguments)
      seq = send_request('initialize', @initialize_arguments)
      res = wait_response(seq)
      @adapter.update_capabilities(res['body']) unless res['body'].nil?
      @status = :running
      if block_given?
        block.call(res)
      else
        res
      end
    end

    def stop_adapter
      if @status == :running
        send_request('disconnect')
      end
      Process.kill(15, @io.pid)
    end

    def cancel_request(seq)
      return if @request_buffer[seq].nil?

      send_request('cancel', { 'requestId' => seq })
      @request_buffer.delete(seq)
    end
  end
end
