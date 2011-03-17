require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe Moniter do

  it "has a notify_me method that takes a block and calls it...somewhere." do
    pending "some justification for this method to actually exist"
    called = false
    Moniter.notify_me do
      called = true
    end
    called.should be_true
  end

  it "knows the iteration schedule (slots in which are called timeboxes)" do
    schedule = Moniter.build_schedule do
      iteration :starts_at => '09:00 AM', :ends_at => '10:30 AM'
    end
    schedule.timeboxes.length.should == 1
    schedule.timeboxes.first.start_time.should == Time.parse('09:00 AM')
    schedule.timeboxes.first.end_time.should   == Time.parse('10:30 AM')
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

  it "can produce an iteration for the currently-applicable timebox (will require Timecop to test)"
  describe "Iteration" do
    it "has a start and end time that match a timebox"
    it "has properly-timed notifications"
    it "has the right start and end time even if the program is left running until the next day"
  end

end
