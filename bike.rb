require 'bang'
require 'target'

NORTH, SOUTH, EAST, WEST = 1, 2, 3, 4

$bang = Array.new
$poss = Array.new

class Photon
    attr_reader :x, :y, :direction
    @@okay = nil
    def initialize(screen, x, y, direction)
        @screen, @x, @y, @direction = screen, x, y, direction
        @crashed = false
    end
    def update(speed = 1)
        case @direction
            when NORTH: @y -= speed
            when SOUTH: @y += speed
            when EAST: @x += speed
            when WEST: @x -= speed
        end
    end
    def collide
        return if @crashed
        @@okay = @screen[@x, @y] unless @@okay
        @crashed |= @screen[@x, @y] != @@okay
        crash if @crashed
    end
    def crashed?
        @crashed
    end
    def crash(photon = nil)
        return if photon and photon == self
        @crashed = true
        $bang << Bang.new(@screen, [@x, @y])
    end
    def collect(position)
        (@x - position[0]) ** 2 + (@y - position[1]) ** 2 < 10
    end
end

class Node
    attr_reader :x, :y
    def initialize(screen, x, y)
        @screen, @x, @y = screen, x, y
        @nodes = Array.new
        @photons = Array.new
    end
    def addPhoton(direction)
        @photons << Photon.new(@screen, @x, @y, direction)
    end
    def update(speed = 1)
        @photons.each { |photon| photon.update(speed) }
        @nodes.each { |node| node.update(speed) }
    end
    def turn
        @nodes.each { |node| node.turn }
        @photons.each do |photon|
            next if photon.crashed?
            node = Node.new(@screen, photon.x, photon.y)
            case photon.direction
                when NORTH, SOUTH
                    node.addPhoton(EAST)
                    node.addPhoton(WEST)
                when EAST, WEST
                    node.addPhoton(NORTH)
                    node.addPhoton(SOUTH)
            end
            @nodes << node
        end
        @photons.clear
    end
    def collide
        @photons.each { |photon| photon.collide }
        @nodes.each { |node| node.collide }
    end
    def collect(position)
        @photons.each { |photon| $poss << photon if photon.collect(position) }
        @nodes.each { |node| node.collect(position) }
    end
    def crashed?
        @photons.all? { |photon| photon.crashed? } and
        @nodes.all? { |node| node.crashed? }
    end
    def crash(item = nil)
        @photons.each { |photon| photon.crash(item) }
        @nodes.each { |node| node.crash(item) }
    end
    def render
        @nodes.each do |node|
            @screen.line([@x, @y], [node.x, node.y], [0xFF, 0, 0, 0x88])
            node.render
        end
        @photons.each do |photon|
            @screen.line([@x, @y], [photon.x, photon.y], [0xFF, 0, 0, 0xAA])
            @screen.plot([photon.x, photon.y], [0xFF, 0x88, 0xAA, 0x88])
        end
    end
    def erase
        @nodes.each do |node|
            node.erase
            @screen.line([@x, @y], [node.x, node.y], [0, 0, 0])
        end
        @photons.each do |photon|
            @screen.line([@x, @y], [photon.x, photon.y], [0, 0, 0])
        end
        @photons.delete_if { |photon| photon.crashed? }
        @nodes.delete_if { |node| node.crashed? }
    end
end

class Bike
    def initialize(screen)
        @screen = screen
        @node = Node.new(screen, screen.w / 2, screen.h / 2)
        @node.addPhoton(NORTH)
        @node.addPhoton(SOUTH)
        @node.addPhoton(EAST)
        @node.addPhoton(WEST)
    end
    def update(moved)
        @node.erase
        $bang.each { |bang| bang.erase }
        $bang.delete_if { |bang| bang.invisible? }
        @node.turn if moved
        @node.update(1)
        @node.render
        @node.collide
        $bang.each { |bang| bang.render }
        @node.crashed? and $bang.length == 0
    end
    def crash
        @node.crash
    end
    def crashed?
        $bang.length == 0
    end
    def collect(item)
        @node.collect(item.position)
        return false if $poss.length == 0
        $bang << Bang.new(@screen, item.position, 2)
        $bang << Bang.new(@screen, item.position, 3)
        $bang << Bang.new(@screen, item.position, 4)
        $bang << Bang.new(@screen, item.position, 5)
        $bang << Bang.new(@screen, item.position, 6)
        @node.crash($poss[rand($poss.length)])
        $poss.clear
        true 
    end
end
