// 
// Copyright 2022 Clemens Cords
// Created on 02.05.22 by clem (mail@clemens-cords.com)
//

#pragma once

#include <SFML/System.hpp>
#include <SFML/Window/Keyboard.hpp>
#include <SFML/Window/Window.hpp>

#include <map>

namespace game
{
    // key wrapper
    enum Key
    {
        A, B, X, Y,
        L, R,
        UP, DOWN, LEFT, RIGHT,
        START, SELECT,
        UNKNOWN
    };

    struct InputHandler
    {
        public:
            // update from render_window
            static void update(sf::Window&);

            // was key up last frame, down this frame
            static bool was_key_pressed(game::Key);

            // was key down last frame, up this frame
            static bool was_key_released(game::Key);

            // is key pressed this frame
            static bool is_key_down(game::Key);

            // is current frames state different from last frames
            static bool has_state_changed(game::Key);

            // how long has a key been held
            static sf::Time get_hold_duration(game::Key);

        private:
            static void load_button_mapping();

            static inline std::map<sf::Keyboard::Key, game::Key> _mapping = {};

            struct KeyState
            {
                bool down_last_frame;
                bool down_this_frame;
                sf::Time duration;

                KeyState()
                    : down_last_frame(false),
                      down_this_frame(false),
                      duration(sf::seconds(0))
                {}
            };

            static inline std::map<game::Key, KeyState> _state = {};
    };
}