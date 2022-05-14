#
# Copyright 2022 Clemens Cords
# Created on 14.05.2022 by clem (mail@clemens-cords.com)
#

include("macros.jl")

module Log

    @enum FormattingOptions begin
        PRETTY     = 1 << 0 # enable colors
        TIMESTAMP  = 1 << 1 # print current date and time
        THREADID   = 1 << 2 # print id of thread write was called from
        CSV        = 1 << 3 # print in CSV format instead
    end
    export FormattingOptions
    export PRETTY
    export TIMESTAMP
    export THREADID
    export CSV

    module detail

        using Dates
        using DataStructures
        using Main.Log

        _stream_lock = Base.ReentrantLock()
        # _stream = <created during Log.initialize>

        _dateformat = Dates.DateFormat("d/m|H:M:S")
        _csv_delimiter = ","

        _queue_add_lock = Base.ReentrantLock()
        _queue = Queue{String}()

        _aborting = false
        _queue_cv = Threads.Condition()
        _queue_cv_lock = Base.ReentrantLock()
        _queue_worker = Threads.@spawn begin
            while true

                if _aborting return end


                lock(_queue_cv.lock)

                try
                    wait(_queue_cv)
                    if !isempty(_queue)

                        write(_stream, dequeue!(_queue))
                        flush(_stream)
                    end
                finally
                    unlock(_queue_cv.lock)
                end
            end
        end

        function append(message::String, options::FormattingOptions...) ::Nothing

            out::String = ""

            if CSV in options

                # header: day,month,time,thread_id,message
                now = Dates.now()

                out *= string(Dates.day(now)) * detail._csv_delimiter
                out *= string(Dates.month(now)) * detail._csv_delimiter
                out *= string(Dates.format(Dates.now(), DateFormat("H:M:S:MS"))) * detail._csv_delimiter
                out *= string(Threads.threadid()) * detail._csv_delimiter
            else
                if TIMESTAMP in options
                    out *= "["
                    out *= Dates.format(Dates.now(), detail._dateformat)
                    out *= "]"
                end

                if THREADID in options
                    out *= "[" * Threads.threadid() * "]"
                end

                if length(options) > 1 # more than one char left of the message
                    out *= " "
                end
            end

            out *= message
            enqueue!(_queue, out)

            lock(_queue_cv.lock)
            notify(_queue_cv)
            unlock(_queue_cv.lock)
        end

        return nothing
    end

    """
    `initialize([::String]) -> Bool`

    initialize the logging environment

    @param path: path of the log output file, optional
    @returns true if initialization was successful, false otherwise
    """
    function init(path::String = "") ::Nothing

        lock(detail._stream_lock)
        if path != ""
            detail.eval(:(_stream = open($path, append=true, truncate=false)))
        else
            detail.eval(:(_stream = stdout))
        end
        unlock(detail._stream_lock)
    end
    export init

    """
    `quit() -> nothing`

    safely exist the logging environment
    """
    function quit()

        detail._abort = true

        lock(detail._queue.lock)
        while !isempty(detail._queue)
            notify(detail._queue_cv)
        end
        unlock(detail._queue.lock);

        #lock(_stream_lock)
        flush(_stream)
        close(_stream)
        #unlock(_stream_lock)
    end
    export quit


    """
    `write(::Any...) -> Nothing`

    write a number of objects as a string to the log stream
    """
    function write(xs...) ::Nothing

        towrite = prod(string.([xs...]))
        detail.append(towrite, PRETTY, TIMESTAMP)

        lock(detail._queue_cv.lock)
        notify(detail._queue_cv)
        unlock(detail._queue_cv.lock)
        return nothing
    end
end

import Base.Filesystem
Log.init("") #""Filesystem.pwd() * "/test.log")
Log.write("test a", 12321, "testbs")
