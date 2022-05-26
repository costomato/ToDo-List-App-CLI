use fs::OpenOptions;
use std::convert::TryInto;
use std::env;
use std::fs;
use std::io::Write;
use std::path::Path;
use std::str;

fn main() {
    let args: Vec<String> = env::args().collect();
    let pr_arg: &str = if args.len() > 1 { &*args[1] } else { "" };
    match pr_arg {
        "ls" => read_tasks(false, false),
        "add" => {
            if args.len() > 3 {
                if &*args[2] >= "0" {
                    create_task(&*args[2], &*args[3])
                } else {
                    println!("Priority cannot be negative")
                }
            } else {
                println!("Error: Missing tasks string. Nothing added!")
            }
        }
        "del" => {
            if args.len() > 2 {
                if delete_task(&*args[2]) == None {
                    print!(
                        "Error: task with index #{} does not exist. Nothing deleted.",
                        &*args[2]
                    )
                } else {
                    print!("Deleted task #{}", &*args[2])
                }
            } else {
                println!("Error: Missing NUMBER for deleting tasks.")
            }
        }
        "done" => {
            if args.len() > 2 {
                update_task(&*args[2])
            } else {
                println!("Error: Missing NUMBER for marking tasks as done.")
            }
        }
        "report" => {
            read_tasks(false, true);
            println!();
            read_tasks(true, true)
        }
        _ => help(),
    }
}

fn get_file_data(which_file: bool) -> Vec<String> {
    let data = match fs::read_to_string(if which_file {
        "completed.txt"
    } else {
        "task.txt"
    }) {
        Ok(file) => file,
        Err(_) => String::new(),
    };
    data.split('\n')
        .filter(|&x| !x.is_empty())
        .map(|s: &str| s.trim().to_string())
        .collect()
}

fn set_file_data(data: Vec<String>) {
    fs::write("task.txt", data.join("\n")).expect("Unable to write to file!")
}

fn create_task(priority: &str, task: &str) {
    let pr = match priority.parse::<i32>() {
        Ok(n) => n,
        Err(_) => {
            println!("Invalid priority");
            return;
        }
    };
    let mut data = get_file_data(false);
    let mut ndx = 0;
    for item in &data {
        let find = item.find(" ");
        let index = if find == None { 0 } else { find.unwrap() };
        let p = match item[0..index].parse::<i32>() {
            Ok(n) => n,
            Err(_) => continue,
        };
        if pr < p {
            break;
        };
        ndx += 1;
    }

    data.insert(ndx, format!("{} {}", priority, task));
    set_file_data(data);
    println!("Added task: \"{}\" with priority {}", task, priority);
}

fn read_tasks(which_file: bool, display_quantity: bool) {
    let data = get_file_data(which_file);
    if display_quantity {
        println!(
            "{}",
            if which_file {
                format!("Completed : {}", data.len())
            } else {
                format!("Pending : {}", data.len())
            }
        )
    } else if data.len() == 0 {
        println!("There are no pending tasks!")
    }

    for i in 0..data.len() {
        let item = &data[i];
        let find = item.find(" ");
        let ndx = if find == None { 0 } else { find.unwrap() };
        println!(
            "{}",
            if which_file {
                format!("{}. {}", i + 1, item)
            } else {
                format!("{}. {} [{}]", i + 1, &item[ndx + 1..], &item[0..ndx])
            }
        )
    }
}

fn update_task(index: &str) {
    let deleted_item = delete_task(index);
    if deleted_item == None {
        println!("Error: no incomplete item with index #{} exists.", index);
        return;
    }

    let mut file = OpenOptions::new()
        .create_new(!Path::new("completed.txt").is_file())
        .write(true)
        .append(true)
        .open("completed.txt")
        .unwrap();

    if let Err(e) = writeln!(file, "{}", deleted_item.unwrap()) {
        eprintln!("Couldn't write to file: {}", e);
    }
    println!("Marked item as done.");
}

fn delete_task(index: &str) -> Option<String> {
    let ndx = match index.parse::<i32>() {
        Ok(n) => n,
        Err(_) => return None,
    };
    let mut data = get_file_data(false);
    if ndx < 1 || ndx > data.len().try_into().unwrap() {
        return None;
    }
    let deleted_item = &data[(ndx - 1) as usize];
    let find = deleted_item.find(" ");
    let pos = if find == None {
        return None;
    } else {
        find.unwrap()
    };
    let deleted = &deleted_item[pos + 1..].to_string();
    data.remove((ndx - 1).try_into().unwrap());
    set_file_data(data);
    return Some(deleted.to_string());
}

fn help() {
    print!("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics")
}
