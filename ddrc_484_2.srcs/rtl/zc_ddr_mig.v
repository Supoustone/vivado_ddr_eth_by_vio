module zc_ddr_mig(

    input           clkin_100m              ,
    input           clkin_400m              ,
    input           clkin_200m              ,
    input           clkin_400m_shift_90     ,
    input           sys_rst_n               ,

    input [15:0]    inport_wr_i             ,            
    input           inport_rd_i             ,                
    input [31:0]    inport_addr_i           ,              
    input [127:0]   inport_wr_data_i        ,              
    output          inport_accept_o         ,              
    output          inport_ack_o            ,              
    output [127:0]  inport_rd_data_o        ,             
    output          inport_rd_data_vld_o    ,

    output          mc_init_done            ,

    output          ddr3_ck_p               ,         
    output          ddr3_ck_n               ,             
    output          ddr3_cke                ,             
    output          ddr3_reset_n            ,          
    output          ddr3_ras_n              ,           
    output          ddr3_cas_n              ,           
    output          ddr3_we_n               ,            
    output          ddr3_cs_n               ,            
    output [2:0]    ddr3_ba                 ,             
    output [13:0]   ddr3_addr               ,            
    output          ddr3_odt                ,            
    output [1:0]    ddr3_dm                 ,             
    inout [1:0]     ddr3_dqs_p              ,       
    inout [1:0]     ddr3_dqs_n              ,           
    inout [15:0]    ddr3_dq                      
);

    wire [13:0]     dfi_address             ;
    wire [2:0]      dfi_bank                ;
    wire            dfi_cas_n               ;
    wire            dfi_cke                 ;
    wire            dfi_cs_n                ;
    wire            dfi_odt                 ;
    wire            dfi_ras_n               ;
    wire            dfi_reset_n             ;
    wire            dfi_we_n                ;
    wire [31:0]     dfi_wrdata              ;
    wire            dfi_wrdata_en           ;
    wire [3:0]      dfi_wrdata_mask         ;
    wire            dfi_rddata_en           ;
    wire [31:0]     dfi_rddata              ;
    wire            dfi_rddata_valid        ;
    wire [3:0]      dfi_rddata_dnv          ;   

    zc_ddr3_core#(
        .DDR_MHZ              ( 100                     ),
        .DFI_WRITE_LATENCY    ( 4                       ),
        .DFI_READ_LATENCY     ( 4                       ),
        .DDR_COL_WIDTH        ( 10                      ),
        .DDR_ROW_WIDTH        ( 14                      ),
        .DDR_BRC_MODE         ( "BRC"                   )
    )u_zc_ddr3_core(
        .sys_clk              ( clkin_100m              ),
        .sys_rst_n            ( sys_rst_n               ),
        .phy_init_done        ( phy_init_done           ),
        .mc_init_done         ( mc_init_done            ),
        .inport_wr_i          ( inport_wr_i             ),
        .inport_rd_i          ( inport_rd_i             ),
        .inport_addr_i        ( inport_addr_i           ),
        .inport_wr_data_i     ( inport_wr_data_i        ),
        .inport_accept_o      ( inport_accept_o         ),
        .inport_ack_o         ( inport_ack_o            ),
        .inport_rd_data_o     ( inport_rd_data_o        ),
        .inport_rd_data_vld_o ( inport_rd_data_vld_o    ),
        .dfi_address_o        ( dfi_address             ),
        .dfi_bank_o           ( dfi_bank                ),
        .dfi_cas_n_o          ( dfi_cas_n               ),
        .dfi_cke_o            ( dfi_cke                 ),
        .dfi_cs_n_o           ( dfi_cs_n                ),
        .dfi_odt_o            ( dfi_odt                 ),
        .dfi_ras_n_o          ( dfi_ras_n               ),
        .dfi_reset_n_o        ( dfi_reset_n             ),
        .dfi_we_n_o           ( dfi_we_n                ),
        .dfi_wrdata_o         ( dfi_wrdata              ),
        .dfi_wrdata_en_o      ( dfi_wrdata_en           ),
        .dfi_wrdata_mask_o    ( dfi_wrdata_mask         ),
        .dfi_rddata_en_o      ( dfi_rddata_en           ),
        .dfi_rddata_i         ( dfi_rddata              ),
        .dfi_rddata_valid_i   ( dfi_rddata_valid        ),
        .dfi_rddata_dnv_i     ( dfi_rddata_dnv          )
    );

    zc_ddr3_phy#(
        .DQS_TAP_DELAY_INIT    ( 27 ),
        .DQ_TAP_DELAY_INIT     ( 0  ),
        .TPHY_RDLAT            ( 5  )

    )u_zc_ddr3_phy(
        .clkin_100m            ( clkin_100m             ),
        .clkin_400m            ( clkin_400m             ),
        .clkin_400m_shift_90   ( clkin_400m_shift_90    ),
        .clkin_200m_ref        ( clkin_200m             ),
        .rst_i                 ( ~sys_rst_n             ),

        .dfi_address_i         ( dfi_address            ),
        .dfi_bank_i            ( dfi_bank               ),
        .dfi_cas_n_i           ( dfi_cas_n              ),
        .dfi_cke_i             ( dfi_cke                ),
        .dfi_cs_n_i            ( dfi_cs_n               ),
        .dfi_odt_i             ( dfi_odt                ),
        .dfi_ras_n_i           ( dfi_ras_n              ),
        .dfi_reset_n_i         ( dfi_reset_n            ),
        .dfi_we_n_i            ( dfi_we_n               ),
        .dfi_wrdata_i          ( dfi_wrdata             ),
        .dfi_wrdata_en_i       ( dfi_wrdata_en          ),
        .dfi_wrdata_mask_i     ( dfi_wrdata_mask        ),
        .dfi_rddata_en_i       ( dfi_rddata_en          ),
        .dfi_rddata_o          ( dfi_rddata             ),
        .dfi_rddata_valid_o    ( dfi_rddata_valid       ),
        .dfi_rddata_dnv_o      ( dfi_rddata_dnv         ),
        .ddr3_ck_p_o           ( ddr3_ck_p              ),
        .ddr3_ck_n_o           ( ddr3_ck_n              ),
        .ddr3_cke_o            ( ddr3_cke               ),
        .ddr3_reset_n_o        ( ddr3_reset_n           ),
        .ddr3_ras_n_o          ( ddr3_ras_n             ),
        .ddr3_cas_n_o          ( ddr3_cas_n             ),
        .ddr3_we_n_o           ( ddr3_we_n              ),
        .ddr3_cs_n_o           ( ddr3_cs_n              ),
        .ddr3_ba_o             ( ddr3_ba                ),
        .ddr3_addr_o           ( ddr3_addr              ),
        .ddr3_odt_o            ( ddr3_odt               ),
        .ddr3_dm_o             ( ddr3_dm                ),
        .ddr3_dqs_p_io         ( ddr3_dqs_p             ),
        .ddr3_dqs_n_io         ( ddr3_dqs_n             ),
        .ddr3_dq_io            ( ddr3_dq                )
    );

    vio_phy_init_done u_vio_phy_init_done (
        .clk                    (clkin_100m             ),                  // input wire clk
        .probe_out0             (phy_init_done          )                   // output wire [0 : 0] probe_out0
    );
endmodule