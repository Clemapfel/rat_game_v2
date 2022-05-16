#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

__debug_enabled = true

include("./common/logging.jl")
include("./common/macros.jl")

@include("./common/random.jl")
@include("./common/pretty_printing.jl")
@include("./common/player_input.jl")

# declare module battle
module battle
    using Main

    @include("./battle/log.jl")
    @include("./battle/stat_change.jl")
    @include("./battle/status_ailment.jl")
    @include("./battle/moves.jl")
    @include("./battle/config/move_config.jl")
    @include("./battle/battle_entity.jl")
end

@include("../settings.jl")

@once Log.@log "initialization successfull"
return true