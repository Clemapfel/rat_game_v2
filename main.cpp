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
    auto _ = {[]{}()};

    auto window = sf::Window();
    game::initialize(window);

    while (window.isOpen())
    {
        InputHandler::update(window);
        window.display();

        if (InputHandler::was_key_pressed(Key::A))
            std::cout << "A" << std::endl;
    }

    return 0;
}

