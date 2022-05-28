defmodule M do
  def main do
    argv = System.argv()
    argc = length(argv)

    case Enum.at(argv, 0) do
      "ls" ->
        read_tasks(false, false)

      "add" ->
        if argc > 2 do
          if Enum.at(argv, 1) >= "0" do
            create_task(Enum.at(argv, 1), Enum.at(argv, 2))
          else
            IO.puts("Priority cannot be negative")
          end
        else
          IO.puts("Error: Missing tasks string. Nothing added!")
        end

      "del" ->
        if argc > 1 do
          index = Enum.at(argv, 1)

          if delete_task(index) do
            IO.puts("Deleted task ##{index}")
          else
            IO.puts("Error: task with index ##{index} does not exist. Nothing deleted.")
          end
        else
          IO.puts("Error: Missing NUMBER for deleting tasks.")
        end

      "done" ->
        if argc > 1 do
          update_task(Enum.at(argv, 1))
        else
          IO.puts("Error: Missing NUMBER for marking tasks as done.")
        end

      "report" ->
        read_tasks(false, true)
        IO.puts("")
        read_tasks(true, true)

      _ ->
        help()
    end
  end

  def get_file_data(which_file) do
    if !File.exists?(if which_file, do: "completed.txt", else: "task.txt") do
      []
    else
      data = File.read!(if which_file, do: "completed.txt", else: "task.txt")
      data = String.split(data, "\n", trim: true) |> Enum.map(&String.trim/1)
      data
    end
  end

  def set_file_data(data) do
    {:ok, file} = File.open("task.txt", [:write])
    IO.write(file, Enum.join(data, "\n"))
    File.close(file)
  end

  def create_task(priority, task) do
    try do
      {pr, ""} = Integer.parse(priority)
      data = get_file_data(false)
      size = length(data)

      ndx =
        if size == 0 do
          0
        else
          Enum.reduce_while(0..(size - 1), 0, fn j, acc ->
            item = Enum.at(data, j)
            {i, _} = :binary.match(item, " ")
            p = String.slice(item, 0..(i - 1))
            {pri, ""} = Integer.parse(p)
            if pr < pri, do: {:halt, acc}, else: {:cont, j + 1}
          end)
        end

      data = List.insert_at(data, ndx, priority <> " " <> task)
      set_file_data(data)
      IO.puts("Added task: \"#{task}\" with priority #{priority}")
    rescue
      _ ->
        IO.puts("Invalid priority")
    end
  end

  def read_tasks(which_file, display_quantity) do
    data = get_file_data(which_file)
    size = length(data)

    if display_quantity do
      IO.puts(if which_file, do: "Completed : #{size}", else: "Pending : #{size}")
    else
      if(size == 0) do
        IO.puts("There are no pending tasks!")
      end
    end

    if size == 0 do
      System.halt(0)
    end

    for i <- 0..(size - 1) do
      item = Enum.at(data, i)
      {ndx, _} = :binary.match(item, " ")

      IO.puts(
        if which_file,
          do: "#{i + 1}. #{item}",
          else:
            "#{i + 1}. #{String.slice(item, (ndx + 1)..-1)} [#{String.slice(item, 0..(ndx - 1))}]"
      )
    end
  end

  def update_task(index) do
    deleted_item = delete_task(index)

    if deleted_item == nil do
      IO.puts("Error: no incomplete item with index ##{index} exists.")
    else
      {:ok, file} = File.open("completed.txt", [:append])
      IO.write(file, deleted_item <> "\n")
      File.close(file)
      IO.puts("Marked item as done.")
    end
  end

  def delete_task(index) do
    data = get_file_data(false)

    try do
      {ndx, ""} = Integer.parse(index)

      if ndx < 1 || ndx > length(data) do
        nil
      else
        deleted_item = Enum.at(data, ndx - 1)
        {pos, _} = :binary.match(deleted_item, " ")
        deleted_item = String.slice(deleted_item, (pos + 1)..-1)
        data = List.delete_at(data, ndx - 1)
        set_file_data(data)
        deleted_item
      end
    rescue
      _ -> IO.puts("Invalid index!")
    end
  end

  def help do
    IO.puts(
      "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics"
    )
  end
end

M.main()
