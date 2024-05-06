module dual_port_ram#(
        parameter WIDTH       =   144     ,
        parameter DEPTH       =   12
)(
    input                           sys_rst_n       ,
    input                           wr_clk          ,
    input                           wr_en           ,
    input [WIDTH - 1 : 0]           wr_data         ,
    input [$clog2(DEPTH) - 1: 0]    wr_addr         ,

    input                           rd_clk          ,
    input                           rd_en           ,
    output [WIDTH - 1 : 0]          rd_data         ,
    input [$clog2(DEPTH) - 1: 0]    rd_addr 
);

    reg [WIDTH - 1 : 0]         ram [DEPTH - 1 : 0] ;

    integer i;

    always@(posedge wr_clk or negedge sys_rst_n)begin
        if(!sys_rst_n)begin
            for(i = 0 ; i < DEPTH ; i = i + 1)
                ram[i] <= 'd0;
        end
        else if(wr_en)
            ram[wr_addr] <= wr_data;
        else
            ram[wr_addr] <= ram[wr_addr];
    end

    assign rd_data = ram[rd_addr];                    //FWFT式FIFO
endmodule
