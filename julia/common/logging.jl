#
# Copyright 2022 Clemens Cords
# Created on 14.05.2022 by clem (mail@clemens-cords.com)
#

"""
logging utilities, supports concurrent environments
"""
module Log

    """
    enum of formatting options, decides additional log contents

    ## Values
    - `LABEL`: addes type of log message (LOG, WARNING, EXCEPTION, ERROR) as label
    - `TIMESTAMP`: adds a timestamp of the form "<hour>:<minute>:<second>"
    - `DATESTAMP`: adds a date of the from "<day>/<month>"
    - `THREADID`: native handle of current thread
    """
    @enum FormattingOptions begin
        LABEL      = UInt32(1) << 0 # print label
        TIMESTAMP  = UInt32(1) << 1 # print current time
        DATESTAMP  = UInt32(1) << 2 # print current date
        THREADID   = UInt32(1) << 3 # print id of thread write was called from
    end
    export FormattingOptions
    export LABEL
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
    export FormattingMode
    export PRETTY
    export CSV

    """
    enum of message types, if in PRETTY mode, colors of log output will be adjusted as followss:

    ## Values
    - `LOG`: grey text with `[LOG]` prefix
    - `WARNING`: yellow text with `[WARNING]` prefix
    - `EXCEPTION`: red text with `[EXCEPTION]` prefix
    - `ERROR`: blinking red text with `[ERROR]` prefix
    """
    @enum MessageType begin
        LOG
        WARNING
        EXCEPTION
        ERROR
    end
    export MessageType
    export LOG
    export WARNING
    export EXCEPTION
    export ERROR

    """
    internal implementation details, end-users should not interact with anything in this module
    """
    module detail

        using Dates
        using Main.Log
        using Test
        using DataStructures

        const _init_lock = Base.ReentrantLock()
        _mode = Log.PRETTY
        _options = Log.FormattingOptions[TIMESTAMP]

        const _task_storage = Queue{Task}()
        const _task_storage_lock = Base.ReentrantLock()

        _stream = stdout
        const _stream_lock = Base.ReentrantLock()

        const _csv_delimiter = ","
        _csv_header = ""
        const _initialization_message = "### LOGGING INITIALIZED ###"
        const _shutdown_message = "### LOGGING SHUTDOWN ###"
        const _log_label = "[LOG]"
        const _warning_label = "[WARNING]"
        const _exception_label = "[EXCEPTION]"
        const _error_label = "[FATAL]"

        """
        `append(type::MessageType, message::String) -> Nothing`

        append a message to the log stream

        ## Arguments
        + `type`: Message Type
        + `message`: raw string
        """
        function append(type::MessageType, message::String) ::Nothing

            lock(_task_storage_lock)

            # cleanup finished tasks
            while !isempty(detail._task_storage) && istaskdone(first(detail._task_storage))
                dequeue!(detail._task_storage)
            end

            enqueue!(_task_storage, Task(() -> begin

                out::String = ""
                m = deepcopy(message)
                now = Dates.now()

                function add_zero(num) ::String
                    out = ""
                    if num < 10 out *= "0" end
                    return out * string(num)
                end

                if _mode == CSV

                    # type
                    if LABEL in _options
                        out *= string(type) * detail._csv_delimiter
                    end

                    # day, month
                    if DATESTAMP in _options
                        out *= string(Dates.day(now)) * detail._csv_delimiter
                        out *= string(Dates.month(now)) * detail._csv_delimiter
                    end

                    # time
                    if TIMESTAMP in _options
                        out *= string(Dates.format(Dates.now(), DateFormat("H:M:S.MS"))) * detail._csv_delimiter
                    end

                    # thread_id
                    if THREADID in _options
                        out *= string(Threads.threadid()) * detail._csv_delimiter
                    end

                    # message
                    out *= message * "\n"

                    @lock _stream_lock begin
                        Base.write(_stream, out)
                        flush(_stream)
                    end

                elseif _mode == PRETTY

                    if LABEL in _options
                        if type == LOG
                            out *= _log_label
                        elseif type == WARNING
                            out *= _warning_label
                        elseif type == EXCEPTION
                            out *= _exception_label
                        elseif type == ERROR
                            out *= _error_label
                        end
                    end

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

                    if !(_stream isa IOStream) # use colors if printing to stdout

                        @lock _stream_lock begin

                            if type == LOG
                                printstyled(detail._stream, out)
                                printstyled(detail._stream, m, color=:green)
                            elseif type == WARNING
                                printstyled(detail._stream, out)
                                printstyled(detail._stream, m, color=:yellow)
                            elseif type == EXCEPTION
                                printstyled(detail._stream, out)
                                printstyled(detail._stream, m, color=:red)
                            elseif type == ERROR
                                printstyled(detail._stream, out)
                                printstyled(detail._stream, m, color=:red, blink=true)
                            end
                            print("\n")
                            flush(detail._stream)
                        end
                    else
                        @lock _stream_lock begin
                            Base.write(_stream, out)
                            flush(_stream)
                        end
                    end
                end
            end))

            # when running non-concurrently, immediately evaluate in main
            if Threads.nthreads() == 1
                schedule(last(_task_storage))
                wait(last(_task_storage))
            else
                last(_task_storage).sticky = false
                schedule(last(_task_storage))
            end

            unlock(_task_storage_lock)
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

                Log.init(Base.Filesystem.pwd() * "/_.log", CSV, [Log.TIMESTAMP, Log.DATESTAMP, Log.THREADID])

                Test.@test Base.Filesystem.isfile(Log.detail._stream)
                Test.@test isopen(Log.detail._stream)

                Log.write("test line")
                Log.quit()
                Test.@test !isopen(Log.detail._stream)

                file = open(Base.Filesystem.pwd() * "/_.log", read=true)

                Test.@test occursin(_csv_header, readline(file, keep=true))
                Test.@test occursin(Log.detail._initialization_message, readline(file))
                Test.@test occursin("test line", readline(file))

                finally Base.Filesystem.rm(Base.Filesystem.pwd() * "/_.log") end
            end
            return nothing
        end
        # no export
    end

    """
    `write(::Any..., [message_type::MessageType]) -> Nothing`

    write to the log stream. If julia was initialized with more than 1 thread,
    writing is concurrent.

    ## Arguments
    + `xs...`: any number of objects, will be converted to strings, similar to Base.print
    + `message_type`: [optional] one of LOG, WARNING, EXCEPTION, ERROR
    """
    function write(xs...; type::MessageType = LOG)

        if length(xs) == 1 && string(getindex(xs, 1)) == ""
            return nothing
        end

        detail.append(type, prod(string.([xs...])))
        yield()
    end
    export write

    """
    `initialize([path::String], [mode::FormattingMode], [options::Vector{FormattingOptions}]) -> Bool`

    initialize the logging environment

    ## Arguments
    + `path`: [optional] path of the log output file, or `""` if the log should write to stdout instead
    + `mode`: [optional] PRETTY for human-readable output, CSV for csv output (only recommended when logging to a file)
    + `options`: [optional] tuple of FormattingOptions

    ## Returns
    `true` if initialization was successful, `false` otherwise
    """
    function init(
        path::String = "",
        mode::FormattingMode = PRETTY,
        options::Vector{FormattingOptions} = [LABEL, TIMESTAMP]
    ) ::Bool

        @lock detail._init_lock begin

            if path != ""
                detail.eval(:(_stream = open($path, append=true, truncate=true)))
            else
                detail.eval(:(_stream = stdout))
            end

            detail.eval(:(_mode = $mode))
            detail.eval(:(_options = $options))

            if mode == CSV

                csv_header = ""
                csv_header *= "type" * detail._csv_delimiter

                if DATESTAMP in options
                   csv_header *= "day" * detail._csv_delimiter
                   csv_header *= "month" * detail._csv_delimiter
                end

                if TIMESTAMP in options
                    csv_header *= "time" * detail._csv_delimiter
                end

                if THREADID in options
                    csv_header *= "thread_id" * detail._csv_delimiter
                end

                csv_header *= "message" * "\n"

                detail.eval(:(_csv_header = $csv_header))
            end
        end

        out = isopen(detail._stream)

        if !out
           Log.write("in Log.init(" * path * ") : initialization failed.")
        else
            if mode == CSV
                Base.write(detail._stream, detail._csv_header)
            end
            Log.write(detail._initialization_message)
        end
        return out
    end
    export init

    """
    `quit() -> Bool`

    safely exist the logging environment

    ## Returns
    `true` if shutdown was successful, false otherwise
    """
    function quit() ::Bool

        for task in detail._task_storage
            wait(task)
        end
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

# usage

# pretty printing
Log.init("")
Log.write("this is a message")
Log.write("this is a warning"; type=Log.WARNING)
Log.write("this is an exception"; type=Log.EXCEPTION)
Log.write("this is an error"; type=Log.ERROR)
Log.quit()

# csv output
Log.init("test.log", Log.CSV, [Log.TIMESTAMP, Log.DATESTAMP, Log.THREADID])
Log.write("this is a message")
Log.write("this is a warning"; type=Log.WARNING)
Log.write("this is an exception"; type=Log.EXCEPTION)
Log.write("this is an error"; type=Log.ERROR)
Log.quit()