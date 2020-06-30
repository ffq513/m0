/*
 * Dynamic AHB switch
 * MASTERS: sets the number of AHB slave-ports on the switch
 *          AHB bus masters connect to these ports. There should only be 1 bus master per slave port
 *
 *          HSEL is used to determine if the port is accessed. This allows a single AHB bus master to be connected to multiple switches. It is allowed to drive HSEL with a static/hardwired signal ('1').
 *
 *          'priority' sets the priority of the port. This is used to determine what slave-port (AHB bus master) gets granted access to a master-port when multiple slave-ports want to access the same master-port. The slave-port with the highest priority is granted access.
 *          'priority' may be a static value or it may be a dynamic value where the priority can be set per AHB transfer. In the latter case 'priority' has the same requirements/restrictions as HSIZE/HBURST/HPROT, that is it must remain stable during a burst transfer.
 *          Hardwiring 'priority' results in a smaller (less logic resources) switch.
 *
 *
 * SLAVES : sets the number of AHB master-ports on the switch
 *          AHB slaves connect to these ports. There may be multiple slaves connected to a master port.
 *          Additional address decoding (HSEL generation) is necessary in this case
 *
 *          'haddr_mask' and 'haddr_base' define when a master-port is addressed.
 *          'haddr_mask' determines the relevant bits for the address decoding and 'haddr_base' specifies the base offset.
 *          selected = (HADDR & haddr_mask) == (haddr_base & haddr_mask)
 *          'haddr_mask' and 'haddr_base' should be static signals. Hardwiring these signals results in a smaller (less logic resource) switch.
 */
