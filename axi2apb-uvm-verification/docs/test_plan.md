# Test Plan

| Test | Goal |
|---|---|
| axi2apb_write_test | Basic AXI write to APB write conversion |
| axi2apb_read_test | Basic AXI read to APB read conversion |
| axi2apb_write_wait_test | APB wait states on write |
| axi2apb_read_wait_test | APB wait states on read |
| axi2apb_bready_delay_test | AXI write response backpressure |
| axi2apb_rready_delay_test | AXI read response backpressure |
| axi2apb_pslverr_test | Observe bridge response when APB PSLVERR is asserted |
| axi2apb_random_stress_test | Mixed random transactions and delay combinations |

## Next tests to add after DUT hookup

- simultaneous AR/AW priority
- back-to-back reads
- back-to-back writes
- mixed read/write traffic
- ID/USER propagation
- reset during transfer
- burst behavior characterization
