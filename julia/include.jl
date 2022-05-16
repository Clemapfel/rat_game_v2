#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

__debug_enabled = true



# declare module game
include("./common/macros.jl")

@include("./common/logging.jl")
@include("./common/random.jl")
@include("./common/pretty_printing.jl")
@include("./common/player_input.jl")

# declare module battle
module battle
    using Main.game

    @include("./battle/log.jl")
    @include("./battle/stat_change.jl")
    @include("./battle/status_ailment.jl")
    @include("./battle/moves.jl")
    @include("./battle/config/move_config.jl")
    @include("./battle/battle_entity.jl")
end

@include("../settings.jl")

using Main.game
using Main.game.battle

Log.@log "initialization successfull"
return true
