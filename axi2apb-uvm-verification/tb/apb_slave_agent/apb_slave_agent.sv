class apb_slave_agent extends uvm_agent;
  `uvm_component_utils(apb_slave_agent)

  apb_slave_sequencer sequencer;
  apb_slave_driver    driver;
  apb_slave_monitor   monitor;

  function new(string name = "apb_slave_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    sequencer = apb_slave_sequencer::type_id::create("sequencer", this);
    driver    = apb_slave_driver::type_id::create("driver", this);
    monitor   = apb_slave_monitor::type_id::create("monitor", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction

endclass
