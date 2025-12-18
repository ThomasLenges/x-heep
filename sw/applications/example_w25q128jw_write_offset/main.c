#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "x-heep.h"
#include "w25q128jw.h"

#include "w25q128jw_controller.h"
#include "ram_new_data.h"


// RAM buffer of size of a sector
uint32_t ram_buffer[1025];

#define LENGTH_BYTES 12
#define LENGTH_WORDS ((LENGTH_BYTES + 3) / 4) // To deal with non-multiple of 4 bytes
#define OFFSET_BYTES 4

// Flash buffer
int32_t __attribute__((section(".xheep_data_flash_only"))) __attribute__ ((aligned (16))) flash_buffer[LENGTH_WORDS]; 

// flash buffer address
uint32_t *flash_address = flash_buffer;
// RAM buffer address
uint32_t *rb_address = ram_buffer;
// RAM new data address
uint32_t *rnd_address = ram_new_data;

// Check function
uint32_t check_result(uint8_t *test_buffer, uint32_t len);


__attribute__((optimize("O0"))) void w25q128jw_controller_run(){
    spi_host_t* spi;
    spi = spi_flash;

    if (w25q128jw_init(spi) != FLASH_OK) return EXIT_FAILURE;

    w25q128jw_controller_rnw(0, LENGTH_BYTES, flash_address+OFFSET_BYTES, rb_address, rnd_address); // Try with one word offset

    printf(ram_buffer[0]);
    printf(ram_buffer[1]);
    printf(ram_buffer[2]);
    printf(ram_buffer[3]);
    printf(ram_buffer[4]);  

    while(!w25q128jw_controller_is_ready_polling());

    w25q128jw_controller_rnw(1, LENGTH_BYTES, flash_address, rb_address, 0x00000000);

    printf(ram_buffer[0]);
    printf(ram_buffer[1]);
    printf(ram_buffer[2]);
    printf(ram_buffer[3]);
    printf(ram_buffer[4]); 

    while(!w25q128jw_controller_is_ready_polling());
}

int main(void) {

    printf("Write test with 4100 bytes\n");

    w25q128jw_controller_run();

    uint32_t res =  check_result(ram_new_data, LENGTH_BYTES);

    if (res == 0){
        return EXIT_SUCCESS;
    } else {
        return EXIT_FAILURE;
    }
}


uint32_t check_result(uint8_t *expected_data, uint32_t len) {
    uint32_t errors = 0;
    uint8_t *ram_buffer_char = (uint8_t *)ram_buffer + OFFSET_BYTES;

    for (uint32_t i = 0; i < len; i++) {
        if (expected_data[i] != ram_buffer_char[i]) {
            printf("Error at position %d: expected %x, got %x\n", i, expected_data[i], ram_buffer_char[i]);
            errors++;
            break;
        }
    }

    return errors;
}