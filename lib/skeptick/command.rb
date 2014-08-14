require 'shellwords'
if defined?(JRUBY_VERSION)
  require 'spoon'
else
  require 'posix/spawn'
end
require 'skeptick/error'

module Skeptick
  class Command
    module Executable
      def command
        Command.new(self)
      end

      def execute
        command.run
      end
      alias_method :build, :execute
      alias_method :run,   :execute
    end

    def initialize(command_obj)
      @command_obj = command_obj
    end

    def command
      @command_obj.to_s.shellsplit.shelljoin
    end
    alias_method :to_s, :command

    def run
      opts = {}
      opts[:chdir] = Skeptick.cd_path.to_s if Skeptick.cd_path

      if Skeptick.debug_mode?
        Skeptick.log("Skeptick Command: #{command}")
      end

      if defined?(JRUBY_VERSION)
        im_process = Spoon.posix_spawn('/usr/bin/env', file_actions, spawn_attr, [command, *opts].join(' '))
      else
        im_process = POSIX::Spawn::Child.new(command, opts)

        if !im_process.success?
          raise ImageMagickError,
            "ImageMagick error\nCommand: #{command}\nSTDERR:\n#{im_process.err}"
        end

        im_process.status
      end
    end
  end
end
