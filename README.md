# SpikeEncodingEva
Spike Encoding Schemes on FPGA
1.RESU Instruction
    RESU supports three types of data sets: MNIST/CIFAR10/IMAGENET
    RESU supports three types of spike encoding: POISS/ISI/TTFS
    RESU can be configured by software, It consists of three RGB channels, and each color channel is processed in four parallel sub_channels.

2.The RISC-V Co-Processor Relative RTL Code PATH:
    RESU/rtl/e203/subsys/e203_subsys_nice_core.v
    RESU/rtl/e203/subsys/rgb_channel_process.v
    RESU/rtl/e203/subsys/poiss_spike_encoder.v
    RESU/rtl/e203/subsys/ttfs_spike_encoder.v
    RESU/rtl/e203/subsys/isi_spike_encoder.v
    RESU/rtl/e203/subsys/guiss_differ.v
    RESU/rtl/e203/subsys/submulshift.v
    RESU/rtl/e203/subsys/ttfs_isi_encoder_share.v

3.C_Project Path: RESU/software/co_processor_spike_encoder
    main_code: RESU/software/co_processor_spike_encoder/co_processor_spike_encoder/application/main.c
    custom_instr: RESU/software/co_processor_spike_encoder/co_processor_spike_encoder/application/insn.h
  If you want to modify the configuration parameters of RESU, please modify the main_code.

4.Simulation steps
   (1)open RESU/rtl/include/test_case_defines.v, select one of the test cases
   (2)cd RESU/RESU_SIM,you can start simulation by using the following commands:
      make clean
      make elab
      make run
      make verdi
   (3)And then,you can see the results of simulation,the hierarchy of RISC-V Co-Processor as follows:
      tb_top.u_e203_soc_top.u_e203_subsys_top.u_e203_subsys_main.u_e203_cpu_top.u_e203_cpu.u_e203_nice_core

5.If you want to create your own test case, Please follow the steps as follows:
   (1)modify the C code,and compile the C code into the xxxx.verilog format.
   (2)copy "xxxx.verilog" to "RESU/tb/test_case"
   (3)modify "RESU/tb/tb_top.v", please modify the content "$readmemh("xxxxx.verilog", itcm_mem);"
   (4)follow the simulation steps, run your own test case
