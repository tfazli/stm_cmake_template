#include <misc.h>

int main([[maybe_unused]] int argc, [[maybe_unused]] char *argv[]) {
    SystemInit();
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);
    while(true) {
        /* *************************************
         * Any custom code can be placed in this
         * section instead of an endless loop.
         * ************************************* */
    }
    return 0;
}
