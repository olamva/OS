#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[])
{
    if (argc == 1)
    {
        printf("Usage: vatopa virtual_address [pid]\n");
        return 0;
    }
    uint64 pa = 0;
    if (argc == 2)
    {
        pa = va2pa(atoi(argv[1]), getpid());
    }
    else if (argc == 3)
    {
        pa = va2pa(atoi(argv[1]), atoi(argv[2]));
    }
    printf("0x%x\n", pa);
    return 0;
}