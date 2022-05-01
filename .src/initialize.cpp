// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <initialize.hpp>
#include <jluna.hpp>
#include <resource_path.hpp>

namespace game
{
    void initialize()
    {
        jluna::initialize();
        jluna::safe_eval_file(game::JULIA_INCLUDE_PATH + "/include.jl");
    }
}

