#
# Copyright 2022 Clemens Cords
# Created on 16.05.2022 by clem (mail@clemens-cords.com)
#

module BattleLog

    using Main.game.PrettyPrinting

    function print(formatted_string::String; wait=true) ::Nothing

        t = Threads.@spawn begin
            Base.print(PrettyPrinting.Text(formatted_string))
        end

        if wait Base.wait(t) end
        return nothing
    end
end
