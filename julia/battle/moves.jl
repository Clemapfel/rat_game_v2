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

    id::Symbol      # internal id
    name::String    # cleartext name

    short_description::String    # in-battle description
    verbose_description::String  # in-menu description

    ap_cost::Int64     # ap cost to use, may be 0
    n_stacks::Int64    # maximum number of stacks, may be -1 for inf

    base::Function     # base behavior
    bonus::Function    # behavior when detonating

    primes::ComboType
    detonates::ComboType

    targeting_mode::TargetingMode
    targets_self::Bool
    targets_ally::Bool
    targets_opponent::Bool

    # debug ctor
    function Move(id::Symbol, base::Function, bonus::Function)

        return new(id, id,
            "", "",
            0, -1,
            base, bonus,
            NO_TYPE, NO_TYPE,
            SINGLE, true, true, true)
    end

    # ctor
    function Move(;
        id::Symbol,
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
        targets_opponent::Bool)

        return new(id, name,
            short_description, verbose_description,
            ap_cost, n_stacks,
            base_f, bonus_f,
            primes, detonates,
            targeting_mode,
            targets_self, targets_ally, targets_opponent)
    end
end

# global move storage
const move_library = Dict{Symbol, Move}()

# add move to move_library
function new_move(
    id::Symbol,
    name::String,
    short_description::String,
    verbose_description::String
    ;
    ap::Integer,
    stacks::Integer,
    primes::ComboType,
    detonates::ComboType,
    mode::TargetingMode,
    targets_self::Bool,
    targets_ally::Bool,
    targets_opponent::Bool,
    base::Function,
    bonus::Function)

    setindex!(move_library, Move(
        id=id, name=name,
        short_description=short_description, verbose_description=verbose_description,
        ap_cost=ap, n_stacks=stacks,
        base_f=base, bonus_f=bonus,
        primes=primes, detonates=detonates,
        targeting_mode=mode,
        targets_self=targets_self,
        targets_ally=targets_ally,
        targets_opponent=targets_opponent
    ), id)
end

# access move library
function get_move(id::Symbol) ::Move
    return move_library[id]
end

### ENTITY INTERACTION ###
abstract type AbstractBattleEntity end

# set primed
function set_primed!(e::AbstractBattleEntity, type::ComboType)
   e.primed = type
end
@public set_primed!

# consume one stack
function reduce_stack!(e::AbstractBattleEntity, move::Move)
    e.moveset[move.id].second -= 1
end
@public reduce_stack!

# apply effect to entity
function apply_move!(user::AbstractBattleEntity, targets::Vector{AbstractBattleEntity}, move::Move) ::Nothing

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
apply_move!(user::AbstractBattleEntity, target::AbstractBattleEntity, move::Move) = apply_move(user, [target], move)
@public apply_move!


