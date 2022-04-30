// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <jluna.hpp>
#include <SFML/Window.hpp>

int main()
{
    jluna::initialize();
    jluna::Base["println"]("hello julia");

    return 0;
}

