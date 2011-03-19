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
        notify_at :start, :via => :foo                            # n1
        notify_when 10.minutes => :elapsed, :via => :bar          # n2
        notify_when 15.minutes => :remain, :via => [:foo, :bar]   # n3
        notify_at :end, :via => :baz                              # n4
      end

      schedule.notifications.length.should == 4
      n1, n2, n3, n4 = *schedule.notifications

      n1.anchor.should == :start
      n2.anchor.should == :start
      n3.anchor.should == :end
      n4.anchor.should == :end

      n1.offset.should be_zero
      n2.offset.should ==  10.minutes
      n3.offset.should == -15.minutes
      n4.offset.should be_zero

      n1.alert_methods.should == [:foo]
      n2.alert_methods.should == [:bar]
      n3.alert_methods.should == [:foo, :bar]
      n4.alert_methods.should == [:baz]
    end

    it "knows which timeslot currently applies" do
      schedule = Moniter.build_schedule do
        iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
      end

      at('08:59 AM')  { schedule.current_timeslot.should be_nil }
      at('09:00 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('09:23 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('10:00 AM') { schedule.current_timeslot.should be_nil }
      at('10:01 AM') { schedule.current_timeslot.should be_nil }
    end

    it "should be able to accept named notification callbacks and call them when appropriate"
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
      iteration.alarm_times.first.should == Time.parse('09:45')
    end
  end

  it "should wrap everything up in a Moniter function that sets up a schedule, then enters a notify-and-sleep loop"

end
