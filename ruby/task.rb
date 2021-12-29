FILE_REMAINING = 'task.txt'.freeze
FILE_COMPLETED = 'completed.txt'.freeze

def help
  puts "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics"
end

def get_file_data(which_file)
  data = nil
  begin
    File.open(which_file ? FILE_COMPLETED : FILE_REMAINING, 'r') do |fr|
      data = fr.readlines
    end
  rescue StandardError
    data = []
  end

  data - ['', nil, "\n"]
end

def set_file_data(data)
  File.open(FILE_REMAINING, 'w') do |fw|
    fw.puts(data)
  end
end

def get_remaining_tasks(which_file, display_quantity = false)
  data = get_file_data(which_file)

  puts 'There are no pending tasks!' if data.empty? && !display_quantity

  if display_quantity
    puts(which_file ? "Completed : #{data.length}" : "Pending : #{data.length}")
  end

  (0..data.length - 1).each do |i|
    item = data[i]
    item = item.strip
    if which_file
      puts "#{i + 1}. #{item}"
    else
      puts "#{i + 1}. #{item[item.index(' ') + 1, item.length]} [#{item[0, item.index(' ')]}]"
    end
  end
end

def set_new_task(priority, task)
  data = get_file_data(false)
  priority = priority.to_i
  puts 'Invalid index' unless priority
  ndx = 0
  data.each do |item|
    item = item.strip
    p = item[0, item.index(' ')].to_i
    break if priority < p

    ndx += 1
  end
  data.insert(ndx, "#{priority} #{task}")
  set_file_data(data)
  puts "Added task: \"#{task}\" with priority #{priority}"
end

def delete_task(index)
  index = index.to_i
  return nil unless index

  data = get_file_data(false)
  return nil if index < 1 || index > data.length

  deleted_item = data[index - 1]
  deleted_item = deleted_item[deleted_item.index(' ') + 1, deleted_item.length]
  data.delete_at(index - 1)
  set_file_data(data)
  deleted_item
end

def set_completed(index)
  deleted_item = delete_task(index)
  unless deleted_item
    puts "Error: no incomplete item with index ##{index} exists."
    return
  end

  File.open(FILE_COMPLETED, 'a') do |fa|
    fa.write(deleted_item)
  end
  puts 'Marked item as done.'
end

primary_arg = ARGV[0]
case primary_arg
when 'ls'
  get_remaining_tasks(false)
when 'add'
  if ARGV[1] && ARGV[2]
    set_new_task(ARGV[1], ARGV[2])
  else
    puts 'Error: Missing tasks string. Nothing added!'
  end

when 'del'
  if ARGV[1]
    if delete_task(ARGV[1])
      puts "Deleted task ##{ARGV[1]}"
    else
      puts "Error: task with index ##{ARGV[1]} does not exist. Nothing deleted."
    end
  else
    puts 'Error: Missing NUMBER for deleting tasks.'
  end

when 'done'
  if ARGV[1]
    set_completed(ARGV[1])
  else
    puts 'Error: Missing NUMBER for marking tasks as done.'
  end

when 'report'
  get_remaining_tasks(false, true)
  puts
  get_remaining_tasks(true, true)
else
  help
end
