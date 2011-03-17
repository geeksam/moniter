$: << File.expand_path(File.dirname(__FILE__))
require 'time'
require 'core_ext'

module Moniter
  module_function

  def notify_me
    yield
  end

  def build_schedule(&block)
    Schedule.new.tap do |schedule|
      schedule.instance_eval(&block)
    end
  end

  Iteration = Struct.new(:start_time, :end_time)

  class Schedule
    attr_reader :iterations

    def initialize
      @iterations = []
    end

    def iteration(options = {})
      start_time = Time.parse(options[:starts_at])
      end_time   = Time.parse(options[:ends_at])
      @iterations << Iteration.new(start_time, end_time)
    end

    def notify_when(options = {})

    end

    # Gimme some sugar, baby
    def each_iteration(&block)
      instance_eval(&block)
    end
  end


end
