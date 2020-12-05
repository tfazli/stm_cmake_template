#include "ItmCoutRerouter.h"
#include <misc.h>

extern "C"
int _write([[maybe_unused]] int file, char *messagePointer, int messageLenght) {
    if(messagePointer == nullptr || messageLenght <= 0) {
        return 0;
    }
    for (int i = 0; i < messageLenght; i++) {
        ITM_SendChar(*messagePointer++);
    }
    return messageLenght;
}
