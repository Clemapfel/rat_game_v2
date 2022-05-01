#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# declare combo type
@enum ComboType begin

    NO_TYPE = 0
    ATTACK = 1  # damage related
    HEX = 2     # buff / debuff / status related
    SUPPORT = 3 # heal / cure related
end
@export_enum ComboType

# declare targeting type
@enum TargetingMode begin

    SINGLE = false
    MULTI = true
end
@export_enum TargetingMode

# declare move
struct Move

    id::String      # internal id
    name::String    # cleartext name

    short_description::String    # in-battle description
    verbose_description::String  # in-menu description

    ap_cost::Int64      # ap cost to use, may be 0
    n_stacks::Int64     # maximum number of stacks, may be -1 for inf

    base::Function     # base behavior
    bonus::Function    # behavior when detonating

    primes::ComboType
    detonates::ComboType

    targeting_mode::TargetingMode
    targets_self::Bool
    targets_ally::Bool
    targets_enemy::Bool

    # debug ctor
    function Move(id, base::Function, bonus::Function)

        return new(id, id,
            "", "",
            0, -1,
            base, bonus,
            NO_TYPE, NO_TYPE,
            SINGLE, true, true, true)
    end

    # ctor
    function Move(;
        id::String,
        name::String,
        short_description::String,
        verbose_description::String,
        ap_cost::Integer,
        n_stacks::Integer,
        base_f::Function,
        bonus_f::Function,
        primes::ComboType,
        detonates::ComboType,
        targeting_mode::TargetingMode,
        targets_self::Bool,
        targets_ally::Bool,
        targets_enemy::Bool)

        return new(id, name,
            short_description, verbose_description,
            ap_cost, n_stacks,
            base_f, bonus_f,
            primes, detonates,
            targeting_mode,
            targets_self, targets_ally, targets_enemy)
    end
end

# global move storage
const move_library = Dict{String, Move}()


### ENTITY INTERACTION ###
abstract type AbstractEntity end

# set primed
function set_primed!(e::AbstractEntity, type::ComboType)
   e.primed = type
end
@public set_primed!

# consume one stack
function reduce_stack!(e::AbstractEntity, move::Move)
    e.moveset[move.id].second -= 1
end
@public reduce_stack!

# apply effect to entity
function apply_move!(user::AbstractEntity, targets::Vector{AbstractEntity}, move::Move) ::Nothing

    @assert user.moveset[move.id].second != 0
    @assert !isempty(targets)
    for target in targets

        if target.id == user.id
            @assert move.targets_self
        elseif target.is_enemy == user.is_enemy
            @assert move.targets_ally
        end

        if target.is_enemy != user.is_enemy
            @assert move.target_enemy
        end
    end

    reduce_ap(user, move.ap_cost)
    reduce_stack(user, move)

    for target in targets

        if target.primed == move.detonates
            move.base(target)
        else
            move.bonus(target)
        end
        set_primed(target, move.primes)
    end
end
apply_move!(user::AbstractEntity, target::AbstractEntity, move::Move) = apply_move(user, [target], move)
@public apply_move!


