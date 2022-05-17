#
# Copyright 2022 Clemens Cords
# Created on 17.05.2022 by clem (mail@clemens-cords.com)
#

# battle scene instance
struct BattleScene
    entities::Dict{Symbol, BattleEntity}
end

# active scene instance
active_scene = BattleScene(Dict{Symbol, BattleEntity}())

# entity access: get single
function get_entity(id::Symbol) ::BattleEntity
   return active_scene.entities[id]
end
export get_entity

# entity access: all
function get_entity_ids() ::Vector{Symbol}
    return Symbol[e.id for e in active_scene.entities]
end

# entity access: get all enemies
function get_enemy_ids() ::Vector{Symbol}

    out = Symbol[]
    for e in active_scene.entities
        if e.is_enemy
            push!(out, e.id)
        end
    end
    return out
end
export get_enemy_ids

# entity access: get all party members
function get_party_ids() ::Vector{Symbol}

    out = Symbol[]
    for e in active_scene.entities
        if !e.is_enemy
            push!(out, e.id)
        end
    end
    return out
end
export get_party_ids

# entity access: all opponents of entity
function get_opponent_ids(user_id::Symbol) ::Vector{Symbol}

    user = active_scene.entities[user_id]
    out = Symbol[]
    for e in active_scene.entities
        if e.id != user_id && e.is_enemy != user.is_enemy
            push!(out, e.id)
        end
    end
    return out
end
export get_opponent_ids

# entity access: all allies of entity but not self
function get_ally_ids(user_id::Symbol) ::Vector{Symbol}

    user = active_scene.entities[user_id]
    out = Vector{Symbol}()
    for e in active_scene.entities
        if e.id != user_id && e.is_enemy == user.is_enemy
            push!(out, e.id)
        end
    end
    return out
end
export get_ally_ids

# entity access: all possible variations of targets based on move & user
function get_possible_target_ids(user_id::Symbol, move::Move) ::Vector{Vector{Symbol}}

    user = active_scene.entities[user_id]
    out = Vector{Vector{Symbol}}()

    if move.targeting_mode == SINGLE

        for e in active_scene.entities

            if e.id == user_id && move.targets_self
                push!(out, [e.id])
            elseif e.id != user_id && e.is_enemy == user.is_enemy && move.targets_ally
                push!(out, [e.id])
            elseif e.id != user_id && e.is_enemy != user.is_enemy && move.targets_opponent
                push!(out, [e.id])
            end
        end
    else # multi

        to_push = Symbol[]
        for e in active_scene.entities
            if e.id == user_id && move.targets_self
                push!(to_push, e.id)
            elseif e.id != user_id && e.is_enemy == user.is_enemy && move.targets_ally
                push!(to_push, e.id)
            elseif e.id != user_id && e.is_enemy != user.is_enemy && move.targets_opponent
                push!(to_push, e.id)
            end
        end

        push!(out, to_push)
    end

    return out
end
export get_possible_target_ids
