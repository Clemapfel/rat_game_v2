#
# Copyright 2022 Clemens Cords
# Created on 02.05.2022 by clem (mail@clemens-cords.com)
#

# TEMPLATE MOVE
new_move(:TEMPLATE_MOVE,

    "template name",
    "short description",
    "verbose description",
    ap = 0,
    stacks = -1,
    primes = NO_TYPE,
    detonates = NO_TYPE,
    mode = SINGLE,
    targets_self = true,
    targets_ally = false,
    targets_opponent= false,

    base = function (x)
    end,

    bonus = function (x)
    end
)
