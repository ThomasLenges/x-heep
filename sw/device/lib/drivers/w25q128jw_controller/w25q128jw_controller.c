#include "w25q128jw_controller_structs.h"
#include "w25q128jw_controller_regs.h"
#include "rv_plic.h"
#include "rv_plic_regs.h"
#include "csr.h"
#include "handler.h"

// ============== POLLING  ==============
__attribute__((optimize("O0"))) uint32_t w25q128jw_controller_is_ready_polling()
{
    /* The transaction READY bit is read from the status register*/
    uint32_t ret = ( w25q128jw_controller_peri->STATUS & (1<<W25Q128JW_CONTROLLER_STATUS_READY_BIT) ); // TO CHANGE FOR STATUS
    return ret;
}

// ============== INTERRUPT  ==============
__attribute__((optimize("O0"))) uint32_t w25q128jw_controller_is_ready_intr()
{
    
}


// ============== OPERATION  ==============
__attribute__((optimize("O0"))) void w25q128jw_controller_rnw(rnw, length_bytes, flash_address, ram_buffer, ram_w_new_data){
    // Send flash address to controller
    write_register( (uint32_t)flash_address,
                    W25Q128JW_CONTROLLER_R_ADDRESS_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Send RAM buffer address to controller
    write_register( (uint32_t)ram_buffer,
                    W25Q128JW_CONTROLLER_S_ADDRESS_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Send RAM new data address to controller
    write_register( (uint32_t)ram_w_new_data,
                    W25Q128JW_CONTROLLER_MD_ADDRESS_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );          
    // Send length (in bytes) to controller
    write_register( length_bytes,
                    W25Q128JW_CONTROLLER_LENGTH_REG_OFFSET,
                    0xFFFFFFFF,
                    0,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Specify it is a operation type (rnw = 1 for read, 0 for write)
    write_register( rnw,
                    W25Q128JW_CONTROLLER_CONTROL_REG_OFFSET,
                    0x1,
                    W25Q128JW_CONTROLLER_CONTROL_RNW_BIT,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
    // Start write operation
    write_register( 0x1,
                    W25Q128JW_CONTROLLER_CONTROL_REG_OFFSET,
                    0x1,
                    W25Q128JW_CONTROLLER_CONTROL_START_BIT,
                    W25Q128JW_CONTROLLER_START_ADDRESS
                );
}

