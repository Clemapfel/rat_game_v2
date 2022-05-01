#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

abstract type AbstractEntity end

# moveset type, dict of mover + number of stacks left (-1 for infinite)
@alias Moveset Dict{String, Pair{Move, Int64}}

# declare battle entity, player or enemy
mutable struct Entity <: AbstractEntity

    id::String      # internal id
    name::String    # cleartext name
    is_enemy::Bool  # is party

    # stats
    base_stats::BaseStats

    hp::Integer
    ap::Integer

    # changes
    attack_change::StatChange
    defense_change::StatChange
    speed_change::StatChange

    # primed type
    primed::ComboType

    # status ailments
    status_state::StatusState

    # moveset and stacks
    moveset::Moveset

    # default ctor for debugging
    function Entity(id::String)

        base = BaseStats(100, 100, 50, 50, 50)
        return new(
            id, id, false,
            base,
            base.hp, base.ap,
            ZERO, ZERO, ZERO, NO_TYPE,
            StatusState(), Moveset());
    end

    # ctor
    function Entity(;
        name::String,
        id::String,
        is_enemy::Bool,
        hp_base::Integer,
        ap_base::Integer,
        attack_base::Integer,
        defense_base::Integer,
        speed_base::Integer)

        return new(id, name, is_enemy,
            BaseStats(hp_base, ap_base, attack_base, defense_base, speed_base),
            ZERO, ZERO, ZERO, NO_TYPE,
            StatusState(), Moveset())
    end
end
@public Entity

### GETTER ###

# hp
function get_hp_base(e::AbstractEntity) ::Int64
    return e.base_stats.hp
end
@public get_hp_base

function get_hp(e::AbstractEntity) ::Int64
    return e.hp
end
@public get_hp

# ap
function get_ap_base(e::AbstractEntity) ::Int64
    return e.base_stats.ap
end
@public get_ap_base

function get_ap(e::AbstractEntity) ::Int64
    return e.ap
end
@public get_ap

# attack
function get_attack_base(e::AbstractEntity) ::Int64
    return e.base_stats.attack
end
@public get_attack_base

function get_attack(e::AbstractEntity) ::Int64

    value = get_attack_base(e)
    value *= stat_change_to_factor(e.attack_change)
    value *= e.status_state.attack_factor
    return (e.is_enemy ? floor(value) : ceil(value))
end
@public get_attack

# defense
function get_defense_base(e::AbstractEntity) ::Int64
    return e.base_stats.defense
end
@public get_defense_base

function get_defense(e::AbstractEntity) ::Int64

    value = get_defense_base(e)
    value *= stat_change_to_factor(e.defense_change)
    value *= e.status_state.defense_factor
    return (e.is_enemy ? floor(value) : ceil(value))
end
@public get_defense

# speed
function get_speed_base(e::AbstractEntity) ::Int64
    return e.base_stats.speed
end
@public get_speed_base

function get_speed(e::AbstractEntity) ::Int64

    value = get_speed_base(e)
    value *= stat_change_to_factor(e.speed_change)
    value *= e.status_state.speed_factor
    return (e.is_enemy ? floor(value) : ceil(value))
end
@public get_speed

# status
function get_status(e::AbstractEntity) ::StatusAilment
    return e.status_state.status
end
@public get_status

# name
function get_name(e::AbstractEntity) ::String
    return e.name
end

# is enemy
function is_enemy(e::AbstractEntity) ::Bool
    return e.is_enemy
end
@public is_enemy

function are_allies(a::AbstractEntity, b::AbstractEntity) ::Bool
   return a.is_enemy == b.is_enemy
end
@public are_allies

### SETTER ###

# hp
function reduce_hp!(e::AbstractEntity, value::Integer) ::Nothing

    @assert value >= 0
    if value == 0 || get_status(e) == DEAD return end

    # kill if knocked out
    if get_status(e) == KNOCKED_OUT
       inflict_status!(e, DEAD)
       return
    end

    # knock out if to 0
    if value >= get_hp(e)
        e.hp = 0
        inflict_status!(e, KNOCKED_OUT)
        return
    end

    e.hp -= value

    # wake up if asleep
    if get_status(e) == ASLEEP
       cure!(e)
    end

    return nothing
end
@public reduce_hp!
@alias deal_damage! reduce_hp!

function add_hp!(e::AbstractEntity, value::Integer) ::Nothing

    @assert value >= 0
    if value == 0 || get_status(e) == DEAD return end

    # res to 1 hp if knocked out
    if get_status(e) == KNOCKED_OUT
        cure!(e)
        e.hp = 1
        return
    end

    base = get_hp_base(e)
    e.hp += (value + e.hp > base ? base - e.hp : value)
    return nothing
end
@public add_hp!
@alias heal add_hp!

# ap
function reduce_ap!(e::AbstractEntity, value::Integer) ::Nothing

    @assert value >= 0
    if value == 0 || get_status(e) == DEAD return end

    e.ap -= (value > e.ap ? e.ap : value)
    return nothing
end
@public reduce_ap!

function add_ap!(e::AbstractEntity, value::Integer) ::Nothing

    @assert value >= 0
    if value == 0 || get_status(e) == DEAD return end

    base = get_ap_base(e)
    e.ap += (value + e.ap > base ? base - e.ap : value)
    return
end
@public add_ap!