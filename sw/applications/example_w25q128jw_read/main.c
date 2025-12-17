#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "x-heep.h"
#include "w25q128jw.h"

#include "w25q128jw_controller.c"
#include "flash_data.c"

#define LENGTH_BYTES 128 // Adapt flash_data.c accordingly (max 128 bytes for this example)
#define LENGTH_WORDS ((LENGTH_BYTES + 3) / 4) // To deal with non-multiple of 4 bytes

// RAM buffer to store data read from FLASH
uint32_t ram_buffer[256];
// Give address to read from FLASH (r_address)
uint32_t *flash_address = flash_buffer;
// Give address to store data read from FLASH (s_address)
uint32_t *ram_buffer_address = ram_buffer;


uint32_t check_result(uint8_t *test_buffer, uint32_t len);

__attribute__((optimize("O0"))) void w25q128jw_controller_run(){
    // Clean DMA
    dma_init(NULL);
    // Gives the address offset how where the test_buffer is stored in the flash
    // r_address = heep_get_flash_address_offset(r_data);
    // Load r_address
    write_register( (uint32_t)r_address,
                    W25Q128JW_CONTROLLER_R_ADDRESS_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Load s_address
    write_register( (uint32_t)s_address,
                    W25Q128JW_CONTROLLER_S_ADDRESS_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Load length
    write_register( LENGTH,
                    W25Q128JW_CONTROLLER_LENGTH_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Specify it is a read operation
    write_register( 0x1,
                    W25Q128JW_CONTROLLER_CONTROL_REG_OFFSET,
                    0x1,
                    W25Q128JW_CONTROLLER_CONTROL_RNW_BIT,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Start read operation
    write_register( 0x1,
                    W25Q128JW_CONTROLLER_CONTROL_REG_OFFSET,
                    0x1,
                    W25Q128JW_CONTROLLER_CONTROL_START_BIT,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
}

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
