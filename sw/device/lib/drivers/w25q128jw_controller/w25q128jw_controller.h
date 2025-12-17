#ifndef W25Q128JW_CONTROLLER_H
#define W25Q128JW_CONTROLLER_H

#include <stdint.h>

// ============== POLLING ==============
uint32_t w25q128jw_controller_is_ready_polling(void);

// ============== INTERRUPT ==============
uint32_t w25q128jw_controller_is_ready_intr(void);

// ============== OPERATION ==============
void w25q128jw_controller_rnw(uint32_t rnw, 
                            uint32_t length_bytes, 
                            uint32_t flash_address, 
                            uint32_t *ram_buffer, 
                            uint32_t *ram_w_new_data);

#endif // W25Q128JW_CONTROLLER_H