// 
// Copyright 2022 Clemens Cords
// Created on 01.05.22 by clem (mail@clemens-cords.com)
//

#include <jluna.hpp>
#include <resource_path.hpp>

int main()
{
    jluna::initialize(1, false);
    return not jluna::unbox<bool>(
        jluna::safe_eval_file(game::JULIA_INCLUDE_PATH + "/test.jl")
    );
}
