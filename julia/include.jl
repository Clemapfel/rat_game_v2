#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# incline included file
macro include(file_name::String)
    return open(file_name, "r") do io
        return String(read(io))
    end
end
export include

# declare module game
module game

    # declare module battle
    module battle
        @include("status_ailment.jl")
    end
end

println("[LOG] initialization successfull");
