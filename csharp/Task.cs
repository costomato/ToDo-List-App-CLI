using System;
using System.IO;
using System.Collections;

class Task
{
    static void Main(string[] args)
    {
        Task task = new Task();
        string primaryArg = args.Length > 0 ? args[0] : "";
        switch (primaryArg)
        {
            case "ls":
                task.GetRemainingTasks(false, false);
                break;
            case "add":
                if (args.Length > 2)
                    task.SetNewTask(args[1], args[2]);
                else
                    Console.WriteLine("Error: Missing tasks string. Nothing added!");
                break;
            case "del":
                if (args.Length > 1)
                {
                    if (task.DeleteTask(args[1]) != null)
                        Console.WriteLine("Deleted task #" + args[1]);
                    else
                        Console.WriteLine("Error: task with index #" + args[1] + " does not exist. Nothing deleted.");
                }
                else
                    Console.WriteLine("Error: Missing NUMBER for deleting tasks.");
                break;
            case "done":
                if (args.Length > 1)
                    task.SetCompleted(args[1]);
                else
                    Console.WriteLine("Error: Missing NUMBER for marking tasks as done.");
                break;
            case "report":
                task.GetRemainingTasks(false, true);
                Console.WriteLine();
                task.GetRemainingTasks(true, true);
                break;
            default:
                task.help();
                break;
        }
    }
    private void help()
    {
        Console.WriteLine(
            "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics");
    }
    private ArrayList GetFileData(bool whichFile)
    {
        ArrayList data = new ArrayList();
        StreamReader sr;
        try
        {
            sr = new StreamReader(whichFile ? "completed.txt" : "task.txt");
        }
        catch (Exception)
        {
            return data;
        }
        string line;
        while ((line = sr.ReadLine()) != null)
        {
            line = line.Trim();
            if (line == String.Empty)
                continue;

            data.Add(line);
        }
        sr.Close();
        return data;
    }
    private void GetRemainingTasks(bool whichFile, bool displayQuantity)
    {
        ArrayList data = GetFileData(whichFile);
        int size = data.Count;
        if (displayQuantity)
            Console.WriteLine(whichFile ? $"Completed : {size}" : $"Pending : {size}");
        else if (size == 0)
        {
            Console.WriteLine("There are no pending tasks!");
            return;
        }
        for (int i = 0; i < size; i++)
        {
            string item = (string)data[i];
            Console.WriteLine(whichFile ? (i + 1) + ". " + item : (i + 1) + ". " + item.Substring(item.IndexOf(" ") + 1) + " [" + item.Substring(0, item.IndexOf(" ")) + "]");
        }
    }
    private string DeleteTask(string index)
    {
        ArrayList data = GetFileData(false);
        int ndx = 0;
        if (!Int32.TryParse(index, out ndx))
            return null;

        if (ndx < 1 || ndx > data.Count)
            return null;

        string deletedItem = (string)data[ndx - 1];
        deletedItem = deletedItem.Substring(deletedItem.IndexOf(" ") + 1);
        data.RemoveAt(ndx - 1);
        File.WriteAllLines("task.txt", (string[])data.ToArray(typeof(string)));

        return deletedItem;
    }
    private void SetNewTask(string priority, string task)
    {
        int p = 0;
        if (!Int32.TryParse(priority, out p))
        {
            Console.WriteLine("Invalid index");
            return;
        }
        ArrayList data = GetFileData(false);
        int ndx = 0;
        foreach (string line in data)
        {
            int pr = 0;
            if (!Int32.TryParse(line.Substring(0, line.IndexOf(" ")), out pr))
                continue;
            if (p < pr)
                break;
            ndx++;
        }
        data.Insert(ndx, $"{priority} {task}");
        File.WriteAllLines("task.txt", (string[])data.ToArray(typeof(string)));
        Console.WriteLine($"Added task: \"{task}\" with priority {priority}");
    }
    private void SetCompleted(string index)
    {
        string deletedItem = DeleteTask(index);
        if (deletedItem == null)
        {
            Console.WriteLine($"Error: no incomplete item with index #{index} exists.");
            return;
        }
        using (StreamWriter sw = File.AppendText("completed.txt"))
            sw.WriteLine(deletedItem);
        Console.WriteLine("Marked item as done.");
    }
}
