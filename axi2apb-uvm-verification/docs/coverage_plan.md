# Coverage Plan

## AXI functional coverage

- read vs write
- low/mid/high address regions
- response values
- write strobe patterns
- read/write x response cross

## APB functional coverage

- read vs write
- PSLVERR 0/1
- read/write x PSLVERR cross

## Planned additions

After DUT integration, add:
- APB wait-state bins: 0, 1, 2-3, 4+
- AXI backpressure bins
- simultaneous read/write request bin
- back-to-back transfer bins
- ID bins
- USER bins
- reset-related coverage
