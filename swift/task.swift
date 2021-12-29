import Cocoa

let args = CommandLine.arguments

func help() {
    print("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics")
}

let getFileData = { (whichFile: Bool) -> [String] in
  let url = FileManager.default.currentDirectoryPath + (whichFile ? "/completed.txt" : "/task.txt")
  var data: [String] = []
  do {
    let savedData = try String(contentsOfFile: url)
    data = savedData.components(separatedBy: "\n")
    data = data.filter({ !$0.isEmpty })
  } catch { }
  return data
}

let getRemainingTasks = { (whichFile: Bool, displayCount: Bool) in
  let data = getFileData(whichFile)
  let size = data.count
  if displayCount {
    print(whichFile ? "Completed : \(size)" : "Pending : \(size)")
  } else if size == 0 {
    print("There are no pending tasks!")
    return
  }
  for i in 0..<size {
    let item = data[i]
    print(whichFile ? "\(i+1). \(item)" : "\(i+1).\(item[item.firstIndex(of: " ")!...]) [\(item[..<item.firstIndex(of: " ")!])]")
  }
}

let setFileData = { (whichFile: Bool, data: [String]) in
  let lines = data.joined(separator: "\n")
  let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath + (whichFile ? "/completed.txt" : "/task.txt"))
  do {
    try lines.write(to: url, atomically: false, encoding: .utf8)
  } catch {
    print("Couldn't write to file")
  }
}

let setNewTask = { (priority: String, task: String, dir: String) in
  let pr = Int(priority) ?? -1
  guard pr > -1 else {
    print("Invalid priority")
    return
  }
  var ndx = 0
  var data = getFileData(false)
  data.forEach { item in
    let p = Int(item.prefix(upTo: item.firstIndex(of: " ")!)) ?? -1
    guard p > -1 else {
      return
    }
    if pr<p {
      return
    }
    ndx+=1
  }
  data.insert("\(priority) \(task)", at: ndx)
  setFileData(false, data)
  print("Added task: \"\(task)\" with priority \(priority)")
}

let deleteTask = { (index: String) -> String? in
  let ndx = Int(index) ?? -1
  var data = getFileData(false)
  guard ndx > 0 && ndx <= data.count else {
    return nil
  }
  var deletedItem = data[ndx-1]
  deletedItem = String(deletedItem.suffix(from: deletedItem.firstIndex(of: " ")!)).trimmingCharacters(in: .whitespacesAndNewlines)
  data.remove(at: ndx-1)
  setFileData(false, data)
  return deletedItem
}

let setCompleted = { (index: String) in
  let deletedItem = deleteTask(index)
  guard deletedItem != nil else {
    print("Error: no incomplete item with index #\(index) exists.")
    return
  }
  var data = getFileData(true)
  data.append(deletedItem!)
  setFileData(true, data)
  print("Marked item as done.")
}

let argc = CommandLine.argc
switch argc > 1 ? args[1] : "" {
case "ls":
    getRemainingTasks(false, false)
case "add":
  if (argc > 3) {
    setNewTask(args[2], args[3], args[0])
  } else {
    print("Error: Missing tasks string. Nothing added!")
  }
case "del":
  if (argc > 2) {
    if (deleteTask(args[2]) != nil) {
      print("Deleted task #\(args[2])")
    }
    else {
      print("Error: task with index #\(args[2]) does not exist. Nothing deleted.")
    }
  }
  else {
    print("Error: Missing NUMBER for deleting tasks.")
  }
case "done":
  if (argc > 2) {
    setCompleted(args[2])
  }
  else {
    print("Error: Missing NUMBER for marking tasks as done.")
  }
case "report":
  getRemainingTasks(false, true)
  print()
  getRemainingTasks(true, true)
default:
    help()
}