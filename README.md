# CobolBank

![COBOL](https://img.shields.io/badge/COBOL-003087?style=for-the-badge&logo=ibm&logoColor=white) ![GnuCOBOL](https://img.shields.io/badge/GnuCOBOL-005F00?style=for-the-badge&logo=gnu&logoColor=white) ![WSL](https://img.shields.io/badge/WSL_2-0078D4?style=for-the-badge&logo=windows&logoColor=white) ![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white) ![IBM](https://img.shields.io/badge/IBM_z/OS-052FAD?style=for-the-badge&logo=ibm&logoColor=white)

An open-source banking system originally written in COBOL for IBM z/OS mainframes, now available in two additional runtime modes — including a retro CRT terminal experience inspired by the Alien: Isolation Sevastopol station aesthetic.

[![▶ Watch Demo](https://img.shields.io/badge/▶_Watch_Demo-CobolBank-black?style=for-the-badge)](https://github.com/user-attachments/assets/53ca5c03-b6b4-4292-9aaa-480744c1bff7)

---

## Overview

CobolBank simulates a complete bank account system: login with PIN lockout, deposit, withdraw, transfer between accounts, account registration, and transaction history. The project preserves the original mainframe architecture while providing modern alternatives to run and study the code without mainframe infrastructure.

| Mode | Language | Runtime | Status |
|------|----------|---------|--------|
| Mainframe | COBOL / CICS / BMS / VSAM | IBM z/OS | Original |
| Terminal | COBOL / GnuCOBOL | WSL 2 + Ubuntu | **Working** |
| Terminal CRT | COBOL / GnuCOBOL + Cool Retro Term | WSL 2 + Ubuntu | **Working** |

---

## Project Structure

```
CobolBank/
│
├── CICS.COB_COBOLBANK_.cbl    ← Main program — screen controller (CICS)
├── CICS.COB_CBLAUTH_.cbl      ← Authentication subprogram (CICS)
├── CICS.COB_CBLTXN_.cbl       ← Transaction subprogram (CICS)
├── CICS.JCL_ZMAPSET_.cbl      ← BMS screen definitions (4 screens)
├── CICS.JCL_VSAMSET_.cbl      ← Account VSAM cluster definition
├── CICS.JCL_VSAMTX_.cbl       ← Transaction history VSAM definition
├── CICS.JCL_PPCOMLNK_.cbl     ← Compile and link JCL
├── CICS.JCL_COPY2VSM_.cbl     ← Load sequential data into VSAM
├── CICS_install.cbl            ← CEDA installation commands
├── SEQDAT.COBOLBANK.cbl        ← Sample sequential data (demo accounts)
│
├── gnucobol/
│   ├── CBLBANK.cbl             ← Main program (DISPLAY/ACCEPT terminal)
│   ├── CBLAUTH.cbl             ← Authentication subprogram (CALL)
│   ├── CBLTXN.cbl              ← Transaction subprogram (indexed file I/O)
│   ├── CBCOLOR.cpy             ← ANSI color codes copybook (green CRT palette)
│   ├── SEED.cbl                ← Creates demo accounts in data files
│   ├── compile.sh              ← Build script
│   ├── launch-crt.sh           ← Launcher: Cool Retro Term + CobolBank
│   ├── test_bank.exp           ← Automated test script (expect)
│   ├── sounds/                 ← Startup and beep audio files
│   ├── CBLBANK.dat             ← Account data file (created by seed)
│   └── CBLBANKTX.dat           ← Transaction history file (created at runtime)
│
└── img/
    ├── Loading.png
    ├── login.png
    ├── register.png
    ├── menu.png
    ├── deposit.png
    ├── withdraw.png
    ├── transfer.png
    ├── statement.png
    └── logout.png
```

---

## Mode 1 — Mainframe (COBOL / CICS / VSAM)

The original implementation. Requires IBM z/OS with CICS, BMS, and VSAM.

### Architecture

```
3270 Terminal
     │
     ▼
CICS Transaction (CBNK)
     │
     ├─► CBLBANK  ← main screen controller
     │       ├─► CBLAUTH  (EXEC CICS LINK — authentication)
     │       └─► CBLTXN   (EXEC CICS LINK — transactions)
     │
     ├─► VSAM VSAMCBLK    (accounts, 37 bytes, key 10)
     └─► VSAM VSAMTXCB    (tx history, 36 bytes, key 15)
```

### BMS Screens (Mapset: CBLBKSET)

| Map | Description | Actions |
|-----|-------------|---------|
| CBLOGIN | Login | Q=Quit, R=Register, ENTER=Login |
| CBHOME | Home / balance | Q=Logout, D=Deposit, W=Withdraw, T=Transfer, S=Statement |
| CBREG | Account registration | Q=Back, C=Create |
| CBSTMT | Statement — last 5 transactions | Q=Back |

### VSAM Record Layout

**Account file (VSAMCBLK) — 37 bytes:**
```
WS-ACCNO    PIC 9(10)   ← indexed key
WS-PIN      PIC 9(10)
WS-BALANCE  PIC 9(10)
WS-ATTEMPTS PIC 9(1)    ← failed login counter (locks at 3)
WS-LOCKED   PIC 9(1)    ← 0=open, 1=locked
WS-TXCOUNT  PIC 9(5)    ← transaction sequence counter
```

**Transaction history file (VSAMTXCB) — 36 bytes:**
```
TX-ACCNO    PIC 9(10)   ← key part 1
TX-SEQNO    PIC 9(5)    ← key part 2
TX-TYPE     PIC X(1)    ← D=Deposit W=Withdraw T=Transfer
TX-AMOUNT   PIC 9(10)
TX-BALANCE  PIC 9(10)
```

### CICS Installation

```
CEDA DEFINE MAPSET(CBLBKSET)  GROUP(CBLBANK)
CEDA DEFINE TRANSACTION(CBNK) PROGRAM(CBLBANK) GROUP(CBLBANK)
CEDA DEFINE PROGRAM(CBLBANK)  GROUP(CBLBANK)
CEDA DEFINE PROGRAM(CBLAUTH)  GROUP(CBLBANK)
CEDA DEFINE PROGRAM(CBLTXN)   GROUP(CBLBANK)
CEDA DEFINE FILE(VSAMCBLK)    GROUP(CBLBANK) DSNAME(U0210.VSAM.CBLBANK)
CEDA DEFINE FILE(VSAMTXCB)    GROUP(CBLBANK) DSNAME(U0210.VSAM.CBLBANKTX)
```

See [CICS_install.cbl](CICS_install.cbl) for the full set of CEDA commands.

### Improvements Over the Original

| # | Feature | Implementation |
|---|---------|---------------|
| 1 | Account registration | `WRITE` to VSAM with duplicate key detection (RESP code 16) |
| 2 | Transfer between accounts | Reads both accounts, validates balance, rewrites both |
| 3 | Bug fix — deposit zero | `IF AMOUNT > ZEROS` before `ADD` |
| 4 | Bug fix — overdraft | `IF AMOUNT <= WS-BALANCE` before `SUBTRACT` |
| 5 | Bug fix — withdraw zero | `IF AMOUNT > ZEROS` before `SUBTRACT` |
| 6 | Descriptive error messages | `EVALUATE` on RESP/result codes, no raw numeric output |
| 7 | Transaction history screen | CBSTMT reads VSAM with `STARTBR/READPREV/ENDBR` |
| 8 | PIN masking | `ATTRB=(UNPROT,NUM,NORM,DRK)` on all PIN fields |
| 9 | Login lockout | WS-ATTEMPTS counter, locks at 3 wrong PINs |
| 10 | Subprogram architecture | CBLAUTH + CBLTXN via `EXEC CICS LINK PROGRAM(...)` |

---

## Mode 2 — Terminal (GnuCOBOL / WSL)

Pure COBOL running on any Linux or WSL environment. Replaces CICS/BMS/VSAM with native COBOL terminal I/O and indexed files. No mainframe required.

The terminal UI features a retro green phosphor CRT aesthetic inspired by the Alien: Isolation Sevastopol station terminals — green-on-black ANSI colors, ASCII block art, and Weyland-Yutani corporate branding.

### CICS → GnuCOBOL Translation

| Mainframe | GnuCOBOL |
|-----------|----------|
| `EXEC CICS SEND MAP` | `DISPLAY` |
| `EXEC CICS RECEIVE MAP` | `ACCEPT` |
| `EXEC CICS READ/REWRITE DATASET` | `READ/REWRITE` on indexed file |
| `EXEC CICS WRITE DATASET` | `WRITE` on indexed file |
| `EXEC CICS LINK PROGRAM(...)` | `CALL 'subprogram' USING ...` |
| `EXEC CICS RETURN` | `GOBACK` / `STOP RUN` |
| `EXEC CICS STARTBR/READPREV/ENDBR` | `START/READ PREVIOUS` on indexed file |
| VSAM cluster | COBOL indexed file (`ORGANIZATION IS INDEXED`) |
| BMS screen colors | ANSI escape codes via `CBCOLOR.cpy` copybook |

### Requirements

- Windows 11 with WSL 2
- Ubuntu 24.04 (via `wsl --install -d Ubuntu`)
- GnuCOBOL 3.1+ (via `sudo apt install gnucobol`)

### Setup (first time only)

```powershell
# 1. Install Ubuntu on WSL (PowerShell as Administrator)
wsl --install -d Ubuntu
```

```bash
# 2. Inside Ubuntu — install GnuCOBOL
sudo apt update && sudo apt install gnucobol -y

# 3. Go to the project folder
cd /mnt/c/Users/<your-user>/Documents/Projetos/CobolBank/gnucobol

# 4. Compile all programs
chmod +x compile.sh && ./compile.sh

# 5. Create demo accounts (run once)
./seed
```

### Running

```bash
cd /mnt/c/Users/<your-user>/Documents/Projetos/CobolBank/gnucobol
./cobolbank
```

### Stopping

To stop the application from inside: press `Q` on the login screen.

If the process is running in the background and needs to be force-killed:

```bash
# Find the process
pgrep -a cobolbank

# Kill it by PID
kill <PID>
```

### Terminal Interface

The terminal renders a full-screen Alien Isolation style UI with ANSI green phosphor colors:

```
  ==================================================
  >>  COBOLBANK FINANCIAL TERMINAL  //  REV 2.3.1
  SYSID: CBKV-2031  //  STATUS: NOMINAL
  ==================================================

   ####  ###  ####   ###  #     ####   ###  #   # #   #
  #     #   # #   # #   # #     #   # #   # ##  # #  #
  #     #   # ####  #   # #     ####  ##### # # # ###
  #     #   # #   # #   # #     #   # #   # #  ## #  #
   ####  ###  ####   ###  ##### ####  #   # #   # #   #

  ==================================================
  >>  WEYLAND-YUTANI CORP.  //  AUTHORIZED USE ONLY
  ==================================================

  ==================================================
  >>  AUTHENTICATION TERMINAL
  ==================================================
  [ PLEASE LOG IN!                               ]

  ACCOUNT.....: _
  PIN.........: _

  [ENTER]=LOGIN  [Q]=EXIT  [R]=REGISTER >
```

### ANSI Color System (`CBCOLOR.cpy`)

The `CBCOLOR.cpy` copybook provides ANSI escape code variables used across all screens:

| Variable | Code | Color |
|----------|------|-------|
| `CB-BGREEN` | `ESC[92m` | Bright green — primary text |
| `CB-GREEN` | `ESC[32m` | Dark green — borders/separators |
| `CB-YELLOW` | `ESC[33m` | Amber — status bar messages |
| `CB-BG-BLK` | `ESC[40m` | Black background |
| `CB-RESET` | `ESC[0m` | Reset all attributes |

### Demo Accounts

| Account | PIN | Balance |
|---------|-----|---------|
| 1000000001 | 1234 | $15,000 |
| 1000000002 | 5678 | $3,200 |
| 1000000003 | 1111 | $87,450 |

### Compiled Binaries

| File | Description |
|------|-------------|
| `cobolbank` | Main executable |
| `CBLAUTH.so` | Authentication shared module |
| `CBLTXN.so` | Transaction shared module |
| `seed` | Demo data loader (run once) |
| `CBLBANK.dat` | Account indexed data file |
| `CBLBANKTX.dat` | Transaction history indexed file |

---

## Mode 3 — CRT Terminal (Cool Retro Term)

The most authentic Alien: Isolation experience. Runs the GnuCOBOL terminal inside **Cool Retro Term**, a terminal emulator that simulates a real CRT phosphor screen with scanlines, bloom, flicker, screen curvature, and chromatic aberration.

### Requirements

- WSL 2 + Ubuntu (same as Mode 2)
- GnuCOBOL installed and compiled (same as Mode 2)
- Cool Retro Term 1.2+ (installed via apt on Ubuntu)
- WSLg — built into Windows 11 WSL2, enables Linux GUI apps natively

### Install Cool Retro Term

```bash
# Inside Ubuntu (WSL2)
sudo apt update && sudo apt install cool-retro-term -y
```

### Launch

```bash
# Option 1 — using the provided launcher script
bash /mnt/c/Users/<your-user>/Documents/Projetos/CobolBank/gnucobol/launch-crt.sh

# Option 2 — direct command (run from Ubuntu terminal)
DISPLAY=:0 cool-retro-term -e bash -c 'cd /mnt/c/Users/<your-user>/Documents/Projetos/CobolBank/gnucobol && ./cobolbank; bash' &
```

> **Note:** The `; bash` at the end keeps the Cool Retro Term window open after CobolBank exits, so you can inspect any output or relaunch manually. The `&` runs it in the background, returning control to the terminal immediately.

### Recommended CRT Profile Settings (Sevastopol)

Configure via `Edit → Settings → Effects` in Cool Retro Term:

| Setting | Value | Effect |
|---------|-------|--------|
| **Color Scheme** | Green Phosphor | Classic CRT green #00FF41 |
| **Font** | Monospace 14 | Clean fixed-width |
| Bloom | 0.45 | Phosphor glow around text |
| Burn-in | 0.40 | Phosphor persistence / ghost trails |
| Scanlines | 0.30 | Horizontal CRT scan lines |
| Flickering | 0.04 | Subtle screen instability |
| Screen curvature | 0.12 | CRT barrel distortion |
| Jitter | 0.08 | Horizontal sync jitter |
| Chroma color | 0.15 | RGB chromatic aberration |
| Noise | 0.03 | Static noise overlay |

Save as profile: **Settings → Save profile → "Sevastopol"**

### Visual Elements Simulated

| Alien: Isolation Effect | Implementation |
|------------------------|----------------|
| Green phosphor monochrome | ANSI `ESC[92m` bright green on black (`CBCOLOR.cpy`) |
| Scanlines | Cool Retro Term scanlines effect |
| Screen flicker | Cool Retro Term flickering effect |
| Phosphor burn-in | Cool Retro Term burn-in effect |
| CRT screen curvature | Cool Retro Term screen curvature |
| Chromatic aberration | Cool Retro Term chroma color + jitter |
| Lo-fi bitmap font | Block `#` ASCII art + monospace terminal font |
| Corporate terminal UI | Weyland-Yutani branding + `>>` prompt style |
| Status bar | `[ INFO MESSAGE... ]` fixed-width display |

---

## Testing (GnuCOBOL Terminal Mode)

All core operations were verified using `expect`-based automated testing on Ubuntu 24.04 (WSL 2) with GnuCOBOL. Tests were run against demo account `1000000001` (PIN `1234`, initial balance $15,000).

### Test Results

| # | Operation | Input | Expected | Result | Final Balance |
|---|-----------|-------|----------|--------|---------------|
| 1 | Login | Account `1000000001`, PIN `1234` | `WELCOME! LOGIN SUCCESSFUL.` | ✅ Pass | $15,000 |
| 2 | Deposit | $500 | `DEPOSIT SUCCESSFUL!` | ✅ Pass | $15,500 |
| 3 | Withdraw | $200 | `WITHDRAWAL SUCCESSFUL!` | ✅ Pass | $15,300 |
| 4 | Transfer | $100 → account `1000000002` | `TRANSFER SUCCESSFUL!` | ✅ Pass | $15,200 |
| 5 | Statement | — | Last 3 transactions listed | ✅ Pass | — |
| 6 | Logout | Q | Returns to login screen | ✅ Pass | — |

### Statement Output (after test sequence)

```
  TYPE       AMOUNT          BALANCE
  --------   ----------      ----------
  TRANSFER   $0000000100      $0000015200
  WITHDRAW   $0000000200      $0000015300
  DEPOSIT    $0000000500      $0000015500
```

### Bug Fixed During Testing

**`CBLTXN.cbl` — transaction file auto-creation**

`OPEN I-O CBLBANKTX.dat` failed with file status `'35'` (file not found) when no transactions had been recorded yet, causing all deposit/withdraw/transfer operations to return a generic error. Fixed by detecting status `'35'` and creating the file automatically on the first transaction:

```cobol
OPEN I-O TX-FILE
IF WS-TX-STATUS = '35'     ← file does not exist yet
  OPEN OUTPUT TX-FILE      ← create it
  CLOSE TX-FILE
  OPEN I-O TX-FILE         ← reopen for read/write
END-IF
```

### Running the Tests

```bash
# Prerequisites: expect installed
sudo apt install expect -y

# Reset demo accounts (required before each test run)
cd /mnt/c/Users/<your-user>/Documents/Projetos/CobolBank/gnucobol
./seed

# Run automated test
expect test_bank.exp
```

---

## Original Mainframe Screens

Screenshots of the original COBOL/CICS/BMS screens on a 3270 terminal:

|  |  |  |  |
|---|---|---|---|
| ![Loading screen](img/Loading.png)_Loading screen_ | ![Login screen](img/login.png)_Login screen_ | ![Register screen](img/register.png)_Register screen_ | ![Home screen](img/menu.png)_Home screen_ |
| ![Deposit screen](img/deposit.png)_Deposit screen_ | ![Withdraw screen](img/withdraw.png)_Withdraw screen_ | ![Transfer screen](img/transfer.png)_Transfer screen_ | ![Statement screen](img/statement.png)_Statement screen_ |
| ![Logout screen](img/logout.png)_Logout screen_ |  |  |  |

---

## Current Maintainer

Open-source contributions welcome.
