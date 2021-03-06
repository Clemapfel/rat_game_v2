#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

abstract type AbstractBattleEntity end

# declare status ailments
@enum StatusAilment begin

    DEAD = -2
    KNOCKED_OUT = -1
    NO_STATUS = 0
    AT_RISK = 2
    STUNNED = 3
    ASLEEP = 4
    POISONED = 5
    BLINDED = 6
    BURNED = 7
    CHILLED = 8
    FROZEN = 9
end
@export_enum StatusAilment

# placeholder for no effect
NO_TURN_EFFECT(_::AbstractBattleEntity) = return
@private NO_TURN_EFFECT

# status state used for entities
mutable struct StatusState

    status::StatusAilment
    turn_effect::Function

    attack_factor::Float32
    defense_factor::Float32
    speed_factor::Float32

    stunned_counter::Int64
    asleep_counter::Int64
    blinded_counter::Int64
    at_risk_counter::Int64

    StatusState() = new(NO_STATUS, NO_TURN_EFFECT, 1.0, 1.0, 1.0, -1, -1, -1, -1)
end
@private StatusState

# clear status state
function reset!(state::StatusState) ::Nothing

    state.turn_effect = NO_TURN_EFFECT

    state.attack_factor = 1
    state.defense_factor = 1
    state.speed_factor = 1

    state.stunned_counter = -1
    state.asleep_counter = -1
    state.blinded_counter = -1
    state.at_risk_counter = -1

    return
end
@private reset!

# remove status ailment
function cure!(e::AbstractBattleEntity) ::Nothing

    e.status_state.status = NO_STATUS
    reset!(e.status_state)
    return
end
@public cure!

# apply status ailment
function inflict_status!(e::AbstractBattleEntity, s::StatusAilment) ::Nothing

    if s == DEAD
        inflict_dead!(e)
    elseif s == KNOCKED_OUT
        inflict_knocked_out!(e)
    elseif s == AT_RISK
        inflict_at_risk!(e)
    elseif s == STUNNED
        inflict_stunned!(e)
    elseif s == ASLEEP
        inflict_asleep!(e)
    elseif s == POISONED
        inflict_poisoned!(e)
    elseif s == BURNED
        inflict_burned!(e)
    elseif s == CHILLED
        inflict_chilled!(e)
    elseif s == FROZEN
        inflict_frozen!(e)
    elseif s == NO_STATUS
        cure!(e)
    end
    return
end
@public inflict_status!

# kill entity
function inflict_dead!(x::AbstractBattleEntity) ::Nothing

    reset!(x.status_state)
    x.status_state.status= DEAD
    return
end
@public inflict_dead!

# knock out
function inflict_knocked_out!(x::AbstractBattleEntity) ::Nothing

    if x.status_state.status!= DEAD
        reset!(x.status_state)
        x.status_state.status= KNOCKED_OUT
    end
    return
end
@public inflict_knocked_out!

# at risk
function inflict_at_risk!(x::AbstractBattleEntity) ::Nothing

    if x.status_state.status== NO_STATUS

        reset!(x.status_state)
        x.status_state.status= AT_RISK
        x.status_state.at_risk_counter = 0

        # cure! after 3 turns
        x.status_state.turn_effect = function (x::AbstractBattleEntity)
            x.status_state.at_risk_counter += 1
            if x.status_state.at_risk_counter == 3
               cure!(x)
            end
        end
    end
    return
end
@public inflict_at_risk!

# asleep
function inflict_asleep!(x::AbstractBattleEntity) ::Nothing

    if x.status_state.status== NO_STATUS

        reset!(x.status_state)
        x.status_state.status= ASLEEP
        x.status_state.asleep_counter = 0

        # 50% chance to wake up, max 4 turns
        x.status_state.turn_effect = function (x::AbstractBattleEntity)

            x.status_state.asleep_counter += 1

            if RNG.toss_coin() || x.status_state.asleep_counter == 4
                cure!(x)
            end
        end
    end
    return
end
@public inflict_asleep!

# poison
function inflict_poisoned!(x::AbstractBattleEntity) ::Nothing

    if x.status_state.status== NO_STATUS

        reset!(x.status_state)
        x.status_state.status= POISONED

        # deal 1/8th per turn
        x.status_state.turn_effect = function (x::AbstractBattleEntity)
            deal_damage(x, (1/8) * x.hp_base)
        end
    end
    return