module ahb3lite_interconnect #(
  parameter HADDR_SIZE  = 32,
  parameter HDATA_SIZE  = 32,
  parameter MASTERS     = 3, //number of AHB Masters
  parameter SLAVES      = 9  //number of AHB slaves
)
(
  //Common signals
  input                   HRESETn,
                          HCLK,

  //Master Ports; AHB masters connect to these
  // thus these are actually AHB Slave Interfaces
  input  [           2:0] mst_priority  [MASTERS],

  input                   mst_HSEL      [MASTERS],
  input  [HADDR_SIZE-1:0] mst_HADDR     [MASTERS],
  input  [HDATA_SIZE-1:0] mst_HWDATA    [MASTERS],
  output [HDATA_SIZE-1:0] mst_HRDATA    [MASTERS],
  input                   mst_HWRITE    [MASTERS],
  input  [           2:0] mst_HSIZE     [MASTERS],
  input  [           2:0] mst_HBURST    [MASTERS],
  input  [           3:0] mst_HPROT     [MASTERS],
  input  [           1:0] mst_HTRANS    [MASTERS],
  input                   mst_HMASTLOCK [MASTERS],
  output                  mst_HREADYOUT [MASTERS],
  input                   mst_HREADY    [MASTERS],
  output                  mst_HRESP     [MASTERS],

  //Slave Ports; AHB Slaves connect to these
  //  thus these are actually AHB Master Interfaces
  input  [HADDR_SIZE-1:0] slv_addr_mask [SLAVES],
  input  [HADDR_SIZE-1:0] slv_addr_base [SLAVES],

  output                  slv_HSEL      [SLAVES],
  output [HADDR_SIZE-1:0] slv_HADDR     [SLAVES],
  output [HDATA_SIZE-1:0] slv_HWDATA    [SLAVES],
  input  [HDATA_SIZE-1:0] slv_HRDATA    [SLAVES],
  output                  slv_HWRITE    [SLAVES],
  output [           2:0] slv_HSIZE     [SLAVES],
  output [           2:0] slv_HBURST    [SLAVES],
  output [           3:0] slv_HPROT     [SLAVES],
  output [           1:0] slv_HTRANS    [SLAVES],
  output                  slv_HMASTLOCK [SLAVES],
  output                  slv_HREADYOUT [SLAVES], //HREADYOUT to slave-decoder; generates HREADY to all connected slaves
  input                   slv_HREADY    [SLAVES], //combinatorial HREADY from all connected slaves
  input                   slv_HRESP     [SLAVES],
  
  //// slave signal
//  input  [HADDR_SIZE-1:0] slv_addr_mask [SLAVES],
  input wire [31:0] slv_addr_mask0,
  input wire [31:0] slv_addr_mask1,
  input wire [31:0] slv_addr_mask2,
  input wire [31:0] slv_addr_mask3,
  input wire [31:0] slv_addr_mask4,
  input wire [31:0] slv_addr_mask5,
  input wire [31:0] slv_addr_mask6,
  input wire [31:0] slv_addr_mask7,
  input wire [31:0] slv_addr_mask8,

//  input  [HADDR_SIZE-1:0] slv_addr_base [SLAVES],
  input wire [31:0] slv_addr_base0,
  input wire [31:0] slv_addr_base1,
  input wire [31:0] slv_addr_base2,
  input wire [31:0] slv_addr_base3,
  input wire [31:0] slv_addr_base4,
  input wire [31:0] slv_addr_base5,
  input wire [31:0] slv_addr_base6,
  input wire [31:0] slv_addr_base7,
  input wire [31:0] slv_addr_base8,
  
//  output                  slv_HSEL      [SLAVES],
  output wire slv_HSEL0,
  output wire slv_HSEL1,
  output wire slv_HSEL2,
  output wire slv_HSEL3,
  output wire slv_HSEL4,
  output wire slv_HSEL5,
  output wire slv_HSEL6,
  output wire slv_HSEL7,
  output wire slv_HSEL8,

//  output [HADDR_SIZE-1:0] slv_HADDR     [SLAVES],
  output wire [31:0]slv_HADDR0,
  output wire [31:0]slv_HADDR1,
  output wire [31:0]slv_HADDR2,
  output wire [31:0]slv_HADDR3,
  output wire [31:0]slv_HADDR4,
  output wire [31:0]slv_HADDR5,
  output wire [31:0]slv_HADDR6,
  output wire [31:0]slv_HADDR7,
  output wire [31:0]slv_HADDR8,

//  output [HDATA_SIZE-1:0] slv_HWDATA    [SLAVES],
  output wire [31:0] slv_HWDATA0,
  output wire [31:0] slv_HWDATA1,
  output wire [31:0] slv_HWDATA2,
  output wire [31:0] slv_HWDATA3,
  output wire [31:0] slv_HWDATA4,
  output wire [31:0] slv_HWDATA5,
  output wire [31:0] slv_HWDATA6,
  output wire [31:0] slv_HWDATA7,
  output wire [31:0] slv_HWDATA8,
  
//  input  [HDATA_SIZE-1:0] slv_HRDATA    [SLAVES],
  input wire [31:0] slv_HRDATA0,
  input wire [31:0] slv_HRDATA1,
  input wire [31:0] slv_HRDATA2,
  input wire [31:0] slv_HRDATA3,
  input wire [31:0] slv_HRDATA4,
  input wire [31:0] slv_HRDATA5,
  input wire [31:0] slv_HRDATA6,
  input wire [31:0] slv_HRDATA7,
  input wire [31:0] slv_HRDATA8,

//  output                  slv_HWRITE    [SLAVES],
  output wire slv_HWRITE0,
  output wire slv_HWRITE1,
  output wire slv_HWRITE2,
  output wire slv_HWRITE3,
  output wire slv_HWRITE4,
  output wire slv_HWRITE5,
  output wire slv_HWRITE6,
  output wire slv_HWRITE7,
  output wire slv_HWRITE8,
  
//  output [           2:0] slv_HSIZE     [SLAVES],
  output wire [2:0] slv_HSIZE0,
  output wire [2:0] slv_HSIZE1,
  output wire [2:0] slv_HSIZE2,
  output wire [2:0] slv_HSIZE3,
  output wire [2:0] slv_HSIZE4,
  output wire [2:0] slv_HSIZE5,
  output wire [2:0] slv_HSIZE6,
  output wire [2:0] slv_HSIZE7,
  output wire [2:0] slv_HSIZE8,
  
//  output [           2:0] slv_HBURST    [SLAVES],
  output wire [2:0] slv_HBURST0,
  output wire [2:0] slv_HBURST1,
  output wire [2:0] slv_HBURST2,
  output wire [2:0] slv_HBURST3,
  output wire [2:0] slv_HBURST4,
  output wire [2:0] slv_HBURST5,
  output wire [2:0] slv_HBURST6,
  output wire [2:0] slv_HBURST7,
  output wire [2:0] slv_HBURST8,
  
//  output [           3:0] slv_HPROT     [SLAVES],
  output wire [3:0] slv_HPROT0,
  output wire [3:0] slv_HPROT1,
  output wire [3:0] slv_HPROT2,
  output wire [3:0] slv_HPROT3,
  output wire [3:0] slv_HPROT4,
  output wire [3:0] slv_HPROT5,
  output wire [3:0] slv_HPROT6,
  output wire [3:0] slv_HPROT7,
  output wire [3:0] slv_HPROT8,
  
//  output [           1:0] slv_HTRANS    [SLAVES],
  output wire [1:0] slv_HTRANS0,
  output wire [1:0] slv_HTRANS1,
  output wire [1:0] slv_HTRANS2,
  output wire [1:0] slv_HTRANS3,
  output wire [1:0] slv_HTRANS4,
  output wire [1:0] slv_HTRANS5,
  output wire [1:0] slv_HTRANS6,
  output wire [1:0] slv_HTRANS7,
  output wire [1:0] slv_HTRANS8,
  
//  output                  slv_HMASTLOCK [SLAVES],
  output wire slv_HMASTLOCK0,
  output wire slv_HMASTLOCK1,
  output wire slv_HMASTLOCK2,
  output wire slv_HMASTLOCK3,
  output wire slv_HMASTLOCK4,
  output wire slv_HMASTLOCK5,
  output wire slv_HMASTLOCK6,
  output wire slv_HMASTLOCK7,
  output wire slv_HMASTLOCK8,
  
//  output                  slv_HREADYOUT [SLAVES], //HREADYOUT to slave-decoder; generates HREADY to all connected slaves
  output wire slv_HREADYOUT0,
  output wire slv_HREADYOUT1,
  output wire slv_HREADYOUT2,
  output wire slv_HREADYOUT3,
  output wire slv_HREADYOUT4,
  output wire slv_HREADYOUT5,
  output wire slv_HREADYOUT6,
  output wire slv_HREADYOUT7,
  output wire slv_HREADYOUT8,
  
  
//  input                   slv_HREADY    [SLAVES], //combinatorial HREADY from all connected slaves
  input wire slv_HREADY0,
  input wire slv_HREADY1,
  input wire slv_HREADY2,
  input wire slv_HREADY3,
  input wire slv_HREADY4,
  input wire slv_HREADY5,
  input wire slv_HREADY6,
  input wire slv_HREADY7,
  input wire slv_HREADY8,
  
//  input                   slv_HRESP     [SLAVES],
  input wire slv_HRESP0,
  input wire slv_HRESP1,
  input wire slv_HRESP2,
  input wire slv_HRESP3,
  input wire slv_HRESP4,
  input wire slv_HRESP5,
  input wire slv_HRESP6,
  input wire slv_HRESP7,
  input wire slv_HRESP8,
  
  //// master signal 
 // input mst_HADDR
  input wire [31:0] mst_HADDR0,
  input wire [31:0] mst_HADDR1,
  input wire [31:0] mst_HADDR2,
//  input  [           2:0] mst_priority  [MASTERS],
  input wire [2:0] mst_priority0,
  input wire [2:0] mst_priority1,
  input wire [2:0] mst_priority2,
//  input                   mst_HSEL      [MASTERS],
  input wire mst_HSEL0,
  input wire mst_HSEL1,
  input wire mst_HSEL2,
//  input  [HDATA_SIZE-1:0] mst_HWDATA    [MASTERS],
  input wire [31:0] mst_HWDATA0,
  input wire [31:0] mst_HWDATA1,
  input wire [31:0] mst_HWDATA2,
//  output [HDATA_SIZE-1:0] mst_HRDATA    [MASTERS],
  output wire [31:0] mst_HRDATA0,
  output wire [31:0] mst_HRDATA1,
  output wire [31:0] mst_HRDATA2,
//  input                   mst_HWRITE    [MASTERS],
  input wire mst_HWRITE0,
  input wire mst_HWRITE1,
  input wire mst_HWRITE2,
//  input  [           2:0] mst_HSIZE     [MASTERS],
  input wire [2:0] mst_HSIZE0,
  input wire [2:0] mst_HSIZE1,
  input wire [2:0] mst_HSIZE2,
//  input  [           2:0] mst_HBURST    [MASTERS],
  input wire [2:0] mst_HBURST0,
  input wire [2:0] mst_HBURST1,
  input wire [2:0] mst_HBURST2,
//  input  [           3:0] mst_HPROT     [MASTERS],
  input wire [3:0] mst_HPROT0,
  input wire [3:0] mst_HPROT1,
  input wire [3:0] mst_HPROT2,
//  input  [           1:0] mst_HTRANS    [MASTERS],
  input wire [1:0] mst_HTRANS0,
  input wire [1:0] mst_HTRANS1,
  input wire [1:0] mst_HTRANS2,
//  input                   mst_HMASTLOCK [MASTERS],
  input wire mst_HMASTLOCK0,
  input wire mst_HMASTLOCK1,
  input wire mst_HMASTLOCK2,
//  output                  mst_HREADYOUT [MASTERS],
  output wire mst_HREADYOUT0,
  output wire mst_HREADYOUT1,
  output wire mst_HREADYOUT2,
//  input                   mst_HREADY    [MASTERS],
  input wire mst_HREADY0,
  input wire mst_HREADY1,
  input wire mst_HREADY2,
//  output                  mst_HRESP     [MASTERS]
  output wire mst_HRESP0,
  output wire mst_HRESP1,
  output wire mst_HRESP2
);
  //////////////////////////////////////////////////////////////////
  //
  // Constants
  //
  import ahb3lite_pkg::*;
  
  // assign master signal 
  // input mst_HADDR 
  assign mst_HADDR0 = mst_HADDR[0];
  assign mst_HADDR1 = mst_HADDR[1];
  assign mst_HADDR2 = mst_HADDR[2];
  //  input  [           2:0] mst_priority  [MASTERS],
  assign mst_priority0 = mst_priority[0];
  assign mst_priority1 = mst_priority[1];
  assign mst_priority2 = mst_priority[2];
  //   input wire mst_HSEL0,
  assign mst_HSEL0 = mst_HSEL[0];
  assign mst_HSEL1 = mst_HSEL[1];
  assign mst_HSEL2 = mst_HSEL[2];
  // input wire [31:0] mst_HWDATA0,
  assign mst_HWDATA0 = mst_HWDATA[0];
  assign mst_HWDATA1 = mst_HWDATA[1];
  assign mst_HWDATA2 = mst_HWDATA[2];
  // output wire [31:0] mst_HRDATA0,
  assign mst_HRDATA0 = mst_HRDATA[0];
  assign mst_HRDATA1 = mst_HRDATA[1];
  assign mst_HRDATA2 = mst_HRDATA[2];
  // input wire mst_HWRITE0,
  assign mst_HWRITE0 = mst_HWRITE[0];
  assign mst_HWRITE1 = mst_HWRITE[1];
  assign mst_HWRITE2 = mst_HWRITE[2];
  // input wire [2:0] mst_HSIZE0,
  assign mst_HSIZE0 = mst_HSIZE[0];
  assign mst_HSIZE1 = mst_HSIZE[1];
  assign mst_HSIZE2 = mst_HSIZE[2];
  // input wire [2:0] mst_HBURST0,
  assign mst_HBURST0 = mst_HBURST[0];
  assign mst_HBURST1 = mst_HBURST[1];
  assign mst_HBURST2 = mst_HBURST[2];
  // input wire [3:0] mst_HPROT0,
  assign mst_HPROT0 = mst_HPROT[0];
  assign mst_HPROT1 = mst_HPROT[1];
  assign mst_HPROT2 = mst_HPROT[2];
  // input wire [1:0] mst_HTRANS0,
  assign mst_HTRANS0 = mst_HTRANS[0];
  assign mst_HTRANS1 = mst_HTRANS[1];
  assign mst_HTRANS2 = mst_HTRANS[2];
  // input wire mst_HMASTLOCK0,
  assign mst_HMASTLOCK0 = mst_HMASTLOCK[0];
  assign mst_HMASTLOCK1 = mst_HMASTLOCK[1];
  assign mst_HMASTLOCK2 = mst_HMASTLOCK[2];
  // input wire mst_HREADYOUT0,
  assign mst_HREADYOUT0 = mst_HREADYOUT[0];
  assign mst_HREADYOUT1 = mst_HREADYOUT[1];
  assign mst_HREADYOUT2 = mst_HREADYOUT[2];
  // input wire mst_HREADY0,
  assign  mst_HREADY0 =  mst_HREADY[0];
  assign  mst_HREADY1 =  mst_HREADY[1];
  assign  mst_HREADY2 =  mst_HREADY[2];
  // input wire mst_HRESP0,
  assign mst_HRESP0 = mst_HRESP[0];
  assign mst_HRESP1 = mst_HRESP[1];
  assign mst_HRESP2 = mst_HRESP[2];
  
  // assign slave signal 
  
  //  input  [HADDR_SIZE-1:0] slv_addr_mask [SLAVES],
  assign slv_addr_mask0 = slv_addr_mask[0];
  assign slv_addr_mask1 = slv_addr_mask[1];
  assign slv_addr_mask2 = slv_addr_mask[2];
  assign slv_addr_mask3 = slv_addr_mask[3];
  assign slv_addr_mask4 = slv_addr_mask[4];
  assign slv_addr_mask5 = slv_addr_mask[5];
  assign slv_addr_mask6 = slv_addr_mask[6];
  assign slv_addr_mask7 = slv_addr_mask[7];
  assign slv_addr_mask8 = slv_addr_mask[8];
  
  //  input  [HADDR_SIZE-1:0] slv_addr_base [SLAVES],
  assign slv_addr_base0 = slv_addr_base[0];
  assign slv_addr_base1 = slv_addr_base[1];
  assign slv_addr_base2 = slv_addr_base[2];
  assign slv_addr_base3 = slv_addr_base[3];
  assign slv_addr_base4 = slv_addr_base[4];
  assign slv_addr_base5 = slv_addr_base[5];
  assign slv_addr_base6 = slv_addr_base[6];
  assign slv_addr_base7 = slv_addr_base[7];
  assign slv_addr_base8 = slv_addr_base[8];
  
  //  output                  slv_HSEL      [SLAVES],
  assign slv_HSEL0 = slv_HSEL[0];
  assign slv_HSEL1 = slv_HSEL[1];
  assign slv_HSEL2 = slv_HSEL[2];
  assign slv_HSEL3 = slv_HSEL[3];
  assign slv_HSEL4 = slv_HSEL[4];
  assign slv_HSEL5 = slv_HSEL[5];
  assign slv_HSEL6 = slv_HSEL[6];
  assign slv_HSEL7 = slv_HSEL[7];
  assign slv_HSEL8 = slv_HSEL[8];
  
  //  output [HADDR_SIZE-1:0] slv_HADDR     [SLAVES],
  assign slv_HADDR0 = slv_HADDR[0];
  assign slv_HADDR1 = slv_HADDR[1];
  assign slv_HADDR2 = slv_HADDR[2];
  assign slv_HADDR3 = slv_HADDR[3];
  assign slv_HADDR4 = slv_HADDR[4];
  assign slv_HADDR5 = slv_HADDR[5];
  assign slv_HADDR6 = slv_HADDR[6];
  assign slv_HADDR7 = slv_HADDR[7];
  assign slv_HADDR8 = slv_HADDR[8];
  
  //  output [HDATA_SIZE-1:0] slv_HWDATA    [SLAVES],
  assign slv_HWDATA0 = slv_HWDATA[0];
  assign slv_HWDATA1 = slv_HWDATA[1];
  assign slv_HWDATA2 = slv_HWDATA[2];
  assign slv_HWDATA3 = slv_HWDATA[3];
  assign slv_HWDATA4 = slv_HWDATA[4];
  assign slv_HWDATA5 = slv_HWDATA[5];
  assign slv_HWDATA6 = slv_HWDATA[6];
  assign slv_HWDATA7 = slv_HWDATA[7];
  assign slv_HWDATA8 = slv_HWDATA[8];
  
  
  //  input  [HDATA_SIZE-1:0] slv_HRDATA    [SLAVES],
  assign slv_HRDATA0 = slv_HRDATA[0];
  assign slv_HRDATA1 = slv_HRDATA[1];
  assign slv_HRDATA2 = slv_HRDATA[2];
  assign slv_HRDATA3 = slv_HRDATA[3];
  assign slv_HRDATA4 = slv_HRDATA[4];
  assign slv_HRDATA5 = slv_HRDATA[5];
  assign slv_HRDATA6 = slv_HRDATA[6];
  assign slv_HRDATA7 = slv_HRDATA[7];
  assign slv_HRDATA8 = slv_HRDATA[8];
  
  
  //  output                  slv_HWRITE    [SLAVES],
  assign slv_HWRITE0 = slv_HWRITE[0];
  assign slv_HWRITE1 = slv_HWRITE[1];
  assign slv_HWRITE2 = slv_HWRITE[2];
  assign slv_HWRITE3 = slv_HWRITE[3];
  assign slv_HWRITE4 = slv_HWRITE[4];
  assign slv_HWRITE5 = slv_HWRITE[5];
  assign slv_HWRITE6 = slv_HWRITE[6];
  assign slv_HWRITE7 = slv_HWRITE[7];
  assign slv_HWRITE8 = slv_HWRITE[8];
  
  //  output [           2:0] slv_HSIZE     [SLAVES],
  assign slv_HSIZE0 = slv_HSIZE[0];
  assign slv_HSIZE1 = slv_HSIZE[1];
  assign slv_HSIZE2 = slv_HSIZE[2];
  assign slv_HSIZE3 = slv_HSIZE[3];
  assign slv_HSIZE4 = slv_HSIZE[4];
  assign slv_HSIZE5 = slv_HSIZE[5];
  assign slv_HSIZE6 = slv_HSIZE[6];
  assign slv_HSIZE7 = slv_HSIZE[7];
  assign slv_HSIZE8 = slv_HSIZE[8];
  
  //  output [           2:0] slv_HBURST    [SLAVES],
  assign slv_HBURST0 = slv_HBURST[0];
  assign slv_HBURST1 = slv_HBURST[1];
  assign slv_HBURST2 = slv_HBURST[2];
  assign slv_HBURST3 = slv_HBURST[3];
  assign slv_HBURST4 = slv_HBURST[4];
  assign slv_HBURST5 = slv_HBURST[5];
  assign slv_HBURST6 = slv_HBURST[6];
  assign slv_HBURST7 = slv_HBURST[7];
  assign slv_HBURST8 = slv_HBURST[8];
  
  //  output [           3:0] slv_HPROT     [SLAVES],
  assign slv_HPROT0 = slv_HPROT[0];
  assign slv_HPROT1 = slv_HPROT[1];
  assign slv_HPROT2 = slv_HPROT[2];
  assign slv_HPROT3 = slv_HPROT[3];
  assign slv_HPROT4 = slv_HPROT[4];
  assign slv_HPROT5 = slv_HPROT[5];
  assign slv_HPROT6 = slv_HPROT[6];
  assign slv_HPROT7 = slv_HPROT[7];
  assign slv_HPROT8 = slv_HPROT[8];
  
   
  //  output [           1:0] slv_HTRANS    [SLAVES],
  assign slv_HTRANS0 = slv_HTRANS[0];
  assign slv_HTRANS1 = slv_HTRANS[1];
  assign slv_HTRANS2 = slv_HTRANS[2];
  assign slv_HTRANS3 = slv_HTRANS[3];
  assign slv_HTRANS4 = slv_HTRANS[4];
  assign slv_HTRANS5 = slv_HTRANS[5];
  assign slv_HTRANS6 = slv_HTRANS[6];
  assign slv_HTRANS7 = slv_HTRANS[7];
  assign slv_HTRANS8 = slv_HTRANS[8];
  
  //  output                  slv_HMASTLOCK [SLAVES],
  assign slv_HMASTLOCK0 = slv_HMASTLOCK[0];
  assign slv_HMASTLOCK1 = slv_HMASTLOCK[1];
  assign slv_HMASTLOCK2 = slv_HMASTLOCK[2];
  assign slv_HMASTLOCK3 = slv_HMASTLOCK[3];
  assign slv_HMASTLOCK4 = slv_HMASTLOCK[4];
  assign slv_HMASTLOCK5 = slv_HMASTLOCK[5];
  assign slv_HMASTLOCK6 = slv_HMASTLOCK[6];
  assign slv_HMASTLOCK7 = slv_HMASTLOCK[7];
  assign slv_HMASTLOCK8 = slv_HMASTLOCK[8];
  
  //  output                  slv_HREADYOUT [SLAVES], //HREADYOUT to slave-decoder; generates HREADY to all connected slaves
  assign slv_HREADYOUT0 = slv_HREADYOUT[0];
  assign slv_HREADYOUT1 = slv_HREADYOUT[1];
  assign slv_HREADYOUT2 = slv_HREADYOUT[2];
  assign slv_HREADYOUT3 = slv_HREADYOUT[3];
  assign slv_HREADYOUT4 = slv_HREADYOUT[4];
  assign slv_HREADYOUT5 = slv_HREADYOUT[5];
  assign slv_HREADYOUT6 = slv_HREADYOUT[6];
  assign slv_HREADYOUT7 = slv_HREADYOUT[7];
  assign slv_HREADYOUT8 = slv_HREADYOUT[8];
  
  
  //  input                   slv_HREADY    [SLAVES], //combinatorial HREADY from all connected slaves
  assign slv_HREADY0 = slv_HREADY[0];
  assign slv_HREADY1 = slv_HREADY[1];
  assign slv_HREADY2 = slv_HREADY[2];
  assign slv_HREADY3 = slv_HREADY[3];
  assign slv_HREADY4 = slv_HREADY[4];
  assign slv_HREADY5 = slv_HREADY[5];
  assign slv_HREADY6 = slv_HREADY[6];
  assign slv_HREADY7 = slv_HREADY[7];
  assign slv_HREADY8 = slv_HREADY[8];
  
  //  input                   slv_HRESP     [SLAVES],
  assign slv_HRESP0 = slv_HRESP[0];
  assign slv_HRESP1 = slv_HRESP[1];
  assign slv_HRESP2 = slv_HRESP[2];
  assign slv_HRESP3 = slv_HRESP[3];
  assign slv_HRESP4 = slv_HRESP[4];
  assign slv_HRESP5 = slv_HRESP[5];
  assign slv_HRESP6 = slv_HRESP[6];
  assign slv_HRESP7 = slv_HRESP[7];
  assign slv_HRESP8 = slv_HRESP[8];
  
  //////////////////////////////////////////////////////////////////
  //
  // Variables
  //
  logic [MASTERS-1:0]             [           2:0] frommstpriority;
  logic [MASTERS-1:0][SLAVES -1:0]                 frommstHSEL;
  logic [MASTERS-1:0]             [HADDR_SIZE-1:0] frommstHADDR;
  logic [MASTERS-1:0]             [HDATA_SIZE-1:0] frommstHWDATA;
  logic [MASTERS-1:0][SLAVES -1:0][HDATA_SIZE-1:0] tomstHRDATA;
  logic [MASTERS-1:0]                              frommstHWRITE;
  logic [MASTERS-1:0]             [           2:0] frommstHSIZE;
  logic [MASTERS-1:0]             [           2:0] frommstHBURST;
  logic [MASTERS-1:0]             [           3:0] frommstHPROT;
  logic [MASTERS-1:0]             [           1:0] frommstHTRANS;
  logic [MASTERS-1:0]                              frommstHMASTLOCK;
  logic [MASTERS-1:0]                              frommstHREADYOUT,
                                                   frommst_canswitch;
  logic [MASTERS-1:0][SLAVES -1:0]                 tomstHREADY;
  logic [MASTERS-1:0][SLAVES -1:0]                 tomstHRESP;
  logic [MASTERS-1:0][SLAVES -1:0]                 tomstgrant;


  logic [SLAVES -1:0][MASTERS-1:0][           2:0] toslvpriority;
  logic [SLAVES -1:0][MASTERS-1:0]                 toslvHSEL;
  logic [SLAVES -1:0][MASTERS-1:0][HADDR_SIZE-1:0] toslvHADDR;
  logic [SLAVES -1:0][MASTERS-1:0][HDATA_SIZE-1:0] toslvHWDATA;
  logic [SLAVES -1:0]             [HDATA_SIZE-1:0] fromslvHRDATA;
  logic [SLAVES -1:0][MASTERS-1:0]                 toslvHWRITE;
  logic [SLAVES -1:0][MASTERS-1:0][           2:0] toslvHSIZE;
  logic [SLAVES -1:0][MASTERS-1:0][           2:0] toslvHBURST;
  logic [SLAVES -1:0][MASTERS-1:0][           3:0] toslvHPROT;
  logic [SLAVES -1:0][MASTERS-1:0][           1:0] toslvHTRANS;
  logic [SLAVES -1:0][MASTERS-1:0]                 toslvHMASTLOCK;
  logic [SLAVES -1:0][MASTERS-1:0]                 toslvHREADY,
                                                   toslv_canswitch;
  logic [SLAVES -1:0]                              fromslvHREADYOUT;
  logic [SLAVES -1:0]                              fromslvHRESP;
  logic [SLAVES -1:0][MASTERS-1:0]                 fromslvgrant;


  genvar m,s;


  //////////////////////////////////////////////////////////////////
  //
  // Module Body
  //
  
  /*
   * Hookup Master Interfaces
   */
