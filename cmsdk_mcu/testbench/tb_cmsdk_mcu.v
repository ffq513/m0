//-----------------------------------------------------------------------------
// Abstract : Testbench for the Cortex-M0 example system
//-----------------------------------------------------------------------------
//
`timescale 1ns/1ps
//`include "cmsdk_mcu_defs.v"

module tb_cmsdk_mcu;
  wire        XTAL1;   // crystal pin 1
  wire        XTAL2;   // crystal pin 2
  wire        NRST;    // active low reset

  wire [15:0] P0;      // Port 0
  wire [15:0] P1;      // Port 1
  //reg  uart0_rxd = 1;
  //wire uart0_txd;
  //wire uart0_txen;
  //Debug tester signals
  wire        nTRST;
  wire        TDI;
  wire        SWDIOTMS;
  wire        SWCLKTCK;
  wire        TDO;

  wire        PCLK;          // Clock for UART capture device
  wire [5:0]  debug_command; // used to drive debug tester
  wire        debug_running; // indicate debug test is running
  wire        debug_err;     // indicate debug test has error

  wire        debug_test_en; // To enable the debug tester connection to MCU GPIO P0
                             // This signal is controlled by software,
                             // Use "UartPutc((char) 0x1B)" to send ESCAPE code to start
                             // the command, use "UartPutc((char) 0x11)" to send debug test
                             // enable command, use "UartPutc((char) 0x12)" to send debug test
                             // disable command. Refer to tb_uart_capture.v file for detail

  parameter BE              = 0;   // Big or little endian
  parameter BKPT            = 4;   // Number of breakpoint comparators
  parameter DBG             = 1;   // Debug configuration
  parameter NUMIRQ          = 32;  // NUM of IRQ
  parameter SMUL            = 0;   // Multiplier configuration
  parameter SYST            = 1;   // SysTick
  parameter WIC             = 1;   // Wake-up interrupt controller support
  parameter WICLINES        = 34;  // Supported WIC lines
  parameter WPT             = 2;   // Number of DWT comparators

 // --------------------------------------------------------------------------------
 // Cortex-M0 Microcontroller
 // --------------------------------------------------------------------------------

  cmsdk_mcu
   #(.BE               (BE),
     .BKPT             (BKPT),          // Number of breakpoint comparators
     .DBG              (DBG),           // Debug configuration
     .NUMIRQ           (NUMIRQ),        // NUMIRQ
     .SMUL             (SMUL),          // Multiplier configuration
     .SYST             (SYST),          // SysTick
     .WIC              (WIC),           // Wake-up interrupt controller support
     .WICLINES         (WICLINES),      // Supported WIC lines
     .WPT              (WPT)            // Number of DWT comparators
   )
   u_cmsdk_mcu (
  .XTAL1      (XTAL1),  // input    clock 
  .XTAL2      (XTAL2),  // output
  .NRST       (NRST),   // active low reset
  .P0         (P0),
  .P1         (P1),
  .nTRST      (nTRST),  // Not needed if serial-wire debug is used
  .TDI        (TDI),    // Not needed if serial-wire debug is used
  .TDO        (TDO),    // Not needed if serial-wire debug is used
  .SWDIOTMS   (SWDIOTMS),
  .SWCLKTCK   (SWCLKTCK)
//  .uart0_rxd  (uart0_rxd),
//  .uart0_txd  (uart0_txd),
//  .uart0_txen (uart0_txen)
//  .UART_TX    (UART_TX)
  );

 // --------------------------------------------------------------------------------
 // Source for clock and reset
 // --------------------------------------------------------------------------------
  cmsdk_clkreset u_cmsdk_clkreset(
  .CLK  (XTAL1),
  .NRST (NRST)       // reset system
  );

 // --------------------------------------------------------------------------------
 // UART output capture
 // --------------------------------------------------------------------------------
  assign PCLK = XTAL1;

  cmsdk_uart_capture   u_cmsdk_uart_capture(
    .RESETn               (NRST),
    .CLK                  (PCLK),
    .RXD                  (P1[1]), // UART 0 used for StdOut
    .DEBUG_TESTER_ENABLE  (debug_test_en),
    .SIMULATIONEND        (),      // This signal set to 1 at the end of simulation.
    .AUXCTRL              ()
  ); 

  // UART connection cross over for UART test
  assign P1[2] = P1[5];  // UART 1 RXD = UART 2 TXD
  assign P1[4] = P1[3];  // UART 2 RXD = UART 1 TXD

 // --------------------------------------------------------------------------------
 // Debug tester connection -
 // --------------------------------------------------------------------------------

 // No debug connection for Cortex-M0 DesignStart
 assign nTRST    = ~NRST; // initial assign nTRST    = NRST;
 assign TDI      = 1'b1;
 assign SWDIOTMS = 1'b1;
 assign SWCLKTCK = 1'b1;

 bufif1 (P0[14], debug_running, debug_test_en);
 bufif1 (P0[14], debug_err, debug_test_en);

 pullup (debug_running);
 pullup (debug_err);

 // --------------------------------------------------------------------------------
 // Misc
 // --------------------------------------------------------------------------------

  initial $timeformat(-9, 0, " ns", 0);

  
endmodule
