package axi2apb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // Items
  `include "axi_master_agent/axi_master_item.sv"
  `include "apb_slave_agent/apb_slave_item.sv"

  // Sequencers
  `include "axi_master_agent/axi_master_sequencer.sv"
  `include "apb_slave_agent/apb_slave_sequencer.sv"

  // Drivers / monitors / agents
  `include "axi_master_agent/axi_master_driver.sv"
  `include "axi_master_agent/axi_master_monitor.sv"
  `include "axi_master_agent/axi_master_agent.sv"

  `include "apb_slave_agent/apb_slave_driver.sv"
  `include "apb_slave_agent/apb_slave_monitor.sv"
  `include "apb_slave_agent/apb_slave_agent.sv"

  // All sequences
  `include "sequences/axi2apb_sequence.sv"

  // Environment
  `include "environment/axi2apb_scoreboard.sv"
  `include "environment/axi2apb_coverage.sv"
  `include "environment/axi2apb_env.sv"

  // All tests
  `include "tests/axi2apb_tests.sv"

endpackage
