class apb_slave_driver extends uvm_driver #(apb_slave_item);
  `uvm_component_utils(apb_slave_driver)

  virtual apb_if vif;

  // Simple APB slave memory model. This allows the first test to write a
  // value through AXI->APB and read the same value back through APB->AXI.
  bit [31:0] memory [bit [31:0]];

  function new(string name = "apb_slave_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_DRV", "virtual apb_if was not found in uvm_config_db")
  endfunction

  task drive_idle();
    vif.slave_cb.pready  <= 1'b0;
    vif.slave_cb.prdata  <= '0;
    vif.slave_cb.pslverr <= 1'b0;
  endtask

  task run_phase(uvm_phase phase);
    apb_slave_item rsp;
    bit [31:0] current_addr;
    bit        current_write;
    bit [31:0] current_wdata;
    bit [31:0] response_data;

    drive_idle();
    wait (vif.PRESETn === 1'b1);

    forever begin
      seq_item_port.get_next_item(rsp);

      // The supplied bridge keeps PSEL asserted and uses PENABLE to identify
      // an active APB request. Completion occurs only when PREADY is high.
      do @(vif.slave_cb);
      while (!(vif.slave_cb.psel && vif.slave_cb.penable));

      current_addr  = vif.slave_cb.paddr;
      current_write = vif.slave_cb.pwrite;
      current_wdata = vif.slave_cb.pwdata;

      repeat (rsp.wait_cycles) begin
        vif.slave_cb.pready <= 1'b0;
        @(vif.slave_cb);
      end

      if (current_write) begin
        response_data = '0;
      end
      else if (memory.exists(current_addr)) begin
        response_data = memory[current_addr];
      end
      else begin
        response_data = rsp.default_read_data;
      end

      vif.slave_cb.prdata  <= response_data;
      vif.slave_cb.pslverr <= rsp.inject_error;
      vif.slave_cb.pready  <= 1'b1;

      // APB transfer completes on a clock edge with PSEL, PENABLE and PREADY high.
      @(vif.slave_cb);

      if (current_write && !rsp.inject_error)
        memory[current_addr] = current_wdata;

      rsp.addr       = current_addr;
      rsp.write      = current_write;
      rsp.write_data = current_wdata;
      rsp.read_data  = response_data;
      rsp.pslverr    = rsp.inject_error;

      vif.slave_cb.pready  <= 1'b0;
      vif.slave_cb.pslverr <= 1'b0;
      vif.slave_cb.prdata  <= '0;

      seq_item_port.item_done();
    end
  endtask

endclass
