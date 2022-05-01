#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

@include("./stat_change.jl")

abstract type AbstractEntity end

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
export StatusAilment

# apply status ailment
function inflict(e::AbstractEntity, status::StatusAilment)

    if (e.status == DEAD)
        return
    end

    if (status == DEAD)
        e.status = DEAD
        e.status_stat_change = StatChange::ZERO
        e.status_turn_effect = (x) -> ()
    end

    if (status == KNOCKED_OUT)
        e.status = KNOCKED_OUT
        e.status_stat_change = StatChange::ZERO
    end
end
export inflict

# remove status ailment
function cure(e::AbstractEntity)

end

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
export status_to_adjective

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
export status_to_verb_present

# to string when status is cured
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
        throw(AssertionError("in status_cure_to_verb: unreachable case"))
        return ""
    end
end
export status_cure_to_verb