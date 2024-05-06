//即使没有读使能，FIFO最先放入的数据在rd_data处也直接存在，相当于FWFT(first word fall through)式FIFO

module zc_sync_fifo#(
    parameter               WIDTH = 144     ,
    parameter               DEPTH = 12
)(
    input                   sys_clk         ,
    input                   sys_rst_n       ,

    input                   wr_en           ,
    input [WIDTH - 1 : 0]   wr_data         ,
    output                  wr_full         ,

    input                   rd_en           ,
    output [WIDTH - 1 : 0]  rd_data         ,
    output                  rd_empty         
);

    reg [$clog2(DEPTH) : 0] wr_addr         ;
    reg [$clog2(DEPTH) : 0] rd_addr         ;

    assign wr_full = (wr_addr == {~rd_addr[$clog2(DEPTH)] , rd_addr[$clog2(DEPTH) - 1 : 0]});
    assign rd_empty = (wr_addr == rd_addr);

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            wr_addr <= 'd0;
        else if(wr_en & ~wr_full)
            wr_addr <= wr_addr + 1'b1;
        else
            wr_addr <= wr_addr;
    end

    always@(posedge sys_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)
            rd_addr <= 0;
        else if(rd_en & ~rd_empty)
            rd_addr <= rd_addr + 1'b1;
        else
            rd_addr <= rd_addr; 
    end

    dual_port_ram#(
        .WIDTH      (   WIDTH                           ),
        .DEPTH      (   DEPTH                           )
    )dual_port_ram_instance(
        .sys_rst_n  (   sys_rst_n                       ),
        .wr_clk     (   sys_clk                         ),
        .wr_en      (   wr_en & ~wr_full                ),
        .wr_data    (   wr_data                         ),
        .wr_addr    (   wr_addr[$clog2(DEPTH) - 1 : 0]  ),
        .rd_clk     (   sys_clk                         ),
        .rd_en      (   rd_en & ~rd_empty               ),
        .rd_data    (   rd_data                         ),
        .rd_addr    (   rd_addr[$clog2(DEPTH) - 1 : 0]  )
    );

endmodule