generate
  for (m=0;m < MASTERS; m++)
  begin: gen_master_ports
  ahb3lite_interconnect_master_port #(
    .HADDR_SIZE     ( HADDR_SIZE             ),
    .HDATA_SIZE     ( HDATA_SIZE             ),
    .MASTERS        ( MASTERS                ),
    .SLAVES         ( SLAVES                 ) )
  master_port (
    .HRESETn        ( HRESETn                ),
    .HCLK           ( HCLK                   ),
	 
    //AHB Slave Interfaces (receive data from AHB Masters)
    //AHB Masters conect to these ports
    .mst_priority   ( mst_priority       [m] ),
    .mst_HSEL       ( mst_HSEL           [m] ),
    .mst_HADDR      ( mst_HADDR          [m] ),
    .mst_HWDATA     ( mst_HWDATA         [m] ),
    .mst_HRDATA     ( mst_HRDATA         [m] ),
    .mst_HWRITE     ( mst_HWRITE         [m] ),
    .mst_HSIZE      ( mst_HSIZE          [m] ),
    .mst_HBURST     ( mst_HBURST         [m] ),
    .mst_HPROT      ( mst_HPROT          [m] ),
    .mst_HTRANS     ( mst_HTRANS         [m] ),
    .mst_HMASTLOCK  ( mst_HMASTLOCK      [m] ),
    .mst_HREADYOUT  ( mst_HREADYOUT      [m] ),
    .mst_HREADY     ( mst_HREADY         [m] ),
    .mst_HRESP      ( mst_HRESP          [m] ),
    
    //AHB Master Interfaces (send data to AHB slaves)
    //AHB Slaves connect to these ports
    .slvHADDRmask   ( slv_addr_mask          ),
    .slvHADDRbase   ( slv_addr_base          ),
    .slvpriority    ( frommstpriority    [m] ),
    .slvHSEL        ( frommstHSEL        [m] ),
    .slvHADDR       ( frommstHADDR       [m] ),
    .slvHWDATA      ( frommstHWDATA      [m] ),
    .slvHRDATA      ( tomstHRDATA        [m] ),
    .slvHWRITE      ( frommstHWRITE      [m] ),
    .slvHSIZE       ( frommstHSIZE       [m] ),
    .slvHBURST      ( frommstHBURST      [m] ),
    .slvHPROT       ( frommstHPROT       [m] ),
    .slvHTRANS      ( frommstHTRANS      [m] ),
    .slvHMASTLOCK   ( frommstHMASTLOCK   [m] ),
    .slvHREADY      ( tomstHREADY        [m] ),
    .slvHREADYOUT   ( frommstHREADYOUT   [m] ),
    .slvHRESP       ( tomstHRESP         [m] ),

    .can_switch     ( frommst_canswitch  [m] ),
    .master_granted ( tomstgrant         [m] ) );
    end
