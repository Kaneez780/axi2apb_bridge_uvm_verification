class axi_master_monitor extends uvm_monitor;

  `uvm_component_utils(axi_master_monitor)

  virtual axi4_if vif;

  uvm_analysis_port #(axi_master_item) analysis_port;


  function new(
    string name = "axi_master_monitor",
    uvm_component parent = null
  );

    super.new(name, parent);

    analysis_port = new("analysis_port", this);

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db#(virtual axi4_if)::get(
          this,
          "",
          "vif",
          vif
        ))
    begin

      `uvm_fatal(
        "AXI_MON",
        "virtual axi4_if was not found in uvm_config_db"
      )

    end

  endfunction



  task run_phase(uvm_phase phase);

    fork

      monitor_write_channel();

      monitor_read_channel();

    join

  endtask



  // ============================================================
  // WRITE MONITOR
  // ============================================================

  task monitor_write_channel();

    bit [31:0] address;
    bit [31:0] write_data;

    bit [15:0] request_id;
    bit [9:0]  request_user;

    bit got_aw;
    bit got_w;


    forever begin

      got_aw = 1'b0;
      got_w  = 1'b0;


      // --------------------------------------------------------
      // Capture AW and W independently
      // --------------------------------------------------------

      while (!(got_aw && got_w)) begin

        @(vif.monitor_cb);


        if (
          !got_aw &&
          vif.monitor_cb.awvalid &&
          vif.monitor_cb.awready
        )
        begin

          address      = vif.monitor_cb.awaddr;
          request_id   = vif.monitor_cb.awid;
          request_user = vif.monitor_cb.awuser;

          got_aw = 1'b1;


          `uvm_info(
            "AXI_MON",
            $sformatf(
              "Captured AW: addr=0x%08h id=0x%04h",
              address,
              request_id
            ),
            UVM_MEDIUM
          )

        end


        if (
          !got_w &&
          vif.monitor_cb.wvalid &&
          vif.monitor_cb.wready
        )
        begin

          write_data = vif.monitor_cb.wdata;

          got_w = 1'b1;


          `uvm_info(
            "AXI_MON",
            $sformatf(
              "Captured W: data=0x%08h",
              write_data
            ),
            UVM_MEDIUM
          )

        end

      end



      // --------------------------------------------------------
      // Wait for B response handshake
      // --------------------------------------------------------

      while (1) begin

        @(vif.monitor_cb);

        if (
          vif.monitor_cb.bvalid &&
          vif.monitor_cb.bready
        )
        begin

          axi_master_item tr;


          tr =
            axi_master_item::type_id::create(
              "monitored_axi_write"
            );


          tr.write = 1'b1;

          tr.addr = address;

          tr.data = write_data;

          tr.id = request_id;

          tr.user = request_user;


          tr.resp =
            vif.monitor_cb.bresp;


          tr.response_id =
            vif.monitor_cb.bid;


          tr.response_user =
            vif.monitor_cb.buser;


          `uvm_info(
            "AXI_MON",
            $sformatf(
              "WRITE COMPLETE addr=0x%08h id=0x%04h BID=0x%04h",
              tr.addr,
              tr.id,
              tr.response_id
            ),
            UVM_MEDIUM
          )


          analysis_port.write(tr);

          break;

        end

      end

    end

  endtask



  // ============================================================
  // READ MONITOR
  // ============================================================

  task monitor_read_channel();

    bit [31:0] address;

    bit [15:0] request_id;

    bit [9:0] request_user;


    forever begin


      // --------------------------------------------------------
      // Wait explicitly for ARVALID && ARREADY
      // --------------------------------------------------------

      while (1) begin

        @(vif.monitor_cb);


        if (
          vif.monitor_cb.arvalid &&
          vif.monitor_cb.arready
        )
        begin

          // IMPORTANT:
          // Save request information immediately at AR handshake.

          address =
            vif.monitor_cb.araddr;


          request_id =
            vif.monitor_cb.arid;


          request_user =
            vif.monitor_cb.aruser;


          `uvm_info(
            "AXI_MON",
            $sformatf(
              "Captured AR: addr=0x%08h id=0x%04h user=0x%03h",
              address,
              request_id,
              request_user
            ),
            UVM_MEDIUM
          )


          break;

        end

      end



      // --------------------------------------------------------
      // Now wait for RVALID && RREADY
      // --------------------------------------------------------

      while (1) begin

        @(vif.monitor_cb);


        if (
          vif.monitor_cb.rvalid &&
          vif.monitor_cb.rready
        )
        begin

          axi_master_item tr;


          tr =
            axi_master_item::type_id::create(
              "monitored_axi_read"
            );


          tr.write = 1'b0;


          // Use SAVED request values.
          tr.addr =
            address;


          tr.id =
            request_id;


          tr.user =
            request_user;


          // Capture response values.
          tr.read_data =
            vif.monitor_cb.rdata;


          tr.resp =
            vif.monitor_cb.rresp;


          tr.response_id =
            vif.monitor_cb.rid;


          tr.response_user =
            vif.monitor_cb.ruser;


          tr.response_last =
            vif.monitor_cb.rlast;


          `uvm_info(
            "AXI_MON",
            $sformatf(
              "READ COMPLETE addr=0x%08h request_id=0x%04h RID=0x%04h data=0x%08h",
              tr.addr,
              tr.id,
              tr.response_id,
              tr.read_data
            ),
            UVM_MEDIUM
          )


          analysis_port.write(tr);

          break;

        end

      end

    end

  endtask


endclass
