package dff_tb_pkg;
    typedef struct packed {
        logic        valid;
        logic [3:0]  tag;
        logic [10:0] data;
    } pkt_t;
endpackage
