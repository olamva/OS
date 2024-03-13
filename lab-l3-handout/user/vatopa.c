#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

uint64 main(int argc, char *argv[])
{
    if (argc != 2 && argc != 3)
    {
        printf("Usage: vatopa virtual_address [pid]\n");
        exit(1);
    }
    uint64 va = *argv[1];
    int pid;
    if (argc == 2)
    {
        pid = getpid();
    }
    if (argc == 3)
    {
        pid = *argv[2];
    }
    uint64 pa = va2pa(va, pid);
    if (pa == 0)
    {
        printf("va2pa failed\n");
        exit(0);
    }

    printf("0x%x\n", pa);
    exit(0);
}
