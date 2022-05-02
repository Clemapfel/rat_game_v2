#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# entity mutation
@testset "entity mutation" begin

    e = Entity(:test)

    @test get_hp(e) == e.hp
    @test get_ap(e) == e.ap
    @test get_hp_base(e) == e.base_stats.hp
    @test get_ap_base(e) == e.base_stats.ap
    @test get_attack_base(e) == e.base_stats.attack
    @test get_defense_base(e) == e.base_stats.defense
    @test get_speed_base(e) == e.base_stats.speed

    inflict_poisoned!(e)
    @test get_status(e) == POISONED
    cure!(e)

    @test get_attack(e) == get_attack_base(e)
    @test get_defense(e) == get_defense_base(e)
    @test get_speed(e) == get_speed(e)

    before = get_attack(e)
    raise_attack!(e)
    @test get_attack(e) > before
    lower_attack!(e)
    lower_attack!(e)
    @test get_attack(e) < before

    before = get_defense(e)
    raise_defense!(e)
    @test get_defense(e) > before
    lower_defense!(e)
    lower_defense!(e)
    @test get_defense(e) < before

    before = get_speed(e)
    raise_speed!(e)
    @test get_speed(e) > before
    lower_speed!(e)
    lower_speed!(e)
    @test get_speed(e) < before

    # ap
    reduce_ap!(e, 50)
    @test get_ap(e) == get_ap_base(e) - 50
    add_ap!(e, 50)
    @test get_ap(e) == get_ap_base(e)

    # hp
    reduce_hp!(e, 50)
    @test get_hp(e) == get_hp_base(e) - 50
    add_hp!(e, 50)
    @test get_hp(e) == get_hp_base(e)

    deal_damage!(e, get_hp_base(e) * 2)
    @test get_hp(e) == 0
    @test get_status(e) == KNOCKED_OUT

    deal_damage!(e, 0)
    @test get_status(e) == KNOCKED_OUT

    deal_damage!(e, 1)
    @test get_status(e) == DEAD
end
