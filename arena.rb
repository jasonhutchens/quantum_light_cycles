require 'bike'
require 'level'

ATTRACT, PLAYING, GAMEOVER = 1, 2, 3

class Arena
    attr_accessor :mode
    def initialize(screen)
        @screen = screen
        @bitmap = Surface.new([200, 200])
        @bitmap.convert!
        @font = TrueTypeFont.new("resources/arsepipe.ttf", 32)
        music = Music.new("resources/arsepipe.mod")
        music.play(-1)
        music.volume = 0.5
        self.mode = ATTRACT
        @moved = false
        @bike = nil
        @level = Level.new(@bitmap)
        @clear = false
        @count = -1
        @sleep = false
    end
    def reset
        @level.reset
        @count = -1
    end
    def update(moved)
        @moved = moved
        @bitmap.fill([0, 00, 0]) if @clear
        @sleep = true if @clear
        @clear = false
        case @mode
            when ATTRACT: attract
            when PLAYING: play
            when GAMEOVER: gameOver
        end
        render
        @screen.flip if @sleep
        sleep 0.8 if @sleep
        @sleep = false
    end
    def mode=(mode)
        @mode = mode
        @screen.fill([0, 0x34, 0])
        @bitmap.fill([0, 0, 0])
        case @mode
            when ATTRACT
                @bike = nil
            when PLAYING
                @bike = Bike.new(@bitmap)
                @count = -1
            when GAMEOVER
                @bike = Bike.new(@bitmap)
                @level.over
        end
        bitmap = @font.render("Quantum Light Cycles", true, [0, 0xFF, 0])
        @screen.blit(bitmap, [240 - bitmap.w / 2, 20 - bitmap.h / 2])
        bitmap = @font.render("by Jason Hutchens", true, [0, 0xCC, 0])
        @screen.blit(bitmap, [240 - bitmap.w / 2, 420 + bitmap.h / 2])
        @screen.rectangle([39, 39, 402, 402], [0, 0xFF, 0, 0x88])
    end
    def render
        @bitmap.rectangle([0, 0, 200, 200], [0, 0, 0])
        @bitmap.rectangle([0, 0, 200, 200], [0, 0x40, 0])
        @screen.blit(@bitmap.zoom(2.0, 2.0, true), [40, 40])
        case @mode
            when ATTRACT
                message = "Q.L.C."
                bitmap = @font.render(message, true, [0xCC, 0xCC, 0xCC])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 160 - bitmap.h / 2])
                message = "SPACE to play"
                bitmap = @font.render(message, true, [0x88, 0x88, 0x88])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 280 - bitmap.h / 2])
                message = "ESCAPE to exit"
                bitmap = @font.render(message, true, [0x66, 0x66, 0x66])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 320 - bitmap.h / 2])
            when PLAYING
                message = "LEVEL #{@level.level}"
                bitmap = @font.render(message, false, [0x88, 0xFF, 0])
                bitmap.set_alpha(0x30)
                @screen.blit(bitmap, [240 - bitmap.w / 2, 200 - bitmap.h / 2])
                if @level.changing
                message = "LEVEL UP!"
                bitmap = @font.render(message, true, [0, 0xFF, 0])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 240 - bitmap.h / 2])
                else
                message = "SCORE - #{@level.score}"
                bitmap = @font.render(message, false, [0, 0xFF, 0])
                bitmap.set_alpha(0x30)
                @screen.blit(bitmap, [240 - bitmap.w / 2, 240 - bitmap.h / 2])
                end
                message = "TOTAL - #{@level.total}"
                bitmap = @font.render(message, false, [0, 0xFF, 0x88])
                bitmap.set_alpha(0x30)
                @screen.blit(bitmap, [240 - bitmap.w / 2, 280 - bitmap.h / 2])
                @screen.fill([0, 0x20, 0], [455, 40, 10, 400])
                (0...@level.score).each do |item|
                    break if item >= 50
                    @screen.circle([460, 435 - item * 8], 2,
                                   [0xFF, 0xFF, 0x00, 0x88])
                end
            when GAMEOVER
                bitmap = @font.render("GAME OVER", true, [0xCC, 0xCC, 0xCC])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 160 - bitmap.h / 2])
                message = "TOTAL - #{@level.total}"
                bitmap = @font.render(message, true, [0x88, 0x88, 0x88])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 280 - bitmap.h / 2])
                message = "BEST - #{@level.best}"
                bitmap = @font.render(message, true, [0x66, 0x66, 0x66])
                @screen.blit(bitmap, [240 - bitmap.w / 2, 320 - bitmap.h / 2])
        end
    end
    def attract
    end
    def play
        @level.erase_cells
        @level.update_walls
        @level.update(@moved)
        @bike.crash if @level.score < 0
        @moved = false if @level.changing and @count < 10
        crashed = @bike.update(@moved)
        old_level = @level.level
        @level.each do |cell|
            if @bike.collect(cell)
                @level.collect(cell)
                break
            end
        end
        @count = 40 if @level.changing and @count == -1
        @bike.crash if @count == 10
        @count -= 1 if @count > 0
        if @level.changing and @count == 0 and @bike.crashed?
            @count = -1
            @bike = Bike.new(@bitmap)
            @clear = true
            @level.change
            return
        end
        @level.render_cells
        self.mode = GAMEOVER if crashed and not @level.changing
    end
    def gameOver
    end
end
