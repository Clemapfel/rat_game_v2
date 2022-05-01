#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

include("include.jl")

using Main.game.battle
using Test

# status behavior
@testset "status ailment" begin

    e = Entity("test")

    @test e.status == NO_STATUS
    @testset begin
        @test e.status_state.turn_effect(e) == nothing
        @test e.status_state.attack_factor == 1
        @test e.status_state.defense_factor == 1
        @test e.status_state.speed_factor == 1
        @test e.status_state.stunned_counter == -1
        @test e.status_state.asleep_counter == -1
        @test e.status_state.blinded_counter == -1
        @test e.status_state.at_risk_counter == -1
    end
end

return true