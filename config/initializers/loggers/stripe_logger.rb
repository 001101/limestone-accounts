# frozen_string_literal: true

# Custom Stripe logger
require "singleton"

class StripeLogger < Logger
  include Singleton

  def initialize
    super(Rails.root.join(STRIPE_LOG_PATH))
    self.formatter = formatter
  end

  # Optional, but good for prefixing timestamps automatically
  def formatter
    proc { |severity, time, _progname, msg|
      formatted_severity = sprintf("%-5s", severity.to_s)
      formatted_time = time.strftime("%Y-%m-%d %H:%M:%S")
      "[#{formatted_severity} #{formatted_time} #{$$}] #{msg.to_s.strip}\n"
    }
  end

  class << self
    delegate :error, :debug, :fatal, :info, :warn, :add, :log, to: :instance
  end
end
