#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

module RNG
    import Random
    const seed = Base.Ref{UInt64}(0)

    function toss_coin(head_chance = 0.5) ::Bool

        global seed[] += 1
        return rand(Random.MersenneTwister(seed[])) <= head_chance
    end
end
