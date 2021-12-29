package main

import (
	"bufio"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	args := os.Args
	argc := len(args)
	var primaryArg string
	if argc > 1 {
		primaryArg = args[1]
	} else {
		primaryArg = ""
	}
	switch primaryArg {
	case "ls":
		getRemainingTasks("task.txt", false)
		break
	case "add":
		if argc > 3 {
			setNewTask(args[2], args[3])
		} else {
			fmt.Println("Error: Missing tasks string. Nothing added!")
		}
		break
	case "del":
		if argc > 2 {
			_, err := deleteTask(args[2])
			if err {
				fmt.Println("Error: task with index #" + args[2] + " does not exist. Nothing deleted.")
			} else {
				fmt.Println("Deleted task #" + args[2])
			}
		} else {
			fmt.Println("Error: Missing NUMBER for deleting tasks.")
		}
		break
	case "done":
		if argc > 2 {
			setCompleted(args[2])
		} else {
			fmt.Println("Error: Missing NUMBER for marking tasks as done.")
		}
		break
	case "report":
		getRemainingTasks("task.txt", true)
		fmt.Println()
		getRemainingTasks("completed.txt", true)
		break
	default:
		help()
	}
}

func help() {
	fmt.Println("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics")
}

func getFileData(filename string) (data []string) {
	file, err := os.Open(filename)
	data = []string{}
	if err != nil {
		return
	}
	defer file.Close()
	scr := bufio.NewScanner(file)
	for scr.Scan() {
		item := strings.TrimSpace(scr.Text())
		if len(item) == 0 {
			continue
		}
		data = append(data, item)
	}
	return
}

func setFileData(filename string, data []string) {
	file, err := os.Create(filename)
	if err != nil {
		return
	}
	defer file.Close()
	fw := bufio.NewWriter(file)
	for _, line := range data {
		if len(line) == 0 {
			continue
		}
		fmt.Fprintln(fw, line)
	}
	fw.Flush()
}

func getRemainingTasks(filename string, displayQuantity bool) {
	data := getFileData(filename)
	size := len(data)
	if displayQuantity {
		if filename == "completed.txt" {
			fmt.Println("Completed :", size)
		} else {
			fmt.Println("Pending :", size)
		}
	} else if size == 0 {
		fmt.Println("There are no pending tasks!")
	}
	for i := 0; i < size; i++ {
		item := data[i]
		if filename == "completed.txt" {
			fmt.Printf("%d. %s\n", (i + 1), item)
		} else {
			fmt.Printf("%d. %s [%s]\n", (i + 1), item[strings.Index(item, " ")+1:], item[:strings.Index(item, " ")])
		}
	}
}

func setNewTask(priority, task string) {
	data := getFileData("task.txt")
	pr, err := strconv.ParseInt(priority, 0, 32)
	if err != nil {
		fmt.Println("Invalid priority")
		return
	}
	var index int = 0
	for _, item := range data {
		p, err := strconv.ParseInt(item[:strings.Index(item, " ")], 0, 32)
		if err != nil {
			continue
		}
		if pr < p {
			break
		}
		index++
	}
	data = append(data, "")
	copy(data[index+1:], data[index:])
	data[index] = priority + " " + task
	setFileData("task.txt", data)
	fmt.Printf("Added task: \"%s\" with priority %d\n", task, pr)
}

func deleteTask(index string) (deletedItem string, err bool) {
	data := getFileData("task.txt")
	ndx, error := strconv.ParseInt(index, 0, 32)
	if error != nil {
		err = true
		return
	}
	if ndx < 1 || ndx > int64(len(data)) {
		err = true
		return
	}
	deletedItem = data[ndx-1]
	deletedItem = deletedItem[strings.Index(deletedItem, " ")+1:]
	data[ndx-1] = ""
	setFileData("task.txt", data)
	return
}

func setCompleted(index string) {
	deletedItem, error := deleteTask(index)
	if error {
		fmt.Printf("Error: no incomplete item with index #%s exists.\n", index)
		return
	}

	f, err := os.OpenFile("completed.txt", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0600)
	if err != nil {
		panic(err)
	}
	defer f.Close()

	if _, err = f.WriteString(deletedItem + "\n"); err != nil {
		panic(err)
	}
	fmt.Println("Marked item as done.")
}
