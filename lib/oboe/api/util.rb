# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

require 'pp'

module Oboe
  module API
    module Util
      BACKTRACE_CUTOFF = 200

      # Internal: Check whether the provided key is reserved or not. Reserved
      # keys are either keys that are handled by liboboe calls or the oboe gem.
      #
      # key - the key to check.
      #
      # Return a boolean indicating whether or not key is reserved.
      def valid_key?(key)
        !%w[ Label Layer Edge Timestamp Timestamp_u ].include? key.to_s
      end

      # Internal: Get the current backtrace.
      #
      # ignore - Number of frames to ignore at the end of the backtrace. Use
      #          when you know how many layers deep in oboe the call is being
      #          made.
      #
      # Returns a string with each frame of the backtrace separated by '\r\n'.
      def backtrace(ignore=1)
        trim_backtrace(Kernel.caller).join("\r\n")
      end

      # Internal: Trim a backtrace to a manageable size
      #
      # backtrace - the backtrace (an array of stack frames/from Kernel.caller)
      #
      # Returns a trimmed backtrace
      def trim_backtrace(backtrace)
        return backtrace unless backtrace.is_a?(Array)

        length = backtrace.size
        if length > BACKTRACE_CUTOFF
          # Trim backtraces by getting the first 180 and last 20 lines
          trimmed = backtrace[0, 180] + ['...[snip]...'] + backtrace[length - 20, 20]
        else
          trimmed = backtrace
        end
        trimmed
      end

      # Internal: Check if a host is blacklisted from tracing
      #
      # addr_port - the addr_port from Net::HTTP although this method
      # can be used from any component in reality
      #
      # Returns a boolean on blacklisted state
      def blacklisted?(addr_port)
        return false unless Oboe::Config.blacklist

        # Ensure that the blacklist is an array 
        unless Oboe::Config.blacklist.is_a?(Array)
          val = Oboe::Config[:blacklist]
          Oboe::Config[:blacklist] = [ val.to_s ]
        end

        Oboe::Config.blacklist.each do |h|
          return true if addr_port.to_s.match(h.to_s)
        end

        false
      end
      
      # Internal: Pretty print a list of arguments for reporting
      #
      # args - the list of arguments to work on
      #
      # Returns a pretty string representation of arguments
      def pps(*args)
        old_out = $stdout
        begin
          s = StringIO.new
          $stdout = s
          pp(*args)
        ensure
          $stdout = old_out
        end
        s.string
      end

      # Internal: Determine a string to report representing klass
      #
      # args - an instance of a Class, a Class or a Module
      #
      # Returns a string representation of klass
      def get_class_name(klass)
        kv = {}
        if klass.to_s =~ /::/
          klass.class.to_s.rpartition('::').last
        else
          if klass.is_a?(Class) and klass.is_a?(Module)
            # Class
            kv["Class"] = klass.to_s
        
          elsif (not klass.is_a?(Class) and not klass.is_a?(Module))
            # Class instance
            kv["Class"] = klass.class.to_s
          
          else
            # Module
            kv["Module"] = klass.to_s
          end
        end
        kv
      end

    end
  end
end
