// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <jluna.hpp>
#include <SFML/Window.hpp>
#include <box2d/b2_api.h>
#include <resource_path.hpp>

#include <initialize.hpp>

#include <SFML/Window.hpp>
#include <render_window.hpp>
#include <input_handler.hpp>

using namespace game;

int main()
{
    game::initialize();

    auto window = sf::Window(
        sf::VideoMode(500, 500),//window_config::video_mode,
        "rat_game_debug",
        sf::Style::None | sf::Style::Titlebar,
        window_config::context_settings
    );
    window.setFramerateLimit(window_config::fps_limit);
    window.setVerticalSyncEnabled(window_config::vsync_enabled);

    while (window.isOpen())
    {
        InputHandler::update(window);
        window.display();
    }

    return 0;
}

