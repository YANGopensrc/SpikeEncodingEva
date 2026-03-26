# Spike Encoding Schemes on FPGA with RISC-V Co-Processor (RESU)

## 1. Supported Encoding Schemes

The system implements the following spike encoding schemes:

* Poisson Encoding (POISS)
* Burst Encoding (ISI)
* Time-to-First-Spike Encoding (TTFS)

## 2. Hardware Implementation

The RTL implementation of the RISC-V co-processor and encoding modules is located at:

```id="qk1v0v"
./rtl/e203/subsys/
```
RTL files:
* `e203_subsys_nice_core.v` 
* `rgb_channel_process.v`
* `poiss_spike_encoder.v`
* `ttfs_spike_encoder.v` 
* `isi_spike_encoder.v`
* `ttfs_isi_encoder_share.v`
* `guiss_differ.v`
* `submulshift.v` 

## 3. Software

The RESU system is configurable via software running on the RISC-V processor.

Project Path

```id="yltmd9"
./software/co_processor_spike_encoder
```

 C Files

* `application/main.c`
* `application/insn.h`
## 4. Run Simulation 

```bash id="87df54"
cd ./RESU_SIM

make clean
make elab
make run
make verdi
```

## 5. Custom Test Case Workflow

To evaluate new workloads:

### Step 1: Generate Memory Image

* Modify the C application
* Compile into a Verilog memory file:

  ```
  xxxx.verilog
  ```
### Step 2: Copy "xxxx.verilog" to

```id="eqsskp"
./tb/test_case/
```
### Step 3: Update Testbench
Edit:
```id="6kwogp"
./tb/tb_top.v
```
```verilog id="7bt0f4"
$readmemh("xxxxx.verilog", itcm_mem);
```
### Step 4: Run Simulation
