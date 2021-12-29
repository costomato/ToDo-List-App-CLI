#include <stdio.h>
#include <string.h>
#define FILE_REMAINING "task.txt"
#define FILE_COMPLETED "completed.txt"
char deletedItem[100];

#include <stdlib.h>
typedef struct list
{
    char item[100];
    struct list *next;
} * LIST;

LIST newNode()
{
    return (LIST)malloc(sizeof(struct list));
}

LIST insert(LIST firstNode, int position, char item[])
{
    LIST curNode = firstNode, prevNode = NULL;
    int ndx = 0;
    while (curNode != NULL)
    {
        if (ndx == position)
            break;
        ndx++;
        prevNode = curNode;
        curNode = curNode->next;
    }
    if (position > ndx) // index out of bounds
        return NULL;

    // insertion process
    LIST newData = newNode();
    newData->next = curNode;
    strcpy(newData->item, item);
    if (prevNode == NULL)
        firstNode = newData;
    else
        prevNode->next = newData;

    return firstNode;
}

LIST rem(LIST firstNode, int position)
{
    LIST curNode = firstNode, prevNode = NULL;
    int ndx = 0;
    while (curNode->next != NULL)
    {
        if (ndx == position)
            break;
        ndx++;
        prevNode = curNode;
        curNode = curNode->next;
    }
    if (position > ndx || position < 0) // index out of bounds
    {
        strcpy(deletedItem, "");
        return firstNode;
    }

    // deletion process
    char task[100];
    char line[100];
    strcpy(line, curNode->item);
    strncpy(task, &line[strcspn(line, " ") + 1], strlen(line));
    strcpy(deletedItem, task);
    if (prevNode == NULL)
        firstNode = curNode->next;
    else
        prevNode->next = curNode->next;
    free(curNode);

    return firstNode;
}

void help()
{
    printf("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics\n");
}

int getLength(LIST data)
{
    int size = 0;
    LIST cur = data;
    while (cur != NULL)
    {
        size++;
        cur = cur->next;
    }
    return size;
}

LIST getFileData(int whichFile)
{
    FILE *fp = fopen(whichFile ? FILE_COMPLETED : FILE_REMAINING, "r");
    if (fp == NULL)
        return NULL;

    LIST first = NULL;
    char line[100];
    int p = fscanf(fp, "%[^\n]%*c", line);
    int pos = -1;
    while (p != -1)
    {
        first = insert(first, ++pos, line);
        p = fscanf(fp, "%[^\n]%*c", line);
    }
    fclose(fp);
    return first;
}

void getRemainingTasks(int whichFile, int displayQuantity)
{
    LIST data = getFileData(whichFile);
    int count = getLength(data);
    if (displayQuantity)
        if (whichFile)
            printf("Completed : %d\n", count);
        else
            printf("Pending : %d\n", count);
    else if (count == 0)
    {
        printf("There are no pending tasks!\n");
        return;
    }
    count = 0;
    while (data != NULL)
    {
        count++;
        if (whichFile)
            printf("%d. %s\n", count, data->item);
        else
        {
            char line[100];
            strcpy(line, data->item);
            int pos = strcspn(line, " ");
            char priority[pos + 1];
            strncpy(priority, &line[0], pos);
            priority[pos] = '\0';

            int p = strlen(line) - pos;
            char task[p + 1];
            strncpy(task, &line[pos + 1], p);
            printf("%d. %s [%s]\n", count, task, priority);
        }
        data = data->next;
    }
}

void setFileData(int whichFile, LIST data)
{
    FILE *fp = fopen(whichFile ? FILE_COMPLETED : FILE_REMAINING, "w");
    if (fp == NULL || data == NULL)
    {
        printf("File error\n");
        return;
    }
    LIST curNode = data;
    while (curNode != NULL)
    {
        fprintf(fp, "%s\n", curNode->item);
        curNode = curNode->next;
    }
}

void setNewTask(char priorityStr[], char task[])
{
    LIST dataList = getFileData(0);
    int ndx = 0;

    LIST curNode = dataList;

    int pr;
    sscanf(priorityStr, "%d", &pr);
    while (curNode != NULL)
    {
        char *data = curNode->item;
        char priority[10] = "";
        strncpy(priority, &data[0], strcspn(data, " "));
        int p;
        sscanf(priority, "%d", &p);
        if (pr < p)
            break;
        ndx++;
        curNode = curNode->next;
    }

    char fullTask[100];
    strcpy(fullTask, priorityStr);
    strcat(fullTask, " ");
    strcat(fullTask, task);
    dataList = insert(dataList, ndx, fullTask);
    setFileData(0, dataList);

    printf("Added task: \"%s\" with priority %d\n", task, pr);
}

void deleteTask(char index[])
{
    LIST data = getFileData(0);
    int ndx;
    sscanf(index, "%d", &ndx);
    data = rem(data, ndx - 1);
    setFileData(0, data);
}

void setCompleted(char index[])
{
    FILE *fp = fopen(FILE_COMPLETED, "a");
    if (fp == NULL)
    {
        printf("Null file\n");
    }
    deleteTask(index);
    if (strlen(deletedItem) == 0)
    {
        printf("Error: no incomplete item with index #%s exists.\n", index);
        return;
    }

    fprintf(fp, "%s\n", deletedItem);
    fclose(fp);

    printf("Marked item as done.\n");
}

int main(int argc, char *argv[])
{
    char *primaryArg = argc > 1 ? argv[1] : "";
    if (strcmp(primaryArg, "ls") == 0)
        getRemainingTasks(0, 0);
    else if (strcmp(primaryArg, "add") == 0)
    {
        if (argc > 3)
        {
            char *arg = argv[2];
            char *task = argv[3];
            if (strlen(task) == 0)
                printf("Error: Missing tasks string. Nothing added!\n");
            else
                setNewTask(arg, task);
        }
        else
            printf("Error: Missing tasks string. Nothing added!\n");
    }
    else if (strcmp(primaryArg, "del") == 0)
    {
        if (argc > 2)
        {
            deleteTask(argv[2]);
            if (strlen(deletedItem) == 0)
                printf("Error: task with index #%s does not exist. Nothing deleted.\n", argv[2]);
            else
                printf("Deleted task #%s\n", argv[2]);
        }
        else
            printf("Error: Missing NUMBER for deleting tasks.\n");
    }
    else if (strcmp(primaryArg, "done") == 0)
    {
        if (argc > 2)
            setCompleted(argv[2]);
        else
            printf("Error: Missing NUMBER for marking tasks as done.\n");
    }
    else if (strcmp(primaryArg, "report") == 0)
    {
        getRemainingTasks(0, 1);
        printf("\n");
        getRemainingTasks(1, 1);
    }
    else
        help();

    return 0;
}
