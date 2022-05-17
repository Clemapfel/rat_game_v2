#
# Copyright 2022 Clemens Cords
# Created on 16.05.2022 by clem (mail@clemens-cords.com)
#

module BattleLog

    using Main
    using Main.battle
    using Main.PrettyPrinting

    module detail
        using Main
        using Main.PrettyPrinting

        # formatting for special strings
        ColorFormat = @NamedTuple begin
            color::Symbol
            underlined::Bool
            reverse::Bool
        end

        function apply_color_format(inside::String, format::ColorFormat) ::String

            front = "[b]"
            back = "[/b]"

            if format.color != :normal
                front = front * "[col=" * string(format.color) * "]"
                back = "[/col]" * back
            end

            if format.underlined
                front = front * "[u]"
                back = "[/u]" * back
            end

            if format.reverse
                front = front * "[r]"
                back = "[/r]" * back
            end

            return front * inside * back
        end

        # id color format
        _id_to_color = Dict{Symbol, ColorFormat}([
            :RAT      => ColorFormat([:violet, false, false]),
            :GIRL     => ColorFormat([:light_pink, false, false]),
            :PROF     => ColorFormat([:light_red, false, false]),
            :MC       => ColorFormat([:aqua, false, false]),
            :WILDCARD => ColorFormat([:orange, false, false]),
            :SCOUT    => ColorFormat([:green, false, false])
        ])
        _enemy_color = ColorFormat([:light_cinnabar, false, false])

        # combo type color format
        _combo_type_to_color = Dict{ComboType, ColorFormat}([
            NO_TYPE => ColorFormat([:normal, true, false]),
            ATTACK  => ColorFormat([:cinnabar, true, false]),
            HEX     => ColorFormat([:hot_pink, true, false]),
            SUPPORT => ColorFormat([:yellow, true, false])
        ])

        # status color format
        _status_to_format = Dict{StatusAilment, ColorFormat}([
            DEAD        => ColorFormat([:normal, false, true]),
            KNOCKED_OUT => ColorFormat([:red, false, true]),
            NO_STATUS   => ColorFormat([:normal, false, false]),
            AT_RISK     => ColorFormat([:dark_red, false, false]),
            STUNNED     => ColorFormat([:yellow, false, false]),
            ASLEEP      => ColorFormat([:gray_10, false, false]),
            POISONED    => ColorFormat([:violet, false, false]),
            BLINDED     => ColorFormat([:gray_10, false, true]),
            BURNED      => ColorFormat([:cinnabar, false, false]),
            CHILLED     => ColorFormat([:aqua, false, false]),
            FROZEN      => ColorFormat([:blue, false, false])
        ])
    end

    function print(formatted_string::String; wait=true) ::Nothing

        t = Threads.@spawn beginb

            for id in Main.get_entity_ids()
                entity = Main.get_entity(id)

                if entity.is_enemy
                    formatted_string = replace(formatted_string,
                        entity.id => detail.apply_color_format(string(entity.id), detail._enemy_color))
                else
                    formatted_sttring = replace(formatted_string,
                        entity.id => detail.apply_color_format(string(entity.id), detail._id_to_color[entity.id]))
                end
            end
            Base.print(PrettyPrinting.Text(formatted_string))
        end

        if wait Base.wait(t) end
        return nothing
    end
end
