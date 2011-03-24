#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w[lib moniter])

# Here's the API I'd like to write against.

Moniter do  # Not sure I can get away with this unless I change the module name -- look up how Float and Float() keep from colliding
  to_notify_via :growl do |message|
    # command line for growl
  end
  to_notify_via :speech do |message|
    # command line for speech
  end

  iteration :starts_at => '09:00 AM', :ends_at => '10:30 AM'
  iteration :starts_at => '10:30 AM', :ends_at => '12:00 PM'
  iteration :starts_at => '01:00 PM', :ends_at => '02:30 PM'
  iteration :starts_at => '02:30 PM', :ends_at => '04:00 PM'
  iteration :starts_at => '04:00 PM', :ends_at => '05:30 PM'

  each_iteration do
    # Could also do:  notify_when 30.minutes => :elapsed, :via => [:growl]
    notify_when 60.minutes => :remain, :via => [:growl]
    notify_when 30.minutes => :remain, :via => [:growl]
    notify_when 15.minutes => :remain, :via => [:growl, :speech]
    notify_when  5.minutes => :remain, :via => [:growl, :speech]
    notify_when  2.minutes => :remain, :via => [:growl, :speech]
  end
end
