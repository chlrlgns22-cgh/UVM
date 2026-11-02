package can_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "can_seq_item.sv"
    `include "can_sequence.sv"
    `include "can_driver.sv"
    `include "can_tx_monitor.sv"
    `include "can_rx_monitor.sv"
    `include "can_tx_agent.sv"
    `include "can_rx_agent.sv"
    `include "can_scoreboard.sv"
    `include "can_coverage.sv"
    `include "can_env.sv"
    `include "can_test.sv"
endpackage