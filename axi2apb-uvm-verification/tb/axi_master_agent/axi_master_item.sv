class axi_master_item extends uvm_sequence_item;

  // ============================================================
  // REQUEST FIELDS USED BY THE AXI2APB DUT
  // ============================================================

  rand bit          write;
  rand bit [31:0]   addr;
  rand bit [31:0]   data;
  rand bit [15:0]   id;
  rand bit [9:0]    user;

  rand bit [7:0]    len;
  rand bit [2:0]    size;
  rand bit [1:0]    burst;
  rand bit          lock;
  rand bit [3:0]    cache;
  rand bit [2:0]    prot;
  rand bit [3:0]    region;
  rand bit [3:0]    qos;
  rand bit [3:0]    strb;
  rand bit          last;


  // ============================================================
  // AXI BACKPRESSURE CONTROL
  //
  // These are not DUT signals.
  // They are testbench control fields used by the AXI driver.
  //
  // bready_delay:
  //   Number of cycles to delay BREADY.
  //
  // rready_delay:
  //   Number of cycles to delay RREADY.
  // ============================================================

  rand int unsigned bready_delay;

  rand int unsigned rready_delay;


  // ============================================================
  // RESPONSE FIELDS CAPTURED BY DRIVER / MONITOR
  // ============================================================

  bit [1:0]         resp;
  bit [31:0]        read_data;
  bit [15:0]        response_id;
  bit [9:0]         response_user;
  bit               response_last;


  // ============================================================
  // SINGLE-BEAT AXI CONSTRAINT
  //
  // First milestone:
  // protocol-correct 32-bit single-beat transfers only.
  // ============================================================

  constraint single_beat_c {

    len    == 8'd0;

    size   == 3'd2;      // 4 bytes = 32-bit beat

    burst  == 2'b01;     // INCR

    lock   == 1'b0;

    cache  == 4'b0000;

    prot   == 3'b000;

    region == 4'b0000;

    qos    == 4'b0000;

    strb   == 4'hF;

    last   == 1'b1;

  }


  // ============================================================
  // ADDRESS ALIGNMENT
  //
  // 32-bit transfer = 4 bytes.
  // Therefore address must be word aligned.
  // ============================================================

  constraint aligned_addr_c {

    addr[1:0] == 2'b00;

  }


  // ============================================================
  // BACKPRESSURE DELAY LIMIT
  //
  // Keeps randomization within a practical range.
  // ============================================================

  constraint backpressure_delay_c {

    bready_delay inside {[0:10]};

    rready_delay inside {[0:10]};

  }


  // ============================================================
  // FACTORY REGISTRATION + FIELD AUTOMATION
  // ============================================================

  `uvm_object_utils_begin(axi_master_item)

    `uvm_field_int(write,          UVM_DEFAULT)

    `uvm_field_int(addr,           UVM_HEX)

    `uvm_field_int(data,           UVM_HEX)

    `uvm_field_int(id,             UVM_HEX)

    `uvm_field_int(user,           UVM_HEX)

    `uvm_field_int(len,            UVM_DEC)

    `uvm_field_int(size,           UVM_DEC)

    `uvm_field_int(burst,          UVM_BIN)

    `uvm_field_int(lock,           UVM_DEFAULT)

    `uvm_field_int(cache,          UVM_HEX)

    `uvm_field_int(prot,           UVM_BIN)

    `uvm_field_int(region,         UVM_HEX)

    `uvm_field_int(qos,            UVM_HEX)

    `uvm_field_int(strb,           UVM_HEX)

    `uvm_field_int(last,           UVM_DEFAULT)


    // Backpressure configuration
    `uvm_field_int(bready_delay,   UVM_DEC)

    `uvm_field_int(rready_delay,   UVM_DEC)


    // Response information
    `uvm_field_int(resp,           UVM_BIN)

    `uvm_field_int(read_data,      UVM_HEX)

    `uvm_field_int(response_id,    UVM_HEX)

    `uvm_field_int(response_user,  UVM_HEX)

    `uvm_field_int(response_last,  UVM_DEFAULT)

  `uvm_object_utils_end


  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  function new(
    string name = "axi_master_item"
  );

    super.new(name);

  endfunction


endclass
