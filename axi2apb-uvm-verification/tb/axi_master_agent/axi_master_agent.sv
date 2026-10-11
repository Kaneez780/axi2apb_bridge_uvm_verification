class axi_master_agent extends uvm_agent;
  `uvm_component_utils(axi_master_agent)

  axi_master_sequencer sequencer;
  axi_master_driver    driver;
  axi_master_monitor   monitor;

  function new(string name = "axi_master_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sequencer = axi_master_sequencer::type_id::create("sequencer", this);
    driver    = axi_master_driver::type_id::create("driver", this);
    monitor   = axi_master_monitor::type_id::create("monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass
