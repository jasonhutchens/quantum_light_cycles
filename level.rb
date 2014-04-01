require 'target'
require 'bang'

class Level
    attr_reader :level, :score, :total, :best, :changing
    @@walls = Array.new
    @@cells = Array.new
    def initialize(screen)
        @level = 1
        @total = 0
        @score = 0
        @best = 0
        @base = 8
        @screen = screen
        @cells = Array.new
        @changing = false
    end
    def Level.addLevel(walls, cells)
        @@walls << walls
        @@cells << cells
    end
    def each
        @cells.sort_by { rand }.each { |cell| yield cell }
    end
    def collect(item)
        @cells.delete_if { |cell| cell == item }
        @score += 3
        @changing = true if @cells.length == 0
    end
    def change
        return unless @changing
        @changing = false
        nextLevel
    end
    def over
        @best = @total if total > best
    end
    def reset
        @level = 1
        @base = 8
        @total = 0
        initLevel
    end
    def nextLevel
        @level += 1
        if @level > @@walls.length
            @level = 1
            @base -= 2 if @base > 4
        end
        @total += @score
        initLevel
    end
    def initLevel
        @score = @base
        @cells.clear
        @@cells[@level - 1].each do |cell|
            @cells << Target.new(@screen, cell)
        end
        @changing = false
    end
    def update(moved)
        @score -= 1 if moved and not @changing
    end
    def update_walls
        last = nil
        @@walls[@level - 1].each do |wall|
            if last and wall
                @screen.line(last, wall, [0, 0, 0])
                @screen.line(last, wall, [0, 0x66, 0xCC, 0x88])
            end
            last = wall
        end
    end
    def erase_cells
        @cells.each { |cell| cell.erase }
    end
    def render_cells
        @cells.each { |cell| cell.render }
    end
end

Level.addLevel([[50, 50], [150, 50], nil, [50, 150], [150, 150]],
               [[100, 165]])

Level.addLevel([[50, 50], [150, 50], nil,
                [50, 150], [150, 150], nil,
                [50, 50], [50, 150]],
               [[100, 20],
                [100, 180],
                [20, 100]])

Level.addLevel([[16, 16], [170, 16]],
               [[50, 8], [100, 8], [150, 8]])

Level.addLevel([[90, 50], [90, 190], [110, 190], [110, 50]],
               [[100, 180], [100, 20]])

Level.addLevel([[10, 10], [190, 10], [190, 190], [10, 190], [10, 20]],
               [[195, 5], [195, 195], [5, 195]])

Level.addLevel([[100, 10], [10, 100]],
               [[100, 10], [10, 100], [50, 50]])

Level.addLevel([[90, 70], [110, 70], nil,
                [90, 130], [110, 130], nil,
                [70, 90], [70, 110], nil,
                [130, 90], [130, 110], nil,
                [50, 50], [150, 50], [150, 150], [50, 150], [50, 50]],
               [[100, 60], [60, 100], [100, 140], [140, 100]])

Level.addLevel([[20, 20], [180, 20], [180, 180], [20, 180], [20, 20], nil,
                [50, 50], [50, 90], [90, 90], [90, 50], [50, 50], nil,
                [110, 50], [110, 90], [150, 90], [150, 50], [110, 50], nil,
                [50, 110], [50, 150], [90, 150], [90, 110], [50, 110], nil,
                [110, 110], [110, 150], [150, 150], [150, 110], [110, 110]],
               [[21, 21], [179, 179], [50, 150], [150, 50]])
