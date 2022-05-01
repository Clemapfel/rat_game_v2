#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

abstract type AbstractEntity end

# declare battle entity, player or enemy participant
mutable struct Entity <: AbstractEntity

    name::String    # cleartext name
    id::String      # internal id

    base_stats::BaseStats

    hp::Integer
    ap::Integer

    attack_change::StatChange
    defense_change::StatChange
    speed_change::StatChange

    # status ailments
    status_state::StatusState

    is_enemy::Bool

    # default ctor
    function Entity(id::String)
        return new(
            id, id,
            BaseStats(100, 100, 50, 50, 50),
            100, 100,
            ZERO, ZERO, ZERO,
            StatusState(),
            false);
    end
end
@public Entity
