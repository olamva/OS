#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    if(argc == 1){
        printf("Usage: vatopa virtual_address [pid]");
    }
    else if(argc == 2){
        uint64 pa = va2pa(atoi(argv[1]), 0);
        printf("0x%x\n", pa);
    }
    else if(argc == 3){
        uint64 pa = va2pa(atoi(argv[1]), atoi(argv[2]));
        printf("0x%x\n", pa);
    }
    return 0;   
}