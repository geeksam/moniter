require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

def at(time_string, &block)
  time = Time.parse(time_string)
  Timecop.freeze(time, &block)
end

describe Moniter do

  it "Can build a Schedule (slots in which are called timeslots)" do
    schedule = Moniter.build_schedule do
      iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
    end
    schedule.timeslots.length.should == 1
    schedule.timeslots.first.starts_at.should == '09:00 AM'
    schedule.timeslots.first.ends_at.should   == '10:00 AM'
  end

  describe Moniter::Schedule do
    it "knows about notifications" do
      schedule = Moniter.build_schedule do
        iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
        each_iteration do
          notify_when 15.minutes => :elapsed
          notify_when 15.minutes => :remain
        end
      end

      schedule.notifications.length.should == 2
      schedule.notifications.first.offset.should ==  15.minutes
      schedule.notifications.last .offset.should == -15.minutes
    end

    it "knows which timeslot currently applies" do
      schedule = Moniter.build_schedule do
        iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
      end
      at('8:59 AM')  { schedule.current_timeslot.should be_nil }
      at('09:00 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('09:23 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('10:00 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('10:01 AM') { schedule.current_timeslot.should be_nil }
    end
  end

  describe Moniter::Iteration do
    before(:each) do
      Timecop.freeze(Time.now)
      @schedule = Moniter.build_schedule do
        iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
        notify_when 15.minutes => :remain
      end
      @iteration = @schedule.iteration_for('09:00 AM')
    end
    after(:each) do
      Timecop.return
    end

    it "has a start and end time that match a timeslot" do
      @iteration.start_time.should == Time.parse('09:00 AM')
      @iteration.end_time.should   == Time.parse('10:00 AM')
    end

    it "has properly-timed alarms" do
      @iteration.alarm_times.first.should == Time.parse('09:45')
    end

    it "has the right start and end time even if the program is left running until the next day" do
      iteration = @schedule.iteration_for('09:00 AM')
      iteration.start_time.should == Time.parse('09:00 AM')
      iteration.end_time.should   == Time.parse('10:00 AM')
    end
  end

  describe "timer loop" do
    it "dispatches an alert if necessary, then sleeps"
  end

  describe "notifications" do
    it "should, like, call Kernel#exec or something, man, because that would be cool"
  end

end
