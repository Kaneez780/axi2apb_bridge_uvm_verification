// ============================================================
// FILE 1:
// tb/axi_master_agent/axi_write_read_sequence.sv
// ============================================================

class axi_write_read_sequence
  extends uvm_sequence #(axi_master_item);

  `uvm_object_utils(axi_write_read_sequence)

  int unsigned bready_delay = 0;
  int unsigned rready_delay = 0;


  function new(
    string name = "axi_write_read_sequence"
  );

    super.new(name);

  endfunction


  task body();

    `uvm_info(
      "AXI_SEQ",
      "Starting single-beat AXI write followed by read",
      UVM_LOW
    )


    // ==========================================================
    // WRITE
    // ==========================================================

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

      req.bready_delay == local::bready_delay;

    })


    // ==========================================================
    // READ
    // ==========================================================

    `uvm_do_with(req, {

      write == 1'b0;

      addr == 32'h0000_0100;

      id == 16'h0022;

      user == 10'h02A;

      len == 8'd0;

      size == 3'd2;

      burst == 2'b01;

      req.rready_delay == local::rready_delay;

    })


    `uvm_info(
      "AXI_SEQ",
      "AXI write/read sequence completed",
      UVM_LOW
    )

  endtask


endclass



// ============================================================
// FILE 2:
// tb/virtual_sequences/axi2apb_backpressure_virtual_sequence.sv
// ============================================================

class axi2apb_backpressure_virtual_sequence
  extends uvm_sequence;

  `uvm_object_utils(axi2apb_backpressure_virtual_sequence)

  `uvm_declare_p_sequencer(axi2apb_virtual_sequencer)


  function new(
    string name = "axi2apb_backpressure_virtual_sequence"
  );

    super.new(name);

  endfunction


  task body();

    axi_write_read_sequence
      axi_sequence;

    apb_write_read_response_sequence
      apb_sequence;


    axi_sequence =
      axi_write_read_sequence::type_id::create(
        "axi_sequence"
      );


    apb_sequence =
      apb_write_read_response_sequence::type_id::create(
        "apb_sequence"
      );


    // ==========================================================
    // AXI BACKPRESSURE CONFIGURATION
    // ==========================================================

    axi_sequence.bready_delay = 3;

    axi_sequence.rready_delay = 4;


    // APB responds immediately in this test.
    apb_sequence.write_wait_cycles = 0;

    apb_sequence.read_wait_cycles = 0;


    `uvm_info(
      "BP_VSEQ",
      "Starting AXI write/read with delayed BREADY and RREADY",
      UVM_LOW
    )


    fork

      axi_sequence.start(
        p_sequencer.axi_sequencer
      );


      apb_sequence.start(
        p_sequencer.apb_sequencer
      );

    join


    `uvm_info(
      "BP_VSEQ",
      "AXI backpressure virtual sequence completed",
      UVM_LOW
    )

  endtask


endclass



// ============================================================
// FILE 3:
// ADD THIS CLASS INSIDE:
// tb/tests/axi2apb_tests.sv
// ============================================================

class axi2apb_backpressure_test
  extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_backpressure_test)


  function new(
    string name = "axi2apb_backpressure_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  task run_phase(uvm_phase phase);

    axi2apb_backpressure_virtual_sequence vseq;


    phase.raise_objection(this);


    `uvm_info(
      "BP_TEST",
      "Starting AXI2APB backpressure test",
      UVM_LOW
    )


    vseq =
      axi2apb_backpressure_virtual_sequence::
      type_id::create("vseq");


    vseq.start(
      env.virtual_sequencer
    );


    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "BP_TEST",
      "AXI2APB backpressure test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


endclass
