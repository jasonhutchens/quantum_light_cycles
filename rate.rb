#!/usr/bin/env ruby

SIZE = 100

class Rate
    attr_reader :fps
    def initialize
        @times = Array.new
        @fps = 0.0
    end
    def reset
        @times.clear
    end
    def update(screen, maximum)
        calculate
#       screen.fill([0x66, 0x66, 0x44], [1, 1, 128, 8])
#       screen.print([1, 1], "#{@fps}", [0xCC, 0xCC, 0xFF, 0x88])
        throttle(maximum)
    end
    def calculate
        @times << Time.now
        @times.delete_at(0) while @times.length > SIZE
        return @fps = 0.0 if @times.length < 2 or @times.first == @times.last
        @fps = @times.length / (@times.last - @times.first) 
    end
    def throttle(desired)
        return if @times.length < 2
        elapsed = @times.at(-1) - @times.at(-2)
        delay = 1.0 / desired - elapsed
        sleep delay * 1.5 if delay > 0.0
    end
end

if __FILE__ == $0
    require 'test/unit'

    class Rate
        attr_reader :times
    end

    class TestRate < Test::Unit::TestCase
        def testRate
            rate = Rate.new(nil)
            SIZE.times do |count|
                assert_equal(rate.times.length, count)
                assert_equal(rate.update, 0.0) if count < 1
                assert_not_equal(rate.update, 0.0) if count > 0
                sleep 0.01
            end
            SIZE.times do
                assert_equal(rate.times.length, SIZE)
                assert_not_equal(rate.update, 0.0)
                sleep 0.01
            end
        end
    end
end
