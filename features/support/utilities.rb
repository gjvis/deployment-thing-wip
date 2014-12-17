module Utilities
  module ScriptRunner

    def sh(command)
      $stderr.puts "run: #{command}"
      $stderr.puts "in: #{`pwd`}"

      system(command)

      raise "Error running command: #{command}\nExit status: #{$?.exitstatus}" unless $?.success?
    end

    module_function :sh

  end
end
