const args = process.argv
const fs = require('fs')
const FILE_REMAINING = 'task.txt'
const FILE_COMPLETED = 'completed.txt'

fs.openSync(FILE_REMAINING, 'a+')
fs.openSync(FILE_COMPLETED, 'a+')

const help = () => {
    process.stdout.write("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics")
}

const getRemainingTasks = (fileName, displayQuantity) => {
    let data = fs.readFileSync(fileName, 'utf-8')
    data = data.split("\n")
    if (data[data.length - 1] == '')
        data.splice(data.length - 1, 1)

    if (displayQuantity) {
        if (fileName == FILE_REMAINING)
            console.log(`Pending : ${data.length}`)
        else
            console.log(`Completed : ${data.length}`)
    }else if (data.length == 0) {
        console.log("There are no pending tasks!")
        return
    }

    let item
    for (let i = 0; i < data.length; i++) {
        item = data[i]
        if (item) {
            if (fileName == FILE_REMAINING)
                console.log(`${i + 1}. ${item.substring(item.indexOf(' ') + 1)} [${item.substring(0, item.indexOf(' '))}]`)
            else
                console.log(`${i + 1}. ${item}`)
        }
    }
}

const setNewTask = (priority, task) => {
    let data = fs.readFileSync(FILE_REMAINING, 'utf-8')
    data = data.split("\n")
    let ndx = 0
    data.forEach(item => {
        if (priority < item.substring(0, item.indexOf(' ')))
            return
        ndx++
    })

    data.splice(ndx, 0, `${priority} ${task}`)

    let newData = ''
    for (let i = 0; i < data.length; i++) {
        if (data[i] == '')
            continue
        newData += i < data.length - 1 ? `${data[i]}\n` : data[i]
    }

    fs.writeFileSync(FILE_REMAINING, newData)
    console.log(`Added task: "${task}" with priority ${priority}`);
}
const deleteTask = (index) => {
    let data = fs.readFileSync(FILE_REMAINING, 'utf-8')
    data = data.split("\n")
    if (index < 1 || index > data.length || data[0] == '') {
        return
    }
    let deletedItem = data[index - 1]
    deletedItem = deletedItem.substring(deletedItem.indexOf(' ') + 1)
    data.splice(index - 1, 1)

    let newData = ''
    for (let i = 0; i < data.length; i++) {
        if (data[i] == '')
            continue
        newData += i < data.length - 1 ? `${data[i]}\n` : data[i]
    }

    fs.writeFileSync(FILE_REMAINING, newData)

    return deletedItem
}

const setCompleted = (index) => {
    const deletedItem = deleteTask(index)
    if (!deletedItem) {
        console.log(`Error: no incomplete item with index #${index} exists.`);
        return
    }
    fs.appendFileSync(FILE_COMPLETED, `${deletedItem}\n`)
    console.log("Marked item as done.")
}

switch (args[2]) {
    case 'help':
        help()
        break;
    case 'ls':
        getRemainingTasks(FILE_REMAINING);
        break;
    case 'add':
        if (args[3] && args[4]) {
            if (args[3] >= '0')
                setNewTask(args[3], args[4])
            else
                console.log('Priority cannot be negative')
        }
        else
            console.log("Error: Missing tasks string. Nothing added!")
        break;
    case 'del':
        if (args[3]) {
            if (deleteTask(args[3]))
                console.log(`Deleted task #${args[3]}`);
            else
                console.log(`Error: task with index #${args[3]} does not exist. Nothing deleted.`);
        }
        else
            console.log("Error: Missing NUMBER for deleting tasks.")
        break;
    case 'done':
        if (args[3])
            setCompleted(args[3])
        else
            console.log("Error: Missing NUMBER for marking tasks as done.")
        break;
    case 'report':
        getRemainingTasks(FILE_REMAINING, true)
        console.log()
        getRemainingTasks(FILE_COMPLETED, true)
        break;
    default:
        help()
}