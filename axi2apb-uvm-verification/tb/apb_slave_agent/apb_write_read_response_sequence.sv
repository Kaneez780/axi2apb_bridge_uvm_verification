class apb_write_read_response_sequence
  extends uvm_sequence #(apb_slave_item);

  `uvm_object_utils(apb_write_read_response_sequence)

  int unsigned write_wait_cycles = 0;
  int unsigned read_wait_cycles  = 0;


  function new(
    string name = "apb_write_read_response_sequence"
  );

    super.new(name);

  endfunction


  task body();

    `uvm_info(
      "APB_SEQ",
      "Preparing APB responses for one write and one read",
      UVM_LOW
    )


    // WRITE RESPONSE
    `uvm_do_with(req, {
      wait_cycles == write_wait_cycles;
      inject_error == 1'b0;
      default_read_data == 32'h0000_0000;
    })


    // READ RESPONSE
    `uvm_do_with(req, {
      wait_cycles == read_wait_cycles;
      inject_error == 1'b0;
      default_read_data == 32'h0000_0000;
    })


    `uvm_info(
      "APB_SEQ",
      "APB response sequence completed",
      UVM_LOW
    )

  endtask


endclass
