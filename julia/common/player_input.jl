#
# Copyright 2022 Clemens Cords
# Created on 02.05.2022 by clem (mail@clemens-cords.com)
#

module keyboard

    # values are equal to sf::Keyboard::Key
    @enum Key begin
        UNKNOWN = Int64(-1)
        A = Int64(0)
        B
        C
        D
        E
        F
        G
        H
        I
        J
        K
        L
        M
        N
        O
        P
        Q
        R
        S
        T
        U
        V
        W
        X
        Y
        Z
        NUM_0
        NUM_1
        NUM_2
        NUM_3
        NUM_4
        NUM_5
        NUM_6
        NUM_7
        NUM_8
        NUM_9
        ESCAPE
        LEFT_CONTROL
        LEFT_SHIFT
        LEFT_ALT
        LEFT_SYSTEM
        RIGHT_CONTROL
        RIGHT_SHIFT
        RIGHT_ALT
        RIGHT_SYSTEM
        MENU
        LEFT_BRACKET
        RIGHT_BRACKET
        SEMICOLON
        COMMA
        PERIOD
        QUOTE
        SLASH
        BACKSLASH
        TILDE
        EQUAL
        HYPHEN
        SPACE
        ENTER
        BACKSPACE
        TAB
        PAGE_UP
        PAGE_DOWN
        END
        HOME
        INSERT
        DELETE
        PLUS
        MINUS
        ASTERISK
        LEFT_ARROW
        RIGHT_ARROW
        UP_ARROW
        DOWN_ARROW
        NUMPAD_0
        NUMPAD_1
        NUMPAD_2
        NUMPAD_3
        NUMPAD_4
        NUMPAD_5
        NUMPAD_6
        NUMPAD_7
        NUMPAD_8
        NUMPAD_9
        F1
        F2
        F3
        F4
        F5
        F6
        F7
        F8
        F9
        F10
        F11
        F12
        F13
        F14
        F15
        PAUSE
    end
    Main.game.@export_enum Key
end

