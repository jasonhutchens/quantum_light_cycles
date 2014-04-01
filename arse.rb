module Comparable
    def lock(min, max)
        return self if between?(min, max)
        return self < min ? min : max
    end
end

RATE = 32

module SplashScreen
    def SplashScreen.render(screen)
        arsepipe_music = Sound.new("resources/arsepipe.wav")
        arsepipe_image = Surface.load_new("resources/arsepipe.jpg")
        channel = arsepipe_music.play
        sleep 0.5
        fade = 1
        while fade > 0
            fade += channel.busy? ? RATE : -RATE
            fade = fade.lock(0, 255)
            arsepipe_image.set_alpha(fade)
            screen.fill([0, 0, 0])
            screen.blit(arsepipe_image, [0, 0], [30, 0, 480, 480])
            screen.flip
        end
        screen.fill([0, 0, 0])
        sleep 0.5
    end
end
