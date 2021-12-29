import sys

FILE_REMAINING = 'task.txt'
FILE_COMPLETED = 'completed.txt'
args = sys.argv

def help():
    print("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics")


def getRemainingTasks(fileName, displayQuantity=None):
    try:
        with open(fileName, 'r') as fr:
            data = fr.readlines()
    except:
        data = []

    if not data and args[1] == 'ls':
        print('There are no pending tasks!')
        return

    if displayQuantity:
        if fileName == FILE_REMAINING:
            print('Pending :', len(data))
        else:
            print('Completed :', len(data))

    for i in range(len(data)):
        item = data[i]
        item = item.strip()
        if fileName == FILE_REMAINING:
            print('%s. %s [%s]' % (
                i+1, item[item.index(' ')+1:], item[0:item.index(' ')]))
        else:
            print('%s. %s' % (i+1, item))


def setNewTask(priority, task):
    try:
        with open(FILE_REMAINING, 'r') as fr:
            data = fr.readlines()
    except:
        data = []
    ndx = 0
    for item in data:
        if priority < item[0:item.index(' ')]:
            break
        ndx += 1
    if not data:
        fullTask = str(priority)+' '+task
    elif ndx == len(data):
        fullTask = '\n'+str(priority)+' '+task
    else:
        fullTask = str(priority)+' '+task+'\n'
    data.insert(ndx, fullTask)
    newData = ''.join(data)

    with open(FILE_REMAINING, 'w') as fr:
        fr.write(newData)
    print('Added task: "%s" with priority %s' % (task, priority))


def deleteTask(index):
    try:
        with open(FILE_REMAINING, 'r') as fr:
            data = fr.readlines()
    except:
        data = []

    try:
        index = int(index)
    except:
        print("Enter a valid index")
        return
    if index < 1 or index > len(data):
        return
    deletedItem = data[index-1]
    deletedItem = deletedItem[deletedItem.index(' ')+1:]
    del data[index-1]
    newData = ''.join(data)
    with open(FILE_REMAINING, 'w') as fr:
        fr.write(newData)
    return deletedItem


def setCompleted(index):
    deletedItem = deleteTask(index)
    if not deletedItem:
        print('Error: no incomplete item with index #%s exists.' % index, end='')
        return
    deletedItem = deletedItem.strip()
    with open(FILE_COMPLETED, 'a') as fc:
        fc.write(deletedItem+'\n')
    print("Marked item as done.")


primaryArg = None
if len(args) > 1:
    primaryArg = args[1]

if primaryArg == 'ls':
    getRemainingTasks(FILE_REMAINING)
elif primaryArg == 'add':
    if len(args) > 3:
        if args[3] >= '0':
            setNewTask(args[2], args[3])
        else:
            print('Priority cannot be negative')

    else:
        print("Error: Missing tasks string. Nothing added!")
elif primaryArg == 'del':
    if len(args) > 2:
        if deleteTask(args[2]):
            print('Deleted task #%s' % args[2], end='')
        else:
            print(
                'Error: task with index #%s does not exist. Nothing deleted.' % args[2], end='')

    else:
        print("Error: Missing NUMBER for deleting tasks.")

elif primaryArg == 'done':
    if len(args) > 2:
        setCompleted(args[2])
    else:
        print("Error: Missing NUMBER for marking tasks as done.")

elif primaryArg == 'report':
    getRemainingTasks(FILE_REMAINING, True)
    print()
    getRemainingTasks(FILE_COMPLETED, True)

else:
    help()
