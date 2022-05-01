#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# declare module game
module game
using Main

    # declare module battle
    module battle
    using Main

        include("./battle/stat_change.jl")
        include("./battle/status_ailment.jl")
        include("./battle/battle_entity.jl")
    end
end

println("[LOG] initialization successfull")
return true