endgenerate


  /*
   * wire mangling
   */
  //Master-->Slave
  generate
    for (s=0; s<SLAVES; s++)
    begin: slave
      for (m=0; m<MASTERS; m++)
      begin: master
          assign toslvpriority    [s][m] = frommstpriority    [m];
          assign toslvHSEL        [s][m] = frommstHSEL        [m][s];
          assign toslvHADDR       [s][m] = frommstHADDR       [m];
          assign toslvHWDATA      [s][m] = frommstHWDATA      [m];
          assign toslvHWRITE      [s][m] = frommstHWRITE      [m];
          assign toslvHSIZE       [s][m] = frommstHSIZE       [m];
          assign toslvHBURST      [s][m] = frommstHBURST      [m];
          assign toslvHPROT       [s][m] = frommstHPROT       [m];
          assign toslvHTRANS      [s][m] = frommstHTRANS      [m];
          assign toslvHMASTLOCK   [s][m] = frommstHMASTLOCK   [m];
          assign toslvHREADY      [s][m] = frommstHREADYOUT   [m]; //feed Masters's HREADY signal to slave port
          assign toslv_canswitch  [s][m] = frommst_canswitch  [m];
      end //next m
    end //next s
  endgenerate


  /*
   * wire mangling
   */
  //Slave-->Master
  generate
    for (m=0; m<MASTERS; m++)
    begin: master
      for (s=0; s<SLAVES; s++)
      begin: slave
          assign tomstgrant [m][s] = fromslvgrant    [s][m];   
          assign tomstHRDATA[m][s] = fromslvHRDATA   [s];
          assign tomstHREADY[m][s] = fromslvHREADYOUT[s];
          assign tomstHRESP [m][s] = fromslvHRESP    [s];
      end //next s
    end //next m
  endgenerate


  /*
   * Hookup Slave Interfaces
   */
