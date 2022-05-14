#
# Copyright 2022 Clemens Cords
# Created on 14.05.2022 by clem (mail@clemens-cords.com)
#

include("macros.jl")

module Log

    """
    enum of formatting options

    ## Values
    - `PRETTY`: enables colors when printing (not available if logging to a file)
    - `TIMESTAMP`: adds a timestamp of the form "<hour>:<minute>:<second>"
    - `DATESTAMP`: adds a date of the from "<day>/<month>"
    - `CSV`: format output as CSV
    """
    @enum FormattingOptions begin
        PRETTY     = UInt32(1) << 0 # enable colors
        TIMESTAMP  = UInt32(1) << 1 # print current time
        DATESTAMP  = UInt32(1) << 2 # print current date
        THREADID   = UInt32(1) << 3 # print id of thread write was called from
        CSV        = UInt32(1) << 4 # print in CSV format instead
    end
    export FormattingOptions
    export PRETTY
    export TIMESTAMP
    export DATESTAMP
    export THREADID
    export CSV

    module detail

        using Dates
        using DataStructures
        using Main.Log
        using Test

        _stream = stdout

        _csv_delimiter = ","
        _initialization_message = "### LOGGING INITIALIZED ###"
        _shutdown_message = "### LOGGING SHUTDOWN ###"


        _queue_add_lock = Base.ReentrantLock()
        _queue = Queue{String}()

        _init_lock = Base.ReentrantLock()

        _aborting = false
        _queue_cv = Threads.Condition()
        _queue_cv_lock = Base.ReentrantLock()
        _queue_worker = Threads.@spawn begin

            while !_aborting
                @lock _queue_cv.lock begin
                    wait(_queue_cv)
                    while !isempty(_queue)
                        write(_stream, dequeue!(_queue))
                        flush(_stream)
                    end
                end
            end
        end


        """
        `abort() -> Nothing`

        Safely shutdown the queue worker, also flushes queue
        """
        function abort() ::Nothing
            _aborting = true
            Log.write(detail._shutdown_message)
            wait(_queue_worker)
            return nothing
        end

        """
        `append(message::String, [options::FormattingOptions...]) -> Nothing`

        append a message to the log stream

        ## Arguments
        + `message`: raw string
        + `options`: multiple formatting options, optional
        """
        function append(message::String, options::FormattingOptions...) ::Nothing

            out::String = ""
            now = Dates.now()

            function add_zero(num) ::String
                out = ""
                if num < 10 out *= "0" end
                return out * string(num)
            end

            if CSV in options

                # header: day,month,time,thread_id,message

                out *= string(Dates.day(now)) * detail._csv_delimiter
                out *= string(Dates.month(now)) * detail._csv_delimiter
                out *= string(Dates.format(Dates.now(), DateFormat("H:M:S:MS"))) * detail._csv_delimiter
                out *= string(Threads.threadid()) * detail._csv_delimiter
            else
                if TIMESTAMP in options
                    out *= "["
                    #out *= add_zero(Dates.day(now)) * "."
                    #out *= add_zero(Dates.month(now)) * "-"
                    #out *= "|"
                    out *= add_zero(Dates.hour(now)) * ":"
                    out *= add_zero(Dates.minute(now)) * ":"
                    out *= add_zero(Dates.second(now))
                    out *= "]"
                end

                if THREADID in options
                    out *= "[" * Threads.threadid() * "]"
                end

                if length(options) > 1 # more than one char left of the message
                    out *= " "
                end
            end

            out *= message * "\n"
            enqueue!(_queue, out)
            return nothing
        end

        using Test
        function test()

            Test.@testset "Logging" begin

                try

                Test.@test istaskstarted(Log.detail._queue_worker)

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
        end
    end

    """
    `initialize([path::String]) -> Bool`

    initialize the logging environment

    ## Arguments
    + `path`: path of the log output file, or `""` if the log should write to stdout instead

    ## Returns
    `true` if initialization was successful, `false` otherwise
    """
    function init(path::String = "") ::Bool

        out = false
        @lock detail._init_lock begin

            if path != ""
                detail.eval(:(_stream = open($path, append=true, truncate=false)))
            else
                detail.eval(:(_stream = stdout))
            end

            Log.write(detail._initialization_message)
            lock(detail._queue_cv.lock)
            notify(detail._queue_cv)
            unlock(detail._queue_cv.lock)

            out = isopen(detail._stream)
        end
        return out
    end
    export init

    """
    `quit() -> nothing`

    safely exist the logging environment
    """
    function quit() ::Nothing
        @lock detail._init_lock begin
            detail.abort()
            if detail._stream isa IOStream
                close(detail._stream)
            end
        end
        return nothing
    end
    export quit

    """
    `write(::Any...) -> Nothing`

    write to the log stream

    ## Arguments
    + `xs...`: any number of objects, will be converted to strings, similar to Base.print
    """
    function write(xs...) ::Nothing

        if length(xs) == 1 && string(getindex(xs, 1)) == ""
            return nothing
        end

        towrite = prod(string.([xs...]))
        Base.Task(detail.append(towrite, PRETTY, TIMESTAMP))

        lock(detail._queue_cv.lock)
        notify(detail._queue_cv)
        unlock(detail._queue_cv.lock)
        return nothing
    end
    export write
end

