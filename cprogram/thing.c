#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dirent.h>
#include <ctype.h>

#define MAX_PROC_PATH 256

void list_processes()
{
    DIR *dir;
    struct dirent *entry;

    // Open the /proc directory
    dir = opendir("/proc");
    if (dir == NULL)
    {
        perror("Unable to open /proc");
        return;
    }

    // Read entries from /proc directory
    while ((entry = readdir(dir)) != NULL)
    {
        if (isdigit(entry->d_name[0]))
        { // Check if entry is a process directory
            char proc_path[MAX_PROC_PATH];
            snprintf(proc_path, MAX_PROC_PATH, "/proc/%s/status", entry->d_name);

            // Open process status file
            FILE *status_file = fopen(proc_path, "r");
            if (status_file == NULL)
            {
                perror("Unable to open process status file");
                continue;
            }

            // Read process name and state from status file
            char name[256], state;
            int pid;
            if (fscanf(status_file, "Name: %s\nPid: %d\nState: %c", name, &pid, &state) == 3)
            {
                printf("%s (%d): %c\n", name, pid, state);
            }

            // Close process status file
            fclose(status_file);
        }
    }

    // Close /proc directory
    closedir(dir);
}

int main()
{
    printf("Listing currently running processes:\n");
    list_processes();
    return 0;
}
