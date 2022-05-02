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

using namespace game;

int main()
{
    initialize();

    while (true)
    {
        render_window.display();
        render_window.close();
    }

    return 0;
}

