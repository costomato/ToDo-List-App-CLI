import java.io.File
import kotlin.text.substring

fun main(args: Array<String>) {
    val primaryArg = if (args.size > 0) args[0] else ""
    when (primaryArg) {
        "ls" -> getRemainingTasks(false)
        "add" -> {
            if (args.size > 2) {
                setNewTask(args[1], args[2])
            } else println("Error: Missing tasks string. Nothing added!")
        }
        "del" -> {
            if (args.size > 1) {
                if (deleteTask(args[1]) != null) println("Deleted task #" + args[1])
                else
                        println(
                                "Error: task with index #" +
                                        args[1] +
                                        " does not exist. Nothing deleted."
                        )
            } else println("Error: Missing NUMBER for deleting tasks.")
        }
        "done" -> {
            if (args.size > 1) setCompleted(args[1])
            else println("Error: Missing NUMBER for marking tasks as done.")
        }
        "report" -> {
            getRemainingTasks(false, true)
            println()
            getRemainingTasks(true, true)
        }
        else -> help()
    }
}

private fun getFileData(whichFile: Boolean): ArrayList<String> {
    val data = ArrayList<String>()
    try {
        File(if (whichFile) "completed.txt" else "task.txt").forEachLine {
            if (it.trim().isEmpty()) return@forEachLine
            data.add(it.trim())
        }
    } catch (e: Exception) {}
    return data
}

private fun getRemainingTasks(whichFile: Boolean, displayQuantity: Boolean = false) {
    val data = getFileData(whichFile)

    if (data.isEmpty() && !displayQuantity) {
        println("There are no pending tasks!")
        return
    }
    if (displayQuantity)
            if (whichFile) println("Completed : ${data.size}")
            else println("Pending : ${data.size}")

    for (i in 0 until data.size) {
        val item = data.get(i).trim()
        println(
                if (whichFile) "${i+1}. ${item}"
                else
                        "${i+1}. ${item.substring(item.indexOf(" ") + 1)} [${item.substring(0, item.indexOf(" "))}]"
        )
    }
}

private fun setNewTask(priority: String, task: String) {
    val pri =
            try {
                priority.toInt()
            } catch (e: Exception) {
                println("Invalid priority")
                return
            }
    val data = getFileData(false)
    var ndx = 0
    for (it in data) {
        val p =
                try {
                    it.substring(0, it.indexOf(" ")).toInt()
                } catch (e: Exception) {
                    return
                }
        if (pri < p) break
        ndx++
    }
    data.add(ndx, "${pri} ${task}")
    File("task.txt").writeText(data.joinToString(separator = "\n"))
    println("Added task: \"${task}\" with priority ${priority}")
}

private fun deleteTask(index: String): String? {
    val ndx =
            try {
                index.toInt()
            } catch (e: Exception) {
                return null
            }

    val data = getFileData(false)
    if (ndx < 1 || ndx > data.size) return null
    var deletedItem = data[ndx - 1]
    deletedItem = deletedItem.substring(deletedItem.indexOf(" ") + 1)
    data.removeAt(ndx - 1)
    File("task.txt").writeText(data.joinToString(separator = "\n"))
    return deletedItem
}

private fun setCompleted(index: String) {
    val deletedItem = deleteTask(index)
    if (deletedItem == null) {
        println("Error: no incomplete item with index #${index} exists.")
        return
    }
    File("completed.txt").appendText("$deletedItem\n")
    println("Marked item as done.")
}

private fun help() {
    print(
            "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics"
    )
}
