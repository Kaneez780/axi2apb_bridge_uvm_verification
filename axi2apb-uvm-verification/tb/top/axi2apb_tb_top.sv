//`timescale 1ns/1ps

module axi2apb_tb_top;

  import uvm_pkg::*;
  import axi2apb_pkg::*;

  localparam int AXI_ADDR_WIDTH  = 32;
  localparam int AXI_DATA_WIDTH  = 32;
  localparam int AXI_ID_WIDTH    = 16;
  localparam int AXI_USER_WIDTH  = 10;
  localparam int APB_ADDR_WIDTH  = 32;

  logic clk;
  logic reset_n;

  initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
  end

  initial begin
    reset_n = 1'b0;
    repeat (5) @(posedge clk);
    reset_n = 1'b1;
  end

  axi4_if #(
    .ADDR_WIDTH (AXI_ADDR_WIDTH),
    .DATA_WIDTH (AXI_DATA_WIDTH),
    .ID_WIDTH   (AXI_ID_WIDTH),
    .USER_WIDTH (AXI_USER_WIDTH)
  ) axi_vif (
    .ACLK    (clk),
    .ARESETn (reset_n)
  );

  apb_if #(
    .ADDR_WIDTH (APB_ADDR_WIDTH),
    .DATA_WIDTH (AXI_DATA_WIDTH)
  ) apb_vif (
    .PCLK    (clk),
    .PRESETn (reset_n)
  );

  // Exact port mapping from the supplied rtl/axi2apb.sv.
  axi2apb #(
    .AXI4_ADDRESS_WIDTH (AXI_ADDR_WIDTH),
    .AXI4_RDATA_WIDTH   (AXI_DATA_WIDTH),
    .AXI4_WDATA_WIDTH   (AXI_DATA_WIDTH),
    .AXI4_ID_WIDTH      (AXI_ID_WIDTH),
    .AXI4_USER_WIDTH    (AXI_USER_WIDTH),
    .BUFF_DEPTH_SLAVE   (4),
    .APB_ADDR_WIDTH     (APB_ADDR_WIDTH)
  ) dut (
    .ACLK       (clk),
    .ARESETn    (reset_n),
    .test_en_i  (1'b0),

    .AWID_i     (axi_vif.awid),
    .AWADDR_i   (axi_vif.awaddr),
    .AWLEN_i    (axi_vif.awlen),
    .AWSIZE_i   (axi_vif.awsize),
    .AWBURST_i  (axi_vif.awburst),
    .AWLOCK_i   (axi_vif.awlock),
    .AWCACHE_i  (axi_vif.awcache),
    .AWPROT_i   (axi_vif.awprot),
    .AWREGION_i (axi_vif.awregion),
    .AWUSER_i   (axi_vif.awuser),
    .AWQOS_i    (axi_vif.awqos),
    .AWVALID_i  (axi_vif.awvalid),
    .AWREADY_o  (axi_vif.awready),

    .WDATA_i    (axi_vif.wdata),
    .WSTRB_i    (axi_vif.wstrb),
    .WLAST_i    (axi_vif.wlast),
    .WUSER_i    (axi_vif.wuser),
    .WVALID_i   (axi_vif.wvalid),
    .WREADY_o   (axi_vif.wready),

    .BID_o      (axi_vif.bid),
    .BRESP_o    (axi_vif.bresp),
    .BVALID_o   (axi_vif.bvalid),
    .BUSER_o    (axi_vif.buser),
    .BREADY_i   (axi_vif.bready),

    .ARID_i     (axi_vif.arid),
    .ARADDR_i   (axi_vif.araddr),
    .ARLEN_i    (axi_vif.arlen),
    .ARSIZE_i   (axi_vif.arsize),
    .ARBURST_i  (axi_vif.arburst),
    .ARLOCK_i   (axi_vif.arlock),
    .ARCACHE_i  (axi_vif.arcache),
    .ARPROT_i   (axi_vif.arprot),
    .ARREGION_i (axi_vif.arregion),
    .ARUSER_i   (axi_vif.aruser),
    .ARQOS_i    (axi_vif.arqos),
    .ARVALID_i  (axi_vif.arvalid),
    .ARREADY_o  (axi_vif.arready),

    .RID_o      (axi_vif.rid),
    .RDATA_o    (axi_vif.rdata),
    .RRESP_o    (axi_vif.rresp),
    .RLAST_o    (axi_vif.rlast),
    .RUSER_o    (axi_vif.ruser),
    .RVALID_o   (axi_vif.rvalid),
    .RREADY_i   (axi_vif.rready),

    .PENABLE    (apb_vif.penable),
    .PWRITE     (apb_vif.pwrite),
    .PADDR      (apb_vif.paddr),
    .PSEL       (apb_vif.psel),
    .PWDATA     (apb_vif.pwdata),
    .PRDATA     (apb_vif.prdata),
    .PREADY     (apb_vif.pready),
    .PSLVERR    (apb_vif.pslverr)
  );

  initial begin
    uvm_config_db#(virtual axi4_if)::set(null, "uvm_test_top.env.axi_agent*", "vif", axi_vif);
    uvm_config_db#(virtual apb_if)::set(null,  "uvm_test_top.env.apb_agent*", "vif", apb_vif);

    run_test();
  end

  initial begin
    $vcdplusfile("waveform.vpd");
    $vcdpluson(0, axi2apb_tb_top);
  end

endmodule
