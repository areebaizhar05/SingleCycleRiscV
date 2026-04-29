def decode_b(val):
    imm12   = (val>>31)&1
    imm11   = (val>>7)&1
    imm10_5 = (val>>25)&0x3F
    imm4_1  = (val>>8)&0xF
    raw = (imm12<<12)|(imm11<<11)|(imm10_5<<5)|(imm4_1<<1)
    if imm12: raw -= (1<<13)
    return raw

def decode_j(val):
    imm20    = (val>>31)&1
    imm19_12 = (val>>12)&0xFF
    imm11    = (val>>20)&1
    imm10_1  = (val>>21)&0x3FF
    raw = (imm20<<20)|(imm19_12<<12)|(imm11<<11)|(imm10_1<<1)
    if imm20: raw -= (1<<21)
    return raw

# PC positions (byte addresses)
# [0]  PC=0   addi x30, x0, 768
# [1]  PC=4   addi x31, x0, 512
# [2]  PC=8   lw x5, 0(x30)         <- read_input
# [3]  PC=12  beq x5, x0, read_input
# [4]  PC=16  add x6, x0, x0
# [5]  PC=20  add x7, x0, x5
# [6]  PC=24  jal ra, add_subroutine  <- sum_loop
# [7]  PC=28  addi x7, x7, -1
# [8]  PC=32  bne x7, x0, sum_loop
# [9]  PC=36  lui x8, 0x1            <- display
# [10] PC=40  add x6, x6, x8
# [11] PC=44  sw x6, 0(x31)
# [12] PC=48  beq x0, x0, read_input
# [13] PC=52  add x6, x6, x7         <- add_subroutine
# [14] PC=56  jalr x0, ra, 0

read_input_pc  = 8
sum_loop_pc    = 24

print("=== Branch/Jump offset checks ===")

# [3] beq x5,x0,read_input  PC=12 -> target=8
needed = read_input_pc - 12
got = decode_b(int('FE028EE3',16))
print(f"[3] beq x5,x0,read_input  PC=12 target=8  needed={needed}  got={got}  {'OK' if needed==got else 'WRONG'}")

# [6] jal ra,add_subroutine  PC=24 -> target=52
needed = 52 - 24
got = decode_j(int('01C000EF',16))
print(f"[6] jal ra,add_sub        PC=24 target=52 needed={needed}  got={got}  {'OK' if needed==got else 'WRONG'}")

# [8] bne x7,x0,sum_loop  PC=32 -> target=24
needed = sum_loop_pc - 32
got = decode_b(int('FE039CE3',16))
print(f"[8] bne x7,x0,sum_loop    PC=32 target=24 needed={needed} got={got}  {'OK' if needed==got else 'WRONG'}")

# [12] beq x0,x0,read_input  PC=48 -> target=8
needed = read_input_pc - 48
got = decode_b(int('FC000CE3',16))
print(f"[12] beq x0,x0,read_input PC=48 target=8  needed={needed} got={got}  {'OK' if needed==got else 'WRONG'}")

print()
print("=== ADDI checks ===")
# addi x30, x0, 768 -> 0x300
val = int('30000F13',16)
imm = val>>20
print(f"[0] addi x30 imm=0x{imm:03X} (expected 0x300) {'OK' if imm==0x300 else 'WRONG'}")

val = int('20000F93',16)
imm = val>>20
print(f"[1] addi x31 imm=0x{imm:03X} (expected 0x200) {'OK' if imm==0x200 else 'WRONG'}")

print()
print("=== LUI check ===")
val = int('00001437',16)
imm20 = (val>>12) & 0xFFFFF
print(f"[9] lui x8 imm=0x{imm20:05X} (expected 0x00001) {'OK' if imm20==1 else 'WRONG'}")
print(f"    Result in x8 = 0x{imm20<<12:08X}")

print()
print("=== SW check ===")
val = int('006FA023',16)
rs2  = (val>>20)&0x1F
rs1  = (val>>15)&0x1F
imm = ((val>>25)<<5)|((val>>7)&0x1F)
if (imm>>11)&1: imm -= (1<<12)
print(f"[11] sw rs2=x{rs2} rs1=x{rs1} offset={imm}")
print(f"     SW writes to address = x31 + {imm} = 512 + {imm} = {512+imm} {'OK' if 512+imm==512 else 'WRONG'}")
