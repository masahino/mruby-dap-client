class DAPshell
  DAP_CONFIG = {
    'lldb-vscode' => {
      server_command: 'lldb-vscode',
      type: 'lldb-vscode'
    },
    'cpptools' => {
      server_command: "#{ENV['HOME']}/.vscode/extensions/ms-vscode.cpptools-1.12.0-darwin-x64/debugAdapters/bin/OpenDebugAD7",
      type: 'cppdbg',
      args: '',
      port: nil
    },
    'codelldb' => {
      server_command: "#{ENV['HOME']}/.vscode/extensions/vadimcn.vscode-lldb-1.7.4/adapter/codelldb",
      args: ['--port 4711'],
      type: 'lldb',
      port: 4711
    }
  }
  def initialize(server_type = 'lldb-vscode')
    @server_type = server_type
    @client = DAP::Client.new(DAP_CONFIG[server_type][:server_command],
                              {
                                'args' => DAP_CONFIG[server_type][:args],
                                'port' => DAP_CONFIG[server_type][:port]
                              })
    # run server and send initialize
    @client.start_debug_adapter({ 'adapterID' => DAP_CONFIG[server_type][:type] })

    @readings = [$stdin, @client.io]
    @thread_id = 0
    @process = { name: '', pid: 0 }
  end

  def launch(program)
    args = program[1..-1]
    @client.launch({ 'name' => 'mruby-dap', 'type' => DAP_CONFIG[@server_type][:type], 'program' => program[0],
                     'args' => args, 'cwd' => File.dirname(__FILE__) })
  end

  def attach(args)
    program = args[0]
    @client.attach({ 'name' => 'mruby-dap', 'type' => DAP_CONFIG[@server_type][:type], 'program' => program })
  end

  def breakpoint(args)
    if args.nil?
      puts '??'
      return
    end

    if args.index(':').nil?
      bp = DAP::Type::FunctionBreakpoint.new(args)
      @client.setFunctionBreakpoints({ 'breakpoints' => [bp] })
    else
      source = DAP::Type::Source.new(args.split(':')[0])
      bp = DAP::Type::SourceBreakpoint.new(args.split(':')[1].to_i)
      @client.setBreakpoints({ 'source' => source, 'breakpoints' => [bp] })
    end
  end

  def shutdown
    @client.disconnect
    exit
  end

  def process_command
    line = gets.chomp
    return if line == ''

    command = line.split(' ')[0]
    case command
    when 'l', 'launch'
      seq = launch(line.split[1..-1])
    when 'a', 'attach'
      seq = attach(line.split[1..-1])
    when 'b'
      seq = breakpoint(line.split[1])
    when 'bl'
      seq = @client.breakpointLocations
    when 's'
      seq = @client.stepIn({ 'threadId' => @thread_id })
    when 'n'
      seq = @client.next({ 'threadId' => @thread_id })
    when 'c'
      seq = @client.continue({ 'threadId' => @thread_id })
    when 'stackTrace'
      seq = @client.stackTrace({ 'threadId' => @thread_id })
    when 'q', 'quit'
      shutdown
    when nil
      seq = nil
    else
      if @client.respond_to?(command)
        seq = @client.send('send_request', command)
      else
        puts 'unknown command'
        seq = nil
      end
    end

    seq
  end

  def process_event(event, body)
    case event
    when 'stopped'
      @thread_id = body['threadId'].to_i
      puts
      puts 'stopped'
      puts body
    when 'process'
      @process[:name] = body['name']
      @process[:pid] = body['systemProcessId'] unless body['systemProcessId'].nil?
      puts
      puts 'process'
      puts body
    when 'initialized'
      #      @client.threads do |res|
      #        @thread_id = res['body']['threads'][0]['id'] if res['body']['threads'].size > 0
      #      end
      puts
      puts 'initialized'
    else
      puts
      puts event
      puts body
    end
  end

  def process_message
    res = @client.wait_message

    case res['type']
    when 'response'
      puts
      puts res
    when 'event'
      process_event(res['event'], res['body'])
    else
      puts
      puts 'unknown message'
    end
  end

  def run
    print '> '
    loop do
      readable, _writable = IO.select(@readings)
      readable.each do |ri|
        if ri == $stdin
          process_command
          print '> '
        elsif ri == @client.io
          unless @client.io.eof?
            process_message
            print '> '
          end
        end
      end
    end
  end
end

if ARGV.size > 0
  DAPshell.new(ARGV[0]).run
else
  DAPshell.new.run
end
