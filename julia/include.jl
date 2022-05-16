#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# declare module game
module game

    include("./common/macros.jl")
    include("./common/random.jl")
    include("./logging.jl")
    include("./pretty_printing.jl")
    include("./common/player_input.jl")

    # declare module battle
    module battle
        using Main.game

        include("./battle/log.jl")
        include("./battle/stat_change.jl")
        include("./battle/status_ailment.jl")
        include("./battle/moves.jl")
        include("./battle/config/move_config.jl")
        include("./battle/battle_entity.jl")
    end

    include("../settings.jl")
end

using Main.game
using Main.game.battle

println("[LOG] initialization successfull")
return true
