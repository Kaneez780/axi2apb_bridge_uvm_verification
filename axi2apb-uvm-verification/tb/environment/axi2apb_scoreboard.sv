// ============================================================================
//
// IMPORTANT DUT BEHAVIOR:
// The supplied RTL keeps AXI BRESP/RRESP = OKAY (2'b00)
// even when APB PSLVERR = 1.
//
// We DO NOT modify the DUT.
// The scoreboard checks the actual behavior of the supplied RTL.
// ============================================================================

`uvm_analysis_imp_decl(_axi)
`uvm_analysis_imp_decl(_apb)


class axi2apb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(axi2apb_scoreboard)


  // ==========================================================================
  // ANALYSIS EXPORTS
  // ==========================================================================

  uvm_analysis_imp_axi #(
    axi_master_item,
    axi2apb_scoreboard
  ) axi_export;


  uvm_analysis_imp_apb #(
    apb_slave_item,
    axi2apb_scoreboard
  ) apb_export;


  // ==========================================================================
  // TRANSACTION QUEUES
  // ==========================================================================

  axi_master_item axi_queue[$];
  apb_slave_item  apb_queue[$];


  // ==========================================================================
  // COUNTERS
  // ==========================================================================

  int unsigned matches;
  int unsigned errors;

  int unsigned axi_read_count;
  int unsigned axi_write_count;

  int unsigned apb_read_count;
  int unsigned apb_write_count;

  int unsigned pslverr_count;


  // ==========================================================================
  // CONSTRUCTOR
  // ==========================================================================

  function new(
    string name = "axi2apb_scoreboard",
    uvm_component parent = null
  );

    super.new(name, parent);

    axi_export = new(
      "axi_export",
      this
    );

    apb_export = new(
      "apb_export",
      this
    );

  endfunction


  // ==========================================================================
  // BUILD PHASE
  // ==========================================================================

  virtual function void build_phase(
    uvm_phase phase
  );

    super.build_phase(phase);

    matches         = 0;
    errors          = 0;

    axi_read_count  = 0;
    axi_write_count = 0;

    apb_read_count  = 0;
    apb_write_count = 0;

    pslverr_count   = 0;


    `uvm_info(
      "SCB",
      "axi2apb_scoreboard build_phase executed",
      UVM_LOW
    )

  endfunction


  // ==========================================================================
  // AXI MONITOR CALLBACK
  // ==========================================================================

  function void write_axi(
    axi_master_item tr
  );

    axi_master_item copy;


    $cast(
      copy,
      tr.clone()
    );


    if (copy.write)
      axi_write_count++;
    else
      axi_read_count++;


    axi_queue.push_back(copy);


    compare_available_transactions();

  endfunction


  // ==========================================================================
  // APB MONITOR CALLBACK
  // ==========================================================================

  function void write_apb(
    apb_slave_item tr
  );

    apb_slave_item copy;


    $cast(
      copy,
      tr.clone()
    );


    if (copy.write)
      apb_write_count++;
    else
      apb_read_count++;


    if (copy.pslverr === 1'b1) begin

      pslverr_count++;

      `uvm_info(
        "SCB",
        $sformatf(
          "Observed APB PSLVERR at address 0x%08h during %s transfer",
          copy.addr,
          copy.write ? "WRITE" : "READ"
        ),
        UVM_LOW
      )

    end


    apb_queue.push_back(copy);


    compare_available_transactions();

  endfunction


  // ==========================================================================
  // COMPARE AXI AND APB TRANSACTIONS
  // ==========================================================================

  function void compare_available_transactions();

    axi_master_item axi_tr;
    apb_slave_item  apb_tr;

    int unsigned transaction_errors;


    while (
      (axi_queue.size() > 0) &&
      (apb_queue.size() > 0)
    )
    begin

      axi_tr = axi_queue.pop_front();

      apb_tr = apb_queue.pop_front();


      transaction_errors = 0;


      // ======================================================================
      // ADDRESS CHECK
      // ======================================================================

      if (
        axi_tr.addr !==
        apb_tr.addr
      )
      begin

        errors++;
        transaction_errors++;

        `uvm_error(
          "SCB",
          $sformatf(
            "Address mismatch AXI=0x%08h APB=0x%08h",
            axi_tr.addr,
            apb_tr.addr
          )
        )

      end


      // ======================================================================
      // DIRECTION CHECK
      // ======================================================================

      if (
        axi_tr.write !==
        apb_tr.write
      )
      begin

        errors++;
        transaction_errors++;

        `uvm_error(
          "SCB",
          $sformatf(
            "Direction mismatch AXI write=%0b APB write=%0b",
            axi_tr.write,
            apb_tr.write
          )
        )

      end


      // ======================================================================
      // WRITE DATA CHECK
      // ======================================================================

      if (axi_tr.write)
      begin

        if (
          axi_tr.data !==
          apb_tr.write_data
        )
        begin

          errors++;
          transaction_errors++;

          `uvm_error(
            "SCB",
            $sformatf(
              "Write data mismatch AXI=0x%08h APB=0x%08h",
              axi_tr.data,
              apb_tr.write_data
            )
          )

        end

      end


      // ======================================================================
      // READ DATA CHECK
      // ======================================================================

      else
      begin

        if (
          axi_tr.read_data !==
          apb_tr.read_data
        )
        begin

          errors++;
          transaction_errors++;

          `uvm_error(
            "SCB",
            $sformatf(
              "Read data mismatch AXI=0x%08h APB=0x%08h",
              axi_tr.read_data,
              apb_tr.read_data
            )
          )

        end


        // Single-beat read must return RLAST = 1.

        if (
          axi_tr.response_last !==
          1'b1
        )
        begin

          errors++;
          transaction_errors++;

          `uvm_error(
            "SCB",
            "Single-beat AXI read did not return RLAST=1"
          )

        end

      end


      // ======================================================================
      // AXI RESPONSE CHECK
      //
      // IMPORTANT:
      //
      // Actual supplied RTL behavior:
      //
      // PSLVERR = 0 -> AXI RESP = OKAY
      // PSLVERR = 1 -> AXI RESP = OKAY
      //
      // Therefore the expected AXI response is always 2'b00.
      // ======================================================================

      if (
        axi_tr.resp !==
        2'b00
      )
      begin

        errors++;
        transaction_errors++;

        `uvm_error(
          "SCB",
          $sformatf(
            "%s response mismatch: expected supplied RTL AXI RESP=00, actual=%02b",
            axi_tr.write ? "WRITE" : "READ",
            axi_tr.resp
          )
        )

      end

      else begin

        if (apb_tr.pslverr === 1'b1) begin

          `uvm_info(
            "SCB_RESP",
            $sformatf(
              "%s PSLVERR observed; supplied RTL keeps AXI RESP=OKAY as expected",
              axi_tr.write ? "WRITE" : "READ"
            ),
            UVM_LOW
          )

        end

      end


      // ======================================================================
      // AXI RESPONSE ID CHECK
      // ======================================================================

      if (
        axi_tr.response_id !==
        axi_tr.id
      )
      begin

        errors++;
        transaction_errors++;

        `uvm_error(
          "SCB",
          $sformatf(
            "AXI ID mismatch request=0x%04h response=0x%04h",
            axi_tr.id,
            axi_tr.response_id
          )
        )

      end


      // ======================================================================
      // TRANSACTION RESULT
      // ======================================================================

      if (
        transaction_errors == 0
      )
      begin

        matches++;

        `uvm_info(
          "SCB",
          $sformatf(
            "Matched %s conversion at address 0x%08h",
            axi_tr.write ? "WRITE" : "READ",
            axi_tr.addr
          ),
          UVM_LOW
        )

      end

      else
      begin

        `uvm_error(
          "SCB",
          $sformatf(
            "%s conversion FAILED at address 0x%08h with %0d error(s)",
            axi_tr.write ? "WRITE" : "READ",
            axi_tr.addr,
            transaction_errors
          )
        )

      end

    end

  endfunction


  // ==========================================================================
  // CHECK PHASE
  // ==========================================================================

  virtual function void check_phase(
    uvm_phase phase
  );

    super.check_phase(phase);


    `uvm_info(
      "SCB",
      "axi2apb_scoreboard check_phase executed",
      UVM_LOW
    )


    if (
      (axi_queue.size() != 0) ||
      (apb_queue.size() != 0)
    )
    begin

      errors++;

      `uvm_error(
        "SCB",
        $sformatf(
          "Unmatched transactions remain AXI=%0d APB=%0d",
          axi_queue.size(),
          apb_queue.size()
        )
      )

    end

  endfunction


  // ==========================================================================
  // REPORT PHASE
  // ==========================================================================

  virtual function void report_phase(
    uvm_phase phase
  );

    super.report_phase(phase);


    `uvm_info(
      "SCB",
      "axi2apb_scoreboard report_phase executed",
      UVM_LOW
    )


    `uvm_info(
      "SCB",
      $sformatf(
        "Summary: AXI_WR=%0d AXI_RD=%0d APB_WR=%0d APB_RD=%0d PSLVERR=%0d",
        axi_write_count,
        axi_read_count,
        apb_write_count,
        apb_read_count,
        pslverr_count
      ),
      UVM_LOW
    )


    if (errors == 0)
    begin

      `uvm_info(
        "SCB",
        $sformatf(
          "TEST PASS: matched transactions=%0d",
          matches
        ),
        UVM_NONE
      )

    end

    else
    begin

      `uvm_error(
        "SCB",
        $sformatf(
          "TEST FAIL: scoreboard errors=%0d matched transactions=%0d",
          errors,
          matches
        )
      )

    end

  endfunction


endclass

