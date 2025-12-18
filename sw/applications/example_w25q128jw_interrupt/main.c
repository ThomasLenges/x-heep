#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

#include "core_v_mini_mcu.h"
#include "x-heep.h"
#include "w25q128jw.h"

#include "w25q128jw_controller.h"
#include "w25q128jw_controller_regs.h"
#include "ram_new_data.h"

#include "csr.h"
#include "rv_plic.h"
#include "dma.h" // For write_register function

// RAM buffer of size of a sector
uint32_t ram_buffer[1025];

#define LENGTH_BYTES 4100
#define LENGTH_WORDS ((LENGTH_BYTES + 3) / 4) // To deal with non-multiple of 4 bytes

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

//
// ISR
//
void handler_irq_w25q128jw_controller(uint32_t id) {
    // Set the done flag
    w25q128jw_controller_set_done_flag();

    // Clear the interrupt flag
    write_register( 0x0,
                    W25Q128JW_CONTROLLER_INTERRUPT_REG_OFFSET,
                    0x1,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
}

__attribute__((optimize("O0"))) void w25q128jw_controller_run(){
    spi_host_t* spi;
    spi = spi_flash;

    if (w25q128jw_init(spi) != FLASH_OK) return EXIT_FAILURE;

    // Clear flag before starting operation
    w25q128jw_controller_clear_done_flag();

    // Activate interrupt in PLIC
    plic_irq_set_priority(W25Q128JW_CONTROLLER_INTR_EVENT, 1);
    plic_irq_set_enabled(W25Q128JW_CONTROLLER_INTR_EVENT, kPlicToggleEnabled);

    // Activate global interrupts
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);   // MIE bit
    CSR_SET_BITS(CSR_REG_MIE, (1 << 11)); // MEIE bit

    w25q128jw_controller_rnw(0, LENGTH_BYTES, flash_address, rb_address, rnd_address);

    // Wait for interrupt 
    while(!w25q128jw_controller_is_ready_intr()) {
        asm volatile("wfi");  // Wait For Interrupt - CPU sleeps
    }
}

int main(void) {
    // Initialize PLIC
    plic_Init();

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
    uint8_t *ram_buffer_char = (uint8_t *)ram_buffer;

    for (uint32_t i = 0; i < len; i++) {
        if (expected_data[i] != ram_buffer_char[i]) {
            printf("Error at position %d: expected %x, got %x\n", i, expected_data[i], ram_buffer_char[i]);
            errors++;
            break;
        }
    }

    return errors;
}