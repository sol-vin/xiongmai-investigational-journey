require "json"
require "socket"
require "uuid"
require "logger"
require "colorize"
require "kemal"

require "./errors"
require "./dahua_hash"
require "./xmsocket"
require "./xmmessage"

require "./commands/*"
require "./commands/info/*"

require "./denial_of_service"

require "./fuzzer/command/fuzzer"