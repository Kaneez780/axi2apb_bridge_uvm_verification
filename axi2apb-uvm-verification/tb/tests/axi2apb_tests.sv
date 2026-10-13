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



// ============================================================
// BACK-TO-BACK READ TEST
// Add this class to axi2apb_tests.sv
// ============================================================

class axi2apb_back_to_back_read_test
  extends axi2apb_base_test;


  `uvm_component_utils(
    axi2apb_back_to_back_read_test
  )


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name = "axi2apb_back_to_back_read_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction : new



  // --------------------------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------------------------

  function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "B2B_RD_TEST",
      "axi2apb_back_to_back_read_test build_phase executed",
      UVM_LOW
    )


  endfunction : build_phase



  // --------------------------------------------------------------------------
  // Run Phase
  // --------------------------------------------------------------------------

  task run_phase(
    uvm_phase phase
  );


    axi2apb_back_to_back_read_virtual_sequence
      vseq;


    `uvm_info(
      "B2B_RD_TEST",
      "Back-to-back AXI read test started",
      UVM_LOW
    )


    phase.raise_objection(this);


    // ------------------------------------------------------------------------
    // Create virtual sequence
    // ------------------------------------------------------------------------

    vseq =
      axi2apb_back_to_back_read_virtual_sequence::
      type_id::create("vseq");


    if (vseq == null) begin

      `uvm_fatal(
        "B2B_RD_TEST",
        "Failed to create back-to-back read virtual sequence"
      )

    end


    // ------------------------------------------------------------------------
    // Start on YOUR existing virtual sequencer
    // ------------------------------------------------------------------------

    vseq.start(
      env.virtual_sequencer
    );


    // ------------------------------------------------------------------------
    // Give monitors and scoreboard time to process final transaction
    // ------------------------------------------------------------------------

    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "B2B_RD_TEST",
      "Back-to-back AXI read test completed",
      UVM_LOW
    )


    phase.drop_objection(this);


  endtask : run_phase



  // --------------------------------------------------------------------------
  // Report Phase
  // --------------------------------------------------------------------------

  function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "B2B_RD_TEST",
      "axi2apb_back_to_back_read_test report_phase executed",
      UVM_LOW
    )


  endfunction : report_phase


endclass : axi2apb_back_to_back_read_test

// ============================================================================
// BACK-TO-BACK WRITE TEST
// ============================================================================

class axi2apb_back_to_back_write_test
  extends axi2apb_base_test;

  `uvm_component_utils(
    axi2apb_back_to_back_write_test
  )


  function new(
    string name = "axi2apb_back_to_back_write_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction : new



  // --------------------------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------------------------

  function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "B2B_WR_TEST",
      "axi2apb_back_to_back_write_test build_phase executed",
      UVM_LOW
    )


  endfunction : build_phase



  // --------------------------------------------------------------------------
  // Run Phase
  // --------------------------------------------------------------------------

  task run_phase(
    uvm_phase phase
  );

    axi2apb_back_to_back_write_virtual_sequence
      vseq;


    `uvm_info(
      "B2B_WR_TEST",
      "Back-to-back AXI write test started",
      UVM_LOW
    )


    phase.raise_objection(this);


    // ------------------------------------------------------------------------
    // Create virtual sequence
    // ------------------------------------------------------------------------

    vseq =
      axi2apb_back_to_back_write_virtual_sequence::
      type_id::create("vseq");


    if (vseq == null) begin

      `uvm_fatal(
        "B2B_WR_TEST",
        "Failed to create back-to-back write virtual sequence"
      )

    end


    // ------------------------------------------------------------------------
    // Start on existing project virtual sequencer
    // ------------------------------------------------------------------------

    vseq.start(
      env.virtual_sequencer
    );


    // ------------------------------------------------------------------------
    // Allow monitor and scoreboard to process final transaction
    // ------------------------------------------------------------------------

    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "B2B_WR_TEST",
      "Back-to-back AXI write test completed",
      UVM_LOW
    )


    phase.drop_objection(this);


  endtask : run_phase



  // --------------------------------------------------------------------------
  // Report Phase
  // --------------------------------------------------------------------------

  function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "B2B_WR_TEST",
      "axi2apb_back_to_back_write_test report_phase executed",
      UVM_LOW
    )


  endfunction : report_phase


endclass : axi2apb_back_to_back_write_test



