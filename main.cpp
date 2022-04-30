// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <jluna.hpp>
#include <SFML/Window.hpp>
#include <box2d/b2_api.h>

int main()
{
    jluna::initialize();
    jluna::Base["println"]("hello julia");

    return 0;
}

