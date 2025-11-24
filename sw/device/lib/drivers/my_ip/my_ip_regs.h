// Generated register defines for my_ip

#ifndef _MY_IP_REG_DEFS_
#define _MY_IP_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define MY_IP_PARAM_REG_WIDTH 32

// Common Interrupt Offsets
#define MY_IP_INTR_COMMON_MY_IP_EVENT_BIT 0

// Interrupt State Register
#define MY_IP_INTR_STATE_REG_OFFSET 0x0
#define MY_IP_INTR_STATE_MY_IP_EVENT_BIT 0

// Interrupt Enable Register
#define MY_IP_INTR_ENABLE_REG_OFFSET 0x4
#define MY_IP_INTR_ENABLE_MY_IP_EVENT_BIT 0

// Interrupt Test Register
#define MY_IP_INTR_TEST_REG_OFFSET 0x8
#define MY_IP_INTR_TEST_MY_IP_EVENT_BIT 0

// Control register for flash controller
#define MY_IP_CONTROL_REG_OFFSET 0xc
#define MY_IP_CONTROL_START_BIT 0
#define MY_IP_CONTROL_RNW_BIT 1

// Status register for flash controller
#define MY_IP_STATUS_REG_OFFSET 0x10
#define MY_IP_STATUS_READY_BIT 0

// Address in Flash to read from
#define MY_IP_R_ADDRESS_REG_OFFSET 0x14

// Address to store read data from SPI_FLASH
#define MY_IP_S_ADDRESS_REG_OFFSET 0x18

// Length of data to W/R
#define MY_IP_LENGTH_REG_OFFSET 0x1c

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _MY_IP_REG_DEFS_
// End generated register defines for my_ip