// ============================================================================
// MIXED READ / WRITE TRAFFIC TEST
// ============================================================================

class axi2apb_mixed_traffic_test
  extends axi2apb_base_test;

  `uvm_component_utils(
    axi2apb_mixed_traffic_test
  )


  function new(
    string name = "axi2apb_mixed_traffic_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction : new



  // --------------------------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------------------------

  function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "MIXED_TEST",
      "axi2apb_mixed_traffic_test build_phase executed",
      UVM_LOW
    )


  endfunction : build_phase



  // --------------------------------------------------------------------------
  // Run Phase
  // --------------------------------------------------------------------------

  task run_phase(
    uvm_phase phase
  );

    axi2apb_mixed_traffic_virtual_sequence
      vseq;


    `uvm_info(
      "MIXED_TEST",
      "AXI2APB mixed read/write traffic test started",
      UVM_LOW
    )


    phase.raise_objection(this);


    // ------------------------------------------------------------------------
    // Create virtual sequence
    // ------------------------------------------------------------------------

    vseq =
      axi2apb_mixed_traffic_virtual_sequence::
      type_id::create("vseq");


    if (vseq == null) begin

      `uvm_fatal(
        "MIXED_TEST",
        "Failed to create mixed traffic virtual sequence"
      )

    end


    // ------------------------------------------------------------------------
    // Start on the existing project virtual sequencer
    // ------------------------------------------------------------------------

    vseq.start(
      env.virtual_sequencer
    );


    // ------------------------------------------------------------------------
    // Allow monitor and scoreboard to process final transaction
    // ------------------------------------------------------------------------

    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "MIXED_TEST",
      "AXI2APB mixed read/write traffic test completed",
      UVM_LOW
    )


    phase.drop_objection(this);


  endtask : run_phase



  // --------------------------------------------------------------------------
  // Report Phase
  // --------------------------------------------------------------------------

  function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "MIXED_TEST",
      "axi2apb_mixed_traffic_test report_phase executed",
      UVM_LOW
    )


  endfunction : report_phase


endclass : axi2apb_mixed_traffic_test


// ============================================================================
// AXI ID / USER PROPAGATION TEST
// ============================================================================

class axi2apb_id_user_test
  extends axi2apb_base_test;

  `uvm_component_utils(
    axi2apb_id_user_test
  )


  // --------------------------------------------------------------------------
  // Constructor
  // --------------------------------------------------------------------------

  function new(
    string name = "axi2apb_id_user_test",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction : new



  // --------------------------------------------------------------------------
  // Build Phase
  // --------------------------------------------------------------------------

  function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);


    `uvm_info(
      "ID_USER_TEST",
      "axi2apb_id_user_test build_phase executed",
      UVM_LOW
    )


  endfunction : build_phase



  // --------------------------------------------------------------------------
  // Run Phase
  // --------------------------------------------------------------------------

  task run_phase(
    uvm_phase phase
  );

    axi2apb_id_user_virtual_sequence
      vseq;


    `uvm_info(
      "ID_USER_TEST",
      "AXI ID/USER propagation test started",
      UVM_LOW
    )


    phase.raise_objection(this);


    // ------------------------------------------------------------------------
    // Create virtual sequence
    // ------------------------------------------------------------------------

    vseq =
      axi2apb_id_user_virtual_sequence::
      type_id::create("vseq");


    if (vseq == null) begin

      `uvm_fatal(
        "ID_USER_TEST",
        "Failed to create ID/USER virtual sequence"
      )

    end


    // ------------------------------------------------------------------------
    // Start virtual sequence
    // ------------------------------------------------------------------------

    vseq.start(
      env.virtual_sequencer
    );


    // ------------------------------------------------------------------------
    // Allow monitor and scoreboard to process final transaction
    // ------------------------------------------------------------------------

    repeat (5)
      @(posedge env.axi_agent.driver.vif.ACLK);


    `uvm_info(
      "ID_USER_TEST",
      "AXI ID/USER propagation test completed",
      UVM_LOW
    )


    phase.drop_objection(this);


  endtask : run_phase



  // --------------------------------------------------------------------------
  // Report Phase
  // --------------------------------------------------------------------------

  function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "ID_USER_TEST",
      "axi2apb_id_user_test report_phase executed",
      UVM_LOW
    )


  endfunction : report_phase


endclass : axi2apb_id_user_test
