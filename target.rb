class Target
    attr_reader :position
    def initialize(screen, position)
        @screen, @position = screen, position
    end
    def update
        erase
        render
    end
    def render
        @screen.circle(@position, 3, [0xFF, 0xFF, 0])
        @screen.filled_circle(@position, 1, [0xFF, 0xFF, 0])
    end
    def erase
        @screen.filled_circle(@position, 4, [0, 0, 0])
    end
end
