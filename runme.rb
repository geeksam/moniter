#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w[lib moniter])

def growl(subject, message, sticky = false)
  `growlnotify #{'-s' if sticky} -t "#{subject}" -m "#{message}"`
end

Moniter do
  clock_resolution 5.seconds

  to_notify_via :growl do |message|
    growl 'Iteration Timer', message
  end

  to_notify_via :speech do |message|
    `say "#{message}"`
  end

  to_notify_via :whats_next do |_|
    growl "What's Next?", "Wrap up, and consider what you'll do next iteration...", true
  end

  to_notify_via :harvest_reminder do |_|
    growl "Time Tracking", "Time to update Harvest!", true
  end

  workdays_are mon..fri

  iteration :starts_at => '09:00 AM', :ends_at => '10:30 AM'
  iteration :starts_at => '10:30 AM', :ends_at => '12:00 PM'
  iteration :starts_at => '01:00 PM', :ends_at => '02:30 PM'
  iteration :starts_at => '02:30 PM', :ends_at => '04:00 PM'
  iteration :starts_at => '04:00 PM', :ends_at => '05:30 PM'

  each_iteration do
    notify_at :start, :via => [:growl, :speech]

    notify_when 60.minutes => :remain, :via => [:growl]
    notify_when 30.minutes => :remain, :via => [:growl]
    notify_when 15.minutes => :remain, :via => [:growl]
    notify_when 10.minutes => :remain, :via => [:growl, :whats_next]
    notify_when  5.minutes => :remain, :via => [:growl, :speech, :harvest_reminder]

    notify_at :end, :via => [:growl, :speech, :harvest_reminder]
  end
end
