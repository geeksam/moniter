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

  Timebox = Struct.new(:start_time, :end_time)
  Notification = Struct.new(:anchor, :interval) do
    def offset
      multiplier = (:remain == anchor ? -1 : 1)
      interval * multiplier
    end
  end

  class Schedule
    attr_reader :timeboxes, :notifications

    def initialize
      @timeboxes = []
      @notifications = []
    end

    def iteration(options = {})
      timeboxes << Timebox.new(options[:starts_at], options[:ends_at])
    end

    def notify_when(options = {})
      options = options.invert
      notifications << Notification.new(:remain, options[:remain]) if options[:remain]
    end

    # Gimme some sugar, baby
    def each_iteration(&block)
      instance_eval(&block)
    end

    def current_iteration
    end
  end


end
