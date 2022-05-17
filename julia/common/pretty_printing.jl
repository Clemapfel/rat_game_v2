#
# Copyright 2022 Clemens Cords
# Created on 16.05.2022 by clem (mail@clemens-cords.com)
#

module PrettyPrinting
    using Main

    export clear_screen, Letter, Text, print_palette, animate

    # clear screen
    function clear_screen() ::Nothing

        ccall(:system, Int32, (Cstring,), "clear");
        return nothing
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
    export Letter

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
    export print

    # text, vector of letters
    struct Text
        letters::Vector{Letter}

        Text(letters::Vector{Letter}) = new(letters)
        Text(raw::String) = return parse(raw)
    end
    export Text

    Base.getindex(text::Text, inds...) = Base.getindex(text.letters, inds...)
    Base.length(text::Text) = Base.length(Text.letters)

    # print full text letter by letter
    function Base.print(text::Text) ::Nothing

        for char in text.letters
            print(char)
        end

        return nothing
    end
    export print

    const _cube =  reshape([i for i in 16:231], 6, 6, 6)

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

        # grayscale mode: use gradient region for higher resolution
        gray_r = round(r * 26)
        gray_g = round(g * 26)
        gray_b = round(b * 26)

        if gray_r == gray_g == gray_b

            gray = gray_r
            if gray == 0 || gray == 1
                return _cube[1, 1, 1]
            elseif gray == 26
                return _cube[6, 6, 6]
            else
                return 230 + gray
            end
        else
            # color mode: use RGB cube region
            return UInt8(_cube[Int64(round(b * 5) + 1), Int64(round(g * 5) + 1), Int64(round(r * 5) + 1)])
        end
    end

    # parsing config
    const COLOR_TAG = "col"
    # use `col=(<r>, <g>, <b>)` for custom color, where r, g, b in [0, 255]
    # or use `col=<palette_color>` where `<palette_color>` is one of the following:


    const palette = Dict{Symbol, UInt8}([
        :true_white => rgb(255, 255, 255),
        :gray_25 => rgb(250, 250, 250),
        :gray_24 => rgb(240, 240, 240),
        :gray_23 => rgb(230, 230, 230),
        :gray_22 => rgb(220, 220, 220),
        :gray_21 => rgb(210, 210, 210),
        :gray_20 => rgb(200, 200, 200),
        :gray_19 => rgb(190, 190, 190),
        :gray_18 => rgb(180, 180, 180),
        :gray_17 => rgb(170, 170, 170),
        :gray_16 => rgb(160, 160, 160),
        :gray_15 => rgb(150, 150, 150),
        :gray_14 => rgb(140, 140, 140),
        :gray_13 => rgb(130, 130, 130),
        :gray_12 => rgb(120, 120, 120),
        :gray_11 => rgb(110, 110, 110),
        :gray_10 => rgb(100, 100, 100),
        :gray_09 => rgb(90, 90, 90),
        :gray_08 => rgb(80, 80, 80),
        :gray_07 => rgb(70, 70, 70),
        :gray_06 => rgb(60, 60, 60),
        :gray_05 => rgb(50, 50, 50),
        :gray_04 => rgb(40, 40, 40),
        :gray_03 => rgb(30, 30, 30),
        :gray_02 => rgb(20, 20, 20),
        :gray_01 => rgb(10, 10, 10),
        :true_black => rgb(0, 0, 0),

        :light_red => rgb(245, 105, 154),
        :red => rgb(237, 34, 96),
        :dark_red => rgb(156, 0, 37),

        :yellow => rgb(255, 237, 32),
        :orange => rgb(255, 144, 0),
        :dark_orange => rgb(191, 54, 0),

        :light_cinnabar => rgb(255, 60, 31),
        :cinnabar => rgb(232, 0, 0),

        :light_green => rgb(39, 255, 146),
        :mint => rgb(39, 255, 146),
        :green => rgb(0, 184, 86),
        :dark_green => rgb(0, 108, 77),
        :fir_green => rgb(0, 46, 91),

        :skin_light => rgb(247, 210, 187),
        :skin_tan => rgb(143, 93, 54),
        :skin_dark => rgb(81, 52, 30),

        :aqua => rgb(1, 221, 255),
        :blue => rgb(19, 175, 240),
        :dark_blue => rgb(12, 111, 232),
        :deep_blue => rgb(1, 45, 146),

        :light_pink => rgb(238, 176, 255),
        :hot_pink => rgb(255, 10, 243),
        :dark_pink => rgb(169, 11, 184),

        :light_violet => rgb(140, 31, 221),
        :violet => rgb(94, 5, 161),
        :dark_violet => rgb(66, 0, 107),

        :true_green => rgb(0, 255, 0),
        :true_yellow => rgb(255, 255, 0),
        :true_cyan => rgb(0, 255, 255),
        :true_magenta => rgb(255, 0, 255),
        :true_red => rgb(255, 0, 0),
        :true_blue => rgb(0, 0, 255)
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

                if (i+length(COLOR_TAG)-1) < length(raw) && raw[i:i+length(COLOR_TAG)-1] == COLOR_TAG

                    @assert color_active != opening "trying to " * (opening ? "open" : "close") * " a color region, but it is already " * (opening ? "open" : "closed")

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

                            while raw[i] != TAG_END_CHAR
                                color_str *= raw[i]
                                i += 1
                            end
                            current_color = PrettyPrinting.palette[Symbol(color_str)]
                        end
                    else
                        current_color = :normal
                    end
                    
                elseif (i+length(BOLD_TAG)-1) < length(raw) && raw[i:i+length(BOLD_TAG)-1] == BOLD_TAG
                    
                    @assert bold_active != opening "trying to " * (opening ? "open" : "close") * " a bold region, but it is already " * (opening ? "open" : "closed")
                    bold_active = opening
                    i += length(BOLD_TAG)
                
                elseif (i+length(UNDERLINED_TAG)-1) < length(raw) && raw[i:i+length(UNDERLINED_TAG)-1] == UNDERLINED_TAG

                    @assert underline_active != opening "trying to " * (opening ? "open" : "close") * " a underlined region, but it is already " * (opening ? "open" : "closed")
                    underline_active = opening
                    i += length(UNDERLINED_TAG)
                    
                elseif (i+length(REVERSE_TAG)-1) < length(raw) && raw[i:i+length(REVERSE_TAG)-1] == REVERSE_TAG
                    
                    @assert reverse_active != opening "trying to " * (opening ? "open" : "close") * " a reverse region, but it is already " * (opening ? "open" : "closed")
                    reverse_active = opening
                    i += length(UNDERLINED_TAG)

                elseif (i+length(BLINKING_TAG)-1) < length(raw) && raw[i:i+length(BLINKING_TAG)-1] == BLINKING_TAG
                        
                    @assert blinking_active != opening "trying to " * (opening ? "open" : "close") * " a blinking region, but it is already " * (opening ? "open" : "closed")
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

                push!(out, to_push)
                i += 1
            end
        end

        catch exc

            offset = 30
            printstyled(stderr, "Error when parsing text: at " * string(i) * "\n", color=:light_red)

            text_start = max(i - 30, 1)
            text_end = min(i + 30, length(raw))

            for c in raw[text_start:text_end]
                if Int64(c) > 33
                    print(stderr, c)
                end
            end
            printstyled(text_end < length(raw) ? " (...)\n" : "\n", color=:light_black)
            printstyled(stderr, repeat("~", i - text_start), "^", color=:light_red)
            println()
            throw(exc)
        end

        return Text(out)
    end

    # pretty print palette with each colors names
    function print_palette() ::Nothing

        order = [:true_black, :gray_01, :gray_02, :gray_03, :gray_04, :gray_05, :gray_06, :gray_07,:gray_08, :gray_09, :gray_10, :gray_11, :gray_12, :gray_13, :gray_14, :gray_15, :gray_16, :gray_17, :gray_18, :gray_19, :gray_20, :gray_21, :gray_22, :gray_23, :gray_24, :gray_25, :true_white, :light_red, :red, :dark_red, :yellow, :orange, :dark_orange, :light_cinnabar, :cinnabar, :light_green, :mint, :green, :dark_green, :fir_green, :skin_light, :skin_tan, :skin_dark, :aqua, :blue, :dark_blue, :deep_blue, :light_pink, :hot_pink, :dark_pink, :light_violet, :violet, :dark_violet, :true_green, :true_yellow, :true_cyan, :true_magenta, :true_red, :true_blue]

        max_length = 0
        for sym in order max_length = max(length(string(sym)), max_length) end

        str = "[b][r]"
        for sym in order
            str *= ("[col=" * string(sym) * "] " * string(sym) * repeat(" ", max_length - length(string(sym))) * " [/col]\n")
        end
        str *= "[/r][/b]"
        print(Text(str))

        return nothing
    end
    export print_palette

    # animate text
    function animate(text::Text) ::Int

        delay::Real = 0.03
        for i in 1:length(text.letters)

            print("\r")
            for j in 1:i
                print(text.letters[j])
            end

            c = text.letters[i].value
            if c == ',' || c == '.' || c == ';' || c == '!' || c == '?'
                sleep(8*delay)
            else
                sleep(delay)
            end
        end
        return length(text.letters)
    end
    export animate
end

