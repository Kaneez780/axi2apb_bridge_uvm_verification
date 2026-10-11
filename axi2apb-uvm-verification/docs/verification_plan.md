# Verification Plan

## Objective

Verify that the AXI-to-APB bridge correctly translates supported AXI transactions into APB transfers and returns the APB completion/data back to AXI.

## Architecture

- Active AXI master UVM agent
- Active APB slave UVM agent
- Cross-protocol scoreboard
- Functional coverage collector
- Virtual sequencer for coordinated stimulus
- Protocol assertions on AXI and APB

## Primary feature list

1. Single AXI write -> APB write
2. Single AXI read -> APB read
3. APB wait states
4. AXI B-channel backpressure
5. AXI R-channel backpressure
6. Address/data preservation
7. APB error observation
8. Read/write priority behavior
9. Back-to-back traffic
10. Mixed randomized traffic
11. Reset behavior
12. ID/USER propagation where supported by the DUT

## DUT-specific caveat

Do not assume unsupported features such as full burst translation or PSLVERR-to-SLVERR conversion until the RTL behavior is confirmed.