end
@public inflict_poisoned!

# blinded
function inflict_blinded(x::AbstractBattleEntity) ::Nothing

    if x.status_state.status== NO_STATUS

        reset!(x.status_state)
        x.status_state.status= BLINDED

        # set attack to 0, lasts for 3 turns
        x.status_state.attack_factor = 0
        x.status_state.turn_effect = function (x::AbstractBattleEntity)
            x.status_state.blinded_counter += 1
            if (x.status_state.blinded_counter == 3)
                cure!(x)
            end
        end
    end
    return
end
@public inflict_blinded

# burned
function inflict_burned!(x::AbstractBattleEntity) ::Nothing

    # fire + ice = cure!
    if x.status_state.status== CHILLED || x.status_state.status== FROZEN
        cure!(x)
    elseif x.status_state.status== NO_STATUS
        reset!(x.status_state)
        x.status_state.status= BURNED

        # def * 0.5, inflict 1/16th each turn
        x.status_state.defense_factor = 0.5
        x.status_state.turn_effect = function (x::AbstractBattleEntity)
            deal_damage(x, (1/16) * x.hp_base)
        end
    end
    return
end
@public inflict_burned!

# chilled
function inflict_chilled!(x::AbstractBattleEntity) ::Nothing

    # chilled + chilled = frozen
    if x.status_state.status== CHILLED
       inflict_frozen!(x)

    # fire + ice = cure!
    elseif x.status_state.status== BURNED
        cure!(x)

    elseif x.status_state.status== NO_STATUS
        reset!(x.status_state)
        x.status_state.status= CHILLED

        # speed * 0.5
        x.status_state.speed_factor = 0.5
    end
    return
end
@public inflict_chilled!

# frozen
function inflict_frozen!(x::AbstractBattleEntity) ::Nothing

    # fire + ice = cure!
    if x.status_state.status== BURNED
        cure!(x)
    elseif x.status_state.status== NO_STATUS || x.status_state.status== CHILLED
        reset!(x.status_state)
        x.status_state.status= FROZEN

        # speed = 0
        x.status_state.speed_factor = 0
    end
    return
end
@public inflict_frozen!

# to string when status is reported
function status_to_adjective(s::StatusAilment) ::String

    if s == DEAD
        return "dead"
    elseif s == KNOCKED_OUT
        return "knocked out"
    elseif s == AT_RISK
        return "at risk"
    elseif s == STUNNED
        return "stunned"
    elseif s == ASLEEP
        return "asleep"
    elseif s == POISONED
        return "poisoned"
    elseif s == BURNED
        return "burned"
    elseif s == CHILLED
        return "chilled"
    elseif s == FROZEN
        return "frozen solid"
    else
        throw(AssertionError("in status_to_adjective: unreachable case"))
        return ""
    end
end
@public status_to_adjective

# to string when status is inflicted
function status_to_verb(s::StatusAilment) ::String

    if s == DEAD
        return "died"
    elseif s == KNOCKED_OUT
        return "fainted"
    elseif s == AT_RISK
        return "was put at risk"
    elseif s == STUNNED
        return "was stunned"
    elseif s == ASLEEP
        return "fell asleep"
    elseif s == POISONED
        return "was poisoned"
    elseif s == BURNED
        return "was set on fire"
    elseif s == CHILLED
        return "was chilled"
    elseif s == FROZEN
        return "froze solid"
    else
        throw(AssertionError("in status_to_verb: unreachable case"))
        return ""
    end
end
@public status_to_verb_present

# to string when status is cure!d
function status_cure_to_verb(s::StatusAilment) ::String

    if s == DEAD
        return "came back from the dead"
    elseif s == KNOCKED_OUT
        return "regained conciousness"
    elseif s == AT_RISK
        return "is not longer at risk"
    elseif s == STUNNED
        return "is no longer stunned"
    elseif s == ASLEEP
        return "woke up"
    elseif s == POISONED
        return "poison wore off"
    elseif s == BURNED
        return "is no longer burning"
    elseif s == CHILLED
        return "is no longer chilled"
    elseif s == FROZEN
        return "thawed and is no longer frozen"
    else
        throw(AssertionError("in status_cure!_to_verb: unreachable case"))
        return ""
    end
end
@public status_cure_to_verb