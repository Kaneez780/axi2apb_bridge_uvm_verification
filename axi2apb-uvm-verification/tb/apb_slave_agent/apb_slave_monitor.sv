class apb_slave_monitor extends uvm_monitor;
  `uvm_component_utils(apb_slave_monitor)

  virtual apb_if vif;
  uvm_analysis_port #(apb_slave_item) analysis_port;

  function new(string name = "apb_slave_monitor", uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_if)::get(this, "", "vif", vif))
      `uvm_fatal("APB_MON", "virtual apb_if was not found in uvm_config_db")
  endfunction

  task run_phase(uvm_phase phase);
    forever begin
      do @(vif.monitor_cb);
      while (!(vif.monitor_cb.psel && vif.monitor_cb.penable && vif.monitor_cb.pready));

      begin
        apb_slave_item tr;
        tr = apb_slave_item::type_id::create("monitored_apb_transfer");
        tr.addr       = vif.monitor_cb.paddr;
        tr.write      = vif.monitor_cb.pwrite;
        tr.write_data = vif.monitor_cb.pwdata;
        tr.read_data  = vif.monitor_cb.prdata;
        tr.pslverr    = vif.monitor_cb.pslverr;

        `uvm_info("APB_MON",
          $sformatf("TRANSFER addr=0x%08h write=%0b wdata=0x%08h rdata=0x%08h",
                    tr.addr, tr.write, tr.write_data, tr.read_data),
          UVM_MEDIUM)

        analysis_port.write(tr);
      end

      // Prevent duplicate sampling of a completed transfer.
      do @(vif.monitor_cb);
      while (vif.monitor_cb.penable);
    end
  endtask

endclass
