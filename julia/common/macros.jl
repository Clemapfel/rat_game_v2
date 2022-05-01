#
# Copyright 2022 Clemens Cords
# Created on 01.05.2022 by clem (mail@clemens-cords.com)
#

macro export_enum(enum_symbol::Symbol)

    enum = __module__.eval(enum_symbol)
    __module__.eval(Expr(:export, Symbol(enum)))
    for e in instances(enum)
        __module__.eval(Expr(:export, Symbol(e)))
    end
end
export @export_enum
