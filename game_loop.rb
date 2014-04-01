require 'arena'

class GameLoop
    attr_reader :done
    def initialize(screen)
        @done = false
        @arena = Arena.new(screen)
        @arena.update(false)
        screen.flip
        sleep 0.6
    end
    def update(key)
        case @arena.mode
            when ATTRACT
                if key == K_SPACE
                    @arena.mode = PLAYING
                    @arena.reset
                end
                @done = key == K_ESCAPE
                key = nil
            when PLAYING
                @arena.mode = ATTRACT if key == K_ESCAPE
            when GAMEOVER
                @arena.mode = ATTRACT if key == K_ESCAPE or key == K_SPACE
                key = nil
        end
        @arena.update(key == K_SPACE)
    end
end
