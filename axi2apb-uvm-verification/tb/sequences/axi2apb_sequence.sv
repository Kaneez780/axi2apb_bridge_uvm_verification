// ============================================================================
// File: axi2apb_sequences.sv
// Description:
//   Contains all AXI2APB project sequences and the virtual sequencer.
//
//   1. axi_write_read_sequence
//   2. apb_write_read_response_sequence
//   3. axi2apb_virtual_sequencer
//   4. axi2apb_write_read_virtual_sequence
//   5. axi2apb_wait_state_virtual_sequence
//   6. axi2apb_backpressure_virtual_sequence
// ============================================================================



// ============================================================================
// 1. AXI WRITE/READ SEQUENCE
// ============================================================================

class axi_write_read_sequence
  extends uvm_sequence #(axi_master_item);

  `uvm_object_utils(axi_write_read_sequence)


  // --------------------------------------------------------------------------
  // Configuration variables
  //
  // Normal test:
  //   cfg_bready_delay = 0
  //   cfg_rready_delay = 0
  //
  // Backpressure test:
  //   These values can be changed by the virtual sequence.
  // --------------------------------------------------------------------------

  rand int unsigned cfg_bready_delay;
  rand int unsigned cfg_rready_delay;


  constraint delay_c {

    cfg_bready_delay inside {[0:10]};

    cfg_rready_delay inside {[0:10]};

  }


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name = "axi_write_read_sequence"
  );

    super.new(name);

    // Default = no AXI backpressure
    cfg_bready_delay = 0;
    cfg_rready_delay = 0;

  endfunction



  // --------------------------------------------------------------------------
  // BODY
  // --------------------------------------------------------------------------

  virtual task body();


    `uvm_info(
      "AXI_SEQ",
      "Starting single-beat AXI write followed by read",
      UVM_LOW
    )


    // ========================================================================
    // AXI WRITE TRANSACTION
    //
    // Address : 0x00000100
    // Data    : 0xDEADBEEF
    // ID      : 0x0011
    // USER    : 0x015
    //
    // Single-beat transfer:
    // AWLEN   = 0
    // AWSIZE  = 2 -> 4 bytes
    // AWBURST = INCR
    // WSTRB   = F -> all 4 bytes enabled
    // WLAST   = 1
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b1;

      addr == 32'h0000_0100;

      data == 32'hDEAD_BEEF;

      id == 16'h0011;

      user == 10'h015;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      strb == 4'hF;

      last == 1'b1;

      bready_delay == local::cfg_bready_delay;

    })


    // ========================================================================
    // AXI READ TRANSACTION
    //
    // Read from the same address that was written above.
    // Expected data from APB side = 0xDEADBEEF
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b0;

      addr == 32'h0000_0100;

      id == 16'h0022;

      user == 10'h02A;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      rready_delay == local::cfg_rready_delay;

    })


    `uvm_info(
      "AXI_SEQ",
      "AXI write/read sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// 2. APB SLAVE RESPONSE SEQUENCE
// ============================================================================

class apb_write_read_response_sequence
  extends uvm_sequence #(apb_slave_item);

  `uvm_object_utils(apb_write_read_response_sequence)


  // --------------------------------------------------------------------------
  // Configurable APB wait states
  //
  // Normal test:
  //   cfg_write_wait_cycles = 0
  //   cfg_read_wait_cycles  = 0
  //
  // Wait-state test:
  //   e.g.
  //   cfg_write_wait_cycles = 3
  //   cfg_read_wait_cycles  = 4
  // --------------------------------------------------------------------------

  rand int unsigned cfg_write_wait_cycles;

  rand int unsigned cfg_read_wait_cycles;


  // --------------------------------------------------------------------------
  // Error configuration
  // --------------------------------------------------------------------------

  rand bit cfg_write_error;

  rand bit cfg_read_error;


  constraint wait_c {

    cfg_write_wait_cycles inside {[0:10]};

    cfg_read_wait_cycles inside {[0:10]};

  }


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name = "apb_write_read_response_sequence"
  );

    super.new(name);

    // Default APB response = immediate and no error
    cfg_write_wait_cycles = 0;

    cfg_read_wait_cycles = 0;

    cfg_write_error = 1'b0;

    cfg_read_error = 1'b0;

  endfunction



  // --------------------------------------------------------------------------
  // BODY
  // --------------------------------------------------------------------------

  virtual task body();


    `uvm_info(
      "APB_SEQ",
      "Preparing APB responses for one write and one read",
      UVM_LOW
    )


    // ========================================================================
    // RESPONSE #1
    // Response for AXI WRITE -> APB WRITE
    // ========================================================================

    `uvm_do_with(req, {

      wait_cycles ==
        local::cfg_write_wait_cycles;

      inject_error ==
        local::cfg_write_error;

      default_read_data ==
        32'h0000_0000;

    })


    // ========================================================================
    // RESPONSE #2
    // Response for AXI READ -> APB READ
    //
    // The APB slave driver/reference memory should return the data previously
    // written to address 0x100.
    //
    // default_read_data is only the fallback value.
    // ========================================================================

    `uvm_do_with(req, {

      wait_cycles ==
        local::cfg_read_wait_cycles;

      inject_error ==
        local::cfg_read_error;

      default_read_data ==
        32'h0000_0000;

    })


    `uvm_info(
      "APB_SEQ",
      "APB response sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// 3. VIRTUAL SEQUENCER
// ============================================================================

class axi2apb_virtual_sequencer
  extends uvm_sequencer;

  `uvm_component_utils(axi2apb_virtual_sequencer)


  // Handles to both physical sequencers
  axi_master_sequencer axi_sequencer;

  apb_slave_sequencer apb_sequencer;


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name = "axi2apb_virtual_sequencer",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction



  // --------------------------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------------------------

  virtual function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "VSEQ",
      "axi2apb_virtual_sequencer build_phase executed",
      UVM_LOW
    )


  endfunction


endclass



// ============================================================================
// 4. NORMAL AXI WRITE/READ VIRTUAL SEQUENCE
//
// Test purpose:
//   - AXI write
//   - immediate APB response
//   - AXI read
//   - immediate APB response
//
// No APB wait states.
// No AXI backpressure.
// ============================================================================

class axi2apb_write_read_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(
    axi2apb_write_read_virtual_sequence
  )


  `uvm_declare_p_sequencer(
    axi2apb_virtual_sequencer
  )


  axi_write_read_sequence
    axi_sequence;


  apb_write_read_response_sequence
    apb_sequence;


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name =
      "axi2apb_write_read_virtual_sequence"
  );

    super.new(name);

  endfunction



  // --------------------------------------------------------------------------
  // BODY
  // --------------------------------------------------------------------------

  virtual task body();


    `uvm_info(
      "VSEQ",
      "Starting coordinated AXI write/read and APB slave responses",
      UVM_LOW
    )


    // ========================================================================
    // AXI and APB sequences must execute simultaneously.
    //
    // AXI side:
    //   sends request
    //
    // APB side:
    //   waits for DUT generated APB request and supplies response
    // ========================================================================

    fork


      begin

        `uvm_do_on_with(
          axi_sequence,
          p_sequencer.axi_sequencer,
          {

            cfg_bready_delay == 0;

            cfg_rready_delay == 0;

          }
        )

      end


      begin

        `uvm_do_on_with(
          apb_sequence,
          p_sequencer.apb_sequencer,
          {

            cfg_write_wait_cycles == 0;

            cfg_read_wait_cycles == 0;

            cfg_write_error == 0;

            cfg_read_error == 0;

          }
        )

      end


    join


    `uvm_info(
      "VSEQ",
      "Coordinated virtual sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// 5. APB WAIT-STATE VIRTUAL SEQUENCE
//
// Test purpose:
//
// WRITE:
//   APB PREADY delayed by 3 cycles
//
// READ:
//   APB PREADY delayed by 4 cycles
//
// AXI response side has no intentional backpressure.
// ============================================================================

class axi2apb_wait_state_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(
    axi2apb_wait_state_virtual_sequence
  )


  `uvm_declare_p_sequencer(
    axi2apb_virtual_sequencer
  )


  axi_write_read_sequence
    axi_sequence;


  apb_write_read_response_sequence
    apb_sequence;


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name =
      "axi2apb_wait_state_virtual_sequence"
  );

    super.new(name);

  endfunction



  // --------------------------------------------------------------------------
  // BODY
  // --------------------------------------------------------------------------

  virtual task body();


    `uvm_info(
      "WAIT_VSEQ",
      "Starting write/read with APB wait states",
      UVM_LOW
    )


    fork


      // ======================================================================
      // AXI sequence remains exactly the same.
      //
      // No BREADY/RREADY delay in this test.
      // ======================================================================

      begin

        `uvm_do_on_with(
          axi_sequence,
          p_sequencer.axi_sequencer,
          {

            cfg_bready_delay == 0;

            cfg_rready_delay == 0;

          }
        )

      end


      // ======================================================================
      // APB side creates wait states.
      //
      // Write:
      //   PREADY remains low for 3 cycles.
      //
      // Read:
      //   PREADY remains low for 4 cycles.
      // ======================================================================

      begin

        `uvm_do_on_with(
          apb_sequence,
          p_sequencer.apb_sequencer,
          {

            cfg_write_wait_cycles == 3;

            cfg_read_wait_cycles == 4;

            cfg_write_error == 0;

            cfg_read_error == 0;

          }
        )

      end


    join


    `uvm_info(
      "WAIT_VSEQ",
      "Wait-state virtual sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// 6. AXI BACKPRESSURE VIRTUAL SEQUENCE
//
// Test purpose:
//
// WRITE RESPONSE:
//   DUT asserts BVALID.
//   AXI master delays BREADY for 3 cycles.
//
// READ RESPONSE:
//   DUT asserts RVALID.
//   AXI master delays RREADY for 4 cycles.
//
// APB slave responds immediately.
// ============================================================================

class axi2apb_backpressure_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(
    axi2apb_backpressure_virtual_sequence
  )


  `uvm_declare_p_sequencer(
    axi2apb_virtual_sequencer
  )


  axi_write_read_sequence
    axi_sequence;


  apb_write_read_response_sequence
    apb_sequence;


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name =
      "axi2apb_backpressure_virtual_sequence"
  );

    super.new(name);

  endfunction



  // --------------------------------------------------------------------------
  // BODY
  // --------------------------------------------------------------------------

  virtual task body();


    `uvm_info(
      "BP_VSEQ",
      "Starting AXI write/read with BREADY and RREADY backpressure",
      UVM_LOW
    )


    fork


      // ======================================================================
      // AXI response backpressure
      //
      // BREADY delayed 3 cycles.
      // RREADY delayed 4 cycles.
      // ======================================================================

      begin

        `uvm_do_on_with(
          axi_sequence,
          p_sequencer.axi_sequencer,
          {

            cfg_bready_delay == 3;

            cfg_rready_delay == 4;

          }
        )

      end


      // ======================================================================
      // APB responds immediately.
      //
      // Therefore any extra delay observed on AXI response is caused by
      // BREADY/RREADY backpressure rather than PREADY.
      // ======================================================================

      begin

        `uvm_do_on_with(
          apb_sequence,
          p_sequencer.apb_sequencer,
          {

            cfg_write_wait_cycles == 0;

            cfg_read_wait_cycles == 0;

            cfg_write_error == 0;

            cfg_read_error == 0;

          }
        )

      end


    join


    `uvm_info(
      "BP_VSEQ",
      "AXI backpressure virtual sequence completed",
      UVM_LOW
    )


  endtask


