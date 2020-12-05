#ifndef ITM_COUT_REROUTER_H
#define ITM_COUT_REROUTER_H

extern "C"
int _write([[maybe_unused]] int file, char *messagePointer, int messageLenght);

#endif // ITM_COUT_REROUTER_H
