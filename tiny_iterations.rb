#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__), *%w[lib moniter])

Moniter do
  to_notify_via :growl do |message|
    `growlnotify -t "Iteration Timer" -m "#{message}"`
  end

  iteration :starts_at => Time.now.to_moniter_s, :ends_at => (Time.now + 1.minute).to_moniter_s

  each_iteration do
    clock_resolution 1.second
    notify_at :start, :via => [:growl]
    notify_when   5.seconds => :elapsed, :via => [:growl]
    notify_when  15.seconds => :elapsed, :via => [:growl]
    notify_when  30.seconds => :elapsed, :via => [:growl]
    notify_when  15.seconds => :remain,  :via => [:growl]
    notify_at :end, :via => [:growl]
  end
end
