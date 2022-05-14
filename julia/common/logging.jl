#
# Copyright 2022 Clemens Cords
# Created on 14.05.2022 by clem (mail@clemens-cords.com)
#

module Log

    """
    enum of formatting options, decides additional log contents

    ## Values
    - `TIMESTAMP`: adds a timestamp of the form "<hour>:<minute>:<second>"
    - `DATESTAMP`: adds a date of the from "<day>/<month>"
    - `THREADID`: native handle of current thread
    """
    @enum FormattingOptions begin
        TIMESTAMP  = UInt32(1) << 1 # print current time
        DATESTAMP  = UInt32(1) << 2 # print current date
        THREADID   = UInt32(1) << 3 # print id of thread write was called from
    end
    export FormattingOptions
    export TIMESTAMP
    export DATESTAMP
    export THREADID

    """
    enum of formatting modes, decide the general structue of log messages

    ## Values
    - `PRETTY`: colors, human readable output
    - `CSV`: format output as CSV
    """
    @enum FormattingMode begin
        PRETTY
        CSV
    end
    export PRETTY
    export CSV

    module detail

        using Dates
        using Main.Log
        using Test
        using DataStructures

        _init_lock = Base.ReentrantLock()
        _mode = Log.PRETTY
        _options = Log.FormattingOptions[TIMESTAMP]

        _task_storage = Queue{Task}()
        _task_storage_lock = Base.ReentrantLock()

        _stream = stdout
        _stream_lock = Base.ReentrantLock()

        _csv_delimiter = ","
        _initialization_message = "### LOGGING INITIALIZED ###"
        _shutdown_message = "### LOGGING SHUTDOWN ###"

        """
        `append(message::String, [options::FormattingOptions...]) -> Nothing`

        append a message to the log stream

        ## Arguments
        + `message`: raw string
        + `options`: multiple formatting options, optional
        """
        function append(message::String) ::Nothing

            lock(_task_storage_lock)

            # cleanup finished tasks
            while !isempty(detail._task_storage) && istaskdone(first(detail._task_storage))
                dequeue!(detail._task_storage)
            end

            enqueue!(_task_storage, Threads.@spawn begin

                out::String = ""
                now = Dates.now()

                function add_zero(num) ::String
                    out = ""
                    if num < 10 out *= "0" end
                    return out * string(num)
                end

                if _mode == CSV

                    if DATESTAMP in _options
                        out *= string(Dates.day(now)) * detail._csv_delimiter
                        out *= string(Dates.month(now)) * detail._csv_delimiter
                    end

                    if TIMESTAMP in _options
                        out *= string(Dates.format(Dates.now(), DateFormat("H:M:S:MS"))) * detail._csv_delimiter
                    end

                    if THREADID in _options
                        out *= string(Threads.threadid()) * detail._csv_delimiter
                    end

                elseif _mode == PRETTY

                    if TIMESTAMP in _options || DATESTAMP in _options

                        out *= "["

                        if DATESTAMP in _options
                            out *= add_zero(Dates.day(now)) * "."
                            out *= add_zero(Dates.month(now)) * "-"
                        end

                        if DATESTAMP in _options && TIMESTAMP in _options
                           out *= "|"
                        end

                        if TIMESTAMP in _options
                           out *= add_zero(Dates.hour(now)) * ":"
                            out *= add_zero(Dates.minute(now)) * ":"
                            out *= add_zero(Dates.second(now))
                        end

                        out *= "]"
                    end

                    if THREADID in _options
                        out *= "[" * Threads.threadid() * "]"
                    end

                    if length(_options) >= 1 # more than one char left of the message
                        out *= " "
                    end
                end

                out *= message * "\n"

                @lock _stream_lock begin
                    Base.write(_stream, out)
                    flush(_stream)
                end
            end)
            return nothing
        end
        # no export

        """
        `test() -> Nothing`

        testset of module `Log`
        """
        function test() ::Nothing

            Test.@testset "Logging" begin

                try

                Log.init(Base.Filesystem.pwd() * "/_.log")

                Test.@test Base.Filesystem.isfile(Log.detail._stream)
                Test.@test isopen(Log.detail._stream)

                Log.write("test line")
                Log.quit()
                Test.@test !isopen(Log.detail._stream)

                file = open(Base.Filesystem.pwd() * "/_.log", read=true)

                Test.@test occursin(Log.detail._initialization_message, readline(file))
                Test.@test occursin("test line", readline(file))

                finally Base.Filesystem.rm(Base.Filesystem.pwd() * "/_.log") end
            end
            return nothing
        end
        # no export
    end

    """
    `write(::Any...) -> Nothing`

    write to the log stream. If julia was initialized with more than 1 thread,
    writing is concurrent.

    ## Arguments
    + `xs...`: any number of objects, will be converted to strings, similar to Base.print
    """
    function write(xs...)

        if length(xs) == 1 && string(getindex(xs, 1)) == ""
            return nothing
        end

        detail.append(prod(string.([xs...])))
    end
    export write

    """
    `initialize([path::String], [mode::FormattingMode], [options::FormattingOptions...]) -> Bool`

    initialize the logging environment

    ## Arguments
    + `path`: path of the log output file, or `""` if the log should write to stdout instead, optional
    + `mode`: PRETTY for human-readable output, CSV for csv output (only recommended when logging to a file), optional
    + `options`: tuple of FormattingOptions, optional

    ## Returns
    `true` if initialization was successful, `false` otherwise
    """
    function init(path::String, mode::FormattingMode, options::FormattingOptions...) ::Bool

        @lock detail._init_lock begin

            if path != ""
                detail.eval(:(_stream = open($path, append=true, truncate=false)))
            else
                detail.eval(:(_stream = stdout))
            end
        end

        Log.write(detail._initialization_message)
        out = isopen(detail._stream)

        if !out
           Log.write("in Log.init(" * path * ") : initialization failed.")
        end
        return out
    end
    export init

    init() = init("", PRETTY, TIMESTAMP)
    init(path::String) = init(path, PRETTY, TIMESTAMP, DATESTAMP)

    """
    `quit() -> Bool`

    safely exist the logging environment

    ## Returns
    `true` if shutdown was successful, false otherwise
    """
    function quit() ::Bool

        Log.write(detail._shutdown_message)

        try
            lock(detail._task_storage_lock)
            lock(detail._init_lock)

            for task in detail._task_storage
                wait(task)
            end

            empty!(detail._task_storage)

            if detail._stream isa IOStream
                close(detail._stream)
            end

            return true
        catch (_)
            return false
        end
    end
end