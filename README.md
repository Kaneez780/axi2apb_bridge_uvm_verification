
# 🚀 AXI4-to-APB Bridge UVM Verification Environment

A complete **UVM-based verification environment** for an **AXI4-to-APB bridge**, developed using **SystemVerilog and UVM 1.2** and simulated with **Synopsys VCS**.

This project verifies the functional behavior of an AXI4-to-APB bridge using a reusable **dual-agent UVM architecture** consisting of an AXI Master Agent and an APB Slave Agent.

---

## 📌 Project Overview

The purpose of this project is to verify that AXI transactions are correctly converted into APB transfers and that the corresponding APB responses are correctly returned to the AXI side.

The supplied DUT is treated as **read-only** and is not modified during verification.

The environment verifies:

- AXI write transactions
- AXI read transactions
- AXI-to-APB address conversion
- AXI-to-APB write-data conversion
- APB read-data return
- APB wait-state handling
- AXI response backpressure
- AXI ID handling
- AXI USER handling
- Randomized AXI/APB transactions
- APB PSLVERR stimulus
- End-to-end transaction checking using a scoreboard

---

## 🏗️ UVM Architecture

```text
                        +----------------------+
                        |       UVM Test       |
                        +----------+-----------+
                                   |
                                   v
                        +----------------------+
                        |   Virtual Sequence   |
                        +----------+-----------+
                                   |
                                   v
                        +----------------------+
                        |  Virtual Sequencer   |
                        +----------+-----------+
                                   |
                    +--------------+--------------+
                    |                             |
                    v                             v
          +-------------------+         +-------------------+
          | AXI Master Agent  |         | APB Slave Agent   |
          +-------------------+         +-------------------+
          | Sequence Item     |         | Sequence Item     |
          | Sequencer         |         | Sequencer         |
          | Driver            |         | Driver            |
          | Monitor           |         | Monitor           |
          +---------+---------+         +---------+---------+
                    |                             |
                    v                             v
                AXI Interface                 APB Interface
                    |                             |
                    +-------------+---------------+
                                  |
                                  v
                         +----------------+
                         |      DUT       |
                         | AXI4-to-APB    |
                         +----------------+
                                  |
                    +-------------+-------------+
                    |                           |
                    v                           v
               AXI Monitor                 APB Monitor
                    |                           |
                    +-------------+-------------+
                                  |
                                  v
                         +----------------+
                         |   Scoreboard   |
                         +----------------+
```

---

## 🔹 AXI Master Agent

The AXI Master Agent is responsible for generating AXI transactions and monitoring AXI responses.

It contains:

- `axi_master_item`
- `axi_master_sequencer`
- `axi_master_driver`
- `axi_master_monitor`
- `axi_master_agent`

The AXI driver handles:

- AW channel
- W channel
- B response channel
- AR channel
- R response channel

It also supports programmable delays on:

- `BREADY`
- `RREADY`

This allows AXI backpressure behavior to be tested.

---

## 🔹 APB Slave Agent

The APB Slave Agent behaves as a programmable APB peripheral connected to the DUT.

It contains:

- `apb_slave_item`
- `apb_slave_sequencer`
- `apb_slave_driver`
- `apb_slave_monitor`
- `apb_slave_agent`

The APB driver supports:

- Immediate responses
- Programmable wait states
- Read-data responses
- Write completion
- PSLVERR injection

---

## 🔹 Virtual Sequencer

The virtual sequencer coordinates both AXI and APB sequencers.

```text
axi2apb_virtual_sequencer
          |
          +---- AXI Master Sequencer
          |
          +---- APB Slave Sequencer
```

This allows AXI stimulus and APB response behavior to be controlled from the same virtual sequence.

---

## 🔹 Scoreboard

The scoreboard performs automatic end-to-end checking between the AXI and APB sides.

```text
AXI Monitor --------+
                    |
                    v
               Scoreboard
                    ^
                    |
APB Monitor --------+
```

For write transactions, the scoreboard checks:

- Address
- Transaction direction
- Write data
- AXI response ID

For read transactions, the scoreboard checks:

- Address
- Transaction direction
- Read data
- AXI response ID
- RLAST

The scoreboard also reports the final test result as:

```text
TEST PASS
```

or:

```text
TEST FAIL
```

---

## 🧪 Verification Tests

The current verification environment contains the following tests:

| Test | Description |
|---|---|
| `axi2apb_write_read_test` | Verifies basic AXI write and read conversion |
| `axi2apb_wait_state_test` | Verifies APB wait-state handling |
| `axi2apb_backpressure_test` | Verifies AXI BREADY and RREADY backpressure |
| `axi2apb_random_test` | Generates constrained-random write/read transactions |
| `axi2apb_error_response_test` | Verifies behavior when APB PSLVERR is asserted |

---

## ✅ Basic Write/Read Test

The basic write/read test verifies the normal AXI-to-APB transaction path.

Example:

```text
AXI Write
    |
    v
APB Write
    |
    v
AXI Write Response
    |
    v
AXI Read
    |
    v
APB Read
    |
    v
AXI Read Response
```

A typical directed transaction uses:

```text
Address = 0x00000100
Data    = 0xDEADBEEF
```

---

## ⏳ APB Wait-State Test

This test verifies bridge behavior when the APB slave delays `PREADY`.

Example:

```text
PREADY = 0
PREADY = 0
PREADY = 0
PREADY = 1
```

The DUT must wait for APB completion before completing the corresponding AXI transaction.

---

## 🔄 AXI Backpressure Test

The backpressure test verifies that the DUT correctly holds AXI responses when the master delays response acceptance.

Write response example:

```text
BVALID = 1
BREADY = 0
BREADY = 0
BREADY = 0
BREADY = 1
```

Read response example:

```text
RVALID = 1
RREADY = 0
RREADY = 0
RREADY = 0
RREADY = 1
```

---

## 🎲 Constrained-Random Test

The constrained-random test generates multiple randomized AXI write/read transactions.

Randomized fields include:

- Address
- Data
- Write ID
- Read ID
- AXI USER
- APB wait cycles
- BREADY delay
- RREADY delay

Each randomized write is followed by a read from the same address so that the returned data can be checked automatically.

---

## ⚠️ APB Error Response Test

The APB error response test intentionally asserts:

```text
PSLVERR = 1
```

for both APB read and write transactions.

The supplied RTL was observed to keep:

```text
BRESP  = OKAY
RRESP  = OKAY
```

even when APB `PSLVERR` is asserted.

The verification environment checks and documents this actual DUT behavior without modifying the RTL.

---


## 🛠️ Tools Used

| Tool | Purpose |
|---|---|
| SystemVerilog | RTL and verification language |
| UVM 1.2 | Verification methodology |
| Synopsys VCS | Compilation and simulation |
| Synopsys DVE | Waveform debugging |
| Git | Version control |
| GitHub | Repository hosting |

---

## ✅ Current Verification Status

- ✅ AXI write verification
- ✅ AXI read verification
- ✅ AXI-to-APB write conversion
- ✅ AXI-to-APB read conversion
- ✅ Address checking
- ✅ Write-data checking
- ✅ Read-data checking
- ✅ AXI ID checking
- ✅ AXI USER handling
- ✅ APB wait-state verification
- ✅ AXI B-channel backpressure
- ✅ AXI R-channel backpressure
- ✅ Constrained-random transactions
- ✅ APB PSLVERR stimulus
- ✅ Automatic scoreboard checking
- ✅ Automatic test pass/fail reporting

---


AXI4-to-APB Bridge UVM Verification Project
```
