// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Mon May  6 17:37:50 2024
// Host        : else running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim -rename_top decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix -prefix
//               decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_ shift_ram_IP_sim_netlist.v
// Design      : shift_ram_IP
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tfgg484-2
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "shift_ram_IP,c_shift_ram_v12_0_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "c_shift_ram_v12_0_12,Vivado 2018.3" *) 
(* NotValidForBitStream *)
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12 U0
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
(* C_XDEVICEFAMILY = "artix7" *) (* downgradeipidentifiedwarnings = "yes" *) 
module decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12
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
  decalper_eb_ot_sdeen_pot_pi_dehcac_xnilix_c_shift_ram_v12_0_12_viv i_synth
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
MwxqjtC/7OtSKh3qHjJy2C58lbKNjee6CNiECRLHUSDz3ChrPGYX/z5jkqWGCcfvn7e0CFkkUJjx
RVyUcxHESTs7dRSY27obsqioytyQpmab17l69NR94G4dLd/o5XQjD8XJSAz3C1WEG5QcuTcdsjQ0
T8pGk5B0diuME+pjmCKdUtD/zU6oAi249GDL8F69Hx7+eLpIXibEE37qVepPnI16cRS+A5WzCFsh
1zt8B15b/ByhZRANKgG5Z/QXUZGtgEAdur8uq9Sv4SHWXamsalZ92wPjc3TE4mHHtX3KL0BPREiy
T7VzvaxkJNfw87STu3X9QkO5Cu1p+sjx7M1VWg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
NJKs+lJwzeG9Z2nY5ulgT0r9YiLkVvMnOfVLJauujlUktxmAMyvsMKJc6dEUVxqxfXv4LbdjNV+p
C3uGw9pTviLS+vdxHfzmw54WoeLbzwaywovG3tFoGwta0KVreN4psfVk5V19QA7o2ALJ7tPLFDGX
1xnNFpFeBDdKLAGlG4sbxT1RPy/fSPvYLqHWWZTbwuNfMgV1UjYFjCVmIprhXIp73SZtq9bPhftQ
4xHQ89a6FaBlWp6jH2kNvanK+G9AJAIqNgySFwOkzRDKcKhR3h86AtB88LIbJGSoaVKgbJ7L/pQB
opp6isPoBv/N0qa3tgvQem3V327FDc+YVdQRLg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 16304)
`pragma protect data_block
r0/uEbzshUnTYMeBaHkYIith5JhcMjxb/2c37x9XvIFiNVC586zdCiOcVJIdBQP5eHLIRnpdihlo
mwbi8TDCRU2A2T3GmN+c8woxutKZ0el6X0NDvUjAUIUPmEJ+hVhhPnm2dmpCg1bvOOmsJEP+dZou
Bf9xL7YrwA+gYNid/5O2K3BGjGhkY/cmtG+NRIByduKGB0oWs73eTaG3Xi+GdtqojxLGzAUQocHo
rhlbBwq7KNH7dm3OjXLt3kn0yP4LcaVWR35EfKEFQEQuIV3kPJynnHX4PxP+muv1wPJRHzJLE6R+
/44nHVBnliTe3+3XgvlYCfgJmAB52UtYXcep+B+CIZtGGGlZmiRiZ+ctPQqrGlOCDSOB6wv7m2U2
ysKQ2Tis0GQQYv4wwo4X/+zFGhDpJE3h7UOxDPvJ1dDp69Z+GQLmeo7rA3AmHiELLF5qDelCGgsr
GmsfJ1UxOw4AreXEP+Cn4FyI//vjBGeCXtzYKi76Y7sUSVWX7v2cf01B4qRE43G+ZJqNFCKaE0T6
lTfjjfNR9I502aVdC7lv5hzDE/KjEnb/Ta5vA0ug1euKABH6lcOfMa6wlCx2h91n49NauzkxEM21
exrdYF1iprt2+pClE4C/gucZYc58p6nnFtkgDIrZwg4iF9Su3pisc1++uD1bACgdYN20JnR3IQW6
udge2a3LrasGSjuASHMCZ87swsRBFttkVIj31QJbf1/+C41jVwKFBxl7AszGrNPVDMg191NiW0Y/
8A4bCfboPTYkG5DAqrpYax+lxlCgiOHcdbrc+L3WSWxULBMWOVQVEaUEAdqrOZC6KLlZfCeQrBw7
JjWH2CiIT2WWvE3NQSOeohXE4Dim+50FgCsUNdhtjOSHAwv+NkKoQGL6D9XMUx5A6y9QP5kTH3M7
BwoL66TzibCvywY1Ditur8JFe7LevhdnDi7EhGFsP26LiCncGguG9+5WQNz2tWGqiAzPOgOS3E59
9eInaJRViGppOO+gh1aiPhJ/NBKBcVxS2GUlN013OCY+fHVak3OiY0nMFBZzPJzJYIHVwvi+wny7
ONbsqnr20n142bb2jImydvpN2fVSsfGHxxkHHi32fumcMMzCAyCape881WU4805REbNEOiOKx6k+
RwTANOrV1rkWFYcY7OkqS2fXLy+TsaLf2Gife5/qI1aWm3kJ6ds+yq4nfYsiMTrifopWYFxTTXLY
0zlOFLXuMmzSVNgfSGeOql7G2gP0B9+R3coCX2g55sBKqwod2IvBtMVlvrUjAWM4avN2bR+tcvBZ
SI04cDG3xjeLqNPzz0887uBAr/k7kX+sxlZ8VCw3GA0nhN2k/6gTCzc8FV/AYjnMqS3LgzJ5TbTL
ferFVVtrM/OVg4g4yBrpwfbyTXQkFVYsW423VQhGnQSWbcg318q0Efm8tf/19jKxLTg7A+woaI2V
RD+lSOPyj1On6cbYWFv0l6AU6O4GMPb1lPt4sZMxcbMEJ8Lzfc/ClF7OQcRD/uskSiFmq6fLI+Nz
scY3gLdH4dqGWD9Jumz25dfd3fqkI05azNk9FfMw9nzLAIOQHSPF/cbCLmhdX+p/vOxRS5dLi8tC
nAOEd7soGEleb4g1qmwP1tgNInU6QmfQ2mDx5t0KjbvUwR8jTen8Cu2+UrYo7pCDGrdA+hqPnZS1
7wUgJkMtqe7+RxvbjhUEpCXE+64B/3VQTGZbkffStl8Cv7PJXIrcVG1t1f0ftdhGzxxDyIdc2sRd
SsC17NSLVVHjNj6mI3xz0Umf1HlIXWFmRclgCLZeYNiuV04qAcP4IDFeqenTGmcChwMlJWWk12e2
GKm+Xfu2udK2NPzOmeF71rDXbTJgmFbntKjprlOTDGmHHGb1Y+pVBGVDLj2HaBRYqG/qc6p98lbk
8ZViWKVOSJyNJQ67c1i+hy/1+5+Z4jQ9ZYTrru/hmUinQGXB+JihUIE4B+IYs+u7pxD7JWsihrc7
SHsXOqcEyMwdFmAliwqQCF3sNWlNhcyl9FZiqshG0B7S8FEhgCtAB9QjzoiX9HgB/STD/vp+E7dx
p2uTntmDzYNFAjXe6FJv80AovOdPq/7irhKu7U/wrtTMl57UQoMPNcDtOviGJQ5NtiFSap4EeFw0
nQbrYTvt6DmcOWGQ9kDyLyj3qQ2VIUWTmhj7HY4/JD2o2Nd9lOIQsuTzlDtBHnDIXDSj00Mh9Dp4
8dk+iMpCBy11VqqAfn+iBCQDjegAF9No+cl0XMQbyTP7rpaMwoa9YzldzoM6jlWTfNeKPYeAqVVu
UrnpV4sV2RCiL0f6hl2FVjO/gEsCpWCdoLvntzQX1hP0oHGXPGJq1hK3AW8gfGfYzP32Uwr7fBk5
Xmb/1WMCZ/6Kpkd44rWqCxW+2kr9lHZbe+RjDCh7N3kc5wc7NxowAaRQr0i+VIgsoa4NoTuZrQBE
ELgjTQjkZW6msp+CxbRFmbheEIKkX6fNnWltUseknQxLjeIr8N8stRp32KKjWO87uQHFPyRJL9JV
s9cLol/EbLI296NhMgCIKzR7CrRf+6168sMeVRmM3OHH51Y8VKVtg06FILPjrFoIPkojQ7WB/lWv
iEOtSXI8owyDZUjPs9wdxIjL01/WYuRlfj9eaM9Y91CpKeP8raL5xf/LaarWUXiYg1mgbfvR2UcY
eV/PSSRyKSrfmrL3Ne6GIOyb4x7US5NTNVNfYVmlV8elrBUwmKyJdiO5ZC2blhzNQTY3qXXap7gt
OXRmrtzM+mM8wQHgTLLpSuTq/qwAS8xzYb675aSxc1DoMX0D2n/LIXtKaNADJHcDBbl2wN0S1HID
zVowz2yQDKc4wzXTA5J/mBJsBRjcKxLWZ8ioaJwqx7vZmJtLjPr/J3jgxxHRK5vBy1VBP7chhtj0
Z8CvZEzMuA9FbK3wlKWBZ8YQenQkt4mnwe5Una9B//uumz0+Vk/hpgAq0zKnDMSlYQDkf9D8cdlU
dj3wd+M9BX/XDAzlbDXul8InZgTA/+YIUWVV7W+lWqtQgzOL78wtJrQXGMG0ndZfFM40NeDGHK+t
YGyT7l5XM9mDRjoAH1sNyeg2bLQE9H3sgLh6fXEYDaGO9OvB7PUoUVTi6V4xA+rg4jLMEcKXO2AJ
E7JhAIbBt0nlx9MOQ+quZ21LBYLTn0JA2ChZpjA1XW+SiXcM6924OQsCWwHETDYvM/Vt6gLf1DFH
Bp2m39mV5Ve8Z07rgvIoPyup3p3jpZzerHeHrUvlQOz11E3N54uH/3qOFD5BgJBsjol2Dve0IMQN
naJcIxt8C8jkCIuLQzFu/Q4gs3Q1auVo+TsDA+JzyO2dvW3Ry2HgOa+8psMY+s46F0jRqPeTPpyO
d/ut5lJJ554y+ovFK5r2PGDe0jlfhP9f7upCE6LVdTcVEtUsTvVeuq1l0fyuM2JuXMGTaitqLkGg
nXtyLRpU2HNfDgcGSZpbXGZ8v/gM4+UA47xncbJuvJ3qvQVCL6CXFJ+z8wyMG3FtPGHyc63+jmQ/
bj07cRKXfEgmS3KJ25TnV2ct+wqmPIMQl7Gfx28AtrbcUyuAiLYNgI5PsXqXQQkAev1hYWV0CTld
KjLh6THfCM5Yc0QPuSzcgxv8Z+y6o3tZTu7HcWOjC+9njBwdohAzbWhHqhoHP1EYWbYMfcdp2M2F
tTI0fyIvk2IHLSqB11xfxDpimvtVSNcUelDjWBklEXhz95sqLpcycvMUDd1i9U+uemykH7uyJLtk
mOnkUDnnCcsQc0Xpkd5gSgUWgRjb73ykplB24IdzTZOFf+6jRX7WY3tndJlXj/d34vA086GI+7Jm
YDx0ywekRFs4U1q01cn8b6lYs19LtSEQ3MiFr5d/a+ZWYPxI3QA5q1pu7Qpf473TpE9JyMInipIP
XlBFBTDmyhHiRucQfgQHOnOKIHgahqZIbDViHciQQxVT/6YE9F5RieSPW2UOVLt13hSVVMMdtSbv
VVW/Kp8W7SIk3GHrQK30vXVp01pthR3GhzX3lWwmL4jro10zrX5IqrYk9Chz41CjA4I9epCdaC3M
SKfiz/QSdZ3FEwsvw1C2ih8WBFlHyhlTyB9B2Er25NoJWVD8SubDsnKeYYLtH3oumpN+7Y4EBPOD
dX9zHkT6G+71QytRZDkVxnjzNGsCa+aJBbFtCb4QOlz/ip0pAeA1I85Lk6z2QAMM+CtqbETeavnH
T4fGr0pcLRlHPM/qcPf2wOgWk6QcXLvlVLJH8zbZJYcyBx29cVwunEepu/dynzwgpuBpmXuL6XFx
KhqZPVszWtlVnYlckXhGmz5TxYFZbMQwM3cWK6FXi/T8f+8ospDDFfhQZ8GC1Nt0OVc64AEduo6c
V8HILj2cs02pwchK2eKvNyOvmu2xA+j2vpi/ipEheZJKMSUuAxYCxB9ehCC6NiR1RRbWMRihExpb
BLOeCaaekeAZMHK8YkYthoczbbdC8jt3vXD49reBvyvcPBg+JW2ZC5zltOe8sR7MQehe3KruaUkW
anYwVs4oBz0k0At/WOVSWnCO1CE+2EkyKXsig9AKpMj5zq3O1Bbnnfc0PNO5yunw4HngCAOyPcU5
1oB+7YLGdsiORBaw7GKCJgBJXp9Qdj6qNOqoKy/E1hJ/v+v8skct4HtIIT+8UbnImxtcPccpE2ak
pvRjpxfHt8NoVRpJ8DaUvXSL9AQ+MIidUElEJR9MuK9aktZylSRKFP3km2in/nehWzXm+DwrpJD7
+8W5o2mg/SLI1h7Vsp9lJ3SMRGyKRgBuVsuWzGAUmlyPR2mUY0XcjjVekaITYS1DzFOGIfoNEwC1
aAUMXpQNe3qrZZqLfiq2FuKNDIIzCkuxRPLeIROGxHn3Ry0ubsXXCGPoQ+NiciMQS5SCsCMl2CIq
vOVx1k331B6I/b8jPWWWvgjwmp76yhU0ShG3nylRs2g5GL/oM57HYzqmYjpCWJZWzd6s73W+MxUD
9TEO/Li3EGnM9YrlTbA6wY75jJX1KoJ4/sQjD8AOAOBJjS/Fnqw+YRbMbMymVyh4NTrJif+AhNZD
Iu8/a9W9WWtQCqaVb7quKSBPfNAWSt6nVyhMvDwzUT+cKjKAyafWY+AE6eoOdzEGjTgLHaAvrclS
J0YL3LilTawEmdjWONJV/i0pwgKL9/qY/xqsxucZivydfmOVn0sihzsd0bACibK+UXQUYpG7Xdjz
ZUo15ybJPNh0uWrLA/K3eM27kcQakL9ITdvIz8WpUKVcWgzYW12V4Ba3LyVkBa9Iml8b60THqZLa
wA8DpRGrGG/bHW+lEEr2OvMVgxYhfnf8bCY/NN0Hg8O9ErYKA2LA37iW6qUHTwZ68Jun4vHOr3Dz
rvXcW2PRAdqfDGkTXFWPBqGmxPssXlEXGUEM4lQNMesZXkfYol7gLMdOIIjbGf16JGmeDrAjEsvA
y9mHrCcXR+2Ps8ZBTsaRIbqwi2I4+nU6iz7e6rtkkKIfVshK+hkfda8ZzxF7DSrKOd8Q3r9Cs4KI
zY+kpAJwFQmAGVS6AoDZp3AcntX6fD/+t3XpXfPOaE2We7Oikx7IB30kSr3YmIpIm0RdDNzr+B6X
KfvqZOgiwLu8BWZ3NQ/iEYOqRjHOXXqIKPa/bTto6QWk6QJ4320OAJafBIyh20/EXNgoro6bxYyG
XNbjxEu6kI2H6MfoyuXWU+p2WvmyO3lqw1noK7aTijBnPxCr64LOAZ8FGYHkoOYPWdnMrWsP+ac1
kuOxYITYX38QcMb0sASV2LA/SHFeD/FMzYep9a75uK78lbWqMhY1iw515kFKTpAFW7cFqTVi7cwB
tsDSKYcuPl84G8bbrJum5Y59+T9sJ4Kk2af3bd2O1bcKm77QY7Wu2KzR5f2tGkk/HeWYhrXRbH0a
WalDhKyQQDLjTqgIEgtasy38D9XrfUigtlapJQ2VGJME+hJBM3trLbGmgNUB/PHt2JPeAebV+Y8Z
gtvHu9hDLY9hbyDnUiUHEgmg18duEFSG63/B7Yi+pZ/MQbSD2T8wkaiTunz1ktAX28YO5TYggj5/
dLzJutQi+Rob3f9ltIYT3oiLxtJN3DuRp2Hv49cq5jeS7wn/CfSBEFEK0Bc+fWco1VvDSqYnFazc
9wptyCPjkkRvn8/zmst4w1EpCvIjBkhkL+9SUoTK2nZPE4zzv4oTsIwyN1nn+Zv6ZiD8k6ymFSVt
j0oqckndTxI8RkfP+izTqpmNwnlPeCZLQHQvrpWVLClfYLS/8wy5eQ0bKFAed1jkQ+4Im5qyurgr
dRjnHTaQl4VfLH/ebaOtn2r3DCDkJxDQ4wO4qagQNEggQCt33AToelcbb7gEjl+mfj4By6Ridzfm
AUdTHNHqGv/80ELvkFPjMqskouilWhOpYN0objNH4z1k1uSitw9E5Buh4QbjpbnXriTvojEY+LvH
i1aLuLw2cMwucX+AoHuTkhHGTdzcwzvZyk/yjKQ1APLE+58ymBHWfRFQAdgXMA9OBNrHCjLmo+d/
ZhIHNMak7DmiRuA3SihT5RxDLogSjhRSeOYJ7aMDs1bLqve7LX8q9thPq0FN3pDlfIavuWjPKSHV
RNd9PWZ7CPLfChTZhgHpl6bX6vuFlUO8jn2ARQwgxvww8FiCebtjJ4RnK6nstbkY6QgnEvuZN1Ng
dfA+w749QlaMHXCjw/l2X3HiSSDVEQAOfjyZJbF6K9CUApJzXABdFo+FZo6/yDWdG8u5jKnZVt9W
WdDRo4cMrc+vtzegV/LloIJw2AHI7320fM7yfWvmloQcoG75uWcR8a8+2hdwF7XYfqeZV75PX6fr
QeGx3uBRcBofbFLwoZmdLJlh1haLIwq2XN9G7QhLwlia3BODxEpPPKIp87LZh1R8SmZMAEb1jmyp
LfNVxOlWE7aNU1xYH4tdFo0jvHJBXegdiDjR48MvPOTXP+JBfPvTjdDuQrSKaQkJb5iYBPUViU25
RfCoC3RI1ADNEk6n4dIp5H7dFVpdORQR0Q/7AeJGB2REr6qHXXBydmO3N+rvuvzdtfDvqJggG+fP
GZJxIvPYC99ZyfbQ/1jVzoyCrIFYvo9asUR10sTGL63YGdso3BxZr2QKKJ+AQkuuk/+3KmrtVr08
P3Drf/RIIAA/p/QruMEFY/gvjtqXQBKHcEc4BUFvU3OWudQMjzN0lky497b+msiP3ERw33yGbLYO
FgCoRPnjP3jYCwm0JyqmmbqvH6fniDmMAnv9jCL1YbcwSVGAqVB7wHHiFnLYQSSfDBI/+kAqCpj8
ZDbwgeF5pPraTZrfHxI+yHO00Y4Jl1eCdXo4xSzI+qmJuKmg2lu971Xztp4bGorokK+SJV401gJy
olRN2bYIQeQb6YhDX28ZghX2ikYTZdFw6U2EZjurCRfjtOsN9HcRkfUIjCxcw0KuoQINbAetzCqq
t2zUtxwdZ/hpxJhmvm+Rf7N2bonrcdpGQWfbK3UWR03KVLsSnhwHbnJDzHYSC/JKLw8gK3n/fL1R
LRG0YqRr18vq0BrpiyRN1ToaVCdiIM9zIHZki4rgmP96aErF0kiQr8ggwuyApbJ0poXAhyCoblds
kqY8h2pdCAynqJ4GPtsMG4dWFWJyZvEPG+spy0lCM7duvQP536vPSB+eyNNFGmIZS/r8cd+sKDi4
0P/73tk0+h2JKZVIr9tHEmqG8nOEvFIpDBnPlOdIUwo1bLH17w4k8t6v+NIG4tV4OCvIkLisYVMf
eAdE+QS8IxkxANOSy8bIjoNkY0Ycsd+99m83hiTJ7B3x/73rdwAedmq4Ssapp3RoNIrKLiSHH1Zi
ockJFRgT+jI2Bmey5O31M8wI8tKD19ZGw779QSRxZd0LBed6GldEWPEQ3taVnpAIQanqVdXKKsfG
IhHH9dntRDNLGp7dPg8buhc0taiCX4K193fgRuK+TvVHP60h9o9kTeUAMBKOTiB1sfzWEgrMtfTm
JxHyKPynK2eFcsq1ckS1uUG8WMM4nHy/o1qMXvbzvt6OfJ42kSECxgEMzG1taHft1/n/OITUF/6p
TVu4BV3YWuXsp22Ka9F7+FrNzf4HKU+2FTeE8EMOejup6VBlvBApxVQy4vbrGtMuqJ9hsiAyLzrr
mMeDpCfuiTCwxUHVswnaSqvq+iwal6CWnsA9ZvALqBVxWQ0FZPIIFVWjiElHYLl6bdtmnEw4hqpr
8a4JCRkwlRkouAFJHq0Yo5XknA6wO3BEiSKU9HBBzVFfpg8rKmbJ3ogu4oyUxidfdP13VAhW9yji
13xPz7nbM89pIxc4NEFv8RwAdJ/NqLA+Z0gIKkMBv29aPN9lcOfw7XPEKuk1O6HfIH/MqcR6SzR5
cKTgsdue7GhLFP7OEXWj84c+tKHgNjMqKpUwxQWjD431gpHHAJBpuqffHmtHS1kT5AfMOhCKxF8G
0ZQ6I2R3tvwdGNHP0JN2s+UV4eLmZudqxvUiSeVjZjS85QwtMcuPlJgz1t5B9S1g7xymctxXyL+h
ZabE24jWaRJTb4UJLX06rb9oqtL9kLRJVBbIgG15FdTXpqTgnSUuWOFcCw/f79rdTxFdoSTeFaRj
2mQ6tx4rEtEvAyLruJEjQmitFqDJYMLA2nI6V9dCDUrpBOUlmxvA4/GL7vhSEhOHA52w7zeMKX9q
pDyyeBhCUM9LMPeTYv+HublbfmJOjewLDy9a4NlbFlWina2rnSW6cu+Vfr2xd5FTCaXTddYfWIy+
IJu2/UHqY7UCntMbEx+bZaA7Op3FRnKBRolfhY/VDcs/4znjOGXnorsFJHg9KONlkM6EXHbkQxIH
AzqMVQ9XgJa3fgSnrpDf5PmcW8kYHsdZFiXBP1i7GMYbo/+dXxq7i3LyPajlof7Wdqf8U+UEivkF
IpVclTzFY7F8QbIFlq47LKNNL8BngacA1Xn03QEVc0E4TatpjbUklYap9yEdNjIX0R5qVhgEoVoD
p+iPG5/Yir6b9zuYE5LJvVLb8VIfqfRoRZynmZSDHEmSXLjnxWcsstypeimxu3x4D/Vn2beVt2lU
JYlFhE/Q//eykKlSc7rA8Uy3PmmydS16zhb5oedOlrxacUe8eOoaMNbNI+eQ8664sIjjS31qVCmF
22+39BJtyzgtWv1+HgUH+y8SVlZyS9WFsNECWKYFO6a6YwkYJN1G00biADth9COkOVNU89seE7HH
rjRZf6Tt2FqV37vUfnyLX68Ckz8oxQhD2qK6TcSrPXx0mPdf9qFK7FY4FcpGKsR7bnkGVzPveisV
NOvxZVJoMxmvRyw5fd2WLgYPEjFoBJ/0EPpKxqX0gq7pV2Fxgn4UANcHXH6KRIG+miUsv+rc7bgQ
/SgaSly5e2lm1dsFPTCQNF8GHbndQchPaWKihqh36roz0+5ZC5U/Wem/4fvF21fq9U+S9dLxTjja
Fkmycre8xuDEB96lNgwKhM/YaEj3FbLnOZjhyAGS4TtnzHnpmzdfmQfk7GjdXX1xNKo0JQ344zNF
HnQhX1cHAs0C/8fljTM+/9ezDeMVz9Q7xiaXjF9Tm2IkK3gzWmBprEbeFP3oRPrfQpyL5mC+rQHt
vZOdQcX7nfTBqmEFKyapfquN428Ebljq6kDKowszMuMt+VwsPEj6ElOiKCYBOBJRo8ATFvsQGDf0
TsCNWhBRrCdxVxmqsH4YZuF2lWW3KwjdSQUhrobQLMxEVnlLyV5eVQyCo7/EQjbNNi6L46mmIslo
1f56pZlDkNFZXxljwJL52a+srHtJTOwhN1NKSltH1qL0n0bGoDNmv4v4HboMBSR//dp6jCzVjTW5
CDVeA1YLupAsrtad+dX3YDw+eYIhtvA9WTAiC8SPMtYUi7tYmrUHa4lWg+7cMj2ke6bxVLD1l7T8
qOwhoIJzd416/d0CR9An7lVZXwnsUt7WRUR5pn61/lU0IXVhwtwmtahFnSlXaqpoRX97MI7gJwrH
OODkplN7GYzNXJvnqLBS9SlLEmlTEcB+YkY528iniPLQOV8rBO3TPbXp/F/RJdcpu8Jrgra5v2g7
ps90ljCwFfvqMx/D0BauG8lBfl+50j3fEgMeBR4AetnMHTCPyTHCtj9WPEw6pKArXb96Z2IyrKsO
Jju7zP9ahkJlIHW15OML1BUwtO15lHEQhsNIzITtbuhrGibCuYu99c8CD5eTFll5ClibpjM4XITH
LocTvYlEo1eYC6S4j29s59FIA+jU++g5RpXbhCsYFzHf6FSbPBF9AWg9O/m+HBN/17SDJUjOWZFe
P+lIcENeZgf/z6B1+vYqaCFqEocyGEQPdfNaCIRGwUuHbK5skE2bmrVkQwpKxEPu1K4z9o5T2ATl
P27nlOVdX6qHda2ydv+v612W/DJiRJtEr6uChmLuQUTBCTou1eb9dl1x/Tq3Xipfzj4QOe1WfbrO
e9YPhkLIn4812kg8qKO5J7zlTTl4v3mvcdhkMeAfCAUc6T162yhz0OKAqnz6wci+7tgY48QC+ZD/
7Xo3QjhUuP/0DjyeDWCW0BXHDtWx6qyUqgakZzxpHA9y0D7j0WkPsMqQjdmesjRDV76Y+U3wP/t5
7ARiD9rSjqcBAWhcSSHmL9K6VKZuB+bFN/kJT5GyNUHlYFFm1lPcjbh/tAUcyRFAGNnH1if548AR
Yt4xwcGRZCXNlUhwT+xyz3bzwz8Ri78qh6kJF2hbhNNNU9EBxIYt8Mv22CwskNzZQ44Bj41a+6V/
0k6sKJSWwVk3b+ymOY8AxwFTRxs4N5FA7rJNvbu90Iqttj5fQGc8mbCMButn/LpFvRqnIp4NLvFV
spmRBg7bePt35poI8Z8PAcxqtv3g0WnBZ0l8XNO7dArp0V33ukv9t/pJ4I6fymguDrnudNahD+3r
FPbGm9ZcNkfkiM7j07dCmgHRBRXu5+WJHOZa2SCthJ3EM8+CnOKKoRP6XKFODKC4wH7pb1YjWAe/
3ZHJYpb62VeZjV6VwbdZACzw6M1MEJlANdmmophHbfAfq0E+nd78T2khdrwVObrab9RnOVU/P6Fe
Eopu3Zpa/IkZW+hdp4mLXtQ7Th+C9Mv3G1EOfeEE9frISsP1TfgJI79ScxqBXzRyHDMNwsxBE+HS
Li7kGVHxXD1wzW/vCv9bLiQArb38yv50AObu0TQNbQ4S5C/FZkbB23znUQyW2fb9RZUlPF80jhVF
dzjygV2lS2Ah2m96vHd6j1goqM9JsruQn/6MvyWPVBz6zOUeVFAFhi98QyxJ+3uw+TeT6YiFYiLC
pkMBblIQ/NvaoWwoHZtl8RhekU08iP8OWGsKh+m7T4OODJQMTSMJnGvZb9JGtXcjGk3h+sdDJcT9
VHjQ8bT8NxBDZjSeUOx5hTx9w2RHcQsrGq1jLoQEoXNJXeGi6vLdwbYeiz0rLBN37BTruf8Q32Yx
/OidQHUbfUEzwjYK/B7zn9chFKUtRCzkoYEAZmzJTEYa5sPfkcXv//9pKNmS5ews8hWypDkQ717r
9QOOn/04fUQa+8bGO9tgAlzylvsGrotMrEytQxKgqOc4+nuHpSD2nXYrOXOa4Vqo7sYBd75MFIAF
W86oZUV0jkHuENFV9geLDvMa9qXN/4U3NKseO4CbZwYBx+hlrNn/nCk0zWcbEJLCSJAP7kj/nyQ9
7QIT4wEJGjyzSOMoer19NuAVW0B0zvvP3f6mgYTsOroHDTBd9eu7F3JXglm4W1zAFjQuOkMTFSBM
wdNtJar+EtN7eZR8fmQkUrr59ZLWzUshKZ3mHKsNhLfzpmOs4j7R2wMS1Yb0YUSeGfxiayqQC+N5
TfsdCqMDw5F5LWr2UhkZsZyOqLUXPGvujzcjOBME+jQKipjlC/TDsAb+nahpv8Rmua8p6qJa13sj
0D3zyQXk/UZStQj6czgpjctUt7rsx8GPNrEXplwTCrjjGnaFrkU/bj55//yJIPKRBBwp9QojHbLi
XzNSferWvTEPgMxbFo0Dzr/JgZgNGPQ7rkNqTXNI6tN3Hb/NGJZQir37kw2Wa+nRdHapZGjeDv9Y
2g2KYJmbRqL5GTEkiDdBZ+hhSFhCOhsgYWo9E0J010ta+TXiyjSHhfLMPcK7nkhCuXFCJM1R0xZF
lZ4SWvh4+kAp+9IW/t9wGAZsMMm66dQUURl9OpxepYqadFz40OI1AmP5MvXrLqQcBI6GsilsCIac
WOtbpOZgqjnwGFAcCNT7qwK3fF3JWNm98qMngzVy8ThwRzxHDiMectkJfnx5RT+6aWd5/7pPys1M
b1lgHoAGV6jLiAInDItFBSDLRogMDAXgb+GubvQKBPqmL3IqOQN8yF/wUM6YPjEFftspwGvrQDVk
1kzXVwiLCHu503DyMQJNnvZcQzzdbo1ZrGfD/sIm/jF300KIEe+xJR2rD4s+8khVNpPmn5kecyo7
h3Sm8kT8x/cbj/JU/9KuVaDoCe0FHOkeiy1TXWMcfg41vG3R7WBnbyWvO60ToKNpTXBn2IlHirjj
9Rj1+4RHnDheElNrc/LlMVvuIAE8FLPS2p4XX1oc8jliMVpXC3P7Dps9Hqu5CJyH0zC6iQd8ca0s
l7LDnVUxn80RkE0DOmPPEemXlpvE/2b0VO7QwHf05u1JNYmHkXVUdy99uYgscVg7bmG1ZIzo/Wjb
HT2oKSwmp7XpUN+VGaQuuOkO93LRAQFDcxIhwTq5203i5zFCOiinSY4E6EfW4zZ+kPkN3GXHiCGs
AGiLA9mOZ2CaIXeB0rZMWioBvQqvEIp/rSjnn0VaQodxFeW0q5b/803/+n11ayXEETZqOXPP+jDl
PnqZfNr8kBV/HPnLAxJM0NL0en3Fqb1hPFYmkd2DqZoky1ewO6kL2XCbbSJuxulZ6YuKCZoxEIov
cxckiGlVpC1ppGMZw334A1tzgZMXLgTtgSwhIaUx+XtE5IO3ZP4yXRvX7cBIGeSNCmn9cLIGYw0F
+VgDPe/xPLYwtYdDEq4+tH0fJMtQ6pIettk3Yw/tc3coJxqJB5gGsOsyRwELxh9MNeFjsLbK1CNP
p0PXnFTcxLt15OOsmba1nu+nNzRDhve0XMjArA+kc7DQ49cky8FpcuynhbDdjK1NtvOI8qyB1uAl
zNbaUFZYG/sdFUZiKazDXEEXIdJ7NnFAYvz7B9sJkd0c1wMzoffdJAkG/9hKRYaxy8imflNpVa7/
qJoptHVmxH2R6b3GGAUpvqp4I3GLQ29UNdi8KiPaq6Qkj7pCFr0yoRNuifnbQVMyl/tdVhskTjBo
8C9H2ONIAC9E0zBObEPyU9Zq0JYcKmPKoCtsc7BcXSsEgj436FXtKuSVSDMTzQiy0u0uIBvb6MEL
JZe0IdKJ+Vc1G4tu9H98gzUNgWgzuSWD3OKPTPsf6qACREGOI61fZZP9nShETtMz932oLGtkSZM+
QaFAz9Auujdvf4QbJie9DvvT7e0jp8Oq03FIrL0s7+7rjfhBrogOrNW/D5W95KPWGCWwgCcikYmF
5Uh2cJnHRUrbLgCTFmxR+E8nWmN5lLOGcpJf6LPhTi4BSV1h78uS6Tn/4mo7AyIaZx4DI2U69lVl
JGJgpY4eh0OyXgUT0OIFUg/+avvYhbftW3Wg4aQcHTO5dNwBbhTvSwIALhRyTgPjqwUiuLEMwIwY
soqFivaaKjJESogtRT2s+oRJW6+94GeaGjtdjcOvm5//8/fIALSgVG8S8uDm1kZUguFOcPRAxO/e
HU3o2OShuAUSj37wfqvCgky/MzEzZY4HaYQb9aRkYy/fFrnDVhcxm/iVxDFA012oWPOFrygDB6Ac
ggpbsWOb3KHQF9AWiGoyKYqgFbLUaN3uUxRqkBH7N3p1JGAtlG7ytEHyYe+PXbwl6TtILJ/2oS2e
8MY7UtQ/X5chnFn4g0FDKEb5eXOUAOLCTRqAVK4CW2ZUmDB0sMSJ7ki9zdg+X6JE1z6g2pTDC+Pr
KpVkgmkoLxsn5JxZulGWq8BJ30f9hK9HqXeZ+/ExbMnGQ9Z721OIrNOekIG1xqhER/0R+sCqsmi0
cUCYlMxusOaKpbCEgEdoHAlH8wSR1EEjHj1zNUSBHiNgz9Kw+vK0t5Cd68ttUhxWvzb03sFppzuZ
Q0/gsNGse2qzkHR1+TGekFwcsxdfSVmOBYE78sQyyDWsSYJeU3Rmvh6fK9N6ZqY0SqrmNDu5R68W
DEDNxRE+f5WtIwN3ZVmWP7efRP4cxYrCFb7+1t26gUWJK9fVae4rn46Em8EoPScDA9sMW8oyVXdL
KNnBCdV7NCRYw4kdra6eJdsD1V6745RxtUfTAGoOW4GfZQWeGOmZy2dnT/G5h1qw5W6P71dIQeWp
Y4wL5GAFmuADhohuVrZCtPW17RkErBzq8nWpWuSeV6jPEyyw+HMWUU2Tn9VC4XTUSSz0iGnQaWZU
wX+TEy2g/Uk0BiZ22pNFMaK6fvuiHXP7s7Nb0QvVqUH01e8yECnqLld2ZiaZX9AELQL2lpZQppKM
uy0lRQ0hp1QO1UgejHQ8nxSCxCFuY9TKevE7XxIPy6Xw2SsWOuhih4Lh/Fo2NkvvZ1BlNcD0UcEr
jcwZg5i+jfGcsIAzeJi2QcdnuP6QVBbBpC89LfeHVwtFIkJbKDXawEwWv704ZnKbPhieGiNXl/gq
cH85G4ZQDNLxFoRbfWEIZBeQWbjQJcLNnMHGxG4zCVz71pkrkXqAqmT8y3z2arDoBGozk0vxamyS
06S+TtBOqzsYPFrMAs6YlQ0kDKQ8iSN1DXDWKeKqhaN4D/kAhgNqm3xI1FhRSTSFX2vGP1jLRw+g
BzvahnEcGhBOwD33mPXbsjgjSeWCq5aKc3sg/lvhqaHHKaHM87eKLqifkHhP9cTZQT70OJBNSlRu
929RRhx8/XzJC3wyCavS3hqdogWq4AqV53UCu3JVbp2kwWVkj6VTuUtt2d78hhyBATJTx2IDu/eA
bghg4lcS1VDzXo7ULzRI174L827oeHIV41WDqhxXU0a1WSfmyDPDvQu7vEwJ7grxFEHzsBgzZPoL
ud8GLrPmYIZn5/mSuRC5ZeUOITG7gGBVvGUaCsbx6AZDNjwLqS+o2xEU/E4ZKTSltNTsC+hARylo
jxts+UB4pyeP3VprSspE4KwqI68gyjc6Nb3MsaQU+GxJLVmIgZQxrAPNE5ibl2PdesP350M9f7Ib
zogu0ZwXZXMfjgWlAIqLDPt+bHz8MxLhDj57zV6ph0Sq6AoGkyLQNG6t6zPbh/1GNBCWQhv2hgkb
xnR4mClYNJD6tNwF8NPbjGtc6bT3g0MIi2Z1KzMxM2R9eIBRTWCMvf1nAUMeHWkS+MZ+oMpF8UsO
mYL/JUKRjGkJ+7Gp8oxjqgg472tTFsefG3tCBst59vZCgGx4/MEJlDCISEABuL3mBtfI2NGd4LW1
/B6iPM3PYdQ2+qhdyPKaizBlLyaEBOwL7O+mmzBykeIxZEqSLBODyUNNRcUhdANUbx3961KTjNsA
XozY7McMHdQFsy2wA5RATwo7CmdQ427vLWsatuiOtgdUyykVm7Py/pAgWl4pzfPUy1mZikXHqELH
nCYJSyoA6MpGOVjmGRmDnO6Ob4g3Ohh1mdslY4Y/pn2HLeWpgihkSRGKmbnxjAdfRKhWSkaui2E4
N7FXAXaO56GHShksU4dlXm+iDaKyZNiMLhpS4y5ANnHzZ3MdooGpWP2yyFeZOoOBvKgJUWRvlwOo
p999sq+8927abbDJq/PXPtG74Q3FSRi6A69UzeScDoFUf6yFqlkeM5whKn19qPw9ew2HMYzAnHfk
VMW7mwvWucgxVuC6BdxWbeOyL5FqQRBePFfdDYABdyQJ8ZPoXQnVRpcAwOkR3WXBQ0t7a5j8Bvr7
MdY/MpEumSiz9Rss0hiS/TqhWIYgWeCfEYewgbvmW7dWOiSCWh+HfXq1C10xZHdSQO1zAe7iTWUi
ByFX1rFgfz7mT8Fsa+xGSdAmMAAdy8g6LxVkH20LkdVMrzG8PY/s7QrCUm+8mBvPA7v5iwRTVMEt
JMizwdiDJkfKlhyhkp0NXFbVXSr/TG8/zesMFEjqjlgfR8MRprHh7w7XuNkneB5EztCO4W8Ix1T4
yOL1B8yQvTePoWrIMZt9+6Rwg2FYumHuQwEvhZCg5RznWzGj2sFx28PERi9uMwjLUs+LSKL4LfbK
CkNFWyIUeTU8EkHKjPIVfJoCse2/hj3IakDeL3iGx9bOoer3geVkTs6L+kSCt6ZTWl/L1Q4Lw8TB
gbRfDXWNSEJn751cJAq8qajkF0W7eEqe7Ai49qQbRmn4hqIvC7yB1r+tVW6XqEt2bAHj5Sf8xs+E
F14THG+P4b1q692Ikz+Uq8fiP+1m57TALCHRlbnY+uQbhhp6YsOphH6ShzcwYQTOn6WUkxk1QWnm
7KcXUm51/4b584SI66B/0xwhCp5/LPD7sBHRHyXchEZSLS1+87Cz8z1/H5BNJEwCrkLkW27IdbCG
zchePCrddtoRlyt00IoMesgwe/bBcJ+ajCOW7A+jDRQ3EOHQbdoAYG5888FF/EqTC3NP9MQVuhWp
jihXFyvKIqD18C0AXuDBcO8Wf+8FNnIRFiPxuAqB/fHa2+ZhgFxNhBBNjEmfoK+6t+I6SUUKNQ/8
4Ohb2oS8lQG3cqrnDE0M5LwQkmfXm/aZJGe00a8MHETO7+I0+NlOfN+iKsPgqQtxgAfdt8riXCfH
DvhbY2af7NsRQ1QyHAv5OSHxhBns7/WimUsyy0MSe3umWzthV3mVRXbBOwtTUMPSqiD/PTZW8aHW
pWkhpkKyxBTebncdHb29dMdK0YeO14hLpC4oJgnvSXT7z9T8vAiMO+ccdOyvYmx09jIvhQQHUqlz
KG5JRyDlTLQB94T27UxXN7aQQZ9O4204uOWyl+EnHIpZcNClGPUd8Ho/VlAeKKyVsPgO2XmS8tLZ
SZBS/+McaBULj9yYICzQoOwleSjSlv8AI4H2mWi58sBKd4jJd5CJy/cuCER6o0VGCXmDDI8Ll3b0
N0a+us+gLX5vvTRoCpNxCSRpKkK9L49I/nUeHOZ7dIXfeFmHJwl5l/akSH9Q4v5QNIwHU5nVdxNd
xOKzn314VH4ondlfRqkG6v7ES0eq9sMMj96JFmJtX+8ZkZc/LyEZAcO1D7p9NotlONy7KLq23WXX
3Q81pTPh5kGv00Qv99mUM7ekdBe9rYtPM+m4oIyMYevKbCOrcfssrQY+1kDKGyCNw7i/Azsin+vx
AG1xmfGIjJELzO44Q7HLcLOsVYovwItMy6XXof8ZJ9s+lV7eO/kaKTWau3lb/T9NBIjJWK8TkG70
wGnBRSYuBpTC/4tboVgPYduS2+D6zGu+Er1XDX1ktCcVO/EDI++hy3y8BhMOBaHMrCF8U1rIVht7
Kty56Cnh5aoVp2EfMzGlv+s/Txk3K54Hhp14iIAfzWB+Lb42VZSS5ulgP85vTBxPLTzfVFmr+F62
T+uWDxO+1damoRfeaqTWVGpk3/K5BNBf477ppMqsKckl8twIOVcR3limmlNw7orCVrqTtQAHm+oj
2wftzhYYLSOoEO0Xd0xqjdTZQ2v58gxDVdrTYSfuveSBQbwU67NyJNzF4guTdy85Y0yNzfCziz5D
t0aQPnc8rlEAy1EJkoTso+GOsKYQrRgY5Z4kEpiRAFxveoRyBvh/VVTF7hlrjCgypHPkyqwh2J4s
ebjFQKOaBUIpmIGFMHKJIAacOiKjDioIcwEPPzpOtjFeF7JLk2vLhUhpcWntEJOkE1mbKxRcLb3d
dZ9L5ZpFHINwNzIytLtf/Pgqsx4bSMNaJtphQM2Z0wDj5ZtFPH5TFwQ3yPuBdd5bI7GtKXTB0kEv
DWithJ2HK9ooMvnlP7OJXPcrhSC+TSp46fKWlX37ZuSrDy6tKbDGTGmmNYVLPGRdNvYLXW4rsMOU
UKAeVa+FaL9Li3BhRw0tYfcZT6wm4DPSlz5EYdVSktTClvfxSEXEU7jfkLVmSrmTxiMz/G0iZGph
P5ow5dItXeinGrowSs+sCxD6/r+CqJRvDuRwTBhvLQMABN+/XXpN2YaEbGD3RFPPB7JcvktcGkzH
PiHu5G5IP9MmR+KZbNOu+RwgZp36/kgEK36PBvqe9AU9RUqfXfDeyBEbKH8sjw5bsYYkKyh6+eiM
Q5wv/XpR+HRPz5iKzDxSw/yusT9bjrJ64BGJe+/HuZYvT24OswaYmrLmN2dd/JLP5Sgs13xXXT42
1eOi5Jmv2TItm6U4Gv+lDsfYOePOQYfzhoZfzlj/815+HgEoxwPxomOImvRGlgIU1dtU1r1Zff4D
4H252EcqznP5tIdC+JzTnFQ5jFgJFh1gaAPhC7a8I+zQzYipdc0z1nBw78cUlpZcebi/O3rkiFFP
KlZQxrhg9bl12jytrU++7jS2V4jXcuX0aqg+ciylt+1MfROAbPhMtx4Vd8VhJVXDVdzH23L6Rbb6
XFPhSVpYT4IStyl4Fy47daN9SUq0aw8+nxLtQ9zxdcFIAAK55ICBNrtnxU+wGVCpflyMjKxNaZzG
8oD8KB4FD7BtHs2Vg3tB/1ToPYuQdZhXo2NQJbs5J7UEKZyXeQzND0VxG+CpLYHmg2ogAUxkyuhk
pWEctJ2ZEDk/lSvMFFDG76PK49bIgZ1lwWkVdrz9pAgz1KYb6sg+QB7Stq5MDdl5sR30EVS7PKc7
X3vQ1v19cdTXzfp+//3mHL3PoY+EpE+KYOXY77rvDpRERD7ENOUIkE4F7NhpsGW4B7IFuAJoCzlt
vmUE5FfJJVKGolvzjm7nvTnRLgDao60adPEhO0DqFiDkcsPJvX7VWOtcTFinFYd3iRa27Fdvj38M
7T7nIeUXWcyX8utFTdqXCoWDu3ue0cNgpuvUr0OEnflqlMTtQdCBvXk9IubtvMZGhCLKjSCojDzF
wPYVUzRvVzn1kPrgrdTg5ISxHFsuw26BwnrFBX4jMCmfNf9K4aqeJJkW8i5laFaHVg+dcGZtITR8
sVgPy8ggl//sCU6MsSTzqxU7EBpu8WYKRsAlpk0tV2iX/klqKyv9OdDmkWlVKomLK57XfWNYy2pF
gWgBAHQ14FDzcqQIIldpGO0xOUL/Q+eWvrC/GaPFnax9tmmEbIi88RubL+n88OqwaoDh5TcMzvDP
CRQnqcOKHPBbJXHDCm8NvXBwVjlHGwCYTchLhRiyhAv3zGvBGJjL4u7pO9RoiV71kar0ijlzcRQj
YCgNkuuSzeuR39PKQfI5PM+qMDDLY83Hios6lrQIBd5RAV6CB3XuOyMaRIaFRgFwovahz7ps+Nwt
6EJStvtB+hvDw+PsBIHMepw0BfxtnwqwgiTB1s/WzRmWnftJm3n5blOXzzi8tn9+Jkj95MQ0hKJe
LlXm/y+tNqKbJW1+Xuexk+RpQf8EmX5t3Ud6BwyJjch3stgo9iyBzhWECG1yRawkIigQypB8DjFp
H2Q8CSDLOOzfVy7v3KZ0APbp80+vMsSYNN0QsvuvC98yBQjTZQc0yQIWmAfTce0NgfMut+ToOvrq
Hq9D3xVT4mwgMUVD33dRA6stY5qn8YfEjI3yA5pg+hMuuTELegmExRAIY3nYnbcdLVI9iQJd4H6j
6PlLZyDQYwcNLPNxxzQu/wbLXK4TBIv1oI4am5Ot9kwiLXiwqb7RABXihrs/WYqq6M0oBM2gfBga
/d3KCr42gFYr/4dJEzPzzDt94u1eRLixqedfQNgl9JSr0E1bI0z2LkjxPOaDZlklffRD8i2FoZJ/
Yx8Cf0O5v0inlfB2mw/SEfjcenFKQBasYO3R+SY6G0OOCSNukELYnFPj02dgzOQDhKIJwNRwiuy2
J5qo2B3yu3yZz4FAWljj+ryV9T3XD+erdUps4j3P3nHkcsaGs9DxfW3sF/eRKiLYT50rVAkxZVrj
EYbMAccaQrDjGJGnhYovBe9SfY70WQp6LTgaPD2YGWdpL5U33eZwTC5yK3rbq99h2eDUNzkoNjMw
SZDwyrI2shkIbCvBdKDFbLCGy0M3guRrfsLbfa200ufRPBXpx+pallttCbe97Jh+x9f4jml/uZWm
4koAjNQ0kGF8MuXdPpUhSpG2gF0iGGy78YiWN2cYppsIgTbNQyGch/+ss9w+RD49BzbSUhD+npRk
ED3mKwMECWI0v+q5edgMY5aEi9/TJCYJtSReI3k0jn3saQ2ir0REuGvQETWccg/P4yo1HPqH04qp
Bf2vOA4ruy1XkIE308b37au34b1BfhHk9bE+z3/2P5jpzIbTsujZe51UNoMY9efEsY3oPAeyMlTM
f5tMfLNsz/JnxBom8I+jzk9Y4YyNWx+LTw2eoQYlz+gTIR9I2/sVRTZu+RivWaTtcZdiFRcr/pdW
5mpJfdydUR05s+pkhOYVMPEa60UGTiXdX+UC0tqzM7Wmm3cH5Xvq7vg8EDI3aVBpc3jK2yvEMAoe
X5cln2wnkRTi4AE8I4oerrBU4HVh7vJSLLQf54/EyTRXBcEf+1M62VdGOfpNE3qK34qh2WRH21w5
rwFVk2/ZixubGAbe82D8wP7OdvfyscCpyhEiallAm4lKRmZNDjbQPVOouCnF9qCkN4PJkc3P30C8
5uQVjWWSaAUtExO7B4t+HhiYBwOCi9gojbhnsu/PijMDg5zuxzhtrX+v8QnSUTcqUzYiX0oDbG8Q
Y2AouM6doPD7VJteJ9Ce4a9e1OMy32a2wa2mxJhBfx9xSQegbIJvLcDa8xOgVwbh/WXutEIoT1gI
pHYztb/SqF+DRG/KChiopKjOOPB7TtB7DtCqKIeQ9IJe6iDpUVIQ+lNI/QzEo2BgJ6yoLfXzPimx
wdihsoPFISVtQrX9JfzHFCGRTNaXYnwejFkDxsEaNWoi+vChyWt5o2aJGVj1RS9NjkB1zKYYt3ee
l6TGQFfiBbKNh34uw8rUuSR6Vd379FGsWH7j84WRtCbmS4EkSE2YDN/oGpCUXRz3oD5fJYjT9TI8
gPjYSvJJjJrxHBel8vZCH/es9ul1++YNS00sEo8VEKx5plZApyFbNVWTbOaEVgu86c8O1+iNxre3
3DJXZD/RmJ13WxrTvqGvbbNIlmiEJfbxGfXvQzPiMA9lORP/LeCJa4UELHxEUS3tesxBiS7yBI04
UR81mmf7WSw5nmB6Hvx2+YtDfLgn4Rfp2RcKUS0W1ynzHl7QFTT2U2m9O1OxngMhG2idxvR3cQ6U
wnlqq9w1dbIgB+oEVlFiCpXzec/dKd9yIexUCMo7zsHorAItBsXuWeMzvsd6Mk54+enms99khFj1
yqhu4O2eg7P7p6P764kVHwyCuI7Zy35nHdPf90GU4OYVgJYWdMauPdFNK2oEIH/1Ko9FZhrEKTqx
dUwLqB5KnwFhPd6D1p7NB+rtaYQ70zVeCtsm09qDWN/IMjN5AUtQ5Dq7Bwy+laHxaH/3iCAZLsgh
Aj+1F/SNcQVjgFIMRf2ht3fXoKggU+y81tELwS+nXuaMaqVuAw8OjQttLHzaQHCSHMdQy4IpNPzg
kcGXwDpfyCUSUspCZnIqzS2cDmI4JodZr+lWIT0dFXbPx23gUHslRq8WFYKC6unDRjAC97k4RhRh
3VmUOhoO9QD7sG7OFDjE0fiymGVj5d65gwJ9UybAzis/GJLT7L7l0tHg3dnaszW6Z7dPJE/Wr064
0V3mkxgTlQILjLKHVmcaZ7cM2Fl6YC10oFlsA1KlOeyM55TmbosTIqMNOdRJKNyh9HnozzXvO46k
L6PXkeMoTE031t/7gZbn4qeyS/m1tvJ6AuwzAvncNgOVAOwoSDBiY8Auophk5rLOPPeDI1dptiwB
DNAKYWc7DJfe8jm6cNHGclF71ivY7bnrPvBwR8p9mgPbhyPsqJdYHSAs0CL3w4mhp8OJqJc1NHCB
SCo=
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
