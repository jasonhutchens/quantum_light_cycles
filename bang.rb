class Bang
    def initialize(screen, position, speed = 1)
        @screen, @position, @speed = screen, position, speed
        @colour = 0xFF
        @radius = @speed
    end
    def render
        return if invisible?
        @colour -= 23 * @speed
        @radius += @speed
        if @speed == 1
            @screen.circle(@position, @radius, [@colour, @colour, 0, 0x88])
        else
            @screen.circle(@position, @radius, [@colour, 0x44, 0x44, 0xCC])
        end
    end
    def erase
        @screen.circle(@position, @radius, [0, 0, 0])
    end
    def invisible?
        @colour < 23 * @speed
    end
end
