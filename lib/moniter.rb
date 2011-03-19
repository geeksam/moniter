$: << File.expand_path(File.dirname(__FILE__))
$: << File.expand_path(File.join(File.dirname(__FILE__), 'moniter'))
require 'time'
require 'forwardable'
require 'core_ext'
require 'schedule'

module Moniter
  module_function

  def build_schedule(&block)
    Schedule.new.tap do |schedule|
      schedule.instance_eval(&block)
    end
  end
end
