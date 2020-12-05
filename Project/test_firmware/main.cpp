#include <gtest/gtest.h>
#include <misc.h>

int main([[maybe_unused]] int argc, [[maybe_unused]] char *argv[]) {
    SystemInit();
    NVIC_PriorityGroupConfig(NVIC_PriorityGroup_4);
    ::testing::InitGoogleTest(&argc, argv);
    int result = RUN_ALL_TESTS();
    std::cout << "Testing programm finished. Awaiting shutdown." << std::endl;
    while(true) {
    }
    return result;
}
