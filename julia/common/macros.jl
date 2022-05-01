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
