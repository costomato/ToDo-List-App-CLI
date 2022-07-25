function getfiledata(whichfile)
    try
        f = open(if whichfile "completed.txt" else "task.txt" end, "r")
        data = filter((i) -> !isempty(strip(i)), readlines(f))
        close(f)
        return data
    catch
        return []
    end
end

function setfiledata(data)
    try
        f = open("task.txt", "w")
        write(f, join(data, "\n"))
        close(f)
    catch
        println("Error writing to file!")
        return
    end
end

function createtask(priority, task)
    data = getfiledata(false)
    pri = parse(Int32, priority)
    ndx = 1
    for i = 1:length(data)
        item = data[i]
        if pri < parse(Int32, item[1:findfirst(" ", item)[1]])
            break
        end
        ndx+=1
    end
    insert!(data, ndx, priority * " " * task)
    setfiledata(data)
    println("Added task: \"$task\" with priority $priority")
end

function readtasks(whichfile, displayquantity)
    data = getfiledata(whichfile)
    size = length(data)
    if displayquantity
        println(if whichfile "Completed : $size" else "Pending : $size" end)
    elseif size == 0
        println("There are no pending tasks!")
    end
    for i = 1:size
        item = data[i]
        ndx = if !whichfile findfirst(" ", item)[1] end
        println(if whichfile "$i. $item" else "$i. $(item[ndx+1:length(item)]) [$(item[1:ndx-1])]" end)
    end
end

function deletetask(index)
    data = getfiledata(false)
    try
        index = parse(Int32, index)
    catch
        println("Invalid task number")
        return nothing
    end
    if index < 1 || index > length(data)
        println("Invalid index")
        return nothing
    end
    deleteditem = data[index]
    deleteditem = deleteditem[findfirst(" ", deleteditem)[1]+1 : length(deleteditem)]
    deleteat!(data, index)
    setfiledata(data)
    return deleteditem
end

function updatetask(index)
    deleteditem = deletetask(index)
    if deleteditem === nothing
        println("Error: no incomplete item with index #$index exists.")
        return
    end
    f = open("completed.txt", "a")
    write(f, "$deleteditem\n")
    println("Marked item as done.")

    close(f)
end

function help()
    println("Usage :-\n\$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n\$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n\$ ./task del INDEX            # Delete the incomplete item with the given index\n\$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n\$ ./task help                 # Show usage\n\$ ./task report               # Statistics")
end

function main()
    size = length(ARGS)
    primaryArg = if size > 0 ARGS[1] else "" end
    if primaryArg == "ls"
        readtasks(false, false)
    elseif primaryArg == "add"
        if size > 2
            createtask(ARGS[2], ARGS[3])
        else
            println("Error: Missing tasks string. Nothing added!")
        end
    elseif primaryArg == "del"
        if size > 1
            if deletetask(ARGS[2]) === nothing
                println("Error: task with index #$(ARGS[2]) does not exist. Nothing deleted.")
            else
                println("Deleted task #" * ARGS[2])
            end
        else
            println("Error: Missing NUMBER for deleting tasks.")
        end
    elseif primaryArg == "done"
        if size > 1
            updatetask(ARGS[2])
        else
            println("Error: Missing NUMBER for marking tasks as done.")
        end
    elseif primaryArg == "report"
        readtasks(false, true)
        println()
        readtasks(true, true)
    else
        help()
    end
end
main()