generate
  for (s=0;s < SLAVES; s++)
  begin: gen_slave_ports
  ahb3lite_interconnect_slave_port #(
    .HADDR_SIZE      ( HADDR_SIZE           ),
    .HDATA_SIZE      ( HDATA_SIZE           ),
    .MASTERS         ( MASTERS              ),
    .SLAVES          ( SLAVES               ) )
  slave_port (
    .HRESETn         ( HRESETn              ),
    .HCLK            ( HCLK                 ),
	 
    //AHB Slave Interfaces (receive data from AHB Masters)
    //AHB Masters connect to these ports
    .mstpriority     ( toslvpriority    [s] ),
    .mstHSEL         ( toslvHSEL        [s] ),
    .mstHADDR        ( toslvHADDR       [s] ),
    .mstHWDATA       ( toslvHWDATA      [s] ),
    .mstHRDATA       ( fromslvHRDATA    [s] ),
    .mstHWRITE       ( toslvHWRITE      [s] ),
    .mstHSIZE        ( toslvHSIZE       [s] ),
    .mstHBURST       ( toslvHBURST      [s] ),
    .mstHPROT        ( toslvHPROT       [s] ),
    .mstHTRANS       ( toslvHTRANS      [s] ),
    .mstHMASTLOCK    ( toslvHMASTLOCK   [s] ),
    .mstHREADY       ( toslvHREADY      [s] ),
    .mstHREADYOUT    ( fromslvHREADYOUT [s] ),
    .mstHRESP        ( fromslvHRESP     [s] ),


    //AHB Master Interfaces (send data to AHB slaves)
    //AHB Slaves connect to these ports
    .slv_HSEL        ( slv_HSEL        [s] ),
    .slv_HADDR       ( slv_HADDR       [s] ),
    .slv_HWDATA      ( slv_HWDATA      [s] ),
    .slv_HRDATA      ( slv_HRDATA      [s] ),
    .slv_HWRITE      ( slv_HWRITE      [s] ),
    .slv_HSIZE       ( slv_HSIZE       [s] ),
    .slv_HBURST      ( slv_HBURST      [s] ),
    .slv_HPROT       ( slv_HPROT       [s] ),
    .slv_HTRANS      ( slv_HTRANS      [s] ),
    .slv_HMASTLOCK   ( slv_HMASTLOCK   [s] ),
    .slv_HREADYOUT   ( slv_HREADYOUT   [s] ),
    .slv_HREADY      ( slv_HREADY      [s] ),
    .slv_HRESP       ( slv_HRESP       [s] ),

    //Internal signals
    .can_switch      ( toslv_canswitch [s] ),
    .granted_master  ( fromslvgrant    [s] ) );
  end
endgenerate


endmodule


