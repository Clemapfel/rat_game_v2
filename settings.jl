#
# Copyright 2022 Clemens Cords
# Created on 02.05.2022 by clem (mail@clemens-cords.com)
#

module settings

    # window settings
    module video

        screenwidth = 1280 #1920
        screenheight = 720 #1080
        fullscreen = false

        anti_aliasing_level = 16
        fps_limit = 120
        vsync_enabled = true
    end

    # bindings when using keyboard
    module keyboard_bindings
        using Main.keyboard
        # see rat_game/julia/common/player_input.jl for key codes

        A = keyboard.SPACE
        B = keyboard.B
        X = keyboard.X
        Y = keyboard.Y
        L = keyboard.L
        R = keyboard.R
        START = keyboard.RIGHT_BRACKET  # plus on german keyboard
        SELECT = keyboard.HYPHEN    # minus on german keyboard

        UP = keyboard.UP_ARROW
        DOWN = keyboard.DOWN_ARROW
        LEFT = keyboard.LEFT_ARROW
        RIGHT = keyboard.RIGHT_ARROW
    end

    # bindings when using controller
    module controller_bindings
        
        A = "CONTROLLER_1"
        B = "CONTROLLER_0"
        X = "CONTROLLER_3"
        Y = "CONTROLLER_2"
        L = "CONTROLLER_4"
        R = "CONTROLLER_5"
        START = "CONTROLLER_7"
        SELECT = "CONTROLLER_6"

        # directions mapped to axis
    end
end
