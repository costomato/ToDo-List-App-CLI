import java.io.File;
import java.io.FileWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Scanner;

public class Task {
	private static final String FILE_REMAINING = "task.txt";
	private static final String FILE_COMPLETED = "completed.txt";

	public static void main(String args[]) {
		Task task = new Task();
		String primaryArg = args.length > 0 ? args[0] : "";
		switch (primaryArg) {
			case "ls":
				task.getRemainingTasks(FILE_REMAINING, false);
				break;
			case "add":
				if (args.length > 2) {
					if (args[0].compareTo("0") >= 0)
						task.setNewTask(args[1], args[2]);
					else
						System.out.println("Invalid priority");
				} else
					System.out.println("Error: Missing tasks string. Nothing added!");
				break;
			case "del":
				if (args.length > 1) {
					if (task.deleteTask(args[1]) != null)
						System.out.println("Deleted task #" + args[1]);
					else
						System.out.println("Error: task with index #" + args[1] + " does not exist. Nothing deleted.");
				} else
					System.out.println("Error: Missing NUMBER for deleting tasks.");
				break;
			case "done":
				if (args.length > 1)
					task.setCompleted(args[1]);
				else
					System.out.println("Error: Missing NUMBER for marking tasks as done.");
				break;
			case "report":
				task.getRemainingTasks(FILE_REMAINING, true);
				System.out.println();
				task.getRemainingTasks(FILE_COMPLETED, true);
				break;
			default:
				task.help();
		}
	}

	private void help() {
		System.out.print(
				"Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics");
	}

	private void getRemainingTasks(String fileName, boolean displayQuantity) {
		List<String> data;
		try {
			data = Files.readAllLines(Paths.get(fileName), StandardCharsets.UTF_8);
		} catch (Exception e) {
			data = Collections.emptyList();
		}
		if (data.isEmpty() && !displayQuantity) {
			System.out.println("There are no pending tasks!");
			return;
		}
		if (displayQuantity)
			System.out.println((fileName.equals(FILE_REMAINING) ? "Pending : " : "Completed : ") + data.size());

		for (int i = 0; i < data.size(); i++) {
			String item = data.get(i);
			System.out.println(fileName == FILE_REMAINING
					? (i + 1) + ". " + item.substring(item.indexOf(" ") + 1) + " ["
							+ item.substring(0, item.indexOf(" ")) + "]"
					: (i + 1) + ". " + item);
		}
	}

	private ArrayList<String> getFileData(String fileName) {
		File file;
		Scanner scanner = null;
		ArrayList<String> data = new ArrayList<String>();

		file = new File(fileName);
		try {
			scanner = new Scanner(file);
		} catch (Exception e) {
		}
		if (scanner != null) {
			while (scanner.hasNextLine())
				data.add(scanner.nextLine());
			scanner.close();
		}
		return data;
	}

	private void setNewTask(String priority, String task) {
		ArrayList<String> data = getFileData(FILE_REMAINING);
		int priorityInt;
		try {
			priorityInt = Integer.parseInt(priority);
		} catch (Exception e) {
			System.out.println("Invalid priority");
			return;
		}
		int ndx = 0;
		for (String item : data) {
			int cur = Integer.parseInt(item.substring(0, item.indexOf(" ")));
			if (priorityInt < cur)
				break;
			ndx++;
		}
		data.add(ndx, priority + " " + task);
		String newData = "";
		for (String item : data)
			newData += item + "\n";
		try {
			FileWriter fw = new FileWriter(FILE_REMAINING);
			fw.write(newData);
			fw.close();
		} catch (Exception e) {
			System.out.print("Couldn't add task!");
			return;
		}
		System.out.printf("Added task: \"%s\" with priority %s", task, priority);
	}

	private String deleteTask(String index) {
		ArrayList<String> data = getFileData(FILE_REMAINING);
		int ndx;
		try {
			ndx = Integer.parseInt(index);
		} catch (Exception e) {
			System.out.println("Enter a valid index");
			return null;
		}
		if (ndx < 1 || ndx > data.size()) {
			return null;
		}
		String deletedItem = data.get(ndx - 1);
		deletedItem = deletedItem.substring(deletedItem.indexOf(" ") + 1);
		data.remove(ndx - 1);
		String newData = "";
		for (String item : data)
			newData += item + "\n";
		try {
			FileWriter fw = new FileWriter(FILE_REMAINING);
			fw.write(newData);
			fw.close();
		} catch (Exception e) {
			System.out.print("Couldn't delete task!");
			return null;
		}
		return deletedItem;
	}

	private void setCompleted(String index) {
		String deletedItem = deleteTask(index);
		if (deletedItem == null) {
			System.out.printf("Error: no incomplete item with index #%s exists.", index);
			return;
		}
		try {
			FileWriter fw = new FileWriter(FILE_COMPLETED, true);
			fw.write(deletedItem + "\n");
			fw.close();
		} catch (Exception e) {
			System.out.print("Couldn't add task!");
			return;
		}
		System.out.println("Marked item as done.");
	}
}


/* 
public
static String removeExtraSpaces(String str)
{
    while (str.contains("  ")) //removing extra spaces from name
        str = str.replace("  ", " ");
    return str.trim();
}
 */