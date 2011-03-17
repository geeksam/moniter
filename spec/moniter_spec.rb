require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Moniter do

  it "has a notify_me method that takes a block and calls it...somewhere." do
    called = false
    Moniter.notify_me do
      called = true
    end
    called.should be_true
  end

  it "knows about iterations" do
    schedule = Moniter.build_schedule do
      iteration :starts_at => '09:00 AM', :ends_at => '10:30 AM'
    end
    schedule.iterations.length.should == 1
    schedule.iterations.first.start_time.should == Time.parse('09:00 AM')
    schedule.iterations.first.end_time.should   == Time.parse('10:30 AM')
  end

  it "knows about notifications" do
    schedule = Moniter.build_schedule do
      iteration :starts_at => '09:00 AM', :ends_at => '10:30 AM'
      each_iteration do
        notify_when 15.minutes => :remain
      end
    end

    schedule.notifications.length.should == 1
    schedule.notifications.first.offset.should == -15.minutes
  end

end
