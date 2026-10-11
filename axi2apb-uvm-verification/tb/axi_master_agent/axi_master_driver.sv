class axi_master_driver extends uvm_driver #(axi_master_item);

  `uvm_component_utils(axi_master_driver)

  virtual axi4_if vif;


  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  function new(
    string name = "axi_master_driver",
    uvm_component parent = null
  );

    super.new(name, parent);

  endfunction


  // ============================================================
  // BUILD PHASE
  // ============================================================

  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    `uvm_info(
      "AXI_DRV",
      "axi_master_driver build_phase executed",
      UVM_LOW
    )

    if (!uvm_config_db#(virtual axi4_if)::get(
          this,
          "",
          "vif",
          vif
        ))
    begin

      `uvm_fatal(
        "AXI_DRV",
        "virtual axi4_if was not found in uvm_config_db"
      )

    end

  endfunction


  // ============================================================
  // DRIVE AXI MASTER SIGNALS TO IDLE
  // ============================================================

  task drive_idle();

    vif.master_cb.awvalid <= 1'b0;

    vif.master_cb.wvalid  <= 1'b0;

    vif.master_cb.bready  <= 1'b0;

    vif.master_cb.arvalid <= 1'b0;

    vif.master_cb.rready  <= 1'b0;

  endtask


  // ============================================================
  // RUN PHASE
  // ============================================================

  task run_phase(uvm_phase phase);

    axi_master_item tr;

    `uvm_info(
      "AXI_DRV",
      "axi_master_driver run_phase started",
      UVM_LOW
    )

    drive_idle();


    // Wait until DUT reset is released.
    wait (vif.ARESETn === 1'b1);


    forever begin

      seq_item_port.get_next_item(tr);


      if (tr.write) begin

        drive_write(tr);

      end

      else begin

        drive_read(tr);

      end


      seq_item_port.item_done();

    end

  endtask


  // ============================================================
  // AXI WRITE TASK
  // ============================================================

  task drive_write(axi_master_item tr);

    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "WRITE addr=0x%08h data=0x%08h id=0x%04h",
        tr.addr,
        tr.data,
        tr.id
      ),
      UVM_MEDIUM
    )


    // ----------------------------------------------------------
    // Initially keep BREADY LOW.
    //
    // For a normal test:
    //   bready_delay = 0
    //
    // For backpressure test:
    //   bready_delay = 3
    // ----------------------------------------------------------

    vif.master_cb.bready <= 1'b0;


    // ==========================================================
    // AXI AW and W channels are independent.
    // Drive both channels in parallel.
    // ==========================================================

    fork


      // ========================================================
      // WRITE ADDRESS CHANNEL
      // ========================================================

      begin : drive_aw

        @(vif.master_cb);


        vif.master_cb.awid     <= tr.id;

        vif.master_cb.awaddr   <= tr.addr;

        vif.master_cb.awlen    <= tr.len;

        vif.master_cb.awsize   <= tr.size;

        vif.master_cb.awburst  <= tr.burst;

        vif.master_cb.awlock   <= tr.lock;

        vif.master_cb.awcache  <= tr.cache;

        vif.master_cb.awprot   <= tr.prot;

        vif.master_cb.awregion <= tr.region;

        vif.master_cb.awuser   <= tr.user;

        vif.master_cb.awqos    <= tr.qos;

        vif.master_cb.awvalid  <= 1'b1;


        // Wait until AXI write-address handshake occurs.
        do begin

          @(vif.master_cb);

        end
        while (vif.master_cb.awready !== 1'b1);


        // AWVALID can be removed after handshake.
        vif.master_cb.awvalid <= 1'b0;

      end


      // ========================================================
      // WRITE DATA CHANNEL
      // ========================================================

      begin : drive_w

        @(vif.master_cb);


        vif.master_cb.wdata  <= tr.data;

        vif.master_cb.wstrb  <= tr.strb;

        vif.master_cb.wlast  <= tr.last;

        vif.master_cb.wuser  <= tr.user;

        vif.master_cb.wvalid <= 1'b1;


        // Wait until AXI write-data handshake occurs.
        do begin

          @(vif.master_cb);

        end
        while (vif.master_cb.wready !== 1'b1);


        // WVALID can be removed after handshake.
        vif.master_cb.wvalid <= 1'b0;

      end


    join


    // ==========================================================
    // WRITE RESPONSE / B CHANNEL
    //
    // IMPORTANT:
    //
    // Previously BREADY was asserted before BVALID.
    // Therefore no real backpressure occurred.
    //
    // Now:
    //
    // 1. Wait for BVALID
    // 2. Keep BREADY LOW for requested number of cycles
    // 3. Assert BREADY
    // 4. Complete handshake
    // ==========================================================


    // Wait for DUT to produce write response.
    do begin

      @(vif.master_cb);

    end
    while (vif.master_cb.bvalid !== 1'b1);


    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "BVALID detected - delaying BREADY for %0d cycles",
        tr.bready_delay
      ),
      UVM_MEDIUM
    )


    // ----------------------------------------------------------
    // Apply write-response backpressure.
    // ----------------------------------------------------------

    repeat (tr.bready_delay) begin

      vif.master_cb.bready <= 1'b0;

      @(vif.master_cb);

    end


    // ----------------------------------------------------------
    // Master is now ready to accept B response.
    // ----------------------------------------------------------

    vif.master_cb.bready <= 1'b1;


    // Wait for actual BVALID/BREADY handshake.
    do begin

      @(vif.master_cb);

    end
    while (vif.master_cb.bvalid !== 1'b1);


    // Capture AXI write response.
    tr.resp          = vif.master_cb.bresp;

    tr.response_id   = vif.master_cb.bid;

    tr.response_user = vif.master_cb.buser;


    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "WRITE RESPONSE BID=0x%04h BRESP=%0b",
        tr.response_id,
        tr.resp
      ),
      UVM_MEDIUM
    )


    // Remove BREADY after response handshake.
    vif.master_cb.bready <= 1'b0;


  endtask


  // ============================================================
  // AXI READ TASK
  // ============================================================

  task drive_read(axi_master_item tr);

    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "READ addr=0x%08h id=0x%04h",
        tr.addr,
        tr.id
      ),
      UVM_MEDIUM
    )


    // ----------------------------------------------------------
    // Initially keep RREADY LOW.
    //
    // For a normal test:
    //   rready_delay = 0
    //
    // For backpressure test:
    //   rready_delay = 4
    // ----------------------------------------------------------

    vif.master_cb.rready <= 1'b0;


    // ==========================================================
    // READ ADDRESS CHANNEL
    // ==========================================================

    @(vif.master_cb);


    vif.master_cb.arid     <= tr.id;

    vif.master_cb.araddr   <= tr.addr;

    vif.master_cb.arlen    <= tr.len;

    vif.master_cb.arsize   <= tr.size;

    vif.master_cb.arburst  <= tr.burst;

    vif.master_cb.arlock   <= tr.lock;

    vif.master_cb.arcache  <= tr.cache;

    vif.master_cb.arprot   <= tr.prot;

    vif.master_cb.arregion <= tr.region;

    vif.master_cb.aruser   <= tr.user;

    vif.master_cb.arqos    <= tr.qos;

    vif.master_cb.arvalid  <= 1'b1;


    // ----------------------------------------------------------
    // Wait for ARVALID / ARREADY handshake.
    // ----------------------------------------------------------

    do begin

      @(vif.master_cb);

    end
    while (vif.master_cb.arready !== 1'b1);


    vif.master_cb.arvalid <= 1'b0;


    // ==========================================================
    // READ RESPONSE / R CHANNEL
    //
    // IMPORTANT:
    //
    // 1. Wait for RVALID
    // 2. Keep RREADY LOW for requested cycles
    // 3. Assert RREADY
    // 4. Capture response on handshake
    // ==========================================================


    // Wait for DUT to produce the read response.
    do begin

      @(vif.master_cb);

    end
    while (vif.master_cb.rvalid !== 1'b1);


    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "RVALID detected - delaying RREADY for %0d cycles",
        tr.rready_delay
      ),
      UVM_MEDIUM
    )


    // ----------------------------------------------------------
    // Apply read-response backpressure.
    // ----------------------------------------------------------

    repeat (tr.rready_delay) begin

      vif.master_cb.rready <= 1'b0;

      @(vif.master_cb);

    end


    // ----------------------------------------------------------
    // Master is now ready to accept read response.
    // ----------------------------------------------------------

    vif.master_cb.rready <= 1'b1;


    // Wait for actual RVALID/RREADY handshake.
    do begin

      @(vif.master_cb);

    end
    while (vif.master_cb.rvalid !== 1'b1);


    // Capture AXI read response.
    tr.read_data =
      vif.master_cb.rdata;


    tr.resp =
      vif.master_cb.rresp;


    tr.response_id =
      vif.master_cb.rid;


    tr.response_user =
      vif.master_cb.ruser;


    tr.response_last =
      vif.master_cb.rlast;


    `uvm_info(
      "AXI_DRV",
      $sformatf(
        "READ RESPONSE RID=0x%04h RDATA=0x%08h RRESP=%0b RLAST=%0b",
        tr.response_id,
        tr.read_data,
        tr.resp,
        tr.response_last
      ),
      UVM_MEDIUM
    )


    // Remove RREADY after handshake.
    vif.master_cb.rready <= 1'b0;


  endtask


endclass
