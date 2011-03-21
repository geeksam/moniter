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
    it "knows about milestones" do
      schedule = Moniter.build_schedule do
        notify_at :start, :via => :foo                            # m1
        notify_when 10.minutes => :elapsed, :via => :bar          # m2
        notify_when 15.minutes => :remain, :via => [:foo, :bar]   # m3
        notify_at :end, :via => :baz                              # m4
      end

      schedule.milestones.length.should == 4
      m1, m2, m3, m4 = *schedule.milestones

      m1.anchor.should == :start
      m2.anchor.should == :start
      m3.anchor.should == :end
      m4.anchor.should == :end

      m1.offset.should be_zero
      m2.offset.should ==  10.minutes
      m3.offset.should == -15.minutes
      m4.offset.should be_zero

      m1.alert_methods.should == [:foo]
      m2.alert_methods.should == [:bar]
      m3.alert_methods.should == [:foo, :bar]
      m4.alert_methods.should == [:baz]
    end

    it "knows which timeslot currently applies" do
      schedule = Moniter.build_schedule do
        iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'
      end

      at('08:59 AM') { schedule.current_timeslot.should be_nil }
      at('09:00 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('09:23 AM') { schedule.current_timeslot.should == schedule.timeslots.first }
      at('10:00 AM') { schedule.current_timeslot.should be_nil }
      at('10:01 AM') { schedule.current_timeslot.should be_nil }
    end

    it "should be able to accept named milestone callbacks and call them when appropriate"
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

    it "has properly-timed notifications" do
      @iteration.notifications.first.time.should == Time.parse('09:45')
    end

    it "has the right start and end time even if the program is left running until the next day" do
      iteration = @schedule.iteration_for('09:00 AM')
      iteration.start_time.should == Time.parse('09:00 AM')
      iteration.end_time.should   == Time.parse('10:00 AM')
      iteration.notifications.first.time.should == Time.parse('09:45')
    end
  end

  it "should wrap everything up in a Moniter function that sets up a schedule, then enters a notify-and-sleep loop"

end
