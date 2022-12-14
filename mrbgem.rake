MRuby::Gem::Specification.new('mruby-dap-client') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'

  spec.add_dependency 'mruby-random'
  spec.add_dependency 'mruby-process', :mgem => 'mruby-process2'
  spec.add_dependency 'mruby-json'
  spec.add_dependency 'mruby-io'
  spec.add_dependency 'mruby-array-ext'
  spec.add_dependency 'mruby-hash-ext'
  spec.add_dependency 'mruby-env'
  spec.add_dependency 'mruby-errno'
  spec.add_dependency 'mruby-sleep'
end
