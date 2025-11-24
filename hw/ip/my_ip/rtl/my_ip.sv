module my_ip #(
    parameter type reg_req_t = reg_pkg::reg_req_t,
    parameter type reg_rsp_t = reg_pkg::reg_rsp_t,
    parameter logic [7:0] SPI_FLASH_TX_FIFO_DEPTH = 8'h48,
    parameter logic [31:0] SPI_FLASH_RX_FIFO_DEPTH = 32'h40
) (
    input logic clk_i,
    input logic rst_ni,

    // Register interface
    input  reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o,

    // Done signal
    output logic my_ip_done_o,

    // Interrupt signal
    output logic my_ip_interrupt_o,

    // Master ports on the system bus
    output obi_pkg::obi_req_t my_ip_master_bus_req_o,
    input obi_pkg::obi_resp_t my_ip_master_bus_resp_i,
    input logic [core_v_mini_mcu_pkg::DMA_CH_NUM-1:0] dma_done
);
  import my_ip_reg_pkg::*;
  import core_v_mini_mcu_pkg::*;
  import spi_host_reg_pkg::*;
  import dma_reg_pkg::*;

  my_ip_reg2hw_t reg2hw;
  my_ip_hw2reg_t hw2reg;

  // OBI FSM
  enum logic [1:0] {
    OBI_IDLE,
    OBI_ISSUE_REQ,
    OBI_WAIT_RVALID
  }
      obi_state_d, obi_state_q;

  function automatic [31:0] bitfield_byteswap32(input [31:0] adress_to_swap);
    bitfield_byteswap32 = {
      adress_to_swap[7:0], adress_to_swap[15:8], adress_to_swap[23:16], adress_to_swap[31:24]
    };
  endfunction

  logic [31:0] address, data, read_value;
  logic obi_start, obi_finish, w_enable;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      obi_state_q <= OBI_IDLE;
    end else begin
      obi_state_q <= obi_state_d;
    end
  end

  always_comb begin
    my_ip_master_bus_req_o.req = 1'b0;
    my_ip_master_bus_req_o.we = 1'b0;
    my_ip_master_bus_req_o.be = 4'b1111;
    my_ip_master_bus_req_o.addr = 32'h00000000;
    my_ip_master_bus_req_o.wdata = 32'h00000000;

    obi_finish = 1'b0;
    read_value = 32'h00000000;

    obi_state_d = obi_state_q;


    case (obi_state_q)
      OBI_IDLE: begin
        if (obi_start) begin
          obi_state_d = OBI_ISSUE_REQ;
        end
      end

      OBI_ISSUE_REQ: begin
        my_ip_master_bus_req_o.req = 1'b1;
        my_ip_master_bus_req_o.we = w_enable;
        my_ip_master_bus_req_o.addr = address;
        my_ip_master_bus_req_o.wdata = data;

        if (my_ip_master_bus_resp_i.gnt) begin
          obi_state_d = OBI_WAIT_RVALID;
        end
      end

      OBI_WAIT_RVALID: begin
        if (my_ip_master_bus_resp_i.rvalid) begin
          read_value  = my_ip_master_bus_resp_i.rdata;
          obi_finish  = 1'b1;
          obi_state_d = OBI_IDLE;
        end
      end

      default: begin
        obi_state_d = OBI_IDLE;
      end
    endcase
  end

  // Top FSM
  typedef enum logic [2:0] {
    TOP_IDLE,
    TOP_READ,
    TOP_FWAIT,
    TOP_ERASE,
    TOP_WRITE
  } top_state_e;

  // READ FSM
  typedef enum logic [3:0]{
    READ_IDLE,
    READ_DMA_SRC_PTR,
    READ_DMA_DST_PTR,
    READ_DMA_SRC_INC,
    READ_DMA_DST_INC,
    READ_DMA_SRC_TYPE,
    READ_DMA_DST_TYPE,
    READ_DMA_TRIG,
    READ_DMA_SIZE_D1,

    READ_SPI_CHECK_TX_FIFO,
    READ_SPI_FILL_TX_FIFO,
    READ_SPI_WAIT_READY_1,
    READ_SPI_SEND_CMD_1,
    READ_SPI_WAIT_READY_2,
    READ_SPI_SEND_CMD_2,
    READ_TRANS
  } read_state_e;

  // FLASH WAIT FSM
  typedef enum logic [3:0]{
    FWAIT_IDLE,
    FWAIT_SET_RXWM_R,
    FWAIT_SET_RXWM_W,
    FWAIT_SPI_CHECK_TX_FIFO,
    FWAIT_SPI_FILL_TX_FIFO,
    FWAIT_SPI_WAIT_READY_1,
    FWAIT_SPI_SEND_CMD_1,
    FWAIT_SPI_WAIT_READY_2,
    FWAIT_SPI_SEND_CMD_2,
    FWAIT_WAIT_RXWM,
    FWAIT_READ_FLASH_STATUS
  } fwait_state_e;

  // ERASE FSM
  typedef enum logic [3:0]{
    ERASE_IDLE,
    ERASE_WE_CHECK_TX_FIFO,
    ERASE_WE_FILL_TX_FIFO,
    ERASE_WE_WAIT_READY,
    ERASE_WE_SEND_CMD,

    ERASE_SE_CHECK_TX_FIFO,
    ERASE_SE_FILL_TX_FIFO,
    ERASE_SE_WAIT_READY,
    ERASE_SE_SEND_CMD
  } erase_state_e;

  // WRITE FSM
  typedef enum logic [4:0] {
    WRITE_IDLE,
    WRITE_PP_CHECK_TX_FIFO,
    WRITE_PP_FILL_TX_FIFO,
    WRITE_PP_WAIT_READY,
    WRITE_PP_SEND_CMD,

    WRITE_DMA_CHECK_READY,
    WRITE_DMA_SRC_PTR,
    WRITE_DMA_DST_PTR,
    WRITE_DMA_SRC_INC,
    WRITE_DMA_DST_INC,
    WRITE_DMA_SRC_TYPE,
    WRITE_DMA_DST_TYPE,
    WRITE_DMA_TRIG,
    WRITE_DMA_SIZE_D1,
    
    WRITE_TRANS,
    WRITE_PP_WAIT_READY_2,
    WRITE_PP_SEND_CMD_2

  } write_state_e;

  top_state_e        top_state_q,        top_state_d;
  read_state_e       read_state_q,       read_state_d;
  erase_state_e      erase_state_q,      erase_state_d;
  fwait_state_e      fwait_state_q,      fwait_state_d;
  write_state_e      write_state_q,      write_state_d;
  logic [1:0] fwait_cnt_q, fwait_cnt_d;


  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      top_state_q <= TOP_IDLE;
      read_state_q <= READ_IDLE;
      erase_state_q <= ERASE_IDLE;
      fwait_state_q <= FWAIT_IDLE;
      write_state_q <= WRITE_IDLE;
      fwait_cnt_q <= 2'b0;
    end else begin
      top_state_q <= top_state_d;
      read_state_q <= read_state_d;
      erase_state_q <= erase_state_d;
      fwait_state_q <= fwait_state_d;
      write_state_q <= write_state_d;
      fwait_cnt_q <= fwait_cnt_d;
    end
  end

  always_comb begin
    address = 32'h00000000;
    data = 32'h00000000;
    w_enable = 1'b0;
    obi_start = 1'b0;
    my_ip_done_o = 1'b0;

    top_state_d = top_state_q;
    read_state_d = read_state_q;
    erase_state_d = erase_state_q;
    fwait_state_d = fwait_state_q;
    write_state_d = write_state_q;
    fwait_cnt_d = fwait_cnt_q;

    hw2reg.control.start.de = 1'b0;
    hw2reg.control.start.d = 1'b0;

    // ========== TOP FSM ==================

    case (top_state_q)
      TOP_IDLE: begin
        if (reg2hw.control.start) begin
          address   = DMA_START_ADDRESS + {25'b0, DMA_STATUS_OFFSET};
          obi_start = 1'b1;

          if (obi_finish && read_value[0]) begin // DMA ready
            top_state_d = TOP_READ;
            read_state_d = READ_DMA_SRC_PTR;
          end
        end
      end

      // ========== READ FSM ==================

      TOP_READ: begin
        case (read_state_q)
          READ_IDLE: begin
            // Nothing to do here.
          end

          READ_DMA_SRC_PTR: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_PTR_OFFSET};
            data = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_RXDATA_OFFSET};
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_DST_PTR;
            end
          end

          READ_DMA_DST_PTR: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_PTR_OFFSET};
            data = reg2hw.s_address;
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_SRC_INC;
            end
          end

          READ_DMA_SRC_INC: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_PTR_INC_D1_OFFSET};
            data = 32'h0;  // Remain at RX Data FIFO address
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_DST_INC;
            end
          end

          READ_DMA_DST_INC: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_PTR_INC_D1_OFFSET};
            data = 32'h4;  // Every address has a word or a byte?
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_SRC_TYPE;
            end
          end

          READ_DMA_SRC_TYPE: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_DATA_TYPE_OFFSET};
            data = 32'h0;  // 32-bit word
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_DST_TYPE;
            end
          end

          READ_DMA_DST_TYPE: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_DATA_TYPE_OFFSET};
            data = 32'h0;  // 32-bit word
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_TRIG;
            end
          end

          READ_DMA_TRIG: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SLOT_OFFSET};
            data = {16'h0, 16'h4};  // TX_TRG: Memory write trigger + RX_TRG: SPI Host RX FIFO threshold
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_DMA_SIZE_D1;
            end
          end

          // Starts transaction 
          READ_DMA_SIZE_D1: begin
            address   = DMA_START_ADDRESS + {25'b0, DMA_SIZE_D1_OFFSET};
            w_enable  = 1'b1;
            obi_start = 1'b1;

            if (reg2hw.length % 4 == 0) begin
              data = reg2hw.length >> 2;  // Number of bytes to transfer
            end else begin
              data = (reg2hw.length >> 2) + 1;  // Number of bytes to transfer rounded to next word
            end

            if (obi_finish) begin
              read_state_d = READ_SPI_CHECK_TX_FIFO;
            end
          end

          READ_SPI_CHECK_TX_FIFO: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[7:0] < SPI_FLASH_TX_FIFO_DEPTH) begin
              read_state_d = READ_SPI_FILL_TX_FIFO;
            end
          end

          READ_SPI_FILL_TX_FIFO: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            data = (((bitfield_byteswap32(reg2hw.r_address & 32'h00ffffff)) >> 8) << 8) | 32'h03;
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_SPI_WAIT_READY_1;
            end
          end

          READ_SPI_WAIT_READY_1: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[31]) begin
              read_state_d = READ_SPI_SEND_CMD_1;
            end
          end

          READ_SPI_SEND_CMD_1: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h1, 24'h3};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_SPI_WAIT_READY_2;
            end
          end

          READ_SPI_WAIT_READY_2: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[31]) begin
              read_state_d = READ_SPI_SEND_CMD_2;
            end
          end

          READ_SPI_SEND_CMD_2: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h1, 2'h0, 1'h0, reg2hw.length[23:0] - 1'h1};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              read_state_d = READ_TRANS;
            end
          end

          READ_TRANS: begin
            if (dma_done[0]) begin  // Transaction done
              if (reg2hw.control.rnw) begin
                read_state_d              = READ_IDLE;
                top_state_d               = TOP_IDLE;
                my_ip_done_o              = 1'b1;
                hw2reg.control.start.de   = 1'b1;
                hw2reg.control.start.d    = 1'b0;
              end else begin
                read_state_d              = READ_IDLE;
                top_state_d               = TOP_FWAIT;
                fwait_state_d             = FWAIT_SET_RXWM_R; 
              end
            end
          end

          default: begin
            read_state_d = READ_IDLE;
          end
        endcase
      end

      // ========== FWAIT FSM ==================

      TOP_FWAIT: begin
        case (fwait_state_q)

          FWAIT_IDLE: begin
            // Nothing to do here.
          end

        `ifdef TARGET_SIM
          FWAIT_SET_RXWM_R: begin
            case (fwait_cnt_q)
              2'h0: begin // Enter erase
                fwait_cnt_d   = fwait_cnt_q + 1'h1;
                fwait_state_d = FWAIT_IDLE;
                top_state_d   = TOP_ERASE;
                erase_state_d = ERASE_WE_CHECK_TX_FIFO;
              end

              2'h1: begin // Enter write
                fwait_cnt_d   = fwait_cnt_q + 1'h1;
                fwait_state_d = FWAIT_IDLE;
                top_state_d   = TOP_WRITE;
                write_state_d = WRITE_PP_CHECK_TX_FIFO;
              end

              2'h2: begin // Exit write
                fwait_cnt_d   = 2'h0;
                fwait_state_d = FWAIT_IDLE;
                top_state_d   = TOP_IDLE;
                my_ip_done_o  = 1'b1;
                hw2reg.control.start.de = 1'b1;
                hw2reg.control.start.d  = 1'b0;
              end

              default: begin
              end
            endcase
          end 
        `else
          // Wait for flash to be ready
          FWAIT_SET_RXWM_R: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_CONTROL_OFFSET};
            obi_start = 1'b1;

            if (obi_finish) begin
              fwait_state_d = FWAIT_SET_RXWM_W;
            end
          end
        `endif

          FWAIT_SET_RXWM_W: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_CONTROL_OFFSET};
            data    = {read_value[31:8], 8'h01}; 
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              fwait_state_d = FWAIT_SPI_CHECK_TX_FIFO;
            end
          end

          FWAIT_SPI_CHECK_TX_FIFO: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[7:0] < SPI_FLASH_TX_FIFO_DEPTH) begin
              fwait_state_d = FWAIT_SPI_FILL_TX_FIFO;
            end
          end

          FWAIT_SPI_FILL_TX_FIFO: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            data = 32'h00000005; // Read Flash Status Register 1
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              fwait_state_d = FWAIT_SPI_WAIT_READY_1;
            end
          end

          FWAIT_SPI_WAIT_READY_1: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[31]) begin
              fwait_state_d = FWAIT_SPI_SEND_CMD_1;
            end
          end

          FWAIT_SPI_SEND_CMD_1: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h1, 24'h0};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              fwait_state_d = FWAIT_SPI_WAIT_READY_2;
            end
          end

          FWAIT_SPI_WAIT_READY_2: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[31]) begin
              fwait_state_d = FWAIT_SPI_SEND_CMD_2;
            end
          end

          FWAIT_SPI_SEND_CMD_2: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h1, 2'h0, 1'h0, 24'h0};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              fwait_state_d = FWAIT_WAIT_RXWM;
            end
          end

          FWAIT_WAIT_RXWM: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[20]) begin
              fwait_state_d = FWAIT_READ_FLASH_STATUS;
            end
          end

          FWAIT_READ_FLASH_STATUS: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_RXDATA_OFFSET};
            obi_start = 1'b1;

            if (obi_finish) begin
              if (read_value[0] == 1'b0) begin
                case (fwait_cnt_q)

                  2'h0: begin // Enter erase
                    fwait_cnt_d   = fwait_cnt_q + 1'h1;
                    fwait_state_d = FWAIT_IDLE;
                    top_state_d   = TOP_ERASE;
                    erase_state_d = ERASE_WE_CHECK_TX_FIFO;
                  end

                  2'h1: begin // Enter write
                    fwait_cnt_d   = fwait_cnt_q + 1'h1;
                    fwait_state_d = FWAIT_IDLE;
                    top_state_d   = TOP_WRITE;
                    write_state_d = WRITE_PP_CHECK_TX_FIFO;
                  end

                  2'h2: begin // Exit write
                    fwait_cnt_d   = 2'h0;
                    fwait_state_d = FWAIT_IDLE;
                    top_state_d   = TOP_IDLE;
                    my_ip_done_o  = 1'b1;
                    hw2reg.control.start.de = 1'b1;
                    hw2reg.control.start.d  = 1'b0;
                  end

                  default: begin
                  end
                endcase
              end else begin
                fwait_state_d = FWAIT_SET_RXWM_R; // Loop again for flash wait
              end
            end
          end

          default: begin
            fwait_state_d = FWAIT_IDLE;
          end

        endcase
      end


      // ========== ERASE FSM ================== 

      TOP_ERASE: begin
        case (erase_state_q)
          ERASE_IDLE: begin
            // Nothing to do here.
          end


          ERASE_WE_CHECK_TX_FIFO: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[7:0] < SPI_FLASH_TX_FIFO_DEPTH) begin
              erase_state_d = ERASE_WE_FILL_TX_FIFO;
            end
          end

          ERASE_WE_FILL_TX_FIFO: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            data = 32'h00000006; // Write Enable command
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              erase_state_d = ERASE_WE_WAIT_READY;
            end
          end

          ERASE_WE_WAIT_READY: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[31]) begin
                erase_state_d = ERASE_WE_SEND_CMD;
            end
          end

          ERASE_WE_SEND_CMD: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h0, 24'h0};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              erase_state_d = ERASE_SE_CHECK_TX_FIFO;
            end
          end

          ERASE_SE_CHECK_TX_FIFO: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[7:0] < SPI_FLASH_TX_FIFO_DEPTH) begin
              erase_state_d = ERASE_SE_FILL_TX_FIFO;
            end
          end

          ERASE_SE_FILL_TX_FIFO: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            data = (((bitfield_byteswap32(reg2hw.r_address & 32'h00ffffff)) >> 8) << 8) | 32'h20; // May need to change address!
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              erase_state_d = ERASE_SE_WAIT_READY;
            end
          end

          ERASE_SE_WAIT_READY: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish &&read_value[31] == 1'b1) begin
              erase_state_d = ERASE_SE_SEND_CMD;
            end
          end

          ERASE_SE_SEND_CMD: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h0, 24'h3};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              erase_state_d              = ERASE_IDLE;
              top_state_d               = TOP_FWAIT;
              fwait_state_d             = FWAIT_SET_RXWM_R; 
            end
          end

          default: begin
            erase_state_d = ERASE_IDLE;
          end
        endcase
      end

      // ========== WRITE FSM ==================

      TOP_WRITE: begin
        case (write_state_q)
          WRITE_IDLE: begin
            // Nothing to do here.
          end

          WRITE_PP_CHECK_TX_FIFO: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[7:0] < SPI_FLASH_TX_FIFO_DEPTH) begin
              write_state_d = WRITE_PP_FILL_TX_FIFO;
            end
          end

          WRITE_PP_FILL_TX_FIFO: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            data = (((bitfield_byteswap32(reg2hw.r_address & 32'h00ffffff)) >> 8) << 8) | 32'h02; // May need to change address!
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_PP_WAIT_READY;
            end
          end

          WRITE_PP_WAIT_READY: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish &&read_value[31] == 1'b1) begin
              write_state_d = WRITE_PP_WAIT_READY;
            end
          end

          WRITE_PP_SEND_CMD: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h1, 24'h3};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_CHECK_READY;
            end
          end

          WRITE_DMA_CHECK_READY: begin
            address   = DMA_START_ADDRESS + {25'b0, DMA_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish && read_value[0]) begin // DMA ready
                write_state_d = WRITE_DMA_SRC_PTR;
            end
          end

          WRITE_DMA_SRC_PTR: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_PTR_OFFSET};
            data = reg2hw.s_address;
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_DST_PTR;
            end
          end

          WRITE_DMA_DST_PTR: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_PTR_OFFSET};
            data = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_TXDATA_OFFSET};
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_SRC_INC;
            end
          end

          WRITE_DMA_SRC_INC: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_PTR_INC_D1_OFFSET};
            data = 32'h4;  // Or 1?
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_DST_INC;
            end
          end

          WRITE_DMA_DST_INC: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_PTR_INC_D1_OFFSET};
            data = 32'h0;  // keep aiming TX FIFO
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_SRC_TYPE;
            end
          end

          WRITE_DMA_SRC_TYPE: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SRC_DATA_TYPE_OFFSET};
            data = 32'h0;  // 32-bit word
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_DST_TYPE;
            end
          end

          WRITE_DMA_DST_TYPE: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_DST_DATA_TYPE_OFFSET};
            data = 32'h0;  // 32-bit word
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_TRIG;
            end
          end

          WRITE_DMA_TRIG: begin
            address = DMA_START_ADDRESS + {25'b0, DMA_SLOT_OFFSET};
            data = {16'h8, 16'h0};  // TX_TRG: Memory to TX SPI FLASH + RX_TRG: Memory read trigger
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d = WRITE_DMA_SIZE_D1;
            end
          end

          // Need to account for more complex situations
          WRITE_DMA_SIZE_D1: begin
            address   = DMA_START_ADDRESS + {25'b0, DMA_SIZE_D1_OFFSET};
            w_enable  = 1'b1;
            obi_start = 1'b1;

            if (reg2hw.length % 4 == 0) begin
              data = reg2hw.length >> 2;  // Number of bytes to transfer
            end else begin
              data = (reg2hw.length >> 2) + 1;  // Number of bytes to transfer rounded to next word
            end

            if (obi_finish) begin
              write_state_d = WRITE_TRANS;
            end
          end

          WRITE_TRANS: begin
            if (dma_done[0]) begin  // Transaction done
              write_state_d             = WRITE_IDLE;
            end
          end

          WRITE_PP_WAIT_READY_2: begin
            address   = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_STATUS_OFFSET};
            obi_start = 1'b1;

            if (obi_finish &&read_value[31] == 1'b1) begin
              write_state_d = WRITE_PP_WAIT_READY;
            end
          end

          WRITE_PP_SEND_CMD_2: begin
            address = SPI_FLASH_START_ADDRESS + {25'b0, SPI_HOST_COMMAND_OFFSET};
            data = {3'h0, 2'h2, 2'h0, 1'h0, reg2hw.length[23:0] - 1'h1};  // Empty + Direction + Speed + Csaat + Length
            w_enable = 1'b1;
            obi_start = 1'b1;

            if (obi_finish) begin
              write_state_d             = WRITE_IDLE;
              top_state_d               = TOP_FWAIT;
              fwait_state_d             = FWAIT_SET_RXWM_R; 
            end
          end

          default: begin
            write_state_d = WRITE_IDLE;
          end
        endcase
      end

      default: begin
        top_state_d = TOP_IDLE;
      end
    endcase
  end

  // Assignments
  assign my_ip_interrupt_o = 1'b0;
  assign hw2reg.status.d = (top_state_q == TOP_IDLE);
  assign hw2reg.status.de = 1'b1;

  // Registers 
  my_ip_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) my_ip_reg_top_i (
      .clk_i(clk_i),
      .rst_ni(rst_ni)
      .reg_req_i,
      .reg_rsp_o,
      .reg2hw,
      .hw2reg,
      .devmode_i(1'b1)
  );
endmodule


