// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon May  6 17:37:50 2024
// Host        : else running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/software_download_zc/Vivado/vivado_my_projects_2/IC/vivado_ddrc_484_2_ddr_eth/ddrc_484_2.srcs/sources_1/ip/shift_ram_IP/shift_ram_IP_sim_netlist.v
// Design      : shift_ram_IP
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "shift_ram_IP,c_shift_ram_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module shift_ram_IP
   (A,
    D,
    CLK,
    Q);
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [5:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 d_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME d_intf, LAYERED_METADATA undef" *) input [7:0]D;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF q_intf:sinit_intf:sset_intf:d_intf:a_intf, ASSOCIATED_RESET SCLR, ASSOCIATED_CLKEN CE, FREQ_HZ 100000000, PHASE 0.000, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 q_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME q_intf, LAYERED_METADATA undef" *) output [7:0]Q;

  wire [5:0]A;
  wire CLK;
  wire [7:0]D;
  wire [7:0]Q;

  (* c_addr_width = "6" *) 
  (* c_ainit_val = "00000000" *) 
  (* c_default_data = "00000000" *) 
  (* c_depth = "36" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "1" *) 
  (* c_has_ce = "0" *) 
  (* c_has_sclr = "0" *) 
  (* c_has_sinit = "0" *) 
  (* c_has_sset = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "0" *) 
  (* c_shift_type = "1" *) 
  (* c_sinit_val = "00000000" *) 
  (* c_sync_enable = "0" *) 
  (* c_sync_priority = "1" *) 
  (* c_verbosity = "0" *) 
  (* c_width = "8" *) 
  (* c_xdevicefamily = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  shift_ram_IP_c_shift_ram_v12_0_12 U0
       (.A(A),
        .CE(1'b1),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule

(* C_ADDR_WIDTH = "6" *) (* C_AINIT_VAL = "00000000" *) (* C_DEFAULT_DATA = "00000000" *) 
(* C_DEPTH = "36" *) (* C_ELABORATION_DIR = "./" *) (* C_HAS_A = "1" *) 
(* C_HAS_CE = "0" *) (* C_HAS_SCLR = "0" *) (* C_HAS_SINIT = "0" *) 
(* C_HAS_SSET = "0" *) (* C_MEM_INIT_FILE = "no_coe_file_loaded" *) (* C_OPT_GOAL = "0" *) 
(* C_PARSER_TYPE = "0" *) (* C_READ_MIF = "0" *) (* C_REG_LAST_BIT = "0" *) 
(* C_SHIFT_TYPE = "1" *) (* C_SINIT_VAL = "00000000" *) (* C_SYNC_ENABLE = "0" *) 
(* C_SYNC_PRIORITY = "1" *) (* C_VERBOSITY = "0" *) (* C_WIDTH = "8" *) 
(* C_XDEVICEFAMILY = "artix7" *) (* ORIG_REF_NAME = "c_shift_ram_v12_0_12" *) (* downgradeipidentifiedwarnings = "yes" *) 
module shift_ram_IP_c_shift_ram_v12_0_12
   (A,
    D,
    CLK,
    CE,
    SCLR,
    SSET,
    SINIT,
    Q);
  input [5:0]A;
  input [7:0]D;
  input CLK;
  input CE;
  input SCLR;
  input SSET;
  input SINIT;
  output [7:0]Q;

  wire [5:0]A;
  wire CLK;
  wire [7:0]D;
  wire [7:0]Q;

  (* c_addr_width = "6" *) 
  (* c_ainit_val = "00000000" *) 
  (* c_default_data = "00000000" *) 
  (* c_depth = "36" *) 
  (* c_elaboration_dir = "./" *) 
  (* c_has_a = "1" *) 
  (* c_has_ce = "0" *) 
  (* c_has_sclr = "0" *) 
  (* c_has_sinit = "0" *) 
  (* c_has_sset = "0" *) 
  (* c_mem_init_file = "no_coe_file_loaded" *) 
  (* c_opt_goal = "0" *) 
  (* c_parser_type = "0" *) 
  (* c_read_mif = "0" *) 
  (* c_reg_last_bit = "0" *) 
  (* c_shift_type = "1" *) 
  (* c_sinit_val = "00000000" *) 
  (* c_sync_enable = "0" *) 
  (* c_sync_priority = "1" *) 
  (* c_verbosity = "0" *) 
  (* c_width = "8" *) 
  (* c_xdevicefamily = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  shift_ram_IP_c_shift_ram_v12_0_12_viv i_synth
       (.A(A),
        .CE(1'b0),
        .CLK(CLK),
        .D(D),
        .Q(Q),
        .SCLR(1'b0),
        .SINIT(1'b0),
        .SSET(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2015"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
R80NnScBgIZD14acGTeYZyZzlDoMDRJH97QvrM1z3/BPxjYOI5xO+RmLRE3ogivikKxeQqDB3hYo
CtT6MXJE8w==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
pzFf5UkhQCihEthT9/vXIu9qyyEco3ugn72RSG7p68vod9TXq7nS9azLrnGkzXHs3PQFBkq+3+ZG
PNN41vDN58/lK8pIjiAlp2V0xXr8ZRf/QoS3nU9pnZ3CEwxt9CGwUMks2MBnm+VSjWWRxbkUaTxZ
+kjzVWvQpUuyFFsOEs8=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
xDcafb3KrEW7vk1Eyiww/9CKbzlKF9C0uKrVBz5bHy5+6GMNsnwfCSkgxU14+VriR3jhdDN7viwB
M3a2pKPouTEOz066rknyw5X/sQ4hniBD3iUl4NQWkHTGym3kv31ZUeZYdl5ODPvzfUJOWUvkAXp/
gf4rtgV5FBbGm8qJS4jxuFSsv4rhcb7t+cae5sULvX9h7Uh0lEoAlNX3YmEW0fWj4bhIgTdzT2gk
C1ytdGU/UAnitwmujc/k+32KWV0i/o3dHRhIc31iawLLSmuBJYefDEaLG6KE8nGHeuho45Se0dhe
7kIaZp4SW1wGf7C0xxqwh1cgZ7+6eWgYBqVY1g==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
OrzITnToGC+ryHZVkpDHCj6CgE4vEVrPZ7Z829783FsE2zjugDCdpipuFZ7ikbeX4Bc52TEJ4mFm
0OxylPcCXPIE74pJ186gBXkmldW4bGFMhTmUHJ94bRAsyJjr329fm+j77y2NmfbHMVOsljahWWK4
OMppytgOrZcnsnsORsbXvvikZALiCB2t+Qc4RdHc3/98o+DDvRf+gwTZNX0GMOitJmVVvqxqw6No
K3aHL26WS+5291/TUz7aF7ySSp+k84h+0omwPrcy0Xc3URWaoYbqLrWiEi22RgQYitI1tEsa+afh
tv3h9WNr+65gWTbdbwWyOz1NeXJSaNV/mc+/Lg==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2017_05", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
riYGAyaVfIXieMgcJVFsucQ9kUNBkyzgx5CLlDibSmqSJjCaDvK63ymwoZpsGDT9Rugub8H1Y8xX
XUpLlzZGCXrlWs6NgjXfNxVpLlkmz7GswYkQ6KhUkZhRuPh0HrpJPt1ne+1pTM6fzi5LXsyTv6sn
TisWpJPdsnmBDHgM6jupb4Iv3OG7/q/NPck9K59oFLN+AyKeQ/8pEy2j7xpMiFTRlE1OTJj2mjHF
yWQWyURMafr1KK5t9Wu7YuocfKiTo0f6okHNafEo/nNpObW1D/liUJlS5GVguNNbnFjSuun9SM4T
MXhUoU0rVPqSkeCGnTpMMYK0MY5IwmbyZXn/fQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
HyAIbEI1uxEAA90t6+VWFTmyUje1JDZQZoMv6A5VyFWA8tJ80b/Pwhc93aHby8xZos0WjlEANrxF
3hJ/l8XJYMVZWlVytBIRAZYGbhnMBOGo/5sjE6O2Ap0308iwfA50rb1ZITdKRqNiW+PlWkaGC+3R
QMUfNUa7cSm841V7mmc=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GUEL70ZQ78wO25wq2V+5JNZcUKzj485nYHAlIxulC+dFYZ1T3bS7X0juNGn/cdIyRbeWgA5z1viA
KyiSR064Z0BmWFsIYHfLEP1CENE6B/DkEgUM//4pBnGxH0CUe8wWHQBcyJQAxQHemECYQ5/QfTqT
96OTv0jwZ8yRjX1vKXS1qZKREGwNAsV3Kgrd9M5oaNz3PuISlyOOLoxPx9Qvu0Z0QYAzZbksLAI6
oekHTbR7CXs/P7+GCnbyf0lD6RFUyKASz8PAAvPi/+knG0A5BGQv9W8rEQ1GlCyJMbWqS7UMYIM5
Aany0Gd6zUtHqzCJMTpR0Gv6o8IS9bMCD8CICQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
AHvhzJLPy1ke21W2Pr/PelqocUXnF0wgkUZZcya64nxCYbRW3WQ9r9N8kISzWZUbTLcu7p/68XAG
tqSbqybrtZiSPsbEubKjdRBE0Fgu4DpkIE5ANttgxr9GWWCaM1fKNNziCfUOUbbhdmwVexbDgd8x
YAMWsg1ahaXmfPOBTqV+auPeh6P0K4X2l4DZ1k9E0/j5bTRhA9Idr3GjY19BYqfycBHyS4Fls+Bn
IH65mXhWgxhgLmyzcZEF/WwHtv66wLaGrQCVy1s3b3V50RSo5bXqnMsIfHw2kFadZojrhUGgsKJb
gwKATW8oky24cXAJHq8IFXNZLmxsEZYA/FjUcQ==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
H2qFWfSl8pOoRJOuoWOi509UdZRNlfCGtunNfW/xJmZgkhcn4jr5h3lbY+6FYLrVt6rbY7dpeDmT
PjApKJ5TxTF38C/fJFfo2KEh7ehbmqFUgujwTUmmIeBwy+XCk5+8yL0RNEP8p1iP5DQBfMM7OhbY
FoDhZqlHIf11kWHTBMnK3GE66zdG4mYTBloPPd+SEH+C97CGLlGNNYy3mVnPmJ/amNYREvBzQE4x
oM8PqUlGD1472toz14Q+rSUdfiGNrmR+XcK3bBsm7x3XzDeAlbanPxzn61uPBo5S1J3oD27oRbBh
FWrVofAgrddF9rqfMUAiZZQ+5P/Qkis97hGlXg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 16320)
`pragma protect data_block
NKBjj5jOZ7vX5paIfrSXN6IuxhTznRC1WPjeniBXkJJ36fYAENimbcxMT5vvhUi9YLyFDTL4k6eU
DuiyS2XrYmPY40PwgA9rvJzt2o00AG2rGVJ0uLZoqeNGeaEWJXIQPz4kz8t9xdRzGGvIBN0/Ad13
2MgiAtjiFQM46YtTALLJb5dNgSOlcjiiEkSrTjscppqoGLj12Ot0vVmoHkFYeUvphU9F0rR0tF3H
oiwVTa3CkJPy3O3o5pGSb9fvyqLRWIBEDBk4FYTtIX1LgMd1BVDiAw5gea5J+/bKuaHN8xiGDxtQ
0cv6/QW96vXJ2/8X/zqmNDOC1YqP+ZVlxGHkjQ29XimwHzPwpfIykpUrExS8W7D54HNWgYWskvkt
Xye3scdpr5JGfF4I7qk6+Pj2Ml8dm2OnbTx55w1kFPtLw8C7B1qbYptqE7tD9FsBZKuUHLycImRT
VCquwq2CM54yobg3tHaeMX3ZJRhzD6tc446TEuhmB9WBqpkjLFcZAbGGyi13SeLoobV3qMWUhHt0
ZiBuZUtMKWSOgYqsUwoDAN+h/mdJ3mkujwxQ1W2qlAXvCl6oRw99Z9xel9zri9ooDn0eh8ggNUHL
BWozAeXVDI/+igM9mHjqRpd8vZIOJEiAOmZq6DYI4QM06SMLA7QHCne7tgngUyuWm06iZubOxROn
CBuWX+QqQVt4WQUkk/oZGEVp9Dtf0G5PGW5Iw0JUKyg1bkSjvXhLQSS7oT+fFpHWxnpkG5X7RrVm
oznEfJcnf8QJb+kiy16kRuudsv7p9pFgm/0MxqQn6ObnYVsuWXs9GQhJsDg3tIz6EeyxFUuKxbYk
t6glk2BvghmUXkiL196qp/ttBMqF70xtKFJYx3spjv9YIhUUadfle2X0rshh+z9cRZuP338G6Brb
LVq2pPnDJkAlmb9IONIxduMY1d/NcGWBR0041FzPBw8ZzODk6yq4WNapk9CdGyY+WNo+CtmXswfm
cGx7yegYrWBsce/Alf5L/pLBKlUF+Udzb2CQ02yNqaFBdlsF4ywzoengvrZMjhd9BK0AzPymU16R
x7GrWH1dubMou1PX8NBgqJP0B+iC3/S9vYyTi4xP+2KsY9LfIe9zooc73sNlEOreu57lKeWatNqn
NZny7Uoal2dA0EJtdBO5tGlVrmyi/dSxjOjUpTz/LAPrqBRR/WHUm4Ushh+UH8IJpqBMrCL+qJTx
DplschdtQ5/nMuUW6ZcAEWzSncDy16w5beZWsCZpBwn7xER3QnOay3qr645Vr3rI8Xfsivb2vVjZ
avT+17yAIQ+1mNwtsGo2/SnL4vNm4/z4KLTsEwpCXOHN7VUi6oQd4hKHnyHVWGbL6rOh9jKlCvSk
uIcxCcp0HX0W87GDRbP/3KklwTiiJ1nAJvWZgzWmDESoadEZqfwc+SKksV0ET7sr/LPZ+LlUQ/8w
d6F7LXXGEj6FGgj8eS0e6ScoXe5h23IgtNo44xPdGuEw/EQ2m08aikIVAjQe5PaUFtt8hqW1w7/G
fW9NF3WgMMXsxcByB2t1jBLIQTKODP+YSp5BmsWyEMJ51fMBE0/hr2vKMdSoO/82S67ltCV99fac
zVSiPZepn/gg3Re6P3DR19igpYVcf7PBiOlSvp8hptyDIHst0xIcIgRKjmBvGRivAl7CfrSbxg9q
hO3su9U92liLvdsWTWJkX8DnPMeHCWQ9t3OKdtXxOtbiOQXjnrHEmlf8G96oKhRhxyMu4d30oUvv
HBMC1EzFyt6aEFuJF7OmNXYWcOREEktTpnI9v7NXUZbyVJFf2cZkTydxfP3uRyklH+7I2HDP2pFg
uJqigsOeB4MvAXlMTzc/uUsYTKUT9K8iG8ofkP8a0bUNmHlKzM+TRklA0zyB6IMMO5+nhkcHBUIC
sCumtg57TKCw91NC2YEbx4pNI6gcp+z9S4Ichjzrhxcxv2xzlfkEqCZDgBYn3OTfCU400Yh1eZIj
eUD5Z7jAyVzvrG0D3rGYePmsHE1YOFT0ILm9gGmrdhlEdRI4oYQypLovKU62ISBMp7xvQGV9WlGs
aEw3fvYyzXYNIcVBsdRTBs7Pwt74bGZUkZCmpeeGpr859xnwUkxLYbU8G1wxFbTxB+xZX0nmvUBB
CG3N8YVAhtKXwv4c8Ar7lkDQXPI7oTpIKC4S0BIxo395YsSGGIWAfbJtXMSlhJkJB8zmyToBH7V7
S67vWsYRmnBf5DJGIGnQTeGXYs8VX6bmkuXK18O6MsHkL65NVWCsb8avme4WjfNJMnB5jnXYFJgA
+9hYYU5Pgfyx2R7h/EpsM/d/QKc+ChOkEBqVFsHAkux0i2HnbEbUoZucIu+TIOCwer6Q2uikNI8H
KsJmMBI80cE1xgC2kiYKJJhDGI8CMGXnSD9ZfJUAGGVctY+ROBdVBL8ux/wQQp74eGOuwb01vUyK
PsCbF2sW4jbWhXzBoii54SBGnqjwie75WC3NmxOtKM/n7lJjHFgdghAxd0E1TH/kg0luYd5GDD+z
eHDpI3gFYkjDFBnvRXUoxGHx8DYSn3eiUAQj7idhneee3tmb5kgNGS4GUKPa2V6T82RPyXmk7209
6Gzf1NZmMKLaR+rOSLeXBura4NDaX69tYf+wgiceFcFLrfYc8Ld3nAMRh5caA+P9EhaUq2XgYgta
kpDk3PPzhEKFvb47YXhZurYmibXrvm9WFnwRmbH+X0wNfV0SmOyBMjiikL+2nrlyWqOunDa+Ev8q
B1DxkWC/4j2aWK5sleF2FVOk0XCQbVC5QDHYvYM/hb2R5SMUnrWPWdwch0IVSGgjsTRt2lWMiXts
SreV6EvhM4HtxtO8//4KXkBSFLXGQJET6Fu1n4aYYqz5J7Kr1+gof+rY0NSoK+gEDMQew5QVKStS
XmpGVwa0Tzd4HfJDCkvofRPOSpGoEKXL8jsHS30wrePZU7t+FLoVSC/TkAz2ToxsGgvtSLMi/vqR
v6hKgoaVjtHIRdaLncLcPWj1h9Z4gREPwzSIaNcfn5k7T3Uii5q11Rhw/vx+eDXZ3iC0voobwYcd
eS3B/cQYvu57/lvG/6ktO56jkbsOmvM3TE1p0qGnn5baODDxCQxcIo28t33wvDbcKiqKTKhsUh3m
roK0cAaA7sIS5fIYx51fdqQ11FQJKfOvbsPjouP+LuSzDyNjNXI56wxO4q/BcXyB8/eAgUk7FzYr
e+Zm/3Wf6Yrc9OhkePCX0E5Rbe6nrry0kGBL944CQ+k6zUdYgfyB0ilBSmp8g4Ipwy+6JlGdukNr
oOVj/gN3AAkkBnXUkoQcrC1AP9EfMuS8LHfcG3iRepC0ReMPxGOJfd2YIpysBVXFJKx6yFgPsN7F
LMfBx2eK2DLOiU1TPtXUCdge9Kuhk1oLdCLCNAW1TrfyUe8HqBCidEaf8MZHWoetLbepl/nT8xlc
yTJyaO0L7JKkf547sP/OQXqu52pUYPFZOz2GqT9g1ggZn6ZSKu+sWnWij3XpwvEqVx5b9HHx9ULk
XRpAKlAwA5g7GBN3mvB/vRNpaPq93NjgnZGEUTfpXRyQkjZT57itXRlLL4WxHN9HzrcM3HDRnZ0l
GJo5W+r0+VNYsOB1RpYkkdkBvS9DFueaqzyuKsVmJATRkXii+0/3hzz8cG0ngqGoL6vyWR3ckp0j
SzRQKgTQtex0Ynq5le9TulTgFiPo+QiKdFxxSjUk5hE9ym5+4AxkPsir7EPReHvvvBcYK+qNovgu
iukK0eEnEwXRA7wiEbveA1ZxBt5f6KAWDx3iROAs6LoTn4fH6AySXUFNX+GEFu6X/Vl7vko86zFX
jDfuy7GDZnpudF/96mRo6nspOYqwpdYHRwoz86CW8HyUw1uyjI9G2YudcS2fD4B2UXUBPrzABxba
uUvkJgQqp8nEp+WZfsVd2cGekWGkioIeAkPQt65zArh6Rf6ErGkBgxU/I54WTGMOOedFfY9qdLzu
gNsfKsot32XpbRHwev29jhH5kGee6D5t1lqn1cZovz9yQpi6MO0wLXFAukrB42FS9BAGdyRXZsZ9
eTsmdDn0D/bmL90nPC4S/jr10BZIZXoT7atm/KlvArlU5672SBWH5f5ByVboxmwlnMPRNbHL2Uu9
QcI1qiczmGvgcZfIAueF3I4uiXb1Jnp1D18Tv6OBdH9Hf55vDi1IqnH1tQRABIxlqHHzs5odpRyU
rECSSY9okO2KlrRXh4IFwC+MALzgRT9hEXg0awidiBP8rfUzssKXB6SFceJrgcxA9CivjcgJ1hdi
06eQQbgem/s2JZ17iyRYBQdPhimF9g8KMzAatuJbE5NgMaZg76p9PTVugXCjqhAZrWPuIsP+XBe1
//XojOgUWgQNhlX3uqazGLuX2hKbOYeoutNzAgXeoEhFPMyoZmr3TmR6LWRH0moYYWsNgOBPtAX9
/dBg6AVDTo85jVlbGprmOpuDyrj87qVAXxMbFT1XUIzDIpy5EC7I+Ml+HE4QgW8TIVyjxSATp+rP
s0hbs2ews2GyXUn/F3xCHHXmJc1+bTjpZ//7g/Bo528zeAr4yF4Yt4cFaKlLtkIgUEFXe5GSauSY
y7MoFKo0yP3re45k0b7SvTlV5jZhTNfK4VogsT2j1lPue24Slpn1iMllUXWeBA5ulvqhbbG1zE12
v1rNCbuWJu190LvysWJhcairfdE2yBOjIfMsL0e9JcZxGmMTgjMSFOFqa/8xFlsnUnwDi6JqslLc
Ca2qUsof+n8HvT9R+LIgOKhpCAYGjGe/G84SzXHari8MHs1noovypok0MOmQqePdoIUChz+bMlA9
A35zFtXgYmvEWLZ2VWHpBFa0CpvUhARZuWK4tzClYn+1SWunVFNJAxXF9yZY+oNfP5OP2laPXytn
E/9lHqwVjmsKpKKwYlmnW8TU8hhT17hCvg+xtYokfBLy1uBXQvTEfelfE6qNWzGc6XRL0EtlH4Zy
E/izUo+dPgCQA/HRM35CXq/9IOnLLwNgzuyWtEnNQAHbAMriikebhFs87ihJvGKz7U4N5+09kT1+
utSNStukOeSAbTPRQqT/afByPoUOJm+HhDg+H+YTncnOhuMkxSm++KHcHttIsctJbhKmDEP9scwo
ZR0sRT5qstKRku71hD4v6Lqpp2N5inVd5zJtEbxA7zE14+CdaRI/jIIt9Y7Og5r+jYALO1D43D/j
rozTrhNZS4kkFXrXNew4dsQiXis3NkoT+mAY71npyOaxrBcbD8BCg67nmITXuwOctDgfqthtnqw5
/8TWls6Azh1bqPy12JWlmyEgKe7PJccgYVYp/3QOqzhaD6pe7aeUuu0kNByiG3i1Uaqy+7uKRo2z
3SakDFxQ8699nYXHQ+IW9p66eL+GA7nCtnym5cRmyMoDpi9TW0z4hO4u/ghlbU4LQu0Qxmx1yD/4
0lvA+WOq6lMcr5rZg3IQC4+DaynHTP3f6ECPBK4ObXoaMtf7R+9BVxVcG1IXtCYpSTaFkqm7sf3L
bfGUYmElJKDlY/0kARcn/JnKoCcGZSQvd3pZQbAPSWqsh5I5fQ804on2XHvbmKx1yCg+6p4wC1tA
6FaQ81Mmtw0xYke1FvdzIgT7+Fjw6VbS4/FIfsREsyb6FmefDcxvFmkb/VFhImMAQOJdX9wD5sNw
wzCnS0pzEPgJl7wPGwGBX7vlTRf9X2NTdkbvzEnemiH0wSF/WOtDkasCEodCzjG0+IOCV0fvrGVO
cxIdafj/ayRpF7eGIfWjnlaC7xD1/F7mvNEJ/NPFtkEzICopCVzvsnFPRVzW5WYjNIb363IZAyKF
lyhRZMSELz4+sPV+Iixgo3yMOhvbWW9GGqGOzv5uer+QS1z+e71OMN2n3WjAxQruO56bbA/DM7sR
jmgshfdTcuR6CoJBYdker58j6AvCatZR3hFcd3CUNhy5kXKWLd+XJpe7xwWv8GpGnWz2kGoYZjop
UKkj0HqcqJC29ruTfkmq1rcoyUJN4+f+yxAN9K9vSNdrtpg0YqnkwF++glW9lDm9Letq24rSfjqZ
zIC/z8M+0gtK3xbqoFsVeWjNdmVO3cJZOiJoyd2GlnlfXKY0W5aFi5jnmc9hPHsaGIlLXUocBKdV
4MS1NI5PhzOlbM2Kcu/HaSPHADGD+wuCxXbsjELhlRGozmx8Wvca6tQKXmExmbbD2mJ8hZbP0pGo
Q4RdmVTZ4UG7GhRCihGsfRAuMejEtLeh1MqakWA3LCgT5yKfKXByc6wG2xuhQxsqOBwKp4zOG4AK
l/u0mJ1LrtZpru2+eEQm/So41udJPqHBvFlL7kZenSmB7H08rmmlFU5BfCt+nxK7DMQpV4/lelMI
9df1RGB9Hn/8/IIlRfbmBK76rSFPrhWABGJnIyIPhJdejG4FNH/7WbB9mFs9f8IgS4iBuxRrkRxD
gsKVWfNqK51JYAg+d3rYzoKUwkdOpoNzrMvtvIKV5/wJDu0eOnqblxHPMUHlgPveG49mqmDFjNdF
aQLp5Jf8cODSDm8XwuNBOccM0UW65C7tX6cvKyPKWODoRK2W14ZJ6D2orKXJQKhIg4rMLgV6BOg3
V5IKRnKCgqB7DLzNhpHf67G0wNuFFr6M3t1/OiBsqZjj49G4/duXi20rAKwaL8HL2gd5eQYyFYff
RNvz0EZkfdfJ/GsTSUbWxOxY+PaA7sNGZ81X+VOwcHlBcI/DGzZmUg8WQmTCgSbuQcDoRM9N7cr1
6MC+Q7DPBYsP0TPeOner+UDNdQF+oEXcQETsTLRuWw/vom28vIzm0anv/cDX4RTvrdj2NMitnUQh
i/EShOuHjWVlKX+dQxnClRjgiTe5QOfIduU3F0c90B7AnzuXX2P+JuFa5PugFmriD8MNbSBB73yM
IusNvfW9n1RU+PzBLguO2EhY0o6E4DEaD8Pq83WJKpf5FkKq0Htib4I8VHyeTgYFpIwsmBD68L2R
A8oCZYYLOmJ2TNEGdcs2QbCwvLzOEQ8ZGU13FU3KmldxAq/u05cwzh1HGcYm5I/OffaJ8KBMU5zI
L9IvU9KcBOgGS1widl/qjLJuC3WggGrebY1V9rjGCogx8yoBgepj+XpsXosVuA3Vr+Wgy3g+TOWG
CUwMODcNPN4mXri+E07XODdkgEJmIEBmYhqXYXlbuRCIGdX8hARLmq53aoFAmlTRq3jc4BCX4hnT
pXQ6B1dFbvxvNhi4WsCFAKlQgQbT+TDU0Td4pOAZFtjXp4DdgcGMIWVzk162FrUvMjTnt9gQh2MY
NbhFSwG2CFU/DUBBVNFCL8JxT+Gp+1KRq4F5R1ZTmaw0ycdpZRX85tCV1KbPu2Cm4adOz89tbTa1
8UIf7CgsZtvV6IOjHbsUoUjQl2Rv6w2MT42ot+bYL2hVXQYsiKYmq/jMzPPG84j5VNiU4NkJgtC9
3P1mtxofQpWsyXwAcxopcdVXgXd34NP3gC8oHVK/ROW4yKwFg94fwzQQtrtSqvRC7OF/vKO2r4N4
xduapAJlzxnN0u/iSL61LeS5X652RWrwVsdLfJLKmr3+JiSrmRlOBsabVvBKXNQI++HpMb3R4R/y
Mq72+E2CRN0quwcWcZcUFyLnGMAjGQRvcVZxDEsknCIz3gmkHXcGNG9stn0zmRv/ycJjXovKt9Ru
BBEa5yWaGnyHKL6E/yeGgrLSBjACOeQscItlmiMfDKYckK3uGPk5uzMQ8YVbq3tc6qm4A0DoXo0d
49n9oyq2xuJASPYP8DTlntMGZKHy8lZ0EtVcMnarJkevXqqSBvcvArk92HQrIFZ0F5LYu9m2f6ew
UVrCjOxCo3AYZIQMFWIVd4gilRjW3Xx5YdwN3yS4s8tH+NrXMvc8ngleZSx5BcE0UKT5tjUmfPp5
rtVcEb+WTohtXv0AA+X1gzJ9vSF7x0g6SuZNzIWF6+ugy1ld4mvrruVuRHZXUcT/G7rbA+fa58mO
H9FINqQp0QSU6mMm+NQEKF2qIAz0hkxKmhcmz8bO1b+CXqfxQgjWG5/UPSN9/ZVyZ/aIKTl0Pmwz
Qc3CEIYrLV6+VRQv4Z1/EzpY0qDtex8+VrtcBcdz6YbAyVwjED3Q6klVZGIhbBIlmbPwsEuUdGFk
v49Mdv+XJVqH2D9SNDBaQQYcS2aIlalHTAb0G2lEQRUvO4XBXZQvjyaOt8Bzgv5eanKuI+lIkFb1
tbhkfuYN4FcEBg58YARZHeoeF2olCO5/9s3fgox0NIOwrmKRt1WVOHWkRS7vdEthqVWw8LzZOKjk
zBO0KnbvImqpgxzbbhgG5r5aJD3Xicuhjwk1CbVymbQCfWBKNp8RgpPLprrjSf4RKO7T4j39Vrkr
EwBpUPHSLWTM9j2yOewT/gHeu4D/DKdY/53xpw7PMB6xvWwLOM2GVJozzYITmjW0FTMyJ6ODtQfD
hAE4YOO/ylK3HAS9Q2f4IpTaxqYm32JXS9nELqdF9Y+MbjO/UasGaswgUDZamKJ2g9qKiez7mF5z
aaQ8bopE6ZpBAJyk0u3kPG83J/3qzENtZkXYeZ5M8o6aIznmerAFbb7w5sijFaROqI8BvzjuOvlo
mi2Oq5iTMhvYjPWZ38wJOr85IIZv50GnNGNNeYcADhECk2+OD0TK/reoExWI+CpPxQaRKEpmm2ba
S8M7lshhyLSiWDOOjzbbVg7eUniil73T7xbJ0cRf+y7fhxYYgt94M8oFTX8PNz04/pjabK77STB0
nNe5l3eHKRhKz/EY3AIf+qge0RI829rTFgUQ1EK49Pzr4JYdPV8Xo1S4S/9z7LQmM42GVATbi+lU
Ez/ZMcUV/NOab18BFBHAQHAg7AH9zNyf4hSYniSvoCO/jwShlwYRCQRxZWG9gNr6YJ1SNfoGjLpI
bU4+WUwrJoVZ2aLTeynPgypNA8dR8t74M4vP7MgVem+DGaTOL2FVj+g9N+g6m3nIS0kGbi2sI5vg
OAk96YcDgfkgdaiPwEj8505BncqWFuw8TPDRONyY7hGQBjrUBU3kWbgTr33M2RQ6UCdZK7xULxt7
tWBjWglt6faZb1jggszjHY/oCxXBzD+ztFgp1hfXBM05oXzIVRkJ4AkijgahjOzOUOqmx4MlDzKd
FK2Wn6v+UD239inAj9zJAiZTxKCUoTFx0qk8Xp8iwTnqMGs0vG3DzBaau4FxqPpRNHKJIM9GmDgX
FEeDqKKMVCZq5uVLenFtSWlZpIJ8X8DsNHVnYNU/bO4EAk0mrG4x7SJ7XVHmoDlWC1c5Aank/Bvf
wfPPI8EWeivgwWYhS4pF8wYfFQ/me4UP4J/TFJ9jORHNJmgIXG3+Aaxx6v/t/lp8IMaNTA025K6r
xLtL9XXEDlGsKJnvHZHqAJrPjTfMQE21m/GX40oK3FWeSEL8vVl8lXFfeA2hGdSfnVhQBhENhFM4
nwPzOdLVBFwYWMZLnUjMvk0WNuWLHzsV6KGmah8AemtEXeqSIvyAhfl8uf1fMR5D2a+td8+OxYY+
ACuuIDsBrKJDJv1S7y3X7BfuGaTPoahPsHWDfDauySHL1O7z995RLsRXHTSYBNpjwau1QJCGhy8V
Y7sK5pbWFgWiuoUNnLrqwLE1Lir7XC4x2j9D9zpXzcFMDhshU/Gm1CIwoKn5Tw25ROgOzVTaB+ja
mNNp9ezVCJr/jvssjQJDemwNQ4wyPmUY9TMgSdPQXt8FHwEBTH5sfCi7imFuohAOP8U9+mfcVgYa
47lPT5Grwg5O3KNMtZmLH4K6SVI0MXOxaehuIfPWnd9e5H2yC0eQ3WZ4qPjp5kGUFXLmF+UiaucE
RtC+kJ1AOb531GW3lCN4wGJlan4yifrDFDNRfmIAy2MZhD5umvDlrXFLXqWt0rQd8uoaOFPDOTEa
BXqZslCDGYAf2NGQ/I6gWHxq/aX/qJ8SpGbQzmYUEzU9LIsJLuwacB3WTT9M+88kIbbFOHp5AwRy
AyveEVZvEjoyoxuH51dxczQ0Cg5mdCLtetVgpbir4np17imTANtFN9KkaXIdWmQdB3rIyh+qAZ7E
/6/vI2843hGoD6J+Bz9jFoASgGg6XrjCclC4N5n5p+p/6lZhqYN8SY5EInNEJ0AVSWfrYVPjl//e
0Cj+Ijbn6rAdsQCr0V4WpKflhHozf9xWiZifPob41an8+mGBXNUkvFq19BBPYWjnRFeBZmZO3jdd
3fD05PQ0hAk2ZfFRin5dd0ioF5yIBDYdoJAKNx1tj7SG3D5g7fWIwTTCnNyYY5fpfD7PGXaUxpaa
CYSlSQL/QeMBtI/s/DzNR99B20R8cD05Dxyue6wsoeyWjhUL5Y+6Wp2mNbEGVgcvXdraryNSBNx9
IBORwuopb0n5MEu6Ch8lhaNDAz7txmqZNkhslcZBj9g/Oa05mjlNTMCmBteyvfDpS6lSJM665ZQ9
8huPNtjCYITIfPBngQk71rCHTXxOEKT3j3tUlHCOUVJxxQTod9TIytrqUsflf3kXLyNNFkfLt2gC
CyuuBZj9pb5esjH7VLdpJ44CarG7eefyszkCtli7yj0Txy2ynetk0sSxMb4i/MVff48/oGTCyRDt
0QHX2X5+mw0BRGw48ZIMaQQLq5k5zSLxg1Pd6J5BdsEys37FMGVBGcE4VgYkjJuSMTox2MRO7YFR
J243kj/N/e+LlF3cJbkYzidM+TRxy47Wdg5YDU+vZav8c8Zwt2plCoIaIm7WJ6VvyEJXzVZNOFje
g0OQL5rqKmoDKtpJMlU50Q0uJYRYBBSVsHtZv8gYegzK2iaJBhsSGp7MZ4eDpq//a7sxnQ08+EIt
N/zsbAW0IBrRQQ2m2j0TeIXxi5ucq2TvwSUCnXWgT7EvJz+lXeQ04dtUuQ/HiXtpVOCp0L226RJJ
tff1WXSsAagllTkdiIuyltyXsOia0WJNIb0y0wsH0DoQ7tnmcdDhorAFHe6QmBNCgmv8TfsYSWIZ
UAgtuNo2olM/AntZJnp1xUS09O4ewQUFI5Gb1UjOhGK1iRtWIzWxaxUewiqLgyoRTnexFoDyPoru
xpbobmbFxPHmjcDmkw5dG1o5zoVMqtLLP6NayhqVMPFPvw5gACqh6FPjQh067XjIemnfFMCEN9hf
kK7CM4is4/Lkzi1oKQhOPNqkAYHm9JhfGPWLdjSNiKH2uFQ1yW95yiA3sqkYQJC4yzvzbLghr5t6
Qb5IEtpf6KFJPThfeBYD/huzpIIPDgbgG76L0xHMO5UmbLJ48D9OL9Xps6UiUxzbOUpE9qcrDIvz
QtFltNEUlH5Ziz4RmZHT1HkHCWEpSBuWG1GtTbc1JZ80uKEJXGw7gg9x1L4lkHmwlvWRNOwSoiAY
7DLmKHv/D7C354cEdsw0/Yr0goQUv4NcdqZuGKA9NgvYnWu3jxk4kDxWBllV4ljT1R8SVPcfk5ei
F01ikIpl9uBRjb66TyN3/5iGaZyDgA0N7gil0rzcJcKy8lVj8o7L6UI91/lR3Kd+ds7MSAzec2l0
Vfw33CUIKuEp9QZJos+JZdjyoZfmHQRpeNFSxvvDjCq4xJLfr2mreHhCu69GNU9x90F8+Ll0KOFC
m1q9S3aw046eS56lXyXkUcxAK1q0hOL4PYhsSyE87g8BEGFuT4+ltfbMMDYEWufz4fEmETp0iMgq
QwFWS6zfG6woCeYTgZlozVsSxZIXP0EFVeha+9O0r9Xt5nXCDMtyA2EsgusCbPBDh5Y6JinDdpKy
hVITvqN1Xiuhr/jYSWfUzh+wf6O53/WvPrhacyOq8iVXFUoBZhpe7BtO+IpHvIiWug3vCT/QyK1X
Xd7T6jQOam74UOVbfxE3l7jXiDa9Zhh7dysz8SYfqy3hffcn1dwPA079ri0cGkGQk3r1T9lKvQk3
LvY9HOH1/8HrDNEiAkzT++GE7dBt3+t+nbNMLeTEmgguMwd7DMJJSNpDKTNj5Ldh4tR3B46cuJk0
cd7AXCbbICISEPPvZguqKP63K8gmbIewL7vSwIkIkKwcYFaIpgXsLCO0qmuAnhz3ksx9tWL56pKx
LKUZTSztrnDqrEgfgFCnO2g47Pj86znuyvSk4G1y0FeXxWhu1hpU+sPmUr6/fyVdn8kgAMYjJneo
Wt8tknLwuY6zQfTVxGqFmjv1esKABYwxjCQ3dPdaQcLqXRAnv8m+sGVdrWncvzdgODOhfr6L/dsZ
IudxdjDkhtLVT4uHJtAn3ecDnQ9aDJcjSQN51bnuQViS1rX0MVf77qC4QLuIzmSY99loBZ/xaxBO
pNoBNnBWyed3dDp0IRWfCcJZ6TePVrW8x0mykkYqq6LMBYXaOUqFeIQr5C4WDXxd6FNZtcPhJTtD
70IVkCQZAisrA+J1NZ3UFUwINJbPNGxHa5+w9kWHU+WdhKmNECVas9VLhK7bcNQNW6utq0vovf7C
+7aJviHbfEKk900xnjjeQfunvQ16Ir0+DdWrwyJPZCMxFzRl6kJ514xPpAF65f9r7Kb158j9BFrX
cDKgiOMkoPucB9XHTsBYFGuRo0/pOi68sYcriRceC+eJcN45z03kK9RRtfnehAEK//uIj2sU3P4w
ZVtcT35/GBHEW1Wnd5GXsOYuX3OqwjTj4UVtx5m6Xcy00GcpysfPGTQDgfK0yg/LezcXtHFXUVa2
6iqbIQeZbXJeEZH0fTzeA9NVqZbNYd8VmahJuehWJf05cvuwe5N6t+FMk6apoajPLT3s2pPx3WZS
8Q8GzWij3A8rXny9vig3p6KTNMsGmRxu02SOMdDszE+WDoFKz3yPkdEZe0Ztb0dTKtZvJzF1m62k
M0YFNasKPKzokgxqR+NhbqN8D2smHlWYaY//ykMDF16Qzag1EHwMjQEj/Fdt72DbKaljXq1DTiR7
D2/TZkB8hJko/QFDHKgEuOyIj3L5KR4K1p3Zo6UWoiib/ZweVGzos6xkVfKYLqaRBx1uPc4ZbHpq
AFeTqnmJsoIN9xEqXuN27PCG8rxgK3/RKkxyVr4aq4pf17RmGTdgMMsJwe8giWBD13Dir1j0liFv
gqcQqtiwGOHKjuHBz1GVYgTU1tQ/2bZYYUAK76G6QUTk1gooWXSS18neVY6h0iyoKtGRW6mGZX/z
GMK1YOmikNy2QMb7yeCT/3QpgagEh8hqx1j3M++5T7fOSaHWioGFDGSJpZYYsTYVFy1gAsB/z9C5
6VleKmbqgVxRdPl1oKrmlVAx0zbNvUs67vf5XCIqs9GCFc6PWcv6dd8sXdjpUSPny7nmGqTZIffk
080e8slysY8yW/DUi39ZysAmsCLvVB3KA+Q31E8qPY+yyx6I9I+YZuzsW4URl6M6z7uoCCPjv+oW
aGqrJvgyeUOp/4kWcImqh/5wKyf5TpktPyneF0oS46aOhBWzS4uloeQPXz8JfbErNKmz/y+G29qE
OZWbUBPKQAOgoETIHRbR1LeaHUJ53MPtCJ78yziXM8zbckpq0+bIkGjXscgy/ENuNlm8ankBbdGQ
blkaH5IQHLwSkcAeM4RGAv/XOFNtsytZpR/jocJ6DontQckaTjBgrBJWkBLPBS6u9q4Yd+58SWeG
wPue7IuFIfXcD3iiPtmOo8lDM+6QNtj8tM7inn9hlRSY53JYUFrDRLxUie9HTipi5/Cu8F06+Y7Q
jGoJyB9MNceaLkHPwGZ8ZWxVpvND9bQFABB3ae490fPSjUTRAxRyxnrWwscTxjCSh5Fqkqen2O/8
CWZye8uVNgT/gFXycAZVoR5E7B+yH7rObQimh2D8RPtjaVzdfkapvjRNbK2HhCjQg+Y2zDQ3N8jD
o6zJkX1/iLAfz3DXj4nkQxh6KpCAnV2I4ALDy8EJwpdRQcZcHVQatxITPvaOn3J3GqlG/tOsXm4V
d32N7WVHDGaaSTK0Q6B1iatrhk051VrkC0Haj4ZtXyLtXYp5/jl+gWjhdrL8KVzE3t13+EBRHHrz
auaJH+Rsfga6G2ucuM8oi9qcKRSlRloiW2OKBqfi+DOibpJ8nQMmmACgkllDWgXOWLNSC7T0b2F8
MeiRam4aqQ2xsvoiHhebW3cjWD7SjYFYYUd9veDqLRMsXNPFKJYaC2IITHNHurgagAdc9aWb00W7
CJkv8ZBhXFiwfq7cDZN4SpdMwADsliS++lGR2ffFLwx5xf/Rx7GVAmsnqB3eWrYwOszkZ+/a0wp7
j0LIcLbdBkou0WmwPYBakCuHjf70yLTI/Fh67seKFowPvY5xdofi49qOojAs+EerulS0FHGanuwo
03fDlRiIO+8kcdvuSc2wttiHc9zROjQcHYerWGaW+7yhaRchaxBH/MNyywnl+vDnombv7CKjiq26
aocmdvie6xBf44ruYLxJg5AzwL69AJUpjqbfVFWeZKJQNOnHVbz0Fbo1l5AnHJzRSN3pdCchAEFr
9elp5sIhBSIzCbImQKPyFaOTRnfzxZ8G5YSIOxgk/MzneASZJo90I81oCtTj4SAOscGFctxUqXz4
6hs9AACHjyBrxdBUaSaa8u1gp/0etxMvWVAci7/cLbg1IR+/hbuHUmeAdHCvQYQ7ctXpqelxJxvC
Ux1/31H9T8+lCFY/u3ofkpwVjQXPukBxrkGTIuxAgWOGX8SryDZHiob7VW263fda8N6jUQLouWjX
2FJRNV3o+VQBhWz1yWYiLFUGIwbwiDBs1gesGwc+nXOTwguOKMk0NrzqW7x9iymj3f4saf9vhaZA
KHeq0ESy2GlXFUAupVhmRje7brGo77398FKQtRToqwGM27YU0MGpUdQmwutCVwUHZ2hI4YNoq5ex
krLdKqt7OhdfBlkIA+uVMjFXIju9E96PxfYf+i2nn/iArU9eFnw8BMmoeqCHdKezrUbdDT79n7G2
KGRNcV1BTHtJxXbD8D+ET5AND4/JFg/IGZ4HdwMbjOi2LkqU00M15qjqve5GUEQ6DLii3RDTQkRr
0BqP7griq4Q6EZeSWRW+EnatBNcC64MtQSwuhtvM2mCO2mTAimiMG6Q+3EN3U87Zdon9QOhcpv6/
GFTFbpV2Dm8wI1/enIM8hUH486Ce1C/j8BFS9JAJaTf7NWtzTXuReBaZfBzk34vowoep/ps9RNGN
g+nRAd27vBdpgaYZbtuhoGNK7jrS9XHij8rxRuVkL+dofFZ2YmaV1W34Fw6dgLV3XBoVsTdUt8Au
cLUKCsSd2sDhNzRQUlGPrvsmwtaokvdHaW5OjM7olbwvpdCx2FrXCNKLSZrjwW5sxJQXh5Edn5fi
Xt8mn1efaLdh/H0RCrXEM5G0/pqWbjjqq4qyubY4EbLKQ8y7O8GA6IICnGA5KsF2aZSrWpNPhNG0
2w+TELafWfY9H0PEXoQevoipQTgtYfiY2/Wt+EHQMflAEPMjfqXJRapC5SLDyYAzN7/yTwNTyN5t
lOQgmyej7F50i9a009Iies02khnf8OYzZyhWV5XyoNVz5qF/cb0LhngX0GefmRi5v7cfEByk87H0
Ua6YuGq6lkDsbm50tYuvCtMsVxRvGIVZDQ9Y3zxV6mN4oMD1OQ5Brle/GUomVl7OwF9/gG2GRSDZ
6sKHwl0PHYYFXVoPjIZYWLrHKvRNPe9PiKEiQEjx6kuaSVIyPfgelYZKgglLXwha4EmEJn2cs6Ey
cz82ENlStD8QZPwAHenhLea3lOAx4KCX58iY0RKZfppTPl3KK+pOecSjLqVYONVTFpAMrEAvPnuw
8SlWZsGpARXKm37tSzEcLEBryXhLMVio9/5iidCXajnDt0wYjBA8+IJ6cuiG4VSuycKhopkGPlyv
in5GjUYOqM45BPD/95+04c/22knsdhGT+gZGiEigXRcjgxLC5BjAyRT18t0Pi+OeDE7VXB7xOlbV
0AQ5FbUB4zHk2In9iqTag5O/5hc4IkWzLNdNDVIWOsKk30WIIW/IF66lDDoKHZpegTTq4EnfEgjK
tGtwFsjhbv5yUKsrvjFnoGvLaq3Af0YbeutAW0GpVBR/8v6a/mzReFiP6aGXOmXuGYyWPTVt5MUv
thxVUmjAeis6p6Lx3HZRzvBhT6hKPQXZy3UI2hjLqwlFzaLI0H5ZNQzLS050iNwHSZp72Pa/wvuY
1Jhd+Ye5hq42I/jDaN2SBjImUvwe8TnIO09z08oYjy6YJT/xNRcgu7Njp0BSnE3DjgQov+FQhsi1
qj/uMgjhkqB3DNX75BmqJ1srjj7zCjzFyIcsef8X514qNLyoie67vR3NURyoqKdxSj7JC1waFM7g
tfwfuwFG6/iC5o7PRXZg84upPfm42V41MVbmxF3xbrqzhfr3zARB9s0/1kcATAyOA7NZJWKCY2gR
GHSxjln2/WKOZtIqgTwSKg8N4/mFY83MfF11qk1zcDidAuoFEfvEL1IDQMZqrbZaFbUAo2XaL9an
/I4Omb7i54jqBRQxaiykuZLnkJV4GRmroq+huIwHJcx0aJINPeOLaXbe1BCy+5tT5ekyzxYgSKUG
8frDFpvKjYahQEe2TQACQ/uVLTZV+5yrb1VoxXCXskyXzfcQROmArhx9y0r9lDFSA0boNgVEIba1
HsPiPMMs1ZIEUdLT70o2Vs8Ovtr+m40h7l0wX36KVXMJGDeY0FXqtpxVnXtjylyNDeHF3p6quqtn
3LXYpfTsQJEwrcJIglo4TW0yEst2oB1rc8WQadXLOrNiPABNO6knSCCgxG3GcUS0G3UW+mQViin2
sxpl5iA2IZJle4pXGno76n/aHcZmMg7HrqCVqOIGX3IcC2aYH5LMw2/+pe0auF9AybZO5ChXpbnK
Gd/vdLRM6p8TobB+jvlxrs6R4MItvaT92R7tMH7w9h5pnsvUUOuNi4TrK2yluRhIJrgQ0ZW8IxXL
h0lTtJVH8WhXuGBUHsm8Xi63UhxssfrsEQt23dnKjYxYSOUZkKrUmNmt0Vuy3pBdKUajxH/kFv9k
hfs21e9MYOQdHt8gWJqNOKXoqZ9gDHUhiRj9qNfAFSHWKh5NjwOAGCAv4cDakxUEm5xH2+8slYp/
pBhfLDrahXoasd01J22vRLTS7R6JsiXhlDVUPDZNfEFyfdvbpSAXKK6SLrqXpHAl4eFaDcVmPjR/
T4fQGrhDN/HlWyb4WAOP1RynqUx2fjjF+Js7lOwBo68lU2v7e6WOK2uDNFwfnBixKF/Ig/VGAYXp
w7ZSgpq6iQVZ3+o02yc7nvBZBgamOmTzfe8/Q20P+A75AMkC/r4Nn+7z+Oa/ht8Du/HzkroZlBzP
8ez6W/IA87VjUYDbdeqIzCBAGoPkhOVcjM+EIA83mAcluxwkflRoCPjmiZmG59ub8F3jjwUSMqbG
nzHAZuonUrsYoGQGxYDiSaPQZu3Z06Sv7fwzvk/aDBo4MTlrid5BkKRhnSUBfl75oiZXPWIF+IfK
NS436xfihUiFgZz5fqWPEIjXLFK485vOSOWS5NEZnE2MavfSaeXFphd6aTjMnKVkR8vd6XYf3317
tRWsIYwJY4YKq71ST1W09NJieVuDTuJfKNuPga0kJ1qjZUSlNrp+GwpG2ee81w7gQaSN01wVqUqp
549abNQQ5dqZl7KdYFiKkepkJDM35wFCKMiZtmR0RG6Vol5o3bqIDCQFYjU3y5rHEj4EPBilA4iT
BGb7nbTLml1KyUCCQekVA5D4QDV/zfWeW2qG7PEdlqv1fyDFm8WqlP564/d6BWW7/lO0lFWstVZ1
Xjt8TiYNqUx3Z4xBpiyvN0JugUkmDZdmsEX8wFLyqlsugdlrDmDeVNVhQzu3ad5sgAF0kfnMANXQ
JYoSzukUCl22wDgeEKVZ+ihZEzlyc0PWHzXWaPnE61PtP2hBB2ee594dEKFeVX8p0niYdVvk9TND
/PtPnFS/r/Hky5Sw6kjwSZzEhPanU3yTbhjfDUh2W1BKVuSG4umJV2BEq/4c/ANh8H/6T4PDvKrt
gxAZTuZWLP8NUTKSxQHF1xcauVE7B1ZsAx/XVLtbfsWWOaQhw+baR9R15d4P2rMyhUrBD8lG0u6E
C29+nndnQYbYi50E741mpkeKaqzWj+zNoCrbuDpyg3EG7NLnSUkWbNe9Ve0Jf0AjBc/xseG/GvWB
h1DthpdX0MYxF9J0UP8E4nAR2PiXKpvZlXGREqwmjuLxPnT0lSfQFyzwZ1oT5Iu1ZkXnwNEw4W5C
oEuOEiARTvnWPviSCovcytn7yhChZYlLbWDrU7r97cfIsmC/zuSCIPX028bDif/8HZev2Fg7tSFQ
xu/K4TbUU/viBRBZLdesK4fdnsMAnJtcq06arX6+NnaSFY7WLLoxk+Ld2f8VUfSgeV9PagpI2muD
cdLvnKkpzexX+mozmBsNhXWAUNsXSMB9g1qcd7wYY+c/c85+kGHaQDT8ipqtku/+/RTdR/ziKYIU
YVRTK+gUK2mcbYu5EDvxpNCJ/76OyDZjwxFjsogdmO6fxstsq3VT9Tw1UfQlHwCccZb/TkbL53Vf
RMCBOd2qSrnX/Adc/pgyPRB22f4DlkKPuMBrynGDYZcKKbOEReahlfEuInxVpl4ABqBur5IeZfgL
LDWz9/VTEmCQdt001cLjxJRm1GFbe2iBUd1iDCB1hZbr3Qz8V/D4shshlQgKYwE8juxh4m86tpMC
hS5dYK5pZArWGvTge8937dxfAAURC8LIERp0IBGRKipTdp7OgdP0TJYDxnFVzvWDIyC2xmeypQSh
vlheQcwAELBTFAwF3imU9JgZBbf2xrbOzpHbg/cDiSMobLb7nttI9vIgLe4lOgAfFtjIlxZ3LiSP
Mao6ZhuFTgNRKD+xieLiNouSyjOikqXKJGyYC6b9xHVVd3T406dAVV+ZhKVM1qnjBUnTiPELZ6AG
NXo45KopCqI7OBrL29ERE6PBx7EI65Tzac1rDeW4MZAsoPycOrC6y7HhdsprjFN2I45pyQfHGBsd
VoGnbr6vj9GDqITzjsFezHRfirNTeIcW+lKGqnc3D/aLYZBEtmShDKvpGDKGgi3CfEgJZw9F2pVU
VnnHGz9UAPbZVf0vGnDuil9jSSI2tZ8Tc0KJ+BSf0p5KrGY3qbWvdtnaVt6BJJ3Ky2eeFT9fk56S
qN3BgLjGTm5NXi3UAzBUN5mlwyT+Ud6InmydnGfKQZ6UP7wV7bRH/18r8J9mS3VX1Oq0d4gLF82h
dyBR21kI7jg92A25ChPnwDCXj5vXd/xgpQMZ2ur+XlV5/+oY0nrc5/baMC8n34f1lSWGOPaP56dH
s0OUDPUgEmVUtCMylbqzif97eoYxpfXL24a3ErAtBsGzZrUkyISkWoUau4WIWIo5hgA4X0G5lXC4
MNmU3f2pNJQsVVwikpytPP4v14g4sHHb+7swBuZXDuvzY2w5MreysvPnmTDL4EJH3jQ+0kKQK8SK
uRG4s0XOoDApSE+yTBcZMlIhVXh1UamEJjKnsp+mOIvFMFF7EE1VK7ix1CqhQ0Uf16d4fILwfQ81
stdv2Os1YGgdCba8ue+4pwwKBjN+AYbbmTzXJYuhRlVS3yS4cGCrG4HeczWSmiqFCHeGLqx+8HYa
Btlz3eyx8BFDX7UHmWZx3qGMeAX7RMGEpRqVIcDM3ncjVJ3y1DyC+anq2gkhlhHy9ffKaYtTJ0Xp
0DkD64/a/Cr9QrDpRwIjkVHOgD9ClBE36ECOQz9P4qDNRXyzRYSN/501SCz81SyGHux/4InmQ6zb
rfrxuA/qFXddgT6iVInb0cwURyiZ2KUpJONY6qP/nEEUR211+RhHSrstHtDq9XXuEAQ4Mah0Xn28
jr5cZr6QsDm9bwnX0rems5ZMLDU7xBajS82cTI3m1Tt427IUjuenjYAuCjIyClz3QCr1pWtNAgP/
EOI5If9iukuvkGxStUOnh6vG6LpQvdcIee4N4HzcPCXN7lhWJ7+/2GI6z/dMDs0KoIkqh3PqGcPa
eKgg3ZQ2cLnh1id5ZFP/iZ+CQkzPhFJFntAxx5fIy0b2tRd1I9vpvIot8r/Au7aCO6JoBx+Ge1nv
FUpzELSHs8kKYjEx5NhJUTKejyW2xhaBfTCANr0TzZIivd5vrhmGPntCYa92+RxEVKGxwuPUiyg1
kSVk05nLvuQ8ivMvFUvzsnhIS+1uHZ4Mz0n6R9rCG6ZtKLO8VbkW4hIFU5lfzZ6JRyYEwmLCCnO3
X2DXiv+/0QgI80XRhNDBkPyaTNjyCDfJ1L8Pqok2reJ+TMs5BrK+yZr1dojB5ceAWL7rSRzyG7o3
rMNbx+WuRuD6AHpkdydAgY8woFwEbRgMzJxI/H6EElHz62KEbEga2KiLozj5oZRTdnoyGKhpCnKt
r4NJ6bhI+1+gcAh1ppcdh6mUJJcQOT+Uq1dw2rEeWhIA1094RkIu0qoefaoe290R/IkNef65s2lj
ZLTbG4INzGGNX4oglvAg9Cqpm7tjMYINkXmlF9vL+K8X2LOJkkC3X5tV9ZJzNtuBAUP/41Izc3zH
gtMHTHnAoZKuy3f6b+aGhVJdxNRlqFLqR1oMMR8PN0luNIYne4gcHMkMriqOhGGlYAQg2kL0mx+E
E9wmAD3Fqk4URDZ9Q8EBQkSfD35P8KY1haSLHBbj4Ci6N+XhQXMumtJFkf40fc/SXRN1t9w8Rv+S
IoqOM56cUwPBJuD6zqelmXRzNSVVZgJO5an2HukRzfg4ia12UP6Di0uo/EOPcpOb4VVFgJtCRFm6
pcpJ9Px0LrW5MMdNaYTDFOeRDuDTTMzJ+KOV0NjP2zdoaPtC4HPF8VsgLDoAboV1qox7WcCWzX1v
XkZOxSr7/xomrvyDvRpFIGp1Uwk1CQ7XD29tV4bM2rIV0CH54NKFPwZkH8peDgnTGexS7dzrjbrL
f+pn+41BDUulNkcHta2b8LZhlVQDBQEJkbQPz8+ySUAZPfact/X7uW4ERN/0g85Dou5GwlYIGlQD
S/2FUG7MTxvYWA/xfwo7fnijB+blICMaZZQUsfm3tM4sxbxlusYLL4ReksBIdGfIZbKLuvgRDv2W
iqbhoWYyl5jDdvpfREzEoCPresPn7fsdI0CcxXKI6UU+1ecgaR9Notkc6trQF0p59lUX3fyXY9/I
MaD9Mk7+38HfUwh79K/d0DM7aVJEi/MtTp/3s2YHT35FtRAtsQXeo5kWBQ5V3wT5hppuxXfa/B1W
8XdYAdel/3QEUqPaApbIW+NFMjnHJYOgLmaEzDn4t/sS0xnixK85h4B1+BORggeR5EkxWn9vOhHT
3qb9jYEHGlV/9eflzn6HvCh9kiy4SRqSfxVUqClGwEUl7yfTrkPwM5jGIeMB383JtrjNa2nTSz+R
5jOEd79l/oK8sDTdhUc2o3SARfQ4M+0Wai4WLAIFugjfSoRpTSehZTNOY4yu7azAnLaw8miZco5b
AQjH5hZEeIdfxHU9uCKu1zdfLe78ENRgI238xyyTA+Y+vcIHwL1Ns27ISR3DagbYOYjj8GYMcip2
jcVnyaWQuuAH6xri/pxwnK6Ldilx6ZFEMvdIXd2n14uveStAooNyS7xBGk4XYfaA91G9HL7tuakd
+fjkcYq5D4vfg4zXXQzFLDY7/QgzyeHmgzPb11mV1HcbbnO0tXw8RmbO0FuZQ0j3FrnZJxpu5YvE
l01hKpvnltvllIqwNAeZ3PPLF1O9yxffnugPFNa1Kj4rMxgJYlv7dE8YHMVcgRmLzNdFEIH1HWQm
TM/3EIAYEjS0Y5iRRcmUK5iRDBRWF/llfTc7nmClhM/tvGDI6w7EOBffwIqNDcOElu9+3CrDw8Kq
dQhSswA1Elpe4/YMjRccXgFBfxFij04SxU9yiw2WvJ4s5R9ZmgMEgeOL4NvKa5lVJIhzp4CCXwEn
2jTdMre44eSMuG/dqnpVHl7sRGqXA/+VyZiezLdLjC/X3+sAnOjGg0asuXl3XIRv6iU6RappDyL/
jRKeuFhOKlenl8LLJredCJaC
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule
`endif
