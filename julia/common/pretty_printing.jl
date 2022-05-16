#
# Copyright 2022 Clemens Cords
# Created on 16.05.2022 by clem (mail@clemens-cords.com)
#

module PrettyPrinting

    # clear screen
    function clear_screen()
        ccall(:system, Int32, (Cstring,), "clear");
    end
    export clear_screen

    # colored letter
    mutable struct Letter

        value::Char
        color::Union{UInt8, Symbol}
        is_bold::Bool
        is_underlined::Bool
        is_blinking::Bool
        is_reverse::Bool
        is_visible::Bool

        function Letter(char::Char)
            new(char, UInt8(255), false, false, false, false, true)
        end
    end

    # print single letter
    function prettyprint(letter::Letter) ::Nothing

        printstyled(string(letter.value),
            color = (letter.color isa Symbol ? letter.color : Int64(letter.color)),
            bold = letter.is_bold,
            underline = letter.is_underlined,
            blink = letter.is_blinking,
            reverse = letter.is_reverse,
            hidden = !letter.is_visible
        )
    end

    # text, vector of letters
    struct Text
        letters::Vector{Letter}
    end

    # print full text letter by letter
    function prettyprint(text::Text) ::Nothing

        for char in text.letters
            prettyprint(char)
        end
    end

    # parse raw text to pretty text
    const COLOR_TAG = "col"
    const BOLD_TAG = "b"
    const UNDERLINED_TAG = "u"
    const REVERSE_TAG = "r"
    const BLINKING_TAG = "fx_b"
    const TAG_START_CHAR = '['
    const TAG_END_CHAR = ']'
    const TAG_END_PREFIX = '/'

    function parse(raw::String) ::Text

        out = Letter[]

        color_active = false
        current_color::Union{UInt8, Symbol} = :normal
        bold_active = false
        underline_active = false
        reverse_active = false
        blinking_active = false

        i = 1
        try
        while i <= length(raw)

            # control tag
            if raw[i] == TAG_START_CHAR

                i += 1
                opening = true
                if raw[i] == TAG_END_PREFIX
                    opening = false
                    i += 1
                end

                if raw[i:i+length(COLOR_TAG)-1] == COLOR_TAG

                    @assert color_active != opening

                    color_active = opening
                    i += length(COLOR_TAG)

                    if color_active
                        @assert raw[i] == '='
                        i += 1

                        if opening
                            num_string = ""
                            while i < length(raw) && raw[i] != TAG_END_CHAR
                                num_string *= raw[i]
                                i += 1
                            end

                            current_color = tryparse(UInt8, num_string)
                        end
                    else
                        current_color = :normal
                    end
                    
                elseif raw[i:i+length(BOLD_TAG)-1] == BOLD_TAG
                    
                    @assert bold_active != opening
                    bold_active = opening
                    i += length(BOLD_TAG)
                
                elseif raw[i:i+length(UNDERLINED_TAG)-1] == UNDERLINED_TAG

                    @assert underline_active != opening
                    underline_active = opening
                    i += length(UNDERLINED_TAG)
                    
                elseif raw[i:i+length(REVERSE_TAG)-1] == REVERSE_TAG
                    
                    @assert reverse_active != opening
                    reverse_active = opening
                    i += length(UNDERLINED_TAG)

                elseif raw[i:i+length(BLINKING_TAG)-1] == BLINKING_TAG
                        
                    @assert blinking_active != opening
                    blinking_active = opening
                    i += length(BLINKING_TAG)
                    
                else
                   throw(ErrorException("Unrecognized Control Tag"))
                end

                @assert raw[i] == TAG_END_CHAR
                i += 1
            else

                to_push = Letter(raw[i])
                to_push.color = current_color
                to_push.is_bold = bold_active
                to_push.is_underlined = underline_active
                to_push.is_blinking = blinking_active
                to_push.is_reverse = reverse_active
                to_push.is_visible = true

                println(to_push.value)
                push!(out, to_push)
                i += 1
            end
        end

        catch exc

            offset = 30
            printstyled(stderr, "Error when parsing text at " * string(i) * "\n", color=:light_red)
            println(stderr, raw[1:i])
            throw(exc)
        end

        return Text(out)
    end
end

text =
"[b]this is bold[/b]\n" *
"[col=123]this is colored[/col]\n" *
"[u]this is underlined[/u]\n" *
"[r]this is reversed[/r]\n" *
"[fx_b] this is blinking[/fx_b]\n"*
"[b][col=123][u][r][fx_b]this is all at once[/b][/col][/u][/r][/fx_b]\n"

parsed = PrettyPrinting.parse(text)
PrettyPrinting.prettyprint(parsed)
