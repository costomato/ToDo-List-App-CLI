<?php
main();
function main()
{
    global $argv;
    global $argc;
    switch ($argc > 1 ? $argv[1] : "") {
        case "ls":
            read_tasks(false, false);
            break;
        case "add":
            if ($argc > 3) {
                if ($argv[2] >= "0")
                    create_task($argv[2], $argv[3]);
                else
                    echo "Priority cannot be negative\n";
            } else {
                echo "Error: Missing tasks string. Nothing added!\n";
            }
            break;
        case "del":
            if ($argc > 2) {
                if (delete_task($argv[2]))
                    echo "Deleted task #" . $argv[2] . "\n";
                else
                    echo "Error: task with index #" . $argv[2] . " does not exist. Nothing deleted.\n";
            } else
                echo "Error: Missing NUMBER for deleting tasks.\n";
            break;
        case "done":
            if ($argc > 2)
                update_task($argv[2]);
            else
                echo "Error: Missing NUMBER for marking tasks as done.\n";
            break;
        case "report":
            read_tasks(false, true);
            echo "\n";
            read_tasks(true, true);
            break;
        default:
            help();
    }
}

function get_file_data($which_file)
{
    if (!file_exists($which_file ? "completed.txt" : "task.txt"))
        return [];
    $data = explode("\n", file_get_contents($which_file ? "completed.txt" : "task.txt"));
    $data = array_filter($data, fn ($value) => !is_null($value) && $value !== '');
    return $data;
}

function set_file_data($data)
{
    file_put_contents('task.txt', implode(PHP_EOL, $data));
}

function create_task($priority, $task)
{
    $data = get_file_data(false);
    $ndx = 0;
    foreach ($data as $item) {
        $pos = strpos($item, " ");
        if ($priority < substr($item, 0, $pos))
            break;
        $ndx++;
    }
    array_splice($data, $ndx, 0, "$priority $task");
    set_file_data($data);
    echo "Added task: \"$task\" with priority $priority\n";
}

function read_tasks($which_file, $display_quantity)
{
    $data = get_file_data($which_file);
    $size = sizeof($data);
    if ($display_quantity)
        echo $which_file ? "Completed : $size\n" : "Pending : $size\n";
    else if ($size == 0)
        echo "There are no pending tasks!\n";
    for ($i = 0; $i < $size; $i++) {
        $item = $data[$i];
        $ndx = strpos($item, " ");
        echo $which_file ? ($i + 1) . ". " . $item . "\n" : ($i + 1) . ". " . substr($item, $ndx + 1) . " [" . substr($item, 0, $ndx) . "]\n";
    }
}

function update_task($index)
{
    $deleted_item = delete_task($index);
    if ($deleted_item == null) {
        echo "Error: no incomplete item with index #$index exists.\n";
        return;
    }
    file_put_contents('completed.txt', $deleted_item . PHP_EOL, FILE_APPEND | LOCK_EX);
    echo "Marked item as done.\n";
}

function delete_task($index)
{
    $data = get_file_data(false);
    if ($index < "1" || $index > sizeof($data))
        return;
    $deleted_item = $data[$index - 1];
    $deleted_item = substr($deleted_item, strpos($deleted_item, " ") + 1);
    unset($data[$index - 1]);
    set_file_data($data);
    return $deleted_item;
}

function help()
{
    echo "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics\n";
}
