`include "cmsdk_mcu_defs.v"

module cmsdk_mcu #(
  //-----------------------------------------
  // CPU options

  parameter BE              = 0,   // Big or little endian
  parameter BKPT            = 4,   // Number of breakpoint comparators
  parameter DBG             = 1,   // Debug configuration
  parameter NUMIRQ          = 32,  // NUM of IRQ
  parameter SMUL            = 0,   // Multiplier configuration
  parameter SYST            = 1,   // SysTick
  parameter WIC             = 0,   // Wake-up interrupt controller support
  parameter WICLINES        = 34,  // Supported WIC lines
  parameter WPT             = 2    // Number of DWT comparators

 )
 (
  input  wire          XTAL1, // input
  output wire          XTAL2, // output
  input  wire          NRST,  // active low reset
  inout  wire  [15:0]  P0,
  inout  wire  [15:0]  P1,

  input  wire          nTRST,
  input  wire          TDI,
  output wire          TDO,
  inout  wire          SWDIOTMS,
  input  wire          SWCLKTCK
  // UART
//  input  wire               uart0_rxd,
//  output wire               uart0_txd,
//  output wire 		      uart0_txen,
//  input  wire               uart1_rxd,
//  output wire               uart1_txd,
//  output wire               uart1_txen,
//  input  wire               uart2_rxd,
//  output wire               uart2_txd,
//  output wire               uart2_txen
//  output wire          UART_TX
  );


//------------------------------------
// internal wires
  wire               SLEEPING;
  wire               APBACTIVE;
  wire               SYSRESETREQ;    // processor system reset request
  wire               WDOGRESETREQ;   // watchdog system reset request
  wire               HRESETREQ;      // Combined system reset request
  wire               cmsdk_SYSRESETREQ; // Combined system reset request
  wire               clk_ctrl_sys_reset_req;
  wire               PMUHRESETREQ;
  wire               PMUDBGRESETREQ;
  wire               LOCKUP;
  wire               LOCKUPRESET;
  wire               PMUENABLE;
  wire               SLEEPDEEP;

  wire               PORESETn;// Power on reset
  wire               HRESETn; // AHB reset
  wire               PRESETn; // APB and peripheral reset
  wire               DBGRESETn; // Debug system reset
  wire               FCLK;    // Free running system clock
  wire               HCLK;    // System clock from PMU
  wire               DCLK;
  wire               SCLK;
  wire               PCLK;    // Peripheral clock
  wire               PCLKG;   // Gated PCLK for APB
  wire               HCLKSYS; // System clock for memory
  wire               PCLKEN;  // Clock divider for AHB to APB bridge
  // Common AHB signals
  wire  [31:0]       HADDR;
  wire  [1:0]        HTRANS;
  wire  [2:0]        HSIZE;
  wire               HWRITE;
  wire  [31:0]       HWDATA;
  wire               HREADY;

  // Flash memory AHB signals
  wire               flash_hsel;
  wire               flash_hreadyout;
  wire  [31:0]       flash_hrdata;
  wire               flash_hresp;

  // SRAM AHB signals
  wire               sram_hsel;
  wire               sram_hreadyout;
  wire  [31:0]       sram_hrdata;
  wire               sram_hresp;

  // internal peripheral signals
  wire               uart0_rxd;
  wire               uart0_txd;
  wire               uart0_txen;
  wire               uart1_rxd;
  wire               uart1_txd;
  wire               uart1_txen;
  wire               uart2_rxd;
  wire               uart2_txd;
  wire               uart2_txen;

  wire               timer0_extin;
  wire               timer1_extin;

  wire  [15:0]       p0_in;
  wire  [15:0]       p0_out;
  wire  [15:0]       p0_outen;
  wire  [15:0]       p0_altfunc;

  wire  [15:0]       p1_in;
  wire  [15:0]       p1_out;
  wire  [15:0]       p1_outen;
  wire  [15:0]       p1_altfunc;

  localparam BASEADDR_GPIO0       = 32'h4001_0000;
  localparam BASEADDR_GPIO1       = 32'h4001_1000;
  localparam BASEADDR_SYSROMTABLE = 32'hF000_0000;

  // Internal Debug signals
  wire               i_trst_n;
  wire               i_swditms;
  wire               i_swclktck;
  wire               i_tdi;
  wire               i_tdo;
  wire               i_tdoen_n;
  wire               i_swdo;
  wire               i_swdoen;
  //wire               i_NRST;  // active low reset
  
  wire               TESTMODE;

  assign TESTMODE = 1'b0;
  
//----------------------------------------
// Clock and reset controller
//----------------------------------------
  // Clock controller generates reset if PMU request (PMUHRESETREQ),
  // CPU request or watchdog request (SYSRESETREQ)
  assign clk_ctrl_sys_reset_req = PMUHRESETREQ | cmsdk_SYSRESETREQ;

  // Clock controller to generate reset and clock signals
  cmsdk_mcu_clkctrl
   #(.CLKGATE_PRESENT(0))
   u_cmsdk_mcu_clkctrl(
     // inputs
    .XTAL1            (XTAL1),
    .NRST             (NRST),

    .APBACTIVE        (APBACTIVE),
    .SLEEPING         (SLEEPING),
    .SLEEPDEEP        (SLEEPDEEP),
    .LOCKUP           (LOCKUP),
    .LOCKUPRESET      (LOCKUPRESET),
    .SYSRESETREQ      (clk_ctrl_sys_reset_req),
    .DBGRESETREQ      (PMUDBGRESETREQ),
    .CGBYPASS         (TESTMODE),
    .RSTBYPASS        (TESTMODE),

     // outputs
    .XTAL2            (XTAL2),

    .FCLK             (FCLK),

    .PCLK             (PCLK),
    .PCLKG            (PCLKG),
    .PCLKEN           (PCLKEN),
    .PORESETn         (PORESETn),
    .DBGRESETn        (DBGRESETn),
    .HRESETn          (HRESETn),
    .PRESETn          (PRESETn)
    );

//----------------------------------------
//
  // System Reset request can be from processor or watchdog
  // or when lockup happens and the control flag is set.
  assign  cmsdk_SYSRESETREQ = SYSRESETREQ | WDOGRESETREQ |
                              (LOCKUP & LOCKUPRESET);

  // Power Management Unit will not be available
  assign  HCLK = FCLK;        // connect HCLK to FCLK
  assign  DCLK = FCLK;        // connect DCLK to FCLK
  assign  SCLK = FCLK;        // connect SCLK to FCLK

  // Since there is no PMU, these signals are not used
  assign  PMUDBGRESETREQ = 1'b0;
  assign  PMUHRESETREQ   = 1'b0;
  
//----------------------------------------
// Flash memory
//----------------------------------------
assign   HCLKSYS  = HCLK;
ahb_rom
   u_ahb_rom (
    .HCLK             (HCLKSYS),
    //.HRESETn          (HRESETn),
    .HSEL             (flash_hsel),  // AHB inputs
    .HADDR            (HADDR [31:0]), // input wire  [31:0] HADDR
    .HTRANS           (HTRANS),
    .HSIZE            (HSIZE),
    .HWRITE           (HWRITE),
    .HWDATA           (HWDATA),
    .HREADY           (1'b1),

    .HREADYOUT        (flash_hreadyout), // Outputs
    .HRDATA           (flash_hrdata),
    .HRESP            (flash_hresp)
  );     

//----------------------------------------
// SRAM
//----------------------------------------
/* Instantiate 1024 byte AHB RAM */
assign sram_hsel  = 1'b1;
//assign sram_hresp = 1'b0;

wire 	[3:0]	 axi_awid;
wire	[7:0]    axi_awlen;     // 8-bit
wire	[2:0]    axi_awsize;    // 3-bit
wire	[1:0]    axi_awburst;   // 2-bit
wire	[3:0]    axi_awcache;   // 4-bit
wire	[31:0]	 axi_awaddr;    // 32-bit
wire 	[2:0]    axi_awprot;    // 3-bit
wire		     axi_awvalid;
wire		     axi_awready;
wire		     axi_awlock;
wire	[31:0]   axi_wdata; // 32-bit
wire	[3:0]    axi_wstrb;     // 4-bit
wire		     axi_wlast;
wire		     axi_wvalid;
wire		     axi_wready;
wire	[3:0]    axi_bid;       // 4-bit
wire	[1:0]    axi_bresp;     // 2-bit
wire		     axi_bvalid;
wire		     axi_bready;  //
wire	[3:0]    axi_arid;      // 4-bit
wire	[7:0]    axi_arlen; // 8-bit
wire	[2:0]    axi_arsize;    // 3-bit
wire	[1:0]    axi_arburst;   // 2-bit
wire	[2:0]    axi_arprot;    // 3-bit
wire	[3:0]    axi_arcache;   // 4-bit
wire		     axi_arvalid;  
wire	[31:0]   axi_araddr;    // 32-bit
wire		     axi_arlock;
wire		     axi_arready;
wire	[3:0]    axi_rid;       // 4-bit
wire	[31:0]   axi_rdata;     // 32-bit
wire	[1:0]    axi_rresp;     // 2-bit
wire		     axi_rvalid;
wire		     axi_rlast;
wire		     axi_rready;

	
ahblite_axi_bridge_0 u_ahblite_axi_bridge_0 (
    // ahb interface
    .s_ahb_hclk     (HCLKSYS),    // input
    .s_ahb_hresetn  (HRESETn), // input
	
    .s_ahb_hsel     (sram_hsel),    
    .s_ahb_haddr    (HADDR [31:0]), // IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_ahb_hprot    (), // 4-bit
    .s_ahb_htrans   (HTRANS), // 2-bit
    .s_ahb_hsize    (HSIZE), // 3-bit
    .s_ahb_hwrite   (HWRITE),
    .s_ahb_hburst   (), // 3-bit
    .s_ahb_hwdata   (HWDATA), // 32-bit
    .s_ahb_hready_out (sram_hreadyout), //OUT STD_LOGIC;
    .s_ahb_hready_in  (HREADY),
    .s_ahb_hrdata   (sram_hrdata), // 32-bit     OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_ahb_hresp    (sram_hresp),   // OUT STD_LOGIC;
    // axi interface 
    .m_axi_awid     (axi_awid), // 4-bit
    .m_axi_awlen    (axi_awlen), // 8-bit
    .m_axi_awsize   (axi_awsize), // 3-bit
    .m_axi_awburst  (axi_awburst), // 2-bit
    .m_axi_awcache  (), // 4-bit
    .m_axi_awaddr   (axi_awaddr), // 32-bit
    .m_axi_awprot   (), // 3-bit
    .m_axi_awvalid  (axi_awvalid),
    .m_axi_awready  (axi_awready),
    .m_axi_awlock   (),
    .m_axi_wdata    (axi_wdata), // 32-bit
    .m_axi_wstrb    (axi_wstrb), // 4-bit
    .m_axi_wlast    (axi_wlast),
    .m_axi_wvalid   (axi_wvalid),
    .m_axi_wready   (axi_wready),
    .m_axi_bid      (axi_bid), // 4-bit
    .m_axi_bresp    (axi_bresp), // 2-bit
    .m_axi_bvalid   (axi_bvalid),
    .m_axi_bready   (axi_bready ), //
    .m_axi_arid     (axi_arid), // 4-bit
    .m_axi_arlen    (axi_arlen), // 8-bit
    .m_axi_arsize   (axi_arsize), // 3-bit
    .m_axi_arburst  (axi_arburst), // 2-bit
    .m_axi_arprot   (), // 3-bit
    .m_axi_arcache  (), // 4-bit
    .m_axi_arvalid  (axi_arvalid), 
    .m_axi_araddr   (axi_araddr), // 32-bit
    .m_axi_arlock   (),
    .m_axi_arready  (axi_arready),
    .m_axi_rid      (axi_rid), // 4-bit
    .m_axi_rdata    (axi_rdata), // 32-bit
    .m_axi_rresp    (axi_rresp), // 2-bit
    .m_axi_rvalid   (axi_rvalid),
    .m_axi_rlast    (axi_rlast),
    .m_axi_rready   (axi_rready)
);    

blk_mem_gen_0 u_blk_mem_gen_0 (
    .s_aclk     	(HCLKSYS), // : IN STD_LOGIC;
    .s_aresetn  	(HRESETn), //: IN STD_LOGIC;
	
    .s_axi_awid 	(axi_awid), // : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    .s_axi_awaddr   (axi_awaddr), // : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_axi_awlen    (axi_awlen), // : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    .s_axi_awsize   (axi_awsize), // : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    .s_axi_awburst  (axi_awburst), //: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    .s_axi_awvalid  (axi_awvalid), //: IN STD_LOGIC;
    .s_axi_awready  (axi_awready), //: OUT STD_LOGIC;
    .s_axi_wdata    (axi_wdata), //: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_axi_wstrb    (axi_wstrb), // : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    .s_axi_wlast    (axi_wlast), //: IN STD_LOGIC;
    .s_axi_wvalid   (axi_wvalid), // : IN STD_LOGIC;
    .s_axi_wready   (axi_wready), //: OUT STD_LOGIC;
    .s_axi_bid      (axi_bid), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    .s_axi_bresp    (axi_bresp), //: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    .s_axi_bvalid   (axi_bvalid), //: OUT STD_LOGIC;
    .s_axi_bready   (axi_bready), //: IN STD_LOGIC;
    .s_axi_arid     (axi_arid), //: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    .s_axi_araddr   (axi_araddr), // : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_axi_arlen    (axi_arlen), //: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    .s_axi_arsize   (axi_arsize), //: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    .s_axi_arburst  (axi_arburst), //: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    .s_axi_arvalid  (axi_arvalid), //: IN STD_LOGIC;
    .s_axi_arready  (axi_arready), //: OUT STD_LOGIC;
    .s_axi_rid      (axi_rid), //: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    .s_axi_rdata    (axi_rdata), //: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    .s_axi_rresp    (axi_rresp), //: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    .s_axi_rlast    (axi_rlast), //: OUT STD_LOGIC;
    .s_axi_rvalid   (axi_rvalid), //: OUT STD_LOGIC;
    .s_axi_rready   (axi_rready)  //: IN STD_LOGIC
); 
//---------------------------------------------------
// System design for example Cortex-M0 MCU
//---------------------------------------------------
  cmsdk_mcu_system
   #(.BE               (BE),
     .BASEADDR_GPIO0   (BASEADDR_GPIO0), // GPIO0 Base Address
     .BASEADDR_GPIO1   (BASEADDR_GPIO1), // GPIO1 Base Address
     .BKPT             (BKPT),           // Number of breakpoint comparators
     .DBG              (DBG),            // Debug configuration
     .NUMIRQ           (NUMIRQ),         // NUMIRQ
     .SMUL             (SMUL),           // Multiplier configuration
     .SYST             (SYST),           // SysTick
     .WIC              (WIC),            // Wake-up interrupt controller support
     .WICLINES         (WICLINES),       // Supported WIC lines
     .WPT              (WPT),            // Number of DWT comparators
     .BASEADDR_SYSROMTABLE (BASEADDR_SYSROMTABLE) // System ROM Table base address
   )
    u_cmsdk_mcu_system (
    .FCLK             (FCLK),
    .HCLK             (HCLK),
    .DCLK             (DCLK),                        
    .SCLK             (SCLK),
    .HRESETn          (HRESETn),
    .PORESETn         (PORESETn),
    .DBGRESETn        (DBGRESETn),
    .PCLK             (PCLK),
    .PCLKG            (PCLKG),
    .PRESETn          (PRESETn),
    .PCLKEN           (PCLKEN),

    // Common AHB signals
    .HADDR            (HADDR),
    .HTRANS           (HTRANS),
    .HSIZE            (HSIZE),
    .HWRITE           (HWRITE),
    .HWDATA           (HWDATA),
    .HREADY           (HREADY),

    // Flash
    .flash_hsel       (flash_hsel),
    .flash_hreadyout  (flash_hreadyout),
    .flash_hrdata     (flash_hrdata),
    .flash_hresp      (flash_hresp),

    // SRAM
    .sram_hsel        (sram_hsel),
    .sram_hreadyout   (sram_hreadyout),
    .sram_hrdata      (sram_hrdata),
    .sram_hresp       (sram_hresp),

    // Optional boot loader
    // Only use if BOOT_MEM_TYPE is not zero
    .boot_hsel        (),
    .boot_hreadyout   (1'b0),
    .boot_hrdata      (32'h00000000),
    .boot_hresp       (1'b0),

    // Status
    .APBACTIVE        (APBACTIVE),
    .SLEEPING         (SLEEPING),
    .SYSRESETREQ      (SYSRESETREQ),
    .WDOGRESETREQ     (WDOGRESETREQ),
    .LOCKUP           (LOCKUP),
    .LOCKUPRESET      (LOCKUPRESET),
    .PMUENABLE        (PMUENABLE),
    .SLEEPDEEP        (SLEEPDEEP),
    // Debug
    .nTRST            (i_trst_n),
    .SWDITMS          (i_swditms),
    .SWCLKTCK         (i_swclktck),
    .TDI              (i_tdi),
    .TDO              (i_tdo),
    .nTDOEN           (i_tdoen_n),
    .SWDO             (i_swdo),
    .SWDOEN           (i_swdoen),
    // UART
    .uart0_rxd        (uart0_rxd),
    .uart0_txd        (uart0_txd),
    .uart0_txen       (uart0_txen),
    .uart1_rxd        (uart1_rxd),
    .uart1_txd        (uart1_txd),
    .uart1_txen       (uart1_txen),
    .uart2_rxd        (uart2_rxd),
    .uart2_txd        (uart2_txd),
    .uart2_txen       (uart2_txen),

    // Timer
    .timer0_extin     (timer0_extin),
    .timer1_extin     (timer1_extin),

    // IO Ports
    .p0_in            (p0_in),
    .p0_out           (p0_out),
    .p0_outen         (p0_outen),
    .p0_altfunc       (p0_altfunc),

    .p1_in            (p1_in),
    .p1_out           (p1_out),
    .p1_outen         (p1_outen),
    .p1_altfunc       (p1_altfunc),

    .DFTSE            (1'b0)
  );
//----------------------------------------
// I/O port pin muxing and tristate
//----------------------------------------
  cmsdk_mcu_pin_mux
  u_pin_mux (
  // UART
  .uart0_rxd        (uart0_rxd),
  .uart0_txd        (uart0_txd),
  .uart0_txen       (uart0_txen),
  .uart1_rxd        (uart1_rxd),
  .uart1_txd        (uart1_txd),
  .uart1_txen       (uart1_txen),
  .uart2_rxd        (uart2_rxd),
  .uart2_txd        (uart2_txd),
  .uart2_txen       (uart2_txen),

  // Timer
  .timer0_extin     (timer0_extin),
  .timer1_extin     (timer1_extin),

  // IO Ports
  .p0_in            (p0_in),
  .p0_out           (p0_out),
  .p0_outen         (p0_outen),
  .p0_altfunc       (p0_altfunc),

  .p1_in            (p1_in),
  .p1_out           (p1_out),
  .p1_outen         (p1_outen),
  .p1_altfunc       (p1_altfunc),

  // Debug
  .i_trst_n         (i_trst_n),
  .i_swditms        (i_swditms),
  .i_swclktck       (i_swclktck),
  .i_tdi            (i_tdi),
  .i_tdo            (i_tdo),
  .i_tdoen_n        (i_tdoen_n),
  .i_swdo           (i_swdo),
  .i_swdoen         (i_swdoen),

  // IO pads
  .P0               (P0),
  .P1               (P1),

  .nTRST            (nTRST),  // Not needed if serial-wire debug is used
  .TDI              (TDI),    // Not needed if serial-wire debug is used
  .SWDIOTMS         (SWDIOTMS),
  .SWCLKTCK         (SWCLKTCK),
  .TDO              (TDO)     // Not needed if serial-wire debug is used

);

endmodule
