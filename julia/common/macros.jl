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

# optimized include
if !isdefined(@__MODULE__, :__already_included)
    __already_included = String[]
end

macro include(path::String)

    if path in Main.__already_included
        return
    else
        push!(Main.__already_included, Base.Filesystem.abspath(path))
    end

    filename(str) = str[length(Base.Filesystem.dirname(str))+2:length(str)]
    file = filename(path)

    if Main.__debug_enabled
       return :(@time begin Log.@log "compiling " * $file; include($path); end; println())
    else
       return :(include($path))
    end
end
export @include

# only execute expression once, useful for scripts that may be included multiple times
if !isdefined(@__MODULE__, :__already_executed)
    __already_executed = Dict{String, Vector{Int64}}()
end

macro once(expr)

    file = Base.Filesystem.pwd() * string(@__FILE__)
    line::Int64 = @__LINE__

    if haskey(__already_executed, file)
        if line in __already_executed[file]
            return
        else
            __module__.eval(expr)
            push!(__already_executed[file], line)
        end
    else
        __module__.eval(expr)
        __already_executed[file] = Int64[line]
    end
end
export @once

