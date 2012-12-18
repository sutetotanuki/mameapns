module Mameapns
  class InterruptibleSleep
    def wait(seconds)
      @l, @r = IO.pipe
      IO.select([@l], nil, nil, @seconds)
      @l.close rescue IOError
      @r.close rescue IOError
    end

    def interrupt
      if @r
        @r.close rescue IOError
      end
    end
  end
end
