import 'dart:io';

main(List<String> args) {
  String primaryArg = args.length > 0 ? args[0] : "";
  switch (primaryArg) {
    case "ls":
      getRemainingTasks(false);
      break;
    case "add":
      if (args.length > 2)
        setNewTask(args[1], args[2]);
      else
        print("Error: Missing tasks string. Nothing added!");
      break;
    case "del":
      if (args.length > 1) {
        if (deleteTask(args[1]) != null)
          print("Deleted task #${args[1]}");
        else
          print(
              "Error: task with index #${args[1]} does not exist. Nothing deleted.");
      } else
        print("Error: Missing NUMBER for deleting tasks.");
      break;
    case "done":
      if (args.length > 1)
        setCompleted(args[1]);
      else
        print("Error: Missing NUMBER for marking tasks as done.");
      break;
    case "report":
      getRemainingTasks(false, true);
      print("");
      getRemainingTasks(true, true);
      break;
    default:
      help();
  }
}

help() {
  print(
      "Usage :-\n\$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n\$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n\$ ./task del INDEX            # Delete the incomplete item with the given index\n\$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n\$ ./task help                 # Show usage\n\$ ./task report               # Statistics");
}

List<String> getFileData(bool whichFile) {
  File fr = File(whichFile ? "completed.txt" : "task.txt");
  return fr.existsSync() ? fr.readAsLinesSync() : [];
}

setFileData(List<String> data) {
  File fr = File("task.txt");
  fr.writeAsStringSync(data.join("\n"));
}

getRemainingTasks(bool whichFile, [bool displayQuantity = false]) {
  List<String> data = getFileData(whichFile);
  if (displayQuantity)
    print(
        whichFile ? "Completed : ${data.length}" : "Pending : ${data.length}");
  else if (data.isEmpty) print("There are no pending tasks!");

  for (int i = 0; i < data.length; i++) {
    String item = data[i];
    print(whichFile
        ? "${i + 1}. $item"
        : "${i + 1}. ${item.substring(item.indexOf(' ') + 1)} [${item.substring(0, item.indexOf(' '))}]");
  }
}

setNewTask(String priority, String task) {
  int pr;
  List<String> data = getFileData(false);
  try {
    pr = int.parse(priority);
  } catch (_) {
    print("Invalid priority");
    return;
  }
  int ndx = 0;
  for (final item in data) {
    int p;
    try {
      p = int.parse(item.substring(0, item.indexOf(" ")));
    } catch (_) {
      continue;
    }
    if (pr < p) break;
    ndx++;
  }
  data.insert(ndx, "$priority $task");
  setFileData(data);
  print("Added task: \"$task\" with priority $priority");
}

String? deleteTask(String index) {
  int ndx;
  try {
    ndx = int.parse(index);
  } catch (_) {
    return null;
  }
  List<String> data = getFileData(false);
  if (ndx < 1 || ndx > data.length) return null;
  String deletedItem = data[ndx - 1];
  deletedItem = deletedItem.substring(deletedItem.indexOf(' ') + 1);
  data.removeAt(ndx - 1);
  setFileData(data);
  return deletedItem;
}

setCompleted(String index) {
  String? deletedItem = deleteTask(index);
  if (deletedItem == null) {
    print("Error: no incomplete item with index #${index} exists.");
    return;
  }
  File("completed.txt")
      .writeAsStringSync("$deletedItem\n", mode: FileMode.append);
  print("Marked item as done.");
}
