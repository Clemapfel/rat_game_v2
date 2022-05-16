#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

# export enum an all instances
macro export_enum(enum_symbol::Symbol)

    enum = __module__.eval(enum_symbol)
    __module__.eval(Expr(:export, Symbol(enum)))
    for e in instances(enum)
        __module__.eval(Expr(:export, Symbol(e)))
    end
end
export @export_enum

# export value
macro public(sym::Symbol...)
    __module__.eval(Expr(:export, sym...))
end
export @public

# don't export value
macro private(sym::Symbol)
    # noop
end
export @private

# type or function alias
macro alias(a::Symbol, b::Expr)

    original =__module__.eval(b)
    __module__.eval(Expr(Symbol("="), a, original))

    if (Base.isexported(__module__, Symbol(original)))
        __module__.eval(Expr(:export, a))
    end
end

macro alias(a::Symbol, b::Symbol)

    original =__module__.eval(b)
    __module__.eval(Expr(Symbol("="), a, original))

    if (Base.isexported(__module__, b))
        __module__.eval(Expr(:export, a))
    end
end
export @alias

macro include(path::String)

    filename(str) = str[length(Base.Filesystem.dirname(str))+2:length(str)]
    file = filename(path)

    if Main.__debug_enabled
       return :(@time print($file * "\n"); include($path); println();)
    else
       return :(include($path))
    end
end
export @include