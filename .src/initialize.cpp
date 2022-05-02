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
    void initialize(sf::Window& render_window)
    {
        using namespace jluna;
        jluna::initialize();
        safe_eval_file(game::JULIA_INCLUDE_PATH + "/include.jl");

        Module settings = Main["game"]["settings"];

        auto video_mode = sf::VideoMode(
                (size_t) settings["video"]["screenwidth"],
                (size_t) settings["video"]["screenheight"]
        );

        auto context_settings = sf::ContextSettings();
        context_settings.antialiasingLevel = (size_t) settings["video"]["anti_aliasing_level"];
        context_settings.majorVersion = 3;
        context_settings.minorVersion = 4;

        Int32 window_style = sf::Style::None;

        if ((bool) settings["video"]["fullscreen"])
            window_style |= sf::Style::Fullscreen;
        else
            window_style |= sf::Style::Titlebar;

        window_style |= sf::Style::Close;

        render_window.create(
            video_mode,
            "rat_game_debug",
            window_style,
            context_settings
        );

        size_t fps_limit = settings["video"]["fps_limit"];
        window_config::fps_limit = fps_limit;
        window_config::frame_duration = sf::seconds(1 / float(fps_limit));

        render_window.setFramerateLimit(fps_limit);
        render_window.setVerticalSyncEnabled(settings["video"]["vsync_enabled"]);
    }
}

