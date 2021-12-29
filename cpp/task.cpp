#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#define FILE_REMAINING "task.txt"
#define FILE_COMPLETED "completed.txt"
using std::cin;
using std::cout;
using std::ifstream;
using std::ofstream;
using std::string;
using std::vector;

void help()
{
    cout << "Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics";
}

vector<string> getFileData(string fileName)
{
    int ndx = -1;
    ifstream fin;
    fin.open(fileName);
    vector<string> data;
    string line;
    while (fin)
    {
        getline(fin, line);
        if (line.empty())
            continue;
        ndx++;
        data.insert(data.begin() + ndx, line);
    }
    fin.close();
    return data;
}

void setFileData(vector<string> data, string fileName)
{
    ofstream fout;
    fout.open(fileName);
    for (int i = 0; i < data.size(); i++)
        fout << data[i] << std::endl;

    fout.close();
}

void getRemainingTasks(string fileName, bool displayQuantity)
{
    vector<string> data = getFileData(fileName);
    if (data.empty() && !displayQuantity)
    {
        cout << "There are no pending tasks!";
        return;
    }
    if (displayQuantity)
        cout << (fileName == FILE_REMAINING ? "Pending : " : "Completed : ") << data.size() << std::endl;

    for (int i = 0; i < data.size(); i++)
    {
        string item = data[i];
        cout << (fileName == FILE_REMAINING ? std::to_string((i + 1)) + ". " + item.substr(item.find(" ") + 1) + " [" + item.substr(0, item.find(" ")) + "]" : std::to_string((i + 1)) + ". " + item) << std::endl;
    }
}

void setNewTask(string priority, string task)
{
    vector<string> data = getFileData(FILE_REMAINING);
    int priorityInt;
    try
    {
        priorityInt = std::stoi(priority);
    }
    catch (...)
    {
        cout << "Invalid priority";
        return;
    }
    int ndx = 0;
    for (int i = 0; i < data.size(); i++)
    {
        int cur;
        try
        {
            cur = std::stoi(data[i].substr(0, data[i].find(" ")));
        }
        catch (...)
        {
        }
        if (priorityInt < cur)
            break;
        ndx++;
    }
    data.insert(data.begin() + ndx, priority + " " + task);
    setFileData(data, FILE_REMAINING);
    cout << "Added task: \"" << task << "\" with priority " << priority;
}

string deleteTask(string index)
{
    vector<string> data = getFileData(FILE_REMAINING);
    int ndx;
    try
    {
        ndx = std::stoi(index);
    }
    catch (...)
    {
        cout << "Enter a valid index";
        return "";
    }
    if (ndx < 1 || ndx > data.size())
        return "";
    string deletedItem = data[ndx - 1];
    deletedItem = deletedItem.substr(deletedItem.find(" ") + 1);
    data.erase(data.begin() + ndx - 1);
    setFileData(data, FILE_REMAINING);
    return deletedItem;
}

void setCompleted(string index)
{
    string deletedItem = deleteTask(index);
    if (deletedItem.empty())
    {
        cout << "Error: no incomplete item with index #" << index << " exists.";
        return;
    }

    ofstream fout;
    fout.open(FILE_COMPLETED, std::ios::app);
    fout << deletedItem << std::endl;
    fout.close();
    cout << "Marked item as done.";
}

void removeExtraSpaces(string *str)
{
    string st = *str;
    string s = "  ", t = " ";
    string::size_type n = 0;
    while ((n = st.find(s)) != string::npos)
        st.replace(n, s.size(), t);
    if (st.size() > 0)
    {
        if (st.substr(0, 1) == " ")
            st.replace(0, 1, "");
        if (st.size() > 0)
        {
            if (st.substr(st.size() - 1) == " ")
                st.replace(st.size() - 1, 1, "");
        }
    }
    *str = st;
}

int main(int argc, char *argv[])
{
    string primaryArg = argc > 1 ? argv[1] : "";
    if (primaryArg == "ls")
        getRemainingTasks(FILE_REMAINING, false);
    else if (primaryArg == "add")
    {
        if (argc > 3)
        {
            string arg = argv[2];
            string task = argv[3];
            if (task.find(" ") != string::npos)
                removeExtraSpaces(&task);
            if (task.empty())
                cout << "Error: Missing tasks string. Nothing added!";
            else
            {
                if (arg.compare("0") >= 0)
                    setNewTask(arg, task);
                else
                    cout << "Invalid priority";
            }
        }
        else
            cout << "Error: Missing tasks string. Nothing added!";
    }
    else if (primaryArg == "del")
    {
        if (argc > 2)
        {
            if (deleteTask(argv[2]).empty())
                cout << "Error: task with index #" << argv[2] << " does not exist. Nothing deleted.";
            else
                cout << "Deleted task #" << argv[2];
        }
        else
            cout << "Error: Missing NUMBER for deleting tasks.";
    }
    else if (primaryArg == "done")
    {
        if (argc > 2)
            setCompleted(argv[2]);
        else
            cout << "Error: Missing NUMBER for marking tasks as done.";
    }
    else if (primaryArg == "report")
    {
        getRemainingTasks(FILE_REMAINING, true);
        cout << std::endl;
        getRemainingTasks(FILE_COMPLETED, true);
    }
    else
        help();

    return 0;
}