# Copyright (c) 2013 AppNeta, Inc.
# All rights reserved.

module TraceView
  ##
  # The current version of the gem.  Used mainly by
  # traceview.gemspec during gem build process
  module Version
    MAJOR = 3
    MINOR = 0
    PATCH = 4
    BUILD = nil

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
  end
end
