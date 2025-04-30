# 🚀 50-Instruction Single-Cycle MIPS Processor – Verilog Project

Welcome to the **MIPS-Verilog** project! This repository contains a clean, modular implementation of a **32-bit single-cycle MIPS processor** supporting **50 instructions**, developed entirely in **Verilog**. Whether you're a student exploring computer architecture or a developer seeking a baseline CPU core for FPGA projects, this repo is for you. 🧠💻

---

## 📌 Key Features

- ✅ **Single-Cycle Design**: All five instruction stages (fetch, decode, execute, memory, write-back) occur in one clock cycle.
- 🧮 **50 MIPS Instructions Supported**: Includes arithmetic, logic, load/store, branch, jump, and shift instructions.
- 🔄 **Modular Verilog Design**: Clean separation of modules like ALU, Register File, Control Unit, Memory, and more.
- ⚙️ **Datapath + Control Logic**: Seamlessly integrated control unit that coordinates the datapath operations.
- 📈 **Simulated & FPGA-Ready**: Runs at ~50 MHz on synthesis; verified using sample assembly programs.
- 🧪 **Tested Instruction Flow**: From `fetch` to `write-back`, each step is functionally simulated.

---

## 🧠 How It Works – Architecture Overview

This MIPS processor is built using a single-cycle datapath based on the classic architecture described in *Digital Design and Computer Architecture* by Harris & Harris. All instruction types (R, I, J) are supported, enabling complex programs and control flows.

### 🧩 Main Components

| Module | Description |
|--------|-------------|
| `Adder` | Computes PC+4 and branch targets. |
| `DFF` / `DFF_en` | Stores state (PC, registers) with optional enable. |
| `Shifter` | Shifts immediates left for branch offsets. |
| `SignExtend` | Converts 16-bit immediates to 32-bit signed values. |
| `MUX` | Selects between control-determined paths. |
| `ALU` | Performs arithmetic and logic operations. |
| `RegisterFile` | 32 x 32-bit registers, 2 read, 1 write. |
| `InstructionMemory` | ROM for storing instructions. |
| `DataMemory` | RAM for load/store operations. |
| `ControlUnit` | Generates control signals based on opcodes. |
| `TopModule` | Brings it all together in one cohesive CPU. |

---

## ⚙️ Instruction Flow

All operations occur in one clock cycle:

1. **Instruction Fetch**: PC accesses instruction memory.
2. **Decode**: Control Unit parses opcode; Register File outputs operands.
3. **Execute**: ALU operates on registers or immediates.
4. **Memory Access**: Loads/stores interact with data memory.
5. **Write Back**: Result written to destination register.
6. **PC Update**: PC is updated to `PC+4`, branch, or jump target.

---

## 💡 Why This Project?

This project was developed to:

- 🎓 Reinforce learning in Computer Architecture and Digital Logic.
- 🔍 Demonstrate datapath and control signal interaction in practice.
- 🧱 Provide a ready-to-extend MIPS baseline for pipelining or FPGA use.

---

## 🎯 Applications

- 🏫 **Academic Projects** – Perfect for lab experiments and demonstrations.
- 🛠️ **Hardware Prototyping** – Deploy on FPGA boards like Xilinx Zynq.
- 📚 **Learning Resource** – Visualize instruction cycle, explore CPU internals.

---

## 🛠️ Setup & Usage

1. **Clone this repo:**
```bash
git clone https://github.com/iamvengeance018/Single-Cycle-MIPS-Processor.git
```

2. **Open in Vivado / ModelSim / Your Favorite Verilog Simulator**

3. **Run Simulations:**
Use the provided testbenches to simulate programs and verify behavior.

4. **Synthesize on FPGA (optional):**
```bash
# Vivado flow
# Add RTL files, constraints, and synthesize
```

---

## ✅ Instruction Set Summary (50 total)
- R-Type: `add`, `sub`, `and`, `or`, `slt`, `sll`, `srl`, ...
- I-Type: `addi`, `andi`, `ori`, `lw`, `sw`, `beq`, `bne`, ...
- J-Type: `j`, `jal`, `jr`, ...

---

## 📁 File Structure
```text
├── src/
│   ├── alu.v
│   ├── control_unit.v
│   ├── datapath.v
│   ├── register_file.v
│   └── ...
├── testbench/
│   ├── cpu_tb.v
│   └── sample_program.mem
├── README.md
└── LICENSE
```

---

## 🤝 Contributing
Pull requests and forks are welcome! Feel free to raise issues or suggest improvements.

---

## 📜 License
This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## 🌟 Acknowledgments
- Inspired by **Harris & Harris** – *Digital Design and Computer Architecture*
- Built for educational purposes in a Computer Architecture lab

---

## 📞 Contact
Questions? Reach out via GitHub Issues or email me at scsvr2004@gmail.com

---

**Let’s build processors from scratch 🚀**

