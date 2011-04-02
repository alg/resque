# --------------------------------------------------
# Convenience Methods
# --------------------------------------------------
def all_spec_files
  Dir['test/**/*_test.rb']
end
 
def run(cmd)
  puts(cmd)
  system(cmd)
end
 
def spec(args)
  run "ruby -I test/ #{args}"
end

def run_all_specs
  spec all_spec_files.join(' ')
end
 
# --------------------------------------------------
# Watchr Rules
# --------------------------------------------------
watch('lib(/resque)?/(.*)\.rb')   { |m| spec("test/%s_test.rb"      % m[2] ) }
watch('^test.*/.*_test\.rb'   )   { |m| spec("%s"                   % m[0] ) }
watch('^test/test_helper\.rb' )   { run_all_specs }
 
# --------------------------------------------------
# Signal Handling
# --------------------------------------------------
# Ctrl-\
Signal.trap('QUIT') do
  puts " --- Running all specs ---\n\n"
  run_all_specs
end
 
# Ctrl-C
Signal.trap('INT') { abort("\n") }
