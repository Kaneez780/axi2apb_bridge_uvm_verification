// ============================================================
// BASE TEST
// ============================================================

class axi2apb_base_test extends uvm_test;

  `uvm_component_utils(axi2apb_base_test)

  axi2apb_env env;


  function new(
    string name = "axi2apb_base_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    env =
      axi2apb_env::type_id::create(
        "env",
        this
      );

  endfunction


endclass



// ============================================================
// TEST 1
// BASIC WRITE + READ TEST
// ============================================================

class axi2apb_write_read_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_write_read_test)


  function new(
    string name = "axi2apb_write_read_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  task run_phase(uvm_phase phase);

    axi2apb_write_read_virtual_sequence vseq;


    phase.raise_objection(this);


    `uvm_info(
      "WR_RD_TEST",
      "Starting AXI2APB write/read test",
      UVM_LOW
    )


    vseq =
      axi2apb_write_read_virtual_sequence::
      type_id::create("vseq");


    vseq.start(
      env.virtual_sequencer
    );


    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "WR_RD_TEST",
      "AXI2APB write/read test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


endclass



// ============================================================
// TEST 2
// APB WAIT STATE TEST
// ============================================================

class axi2apb_wait_state_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_wait_state_test)


  function new(
    string name = "axi2apb_wait_state_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  task run_phase(uvm_phase phase);

    axi2apb_wait_state_virtual_sequence vseq;


    phase.raise_objection(this);


    `uvm_info(
      "WAIT_TEST",
      "Starting AXI2APB APB wait-state test",
      UVM_LOW
    )


    vseq =
      axi2apb_wait_state_virtual_sequence::
      type_id::create("vseq");


    vseq.start(
      env.virtual_sequencer
    );


    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "WAIT_TEST",
      "AXI2APB APB wait-state test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


endclass
// ============================================================
// AXI2APB BACKPRESSURE TEST
// ============================================================

class axi2apb_backpressure_test extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_backpressure_test)


  function new(
    string name = "axi2apb_backpressure_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(
      "BP_TEST",
      "axi2apb_backpressure_test build_phase executed",
      UVM_LOW
    )

  endfunction


  task run_phase(uvm_phase phase);

    axi2apb_backpressure_virtual_sequence vseq;


    `uvm_info(
      "BP_TEST",
      "axi2apb_backpressure_test run_phase started",
      UVM_LOW
    )


    phase.raise_objection(this);


    vseq =
      axi2apb_backpressure_virtual_sequence::
      type_id::create("vseq");


    vseq.start(
      env.virtual_sequencer
    );


    // Allow monitor and scoreboard to process final transaction
    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "BP_TEST",
      "AXI2APB backpressure test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(
      "BP_TEST",
      "axi2apb_backpressure_test report_phase executed",
      UVM_LOW
    )

  endfunction


endclass





// ============================================================================
// CONSTRAINED-RANDOM TEST
// ============================================================================

class axi2apb_random_test
  extends axi2apb_base_test;

  `uvm_component_utils(axi2apb_random_test)


  function new(
    string name = "axi2apb_random_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(
      "RANDOM_TEST",
      "axi2apb_random_test build_phase executed",
      UVM_LOW
    )

  endfunction

  task run_phase(uvm_phase phase);

    axi2apb_random_virtual_sequence vseq;


    `uvm_info(
      "RANDOM_TEST",
      "axi2apb_random_test run_phase started",
      UVM_LOW
    )


    phase.raise_objection(this);


    vseq =
      axi2apb_random_virtual_sequence::
      type_id::create("vseq");


    // Number of random write/read pairs.
    vseq.number_of_transactions = 20;


    vseq.start(
      env.virtual_sequencer
    );


    // Let monitor and scoreboard finish processing.
    repeat (10)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "RANDOM_TEST",
      "AXI2APB constrained-random test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


  function void report_phase(uvm_phase phase);

    super.report_phase(phase);

    `uvm_info(
      "RANDOM_TEST",
      "axi2apb_random_test report_phase executed",
      UVM_LOW
    )

  endfunction


endclass

// ============================================================================
// AXI2APB ERROR RESPONSE TEST
// ============================================================================

class axi2apb_error_response_test
  extends axi2apb_base_test;

  `uvm_component_utils(
    axi2apb_error_response_test
  )


  function new(
    string name = "axi2apb_error_response_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "ERR_TEST",
      "axi2apb_error_response_test build_phase executed",
      UVM_LOW
    )

  endfunction


  task run_phase(
    uvm_phase phase
  );

    axi2apb_error_response_virtual_sequence
      vseq;


    `uvm_info(
      "ERR_TEST",
      "axi2apb_error_response_test run_phase started",
      UVM_LOW
    )


    phase.raise_objection(this);


    vseq =
      axi2apb_error_response_virtual_sequence::
      type_id::create("vseq");


    vseq.start(
      env.virtual_sequencer
    );


    // Allow monitors / scoreboard to complete.
    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "ERR_TEST",
      "AXI2APB error response test completed",
      UVM_LOW
    )


    phase.drop_objection(this);

  endtask


  function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "ERR_TEST",
      "axi2apb_error_response_test report_phase executed",
      UVM_LOW
    )

  endfunction


endclass
