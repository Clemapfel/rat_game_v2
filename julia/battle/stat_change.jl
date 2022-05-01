#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

abstract type AbstractEntity end

# declare base stat
struct BaseStats

    hp_base::Int64
    ap_base::Int64

    attack_base::Int64
    defense_base::Int64
    speed_base::Int64
end
@public BaseStats

# declare possible stat changes
@enum StatChange begin

    PLUS_4 = 4
    PLUS_3 = 3
    PLUS_2 = 2
    PLUS_1 = 1
    ZERO = 0
    MINUS_1 = -1
    MINUS_2 = -2
    MINUS_3 = -3
    MINUS_4 = -4
end
@export_enum StatChange

# convert enum to factor applied to stat
function stat_change_to_factor(s::StatChange) ::Float32

    if s == PLUS_4
        return 3.0
    elseif s == PLUS_3
        return 2.5
    elseif s == PLUS_2
        return 2.0
    elseif s == PLUS_1
        return 1.5
    elseif s == ZERO
        return 1.0
    elseif s == MINUS_1
        return 0.75
    elseif s == MINUS_2
        return 0.5
    elseif s == MINUS_3
        return 0.25
    elseif s == MINUS_4
        return 0.0 # decay after 1 turn to -3
    end
end
@public stat_change_to_factor

# add +1 to stat change
function raise(s::StatChange) ::StatChange

    value = Int64(s) + 1
    value = min(value, 4)
    return StatChange(value)
end
@public raise

# add -1 to stat change
function lower(s::StatChange) ::StatChange

    value = Int64(s) - 1
    value = max(value, -4)
    return StatChange(value)
end
@public lower

# add +1 to given stat
raise_attack!(e::AbstractEntity) = e.attack_change = raise(e.attack_change)
raise_defense!(e::AbstractEntity) = e.defense_change = raise(e.defense_change)
raise_speed!(e::AbstractEntity) = e.speed_change = raise(e.speed_change)
@public(raise_attack!, raise_defense!, raise_speed!)

# add -1 to given stat
lower_attack!(e::AbstractEntity) = e.attack_change = lower(e.attack_change)
lower_defense!(e::AbstractEntity) = e.defense_change = lower(e.defense_change)
lower_speed!(e::AbstractEntity) = e.speed_change = lower(e.speed_change)
@public(lower_attack!, lower_defense!, lower_speed!)
