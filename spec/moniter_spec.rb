require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

def at(time_string, &block)
  time = Time.parse(time_string)
  Timecop.freeze(time, &block)
end

describe Moniter do
  before(:each) do
    @foo_notifier = foo_notifier = mock('foo notifier')
    @bar_notifier = bar_notifier = mock('bar notifier')
    @baz_notifier = baz_notifier = mock('baz notifier')
    @schedule = Moniter.build_schedule do
      clock_resolution 1.minute

      to_notify_via(:foo) { |message| foo_notifier.spiffy(message) }
      to_notify_via(:bar) { |message| bar_notifier.spiffy(message) }
      to_notify_via(:baz) { |message| baz_notifier.spiffy(message) }

      iteration :starts_at => '09:00 AM', :ends_at => '10:00 AM'

      notify_at :start, :via => :foo                            # m1
      notify_when 10.minutes => :elapsed, :via => :bar          # m2
      notify_when 15.minutes => :remain, :via => [:foo, :bar]   # m3
      notify_at :end, :via => :baz                              # m4
    end
  end

  describe Moniter::Schedule do
    it "has a resolution" do
      @schedule.sleep_interval.should == 1.minute
    end

    it "has timeslots" do
      @schedule.timeslots.length.should == 1
      @schedule.timeslots.first.starts_at.should == '09:00 AM'
      @schedule.timeslots.first.ends_at.should   == '10:00 AM'
    end

    it "knows about milestones" do
      @schedule.milestones.length.should == 4
      m1, m2, m3, m4 = *@schedule.milestones

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

    describe "named milestone callbacks" do
      it "calls the 'iteration started' notification when the iteration starts" do
        at '09:00 AM' do
          @foo_notifier.should_receive(:spiffy).with('Iteration started')
          @schedule.tick
        end
      end

      it "calls the 'iteration started' notification if it's still around a few minutes later" do
        at '09:03 AM' do
          @foo_notifier.should_receive(:spiffy).with('Iteration started')
          @schedule.tick
        end
      end

      it "calls the '10 minutes elapsed' notification when 10 minutes have elapsed" do
        at '09:10 AM' do
          @bar_notifier.should_receive(:spiffy).with('10 minutes elapsed')
          @schedule.tick
        end
      end

      it "calls the '10 minutes elapsed' notification when 11 minutes have elapsed" do
        at '09:11 AM' do
          @bar_notifier.should_receive(:spiffy).with('11 minutes elapsed')
          @schedule.tick
        end
      end

      it "calls the '15 minutes remaining' notification when 15 minutes remain" do
        at '09:45 AM' do
          @foo_notifier.should_receive(:spiffy).with('15 minutes remaining')
          @bar_notifier.should_receive(:spiffy).with('15 minutes remaining')
          @schedule.tick
        end
      end

      it "calls the '15 minutes remaining' notification when 13 minutes remain" do
        at '09:47 AM' do
          @foo_notifier.should_receive(:spiffy).with('13 minutes remaining')
          @bar_notifier.should_receive(:spiffy).with('13 minutes remaining')
          @schedule.tick
        end
      end

      it "calls the 'iteration finished' notification when 0 minutes remain" do
        at('09:00 AM') do
          @foo_notifier.should_receive(:spiffy).with('Iteration started')
          @schedule.tick
        end

        at '10:00 AM' do
          @baz_notifier.should_receive(:spiffy).with('Iteration complete')
          @schedule.tick
        end
      end

      it "calls all of the notifications, in order, at appropriate times" do
        at '09:00 AM' do
          @foo_notifier.should_receive(:spiffy).with('Iteration started')
          @schedule.tick
        end

        at '09:10 AM' do
          @bar_notifier.should_receive(:spiffy).with('10 minutes elapsed')
          @schedule.tick
        end

        at '09:45 AM' do
          @foo_notifier.should_receive(:spiffy).with('15 minutes remaining')
          @bar_notifier.should_receive(:spiffy).with('15 minutes remaining')
          @schedule.tick
        end

        at '10:00 AM' do
          @baz_notifier.should_receive(:spiffy).with('Iteration complete')
          @schedule.tick
        end
      end
    end
  end

  describe Moniter::Iteration do
    before(:each) do
      @iteration = @schedule.iteration_for('09:00 AM')
      @n1, @n2, @n3, @n4 = *@iteration.notifications
    end

    it "has a start and end time that match a timeslot" do
      @iteration.start_time.should == Time.parse('09:00 AM')
      @iteration.end_time.should   == Time.parse('10:00 AM')
    end

    it "has properly-timed notifications" do
      @iteration.notifications.length.should == 4
      @n1.time.should == Time.parse('09:00')
      @n2.time.should == Time.parse('09:10')
      @n3.time.should == Time.parse('09:45')
      @n4.time.should == Time.parse('10:00')
    end

    it "has the right start and end time even if the program is left running until the next day" do
      Timecop.freeze(Time.now + 1.day)
      iteration = @schedule.iteration_for('09:00 AM')
      iteration.start_time.should == Time.parse('09:00 AM')
      iteration.end_time.should   == Time.parse('10:00 AM')

      @n1.time.should == Time.parse('09:00')
      @n2.time.should == Time.parse('09:10')
      @n3.time.should == Time.parse('09:45')
      @n4.time.should == Time.parse('10:00')
    end
  end

end
