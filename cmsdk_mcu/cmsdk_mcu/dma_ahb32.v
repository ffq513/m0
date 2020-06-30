//---------------------------------------------------------
//-- Source file: dma.v -- top level
//---------------------------------------------------------

`include "dma_ahb32_defines.v"
  
module dma_ahb32 (hclk,hresetn,scan_en,idle,INT,
periph_tx_req,periph_tx_clr,periph_rx_req,periph_rx_clr,
pclken,psel,penable,paddr,pwrite,pwdata,prdata,pslverr,pready,
hwaddr,hwburst,hwsize,hwtrans,hwdata,hwready,hwresp,hraddr,hrburst,hrsize,hrtrans,hrdata,hrready,hrresp);
   // clock and reset 
   input                 hclk;
   input                 hresetn;
   
   //
   input                 scan_en;   // scan enable (set = 0)

   output                idle;		// 
   output [1-1:0]        INT;      	// interrupt == dma_err
   
   input  [31:1]         periph_tx_req;   // TX request
   output [31:1]         periph_tx_clr;   // TX clear
   
   input  [31:1]         periph_rx_req;   // RX request 
   output [31:1]         periph_rx_clr;	  // RX clear 
   
// APB Slave Interface
   input                 pclken;
   input                 psel;
   input                 penable;
   input [12:0]		 	 paddr;
   input                 pwrite;
   input [31:0]          pwdata;
   
   output [31:0]         prdata;
   output                pslverr;
   output                pready;
   
// AHB-Lite Master Interface  
   output [32-1:0]       hwaddr; 	//WHADDR0;
   output [2:0]          hwburst;	//WHBURST0;
   output [1:0]          hwsize;	//WHSIZE0;
   output [1:0]          hwtrans;	//WHTRANS0;
   output [32-1:0]       hwdata;	//WHWDATA0;
   
   input                 hwready;	//WHREADY0;
   input                 hwresp;	//WHRESP0; 
   
   output [32-1:0]       hraddr;	//RHADDR0;
   output [2:0]          hrburst;	//RHBURST0;
   output [1:0]          hrsize;	//RHSIZE0;
   output [1:0]          hrtrans;	//RHTRANS0;
   
   input [32-1:0]        hrdata;	//RHRDATA0;
   input                 hrready;	//RHREADY0;
   input                 hrresp;	//RHRESP0;


   
   wire                 rd_port_num0;
   wire                 wr_port_num0;
   wire                 rd_port_num1;
   wire                 wr_port_num1;
   wire                 slv_rd_port_num0;
   wire                 slv_wr_port_num0;
   wire                 slv_rd_port_num1;
   wire                 slv_wr_port_num1;
   
   wire [32-1:0]                		hwaddr;		//WHADDR0;
   wire [2:0]                           hwburst;	//WHBURST0;
   wire [1:0]                           hwsize;		//WHSIZE0;
   wire [1:0]                           hwtrans;	//WHTRANS0;
   wire [32-1:0]                		hwdata;		//WHWDATA0;
   wire                                 hwready;	//WHREADY0;
   wire                                 hwresp;		//WHRESP0;
   wire [32-1:0]                		hraddr;		//RHADDR0;
   wire [2:0]                           hrburst;	//RHBURST0;
   wire [1:0]                           hrsize;		//RHSIZE0;
   wire [1:0]                           hrtrans;	//RHTRANS0;
   wire [32-1:0]                		hrdata;		//RHRDATA0;
   wire                                 hrready;	//RHREADY0;
   wire                                 hrresp;		//RHRESP0;
   wire                                 WHLAST0;
   wire                                 WHOLD0;
   wire                                 RHLAST0;
   wire                                 RHOLD0;
   
	// wire for core_dual module 
   wire [32-1:0]           				hwaddr_m0; 		//M0_WHADDR;
   wire [2:0]                           hwburst_m0; 	//M0_WHBURST;
   wire [1:0]                           hwsize_m0; 		//M0_WHSIZE;
   wire [1:0]                           hwtrans_m0;		//M0_WHTRANS;
   wire [32-1:0]           				hwdata_m0;		//M0_WHWDATA;
   wire                                 hwready_m0;		//M0_WHREADY;
   wire                                 hwresp_m0;		//M0_WHRESP;
	//
   wire [32-1:0]           				hraddr_m0;		//M0_RHADDR;
   wire [2:0]                           hrburst_m0;		//M0_RHBURST;
   wire [1:0]                           hrsize_m0;		//M0_RHSIZE;
   wire [1:0]                           hrtrans_m0;		//M0_RHTRANS;
   wire [32-1:0]           				hrdata_m0;		//M0_RHRDATA;
   wire                                 hrready_m0;		//M0_RHREADY;
   wire                                 hrresp_m0;		//M0_RHRESP;

   wire                                 M0_WHLAST;
   wire                                 M0_WHOLD;
   wire                                 M0_RHLAST;
   wire                                 M0_RHOLD;
   /*
   wire [24-1:0]           				M1_WHADDR;
   wire [2:0]                           M1_WHBURST;
   wire [1:0]                           M1_WHSIZE;
   wire [1:0]                           M1_WHTRANS;
   wire [32-1:0]           				M1_WHWDATA;
   wire                                 M1_WHREADY;
   wire                                 M1_WHRESP;
   wire [24-1:0]           				M1_RHADDR;
   wire [2:0]                           M1_RHBURST;
   wire [1:0]                           M1_RHSIZE;
   wire [1:0]                           M1_RHTRANS;
   wire [32-1:0]           				M1_RHRDATA;
   wire                                 M1_RHREADY;
   wire                                 M1_RHRESP;
   wire                                 M1_WHLAST;
   wire                                 M1_WHOLD;
   wire                                 M1_RHLAST;
   wire                                 M1_RHOLD;
*/   
   wire [31:1]                 			periph_tx_req;
   wire [31:1]                 			periph_rx_req;
   wire [31:1]                 			periph_tx_clr;
   wire [31:1]                 			periph_rx_clr;
   
   assign                               hwaddr   = hwaddr_m0; 	//M0_WHADDR;
   assign                               hwburst  = hwburst_m0;  //M0_WHBURST;
   assign                               hwsize   = hwsize_m0;	//M0_WHSIZE;
   assign                               hwtrans  = hwtrans_m0;	//M0_WHTRANS;
   assign                               hwdata   = hwdata_m0;	//M0_WHWDATA;
   assign                               hraddr   = hraddr_m0;	//M0_RHADDR;
   assign                               hrburst  = hrburst_m0;	//M0_RHBURST;
   assign                               hrsize   = hrsize_m0;	//M0_RHSIZE;
   assign                               hrtrans  = hrtrans_m0;	//M0_RHTRANS;

   assign                               hwready_m0   = hwready;	//WHREADY0;
   assign                               hwresp_m0    = hwresp;	//WHRESP0;
   assign                               hrdata_m0    = hrdata;	//RHRDATA0;
   assign                               hrready_m0   = hrready;	//RHREADY0;
   assign                               hrresp_m0	 = hrresp;	//RHRESP0;
   
   assign                               WHLAST0   = M0_WHLAST;
   assign                               RHLAST0   = M0_RHLAST;
   assign                               M0_WHOLD  = WHOLD0;
   assign                               M0_RHOLD  = RHOLD0;
   
   assign 								WHLAST0 = 1'b0;
   assign 								RHLAST0 = 1'b0;
   assign                 				RHOLD0  = 1'b0;
   assign                 				WHOLD0  = 1'b0;

dma_ahb32_dual_core
   u_dma_ahb32_dual_core (
	// Clock and reset 
            .clk(hclk),     // clk
            .reset(hresetn),
            .scan_en(scan_en),

            .idle(idle),
            .INT(INT),
            .periph_tx_req(periph_tx_req),
            .periph_tx_clr(periph_tx_clr),
            .periph_rx_req(periph_rx_req),
            .periph_rx_clr(periph_rx_clr),
			
			// APB bus
            .pclken		(pclken),
            .psel		(psel),
            .penable	(penable),
            .paddr		(paddr),
            .pwrite		(pwrite),
            .pwdata		(pwdata),
            .prdata		(prdata),
            .pslverr	(pslverr),
            .pready		(pready),
             
            .rd_port_num0(rd_port_num0),
            .wr_port_num0(wr_port_num0),
            .rd_port_num1(rd_port_num1),
            .wr_port_num1(wr_port_num1),
			// AHB-Lite
            .M0_WHADDR (hwaddr_m0),
            .M0_WHBURST(hwburst_m0),
            .M0_WHSIZE (hwsize_m0),
            .M0_WHTRANS(hwtrans_m0),
            .M0_WHWDATA(hwdata_m0),
            .M0_WHREADY(hwready_m0),
            .M0_WHRESP(hwresp_m0),
            .M0_RHADDR(hraddr_m0),
            .M0_RHBURST(hrburst_m0),
            .M0_RHSIZE(hrsize_m0),
            .M0_RHTRANS(hrtrans_m0),
            .M0_RHRDATA(hrdata_m0),
            .M0_RHREADY(hrready_m0),
            .M0_RHRESP(hrresp_m0),
			// remove 
            .M0_WHLAST(M0_WHLAST),
            .M0_WHOLD(M0_WHOLD),
            .M0_RHLAST(M0_RHLAST),
            .M0_RHOLD(M0_RHOLD));
   
endmodule




