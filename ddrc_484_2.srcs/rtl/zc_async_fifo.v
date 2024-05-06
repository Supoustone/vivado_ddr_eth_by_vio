module async_fifo#(
    parameter DEPTH = 256,
    parameter WIDTH = 128
)(
        input                               wr_clk      ,
        input                               wr_en       ,
        input [WIDTH - 1 : 0]               wr_data     ,
        output                              wr_full     ,

        input                               rd_clk      ,
        input                               rd_en       ,
        output [WIDTH - 1 : 0]              rd_data     ,
        output                              rd_empty    ,

        input                               rst_n
    );

    wire [$clog2(DEPTH) : 0]  wr_addr;
    wire [$clog2(DEPTH) : 0]  rd_addr;

    wire [$clog2(DEPTH) : 0] sync_wr_pointer;
    wire [$clog2(DEPTH) : 0] rd_pointer;
    wire [$clog2(DEPTH) : 0] sync_rd_pointer;
    wire [$clog2(DEPTH) : 0] wr_pointer;

    dual_port_ram#(
        .DEPTH      (DEPTH              )               ,
        .WIDTH      (WIDTH              )
    )
    dual_port_ram_instance(
        .sys_rst_n  (rst_n              )               ,
        .wr_clk     (wr_clk             )               ,
        .wr_en      (wr_en & ~wr_full   )               ,
        .wr_addr    (wr_addr[$clog2(DEPTH) - 1 : 0])    ,
        .wr_data    (wr_data            )               ,
        .rd_clk     (rd_clk             )               ,
        .rd_en      (rd_en & ~rd_empty  )               ,
        .rd_addr    (rd_addr[$clog2(DEPTH) - 1 : 0])    ,
        .rd_data    (rd_data            )
    );

    read_ptr_empty#(
        .DEPTH              (DEPTH              )       ,
        .WIDTH              (WIDTH              )
    )
    read_ptr_empty_instance(
        .rd_clk             (rd_clk             )       ,
        .rst_n              (rst_n              )       ,
        .rd_en              (rd_en              )       ,
        .rd_addr            (rd_addr            )       ,
        .sync_wr_pointer    (sync_wr_pointer    )       ,
        .rd_pointer         (rd_pointer         )       ,
        .rd_empty           (rd_empty           )
    );

    write_ptr_full#(
        .DEPTH              (DEPTH              )       ,
        .WIDTH              (WIDTH              )
    )
    write_ptr_full_instance(
        .wr_clk             (wr_clk             )       ,
        .rst_n              (rst_n              )       ,
        .wr_en              (wr_en              )       ,
        .wr_addr            (wr_addr            )       ,
        .sync_rd_pointer    (sync_rd_pointer    )       ,
        .wr_pointer         (wr_pointer         )       ,
        .wr_full            (wr_full            )
    );

    sync_r2w#(
        .DEPTH              (DEPTH              )       ,
        .WIDTH              (WIDTH              )
    )
    sync_r2w_instance(
        .wr_clk             (wr_clk             )       ,
        .rst_n              (rst_n              )       ,
        .rd_pointer         (rd_pointer         )       ,
        .sync_rd_pointer    (sync_rd_pointer    )
    );

    sync_w2r#(
        .DEPTH              (DEPTH              )       ,
        .WIDTH              (WIDTH              )
    )
    sync_w2r_instance(
        .rd_clk             (rd_clk             )       ,
        .rst_n              (rst_n              )       ,
        .wr_pointer         (wr_pointer         )       ,
        .sync_wr_pointer    (sync_wr_pointer    )
    );
endmodule

module read_ptr_empty#(
    parameter                   DEPTH = 16              ,
    parameter                   WIDTH = 8
)(
    input                       rd_clk                  ,
    input                       rst_n                   ,

    input                               rd_en           ,
    output reg [$clog2(DEPTH) : 0]      rd_addr         ,
    
    input [$clog2(DEPTH) : 0]           sync_wr_pointer ,
    output reg [$clog2(DEPTH) : 0]      rd_pointer      ,
    output                              rd_empty
    );

    assign rd_empty = (rd_pointer == sync_wr_pointer);

    always@(posedge rd_clk or negedge rst_n)begin
        if(!rst_n)
            rd_addr <= 'd0;
        else if(!rd_empty & rd_en)
            rd_addr <= rd_addr + 1'b1;
        else
            rd_addr <= rd_addr;
    end

    always@(*)begin
        rd_pointer <= rd_addr ^ (rd_addr >> 1);
    end
endmodule


module write_ptr_full#(
    parameter                       DEPTH = 16          ,
    parameter                       WIDTH = 8
)(
    input                           wr_clk              ,
    input                           rst_n               ,
    input                           wr_en               ,
    output reg[$clog2(DEPTH) : 0]   wr_addr             ,

    input [$clog2(DEPTH) : 0]       sync_rd_pointer     ,
    output reg [$clog2(DEPTH) : 0]  wr_pointer          ,
    output                          wr_full
    );

    //产生full, 最高位和次高位不同而其他位均相同则判断为full
    assign wr_full = (wr_pointer == {~sync_rd_pointer[$clog2(DEPTH) : $clog2(DEPTH) - 1] , sync_rd_pointer[$clog2(DEPTH) - 2 : 0]});

    always@(posedge wr_clk or negedge rst_n)begin
        if(!rst_n)
            wr_addr <= 0;
        else if(!wr_full & wr_en)
            wr_addr <= wr_addr + 1'b1;
        else
            wr_addr <= wr_addr;
    end

    always@(*)begin
        wr_pointer <= wr_addr ^ (wr_addr >> 1);
    end
endmodule

module sync_r2w#(
    parameter                       DEPTH = 16      ,
    parameter                       WIDTH = 8
)(
    input                           wr_clk          ,
    input                           rst_n           ,
    input [$clog2(DEPTH) : 0]       rd_pointer      ,

    output reg [$clog2(DEPTH) : 0]  sync_rd_pointer
    );

    reg [$clog2(DEPTH) : 0]rd_pointer_d;

    always@(posedge wr_clk or negedge rst_n)begin
        if(!rst_n)begin
            rd_pointer_d <= 'd0;
            sync_rd_pointer <= rd_pointer_d;
        end
        else begin
            rd_pointer_d <= rd_pointer;
            sync_rd_pointer <= rd_pointer_d;
        end
    end
endmodule

module sync_w2r#(
    parameter                       DEPTH = 16          ,
    parameter                       WIDTH = 8
)(
    input                           rd_clk              ,
    input                           rst_n               ,
    input [$clog2(DEPTH) : 0]       wr_pointer          ,
    output reg [$clog2(DEPTH) : 0]  sync_wr_pointer
    );

    reg [$clog2(DEPTH) : 0]wr_pointer_d;

    always@(posedge rd_clk or negedge rst_n)begin
        if(!rst_n)begin
            wr_pointer_d <= 'd0;
            sync_wr_pointer <= 'd0;
        end
        else begin
            wr_pointer_d <= wr_pointer;
            sync_wr_pointer <= wr_pointer_d;
        end
    end
endmodule





