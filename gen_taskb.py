def btype(rs1, rs2, funct3, offset):
    o = offset & 0x1FFF
    imm12=(o>>12)&1; imm11=(o>>11)&1; imm10_5=(o>>5)&0x3F; imm4_1=(o>>1)&0xF
    return (imm12<<31)|(imm10_5<<25)|(rs2<<20)|(rs1<<15)|(funct3<<12)|(imm4_1<<8)|(imm11<<7)|0x63
def jtype(rd, offset):
    o=offset&0x1FFFFF; imm20=(o>>20)&1; imm10_1=(o>>1)&0x3FF; imm11=(o>>11)&1; imm19_12=(o>>12)&0xFF
    return (imm20<<31)|(imm10_1<<21)|(imm11<<20)|(imm19_12<<12)|(rd<<7)|0x6F
def itype(rd, rs1, f3, imm, op):
    imm12 = imm & 0xFFF
    return (imm12<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|op
def rtype(rd,rs1,rs2,f3,f7): return (f7<<25)|(rs2<<20)|(rs1<<15)|(f3<<12)|(rd<<7)|0x33
def utype(rd,imm20,op): return (imm20<<12)|(rd<<7)|op
def sw(base,src,off):
    imm11_5=(off>>5)&0x7F; imm4_0=off&0x1F
    return (imm11_5<<25)|(src<<20)|(base<<15)|(2<<12)|(imm4_0<<7)|0x23

x0,x10,x11,x12,x13,x14,x15,x30,x31=0,10,11,12,13,14,15,30,31
L=0x08  # loop address

instructions=[
 itype(x30,x0,0,768,0x13),           # 0x00 addi x30, x0, 768
 itype(x31,x0,0,512,0x13),           # 0x04 addi x31, x0, 512
 itype(x10,x30,2,0,3),               # 0x08 lw x10, 0(x30)  <- LOOP
 utype(x11,8,0x37),                  # 0x0C lui x11, 8
 rtype(x12,x10,x11,7,0),             # 0x10 and x12, x10, x11
 btype(x12,x0,1,0x44-0x14),          # 0x14 bne x12, x0, +48 -> do_lui
 utype(x11,4,0x37),                  # 0x18 lui x11, 4
 rtype(x12,x10,x11,7,0),             # 0x1C and x12, x10, x11
 btype(x12,x0,1,0x50-0x20),          # 0x20 bne x12, x0, +48 -> do_jal
 utype(x11,2,0x37),                  # 0x24 lui x11, 2
 rtype(x12,x10,x11,7,0),             # 0x28 and x12, x10, x11
 btype(x12,x0,1,0x60-0x2C),          # 0x2C bne x12, x0, +52 -> do_bneq
 utype(x11,1,0x37),                  # 0x30 lui x11, 1
 rtype(x12,x10,x11,7,0),             # 0x34 and x12, x10, x11
 btype(x12,x0,1,0x78-0x38),          # 0x38 bne x12, x0, +64 -> do_bneq2
 sw(x31,x0,0),                       # 0x3C sw x0, 0(x31)
 btype(x0,x0,0,L-0x40),              # 0x40 beq x0,x0,loop
 utype(x13,0x12345,0x37),            # 0x44 lui x13, 0x12345  <- do_lui
 sw(x31,x13,0),                      # 0x48 sw x13, 0(x31)
 btype(x0,x0,0,L-0x4C),              # 0x4C beq x0,x0,loop
 jtype(x0,0x54-0x50),                # 0x50 jal x0, +4 -> jal_target at 0x54
 utype(x13,0x96250,0x37),            # 0x54 lui x13, 0x96250  <- jal_target
 sw(x31,x13,0),                      # 0x58 sw x13, 0(x31)
 btype(x0,x0,0,L-0x5C),              # 0x5C beq x0,x0,loop
 itype(x14,x0,0,4,0x13),             # 0x60 addi x14, x0, 4  <- do_bneq (SW13)
 itype(x15,x0,0,4,0x13),             # 0x64 addi x15, x0, 4
 btype(x14,x15,1,0x74-0x68),         # 0x68 bne x14,x15,+12 (NOT taken: equal)
 sw(x31,x0,0),                       # 0x6C sw x0, 0(x31)  shows 0000
 btype(x0,x0,0,L-0x70),              # 0x70 beq x0,x0,loop
 btype(x0,x0,0,L-0x74),              # 0x74 skip1 (not reached)
 itype(x14,x0,0,4,0x13),             # 0x78 addi x14, x0, 4  <- do_bneq2 (SW12)
 itype(x15,x0,0,5,0x13),             # 0x7C addi x15, x0, 5
 btype(x14,x15,1,0x8C-0x80),         # 0x80 bne x14,x15,+12 (IS taken: not equal)
 sw(x31,x0,0),                       # 0x84 not reached
 btype(x0,x0,0,L-0x88),              # 0x88 not reached
 utype(x13,0x11111,0x37),            # 0x8C lui x13, 0x11111  <- show_t: seg=1111, leds=0x1000
 sw(x31,x13,0),                      # 0x90 sw x13, 0(x31)
 btype(x0,x0,0,L-0x94),              # 0x94 beq x0,x0,loop
]

for x in instructions:
    print(f'{x&0xFFFFFFFF:08X}')
