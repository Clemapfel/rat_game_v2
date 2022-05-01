#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# inline included file
macro include(file_name::String)
    return open(file_name, "r") do io
        file = @__FILE__
        return file * "/" * String(read(io))
    end
end
export include

# include pragma once
macro include_once(file_name::String)
    if !isdefined(__module__, :__include_once)
        Base.eval(__module__, :(__include_once = Set{String}()))
    end

    if file_name in __module__.__include_once
        println("already")
        return :()
    else
        push!(__module__.__include_once, file_name)
        return :(@include($file_name))
    end
end
export include_once

# declare module game
module game
using Main

    # declare module battle
    module battle
    using Main

        @include("./battle/stat_change.jl")
        @include("./battle/status_ailment.jl")
        @include("./battle/battle_entity.jl")
    end
end

println("[LOG] initialization successfull")
return true
