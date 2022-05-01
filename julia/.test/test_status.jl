#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# status behavior
@testset "status ailment" begin

    e = Entity("test")

    @test e.status_state.status== NO_STATUS
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

    inflict_at_risk(e)
    @test e.status_state.status== AT_RISK
    cure(e)

    inflict_asleep(e)
    @test e.status_state.status== ASLEEP
    cure(e)

    inflict_blinded(e)
    @test e.status_state.status== BLINDED
    @test e.status_state.attack_factor == 0
    cure(e)

    inflict_poisoned(e)
    @test e.status_state.status== POISONED
    cure(e)

    inflict_burned(e)
    @test e.status_state.status== BURNED
    @test e.status_state.defense_factor == 0.5
    cure(e)

    inflict_chilled(e)
    @test e.status_state.status== CHILLED
    @test e.status_state.speed_factor == 0.5
    cure(e)

    inflict_frozen(e)
    @test e.status_state.status== FROZEN
    @test e.status_state.speed_factor == 0
    cure(e)

    inflict_burned(e)
    inflict_chilled(e)
    @test e.status_state.status== NO_STATUS
    cure(e)

    inflict_chilled(e)
    inflict_burned(e)
    @test e.status_state.status== NO_STATUS
    cure(e)

    inflict_burned(e)
    inflict_frozen(e)
    @test e.status_state.status== NO_STATUS
    cure(e)

    inflict_frozen(e)
    inflict_burned(e)
    @test e.status_state.status== NO_STATUS
    cure(e)

    inflict_chilled(e)
    inflict_chilled(e)
    @test e.status_state.status== FROZEN
    cure(e)

    inflict_chilled(e)
    inflict_frozen(e)
    @test e.status_state.status== FROZEN
    cure(e)
end

return true