endclass


// ============================================================================
// RANDOM AXI WRITE/READ SEQUENCE
//
// Generates one random write followed by a read from the SAME address.
// This makes the random test self-checking and meaningful.
// ============================================================================

class axi_random_write_read_sequence
  extends uvm_sequence #(axi_master_item);

  `uvm_object_utils(axi_random_write_read_sequence)


  // Random values shared by the write and read
  rand bit [31:0] random_addr;
  rand bit [31:0] random_data;

  rand bit [15:0] write_id;
  rand bit [15:0] read_id;

  rand bit [9:0]  write_user;
  rand bit [9:0]  read_user;

  rand int unsigned write_bready_delay;
  rand int unsigned read_rready_delay;


  // Keep addresses word aligned for 32-bit transfers.
  constraint random_addr_c {

    random_addr[1:0] == 2'b00;

    // Keep the first random test in a practical address range.
    random_addr inside {
      [32'h0000_0000 : 32'h0000_FFFC]
    };

  }


  constraint random_delay_c {

    write_bready_delay inside {[0:4]};

    read_rready_delay inside {[0:4]};

  }


  function new(
    string name = "axi_random_write_read_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    // Randomize the sequence-level variables first.
    if (!randomize()) begin

      `uvm_fatal(
        "AXI_RANDOM_SEQ",
        "Failed to randomize AXI random write/read sequence"
      )

    end


    `uvm_info(
      "AXI_RANDOM_SEQ",
      $sformatf(
        "Random pair: addr=0x%08h data=0x%08h write_id=0x%04h read_id=0x%04h",
        random_addr,
        random_data,
        write_id,
        read_id
      ),
      UVM_MEDIUM
    )


    // ========================================================================
    // RANDOM WRITE
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b1;

      addr == local::random_addr;

      data == local::random_data;

      id == local::write_id;

      user == local::write_user;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      strb == 4'hF;

      last == 1'b1;

      bready_delay == local::write_bready_delay;

      rready_delay == 0;

    })


    // ========================================================================
    // READ BACK FROM SAME RANDOM ADDRESS
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b0;

      addr == local::random_addr;

      id == local::read_id;

      user == local::read_user;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      strb == 4'hF;

      last == 1'b1;

      bready_delay == 0;

      rready_delay == local::read_rready_delay;

    })


  endtask


endclass



// ============================================================================
// RANDOM APB RESPONSE SEQUENCE
//
// Generates two APB responses:
// 1. response for random write
// 2. response for random read
//
// Each response gets independently randomized wait states.
// ============================================================================

class apb_random_write_read_response_sequence
  extends uvm_sequence #(apb_slave_item);

  `uvm_object_utils(apb_random_write_read_response_sequence)


  rand int unsigned random_write_wait;
  rand int unsigned random_read_wait;


  constraint random_wait_c {

    random_write_wait inside {[0:4]};

    random_read_wait inside {[0:4]};

  }


  function new(
    string name = "apb_random_write_read_response_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    if (!randomize()) begin

      `uvm_fatal(
        "APB_RANDOM_SEQ",
        "Failed to randomize APB response sequence"
      )

    end


    `uvm_info(
      "APB_RANDOM_SEQ",
      $sformatf(
        "Random APB waits: write=%0d read=%0d",
        random_write_wait,
        random_read_wait
      ),
      UVM_MEDIUM
    )


    // Response for APB write
    `uvm_do_with(req, {

      wait_cycles ==
        local::random_write_wait;

      inject_error ==
        1'b0;

      default_read_data ==
        32'h0000_0000;

    })


    // Response for APB read
    `uvm_do_with(req, {

      wait_cycles ==
        local::random_read_wait;

      inject_error ==
        1'b0;

      default_read_data ==
        32'h0000_0000;

    })


  endtask


endclass



// ============================================================================
// RANDOM VIRTUAL SEQUENCE
//
// Runs several random write/read pairs.
// AXI and APB sequences execute together for every pair.
// ============================================================================

class axi2apb_random_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(axi2apb_random_virtual_sequence)

  `uvm_declare_p_sequencer(
    axi2apb_virtual_sequencer
  )


  int unsigned number_of_transactions = 20;


  axi_random_write_read_sequence
    axi_random_sequence;

  apb_random_write_read_response_sequence
    apb_random_sequence;


  function new(
    string name = "axi2apb_random_virtual_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    `uvm_info(
      "RANDOM_VSEQ",
      $sformatf(
        "Starting AXI2APB constrained-random test with %0d write/read pairs",
        number_of_transactions
      ),
      UVM_LOW
    )


    repeat (number_of_transactions) begin


      fork


        begin

          `uvm_do_on(
            axi_random_sequence,
            p_sequencer.axi_sequencer
          )

        end


        begin

          `uvm_do_on(
            apb_random_sequence,
            p_sequencer.apb_sequencer
          )

        end


      join


    end


    `uvm_info(
      "RANDOM_VSEQ",
      "AXI2APB constrained-random virtual sequence completed",
      UVM_LOW
    )


  endtask


endclass

// ============================================================================
// AXI ERROR WRITE/READ SEQUENCE
//
// Sends:
//   1. One AXI write
//   2. One AXI read
//
// APB side will intentionally return PSLVERR for both.
// ============================================================================

class axi_error_write_read_sequence
  extends uvm_sequence #(axi_master_item);

  `uvm_object_utils(axi_error_write_read_sequence)


  function new(
    string name = "axi_error_write_read_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    `uvm_info(
      "AXI_ERR_SEQ",
      "Starting AXI write/read for APB error propagation test",
      UVM_LOW
    )


    // ========================================================================
    // WRITE REQUEST
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b1;

      addr == 32'h0000_0200;

      data == 32'hCAFE_BABE;

      id == 16'h00A1;

      user == 10'h055;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      strb == 4'hF;

      last == 1'b1;

      bready_delay == 0;

      rready_delay == 0;

    })


    // ========================================================================
    // READ REQUEST
    // ========================================================================

    `uvm_do_with(req, {

      write == 1'b0;

      addr == 32'h0000_0200;

      id == 16'h00B2;

      user == 10'h066;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      strb == 4'hF;

      last == 1'b1;

      bready_delay == 0;

      rready_delay == 0;

    })


    `uvm_info(
      "AXI_ERR_SEQ",
      "AXI error write/read sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// APB ERROR RESPONSE SEQUENCE
//
// Generates:
//   WRITE response -> PSLVERR = 1
//   READ response  -> PSLVERR = 1
// ============================================================================

class apb_error_response_sequence
  extends uvm_sequence #(apb_slave_item);

  `uvm_object_utils(apb_error_response_sequence)


  function new(
    string name = "apb_error_response_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    `uvm_info(
      "APB_ERR_SEQ",
      "Starting APB error responses",
      UVM_LOW
    )


    // ========================================================================
    // ERROR RESPONSE FOR WRITE
    // ========================================================================

    `uvm_do_with(req, {

      wait_cycles == 0;

      inject_error == 1'b1;

      default_read_data == 32'h0000_0000;

    })


    // ========================================================================
    // ERROR RESPONSE FOR READ
    //
    // Data itself is not the main purpose here.
    // We mainly want PSLVERR = 1 and AXI RRESP = SLVERR.
    // ========================================================================

    `uvm_do_with(req, {

      wait_cycles == 0;

      inject_error == 1'b1;

      default_read_data == 32'h1234_5678;

    })


    `uvm_info(
      "APB_ERR_SEQ",
      "APB error response sequence completed",
      UVM_LOW
    )


  endtask


endclass



// ============================================================================
// AXI2APB ERROR VIRTUAL SEQUENCE
// ============================================================================

class axi2apb_error_response_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(
    axi2apb_error_response_virtual_sequence
  )

  `uvm_declare_p_sequencer(
    axi2apb_virtual_sequencer
  )


  axi_error_write_read_sequence
    axi_sequence;

  apb_error_response_sequence
    apb_sequence;


  function new(
    string name =
      "axi2apb_error_response_virtual_sequence"
  );

    super.new(name);

  endfunction


  virtual task body();


    `uvm_info(
      "ERR_VSEQ",
      "Starting AXI2APB error propagation virtual sequence",
      UVM_LOW
    )


    fork


      begin

        `uvm_do_on(
          axi_sequence,
          p_sequencer.axi_sequencer
        )

      end


      begin

        `uvm_do_on(
          apb_sequence,
          p_sequencer.apb_sequencer
        )

      end


    join


    `uvm_info(
      "ERR_VSEQ",
      "AXI2APB error propagation virtual sequence completed",
      UVM_LOW
    )


  endtask


endclass
