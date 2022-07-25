#import <Foundation/Foundation.h>

@implementation NSString (util)
- (int) indexOf:(NSString *)text {
    NSRange range = [self rangeOfString:text];
    if ( range.length > 0 ) {
        return range.location;
    } else {
        return -1;
    }
}
@end

/* 
Throughout the program I have used printf() for printing to console instead of NSLog()
This is because, while running tests js was somehow not able to receive the output strings.
I tried many ways. Nothing worked but using printf() instead of NSLog()

If someone knows the reason why NSLog() was causing that issue, please let me know!
*/

void getFileData(bool whichFile, NSMutableArray *lines) {
    NSString *filePath = whichFile? @"completed.txt" : @"task.txt";
    NSString *fileContents = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSArray *array = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (NSString *line in array) {
        if ([line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0)
            [lines addObject:line];
    }
}

void setFileData(bool whichFile, NSMutableArray *data) {
    NSString *filePath = whichFile? @"completed.txt" : @"task.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileContents = [data componentsJoinedByString:@"\n"];
    [fileContents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void createTask(NSString *priority, NSString *task) {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    getFileData(false, data);
    int priorityInt = [priority intValue];
    NSString *newLine = [NSString stringWithFormat:@"%@ %@", priority, task];
    int ndx = 0;

    for(NSString *item in data) {
        int p = [item substringToIndex:[item indexOf:@" "]].intValue;
        if (p > priorityInt) 
        break;
        ndx++;
    }
    [data insertObject:newLine atIndex:ndx];
    setFileData(false, data);
    printf("Added task: \"%s\" with priority %s\n", [task UTF8String], [priority UTF8String]);
}

void readTasks(bool whichFile, bool displayQuantity) {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    getFileData(whichFile, data);
    int size = [data count];
    if(displayQuantity)
    printf("%s : %d\n", whichFile? "Completed":"Pending", size);
    else if (size == 0)
    printf("There are no pending tasks!\n");
    for (int i = 0; i< size; i++) {
        NSString *item = data[i];
        int ndx = [item indexOf: @" "];
        if(whichFile)
        printf("%d. %s\n", i+1, [item UTF8String]);
        else
        printf("%d. %s [%s]\n", i+1, [[item substringFromIndex:ndx+1] UTF8String], [[item substringToIndex:ndx] UTF8String]);
    }
}

NSString* deleteTask(NSString* index) {
    NSMutableArray *data = [[NSMutableArray alloc] init];
    getFileData(false, data);
    int ndx = [index intValue];
    if (ndx > [data count] || ndx < 1)
        return nil;
    NSString *task = data[ndx-1];
    task = [task substringFromIndex:[task indexOf: @" "]+1];
    [data removeObjectAtIndex:ndx-1];
    setFileData(false, data);
    return task;
}

void updateTask(NSString *index) {
    NSString *deletedItem = deleteTask(index);
    if(deletedItem == nil) {
        printf("Error: no incomplete item with index #%s exists.\n", [index UTF8String]);
        return;
    }
    NSMutableArray *data = [[NSMutableArray alloc] init];
    getFileData(true, data);
    [data addObject:deletedItem];
    setFileData(true, data);
    printf("Marked item as done.\n");
}

void help() {
    printf("Usage :-\n$ ./task add 2 hello world    # Add a new item with priority 2 and text \"hello world\" to the list\n$ ./task ls                   # Show incomplete priority list items sorted by priority in ascending order\n$ ./task del INDEX            # Delete the incomplete item with the given index\n$ ./task done INDEX           # Mark the incomplete item with the given index as complete\n$ ./task help                 # Show usage\n$ ./task report               # Statistics\n");
}

int main(int argc, const char * argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    const char * primaryArg = argc > 1 ? argv[1] : "";
    if(strcmp(primaryArg, "ls") == 0) {
        readTasks(false, false);
    } else if(strcmp(primaryArg, "add") == 0) {
        if(argc > 3) {
            if([[NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding] intValue] >= 0)
                createTask([NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding], [NSString stringWithCString:argv[3] encoding:NSUTF8StringEncoding]);
            else
                printf("Priority cannot be negative\n");
        } else {
            printf("Error: Missing tasks string. Nothing added!\n");
        }
    } else if(strcmp(primaryArg, "del") == 0) {
        if(argc > 2) {
            if(deleteTask([NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding]) == nil)
                printf("Error: task with index #%s does not exist. Nothing deleted.", argv[2]);
            else
                printf("Deleted task #%s", argv[2]);
        } else
            printf("Error: Missing NUMBER for deleting tasks.\n");
    } else if(strcmp(primaryArg, "done") == 0) {
        if(argc > 2)
            updateTask([NSString stringWithCString:argv[2] encoding:NSUTF8StringEncoding]);
        else
            printf("Error: Missing NUMBER for marking tasks as done.\n");
    } else if(strcmp(primaryArg, "help") == 0) {
        help();
    } else if(strcmp(primaryArg, "report") == 0) {
        readTasks(false, true);
        printf("\n");
        readTasks(true, true);
    } else {
        help();
    }
    [pool drain];
    return 0;
}