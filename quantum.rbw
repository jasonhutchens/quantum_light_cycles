#!/usr/bin/env ruby

require 'rudl'
require 'rate'
require 'arse'
require 'game_loop'

include RUDL
include Constant

TITLE = "Quantum Light Cycles"

Mouse.visible = false
EventQueue.grab = true
Mixer.new(44100, 16, 2, 16384)
screen = DisplaySurface.new([480, 480], HWSURFACE, 32) # icon?
screen.set_caption(TITLE)

SplashScreen.render(screen)

game_loop = GameLoop.new(screen)

rate = Rate.new

EventQueue.flush

begin
    event = EventQueue.poll
    key = (event and event.is_a?(KeyDownEvent)) ? event.key : nil
    game_loop.update(key)
    rate.update(screen, 50)
    screen.flip
rescue => except
    puts except
    exit
end until game_loop.done

screen.destroy
