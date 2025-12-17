#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "x-heep.h"
#include "w25q128jw.h"

#include "w25q128jw_controller.c"
#include "flash_data.c"

#define LENGTH_BYTES 0 // Adapt flash_data.c accordingly (max 128 bytes for this example)
#define LENGTH_WORDS ((LENGTH_BYTES + 3) / 4) // To deal with non-multiple of 4 bytes

// RAM buffer to store data read from FLASH
uint32_t ram_buffer[256];
// Give address to read from FLASH (r_address)
uint32_t *flash_address = flash_buffer;
// Give address to store data read from FLASH (s_address)
uint32_t *ram_buffer_address = ram_buffer;


uint32_t check_result(uint8_t *test_buffer, uint32_t len);


__attribute__((optimize("O0"))) void w25q128jw_controller_run(){
    spi_host_t* spi;
    spi = spi_flash;

    if (w25q128jw_init(spi) != FLASH_OK) return EXIT_FAILURE;

    w25q128jw_controller_rnw(1, LENGTH_BYTES, flash_address, ram_buffer_address, 0x00000000);

    while(!w25q128jw_controller_is_ready_polling());
}

int main(void) {

    w25q128jw_controller_run();

    uint32_t res =  check_result(ram_golden_data, LENGTH_BYTES);

    if (res == 0){
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}

uint32_t check_result(uint8_t *test_buffer, uint32_t len) {
    uint32_t errors = 0;
    uint8_t *ram_buffer_char = (uint8_t *)ram_buffer;

    for (uint32_t i = 0; i < len; i++) {
        if (test_buffer[i] != ram_buffer_char[i]) {
            printf("Error at position %d: expected %x, got %x\n", i, test_buffer[i], ram_buffer_char[i]);
            errors++;
            break;
        }
    }

    return errors;
}
