#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

abstract type AbstractEntity end

# declare battle entity, player or enemy participant
mutable struct Entity <: AbstractEntity

    name::String    # cleartext name
    id::String      # internal id

    hp_base::Integer
    ap_base::Integer

    attack_base::Integer
    defense_base::Integer
    speed_base::Integer

    attack_change::StatChange
    defense_change::StatChange
    speed_change::StatChange

    status::StatusAilment
    status_stat_change::StatChange
    status_turn_effect::Function

    is_enemy::Bool
end