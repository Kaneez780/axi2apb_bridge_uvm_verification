# Testbench structure

```text
tb/
├── interfaces/
│   ├── axi4_if.sv
│   └── apb_if.sv
├── axi_master_agent/
│   ├── axi_master_item.sv
│   ├── axi_master_sequencer.sv
│   ├── axi_write_read_sequence.sv
│   ├── axi_master_driver.sv
│   ├── axi_master_monitor.sv
│   └── axi_master_agent.sv
├── apb_slave_agent/
│   ├── apb_slave_item.sv
│   ├── apb_slave_sequencer.sv
│   ├── apb_write_read_response_sequence.sv
│   ├── apb_slave_driver.sv
│   ├── apb_slave_monitor.sv
│   └── apb_slave_agent.sv
├── virtual_sequences/
│   ├── axi2apb_virtual_sequencer.sv
│   └── axi2apb_write_read_virtual_sequence.sv
├── environment/
│   ├── axi2apb_scoreboard.sv
│   └── axi2apb_env.sv
├── tests/
│   ├── axi2apb_base_test.sv
│   └── axi2apb_write_read_test.sv
├── top/
│   └── axi2apb_tb_top.sv
└── axi2apb_pkg.sv
```

No assertions or functional coverage are included in this first baseline.
