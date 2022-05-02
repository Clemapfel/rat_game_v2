// 
// Copyright 2022 Clemens Cords
// Created on 02.05.22 by clem (mail@clemens-cords.com)
//

#pragma once

#include <SFML/Window.hpp>

#include <memory>

namespace game
{
    namespace window_config
    {
        static inline uint32_t style = sf::Style::None;
        static inline sf::VideoMode video_mode;
        static inline sf::ContextSettings context_settings;

        static inline size_t fps_limit = 60;
        static inline sf::Time frame_duration;
        static inline bool vsync_enabled;
    }
}