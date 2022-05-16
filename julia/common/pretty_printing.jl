#
# Copyright 2022 Clemens Cords
# Created on 16.05.2022 by clem (mail@clemens-cords.com)
#

module PrettyPrinting

    # clear screen
    function clear_screen()
        ccall(:system, Int32, (Cstring,), "clear");
    end

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
    function Base.print(letter::Letter) ::Nothing

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

        Text(letters::Vector{Letter}) = new(letters)
        Text(raw::String) = return parse(raw)
    end

    # print full text letter by letter
    function Base.print(text::Text) ::Nothing

        for char in text.letters
            print(char)
        end
    end


    """
    `rgb(::Integer, ::Integer, ::Integer) -> Int64`

    map 8-bit rgb value to `printstyled` compatible number

    # Arguments:
    + red: red component in [0, 255]
    + green: green component in [0, 255]
    + blue: blue component in [0, 255]

    # Returns
    Int64

    # Examples:

    ```julia
    # print transition from cyan to magenta
    for i in 0:255
        printstyled("██", color=rgb(i, 255-i, 255))
    end
    ```
    """
    function rgb(red::Integer, green::Integer, blue::Integer) ::UInt8

        @assert 0 <= red <= 255 && 0 <= green <= 255 && 0 <= blue <= 255

        r = Float64(red) / 255
        g = Float64(green) / 255
        b = Float64(blue) / 255

        cube = reshape([i for i in 16:231], 6, 6, 6)

        # grayscale mode: use gradient region for higher resolution
        gray_r = round(r * 26)
        gray_g = round(g * 26)
        gray_b = round(b * 26)

        if gray_r == gray_g == gray_b

            gray = gray_r
            if gray == 0
                return cube[1, 1, 1]
            elseif gray == 26
                return cube[6, 6, 6]
            else
                return 231 + gray
            end
        else
            # color mode: use RGB cube region
            return UInt8(cube[Int64(round(b * 5) + 1), Int64(round(g * 5) + 1), Int64(round(r * 5) + 1)])
        end
    end

    # parsing config
    const COLOR_TAG = "col"
    # use `col=(<r>, <g>, <b>)` for custom color, where r, g, b in [0, 255]
    # or use `col=<palette_color>` where `<palette_color>` is one of the following:

    const palette = Dict{Symbol, UInt8}([
        :test => rgb(123, 0, 245)
    ])

    const BOLD_TAG = "b"
    const UNDERLINED_TAG = "u"
    const REVERSE_TAG = "r"
    const BLINKING_TAG = "fx_b"
    const TAG_START_CHAR = '['
    const TAG_END_CHAR = ']'
    const TAG_END_PREFIX = '/'

    # parse raw string to text
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

                        # custom
                        if (raw[i] == '(')

                            i += 1
                            red_str = ""
                            while raw[i] != ','
                                red_str *= raw[i]
                                i += 1
                            end
                            i += 1

                            green_str = ""
                            while raw[i] != ','
                                green_str *= raw[i]
                                i += 1
                            end
                            i += 1

                            blue_str = ""
                            while raw[i] != ')'
                                blue_str *= raw[i]
                                i += 1
                            end

                            @assert raw[i] == ')'
                            current_color = rgb(tryparse(UInt8, red_str), tryparse(UInt8, blue_str), tryparse(UInt8, green_str))
                        # palette
                        else
                            color_str = ""
                            while raw[i] != ')'
                                color_str *= raw[i]
                            end

                            @assert raw[i] == ')'
                            current_color = palette[Symbol(color_str)]
                        end

                        i += 1
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

parsed = PrettyPrinting.Text("[col=(0, 255, 255)]text[/col]")
