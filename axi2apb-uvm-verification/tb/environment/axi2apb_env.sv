class axi2apb_env extends uvm_env;
  `uvm_component_utils(axi2apb_env)

  axi_master_agent          axi_agent;
  apb_slave_agent           apb_agent;
  axi2apb_virtual_sequencer virtual_sequencer;
  axi2apb_scoreboard        scoreboard;
  axi2apb_coverage coverage;

  function new(string name = "axi2apb_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    axi_agent         = axi_master_agent::type_id::create("axi_agent", this);
    apb_agent         = apb_slave_agent::type_id::create("apb_agent", this);
    virtual_sequencer = axi2apb_virtual_sequencer::type_id::create("virtual_sequencer", this);
    scoreboard        = axi2apb_scoreboard::type_id::create("scoreboard", this);
    coverage = axi2apb_coverage::type_id::create( "coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    virtual_sequencer.axi_sequencer = axi_agent.sequencer;
    virtual_sequencer.apb_sequencer = apb_agent.sequencer;

    axi_agent.monitor.analysis_port.connect(scoreboard.axi_export);
    apb_agent.monitor.analysis_port.connect(scoreboard.apb_export);

   axi_agent.monitor.analysis_port.connect(coverage.axi_imp);
  apb_agent.monitor.analysis_port.connect(coverage.apb_imp);
  endfunction

endclass
