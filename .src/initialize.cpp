// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <initialize.hpp>
#include <jluna.hpp>
#include <resource_path.hpp>
#include <render_window.hpp>

namespace game
{
    void initialize()
    {
        using namespace jluna;
        jluna::initialize();

        safe_eval_file(game::SETTINGS_FILE_LOCATION);
        Module settings = Main["settings"];

        window_config::video_mode = sf::VideoMode(
                (size_t) settings["video"]["screenwidth"],
                (size_t) settings["video"]["screenheight"]
        );

        window_config::context_settings = sf::ContextSettings();
        window_config::context_settings.antialiasingLevel = (size_t) settings["video"]["anti_aliasing_level"];
        window_config::context_settings.majorVersion = 3;
        window_config::context_settings.minorVersion = 4;

        if ((bool) settings["video"]["fullscreen"])
            window_config::style = sf::Style::None | sf::Style::Fullscreen;
        else
            window_config::style = sf::Style::None | sf::Style::Titlebar | sf::Style::Close;

        size_t fps_limit = settings["video"]["fps_limit"];
        window_config::fps_limit = fps_limit;
        window_config::frame_duration = sf::seconds(1 / float(fps_limit));

        safe_eval_file(game::JULIA_INCLUDE_PATH + "/include.jl");
    }
}

