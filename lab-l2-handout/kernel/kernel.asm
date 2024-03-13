
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	9d013103          	ld	sp,-1584(sp) # 800089d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	9e070713          	addi	a4,a4,-1568 # 80008a30 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	07e78793          	addi	a5,a5,126 # 800060e0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc75f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	6d0080e7          	jalr	1744(ra) # 800027fa <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000186:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	9e650513          	addi	a0,a0,-1562 # 80010b70 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	9d648493          	addi	s1,s1,-1578 # 80010b70 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	a6690913          	addi	s2,s2,-1434 # 80010c08 <cons+0x98>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

        if (c == C('D'))
    800001aa:	4b91                	li	s7,4
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
            break;

        dst++;
        --n;

        if (c == '\n')
    800001ae:	4ca9                	li	s9,10
    while (n > 0)
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
        while (cons.r == cons.w)
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
            if (killed(myproc()))
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	a2e080e7          	jalr	-1490(ra) # 80001bee <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	47c080e7          	jalr	1148(ra) # 80002644 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	1c6080e7          	jalr	454(ra) # 8000239c <sleep>
        while (cons.r == cons.w)
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
        if (c == C('D'))
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
        cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	592080e7          	jalr	1426(ra) # 800027a4 <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1
        if (c == '\n')
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	94a50513          	addi	a0,a0,-1718 # 80010b70 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	93450513          	addi	a0,a0,-1740 # 80010b70 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
                return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
            if (n < target)
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
                cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	98f72b23          	sw	a5,-1642(a4) # 80010c08 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
        uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002cc:	00011517          	auipc	a0,0x11
    800002d0:	8a450513          	addi	a0,a0,-1884 # 80010b70 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

    switch (c)
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	55e080e7          	jalr	1374(ra) # 80002850 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	87650513          	addi	a0,a0,-1930 # 80010b70 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
    switch (c)
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031e:	00011717          	auipc	a4,0x11
    80000322:	85270713          	addi	a4,a4,-1966 # 80010b70 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
            consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00011797          	auipc	a5,0x11
    8000034c:	82878793          	addi	a5,a5,-2008 # 80010b70 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00011797          	auipc	a5,0x11
    8000037a:	8927a783          	lw	a5,-1902(a5) # 80010c08 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	7e670713          	addi	a4,a4,2022 # 80010b70 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	7d648493          	addi	s1,s1,2006 # 80010b70 <cons>
        while (cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
            cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
        while (cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	79a70713          	addi	a4,a4,1946 # 80010b70 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	82f72223          	sw	a5,-2012(a4) # 80010c10 <cons+0xa0>
            consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
            consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	75e78793          	addi	a5,a5,1886 # 80010b70 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	7cc7ab23          	sw	a2,2006(a5) # 80010c0c <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	7ca50513          	addi	a0,a0,1994 # 80010c08 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	fba080e7          	jalr	-70(ra) # 80002400 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	71050513          	addi	a0,a0,1808 # 80010b70 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	a9078793          	addi	a5,a5,-1392 # 80020f08 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	6e07a223          	sw	zero,1764(a5) # 80010c30 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	46f72823          	sw	a5,1136(a4) # 800089f0 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	674dad83          	lw	s11,1652(s11) # 80010c30 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	61e50513          	addi	a0,a0,1566 # 80010c18 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	4c050513          	addi	a0,a0,1216 # 80010c18 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	4a448493          	addi	s1,s1,1188 # 80010c18 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	46450513          	addi	a0,a0,1124 # 80010c38 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	1f07a783          	lw	a5,496(a5) # 800089f0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	1c07b783          	ld	a5,448(a5) # 800089f8 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	1c073703          	ld	a4,448(a4) # 80008a00 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	3d6a0a13          	addi	s4,s4,982 # 80010c38 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	18e48493          	addi	s1,s1,398 # 800089f8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	18e98993          	addi	s3,s3,398 # 80008a00 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	b6c080e7          	jalr	-1172(ra) # 80002400 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	36850513          	addi	a0,a0,872 # 80010c38 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	1107a783          	lw	a5,272(a5) # 800089f0 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	11673703          	ld	a4,278(a4) # 80008a00 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1067b783          	ld	a5,262(a5) # 800089f8 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	33a98993          	addi	s3,s3,826 # 80010c38 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	0f248493          	addi	s1,s1,242 # 800089f8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	0f290913          	addi	s2,s2,242 # 80008a00 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	a7e080e7          	jalr	-1410(ra) # 8000239c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	30448493          	addi	s1,s1,772 # 80010c38 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	0ae7bc23          	sd	a4,184(a5) # 80008a00 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	27e48493          	addi	s1,s1,638 # 80010c38 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	6a478793          	addi	a5,a5,1700 # 800220a0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	25490913          	addi	s2,s2,596 # 80010c70 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	1b650513          	addi	a0,a0,438 # 80010c70 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	5d250513          	addi	a0,a0,1490 # 800220a0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	18048493          	addi	s1,s1,384 # 80010c70 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	16850513          	addi	a0,a0,360 # 80010c70 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	13c50513          	addi	a0,a0,316 # 80010c70 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	062080e7          	jalr	98(ra) # 80001bd2 <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	030080e7          	jalr	48(ra) # 80001bd2 <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	024080e7          	jalr	36(ra) # 80001bd2 <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	00c080e7          	jalr	12(ra) # 80001bd2 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	fcc080e7          	jalr	-52(ra) # 80001bd2 <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	fa0080e7          	jalr	-96(ra) # 80001bd2 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdcf61>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	d42080e7          	jalr	-702(ra) # 80001bc2 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	b8070713          	addi	a4,a4,-1152 # 80008a08 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	d26080e7          	jalr	-730(ra) # 80001bc2 <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	c1a080e7          	jalr	-998(ra) # 80002ad8 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	25a080e7          	jalr	602(ra) # 80006120 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	3ac080e7          	jalr	940(ra) # 8000227a <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	bb2080e7          	jalr	-1102(ra) # 80001ae0 <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	b7a080e7          	jalr	-1158(ra) # 80002ab0 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	b9a080e7          	jalr	-1126(ra) # 80002ad8 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	1c4080e7          	jalr	452(ra) # 8000610a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	1d2080e7          	jalr	466(ra) # 80006120 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	36e080e7          	jalr	878(ra) # 800032c4 <binit>
    iinit();         // inode table
    80000f5e:	00003097          	auipc	ra,0x3
    80000f62:	a0e080e7          	jalr	-1522(ra) # 8000396c <iinit>
    fileinit();      // file table
    80000f66:	00004097          	auipc	ra,0x4
    80000f6a:	9b4080e7          	jalr	-1612(ra) # 8000491a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	2ba080e7          	jalr	698(ra) # 80006228 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	f50080e7          	jalr	-176(ra) # 80001ec6 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	a8f72223          	sw	a5,-1404(a4) # 80008a08 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	a787b783          	ld	a5,-1416(a5) # 80008a10 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdcf57>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00001097          	auipc	ra,0x1
    80001232:	81c080e7          	jalr	-2020(ra) # 80001a4a <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	7aa7be23          	sd	a0,1980(a5) # 80008a10 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdcf60>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    8000184a:	8792                	mv	a5,tp
    int id = r_tp();
    8000184c:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    8000184e:	0000fa97          	auipc	s5,0xf
    80001852:	442a8a93          	addi	s5,s5,1090 # 80010c90 <cpus>
    80001856:	00779713          	slli	a4,a5,0x7
    8000185a:	00ea86b3          	add	a3,s5,a4
    8000185e:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdcf60>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001862:	100026f3          	csrr	a3,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001866:	0026e693          	ori	a3,a3,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000186a:	10069073          	csrw	sstatus,a3
            // Switch to chosen process.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
            p->state = RUNNING;
            c->proc = p;
            swtch(&c->context, &p->context);
    8000186e:	0721                	addi	a4,a4,8
    80001870:	9aba                	add	s5,s5,a4
    for (p = proc; p < &proc[NPROC]; p++)
    80001872:	00010497          	auipc	s1,0x10
    80001876:	84e48493          	addi	s1,s1,-1970 # 800110c0 <proc>
        if (p->state == RUNNABLE)
    8000187a:	498d                	li	s3,3
            p->state = RUNNING;
    8000187c:	4b11                	li	s6,4
            c->proc = p;
    8000187e:	079e                	slli	a5,a5,0x7
    80001880:	0000fa17          	auipc	s4,0xf
    80001884:	410a0a13          	addi	s4,s4,1040 # 80010c90 <cpus>
    80001888:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    8000188a:	00015917          	auipc	s2,0x15
    8000188e:	43690913          	addi	s2,s2,1078 # 80016cc0 <tickslock>
    80001892:	a811                	j	800018a6 <rr_scheduler+0x70>

            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->proc = 0;
        }
        release(&p->lock);
    80001894:	8526                	mv	a0,s1
    80001896:	fffff097          	auipc	ra,0xfffff
    8000189a:	3f4080e7          	jalr	1012(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000189e:	17048493          	addi	s1,s1,368
    800018a2:	03248863          	beq	s1,s2,800018d2 <rr_scheduler+0x9c>
        acquire(&p->lock);
    800018a6:	8526                	mv	a0,s1
    800018a8:	fffff097          	auipc	ra,0xfffff
    800018ac:	32e080e7          	jalr	814(ra) # 80000bd6 <acquire>
        if (p->state == RUNNABLE)
    800018b0:	4c9c                	lw	a5,24(s1)
    800018b2:	ff3791e3          	bne	a5,s3,80001894 <rr_scheduler+0x5e>
            p->state = RUNNING;
    800018b6:	0164ac23          	sw	s6,24(s1)
            c->proc = p;
    800018ba:	009a3023          	sd	s1,0(s4)
            swtch(&c->context, &p->context);
    800018be:	06848593          	addi	a1,s1,104
    800018c2:	8556                	mv	a0,s5
    800018c4:	00001097          	auipc	ra,0x1
    800018c8:	182080e7          	jalr	386(ra) # 80002a46 <swtch>
            c->proc = 0;
    800018cc:	000a3023          	sd	zero,0(s4)
    800018d0:	b7d1                	j	80001894 <rr_scheduler+0x5e>
    }
    // In case a setsched happened, we will switch to the new scheduler after one
    // Round Robin round has completed.
}
    800018d2:	70e2                	ld	ra,56(sp)
    800018d4:	7442                	ld	s0,48(sp)
    800018d6:	74a2                	ld	s1,40(sp)
    800018d8:	7902                	ld	s2,32(sp)
    800018da:	69e2                	ld	s3,24(sp)
    800018dc:	6a42                	ld	s4,16(sp)
    800018de:	6aa2                	ld	s5,8(sp)
    800018e0:	6b02                	ld	s6,0(sp)
    800018e2:	6121                	addi	sp,sp,64
    800018e4:	8082                	ret

00000000800018e6 <mlfq_scheduler>:
#define LOW 1
#define TIME_SLICE_HIGH 5 // Time slice for high priority queue
#define TIME_SLICE_LOW 10 // Time slice for low priority queue
#define BOOST_PERIOD 100  // Time period after which all processes are boosted to high priority
void mlfq_scheduler(void)
{
    800018e6:	711d                	addi	sp,sp,-96
    800018e8:	ec86                	sd	ra,88(sp)
    800018ea:	e8a2                	sd	s0,80(sp)
    800018ec:	e4a6                	sd	s1,72(sp)
    800018ee:	e0ca                	sd	s2,64(sp)
    800018f0:	fc4e                	sd	s3,56(sp)
    800018f2:	f852                	sd	s4,48(sp)
    800018f4:	f456                	sd	s5,40(sp)
    800018f6:	f05a                	sd	s6,32(sp)
    800018f8:	ec5e                	sd	s7,24(sp)
    800018fa:	e862                	sd	s8,16(sp)
    800018fc:	e466                	sd	s9,8(sp)
    800018fe:	e06a                	sd	s10,0(sp)
    80001900:	1080                	addi	s0,sp,96
  asm volatile("mv %0, tp" : "=r" (x) );
    80001902:	8992                	mv	s3,tp
    int id = r_tp();
    80001904:	2981                	sext.w	s3,s3
    struct proc *p;
    struct cpu *c = mycpu();
    static int last_boost = 0;
    c->proc = 0;
    80001906:	00799713          	slli	a4,s3,0x7
    8000190a:	0000f797          	auipc	a5,0xf
    8000190e:	38678793          	addi	a5,a5,902 # 80010c90 <cpus>
    80001912:	97ba                	add	a5,a5,a4
    80001914:	0007b023          	sd	zero,0(a5)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001918:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000191c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001920:	10079073          	csrw	sstatus,a5
    intr_on(); // Ensure devices can interrupt
    // Check if it's time to boost the priority of all processes
    if (ticks - last_boost > BOOST_PERIOD)
    80001924:	00007797          	auipc	a5,0x7
    80001928:	1047a783          	lw	a5,260(a5) # 80008a28 <ticks>
    8000192c:	00007717          	auipc	a4,0x7
    80001930:	0ec72703          	lw	a4,236(a4) # 80008a18 <last_boost.2>
    80001934:	9f99                	subw	a5,a5,a4
    80001936:	06400713          	li	a4,100
    8000193a:	04f77663          	bgeu	a4,a5,80001986 <mlfq_scheduler+0xa0>
    {
        for (p = proc; p < &proc[NPROC]; p++)
    8000193e:	0000f497          	auipc	s1,0xf
    80001942:	78248493          	addi	s1,s1,1922 # 800110c0 <proc>
    80001946:	00015917          	auipc	s2,0x15
    8000194a:	37a90913          	addi	s2,s2,890 # 80016cc0 <tickslock>
    8000194e:	a811                	j	80001962 <mlfq_scheduler+0x7c>
            acquire(&p->lock);
            if (p->state != UNUSED)
            {
                p->priority = HIGH;
            }
            release(&p->lock);
    80001950:	8526                	mv	a0,s1
    80001952:	fffff097          	auipc	ra,0xfffff
    80001956:	338080e7          	jalr	824(ra) # 80000c8a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    8000195a:	17048493          	addi	s1,s1,368
    8000195e:	01248c63          	beq	s1,s2,80001976 <mlfq_scheduler+0x90>
            acquire(&p->lock);
    80001962:	8526                	mv	a0,s1
    80001964:	fffff097          	auipc	ra,0xfffff
    80001968:	272080e7          	jalr	626(ra) # 80000bd6 <acquire>
            if (p->state != UNUSED)
    8000196c:	4c9c                	lw	a5,24(s1)
    8000196e:	d3ed                	beqz	a5,80001950 <mlfq_scheduler+0x6a>
                p->priority = HIGH;
    80001970:	0004ae23          	sw	zero,28(s1)
    80001974:	bff1                	j	80001950 <mlfq_scheduler+0x6a>
        }
        last_boost = ticks;
    80001976:	00007797          	auipc	a5,0x7
    8000197a:	0b27a783          	lw	a5,178(a5) # 80008a28 <ticks>
    8000197e:	00007717          	auipc	a4,0x7
    80001982:	08f72d23          	sw	a5,154(a4) # 80008a18 <last_boost.2>
            acquire(&p->lock);
            if (p->state == RUNNABLE && p->priority == priority)
            {
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001986:	00799c13          	slli	s8,s3,0x7
    8000198a:	0000f797          	auipc	a5,0xf
    8000198e:	30e78793          	addi	a5,a5,782 # 80010c98 <cpus+0x8>
    80001992:	9c3e                	add	s8,s8,a5
    80001994:	4c81                	li	s9,0
            if (p->state == RUNNABLE && p->priority == priority)
    80001996:	4a0d                	li	s4,3
                p->state = RUNNING;
    80001998:	4b91                	li	s7,4
                c->proc = p;
    8000199a:	099e                	slli	s3,s3,0x7
    8000199c:	0000fb17          	auipc	s6,0xf
    800019a0:	2f4b0b13          	addi	s6,s6,756 # 80010c90 <cpus>
    800019a4:	9b4e                	add	s6,s6,s3
        for (p = proc; p < &proc[NPROC]; p++)
    800019a6:	00015997          	auipc	s3,0x15
    800019aa:	31a98993          	addi	s3,s3,794 # 80016cc0 <tickslock>
    800019ae:	a885                	j	80001a1e <mlfq_scheduler+0x138>
                // After running, check if the process used up its entire time slice
                if (p->priority == HIGH && p->time_slice_used >= TIME_SLICE_HIGH)
                {
                    p->priority = LOW; // Demote to low priority queue
                }
                else if (p->priority == LOW && p->time_slice_used >= TIME_SLICE_LOW)
    800019b0:	01a79863          	bne	a5,s10,800019c0 <mlfq_scheduler+0xda>
    800019b4:	5098                	lw	a4,32(s1)
    800019b6:	47a5                	li	a5,9
    800019b8:	00e7d463          	bge	a5,a4,800019c0 <mlfq_scheduler+0xda>
                {
                    p->priority = HIGH; // Boost back to high priority queue as a simplification
    800019bc:	0004ae23          	sw	zero,28(s1)
                }
                p->time_slice_used = 0; // Reset time slice usage for next scheduling round
    800019c0:	0204a023          	sw	zero,32(s1)
                c->proc = 0;
    800019c4:	000b3023          	sd	zero,0(s6)
            }
            release(&p->lock);
    800019c8:	8526                	mv	a0,s1
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	2c0080e7          	jalr	704(ra) # 80000c8a <release>
        for (p = proc; p < &proc[NPROC]; p++)
    800019d2:	17048493          	addi	s1,s1,368
    800019d6:	05348063          	beq	s1,s3,80001a16 <mlfq_scheduler+0x130>
            acquire(&p->lock);
    800019da:	8526                	mv	a0,s1
    800019dc:	fffff097          	auipc	ra,0xfffff
    800019e0:	1fa080e7          	jalr	506(ra) # 80000bd6 <acquire>
            if (p->state == RUNNABLE && p->priority == priority)
    800019e4:	4c9c                	lw	a5,24(s1)
    800019e6:	ff4791e3          	bne	a5,s4,800019c8 <mlfq_scheduler+0xe2>
    800019ea:	4cdc                	lw	a5,28(s1)
    800019ec:	fd579ee3          	bne	a5,s5,800019c8 <mlfq_scheduler+0xe2>
                p->state = RUNNING;
    800019f0:	0174ac23          	sw	s7,24(s1)
                c->proc = p;
    800019f4:	009b3023          	sd	s1,0(s6)
                swtch(&c->context, &p->context);
    800019f8:	06848593          	addi	a1,s1,104
    800019fc:	8562                	mv	a0,s8
    800019fe:	00001097          	auipc	ra,0x1
    80001a02:	048080e7          	jalr	72(ra) # 80002a46 <swtch>
                if (p->priority == HIGH && p->time_slice_used >= TIME_SLICE_HIGH)
    80001a06:	4cdc                	lw	a5,28(s1)
    80001a08:	f7c5                	bnez	a5,800019b0 <mlfq_scheduler+0xca>
    80001a0a:	509c                	lw	a5,32(s1)
    80001a0c:	fafbdae3          	bge	s7,a5,800019c0 <mlfq_scheduler+0xda>
                    p->priority = LOW; // Demote to low priority queue
    80001a10:	01a4ae23          	sw	s10,28(s1)
    80001a14:	b775                	j	800019c0 <mlfq_scheduler+0xda>
    for (int priority = HIGH; priority <= LOW; priority++)
    80001a16:	2c85                	addiw	s9,s9,1
    80001a18:	4789                	li	a5,2
    80001a1a:	00fc8a63          	beq	s9,a5,80001a2e <mlfq_scheduler+0x148>
        for (p = proc; p < &proc[NPROC]; p++)
    80001a1e:	0000f497          	auipc	s1,0xf
    80001a22:	6a248493          	addi	s1,s1,1698 # 800110c0 <proc>
            if (p->state == RUNNABLE && p->priority == priority)
    80001a26:	000c8a9b          	sext.w	s5,s9
                else if (p->priority == LOW && p->time_slice_used >= TIME_SLICE_LOW)
    80001a2a:	4d05                	li	s10,1
    80001a2c:	b77d                	j	800019da <mlfq_scheduler+0xf4>
        }
    }
}
    80001a2e:	60e6                	ld	ra,88(sp)
    80001a30:	6446                	ld	s0,80(sp)
    80001a32:	64a6                	ld	s1,72(sp)
    80001a34:	6906                	ld	s2,64(sp)
    80001a36:	79e2                	ld	s3,56(sp)
    80001a38:	7a42                	ld	s4,48(sp)
    80001a3a:	7aa2                	ld	s5,40(sp)
    80001a3c:	7b02                	ld	s6,32(sp)
    80001a3e:	6be2                	ld	s7,24(sp)
    80001a40:	6c42                	ld	s8,16(sp)
    80001a42:	6ca2                	ld	s9,8(sp)
    80001a44:	6d02                	ld	s10,0(sp)
    80001a46:	6125                	addi	sp,sp,96
    80001a48:	8082                	ret

0000000080001a4a <proc_mapstacks>:
{
    80001a4a:	7139                	addi	sp,sp,-64
    80001a4c:	fc06                	sd	ra,56(sp)
    80001a4e:	f822                	sd	s0,48(sp)
    80001a50:	f426                	sd	s1,40(sp)
    80001a52:	f04a                	sd	s2,32(sp)
    80001a54:	ec4e                	sd	s3,24(sp)
    80001a56:	e852                	sd	s4,16(sp)
    80001a58:	e456                	sd	s5,8(sp)
    80001a5a:	e05a                	sd	s6,0(sp)
    80001a5c:	0080                	addi	s0,sp,64
    80001a5e:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001a60:	0000f497          	auipc	s1,0xf
    80001a64:	66048493          	addi	s1,s1,1632 # 800110c0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001a68:	8b26                	mv	s6,s1
    80001a6a:	00006a97          	auipc	s5,0x6
    80001a6e:	596a8a93          	addi	s5,s5,1430 # 80008000 <etext>
    80001a72:	04000937          	lui	s2,0x4000
    80001a76:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001a78:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001a7a:	00015a17          	auipc	s4,0x15
    80001a7e:	246a0a13          	addi	s4,s4,582 # 80016cc0 <tickslock>
        char *pa = kalloc();
    80001a82:	fffff097          	auipc	ra,0xfffff
    80001a86:	064080e7          	jalr	100(ra) # 80000ae6 <kalloc>
    80001a8a:	862a                	mv	a2,a0
        if (pa == 0)
    80001a8c:	c131                	beqz	a0,80001ad0 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001a8e:	416485b3          	sub	a1,s1,s6
    80001a92:	8591                	srai	a1,a1,0x4
    80001a94:	000ab783          	ld	a5,0(s5)
    80001a98:	02f585b3          	mul	a1,a1,a5
    80001a9c:	2585                	addiw	a1,a1,1
    80001a9e:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001aa2:	4719                	li	a4,6
    80001aa4:	6685                	lui	a3,0x1
    80001aa6:	40b905b3          	sub	a1,s2,a1
    80001aaa:	854e                	mv	a0,s3
    80001aac:	fffff097          	auipc	ra,0xfffff
    80001ab0:	692080e7          	jalr	1682(ra) # 8000113e <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001ab4:	17048493          	addi	s1,s1,368
    80001ab8:	fd4495e3          	bne	s1,s4,80001a82 <proc_mapstacks+0x38>
}
    80001abc:	70e2                	ld	ra,56(sp)
    80001abe:	7442                	ld	s0,48(sp)
    80001ac0:	74a2                	ld	s1,40(sp)
    80001ac2:	7902                	ld	s2,32(sp)
    80001ac4:	69e2                	ld	s3,24(sp)
    80001ac6:	6a42                	ld	s4,16(sp)
    80001ac8:	6aa2                	ld	s5,8(sp)
    80001aca:	6b02                	ld	s6,0(sp)
    80001acc:	6121                	addi	sp,sp,64
    80001ace:	8082                	ret
            panic("kalloc");
    80001ad0:	00006517          	auipc	a0,0x6
    80001ad4:	70850513          	addi	a0,a0,1800 # 800081d8 <digits+0x198>
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	a68080e7          	jalr	-1432(ra) # 80000540 <panic>

0000000080001ae0 <procinit>:
{
    80001ae0:	7139                	addi	sp,sp,-64
    80001ae2:	fc06                	sd	ra,56(sp)
    80001ae4:	f822                	sd	s0,48(sp)
    80001ae6:	f426                	sd	s1,40(sp)
    80001ae8:	f04a                	sd	s2,32(sp)
    80001aea:	ec4e                	sd	s3,24(sp)
    80001aec:	e852                	sd	s4,16(sp)
    80001aee:	e456                	sd	s5,8(sp)
    80001af0:	e05a                	sd	s6,0(sp)
    80001af2:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001af4:	00006597          	auipc	a1,0x6
    80001af8:	6ec58593          	addi	a1,a1,1772 # 800081e0 <digits+0x1a0>
    80001afc:	0000f517          	auipc	a0,0xf
    80001b00:	59450513          	addi	a0,a0,1428 # 80011090 <pid_lock>
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	042080e7          	jalr	66(ra) # 80000b46 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b0c:	00006597          	auipc	a1,0x6
    80001b10:	6dc58593          	addi	a1,a1,1756 # 800081e8 <digits+0x1a8>
    80001b14:	0000f517          	auipc	a0,0xf
    80001b18:	59450513          	addi	a0,a0,1428 # 800110a8 <wait_lock>
    80001b1c:	fffff097          	auipc	ra,0xfffff
    80001b20:	02a080e7          	jalr	42(ra) # 80000b46 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b24:	0000f497          	auipc	s1,0xf
    80001b28:	59c48493          	addi	s1,s1,1436 # 800110c0 <proc>
        initlock(&p->lock, "proc");
    80001b2c:	00006b17          	auipc	s6,0x6
    80001b30:	6ccb0b13          	addi	s6,s6,1740 # 800081f8 <digits+0x1b8>
        p->kstack = KSTACK((int)(p - proc));
    80001b34:	8aa6                	mv	s5,s1
    80001b36:	00006a17          	auipc	s4,0x6
    80001b3a:	4caa0a13          	addi	s4,s4,1226 # 80008000 <etext>
    80001b3e:	04000937          	lui	s2,0x4000
    80001b42:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b44:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b46:	00015997          	auipc	s3,0x15
    80001b4a:	17a98993          	addi	s3,s3,378 # 80016cc0 <tickslock>
        initlock(&p->lock, "proc");
    80001b4e:	85da                	mv	a1,s6
    80001b50:	8526                	mv	a0,s1
    80001b52:	fffff097          	auipc	ra,0xfffff
    80001b56:	ff4080e7          	jalr	-12(ra) # 80000b46 <initlock>
        p->state = UNUSED;
    80001b5a:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001b5e:	415487b3          	sub	a5,s1,s5
    80001b62:	8791                	srai	a5,a5,0x4
    80001b64:	000a3703          	ld	a4,0(s4)
    80001b68:	02e787b3          	mul	a5,a5,a4
    80001b6c:	2785                	addiw	a5,a5,1
    80001b6e:	00d7979b          	slliw	a5,a5,0xd
    80001b72:	40f907b3          	sub	a5,s2,a5
    80001b76:	e4bc                	sd	a5,72(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001b78:	17048493          	addi	s1,s1,368
    80001b7c:	fd3499e3          	bne	s1,s3,80001b4e <procinit+0x6e>
}
    80001b80:	70e2                	ld	ra,56(sp)
    80001b82:	7442                	ld	s0,48(sp)
    80001b84:	74a2                	ld	s1,40(sp)
    80001b86:	7902                	ld	s2,32(sp)
    80001b88:	69e2                	ld	s3,24(sp)
    80001b8a:	6a42                	ld	s4,16(sp)
    80001b8c:	6aa2                	ld	s5,8(sp)
    80001b8e:	6b02                	ld	s6,0(sp)
    80001b90:	6121                	addi	sp,sp,64
    80001b92:	8082                	ret

0000000080001b94 <copy_array>:
{
    80001b94:	1141                	addi	sp,sp,-16
    80001b96:	e422                	sd	s0,8(sp)
    80001b98:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001b9a:	02c05163          	blez	a2,80001bbc <copy_array+0x28>
    80001b9e:	87aa                	mv	a5,a0
    80001ba0:	0505                	addi	a0,a0,1
    80001ba2:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001ba4:	1602                	slli	a2,a2,0x20
    80001ba6:	9201                	srli	a2,a2,0x20
    80001ba8:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001bac:	0007c703          	lbu	a4,0(a5)
    80001bb0:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001bb4:	0785                	addi	a5,a5,1
    80001bb6:	0585                	addi	a1,a1,1
    80001bb8:	fed79ae3          	bne	a5,a3,80001bac <copy_array+0x18>
}
    80001bbc:	6422                	ld	s0,8(sp)
    80001bbe:	0141                	addi	sp,sp,16
    80001bc0:	8082                	ret

0000000080001bc2 <cpuid>:
{
    80001bc2:	1141                	addi	sp,sp,-16
    80001bc4:	e422                	sd	s0,8(sp)
    80001bc6:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bc8:	8512                	mv	a0,tp
}
    80001bca:	2501                	sext.w	a0,a0
    80001bcc:	6422                	ld	s0,8(sp)
    80001bce:	0141                	addi	sp,sp,16
    80001bd0:	8082                	ret

0000000080001bd2 <mycpu>:
{
    80001bd2:	1141                	addi	sp,sp,-16
    80001bd4:	e422                	sd	s0,8(sp)
    80001bd6:	0800                	addi	s0,sp,16
    80001bd8:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001bda:	2781                	sext.w	a5,a5
    80001bdc:	079e                	slli	a5,a5,0x7
}
    80001bde:	0000f517          	auipc	a0,0xf
    80001be2:	0b250513          	addi	a0,a0,178 # 80010c90 <cpus>
    80001be6:	953e                	add	a0,a0,a5
    80001be8:	6422                	ld	s0,8(sp)
    80001bea:	0141                	addi	sp,sp,16
    80001bec:	8082                	ret

0000000080001bee <myproc>:
{
    80001bee:	1101                	addi	sp,sp,-32
    80001bf0:	ec06                	sd	ra,24(sp)
    80001bf2:	e822                	sd	s0,16(sp)
    80001bf4:	e426                	sd	s1,8(sp)
    80001bf6:	1000                	addi	s0,sp,32
    push_off();
    80001bf8:	fffff097          	auipc	ra,0xfffff
    80001bfc:	f92080e7          	jalr	-110(ra) # 80000b8a <push_off>
    80001c00:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c02:	2781                	sext.w	a5,a5
    80001c04:	079e                	slli	a5,a5,0x7
    80001c06:	0000f717          	auipc	a4,0xf
    80001c0a:	08a70713          	addi	a4,a4,138 # 80010c90 <cpus>
    80001c0e:	97ba                	add	a5,a5,a4
    80001c10:	6384                	ld	s1,0(a5)
    pop_off();
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	018080e7          	jalr	24(ra) # 80000c2a <pop_off>
}
    80001c1a:	8526                	mv	a0,s1
    80001c1c:	60e2                	ld	ra,24(sp)
    80001c1e:	6442                	ld	s0,16(sp)
    80001c20:	64a2                	ld	s1,8(sp)
    80001c22:	6105                	addi	sp,sp,32
    80001c24:	8082                	ret

0000000080001c26 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c26:	1141                	addi	sp,sp,-16
    80001c28:	e406                	sd	ra,8(sp)
    80001c2a:	e022                	sd	s0,0(sp)
    80001c2c:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c2e:	00000097          	auipc	ra,0x0
    80001c32:	fc0080e7          	jalr	-64(ra) # 80001bee <myproc>
    80001c36:	fffff097          	auipc	ra,0xfffff
    80001c3a:	054080e7          	jalr	84(ra) # 80000c8a <release>

    if (first)
    80001c3e:	00007797          	auipc	a5,0x7
    80001c42:	cf27a783          	lw	a5,-782(a5) # 80008930 <first.1>
    80001c46:	eb89                	bnez	a5,80001c58 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001c48:	00001097          	auipc	ra,0x1
    80001c4c:	ea8080e7          	jalr	-344(ra) # 80002af0 <usertrapret>
}
    80001c50:	60a2                	ld	ra,8(sp)
    80001c52:	6402                	ld	s0,0(sp)
    80001c54:	0141                	addi	sp,sp,16
    80001c56:	8082                	ret
        first = 0;
    80001c58:	00007797          	auipc	a5,0x7
    80001c5c:	cc07ac23          	sw	zero,-808(a5) # 80008930 <first.1>
        fsinit(ROOTDEV);
    80001c60:	4505                	li	a0,1
    80001c62:	00002097          	auipc	ra,0x2
    80001c66:	c8a080e7          	jalr	-886(ra) # 800038ec <fsinit>
    80001c6a:	bff9                	j	80001c48 <forkret+0x22>

0000000080001c6c <allocpid>:
{
    80001c6c:	1101                	addi	sp,sp,-32
    80001c6e:	ec06                	sd	ra,24(sp)
    80001c70:	e822                	sd	s0,16(sp)
    80001c72:	e426                	sd	s1,8(sp)
    80001c74:	e04a                	sd	s2,0(sp)
    80001c76:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001c78:	0000f917          	auipc	s2,0xf
    80001c7c:	41890913          	addi	s2,s2,1048 # 80011090 <pid_lock>
    80001c80:	854a                	mv	a0,s2
    80001c82:	fffff097          	auipc	ra,0xfffff
    80001c86:	f54080e7          	jalr	-172(ra) # 80000bd6 <acquire>
    pid = nextpid;
    80001c8a:	00007797          	auipc	a5,0x7
    80001c8e:	cb678793          	addi	a5,a5,-842 # 80008940 <nextpid>
    80001c92:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001c94:	0014871b          	addiw	a4,s1,1
    80001c98:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001c9a:	854a                	mv	a0,s2
    80001c9c:	fffff097          	auipc	ra,0xfffff
    80001ca0:	fee080e7          	jalr	-18(ra) # 80000c8a <release>
}
    80001ca4:	8526                	mv	a0,s1
    80001ca6:	60e2                	ld	ra,24(sp)
    80001ca8:	6442                	ld	s0,16(sp)
    80001caa:	64a2                	ld	s1,8(sp)
    80001cac:	6902                	ld	s2,0(sp)
    80001cae:	6105                	addi	sp,sp,32
    80001cb0:	8082                	ret

0000000080001cb2 <proc_pagetable>:
{
    80001cb2:	1101                	addi	sp,sp,-32
    80001cb4:	ec06                	sd	ra,24(sp)
    80001cb6:	e822                	sd	s0,16(sp)
    80001cb8:	e426                	sd	s1,8(sp)
    80001cba:	e04a                	sd	s2,0(sp)
    80001cbc:	1000                	addi	s0,sp,32
    80001cbe:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001cc0:	fffff097          	auipc	ra,0xfffff
    80001cc4:	668080e7          	jalr	1640(ra) # 80001328 <uvmcreate>
    80001cc8:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001cca:	c121                	beqz	a0,80001d0a <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ccc:	4729                	li	a4,10
    80001cce:	00005697          	auipc	a3,0x5
    80001cd2:	33268693          	addi	a3,a3,818 # 80007000 <_trampoline>
    80001cd6:	6605                	lui	a2,0x1
    80001cd8:	040005b7          	lui	a1,0x4000
    80001cdc:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001cde:	05b2                	slli	a1,a1,0xc
    80001ce0:	fffff097          	auipc	ra,0xfffff
    80001ce4:	3be080e7          	jalr	958(ra) # 8000109e <mappages>
    80001ce8:	02054863          	bltz	a0,80001d18 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001cec:	4719                	li	a4,6
    80001cee:	06093683          	ld	a3,96(s2)
    80001cf2:	6605                	lui	a2,0x1
    80001cf4:	020005b7          	lui	a1,0x2000
    80001cf8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001cfa:	05b6                	slli	a1,a1,0xd
    80001cfc:	8526                	mv	a0,s1
    80001cfe:	fffff097          	auipc	ra,0xfffff
    80001d02:	3a0080e7          	jalr	928(ra) # 8000109e <mappages>
    80001d06:	02054163          	bltz	a0,80001d28 <proc_pagetable+0x76>
}
    80001d0a:	8526                	mv	a0,s1
    80001d0c:	60e2                	ld	ra,24(sp)
    80001d0e:	6442                	ld	s0,16(sp)
    80001d10:	64a2                	ld	s1,8(sp)
    80001d12:	6902                	ld	s2,0(sp)
    80001d14:	6105                	addi	sp,sp,32
    80001d16:	8082                	ret
        uvmfree(pagetable, 0);
    80001d18:	4581                	li	a1,0
    80001d1a:	8526                	mv	a0,s1
    80001d1c:	00000097          	auipc	ra,0x0
    80001d20:	812080e7          	jalr	-2030(ra) # 8000152e <uvmfree>
        return 0;
    80001d24:	4481                	li	s1,0
    80001d26:	b7d5                	j	80001d0a <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d28:	4681                	li	a3,0
    80001d2a:	4605                	li	a2,1
    80001d2c:	040005b7          	lui	a1,0x4000
    80001d30:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d32:	05b2                	slli	a1,a1,0xc
    80001d34:	8526                	mv	a0,s1
    80001d36:	fffff097          	auipc	ra,0xfffff
    80001d3a:	52e080e7          	jalr	1326(ra) # 80001264 <uvmunmap>
        uvmfree(pagetable, 0);
    80001d3e:	4581                	li	a1,0
    80001d40:	8526                	mv	a0,s1
    80001d42:	fffff097          	auipc	ra,0xfffff
    80001d46:	7ec080e7          	jalr	2028(ra) # 8000152e <uvmfree>
        return 0;
    80001d4a:	4481                	li	s1,0
    80001d4c:	bf7d                	j	80001d0a <proc_pagetable+0x58>

0000000080001d4e <proc_freepagetable>:
{
    80001d4e:	1101                	addi	sp,sp,-32
    80001d50:	ec06                	sd	ra,24(sp)
    80001d52:	e822                	sd	s0,16(sp)
    80001d54:	e426                	sd	s1,8(sp)
    80001d56:	e04a                	sd	s2,0(sp)
    80001d58:	1000                	addi	s0,sp,32
    80001d5a:	84aa                	mv	s1,a0
    80001d5c:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d5e:	4681                	li	a3,0
    80001d60:	4605                	li	a2,1
    80001d62:	040005b7          	lui	a1,0x4000
    80001d66:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d68:	05b2                	slli	a1,a1,0xc
    80001d6a:	fffff097          	auipc	ra,0xfffff
    80001d6e:	4fa080e7          	jalr	1274(ra) # 80001264 <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001d72:	4681                	li	a3,0
    80001d74:	4605                	li	a2,1
    80001d76:	020005b7          	lui	a1,0x2000
    80001d7a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d7c:	05b6                	slli	a1,a1,0xd
    80001d7e:	8526                	mv	a0,s1
    80001d80:	fffff097          	auipc	ra,0xfffff
    80001d84:	4e4080e7          	jalr	1252(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, sz);
    80001d88:	85ca                	mv	a1,s2
    80001d8a:	8526                	mv	a0,s1
    80001d8c:	fffff097          	auipc	ra,0xfffff
    80001d90:	7a2080e7          	jalr	1954(ra) # 8000152e <uvmfree>
}
    80001d94:	60e2                	ld	ra,24(sp)
    80001d96:	6442                	ld	s0,16(sp)
    80001d98:	64a2                	ld	s1,8(sp)
    80001d9a:	6902                	ld	s2,0(sp)
    80001d9c:	6105                	addi	sp,sp,32
    80001d9e:	8082                	ret

0000000080001da0 <freeproc>:
{
    80001da0:	1101                	addi	sp,sp,-32
    80001da2:	ec06                	sd	ra,24(sp)
    80001da4:	e822                	sd	s0,16(sp)
    80001da6:	e426                	sd	s1,8(sp)
    80001da8:	1000                	addi	s0,sp,32
    80001daa:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001dac:	7128                	ld	a0,96(a0)
    80001dae:	c509                	beqz	a0,80001db8 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	c38080e7          	jalr	-968(ra) # 800009e8 <kfree>
    p->trapframe = 0;
    80001db8:	0604b023          	sd	zero,96(s1)
    if (p->pagetable)
    80001dbc:	6ca8                	ld	a0,88(s1)
    80001dbe:	c511                	beqz	a0,80001dca <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001dc0:	68ac                	ld	a1,80(s1)
    80001dc2:	00000097          	auipc	ra,0x0
    80001dc6:	f8c080e7          	jalr	-116(ra) # 80001d4e <proc_freepagetable>
    p->pagetable = 0;
    80001dca:	0404bc23          	sd	zero,88(s1)
    p->sz = 0;
    80001dce:	0404b823          	sd	zero,80(s1)
    p->pid = 0;
    80001dd2:	0204ac23          	sw	zero,56(s1)
    p->parent = 0;
    80001dd6:	0404b023          	sd	zero,64(s1)
    p->name[0] = 0;
    80001dda:	16048023          	sb	zero,352(s1)
    p->chan = 0;
    80001dde:	0204b423          	sd	zero,40(s1)
    p->killed = 0;
    80001de2:	0204a823          	sw	zero,48(s1)
    p->xstate = 0;
    80001de6:	0204aa23          	sw	zero,52(s1)
    p->state = UNUSED;
    80001dea:	0004ac23          	sw	zero,24(s1)
}
    80001dee:	60e2                	ld	ra,24(sp)
    80001df0:	6442                	ld	s0,16(sp)
    80001df2:	64a2                	ld	s1,8(sp)
    80001df4:	6105                	addi	sp,sp,32
    80001df6:	8082                	ret

0000000080001df8 <allocproc>:
{
    80001df8:	1101                	addi	sp,sp,-32
    80001dfa:	ec06                	sd	ra,24(sp)
    80001dfc:	e822                	sd	s0,16(sp)
    80001dfe:	e426                	sd	s1,8(sp)
    80001e00:	e04a                	sd	s2,0(sp)
    80001e02:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e04:	0000f497          	auipc	s1,0xf
    80001e08:	2bc48493          	addi	s1,s1,700 # 800110c0 <proc>
    80001e0c:	00015917          	auipc	s2,0x15
    80001e10:	eb490913          	addi	s2,s2,-332 # 80016cc0 <tickslock>
        acquire(&p->lock);
    80001e14:	8526                	mv	a0,s1
    80001e16:	fffff097          	auipc	ra,0xfffff
    80001e1a:	dc0080e7          	jalr	-576(ra) # 80000bd6 <acquire>
        if (p->state == UNUSED)
    80001e1e:	4c9c                	lw	a5,24(s1)
    80001e20:	cf81                	beqz	a5,80001e38 <allocproc+0x40>
            release(&p->lock);
    80001e22:	8526                	mv	a0,s1
    80001e24:	fffff097          	auipc	ra,0xfffff
    80001e28:	e66080e7          	jalr	-410(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e2c:	17048493          	addi	s1,s1,368
    80001e30:	ff2492e3          	bne	s1,s2,80001e14 <allocproc+0x1c>
    return 0;
    80001e34:	4481                	li	s1,0
    80001e36:	a889                	j	80001e88 <allocproc+0x90>
    p->pid = allocpid();
    80001e38:	00000097          	auipc	ra,0x0
    80001e3c:	e34080e7          	jalr	-460(ra) # 80001c6c <allocpid>
    80001e40:	dc88                	sw	a0,56(s1)
    p->state = USED;
    80001e42:	4785                	li	a5,1
    80001e44:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e46:	fffff097          	auipc	ra,0xfffff
    80001e4a:	ca0080e7          	jalr	-864(ra) # 80000ae6 <kalloc>
    80001e4e:	892a                	mv	s2,a0
    80001e50:	f0a8                	sd	a0,96(s1)
    80001e52:	c131                	beqz	a0,80001e96 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001e54:	8526                	mv	a0,s1
    80001e56:	00000097          	auipc	ra,0x0
    80001e5a:	e5c080e7          	jalr	-420(ra) # 80001cb2 <proc_pagetable>
    80001e5e:	892a                	mv	s2,a0
    80001e60:	eca8                	sd	a0,88(s1)
    if (p->pagetable == 0)
    80001e62:	c531                	beqz	a0,80001eae <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001e64:	07000613          	li	a2,112
    80001e68:	4581                	li	a1,0
    80001e6a:	06848513          	addi	a0,s1,104
    80001e6e:	fffff097          	auipc	ra,0xfffff
    80001e72:	e64080e7          	jalr	-412(ra) # 80000cd2 <memset>
    p->context.ra = (uint64)forkret;
    80001e76:	00000797          	auipc	a5,0x0
    80001e7a:	db078793          	addi	a5,a5,-592 # 80001c26 <forkret>
    80001e7e:	f4bc                	sd	a5,104(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001e80:	64bc                	ld	a5,72(s1)
    80001e82:	6705                	lui	a4,0x1
    80001e84:	97ba                	add	a5,a5,a4
    80001e86:	f8bc                	sd	a5,112(s1)
}
    80001e88:	8526                	mv	a0,s1
    80001e8a:	60e2                	ld	ra,24(sp)
    80001e8c:	6442                	ld	s0,16(sp)
    80001e8e:	64a2                	ld	s1,8(sp)
    80001e90:	6902                	ld	s2,0(sp)
    80001e92:	6105                	addi	sp,sp,32
    80001e94:	8082                	ret
        freeproc(p);
    80001e96:	8526                	mv	a0,s1
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	f08080e7          	jalr	-248(ra) # 80001da0 <freeproc>
        release(&p->lock);
    80001ea0:	8526                	mv	a0,s1
    80001ea2:	fffff097          	auipc	ra,0xfffff
    80001ea6:	de8080e7          	jalr	-536(ra) # 80000c8a <release>
        return 0;
    80001eaa:	84ca                	mv	s1,s2
    80001eac:	bff1                	j	80001e88 <allocproc+0x90>
        freeproc(p);
    80001eae:	8526                	mv	a0,s1
    80001eb0:	00000097          	auipc	ra,0x0
    80001eb4:	ef0080e7          	jalr	-272(ra) # 80001da0 <freeproc>
        release(&p->lock);
    80001eb8:	8526                	mv	a0,s1
    80001eba:	fffff097          	auipc	ra,0xfffff
    80001ebe:	dd0080e7          	jalr	-560(ra) # 80000c8a <release>
        return 0;
    80001ec2:	84ca                	mv	s1,s2
    80001ec4:	b7d1                	j	80001e88 <allocproc+0x90>

0000000080001ec6 <userinit>:
{
    80001ec6:	1101                	addi	sp,sp,-32
    80001ec8:	ec06                	sd	ra,24(sp)
    80001eca:	e822                	sd	s0,16(sp)
    80001ecc:	e426                	sd	s1,8(sp)
    80001ece:	1000                	addi	s0,sp,32
    p = allocproc();
    80001ed0:	00000097          	auipc	ra,0x0
    80001ed4:	f28080e7          	jalr	-216(ra) # 80001df8 <allocproc>
    80001ed8:	84aa                	mv	s1,a0
    initproc = p;
    80001eda:	00007797          	auipc	a5,0x7
    80001ede:	b4a7b323          	sd	a0,-1210(a5) # 80008a20 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001ee2:	03400613          	li	a2,52
    80001ee6:	00007597          	auipc	a1,0x7
    80001eea:	a6a58593          	addi	a1,a1,-1430 # 80008950 <initcode>
    80001eee:	6d28                	ld	a0,88(a0)
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	466080e7          	jalr	1126(ra) # 80001356 <uvmfirst>
    p->sz = PGSIZE;
    80001ef8:	6785                	lui	a5,0x1
    80001efa:	e8bc                	sd	a5,80(s1)
    p->trapframe->epc = 0;     // user program counter
    80001efc:	70b8                	ld	a4,96(s1)
    80001efe:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f02:	70b8                	ld	a4,96(s1)
    80001f04:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f06:	4641                	li	a2,16
    80001f08:	00006597          	auipc	a1,0x6
    80001f0c:	2f858593          	addi	a1,a1,760 # 80008200 <digits+0x1c0>
    80001f10:	16048513          	addi	a0,s1,352
    80001f14:	fffff097          	auipc	ra,0xfffff
    80001f18:	f08080e7          	jalr	-248(ra) # 80000e1c <safestrcpy>
    p->cwd = namei("/");
    80001f1c:	00006517          	auipc	a0,0x6
    80001f20:	2f450513          	addi	a0,a0,756 # 80008210 <digits+0x1d0>
    80001f24:	00002097          	auipc	ra,0x2
    80001f28:	3f2080e7          	jalr	1010(ra) # 80004316 <namei>
    80001f2c:	14a4bc23          	sd	a0,344(s1)
    p->state = RUNNABLE;
    80001f30:	478d                	li	a5,3
    80001f32:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001f34:	8526                	mv	a0,s1
    80001f36:	fffff097          	auipc	ra,0xfffff
    80001f3a:	d54080e7          	jalr	-684(ra) # 80000c8a <release>
}
    80001f3e:	60e2                	ld	ra,24(sp)
    80001f40:	6442                	ld	s0,16(sp)
    80001f42:	64a2                	ld	s1,8(sp)
    80001f44:	6105                	addi	sp,sp,32
    80001f46:	8082                	ret

0000000080001f48 <growproc>:
{
    80001f48:	1101                	addi	sp,sp,-32
    80001f4a:	ec06                	sd	ra,24(sp)
    80001f4c:	e822                	sd	s0,16(sp)
    80001f4e:	e426                	sd	s1,8(sp)
    80001f50:	e04a                	sd	s2,0(sp)
    80001f52:	1000                	addi	s0,sp,32
    80001f54:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001f56:	00000097          	auipc	ra,0x0
    80001f5a:	c98080e7          	jalr	-872(ra) # 80001bee <myproc>
    80001f5e:	84aa                	mv	s1,a0
    sz = p->sz;
    80001f60:	692c                	ld	a1,80(a0)
    if (n > 0)
    80001f62:	01204c63          	bgtz	s2,80001f7a <growproc+0x32>
    else if (n < 0)
    80001f66:	02094663          	bltz	s2,80001f92 <growproc+0x4a>
    p->sz = sz;
    80001f6a:	e8ac                	sd	a1,80(s1)
    return 0;
    80001f6c:	4501                	li	a0,0
}
    80001f6e:	60e2                	ld	ra,24(sp)
    80001f70:	6442                	ld	s0,16(sp)
    80001f72:	64a2                	ld	s1,8(sp)
    80001f74:	6902                	ld	s2,0(sp)
    80001f76:	6105                	addi	sp,sp,32
    80001f78:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001f7a:	4691                	li	a3,4
    80001f7c:	00b90633          	add	a2,s2,a1
    80001f80:	6d28                	ld	a0,88(a0)
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	48e080e7          	jalr	1166(ra) # 80001410 <uvmalloc>
    80001f8a:	85aa                	mv	a1,a0
    80001f8c:	fd79                	bnez	a0,80001f6a <growproc+0x22>
            return -1;
    80001f8e:	557d                	li	a0,-1
    80001f90:	bff9                	j	80001f6e <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001f92:	00b90633          	add	a2,s2,a1
    80001f96:	6d28                	ld	a0,88(a0)
    80001f98:	fffff097          	auipc	ra,0xfffff
    80001f9c:	430080e7          	jalr	1072(ra) # 800013c8 <uvmdealloc>
    80001fa0:	85aa                	mv	a1,a0
    80001fa2:	b7e1                	j	80001f6a <growproc+0x22>

0000000080001fa4 <ps>:
{
    80001fa4:	715d                	addi	sp,sp,-80
    80001fa6:	e486                	sd	ra,72(sp)
    80001fa8:	e0a2                	sd	s0,64(sp)
    80001faa:	fc26                	sd	s1,56(sp)
    80001fac:	f84a                	sd	s2,48(sp)
    80001fae:	f44e                	sd	s3,40(sp)
    80001fb0:	f052                	sd	s4,32(sp)
    80001fb2:	ec56                	sd	s5,24(sp)
    80001fb4:	e85a                	sd	s6,16(sp)
    80001fb6:	e45e                	sd	s7,8(sp)
    80001fb8:	e062                	sd	s8,0(sp)
    80001fba:	0880                	addi	s0,sp,80
    80001fbc:	84aa                	mv	s1,a0
    80001fbe:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80001fc0:	00000097          	auipc	ra,0x0
    80001fc4:	c2e080e7          	jalr	-978(ra) # 80001bee <myproc>
        return result;
    80001fc8:	4901                	li	s2,0
    if (count == 0)
    80001fca:	0c0b8563          	beqz	s7,80002094 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    80001fce:	05053b03          	ld	s6,80(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80001fd2:	003b951b          	slliw	a0,s7,0x3
    80001fd6:	0175053b          	addw	a0,a0,s7
    80001fda:	0025151b          	slliw	a0,a0,0x2
    80001fde:	00000097          	auipc	ra,0x0
    80001fe2:	f6a080e7          	jalr	-150(ra) # 80001f48 <growproc>
    80001fe6:	12054f63          	bltz	a0,80002124 <ps+0x180>
    struct user_proc loc_result[count];
    80001fea:	003b9a13          	slli	s4,s7,0x3
    80001fee:	9a5e                	add	s4,s4,s7
    80001ff0:	0a0a                	slli	s4,s4,0x2
    80001ff2:	00fa0793          	addi	a5,s4,15
    80001ff6:	8391                	srli	a5,a5,0x4
    80001ff8:	0792                	slli	a5,a5,0x4
    80001ffa:	40f10133          	sub	sp,sp,a5
    80001ffe:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    80002000:	17000793          	li	a5,368
    80002004:	02f484b3          	mul	s1,s1,a5
    80002008:	0000f797          	auipc	a5,0xf
    8000200c:	0b878793          	addi	a5,a5,184 # 800110c0 <proc>
    80002010:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80002012:	00015797          	auipc	a5,0x15
    80002016:	cae78793          	addi	a5,a5,-850 # 80016cc0 <tickslock>
        return result;
    8000201a:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    8000201c:	06f4fc63          	bgeu	s1,a5,80002094 <ps+0xf0>
    acquire(&wait_lock);
    80002020:	0000f517          	auipc	a0,0xf
    80002024:	08850513          	addi	a0,a0,136 # 800110a8 <wait_lock>
    80002028:	fffff097          	auipc	ra,0xfffff
    8000202c:	bae080e7          	jalr	-1106(ra) # 80000bd6 <acquire>
        if (localCount == count)
    80002030:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002034:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002036:	00015c17          	auipc	s8,0x15
    8000203a:	c8ac0c13          	addi	s8,s8,-886 # 80016cc0 <tickslock>
    8000203e:	a851                	j	800020d2 <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    80002040:	00399793          	slli	a5,s3,0x3
    80002044:	97ce                	add	a5,a5,s3
    80002046:	078a                	slli	a5,a5,0x2
    80002048:	97d6                	add	a5,a5,s5
    8000204a:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	c3a080e7          	jalr	-966(ra) # 80000c8a <release>
    release(&wait_lock);
    80002058:	0000f517          	auipc	a0,0xf
    8000205c:	05050513          	addi	a0,a0,80 # 800110a8 <wait_lock>
    80002060:	fffff097          	auipc	ra,0xfffff
    80002064:	c2a080e7          	jalr	-982(ra) # 80000c8a <release>
    if (localCount < count)
    80002068:	0179f963          	bgeu	s3,s7,8000207a <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    8000206c:	00399793          	slli	a5,s3,0x3
    80002070:	97ce                	add	a5,a5,s3
    80002072:	078a                	slli	a5,a5,0x2
    80002074:	97d6                	add	a5,a5,s5
    80002076:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    8000207a:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    8000207c:	00000097          	auipc	ra,0x0
    80002080:	b72080e7          	jalr	-1166(ra) # 80001bee <myproc>
    80002084:	86d2                	mv	a3,s4
    80002086:	8656                	mv	a2,s5
    80002088:	85da                	mv	a1,s6
    8000208a:	6d28                	ld	a0,88(a0)
    8000208c:	fffff097          	auipc	ra,0xfffff
    80002090:	5e0080e7          	jalr	1504(ra) # 8000166c <copyout>
}
    80002094:	854a                	mv	a0,s2
    80002096:	fb040113          	addi	sp,s0,-80
    8000209a:	60a6                	ld	ra,72(sp)
    8000209c:	6406                	ld	s0,64(sp)
    8000209e:	74e2                	ld	s1,56(sp)
    800020a0:	7942                	ld	s2,48(sp)
    800020a2:	79a2                	ld	s3,40(sp)
    800020a4:	7a02                	ld	s4,32(sp)
    800020a6:	6ae2                	ld	s5,24(sp)
    800020a8:	6b42                	ld	s6,16(sp)
    800020aa:	6ba2                	ld	s7,8(sp)
    800020ac:	6c02                	ld	s8,0(sp)
    800020ae:	6161                	addi	sp,sp,80
    800020b0:	8082                	ret
        release(&p->lock);
    800020b2:	8526                	mv	a0,s1
    800020b4:	fffff097          	auipc	ra,0xfffff
    800020b8:	bd6080e7          	jalr	-1066(ra) # 80000c8a <release>
        localCount++;
    800020bc:	2985                	addiw	s3,s3,1
    800020be:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    800020c2:	17048493          	addi	s1,s1,368
    800020c6:	f984f9e3          	bgeu	s1,s8,80002058 <ps+0xb4>
        if (localCount == count)
    800020ca:	02490913          	addi	s2,s2,36
    800020ce:	053b8d63          	beq	s7,s3,80002128 <ps+0x184>
        acquire(&p->lock);
    800020d2:	8526                	mv	a0,s1
    800020d4:	fffff097          	auipc	ra,0xfffff
    800020d8:	b02080e7          	jalr	-1278(ra) # 80000bd6 <acquire>
        if (p->state == UNUSED)
    800020dc:	4c9c                	lw	a5,24(s1)
    800020de:	d3ad                	beqz	a5,80002040 <ps+0x9c>
        loc_result[localCount].state = p->state;
    800020e0:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    800020e4:	589c                	lw	a5,48(s1)
    800020e6:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    800020ea:	58dc                	lw	a5,52(s1)
    800020ec:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    800020f0:	5c9c                	lw	a5,56(s1)
    800020f2:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    800020f6:	4641                	li	a2,16
    800020f8:	85ca                	mv	a1,s2
    800020fa:	16048513          	addi	a0,s1,352
    800020fe:	00000097          	auipc	ra,0x0
    80002102:	a96080e7          	jalr	-1386(ra) # 80001b94 <copy_array>
        if (p->parent != 0) // init
    80002106:	60a8                	ld	a0,64(s1)
    80002108:	d54d                	beqz	a0,800020b2 <ps+0x10e>
            acquire(&p->parent->lock);
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	acc080e7          	jalr	-1332(ra) # 80000bd6 <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    80002112:	60a8                	ld	a0,64(s1)
    80002114:	5d1c                	lw	a5,56(a0)
    80002116:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    8000211a:	fffff097          	auipc	ra,0xfffff
    8000211e:	b70080e7          	jalr	-1168(ra) # 80000c8a <release>
    80002122:	bf41                	j	800020b2 <ps+0x10e>
        return result;
    80002124:	4901                	li	s2,0
    80002126:	b7bd                	j	80002094 <ps+0xf0>
    release(&wait_lock);
    80002128:	0000f517          	auipc	a0,0xf
    8000212c:	f8050513          	addi	a0,a0,-128 # 800110a8 <wait_lock>
    80002130:	fffff097          	auipc	ra,0xfffff
    80002134:	b5a080e7          	jalr	-1190(ra) # 80000c8a <release>
    if (localCount < count)
    80002138:	b789                	j	8000207a <ps+0xd6>

000000008000213a <fork>:
{
    8000213a:	7139                	addi	sp,sp,-64
    8000213c:	fc06                	sd	ra,56(sp)
    8000213e:	f822                	sd	s0,48(sp)
    80002140:	f426                	sd	s1,40(sp)
    80002142:	f04a                	sd	s2,32(sp)
    80002144:	ec4e                	sd	s3,24(sp)
    80002146:	e852                	sd	s4,16(sp)
    80002148:	e456                	sd	s5,8(sp)
    8000214a:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000214c:	00000097          	auipc	ra,0x0
    80002150:	aa2080e7          	jalr	-1374(ra) # 80001bee <myproc>
    80002154:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002156:	00000097          	auipc	ra,0x0
    8000215a:	ca2080e7          	jalr	-862(ra) # 80001df8 <allocproc>
    8000215e:	10050c63          	beqz	a0,80002276 <fork+0x13c>
    80002162:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    80002164:	050ab603          	ld	a2,80(s5)
    80002168:	6d2c                	ld	a1,88(a0)
    8000216a:	058ab503          	ld	a0,88(s5)
    8000216e:	fffff097          	auipc	ra,0xfffff
    80002172:	3fa080e7          	jalr	1018(ra) # 80001568 <uvmcopy>
    80002176:	04054863          	bltz	a0,800021c6 <fork+0x8c>
    np->sz = p->sz;
    8000217a:	050ab783          	ld	a5,80(s5)
    8000217e:	04fa3823          	sd	a5,80(s4)
    *(np->trapframe) = *(p->trapframe);
    80002182:	060ab683          	ld	a3,96(s5)
    80002186:	87b6                	mv	a5,a3
    80002188:	060a3703          	ld	a4,96(s4)
    8000218c:	12068693          	addi	a3,a3,288
    80002190:	0007b803          	ld	a6,0(a5)
    80002194:	6788                	ld	a0,8(a5)
    80002196:	6b8c                	ld	a1,16(a5)
    80002198:	6f90                	ld	a2,24(a5)
    8000219a:	01073023          	sd	a6,0(a4)
    8000219e:	e708                	sd	a0,8(a4)
    800021a0:	eb0c                	sd	a1,16(a4)
    800021a2:	ef10                	sd	a2,24(a4)
    800021a4:	02078793          	addi	a5,a5,32
    800021a8:	02070713          	addi	a4,a4,32
    800021ac:	fed792e3          	bne	a5,a3,80002190 <fork+0x56>
    np->trapframe->a0 = 0;
    800021b0:	060a3783          	ld	a5,96(s4)
    800021b4:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800021b8:	0d8a8493          	addi	s1,s5,216
    800021bc:	0d8a0913          	addi	s2,s4,216
    800021c0:	158a8993          	addi	s3,s5,344
    800021c4:	a00d                	j	800021e6 <fork+0xac>
        freeproc(np);
    800021c6:	8552                	mv	a0,s4
    800021c8:	00000097          	auipc	ra,0x0
    800021cc:	bd8080e7          	jalr	-1064(ra) # 80001da0 <freeproc>
        release(&np->lock);
    800021d0:	8552                	mv	a0,s4
    800021d2:	fffff097          	auipc	ra,0xfffff
    800021d6:	ab8080e7          	jalr	-1352(ra) # 80000c8a <release>
        return -1;
    800021da:	597d                	li	s2,-1
    800021dc:	a059                	j	80002262 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    800021de:	04a1                	addi	s1,s1,8
    800021e0:	0921                	addi	s2,s2,8
    800021e2:	01348b63          	beq	s1,s3,800021f8 <fork+0xbe>
        if (p->ofile[i])
    800021e6:	6088                	ld	a0,0(s1)
    800021e8:	d97d                	beqz	a0,800021de <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    800021ea:	00002097          	auipc	ra,0x2
    800021ee:	7c2080e7          	jalr	1986(ra) # 800049ac <filedup>
    800021f2:	00a93023          	sd	a0,0(s2)
    800021f6:	b7e5                	j	800021de <fork+0xa4>
    np->cwd = idup(p->cwd);
    800021f8:	158ab503          	ld	a0,344(s5)
    800021fc:	00002097          	auipc	ra,0x2
    80002200:	930080e7          	jalr	-1744(ra) # 80003b2c <idup>
    80002204:	14aa3c23          	sd	a0,344(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002208:	4641                	li	a2,16
    8000220a:	160a8593          	addi	a1,s5,352
    8000220e:	160a0513          	addi	a0,s4,352
    80002212:	fffff097          	auipc	ra,0xfffff
    80002216:	c0a080e7          	jalr	-1014(ra) # 80000e1c <safestrcpy>
    pid = np->pid;
    8000221a:	038a2903          	lw	s2,56(s4)
    release(&np->lock);
    8000221e:	8552                	mv	a0,s4
    80002220:	fffff097          	auipc	ra,0xfffff
    80002224:	a6a080e7          	jalr	-1430(ra) # 80000c8a <release>
    acquire(&wait_lock);
    80002228:	0000f497          	auipc	s1,0xf
    8000222c:	e8048493          	addi	s1,s1,-384 # 800110a8 <wait_lock>
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	9a4080e7          	jalr	-1628(ra) # 80000bd6 <acquire>
    np->parent = p;
    8000223a:	055a3023          	sd	s5,64(s4)
    release(&wait_lock);
    8000223e:	8526                	mv	a0,s1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	a4a080e7          	jalr	-1462(ra) # 80000c8a <release>
    acquire(&np->lock);
    80002248:	8552                	mv	a0,s4
    8000224a:	fffff097          	auipc	ra,0xfffff
    8000224e:	98c080e7          	jalr	-1652(ra) # 80000bd6 <acquire>
    np->state = RUNNABLE;
    80002252:	478d                	li	a5,3
    80002254:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002258:	8552                	mv	a0,s4
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	a30080e7          	jalr	-1488(ra) # 80000c8a <release>
}
    80002262:	854a                	mv	a0,s2
    80002264:	70e2                	ld	ra,56(sp)
    80002266:	7442                	ld	s0,48(sp)
    80002268:	74a2                	ld	s1,40(sp)
    8000226a:	7902                	ld	s2,32(sp)
    8000226c:	69e2                	ld	s3,24(sp)
    8000226e:	6a42                	ld	s4,16(sp)
    80002270:	6aa2                	ld	s5,8(sp)
    80002272:	6121                	addi	sp,sp,64
    80002274:	8082                	ret
        return -1;
    80002276:	597d                	li	s2,-1
    80002278:	b7ed                	j	80002262 <fork+0x128>

000000008000227a <scheduler>:
{
    8000227a:	1101                	addi	sp,sp,-32
    8000227c:	ec06                	sd	ra,24(sp)
    8000227e:	e822                	sd	s0,16(sp)
    80002280:	e426                	sd	s1,8(sp)
    80002282:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002284:	00006497          	auipc	s1,0x6
    80002288:	6b448493          	addi	s1,s1,1716 # 80008938 <sched_pointer>
    8000228c:	609c                	ld	a5,0(s1)
    8000228e:	9782                	jalr	a5
    while (1)
    80002290:	bff5                	j	8000228c <scheduler+0x12>

0000000080002292 <sched>:
{
    80002292:	7179                	addi	sp,sp,-48
    80002294:	f406                	sd	ra,40(sp)
    80002296:	f022                	sd	s0,32(sp)
    80002298:	ec26                	sd	s1,24(sp)
    8000229a:	e84a                	sd	s2,16(sp)
    8000229c:	e44e                	sd	s3,8(sp)
    8000229e:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	94e080e7          	jalr	-1714(ra) # 80001bee <myproc>
    800022a8:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800022aa:	fffff097          	auipc	ra,0xfffff
    800022ae:	8b2080e7          	jalr	-1870(ra) # 80000b5c <holding>
    800022b2:	c53d                	beqz	a0,80002320 <sched+0x8e>
    800022b4:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800022b6:	2781                	sext.w	a5,a5
    800022b8:	079e                	slli	a5,a5,0x7
    800022ba:	0000f717          	auipc	a4,0xf
    800022be:	9d670713          	addi	a4,a4,-1578 # 80010c90 <cpus>
    800022c2:	97ba                	add	a5,a5,a4
    800022c4:	5fb8                	lw	a4,120(a5)
    800022c6:	4785                	li	a5,1
    800022c8:	06f71463          	bne	a4,a5,80002330 <sched+0x9e>
    if (p->state == RUNNING)
    800022cc:	4c98                	lw	a4,24(s1)
    800022ce:	4791                	li	a5,4
    800022d0:	06f70863          	beq	a4,a5,80002340 <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800022d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800022d8:	8b89                	andi	a5,a5,2
    if (intr_get())
    800022da:	ebbd                	bnez	a5,80002350 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    800022dc:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    800022de:	0000f917          	auipc	s2,0xf
    800022e2:	9b290913          	addi	s2,s2,-1614 # 80010c90 <cpus>
    800022e6:	2781                	sext.w	a5,a5
    800022e8:	079e                	slli	a5,a5,0x7
    800022ea:	97ca                	add	a5,a5,s2
    800022ec:	07c7a983          	lw	s3,124(a5)
    800022f0:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    800022f2:	2581                	sext.w	a1,a1
    800022f4:	059e                	slli	a1,a1,0x7
    800022f6:	05a1                	addi	a1,a1,8
    800022f8:	95ca                	add	a1,a1,s2
    800022fa:	06848513          	addi	a0,s1,104
    800022fe:	00000097          	auipc	ra,0x0
    80002302:	748080e7          	jalr	1864(ra) # 80002a46 <swtch>
    80002306:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002308:	2781                	sext.w	a5,a5
    8000230a:	079e                	slli	a5,a5,0x7
    8000230c:	993e                	add	s2,s2,a5
    8000230e:	07392e23          	sw	s3,124(s2)
}
    80002312:	70a2                	ld	ra,40(sp)
    80002314:	7402                	ld	s0,32(sp)
    80002316:	64e2                	ld	s1,24(sp)
    80002318:	6942                	ld	s2,16(sp)
    8000231a:	69a2                	ld	s3,8(sp)
    8000231c:	6145                	addi	sp,sp,48
    8000231e:	8082                	ret
        panic("sched p->lock");
    80002320:	00006517          	auipc	a0,0x6
    80002324:	ef850513          	addi	a0,a0,-264 # 80008218 <digits+0x1d8>
    80002328:	ffffe097          	auipc	ra,0xffffe
    8000232c:	218080e7          	jalr	536(ra) # 80000540 <panic>
        panic("sched locks");
    80002330:	00006517          	auipc	a0,0x6
    80002334:	ef850513          	addi	a0,a0,-264 # 80008228 <digits+0x1e8>
    80002338:	ffffe097          	auipc	ra,0xffffe
    8000233c:	208080e7          	jalr	520(ra) # 80000540 <panic>
        panic("sched running");
    80002340:	00006517          	auipc	a0,0x6
    80002344:	ef850513          	addi	a0,a0,-264 # 80008238 <digits+0x1f8>
    80002348:	ffffe097          	auipc	ra,0xffffe
    8000234c:	1f8080e7          	jalr	504(ra) # 80000540 <panic>
        panic("sched interruptible");
    80002350:	00006517          	auipc	a0,0x6
    80002354:	ef850513          	addi	a0,a0,-264 # 80008248 <digits+0x208>
    80002358:	ffffe097          	auipc	ra,0xffffe
    8000235c:	1e8080e7          	jalr	488(ra) # 80000540 <panic>

0000000080002360 <yield>:
{
    80002360:	1101                	addi	sp,sp,-32
    80002362:	ec06                	sd	ra,24(sp)
    80002364:	e822                	sd	s0,16(sp)
    80002366:	e426                	sd	s1,8(sp)
    80002368:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    8000236a:	00000097          	auipc	ra,0x0
    8000236e:	884080e7          	jalr	-1916(ra) # 80001bee <myproc>
    80002372:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002374:	fffff097          	auipc	ra,0xfffff
    80002378:	862080e7          	jalr	-1950(ra) # 80000bd6 <acquire>
    p->state = RUNNABLE;
    8000237c:	478d                	li	a5,3
    8000237e:	cc9c                	sw	a5,24(s1)
    sched();
    80002380:	00000097          	auipc	ra,0x0
    80002384:	f12080e7          	jalr	-238(ra) # 80002292 <sched>
    release(&p->lock);
    80002388:	8526                	mv	a0,s1
    8000238a:	fffff097          	auipc	ra,0xfffff
    8000238e:	900080e7          	jalr	-1792(ra) # 80000c8a <release>
}
    80002392:	60e2                	ld	ra,24(sp)
    80002394:	6442                	ld	s0,16(sp)
    80002396:	64a2                	ld	s1,8(sp)
    80002398:	6105                	addi	sp,sp,32
    8000239a:	8082                	ret

000000008000239c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000239c:	7179                	addi	sp,sp,-48
    8000239e:	f406                	sd	ra,40(sp)
    800023a0:	f022                	sd	s0,32(sp)
    800023a2:	ec26                	sd	s1,24(sp)
    800023a4:	e84a                	sd	s2,16(sp)
    800023a6:	e44e                	sd	s3,8(sp)
    800023a8:	1800                	addi	s0,sp,48
    800023aa:	89aa                	mv	s3,a0
    800023ac:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800023ae:	00000097          	auipc	ra,0x0
    800023b2:	840080e7          	jalr	-1984(ra) # 80001bee <myproc>
    800023b6:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    800023b8:	fffff097          	auipc	ra,0xfffff
    800023bc:	81e080e7          	jalr	-2018(ra) # 80000bd6 <acquire>
    release(lk);
    800023c0:	854a                	mv	a0,s2
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	8c8080e7          	jalr	-1848(ra) # 80000c8a <release>

    // Go to sleep.
    p->chan = chan;
    800023ca:	0334b423          	sd	s3,40(s1)
    p->state = SLEEPING;
    800023ce:	4789                	li	a5,2
    800023d0:	cc9c                	sw	a5,24(s1)

    sched();
    800023d2:	00000097          	auipc	ra,0x0
    800023d6:	ec0080e7          	jalr	-320(ra) # 80002292 <sched>

    // Tidy up.
    p->chan = 0;
    800023da:	0204b423          	sd	zero,40(s1)

    // Reacquire original lock.
    release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8aa080e7          	jalr	-1878(ra) # 80000c8a <release>
    acquire(lk);
    800023e8:	854a                	mv	a0,s2
    800023ea:	ffffe097          	auipc	ra,0xffffe
    800023ee:	7ec080e7          	jalr	2028(ra) # 80000bd6 <acquire>
}
    800023f2:	70a2                	ld	ra,40(sp)
    800023f4:	7402                	ld	s0,32(sp)
    800023f6:	64e2                	ld	s1,24(sp)
    800023f8:	6942                	ld	s2,16(sp)
    800023fa:	69a2                	ld	s3,8(sp)
    800023fc:	6145                	addi	sp,sp,48
    800023fe:	8082                	ret

0000000080002400 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002400:	7139                	addi	sp,sp,-64
    80002402:	fc06                	sd	ra,56(sp)
    80002404:	f822                	sd	s0,48(sp)
    80002406:	f426                	sd	s1,40(sp)
    80002408:	f04a                	sd	s2,32(sp)
    8000240a:	ec4e                	sd	s3,24(sp)
    8000240c:	e852                	sd	s4,16(sp)
    8000240e:	e456                	sd	s5,8(sp)
    80002410:	0080                	addi	s0,sp,64
    80002412:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002414:	0000f497          	auipc	s1,0xf
    80002418:	cac48493          	addi	s1,s1,-852 # 800110c0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000241c:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    8000241e:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002420:	00015917          	auipc	s2,0x15
    80002424:	8a090913          	addi	s2,s2,-1888 # 80016cc0 <tickslock>
    80002428:	a811                	j	8000243c <wakeup+0x3c>
            }
            release(&p->lock);
    8000242a:	8526                	mv	a0,s1
    8000242c:	fffff097          	auipc	ra,0xfffff
    80002430:	85e080e7          	jalr	-1954(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002434:	17048493          	addi	s1,s1,368
    80002438:	03248663          	beq	s1,s2,80002464 <wakeup+0x64>
        if (p != myproc())
    8000243c:	fffff097          	auipc	ra,0xfffff
    80002440:	7b2080e7          	jalr	1970(ra) # 80001bee <myproc>
    80002444:	fea488e3          	beq	s1,a0,80002434 <wakeup+0x34>
            acquire(&p->lock);
    80002448:	8526                	mv	a0,s1
    8000244a:	ffffe097          	auipc	ra,0xffffe
    8000244e:	78c080e7          	jalr	1932(ra) # 80000bd6 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    80002452:	4c9c                	lw	a5,24(s1)
    80002454:	fd379be3          	bne	a5,s3,8000242a <wakeup+0x2a>
    80002458:	749c                	ld	a5,40(s1)
    8000245a:	fd4798e3          	bne	a5,s4,8000242a <wakeup+0x2a>
                p->state = RUNNABLE;
    8000245e:	0154ac23          	sw	s5,24(s1)
    80002462:	b7e1                	j	8000242a <wakeup+0x2a>
        }
    }
}
    80002464:	70e2                	ld	ra,56(sp)
    80002466:	7442                	ld	s0,48(sp)
    80002468:	74a2                	ld	s1,40(sp)
    8000246a:	7902                	ld	s2,32(sp)
    8000246c:	69e2                	ld	s3,24(sp)
    8000246e:	6a42                	ld	s4,16(sp)
    80002470:	6aa2                	ld	s5,8(sp)
    80002472:	6121                	addi	sp,sp,64
    80002474:	8082                	ret

0000000080002476 <reparent>:
{
    80002476:	7179                	addi	sp,sp,-48
    80002478:	f406                	sd	ra,40(sp)
    8000247a:	f022                	sd	s0,32(sp)
    8000247c:	ec26                	sd	s1,24(sp)
    8000247e:	e84a                	sd	s2,16(sp)
    80002480:	e44e                	sd	s3,8(sp)
    80002482:	e052                	sd	s4,0(sp)
    80002484:	1800                	addi	s0,sp,48
    80002486:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002488:	0000f497          	auipc	s1,0xf
    8000248c:	c3848493          	addi	s1,s1,-968 # 800110c0 <proc>
            pp->parent = initproc;
    80002490:	00006a17          	auipc	s4,0x6
    80002494:	590a0a13          	addi	s4,s4,1424 # 80008a20 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    80002498:	00015997          	auipc	s3,0x15
    8000249c:	82898993          	addi	s3,s3,-2008 # 80016cc0 <tickslock>
    800024a0:	a029                	j	800024aa <reparent+0x34>
    800024a2:	17048493          	addi	s1,s1,368
    800024a6:	01348d63          	beq	s1,s3,800024c0 <reparent+0x4a>
        if (pp->parent == p)
    800024aa:	60bc                	ld	a5,64(s1)
    800024ac:	ff279be3          	bne	a5,s2,800024a2 <reparent+0x2c>
            pp->parent = initproc;
    800024b0:	000a3503          	ld	a0,0(s4)
    800024b4:	e0a8                	sd	a0,64(s1)
            wakeup(initproc);
    800024b6:	00000097          	auipc	ra,0x0
    800024ba:	f4a080e7          	jalr	-182(ra) # 80002400 <wakeup>
    800024be:	b7d5                	j	800024a2 <reparent+0x2c>
}
    800024c0:	70a2                	ld	ra,40(sp)
    800024c2:	7402                	ld	s0,32(sp)
    800024c4:	64e2                	ld	s1,24(sp)
    800024c6:	6942                	ld	s2,16(sp)
    800024c8:	69a2                	ld	s3,8(sp)
    800024ca:	6a02                	ld	s4,0(sp)
    800024cc:	6145                	addi	sp,sp,48
    800024ce:	8082                	ret

00000000800024d0 <exit>:
{
    800024d0:	7179                	addi	sp,sp,-48
    800024d2:	f406                	sd	ra,40(sp)
    800024d4:	f022                	sd	s0,32(sp)
    800024d6:	ec26                	sd	s1,24(sp)
    800024d8:	e84a                	sd	s2,16(sp)
    800024da:	e44e                	sd	s3,8(sp)
    800024dc:	e052                	sd	s4,0(sp)
    800024de:	1800                	addi	s0,sp,48
    800024e0:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    800024e2:	fffff097          	auipc	ra,0xfffff
    800024e6:	70c080e7          	jalr	1804(ra) # 80001bee <myproc>
    800024ea:	89aa                	mv	s3,a0
    if (p == initproc)
    800024ec:	00006797          	auipc	a5,0x6
    800024f0:	5347b783          	ld	a5,1332(a5) # 80008a20 <initproc>
    800024f4:	0d850493          	addi	s1,a0,216
    800024f8:	15850913          	addi	s2,a0,344
    800024fc:	02a79363          	bne	a5,a0,80002522 <exit+0x52>
        panic("init exiting");
    80002500:	00006517          	auipc	a0,0x6
    80002504:	d6050513          	addi	a0,a0,-672 # 80008260 <digits+0x220>
    80002508:	ffffe097          	auipc	ra,0xffffe
    8000250c:	038080e7          	jalr	56(ra) # 80000540 <panic>
            fileclose(f);
    80002510:	00002097          	auipc	ra,0x2
    80002514:	4ee080e7          	jalr	1262(ra) # 800049fe <fileclose>
            p->ofile[fd] = 0;
    80002518:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000251c:	04a1                	addi	s1,s1,8
    8000251e:	01248563          	beq	s1,s2,80002528 <exit+0x58>
        if (p->ofile[fd])
    80002522:	6088                	ld	a0,0(s1)
    80002524:	f575                	bnez	a0,80002510 <exit+0x40>
    80002526:	bfdd                	j	8000251c <exit+0x4c>
    begin_op();
    80002528:	00002097          	auipc	ra,0x2
    8000252c:	00e080e7          	jalr	14(ra) # 80004536 <begin_op>
    iput(p->cwd);
    80002530:	1589b503          	ld	a0,344(s3)
    80002534:	00001097          	auipc	ra,0x1
    80002538:	7f0080e7          	jalr	2032(ra) # 80003d24 <iput>
    end_op();
    8000253c:	00002097          	auipc	ra,0x2
    80002540:	078080e7          	jalr	120(ra) # 800045b4 <end_op>
    p->cwd = 0;
    80002544:	1409bc23          	sd	zero,344(s3)
    acquire(&wait_lock);
    80002548:	0000f497          	auipc	s1,0xf
    8000254c:	b6048493          	addi	s1,s1,-1184 # 800110a8 <wait_lock>
    80002550:	8526                	mv	a0,s1
    80002552:	ffffe097          	auipc	ra,0xffffe
    80002556:	684080e7          	jalr	1668(ra) # 80000bd6 <acquire>
    reparent(p);
    8000255a:	854e                	mv	a0,s3
    8000255c:	00000097          	auipc	ra,0x0
    80002560:	f1a080e7          	jalr	-230(ra) # 80002476 <reparent>
    wakeup(p->parent);
    80002564:	0409b503          	ld	a0,64(s3)
    80002568:	00000097          	auipc	ra,0x0
    8000256c:	e98080e7          	jalr	-360(ra) # 80002400 <wakeup>
    acquire(&p->lock);
    80002570:	854e                	mv	a0,s3
    80002572:	ffffe097          	auipc	ra,0xffffe
    80002576:	664080e7          	jalr	1636(ra) # 80000bd6 <acquire>
    p->xstate = status;
    8000257a:	0349aa23          	sw	s4,52(s3)
    p->state = ZOMBIE;
    8000257e:	4795                	li	a5,5
    80002580:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002584:	8526                	mv	a0,s1
    80002586:	ffffe097          	auipc	ra,0xffffe
    8000258a:	704080e7          	jalr	1796(ra) # 80000c8a <release>
    sched();
    8000258e:	00000097          	auipc	ra,0x0
    80002592:	d04080e7          	jalr	-764(ra) # 80002292 <sched>
    panic("zombie exit");
    80002596:	00006517          	auipc	a0,0x6
    8000259a:	cda50513          	addi	a0,a0,-806 # 80008270 <digits+0x230>
    8000259e:	ffffe097          	auipc	ra,0xffffe
    800025a2:	fa2080e7          	jalr	-94(ra) # 80000540 <panic>

00000000800025a6 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800025a6:	7179                	addi	sp,sp,-48
    800025a8:	f406                	sd	ra,40(sp)
    800025aa:	f022                	sd	s0,32(sp)
    800025ac:	ec26                	sd	s1,24(sp)
    800025ae:	e84a                	sd	s2,16(sp)
    800025b0:	e44e                	sd	s3,8(sp)
    800025b2:	1800                	addi	s0,sp,48
    800025b4:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800025b6:	0000f497          	auipc	s1,0xf
    800025ba:	b0a48493          	addi	s1,s1,-1270 # 800110c0 <proc>
    800025be:	00014997          	auipc	s3,0x14
    800025c2:	70298993          	addi	s3,s3,1794 # 80016cc0 <tickslock>
    {
        acquire(&p->lock);
    800025c6:	8526                	mv	a0,s1
    800025c8:	ffffe097          	auipc	ra,0xffffe
    800025cc:	60e080e7          	jalr	1550(ra) # 80000bd6 <acquire>
        if (p->pid == pid)
    800025d0:	5c9c                	lw	a5,56(s1)
    800025d2:	01278d63          	beq	a5,s2,800025ec <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    800025d6:	8526                	mv	a0,s1
    800025d8:	ffffe097          	auipc	ra,0xffffe
    800025dc:	6b2080e7          	jalr	1714(ra) # 80000c8a <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800025e0:	17048493          	addi	s1,s1,368
    800025e4:	ff3491e3          	bne	s1,s3,800025c6 <kill+0x20>
    }
    return -1;
    800025e8:	557d                	li	a0,-1
    800025ea:	a829                	j	80002604 <kill+0x5e>
            p->killed = 1;
    800025ec:	4785                	li	a5,1
    800025ee:	d89c                	sw	a5,48(s1)
            if (p->state == SLEEPING)
    800025f0:	4c98                	lw	a4,24(s1)
    800025f2:	4789                	li	a5,2
    800025f4:	00f70f63          	beq	a4,a5,80002612 <kill+0x6c>
            release(&p->lock);
    800025f8:	8526                	mv	a0,s1
    800025fa:	ffffe097          	auipc	ra,0xffffe
    800025fe:	690080e7          	jalr	1680(ra) # 80000c8a <release>
            return 0;
    80002602:	4501                	li	a0,0
}
    80002604:	70a2                	ld	ra,40(sp)
    80002606:	7402                	ld	s0,32(sp)
    80002608:	64e2                	ld	s1,24(sp)
    8000260a:	6942                	ld	s2,16(sp)
    8000260c:	69a2                	ld	s3,8(sp)
    8000260e:	6145                	addi	sp,sp,48
    80002610:	8082                	ret
                p->state = RUNNABLE;
    80002612:	478d                	li	a5,3
    80002614:	cc9c                	sw	a5,24(s1)
    80002616:	b7cd                	j	800025f8 <kill+0x52>

0000000080002618 <setkilled>:

void setkilled(struct proc *p)
{
    80002618:	1101                	addi	sp,sp,-32
    8000261a:	ec06                	sd	ra,24(sp)
    8000261c:	e822                	sd	s0,16(sp)
    8000261e:	e426                	sd	s1,8(sp)
    80002620:	1000                	addi	s0,sp,32
    80002622:	84aa                	mv	s1,a0
    acquire(&p->lock);
    80002624:	ffffe097          	auipc	ra,0xffffe
    80002628:	5b2080e7          	jalr	1458(ra) # 80000bd6 <acquire>
    p->killed = 1;
    8000262c:	4785                	li	a5,1
    8000262e:	d89c                	sw	a5,48(s1)
    release(&p->lock);
    80002630:	8526                	mv	a0,s1
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	658080e7          	jalr	1624(ra) # 80000c8a <release>
}
    8000263a:	60e2                	ld	ra,24(sp)
    8000263c:	6442                	ld	s0,16(sp)
    8000263e:	64a2                	ld	s1,8(sp)
    80002640:	6105                	addi	sp,sp,32
    80002642:	8082                	ret

0000000080002644 <killed>:

int killed(struct proc *p)
{
    80002644:	1101                	addi	sp,sp,-32
    80002646:	ec06                	sd	ra,24(sp)
    80002648:	e822                	sd	s0,16(sp)
    8000264a:	e426                	sd	s1,8(sp)
    8000264c:	e04a                	sd	s2,0(sp)
    8000264e:	1000                	addi	s0,sp,32
    80002650:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    80002652:	ffffe097          	auipc	ra,0xffffe
    80002656:	584080e7          	jalr	1412(ra) # 80000bd6 <acquire>
    k = p->killed;
    8000265a:	0304a903          	lw	s2,48(s1)
    release(&p->lock);
    8000265e:	8526                	mv	a0,s1
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	62a080e7          	jalr	1578(ra) # 80000c8a <release>
    return k;
}
    80002668:	854a                	mv	a0,s2
    8000266a:	60e2                	ld	ra,24(sp)
    8000266c:	6442                	ld	s0,16(sp)
    8000266e:	64a2                	ld	s1,8(sp)
    80002670:	6902                	ld	s2,0(sp)
    80002672:	6105                	addi	sp,sp,32
    80002674:	8082                	ret

0000000080002676 <wait>:
{
    80002676:	715d                	addi	sp,sp,-80
    80002678:	e486                	sd	ra,72(sp)
    8000267a:	e0a2                	sd	s0,64(sp)
    8000267c:	fc26                	sd	s1,56(sp)
    8000267e:	f84a                	sd	s2,48(sp)
    80002680:	f44e                	sd	s3,40(sp)
    80002682:	f052                	sd	s4,32(sp)
    80002684:	ec56                	sd	s5,24(sp)
    80002686:	e85a                	sd	s6,16(sp)
    80002688:	e45e                	sd	s7,8(sp)
    8000268a:	e062                	sd	s8,0(sp)
    8000268c:	0880                	addi	s0,sp,80
    8000268e:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002690:	fffff097          	auipc	ra,0xfffff
    80002694:	55e080e7          	jalr	1374(ra) # 80001bee <myproc>
    80002698:	892a                	mv	s2,a0
    acquire(&wait_lock);
    8000269a:	0000f517          	auipc	a0,0xf
    8000269e:	a0e50513          	addi	a0,a0,-1522 # 800110a8 <wait_lock>
    800026a2:	ffffe097          	auipc	ra,0xffffe
    800026a6:	534080e7          	jalr	1332(ra) # 80000bd6 <acquire>
        havekids = 0;
    800026aa:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800026ac:	4a15                	li	s4,5
                havekids = 1;
    800026ae:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026b0:	00014997          	auipc	s3,0x14
    800026b4:	61098993          	addi	s3,s3,1552 # 80016cc0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800026b8:	0000fc17          	auipc	s8,0xf
    800026bc:	9f0c0c13          	addi	s8,s8,-1552 # 800110a8 <wait_lock>
        havekids = 0;
    800026c0:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026c2:	0000f497          	auipc	s1,0xf
    800026c6:	9fe48493          	addi	s1,s1,-1538 # 800110c0 <proc>
    800026ca:	a0bd                	j	80002738 <wait+0xc2>
                    pid = pp->pid;
    800026cc:	0384a983          	lw	s3,56(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800026d0:	000b0e63          	beqz	s6,800026ec <wait+0x76>
    800026d4:	4691                	li	a3,4
    800026d6:	03448613          	addi	a2,s1,52
    800026da:	85da                	mv	a1,s6
    800026dc:	05893503          	ld	a0,88(s2)
    800026e0:	fffff097          	auipc	ra,0xfffff
    800026e4:	f8c080e7          	jalr	-116(ra) # 8000166c <copyout>
    800026e8:	02054563          	bltz	a0,80002712 <wait+0x9c>
                    freeproc(pp);
    800026ec:	8526                	mv	a0,s1
    800026ee:	fffff097          	auipc	ra,0xfffff
    800026f2:	6b2080e7          	jalr	1714(ra) # 80001da0 <freeproc>
                    release(&pp->lock);
    800026f6:	8526                	mv	a0,s1
    800026f8:	ffffe097          	auipc	ra,0xffffe
    800026fc:	592080e7          	jalr	1426(ra) # 80000c8a <release>
                    release(&wait_lock);
    80002700:	0000f517          	auipc	a0,0xf
    80002704:	9a850513          	addi	a0,a0,-1624 # 800110a8 <wait_lock>
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	582080e7          	jalr	1410(ra) # 80000c8a <release>
                    return pid;
    80002710:	a0b5                	j	8000277c <wait+0x106>
                        release(&pp->lock);
    80002712:	8526                	mv	a0,s1
    80002714:	ffffe097          	auipc	ra,0xffffe
    80002718:	576080e7          	jalr	1398(ra) # 80000c8a <release>
                        release(&wait_lock);
    8000271c:	0000f517          	auipc	a0,0xf
    80002720:	98c50513          	addi	a0,a0,-1652 # 800110a8 <wait_lock>
    80002724:	ffffe097          	auipc	ra,0xffffe
    80002728:	566080e7          	jalr	1382(ra) # 80000c8a <release>
                        return -1;
    8000272c:	59fd                	li	s3,-1
    8000272e:	a0b9                	j	8000277c <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002730:	17048493          	addi	s1,s1,368
    80002734:	03348463          	beq	s1,s3,8000275c <wait+0xe6>
            if (pp->parent == p)
    80002738:	60bc                	ld	a5,64(s1)
    8000273a:	ff279be3          	bne	a5,s2,80002730 <wait+0xba>
                acquire(&pp->lock);
    8000273e:	8526                	mv	a0,s1
    80002740:	ffffe097          	auipc	ra,0xffffe
    80002744:	496080e7          	jalr	1174(ra) # 80000bd6 <acquire>
                if (pp->state == ZOMBIE)
    80002748:	4c9c                	lw	a5,24(s1)
    8000274a:	f94781e3          	beq	a5,s4,800026cc <wait+0x56>
                release(&pp->lock);
    8000274e:	8526                	mv	a0,s1
    80002750:	ffffe097          	auipc	ra,0xffffe
    80002754:	53a080e7          	jalr	1338(ra) # 80000c8a <release>
                havekids = 1;
    80002758:	8756                	mv	a4,s5
    8000275a:	bfd9                	j	80002730 <wait+0xba>
        if (!havekids || killed(p))
    8000275c:	c719                	beqz	a4,8000276a <wait+0xf4>
    8000275e:	854a                	mv	a0,s2
    80002760:	00000097          	auipc	ra,0x0
    80002764:	ee4080e7          	jalr	-284(ra) # 80002644 <killed>
    80002768:	c51d                	beqz	a0,80002796 <wait+0x120>
            release(&wait_lock);
    8000276a:	0000f517          	auipc	a0,0xf
    8000276e:	93e50513          	addi	a0,a0,-1730 # 800110a8 <wait_lock>
    80002772:	ffffe097          	auipc	ra,0xffffe
    80002776:	518080e7          	jalr	1304(ra) # 80000c8a <release>
            return -1;
    8000277a:	59fd                	li	s3,-1
}
    8000277c:	854e                	mv	a0,s3
    8000277e:	60a6                	ld	ra,72(sp)
    80002780:	6406                	ld	s0,64(sp)
    80002782:	74e2                	ld	s1,56(sp)
    80002784:	7942                	ld	s2,48(sp)
    80002786:	79a2                	ld	s3,40(sp)
    80002788:	7a02                	ld	s4,32(sp)
    8000278a:	6ae2                	ld	s5,24(sp)
    8000278c:	6b42                	ld	s6,16(sp)
    8000278e:	6ba2                	ld	s7,8(sp)
    80002790:	6c02                	ld	s8,0(sp)
    80002792:	6161                	addi	sp,sp,80
    80002794:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002796:	85e2                	mv	a1,s8
    80002798:	854a                	mv	a0,s2
    8000279a:	00000097          	auipc	ra,0x0
    8000279e:	c02080e7          	jalr	-1022(ra) # 8000239c <sleep>
        havekids = 0;
    800027a2:	bf39                	j	800026c0 <wait+0x4a>

00000000800027a4 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027a4:	7179                	addi	sp,sp,-48
    800027a6:	f406                	sd	ra,40(sp)
    800027a8:	f022                	sd	s0,32(sp)
    800027aa:	ec26                	sd	s1,24(sp)
    800027ac:	e84a                	sd	s2,16(sp)
    800027ae:	e44e                	sd	s3,8(sp)
    800027b0:	e052                	sd	s4,0(sp)
    800027b2:	1800                	addi	s0,sp,48
    800027b4:	84aa                	mv	s1,a0
    800027b6:	892e                	mv	s2,a1
    800027b8:	89b2                	mv	s3,a2
    800027ba:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    800027bc:	fffff097          	auipc	ra,0xfffff
    800027c0:	432080e7          	jalr	1074(ra) # 80001bee <myproc>
    if (user_dst)
    800027c4:	c08d                	beqz	s1,800027e6 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    800027c6:	86d2                	mv	a3,s4
    800027c8:	864e                	mv	a2,s3
    800027ca:	85ca                	mv	a1,s2
    800027cc:	6d28                	ld	a0,88(a0)
    800027ce:	fffff097          	auipc	ra,0xfffff
    800027d2:	e9e080e7          	jalr	-354(ra) # 8000166c <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    800027d6:	70a2                	ld	ra,40(sp)
    800027d8:	7402                	ld	s0,32(sp)
    800027da:	64e2                	ld	s1,24(sp)
    800027dc:	6942                	ld	s2,16(sp)
    800027de:	69a2                	ld	s3,8(sp)
    800027e0:	6a02                	ld	s4,0(sp)
    800027e2:	6145                	addi	sp,sp,48
    800027e4:	8082                	ret
        memmove((char *)dst, src, len);
    800027e6:	000a061b          	sext.w	a2,s4
    800027ea:	85ce                	mv	a1,s3
    800027ec:	854a                	mv	a0,s2
    800027ee:	ffffe097          	auipc	ra,0xffffe
    800027f2:	540080e7          	jalr	1344(ra) # 80000d2e <memmove>
        return 0;
    800027f6:	8526                	mv	a0,s1
    800027f8:	bff9                	j	800027d6 <either_copyout+0x32>

00000000800027fa <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800027fa:	7179                	addi	sp,sp,-48
    800027fc:	f406                	sd	ra,40(sp)
    800027fe:	f022                	sd	s0,32(sp)
    80002800:	ec26                	sd	s1,24(sp)
    80002802:	e84a                	sd	s2,16(sp)
    80002804:	e44e                	sd	s3,8(sp)
    80002806:	e052                	sd	s4,0(sp)
    80002808:	1800                	addi	s0,sp,48
    8000280a:	892a                	mv	s2,a0
    8000280c:	84ae                	mv	s1,a1
    8000280e:	89b2                	mv	s3,a2
    80002810:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	3dc080e7          	jalr	988(ra) # 80001bee <myproc>
    if (user_src)
    8000281a:	c08d                	beqz	s1,8000283c <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000281c:	86d2                	mv	a3,s4
    8000281e:	864e                	mv	a2,s3
    80002820:	85ca                	mv	a1,s2
    80002822:	6d28                	ld	a0,88(a0)
    80002824:	fffff097          	auipc	ra,0xfffff
    80002828:	ed4080e7          	jalr	-300(ra) # 800016f8 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    8000282c:	70a2                	ld	ra,40(sp)
    8000282e:	7402                	ld	s0,32(sp)
    80002830:	64e2                	ld	s1,24(sp)
    80002832:	6942                	ld	s2,16(sp)
    80002834:	69a2                	ld	s3,8(sp)
    80002836:	6a02                	ld	s4,0(sp)
    80002838:	6145                	addi	sp,sp,48
    8000283a:	8082                	ret
        memmove(dst, (char *)src, len);
    8000283c:	000a061b          	sext.w	a2,s4
    80002840:	85ce                	mv	a1,s3
    80002842:	854a                	mv	a0,s2
    80002844:	ffffe097          	auipc	ra,0xffffe
    80002848:	4ea080e7          	jalr	1258(ra) # 80000d2e <memmove>
        return 0;
    8000284c:	8526                	mv	a0,s1
    8000284e:	bff9                	j	8000282c <either_copyin+0x32>

0000000080002850 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002850:	715d                	addi	sp,sp,-80
    80002852:	e486                	sd	ra,72(sp)
    80002854:	e0a2                	sd	s0,64(sp)
    80002856:	fc26                	sd	s1,56(sp)
    80002858:	f84a                	sd	s2,48(sp)
    8000285a:	f44e                	sd	s3,40(sp)
    8000285c:	f052                	sd	s4,32(sp)
    8000285e:	ec56                	sd	s5,24(sp)
    80002860:	e85a                	sd	s6,16(sp)
    80002862:	e45e                	sd	s7,8(sp)
    80002864:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    80002866:	00006517          	auipc	a0,0x6
    8000286a:	86250513          	addi	a0,a0,-1950 # 800080c8 <digits+0x88>
    8000286e:	ffffe097          	auipc	ra,0xffffe
    80002872:	d1c080e7          	jalr	-740(ra) # 8000058a <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002876:	0000f497          	auipc	s1,0xf
    8000287a:	9aa48493          	addi	s1,s1,-1622 # 80011220 <proc+0x160>
    8000287e:	00014917          	auipc	s2,0x14
    80002882:	5a290913          	addi	s2,s2,1442 # 80016e20 <bcache+0x148>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002886:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002888:	00006997          	auipc	s3,0x6
    8000288c:	9f898993          	addi	s3,s3,-1544 # 80008280 <digits+0x240>
        printf("%d <%s %s", p->pid, state, p->name);
    80002890:	00006a97          	auipc	s5,0x6
    80002894:	9f8a8a93          	addi	s5,s5,-1544 # 80008288 <digits+0x248>
        printf("\n");
    80002898:	00006a17          	auipc	s4,0x6
    8000289c:	830a0a13          	addi	s4,s4,-2000 # 800080c8 <digits+0x88>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028a0:	00006b97          	auipc	s7,0x6
    800028a4:	af8b8b93          	addi	s7,s7,-1288 # 80008398 <states.0>
    800028a8:	a00d                	j	800028ca <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800028aa:	ed86a583          	lw	a1,-296(a3)
    800028ae:	8556                	mv	a0,s5
    800028b0:	ffffe097          	auipc	ra,0xffffe
    800028b4:	cda080e7          	jalr	-806(ra) # 8000058a <printf>
        printf("\n");
    800028b8:	8552                	mv	a0,s4
    800028ba:	ffffe097          	auipc	ra,0xffffe
    800028be:	cd0080e7          	jalr	-816(ra) # 8000058a <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800028c2:	17048493          	addi	s1,s1,368
    800028c6:	03248263          	beq	s1,s2,800028ea <procdump+0x9a>
        if (p->state == UNUSED)
    800028ca:	86a6                	mv	a3,s1
    800028cc:	eb84a783          	lw	a5,-328(s1)
    800028d0:	dbed                	beqz	a5,800028c2 <procdump+0x72>
            state = "???";
    800028d2:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028d4:	fcfb6be3          	bltu	s6,a5,800028aa <procdump+0x5a>
    800028d8:	02079713          	slli	a4,a5,0x20
    800028dc:	01d75793          	srli	a5,a4,0x1d
    800028e0:	97de                	add	a5,a5,s7
    800028e2:	6390                	ld	a2,0(a5)
    800028e4:	f279                	bnez	a2,800028aa <procdump+0x5a>
            state = "???";
    800028e6:	864e                	mv	a2,s3
    800028e8:	b7c9                	j	800028aa <procdump+0x5a>
    }
}
    800028ea:	60a6                	ld	ra,72(sp)
    800028ec:	6406                	ld	s0,64(sp)
    800028ee:	74e2                	ld	s1,56(sp)
    800028f0:	7942                	ld	s2,48(sp)
    800028f2:	79a2                	ld	s3,40(sp)
    800028f4:	7a02                	ld	s4,32(sp)
    800028f6:	6ae2                	ld	s5,24(sp)
    800028f8:	6b42                	ld	s6,16(sp)
    800028fa:	6ba2                	ld	s7,8(sp)
    800028fc:	6161                	addi	sp,sp,80
    800028fe:	8082                	ret

0000000080002900 <schedls>:

void schedls()
{
    80002900:	1101                	addi	sp,sp,-32
    80002902:	ec06                	sd	ra,24(sp)
    80002904:	e822                	sd	s0,16(sp)
    80002906:	e426                	sd	s1,8(sp)
    80002908:	1000                	addi	s0,sp,32
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    8000290a:	00006517          	auipc	a0,0x6
    8000290e:	98e50513          	addi	a0,a0,-1650 # 80008298 <digits+0x258>
    80002912:	ffffe097          	auipc	ra,0xffffe
    80002916:	c78080e7          	jalr	-904(ra) # 8000058a <printf>
    printf("====================================\n");
    8000291a:	00006517          	auipc	a0,0x6
    8000291e:	9a650513          	addi	a0,a0,-1626 # 800082c0 <digits+0x280>
    80002922:	ffffe097          	auipc	ra,0xffffe
    80002926:	c68080e7          	jalr	-920(ra) # 8000058a <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    8000292a:	00006717          	auipc	a4,0x6
    8000292e:	06e73703          	ld	a4,110(a4) # 80008998 <available_schedulers+0x10>
    80002932:	00006797          	auipc	a5,0x6
    80002936:	0067b783          	ld	a5,6(a5) # 80008938 <sched_pointer>
    8000293a:	08f70763          	beq	a4,a5,800029c8 <schedls+0xc8>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    8000293e:	00006517          	auipc	a0,0x6
    80002942:	9aa50513          	addi	a0,a0,-1622 # 800082e8 <digits+0x2a8>
    80002946:	ffffe097          	auipc	ra,0xffffe
    8000294a:	c44080e7          	jalr	-956(ra) # 8000058a <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    8000294e:	00006497          	auipc	s1,0x6
    80002952:	00248493          	addi	s1,s1,2 # 80008950 <initcode>
    80002956:	48b0                	lw	a2,80(s1)
    80002958:	00006597          	auipc	a1,0x6
    8000295c:	03058593          	addi	a1,a1,48 # 80008988 <available_schedulers>
    80002960:	00006517          	auipc	a0,0x6
    80002964:	99850513          	addi	a0,a0,-1640 # 800082f8 <digits+0x2b8>
    80002968:	ffffe097          	auipc	ra,0xffffe
    8000296c:	c22080e7          	jalr	-990(ra) # 8000058a <printf>
        if (available_schedulers[i].impl == sched_pointer)
    80002970:	74b8                	ld	a4,104(s1)
    80002972:	00006797          	auipc	a5,0x6
    80002976:	fc67b783          	ld	a5,-58(a5) # 80008938 <sched_pointer>
    8000297a:	06f70063          	beq	a4,a5,800029da <schedls+0xda>
            printf("   \t");
    8000297e:	00006517          	auipc	a0,0x6
    80002982:	96a50513          	addi	a0,a0,-1686 # 800082e8 <digits+0x2a8>
    80002986:	ffffe097          	auipc	ra,0xffffe
    8000298a:	c04080e7          	jalr	-1020(ra) # 8000058a <printf>
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    8000298e:	00006617          	auipc	a2,0x6
    80002992:	03262603          	lw	a2,50(a2) # 800089c0 <available_schedulers+0x38>
    80002996:	00006597          	auipc	a1,0x6
    8000299a:	01258593          	addi	a1,a1,18 # 800089a8 <available_schedulers+0x20>
    8000299e:	00006517          	auipc	a0,0x6
    800029a2:	95a50513          	addi	a0,a0,-1702 # 800082f8 <digits+0x2b8>
    800029a6:	ffffe097          	auipc	ra,0xffffe
    800029aa:	be4080e7          	jalr	-1052(ra) # 8000058a <printf>
    }
    printf("\n*: current scheduler\n\n");
    800029ae:	00006517          	auipc	a0,0x6
    800029b2:	95250513          	addi	a0,a0,-1710 # 80008300 <digits+0x2c0>
    800029b6:	ffffe097          	auipc	ra,0xffffe
    800029ba:	bd4080e7          	jalr	-1068(ra) # 8000058a <printf>
}
    800029be:	60e2                	ld	ra,24(sp)
    800029c0:	6442                	ld	s0,16(sp)
    800029c2:	64a2                	ld	s1,8(sp)
    800029c4:	6105                	addi	sp,sp,32
    800029c6:	8082                	ret
            printf("[*]\t");
    800029c8:	00006517          	auipc	a0,0x6
    800029cc:	92850513          	addi	a0,a0,-1752 # 800082f0 <digits+0x2b0>
    800029d0:	ffffe097          	auipc	ra,0xffffe
    800029d4:	bba080e7          	jalr	-1094(ra) # 8000058a <printf>
    800029d8:	bf9d                	j	8000294e <schedls+0x4e>
    800029da:	00006517          	auipc	a0,0x6
    800029de:	91650513          	addi	a0,a0,-1770 # 800082f0 <digits+0x2b0>
    800029e2:	ffffe097          	auipc	ra,0xffffe
    800029e6:	ba8080e7          	jalr	-1112(ra) # 8000058a <printf>
    800029ea:	b755                	j	8000298e <schedls+0x8e>

00000000800029ec <schedset>:

void schedset(int id)
{
    800029ec:	1141                	addi	sp,sp,-16
    800029ee:	e406                	sd	ra,8(sp)
    800029f0:	e022                	sd	s0,0(sp)
    800029f2:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    800029f4:	4705                	li	a4,1
    800029f6:	02a76f63          	bltu	a4,a0,80002a34 <schedset+0x48>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    800029fa:	00551793          	slli	a5,a0,0x5
    800029fe:	00006717          	auipc	a4,0x6
    80002a02:	f5270713          	addi	a4,a4,-174 # 80008950 <initcode>
    80002a06:	973e                	add	a4,a4,a5
    80002a08:	6738                	ld	a4,72(a4)
    80002a0a:	00006697          	auipc	a3,0x6
    80002a0e:	f2e6b723          	sd	a4,-210(a3) # 80008938 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a12:	00006597          	auipc	a1,0x6
    80002a16:	f7658593          	addi	a1,a1,-138 # 80008988 <available_schedulers>
    80002a1a:	95be                	add	a1,a1,a5
    80002a1c:	00006517          	auipc	a0,0x6
    80002a20:	92450513          	addi	a0,a0,-1756 # 80008340 <digits+0x300>
    80002a24:	ffffe097          	auipc	ra,0xffffe
    80002a28:	b66080e7          	jalr	-1178(ra) # 8000058a <printf>
    80002a2c:	60a2                	ld	ra,8(sp)
    80002a2e:	6402                	ld	s0,0(sp)
    80002a30:	0141                	addi	sp,sp,16
    80002a32:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002a34:	00006517          	auipc	a0,0x6
    80002a38:	8e450513          	addi	a0,a0,-1820 # 80008318 <digits+0x2d8>
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b4e080e7          	jalr	-1202(ra) # 8000058a <printf>
        return;
    80002a44:	b7e5                	j	80002a2c <schedset+0x40>

0000000080002a46 <swtch>:
    80002a46:	00153023          	sd	ra,0(a0)
    80002a4a:	00253423          	sd	sp,8(a0)
    80002a4e:	e900                	sd	s0,16(a0)
    80002a50:	ed04                	sd	s1,24(a0)
    80002a52:	03253023          	sd	s2,32(a0)
    80002a56:	03353423          	sd	s3,40(a0)
    80002a5a:	03453823          	sd	s4,48(a0)
    80002a5e:	03553c23          	sd	s5,56(a0)
    80002a62:	05653023          	sd	s6,64(a0)
    80002a66:	05753423          	sd	s7,72(a0)
    80002a6a:	05853823          	sd	s8,80(a0)
    80002a6e:	05953c23          	sd	s9,88(a0)
    80002a72:	07a53023          	sd	s10,96(a0)
    80002a76:	07b53423          	sd	s11,104(a0)
    80002a7a:	0005b083          	ld	ra,0(a1)
    80002a7e:	0085b103          	ld	sp,8(a1)
    80002a82:	6980                	ld	s0,16(a1)
    80002a84:	6d84                	ld	s1,24(a1)
    80002a86:	0205b903          	ld	s2,32(a1)
    80002a8a:	0285b983          	ld	s3,40(a1)
    80002a8e:	0305ba03          	ld	s4,48(a1)
    80002a92:	0385ba83          	ld	s5,56(a1)
    80002a96:	0405bb03          	ld	s6,64(a1)
    80002a9a:	0485bb83          	ld	s7,72(a1)
    80002a9e:	0505bc03          	ld	s8,80(a1)
    80002aa2:	0585bc83          	ld	s9,88(a1)
    80002aa6:	0605bd03          	ld	s10,96(a1)
    80002aaa:	0685bd83          	ld	s11,104(a1)
    80002aae:	8082                	ret

0000000080002ab0 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002ab0:	1141                	addi	sp,sp,-16
    80002ab2:	e406                	sd	ra,8(sp)
    80002ab4:	e022                	sd	s0,0(sp)
    80002ab6:	0800                	addi	s0,sp,16
    initlock(&tickslock, "time");
    80002ab8:	00006597          	auipc	a1,0x6
    80002abc:	91058593          	addi	a1,a1,-1776 # 800083c8 <states.0+0x30>
    80002ac0:	00014517          	auipc	a0,0x14
    80002ac4:	20050513          	addi	a0,a0,512 # 80016cc0 <tickslock>
    80002ac8:	ffffe097          	auipc	ra,0xffffe
    80002acc:	07e080e7          	jalr	126(ra) # 80000b46 <initlock>
}
    80002ad0:	60a2                	ld	ra,8(sp)
    80002ad2:	6402                	ld	s0,0(sp)
    80002ad4:	0141                	addi	sp,sp,16
    80002ad6:	8082                	ret

0000000080002ad8 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002ad8:	1141                	addi	sp,sp,-16
    80002ada:	e422                	sd	s0,8(sp)
    80002adc:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ade:	00003797          	auipc	a5,0x3
    80002ae2:	57278793          	addi	a5,a5,1394 # 80006050 <kernelvec>
    80002ae6:	10579073          	csrw	stvec,a5
    w_stvec((uint64)kernelvec);
}
    80002aea:	6422                	ld	s0,8(sp)
    80002aec:	0141                	addi	sp,sp,16
    80002aee:	8082                	ret

0000000080002af0 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002af0:	1141                	addi	sp,sp,-16
    80002af2:	e406                	sd	ra,8(sp)
    80002af4:	e022                	sd	s0,0(sp)
    80002af6:	0800                	addi	s0,sp,16
    struct proc *p = myproc();
    80002af8:	fffff097          	auipc	ra,0xfffff
    80002afc:	0f6080e7          	jalr	246(ra) # 80001bee <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b00:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b04:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b06:	10079073          	csrw	sstatus,a5
    // kerneltrap() to usertrap(), so turn off interrupts until
    // we're back in user space, where usertrap() is correct.
    intr_off();

    // send syscalls, interrupts, and exceptions to uservec in trampoline.S
    uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b0a:	00004697          	auipc	a3,0x4
    80002b0e:	4f668693          	addi	a3,a3,1270 # 80007000 <_trampoline>
    80002b12:	00004717          	auipc	a4,0x4
    80002b16:	4ee70713          	addi	a4,a4,1262 # 80007000 <_trampoline>
    80002b1a:	8f15                	sub	a4,a4,a3
    80002b1c:	040007b7          	lui	a5,0x4000
    80002b20:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b22:	07b2                	slli	a5,a5,0xc
    80002b24:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b26:	10571073          	csrw	stvec,a4
    w_stvec(trampoline_uservec);

    // set up trapframe values that uservec will need when
    // the process next traps into the kernel.
    p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b2a:	7138                	ld	a4,96(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b2c:	18002673          	csrr	a2,satp
    80002b30:	e310                	sd	a2,0(a4)
    p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b32:	7130                	ld	a2,96(a0)
    80002b34:	6538                	ld	a4,72(a0)
    80002b36:	6585                	lui	a1,0x1
    80002b38:	972e                	add	a4,a4,a1
    80002b3a:	e618                	sd	a4,8(a2)
    p->trapframe->kernel_trap = (uint64)usertrap;
    80002b3c:	7138                	ld	a4,96(a0)
    80002b3e:	00000617          	auipc	a2,0x0
    80002b42:	13060613          	addi	a2,a2,304 # 80002c6e <usertrap>
    80002b46:	eb10                	sd	a2,16(a4)
    p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002b48:	7138                	ld	a4,96(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b4a:	8612                	mv	a2,tp
    80002b4c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b4e:	10002773          	csrr	a4,sstatus
    // set up the registers that trampoline.S's sret will use
    // to get to user space.

    // set S Previous Privilege mode to User.
    unsigned long x = r_sstatus();
    x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b52:	eff77713          	andi	a4,a4,-257
    x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b56:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b5a:	10071073          	csrw	sstatus,a4
    w_sstatus(x);

    // set S Exception Program Counter to the saved user pc.
    w_sepc(p->trapframe->epc);
    80002b5e:	7138                	ld	a4,96(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002b60:	6f18                	ld	a4,24(a4)
    80002b62:	14171073          	csrw	sepc,a4

    // tell trampoline.S the user page table to switch to.
    uint64 satp = MAKE_SATP(p->pagetable);
    80002b66:	6d28                	ld	a0,88(a0)
    80002b68:	8131                	srli	a0,a0,0xc

    // jump to userret in trampoline.S at the top of memory, which
    // switches to the user page table, restores user registers,
    // and switches to user mode with sret.
    uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002b6a:	00004717          	auipc	a4,0x4
    80002b6e:	53270713          	addi	a4,a4,1330 # 8000709c <userret>
    80002b72:	8f15                	sub	a4,a4,a3
    80002b74:	97ba                	add	a5,a5,a4
    ((void (*)(uint64))trampoline_userret)(satp);
    80002b76:	577d                	li	a4,-1
    80002b78:	177e                	slli	a4,a4,0x3f
    80002b7a:	8d59                	or	a0,a0,a4
    80002b7c:	9782                	jalr	a5
}
    80002b7e:	60a2                	ld	ra,8(sp)
    80002b80:	6402                	ld	s0,0(sp)
    80002b82:	0141                	addi	sp,sp,16
    80002b84:	8082                	ret

0000000080002b86 <clockintr>:
    w_sepc(sepc);
    w_sstatus(sstatus);
}

void clockintr()
{
    80002b86:	1101                	addi	sp,sp,-32
    80002b88:	ec06                	sd	ra,24(sp)
    80002b8a:	e822                	sd	s0,16(sp)
    80002b8c:	e426                	sd	s1,8(sp)
    80002b8e:	1000                	addi	s0,sp,32
    acquire(&tickslock);
    80002b90:	00014497          	auipc	s1,0x14
    80002b94:	13048493          	addi	s1,s1,304 # 80016cc0 <tickslock>
    80002b98:	8526                	mv	a0,s1
    80002b9a:	ffffe097          	auipc	ra,0xffffe
    80002b9e:	03c080e7          	jalr	60(ra) # 80000bd6 <acquire>
    ticks++;
    80002ba2:	00006517          	auipc	a0,0x6
    80002ba6:	e8650513          	addi	a0,a0,-378 # 80008a28 <ticks>
    80002baa:	411c                	lw	a5,0(a0)
    80002bac:	2785                	addiw	a5,a5,1
    80002bae:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    80002bb0:	00000097          	auipc	ra,0x0
    80002bb4:	850080e7          	jalr	-1968(ra) # 80002400 <wakeup>
    release(&tickslock);
    80002bb8:	8526                	mv	a0,s1
    80002bba:	ffffe097          	auipc	ra,0xffffe
    80002bbe:	0d0080e7          	jalr	208(ra) # 80000c8a <release>
}
    80002bc2:	60e2                	ld	ra,24(sp)
    80002bc4:	6442                	ld	s0,16(sp)
    80002bc6:	64a2                	ld	s1,8(sp)
    80002bc8:	6105                	addi	sp,sp,32
    80002bca:	8082                	ret

0000000080002bcc <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002bcc:	1101                	addi	sp,sp,-32
    80002bce:	ec06                	sd	ra,24(sp)
    80002bd0:	e822                	sd	s0,16(sp)
    80002bd2:	e426                	sd	s1,8(sp)
    80002bd4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002bd6:	14202773          	csrr	a4,scause
    uint64 scause = r_scause();

    if ((scause & 0x8000000000000000L) &&
    80002bda:	00074d63          	bltz	a4,80002bf4 <devintr+0x28>
        if (irq)
            plic_complete(irq);

        return 1;
    }
    else if (scause == 0x8000000000000001L)
    80002bde:	57fd                	li	a5,-1
    80002be0:	17fe                	slli	a5,a5,0x3f
    80002be2:	0785                	addi	a5,a5,1

        return 2;
    }
    else
    {
        return 0;
    80002be4:	4501                	li	a0,0
    else if (scause == 0x8000000000000001L)
    80002be6:	06f70363          	beq	a4,a5,80002c4c <devintr+0x80>
    }
}
    80002bea:	60e2                	ld	ra,24(sp)
    80002bec:	6442                	ld	s0,16(sp)
    80002bee:	64a2                	ld	s1,8(sp)
    80002bf0:	6105                	addi	sp,sp,32
    80002bf2:	8082                	ret
        (scause & 0xff) == 9)
    80002bf4:	0ff77793          	zext.b	a5,a4
    if ((scause & 0x8000000000000000L) &&
    80002bf8:	46a5                	li	a3,9
    80002bfa:	fed792e3          	bne	a5,a3,80002bde <devintr+0x12>
        int irq = plic_claim();
    80002bfe:	00003097          	auipc	ra,0x3
    80002c02:	55a080e7          	jalr	1370(ra) # 80006158 <plic_claim>
    80002c06:	84aa                	mv	s1,a0
        if (irq == UART0_IRQ)
    80002c08:	47a9                	li	a5,10
    80002c0a:	02f50763          	beq	a0,a5,80002c38 <devintr+0x6c>
        else if (irq == VIRTIO0_IRQ)
    80002c0e:	4785                	li	a5,1
    80002c10:	02f50963          	beq	a0,a5,80002c42 <devintr+0x76>
        return 1;
    80002c14:	4505                	li	a0,1
        else if (irq)
    80002c16:	d8f1                	beqz	s1,80002bea <devintr+0x1e>
            printf("unexpected interrupt irq=%d\n", irq);
    80002c18:	85a6                	mv	a1,s1
    80002c1a:	00005517          	auipc	a0,0x5
    80002c1e:	7b650513          	addi	a0,a0,1974 # 800083d0 <states.0+0x38>
    80002c22:	ffffe097          	auipc	ra,0xffffe
    80002c26:	968080e7          	jalr	-1688(ra) # 8000058a <printf>
            plic_complete(irq);
    80002c2a:	8526                	mv	a0,s1
    80002c2c:	00003097          	auipc	ra,0x3
    80002c30:	550080e7          	jalr	1360(ra) # 8000617c <plic_complete>
        return 1;
    80002c34:	4505                	li	a0,1
    80002c36:	bf55                	j	80002bea <devintr+0x1e>
            uartintr();
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	d60080e7          	jalr	-672(ra) # 80000998 <uartintr>
    80002c40:	b7ed                	j	80002c2a <devintr+0x5e>
            virtio_disk_intr();
    80002c42:	00004097          	auipc	ra,0x4
    80002c46:	a02080e7          	jalr	-1534(ra) # 80006644 <virtio_disk_intr>
    80002c4a:	b7c5                	j	80002c2a <devintr+0x5e>
        if (cpuid() == 0)
    80002c4c:	fffff097          	auipc	ra,0xfffff
    80002c50:	f76080e7          	jalr	-138(ra) # 80001bc2 <cpuid>
    80002c54:	c901                	beqz	a0,80002c64 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002c56:	144027f3          	csrr	a5,sip
        w_sip(r_sip() & ~2);
    80002c5a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002c5c:	14479073          	csrw	sip,a5
        return 2;
    80002c60:	4509                	li	a0,2
    80002c62:	b761                	j	80002bea <devintr+0x1e>
            clockintr();
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	f22080e7          	jalr	-222(ra) # 80002b86 <clockintr>
    80002c6c:	b7ed                	j	80002c56 <devintr+0x8a>

0000000080002c6e <usertrap>:
{
    80002c6e:	1101                	addi	sp,sp,-32
    80002c70:	ec06                	sd	ra,24(sp)
    80002c72:	e822                	sd	s0,16(sp)
    80002c74:	e426                	sd	s1,8(sp)
    80002c76:	e04a                	sd	s2,0(sp)
    80002c78:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002c7a:	100027f3          	csrr	a5,sstatus
    if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002c7e:	1007f793          	andi	a5,a5,256
    80002c82:	e3b1                	bnez	a5,80002cc6 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c84:	00003797          	auipc	a5,0x3
    80002c88:	3cc78793          	addi	a5,a5,972 # 80006050 <kernelvec>
    80002c8c:	10579073          	csrw	stvec,a5
    struct proc *p = myproc();
    80002c90:	fffff097          	auipc	ra,0xfffff
    80002c94:	f5e080e7          	jalr	-162(ra) # 80001bee <myproc>
    80002c98:	84aa                	mv	s1,a0
    p->trapframe->epc = r_sepc();
    80002c9a:	713c                	ld	a5,96(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002c9c:	14102773          	csrr	a4,sepc
    80002ca0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ca2:	14202773          	csrr	a4,scause
    if (r_scause() == 8)
    80002ca6:	47a1                	li	a5,8
    80002ca8:	02f70763          	beq	a4,a5,80002cd6 <usertrap+0x68>
    else if ((which_dev = devintr()) != 0)
    80002cac:	00000097          	auipc	ra,0x0
    80002cb0:	f20080e7          	jalr	-224(ra) # 80002bcc <devintr>
    80002cb4:	892a                	mv	s2,a0
    80002cb6:	c151                	beqz	a0,80002d3a <usertrap+0xcc>
    if (killed(p))
    80002cb8:	8526                	mv	a0,s1
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	98a080e7          	jalr	-1654(ra) # 80002644 <killed>
    80002cc2:	c929                	beqz	a0,80002d14 <usertrap+0xa6>
    80002cc4:	a099                	j	80002d0a <usertrap+0x9c>
        panic("usertrap: not from user mode");
    80002cc6:	00005517          	auipc	a0,0x5
    80002cca:	72a50513          	addi	a0,a0,1834 # 800083f0 <states.0+0x58>
    80002cce:	ffffe097          	auipc	ra,0xffffe
    80002cd2:	872080e7          	jalr	-1934(ra) # 80000540 <panic>
        if (killed(p))
    80002cd6:	00000097          	auipc	ra,0x0
    80002cda:	96e080e7          	jalr	-1682(ra) # 80002644 <killed>
    80002cde:	e921                	bnez	a0,80002d2e <usertrap+0xc0>
        p->trapframe->epc += 4;
    80002ce0:	70b8                	ld	a4,96(s1)
    80002ce2:	6f1c                	ld	a5,24(a4)
    80002ce4:	0791                	addi	a5,a5,4
    80002ce6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ce8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002cec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002cf0:	10079073          	csrw	sstatus,a5
        syscall();
    80002cf4:	00000097          	auipc	ra,0x0
    80002cf8:	2d8080e7          	jalr	728(ra) # 80002fcc <syscall>
    if (killed(p))
    80002cfc:	8526                	mv	a0,s1
    80002cfe:	00000097          	auipc	ra,0x0
    80002d02:	946080e7          	jalr	-1722(ra) # 80002644 <killed>
    80002d06:	c911                	beqz	a0,80002d1a <usertrap+0xac>
    80002d08:	4901                	li	s2,0
        exit(-1);
    80002d0a:	557d                	li	a0,-1
    80002d0c:	fffff097          	auipc	ra,0xfffff
    80002d10:	7c4080e7          	jalr	1988(ra) # 800024d0 <exit>
    if (which_dev == 2)
    80002d14:	4789                	li	a5,2
    80002d16:	04f90f63          	beq	s2,a5,80002d74 <usertrap+0x106>
    usertrapret();
    80002d1a:	00000097          	auipc	ra,0x0
    80002d1e:	dd6080e7          	jalr	-554(ra) # 80002af0 <usertrapret>
}
    80002d22:	60e2                	ld	ra,24(sp)
    80002d24:	6442                	ld	s0,16(sp)
    80002d26:	64a2                	ld	s1,8(sp)
    80002d28:	6902                	ld	s2,0(sp)
    80002d2a:	6105                	addi	sp,sp,32
    80002d2c:	8082                	ret
            exit(-1);
    80002d2e:	557d                	li	a0,-1
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	7a0080e7          	jalr	1952(ra) # 800024d0 <exit>
    80002d38:	b765                	j	80002ce0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d3a:	142025f3          	csrr	a1,scause
        printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d3e:	5c90                	lw	a2,56(s1)
    80002d40:	00005517          	auipc	a0,0x5
    80002d44:	6d050513          	addi	a0,a0,1744 # 80008410 <states.0+0x78>
    80002d48:	ffffe097          	auipc	ra,0xffffe
    80002d4c:	842080e7          	jalr	-1982(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d50:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002d54:	14302673          	csrr	a2,stval
        printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002d58:	00005517          	auipc	a0,0x5
    80002d5c:	6e850513          	addi	a0,a0,1768 # 80008440 <states.0+0xa8>
    80002d60:	ffffe097          	auipc	ra,0xffffe
    80002d64:	82a080e7          	jalr	-2006(ra) # 8000058a <printf>
        setkilled(p);
    80002d68:	8526                	mv	a0,s1
    80002d6a:	00000097          	auipc	ra,0x0
    80002d6e:	8ae080e7          	jalr	-1874(ra) # 80002618 <setkilled>
    80002d72:	b769                	j	80002cfc <usertrap+0x8e>
        yield(YIELD_TIMER);
    80002d74:	4505                	li	a0,1
    80002d76:	fffff097          	auipc	ra,0xfffff
    80002d7a:	5ea080e7          	jalr	1514(ra) # 80002360 <yield>
    80002d7e:	bf71                	j	80002d1a <usertrap+0xac>

0000000080002d80 <kerneltrap>:
{
    80002d80:	7179                	addi	sp,sp,-48
    80002d82:	f406                	sd	ra,40(sp)
    80002d84:	f022                	sd	s0,32(sp)
    80002d86:	ec26                	sd	s1,24(sp)
    80002d88:	e84a                	sd	s2,16(sp)
    80002d8a:	e44e                	sd	s3,8(sp)
    80002d8c:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d8e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d92:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d96:	142029f3          	csrr	s3,scause
    if ((sstatus & SSTATUS_SPP) == 0)
    80002d9a:	1004f793          	andi	a5,s1,256
    80002d9e:	cb85                	beqz	a5,80002dce <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002da0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002da4:	8b89                	andi	a5,a5,2
    if (intr_get() != 0)
    80002da6:	ef85                	bnez	a5,80002dde <kerneltrap+0x5e>
    if ((which_dev = devintr()) == 0)
    80002da8:	00000097          	auipc	ra,0x0
    80002dac:	e24080e7          	jalr	-476(ra) # 80002bcc <devintr>
    80002db0:	cd1d                	beqz	a0,80002dee <kerneltrap+0x6e>
    if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002db2:	4789                	li	a5,2
    80002db4:	06f50a63          	beq	a0,a5,80002e28 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002db8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dbc:	10049073          	csrw	sstatus,s1
}
    80002dc0:	70a2                	ld	ra,40(sp)
    80002dc2:	7402                	ld	s0,32(sp)
    80002dc4:	64e2                	ld	s1,24(sp)
    80002dc6:	6942                	ld	s2,16(sp)
    80002dc8:	69a2                	ld	s3,8(sp)
    80002dca:	6145                	addi	sp,sp,48
    80002dcc:	8082                	ret
        panic("kerneltrap: not from supervisor mode");
    80002dce:	00005517          	auipc	a0,0x5
    80002dd2:	69250513          	addi	a0,a0,1682 # 80008460 <states.0+0xc8>
    80002dd6:	ffffd097          	auipc	ra,0xffffd
    80002dda:	76a080e7          	jalr	1898(ra) # 80000540 <panic>
        panic("kerneltrap: interrupts enabled");
    80002dde:	00005517          	auipc	a0,0x5
    80002de2:	6aa50513          	addi	a0,a0,1706 # 80008488 <states.0+0xf0>
    80002de6:	ffffd097          	auipc	ra,0xffffd
    80002dea:	75a080e7          	jalr	1882(ra) # 80000540 <panic>
        printf("scause %p\n", scause);
    80002dee:	85ce                	mv	a1,s3
    80002df0:	00005517          	auipc	a0,0x5
    80002df4:	6b850513          	addi	a0,a0,1720 # 800084a8 <states.0+0x110>
    80002df8:	ffffd097          	auipc	ra,0xffffd
    80002dfc:	792080e7          	jalr	1938(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e00:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e04:	14302673          	csrr	a2,stval
        printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e08:	00005517          	auipc	a0,0x5
    80002e0c:	6b050513          	addi	a0,a0,1712 # 800084b8 <states.0+0x120>
    80002e10:	ffffd097          	auipc	ra,0xffffd
    80002e14:	77a080e7          	jalr	1914(ra) # 8000058a <printf>
        panic("kerneltrap");
    80002e18:	00005517          	auipc	a0,0x5
    80002e1c:	6b850513          	addi	a0,a0,1720 # 800084d0 <states.0+0x138>
    80002e20:	ffffd097          	auipc	ra,0xffffd
    80002e24:	720080e7          	jalr	1824(ra) # 80000540 <panic>
    if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e28:	fffff097          	auipc	ra,0xfffff
    80002e2c:	dc6080e7          	jalr	-570(ra) # 80001bee <myproc>
    80002e30:	d541                	beqz	a0,80002db8 <kerneltrap+0x38>
    80002e32:	fffff097          	auipc	ra,0xfffff
    80002e36:	dbc080e7          	jalr	-580(ra) # 80001bee <myproc>
    80002e3a:	4d18                	lw	a4,24(a0)
    80002e3c:	4791                	li	a5,4
    80002e3e:	f6f71de3          	bne	a4,a5,80002db8 <kerneltrap+0x38>
        yield(YIELD_OTHER);
    80002e42:	4509                	li	a0,2
    80002e44:	fffff097          	auipc	ra,0xfffff
    80002e48:	51c080e7          	jalr	1308(ra) # 80002360 <yield>
    80002e4c:	b7b5                	j	80002db8 <kerneltrap+0x38>

0000000080002e4e <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e4e:	1101                	addi	sp,sp,-32
    80002e50:	ec06                	sd	ra,24(sp)
    80002e52:	e822                	sd	s0,16(sp)
    80002e54:	e426                	sd	s1,8(sp)
    80002e56:	1000                	addi	s0,sp,32
    80002e58:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002e5a:	fffff097          	auipc	ra,0xfffff
    80002e5e:	d94080e7          	jalr	-620(ra) # 80001bee <myproc>
    switch (n)
    80002e62:	4795                	li	a5,5
    80002e64:	0497e163          	bltu	a5,s1,80002ea6 <argraw+0x58>
    80002e68:	048a                	slli	s1,s1,0x2
    80002e6a:	00005717          	auipc	a4,0x5
    80002e6e:	69e70713          	addi	a4,a4,1694 # 80008508 <states.0+0x170>
    80002e72:	94ba                	add	s1,s1,a4
    80002e74:	409c                	lw	a5,0(s1)
    80002e76:	97ba                	add	a5,a5,a4
    80002e78:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002e7a:	713c                	ld	a5,96(a0)
    80002e7c:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002e7e:	60e2                	ld	ra,24(sp)
    80002e80:	6442                	ld	s0,16(sp)
    80002e82:	64a2                	ld	s1,8(sp)
    80002e84:	6105                	addi	sp,sp,32
    80002e86:	8082                	ret
        return p->trapframe->a1;
    80002e88:	713c                	ld	a5,96(a0)
    80002e8a:	7fa8                	ld	a0,120(a5)
    80002e8c:	bfcd                	j	80002e7e <argraw+0x30>
        return p->trapframe->a2;
    80002e8e:	713c                	ld	a5,96(a0)
    80002e90:	63c8                	ld	a0,128(a5)
    80002e92:	b7f5                	j	80002e7e <argraw+0x30>
        return p->trapframe->a3;
    80002e94:	713c                	ld	a5,96(a0)
    80002e96:	67c8                	ld	a0,136(a5)
    80002e98:	b7dd                	j	80002e7e <argraw+0x30>
        return p->trapframe->a4;
    80002e9a:	713c                	ld	a5,96(a0)
    80002e9c:	6bc8                	ld	a0,144(a5)
    80002e9e:	b7c5                	j	80002e7e <argraw+0x30>
        return p->trapframe->a5;
    80002ea0:	713c                	ld	a5,96(a0)
    80002ea2:	6fc8                	ld	a0,152(a5)
    80002ea4:	bfe9                	j	80002e7e <argraw+0x30>
    panic("argraw");
    80002ea6:	00005517          	auipc	a0,0x5
    80002eaa:	63a50513          	addi	a0,a0,1594 # 800084e0 <states.0+0x148>
    80002eae:	ffffd097          	auipc	ra,0xffffd
    80002eb2:	692080e7          	jalr	1682(ra) # 80000540 <panic>

0000000080002eb6 <fetchaddr>:
{
    80002eb6:	1101                	addi	sp,sp,-32
    80002eb8:	ec06                	sd	ra,24(sp)
    80002eba:	e822                	sd	s0,16(sp)
    80002ebc:	e426                	sd	s1,8(sp)
    80002ebe:	e04a                	sd	s2,0(sp)
    80002ec0:	1000                	addi	s0,sp,32
    80002ec2:	84aa                	mv	s1,a0
    80002ec4:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002ec6:	fffff097          	auipc	ra,0xfffff
    80002eca:	d28080e7          	jalr	-728(ra) # 80001bee <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002ece:	693c                	ld	a5,80(a0)
    80002ed0:	02f4f863          	bgeu	s1,a5,80002f00 <fetchaddr+0x4a>
    80002ed4:	00848713          	addi	a4,s1,8
    80002ed8:	02e7e663          	bltu	a5,a4,80002f04 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002edc:	46a1                	li	a3,8
    80002ede:	8626                	mv	a2,s1
    80002ee0:	85ca                	mv	a1,s2
    80002ee2:	6d28                	ld	a0,88(a0)
    80002ee4:	fffff097          	auipc	ra,0xfffff
    80002ee8:	814080e7          	jalr	-2028(ra) # 800016f8 <copyin>
    80002eec:	00a03533          	snez	a0,a0
    80002ef0:	40a00533          	neg	a0,a0
}
    80002ef4:	60e2                	ld	ra,24(sp)
    80002ef6:	6442                	ld	s0,16(sp)
    80002ef8:	64a2                	ld	s1,8(sp)
    80002efa:	6902                	ld	s2,0(sp)
    80002efc:	6105                	addi	sp,sp,32
    80002efe:	8082                	ret
        return -1;
    80002f00:	557d                	li	a0,-1
    80002f02:	bfcd                	j	80002ef4 <fetchaddr+0x3e>
    80002f04:	557d                	li	a0,-1
    80002f06:	b7fd                	j	80002ef4 <fetchaddr+0x3e>

0000000080002f08 <fetchstr>:
{
    80002f08:	7179                	addi	sp,sp,-48
    80002f0a:	f406                	sd	ra,40(sp)
    80002f0c:	f022                	sd	s0,32(sp)
    80002f0e:	ec26                	sd	s1,24(sp)
    80002f10:	e84a                	sd	s2,16(sp)
    80002f12:	e44e                	sd	s3,8(sp)
    80002f14:	1800                	addi	s0,sp,48
    80002f16:	892a                	mv	s2,a0
    80002f18:	84ae                	mv	s1,a1
    80002f1a:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002f1c:	fffff097          	auipc	ra,0xfffff
    80002f20:	cd2080e7          	jalr	-814(ra) # 80001bee <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f24:	86ce                	mv	a3,s3
    80002f26:	864a                	mv	a2,s2
    80002f28:	85a6                	mv	a1,s1
    80002f2a:	6d28                	ld	a0,88(a0)
    80002f2c:	fffff097          	auipc	ra,0xfffff
    80002f30:	85a080e7          	jalr	-1958(ra) # 80001786 <copyinstr>
    80002f34:	00054e63          	bltz	a0,80002f50 <fetchstr+0x48>
    return strlen(buf);
    80002f38:	8526                	mv	a0,s1
    80002f3a:	ffffe097          	auipc	ra,0xffffe
    80002f3e:	f14080e7          	jalr	-236(ra) # 80000e4e <strlen>
}
    80002f42:	70a2                	ld	ra,40(sp)
    80002f44:	7402                	ld	s0,32(sp)
    80002f46:	64e2                	ld	s1,24(sp)
    80002f48:	6942                	ld	s2,16(sp)
    80002f4a:	69a2                	ld	s3,8(sp)
    80002f4c:	6145                	addi	sp,sp,48
    80002f4e:	8082                	ret
        return -1;
    80002f50:	557d                	li	a0,-1
    80002f52:	bfc5                	j	80002f42 <fetchstr+0x3a>

0000000080002f54 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f54:	1101                	addi	sp,sp,-32
    80002f56:	ec06                	sd	ra,24(sp)
    80002f58:	e822                	sd	s0,16(sp)
    80002f5a:	e426                	sd	s1,8(sp)
    80002f5c:	1000                	addi	s0,sp,32
    80002f5e:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f60:	00000097          	auipc	ra,0x0
    80002f64:	eee080e7          	jalr	-274(ra) # 80002e4e <argraw>
    80002f68:	c088                	sw	a0,0(s1)
}
    80002f6a:	60e2                	ld	ra,24(sp)
    80002f6c:	6442                	ld	s0,16(sp)
    80002f6e:	64a2                	ld	s1,8(sp)
    80002f70:	6105                	addi	sp,sp,32
    80002f72:	8082                	ret

0000000080002f74 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002f74:	1101                	addi	sp,sp,-32
    80002f76:	ec06                	sd	ra,24(sp)
    80002f78:	e822                	sd	s0,16(sp)
    80002f7a:	e426                	sd	s1,8(sp)
    80002f7c:	1000                	addi	s0,sp,32
    80002f7e:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	ece080e7          	jalr	-306(ra) # 80002e4e <argraw>
    80002f88:	e088                	sd	a0,0(s1)
}
    80002f8a:	60e2                	ld	ra,24(sp)
    80002f8c:	6442                	ld	s0,16(sp)
    80002f8e:	64a2                	ld	s1,8(sp)
    80002f90:	6105                	addi	sp,sp,32
    80002f92:	8082                	ret

0000000080002f94 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002f94:	7179                	addi	sp,sp,-48
    80002f96:	f406                	sd	ra,40(sp)
    80002f98:	f022                	sd	s0,32(sp)
    80002f9a:	ec26                	sd	s1,24(sp)
    80002f9c:	e84a                	sd	s2,16(sp)
    80002f9e:	1800                	addi	s0,sp,48
    80002fa0:	84ae                	mv	s1,a1
    80002fa2:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002fa4:	fd840593          	addi	a1,s0,-40
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	fcc080e7          	jalr	-52(ra) # 80002f74 <argaddr>
    return fetchstr(addr, buf, max);
    80002fb0:	864a                	mv	a2,s2
    80002fb2:	85a6                	mv	a1,s1
    80002fb4:	fd843503          	ld	a0,-40(s0)
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	f50080e7          	jalr	-176(ra) # 80002f08 <fetchstr>
}
    80002fc0:	70a2                	ld	ra,40(sp)
    80002fc2:	7402                	ld	s0,32(sp)
    80002fc4:	64e2                	ld	s1,24(sp)
    80002fc6:	6942                	ld	s2,16(sp)
    80002fc8:	6145                	addi	sp,sp,48
    80002fca:	8082                	ret

0000000080002fcc <syscall>:
    [SYS_schedset] sys_schedset,
    [SYS_yield] sys_yield,
};

void syscall(void)
{
    80002fcc:	1101                	addi	sp,sp,-32
    80002fce:	ec06                	sd	ra,24(sp)
    80002fd0:	e822                	sd	s0,16(sp)
    80002fd2:	e426                	sd	s1,8(sp)
    80002fd4:	e04a                	sd	s2,0(sp)
    80002fd6:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80002fd8:	fffff097          	auipc	ra,0xfffff
    80002fdc:	c16080e7          	jalr	-1002(ra) # 80001bee <myproc>
    80002fe0:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80002fe2:	06053903          	ld	s2,96(a0)
    80002fe6:	0a893783          	ld	a5,168(s2)
    80002fea:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80002fee:	37fd                	addiw	a5,a5,-1
    80002ff0:	4761                	li	a4,24
    80002ff2:	00f76f63          	bltu	a4,a5,80003010 <syscall+0x44>
    80002ff6:	00369713          	slli	a4,a3,0x3
    80002ffa:	00005797          	auipc	a5,0x5
    80002ffe:	52678793          	addi	a5,a5,1318 # 80008520 <syscalls>
    80003002:	97ba                	add	a5,a5,a4
    80003004:	639c                	ld	a5,0(a5)
    80003006:	c789                	beqz	a5,80003010 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003008:	9782                	jalr	a5
    8000300a:	06a93823          	sd	a0,112(s2)
    8000300e:	a839                	j	8000302c <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80003010:	16048613          	addi	a2,s1,352
    80003014:	5c8c                	lw	a1,56(s1)
    80003016:	00005517          	auipc	a0,0x5
    8000301a:	4d250513          	addi	a0,a0,1234 # 800084e8 <states.0+0x150>
    8000301e:	ffffd097          	auipc	ra,0xffffd
    80003022:	56c080e7          	jalr	1388(ra) # 8000058a <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003026:	70bc                	ld	a5,96(s1)
    80003028:	577d                	li	a4,-1
    8000302a:	fbb8                	sd	a4,112(a5)
    }
}
    8000302c:	60e2                	ld	ra,24(sp)
    8000302e:	6442                	ld	s0,16(sp)
    80003030:	64a2                	ld	s1,8(sp)
    80003032:	6902                	ld	s2,0(sp)
    80003034:	6105                	addi	sp,sp,32
    80003036:	8082                	ret

0000000080003038 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003038:	1101                	addi	sp,sp,-32
    8000303a:	ec06                	sd	ra,24(sp)
    8000303c:	e822                	sd	s0,16(sp)
    8000303e:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80003040:	fec40593          	addi	a1,s0,-20
    80003044:	4501                	li	a0,0
    80003046:	00000097          	auipc	ra,0x0
    8000304a:	f0e080e7          	jalr	-242(ra) # 80002f54 <argint>
    exit(n);
    8000304e:	fec42503          	lw	a0,-20(s0)
    80003052:	fffff097          	auipc	ra,0xfffff
    80003056:	47e080e7          	jalr	1150(ra) # 800024d0 <exit>
    return 0; // not reached
}
    8000305a:	4501                	li	a0,0
    8000305c:	60e2                	ld	ra,24(sp)
    8000305e:	6442                	ld	s0,16(sp)
    80003060:	6105                	addi	sp,sp,32
    80003062:	8082                	ret

0000000080003064 <sys_getpid>:

uint64
sys_getpid(void)
{
    80003064:	1141                	addi	sp,sp,-16
    80003066:	e406                	sd	ra,8(sp)
    80003068:	e022                	sd	s0,0(sp)
    8000306a:	0800                	addi	s0,sp,16
    return myproc()->pid;
    8000306c:	fffff097          	auipc	ra,0xfffff
    80003070:	b82080e7          	jalr	-1150(ra) # 80001bee <myproc>
}
    80003074:	5d08                	lw	a0,56(a0)
    80003076:	60a2                	ld	ra,8(sp)
    80003078:	6402                	ld	s0,0(sp)
    8000307a:	0141                	addi	sp,sp,16
    8000307c:	8082                	ret

000000008000307e <sys_fork>:

uint64
sys_fork(void)
{
    8000307e:	1141                	addi	sp,sp,-16
    80003080:	e406                	sd	ra,8(sp)
    80003082:	e022                	sd	s0,0(sp)
    80003084:	0800                	addi	s0,sp,16
    return fork();
    80003086:	fffff097          	auipc	ra,0xfffff
    8000308a:	0b4080e7          	jalr	180(ra) # 8000213a <fork>
}
    8000308e:	60a2                	ld	ra,8(sp)
    80003090:	6402                	ld	s0,0(sp)
    80003092:	0141                	addi	sp,sp,16
    80003094:	8082                	ret

0000000080003096 <sys_wait>:

uint64
sys_wait(void)
{
    80003096:	1101                	addi	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    8000309e:	fe840593          	addi	a1,s0,-24
    800030a2:	4501                	li	a0,0
    800030a4:	00000097          	auipc	ra,0x0
    800030a8:	ed0080e7          	jalr	-304(ra) # 80002f74 <argaddr>
    return wait(p);
    800030ac:	fe843503          	ld	a0,-24(s0)
    800030b0:	fffff097          	auipc	ra,0xfffff
    800030b4:	5c6080e7          	jalr	1478(ra) # 80002676 <wait>
}
    800030b8:	60e2                	ld	ra,24(sp)
    800030ba:	6442                	ld	s0,16(sp)
    800030bc:	6105                	addi	sp,sp,32
    800030be:	8082                	ret

00000000800030c0 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    800030c0:	7179                	addi	sp,sp,-48
    800030c2:	f406                	sd	ra,40(sp)
    800030c4:	f022                	sd	s0,32(sp)
    800030c6:	ec26                	sd	s1,24(sp)
    800030c8:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    800030ca:	fdc40593          	addi	a1,s0,-36
    800030ce:	4501                	li	a0,0
    800030d0:	00000097          	auipc	ra,0x0
    800030d4:	e84080e7          	jalr	-380(ra) # 80002f54 <argint>
    addr = myproc()->sz;
    800030d8:	fffff097          	auipc	ra,0xfffff
    800030dc:	b16080e7          	jalr	-1258(ra) # 80001bee <myproc>
    800030e0:	6924                	ld	s1,80(a0)
    if (growproc(n) < 0)
    800030e2:	fdc42503          	lw	a0,-36(s0)
    800030e6:	fffff097          	auipc	ra,0xfffff
    800030ea:	e62080e7          	jalr	-414(ra) # 80001f48 <growproc>
    800030ee:	00054863          	bltz	a0,800030fe <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    800030f2:	8526                	mv	a0,s1
    800030f4:	70a2                	ld	ra,40(sp)
    800030f6:	7402                	ld	s0,32(sp)
    800030f8:	64e2                	ld	s1,24(sp)
    800030fa:	6145                	addi	sp,sp,48
    800030fc:	8082                	ret
        return -1;
    800030fe:	54fd                	li	s1,-1
    80003100:	bfcd                	j	800030f2 <sys_sbrk+0x32>

0000000080003102 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003102:	7139                	addi	sp,sp,-64
    80003104:	fc06                	sd	ra,56(sp)
    80003106:	f822                	sd	s0,48(sp)
    80003108:	f426                	sd	s1,40(sp)
    8000310a:	f04a                	sd	s2,32(sp)
    8000310c:	ec4e                	sd	s3,24(sp)
    8000310e:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003110:	fcc40593          	addi	a1,s0,-52
    80003114:	4501                	li	a0,0
    80003116:	00000097          	auipc	ra,0x0
    8000311a:	e3e080e7          	jalr	-450(ra) # 80002f54 <argint>
    acquire(&tickslock);
    8000311e:	00014517          	auipc	a0,0x14
    80003122:	ba250513          	addi	a0,a0,-1118 # 80016cc0 <tickslock>
    80003126:	ffffe097          	auipc	ra,0xffffe
    8000312a:	ab0080e7          	jalr	-1360(ra) # 80000bd6 <acquire>
    ticks0 = ticks;
    8000312e:	00006917          	auipc	s2,0x6
    80003132:	8fa92903          	lw	s2,-1798(s2) # 80008a28 <ticks>
    while (ticks - ticks0 < n)
    80003136:	fcc42783          	lw	a5,-52(s0)
    8000313a:	cf9d                	beqz	a5,80003178 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    8000313c:	00014997          	auipc	s3,0x14
    80003140:	b8498993          	addi	s3,s3,-1148 # 80016cc0 <tickslock>
    80003144:	00006497          	auipc	s1,0x6
    80003148:	8e448493          	addi	s1,s1,-1820 # 80008a28 <ticks>
        if (killed(myproc()))
    8000314c:	fffff097          	auipc	ra,0xfffff
    80003150:	aa2080e7          	jalr	-1374(ra) # 80001bee <myproc>
    80003154:	fffff097          	auipc	ra,0xfffff
    80003158:	4f0080e7          	jalr	1264(ra) # 80002644 <killed>
    8000315c:	ed15                	bnez	a0,80003198 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    8000315e:	85ce                	mv	a1,s3
    80003160:	8526                	mv	a0,s1
    80003162:	fffff097          	auipc	ra,0xfffff
    80003166:	23a080e7          	jalr	570(ra) # 8000239c <sleep>
    while (ticks - ticks0 < n)
    8000316a:	409c                	lw	a5,0(s1)
    8000316c:	412787bb          	subw	a5,a5,s2
    80003170:	fcc42703          	lw	a4,-52(s0)
    80003174:	fce7ece3          	bltu	a5,a4,8000314c <sys_sleep+0x4a>
    }
    release(&tickslock);
    80003178:	00014517          	auipc	a0,0x14
    8000317c:	b4850513          	addi	a0,a0,-1208 # 80016cc0 <tickslock>
    80003180:	ffffe097          	auipc	ra,0xffffe
    80003184:	b0a080e7          	jalr	-1270(ra) # 80000c8a <release>
    return 0;
    80003188:	4501                	li	a0,0
}
    8000318a:	70e2                	ld	ra,56(sp)
    8000318c:	7442                	ld	s0,48(sp)
    8000318e:	74a2                	ld	s1,40(sp)
    80003190:	7902                	ld	s2,32(sp)
    80003192:	69e2                	ld	s3,24(sp)
    80003194:	6121                	addi	sp,sp,64
    80003196:	8082                	ret
            release(&tickslock);
    80003198:	00014517          	auipc	a0,0x14
    8000319c:	b2850513          	addi	a0,a0,-1240 # 80016cc0 <tickslock>
    800031a0:	ffffe097          	auipc	ra,0xffffe
    800031a4:	aea080e7          	jalr	-1302(ra) # 80000c8a <release>
            return -1;
    800031a8:	557d                	li	a0,-1
    800031aa:	b7c5                	j	8000318a <sys_sleep+0x88>

00000000800031ac <sys_kill>:

uint64
sys_kill(void)
{
    800031ac:	1101                	addi	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800031b4:	fec40593          	addi	a1,s0,-20
    800031b8:	4501                	li	a0,0
    800031ba:	00000097          	auipc	ra,0x0
    800031be:	d9a080e7          	jalr	-614(ra) # 80002f54 <argint>
    return kill(pid);
    800031c2:	fec42503          	lw	a0,-20(s0)
    800031c6:	fffff097          	auipc	ra,0xfffff
    800031ca:	3e0080e7          	jalr	992(ra) # 800025a6 <kill>
}
    800031ce:	60e2                	ld	ra,24(sp)
    800031d0:	6442                	ld	s0,16(sp)
    800031d2:	6105                	addi	sp,sp,32
    800031d4:	8082                	ret

00000000800031d6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800031d6:	1101                	addi	sp,sp,-32
    800031d8:	ec06                	sd	ra,24(sp)
    800031da:	e822                	sd	s0,16(sp)
    800031dc:	e426                	sd	s1,8(sp)
    800031de:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    800031e0:	00014517          	auipc	a0,0x14
    800031e4:	ae050513          	addi	a0,a0,-1312 # 80016cc0 <tickslock>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	9ee080e7          	jalr	-1554(ra) # 80000bd6 <acquire>
    xticks = ticks;
    800031f0:	00006497          	auipc	s1,0x6
    800031f4:	8384a483          	lw	s1,-1992(s1) # 80008a28 <ticks>
    release(&tickslock);
    800031f8:	00014517          	auipc	a0,0x14
    800031fc:	ac850513          	addi	a0,a0,-1336 # 80016cc0 <tickslock>
    80003200:	ffffe097          	auipc	ra,0xffffe
    80003204:	a8a080e7          	jalr	-1398(ra) # 80000c8a <release>
    return xticks;
}
    80003208:	02049513          	slli	a0,s1,0x20
    8000320c:	9101                	srli	a0,a0,0x20
    8000320e:	60e2                	ld	ra,24(sp)
    80003210:	6442                	ld	s0,16(sp)
    80003212:	64a2                	ld	s1,8(sp)
    80003214:	6105                	addi	sp,sp,32
    80003216:	8082                	ret

0000000080003218 <sys_ps>:

void *
sys_ps(void)
{
    80003218:	1101                	addi	sp,sp,-32
    8000321a:	ec06                	sd	ra,24(sp)
    8000321c:	e822                	sd	s0,16(sp)
    8000321e:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003220:	fe042623          	sw	zero,-20(s0)
    80003224:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003228:	fec40593          	addi	a1,s0,-20
    8000322c:	4501                	li	a0,0
    8000322e:	00000097          	auipc	ra,0x0
    80003232:	d26080e7          	jalr	-730(ra) # 80002f54 <argint>
    argint(1, &count);
    80003236:	fe840593          	addi	a1,s0,-24
    8000323a:	4505                	li	a0,1
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	d18080e7          	jalr	-744(ra) # 80002f54 <argint>
    return ps((uint8)start, (uint8)count);
    80003244:	fe844583          	lbu	a1,-24(s0)
    80003248:	fec44503          	lbu	a0,-20(s0)
    8000324c:	fffff097          	auipc	ra,0xfffff
    80003250:	d58080e7          	jalr	-680(ra) # 80001fa4 <ps>
}
    80003254:	60e2                	ld	ra,24(sp)
    80003256:	6442                	ld	s0,16(sp)
    80003258:	6105                	addi	sp,sp,32
    8000325a:	8082                	ret

000000008000325c <sys_schedls>:

uint64 sys_schedls(void)
{
    8000325c:	1141                	addi	sp,sp,-16
    8000325e:	e406                	sd	ra,8(sp)
    80003260:	e022                	sd	s0,0(sp)
    80003262:	0800                	addi	s0,sp,16
    schedls();
    80003264:	fffff097          	auipc	ra,0xfffff
    80003268:	69c080e7          	jalr	1692(ra) # 80002900 <schedls>
    return 0;
}
    8000326c:	4501                	li	a0,0
    8000326e:	60a2                	ld	ra,8(sp)
    80003270:	6402                	ld	s0,0(sp)
    80003272:	0141                	addi	sp,sp,16
    80003274:	8082                	ret

0000000080003276 <sys_schedset>:

uint64 sys_schedset(void)
{
    80003276:	1101                	addi	sp,sp,-32
    80003278:	ec06                	sd	ra,24(sp)
    8000327a:	e822                	sd	s0,16(sp)
    8000327c:	1000                	addi	s0,sp,32
    int id = 0;
    8000327e:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    80003282:	fec40593          	addi	a1,s0,-20
    80003286:	4501                	li	a0,0
    80003288:	00000097          	auipc	ra,0x0
    8000328c:	ccc080e7          	jalr	-820(ra) # 80002f54 <argint>
    schedset(id - 1);
    80003290:	fec42503          	lw	a0,-20(s0)
    80003294:	357d                	addiw	a0,a0,-1
    80003296:	fffff097          	auipc	ra,0xfffff
    8000329a:	756080e7          	jalr	1878(ra) # 800029ec <schedset>
    return 0;
}
    8000329e:	4501                	li	a0,0
    800032a0:	60e2                	ld	ra,24(sp)
    800032a2:	6442                	ld	s0,16(sp)
    800032a4:	6105                	addi	sp,sp,32
    800032a6:	8082                	ret

00000000800032a8 <sys_yield>:

uint64 sys_yield(void)
{
    800032a8:	1141                	addi	sp,sp,-16
    800032aa:	e406                	sd	ra,8(sp)
    800032ac:	e022                	sd	s0,0(sp)
    800032ae:	0800                	addi	s0,sp,16
    yield(YIELD_OTHER);
    800032b0:	4509                	li	a0,2
    800032b2:	fffff097          	auipc	ra,0xfffff
    800032b6:	0ae080e7          	jalr	174(ra) # 80002360 <yield>
    return 0;
    800032ba:	4501                	li	a0,0
    800032bc:	60a2                	ld	ra,8(sp)
    800032be:	6402                	ld	s0,0(sp)
    800032c0:	0141                	addi	sp,sp,16
    800032c2:	8082                	ret

00000000800032c4 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032c4:	7179                	addi	sp,sp,-48
    800032c6:	f406                	sd	ra,40(sp)
    800032c8:	f022                	sd	s0,32(sp)
    800032ca:	ec26                	sd	s1,24(sp)
    800032cc:	e84a                	sd	s2,16(sp)
    800032ce:	e44e                	sd	s3,8(sp)
    800032d0:	e052                	sd	s4,0(sp)
    800032d2:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800032d4:	00005597          	auipc	a1,0x5
    800032d8:	31c58593          	addi	a1,a1,796 # 800085f0 <syscalls+0xd0>
    800032dc:	00014517          	auipc	a0,0x14
    800032e0:	9fc50513          	addi	a0,a0,-1540 # 80016cd8 <bcache>
    800032e4:	ffffe097          	auipc	ra,0xffffe
    800032e8:	862080e7          	jalr	-1950(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800032ec:	0001c797          	auipc	a5,0x1c
    800032f0:	9ec78793          	addi	a5,a5,-1556 # 8001ecd8 <bcache+0x8000>
    800032f4:	0001c717          	auipc	a4,0x1c
    800032f8:	c4c70713          	addi	a4,a4,-948 # 8001ef40 <bcache+0x8268>
    800032fc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80003300:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003304:	00014497          	auipc	s1,0x14
    80003308:	9ec48493          	addi	s1,s1,-1556 # 80016cf0 <bcache+0x18>
    b->next = bcache.head.next;
    8000330c:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000330e:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80003310:	00005a17          	auipc	s4,0x5
    80003314:	2e8a0a13          	addi	s4,s4,744 # 800085f8 <syscalls+0xd8>
    b->next = bcache.head.next;
    80003318:	2b893783          	ld	a5,696(s2)
    8000331c:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000331e:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80003322:	85d2                	mv	a1,s4
    80003324:	01048513          	addi	a0,s1,16
    80003328:	00001097          	auipc	ra,0x1
    8000332c:	4c8080e7          	jalr	1224(ra) # 800047f0 <initsleeplock>
    bcache.head.next->prev = b;
    80003330:	2b893783          	ld	a5,696(s2)
    80003334:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003336:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000333a:	45848493          	addi	s1,s1,1112
    8000333e:	fd349de3          	bne	s1,s3,80003318 <binit+0x54>
  }
}
    80003342:	70a2                	ld	ra,40(sp)
    80003344:	7402                	ld	s0,32(sp)
    80003346:	64e2                	ld	s1,24(sp)
    80003348:	6942                	ld	s2,16(sp)
    8000334a:	69a2                	ld	s3,8(sp)
    8000334c:	6a02                	ld	s4,0(sp)
    8000334e:	6145                	addi	sp,sp,48
    80003350:	8082                	ret

0000000080003352 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003352:	7179                	addi	sp,sp,-48
    80003354:	f406                	sd	ra,40(sp)
    80003356:	f022                	sd	s0,32(sp)
    80003358:	ec26                	sd	s1,24(sp)
    8000335a:	e84a                	sd	s2,16(sp)
    8000335c:	e44e                	sd	s3,8(sp)
    8000335e:	1800                	addi	s0,sp,48
    80003360:	892a                	mv	s2,a0
    80003362:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003364:	00014517          	auipc	a0,0x14
    80003368:	97450513          	addi	a0,a0,-1676 # 80016cd8 <bcache>
    8000336c:	ffffe097          	auipc	ra,0xffffe
    80003370:	86a080e7          	jalr	-1942(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003374:	0001c497          	auipc	s1,0x1c
    80003378:	c1c4b483          	ld	s1,-996(s1) # 8001ef90 <bcache+0x82b8>
    8000337c:	0001c797          	auipc	a5,0x1c
    80003380:	bc478793          	addi	a5,a5,-1084 # 8001ef40 <bcache+0x8268>
    80003384:	02f48f63          	beq	s1,a5,800033c2 <bread+0x70>
    80003388:	873e                	mv	a4,a5
    8000338a:	a021                	j	80003392 <bread+0x40>
    8000338c:	68a4                	ld	s1,80(s1)
    8000338e:	02e48a63          	beq	s1,a4,800033c2 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003392:	449c                	lw	a5,8(s1)
    80003394:	ff279ce3          	bne	a5,s2,8000338c <bread+0x3a>
    80003398:	44dc                	lw	a5,12(s1)
    8000339a:	ff3799e3          	bne	a5,s3,8000338c <bread+0x3a>
      b->refcnt++;
    8000339e:	40bc                	lw	a5,64(s1)
    800033a0:	2785                	addiw	a5,a5,1
    800033a2:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033a4:	00014517          	auipc	a0,0x14
    800033a8:	93450513          	addi	a0,a0,-1740 # 80016cd8 <bcache>
    800033ac:	ffffe097          	auipc	ra,0xffffe
    800033b0:	8de080e7          	jalr	-1826(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800033b4:	01048513          	addi	a0,s1,16
    800033b8:	00001097          	auipc	ra,0x1
    800033bc:	472080e7          	jalr	1138(ra) # 8000482a <acquiresleep>
      return b;
    800033c0:	a8b9                	j	8000341e <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033c2:	0001c497          	auipc	s1,0x1c
    800033c6:	bc64b483          	ld	s1,-1082(s1) # 8001ef88 <bcache+0x82b0>
    800033ca:	0001c797          	auipc	a5,0x1c
    800033ce:	b7678793          	addi	a5,a5,-1162 # 8001ef40 <bcache+0x8268>
    800033d2:	00f48863          	beq	s1,a5,800033e2 <bread+0x90>
    800033d6:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800033d8:	40bc                	lw	a5,64(s1)
    800033da:	cf81                	beqz	a5,800033f2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033dc:	64a4                	ld	s1,72(s1)
    800033de:	fee49de3          	bne	s1,a4,800033d8 <bread+0x86>
  panic("bget: no buffers");
    800033e2:	00005517          	auipc	a0,0x5
    800033e6:	21e50513          	addi	a0,a0,542 # 80008600 <syscalls+0xe0>
    800033ea:	ffffd097          	auipc	ra,0xffffd
    800033ee:	156080e7          	jalr	342(ra) # 80000540 <panic>
      b->dev = dev;
    800033f2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800033f6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800033fa:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800033fe:	4785                	li	a5,1
    80003400:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003402:	00014517          	auipc	a0,0x14
    80003406:	8d650513          	addi	a0,a0,-1834 # 80016cd8 <bcache>
    8000340a:	ffffe097          	auipc	ra,0xffffe
    8000340e:	880080e7          	jalr	-1920(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003412:	01048513          	addi	a0,s1,16
    80003416:	00001097          	auipc	ra,0x1
    8000341a:	414080e7          	jalr	1044(ra) # 8000482a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000341e:	409c                	lw	a5,0(s1)
    80003420:	cb89                	beqz	a5,80003432 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003422:	8526                	mv	a0,s1
    80003424:	70a2                	ld	ra,40(sp)
    80003426:	7402                	ld	s0,32(sp)
    80003428:	64e2                	ld	s1,24(sp)
    8000342a:	6942                	ld	s2,16(sp)
    8000342c:	69a2                	ld	s3,8(sp)
    8000342e:	6145                	addi	sp,sp,48
    80003430:	8082                	ret
    virtio_disk_rw(b, 0);
    80003432:	4581                	li	a1,0
    80003434:	8526                	mv	a0,s1
    80003436:	00003097          	auipc	ra,0x3
    8000343a:	fdc080e7          	jalr	-36(ra) # 80006412 <virtio_disk_rw>
    b->valid = 1;
    8000343e:	4785                	li	a5,1
    80003440:	c09c                	sw	a5,0(s1)
  return b;
    80003442:	b7c5                	j	80003422 <bread+0xd0>

0000000080003444 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003444:	1101                	addi	sp,sp,-32
    80003446:	ec06                	sd	ra,24(sp)
    80003448:	e822                	sd	s0,16(sp)
    8000344a:	e426                	sd	s1,8(sp)
    8000344c:	1000                	addi	s0,sp,32
    8000344e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003450:	0541                	addi	a0,a0,16
    80003452:	00001097          	auipc	ra,0x1
    80003456:	472080e7          	jalr	1138(ra) # 800048c4 <holdingsleep>
    8000345a:	cd01                	beqz	a0,80003472 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    8000345c:	4585                	li	a1,1
    8000345e:	8526                	mv	a0,s1
    80003460:	00003097          	auipc	ra,0x3
    80003464:	fb2080e7          	jalr	-78(ra) # 80006412 <virtio_disk_rw>
}
    80003468:	60e2                	ld	ra,24(sp)
    8000346a:	6442                	ld	s0,16(sp)
    8000346c:	64a2                	ld	s1,8(sp)
    8000346e:	6105                	addi	sp,sp,32
    80003470:	8082                	ret
    panic("bwrite");
    80003472:	00005517          	auipc	a0,0x5
    80003476:	1a650513          	addi	a0,a0,422 # 80008618 <syscalls+0xf8>
    8000347a:	ffffd097          	auipc	ra,0xffffd
    8000347e:	0c6080e7          	jalr	198(ra) # 80000540 <panic>

0000000080003482 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003482:	1101                	addi	sp,sp,-32
    80003484:	ec06                	sd	ra,24(sp)
    80003486:	e822                	sd	s0,16(sp)
    80003488:	e426                	sd	s1,8(sp)
    8000348a:	e04a                	sd	s2,0(sp)
    8000348c:	1000                	addi	s0,sp,32
    8000348e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003490:	01050913          	addi	s2,a0,16
    80003494:	854a                	mv	a0,s2
    80003496:	00001097          	auipc	ra,0x1
    8000349a:	42e080e7          	jalr	1070(ra) # 800048c4 <holdingsleep>
    8000349e:	c92d                	beqz	a0,80003510 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800034a0:	854a                	mv	a0,s2
    800034a2:	00001097          	auipc	ra,0x1
    800034a6:	3de080e7          	jalr	990(ra) # 80004880 <releasesleep>

  acquire(&bcache.lock);
    800034aa:	00014517          	auipc	a0,0x14
    800034ae:	82e50513          	addi	a0,a0,-2002 # 80016cd8 <bcache>
    800034b2:	ffffd097          	auipc	ra,0xffffd
    800034b6:	724080e7          	jalr	1828(ra) # 80000bd6 <acquire>
  b->refcnt--;
    800034ba:	40bc                	lw	a5,64(s1)
    800034bc:	37fd                	addiw	a5,a5,-1
    800034be:	0007871b          	sext.w	a4,a5
    800034c2:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034c4:	eb05                	bnez	a4,800034f4 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034c6:	68bc                	ld	a5,80(s1)
    800034c8:	64b8                	ld	a4,72(s1)
    800034ca:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    800034cc:	64bc                	ld	a5,72(s1)
    800034ce:	68b8                	ld	a4,80(s1)
    800034d0:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034d2:	0001c797          	auipc	a5,0x1c
    800034d6:	80678793          	addi	a5,a5,-2042 # 8001ecd8 <bcache+0x8000>
    800034da:	2b87b703          	ld	a4,696(a5)
    800034de:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800034e0:	0001c717          	auipc	a4,0x1c
    800034e4:	a6070713          	addi	a4,a4,-1440 # 8001ef40 <bcache+0x8268>
    800034e8:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800034ea:	2b87b703          	ld	a4,696(a5)
    800034ee:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800034f0:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800034f4:	00013517          	auipc	a0,0x13
    800034f8:	7e450513          	addi	a0,a0,2020 # 80016cd8 <bcache>
    800034fc:	ffffd097          	auipc	ra,0xffffd
    80003500:	78e080e7          	jalr	1934(ra) # 80000c8a <release>
}
    80003504:	60e2                	ld	ra,24(sp)
    80003506:	6442                	ld	s0,16(sp)
    80003508:	64a2                	ld	s1,8(sp)
    8000350a:	6902                	ld	s2,0(sp)
    8000350c:	6105                	addi	sp,sp,32
    8000350e:	8082                	ret
    panic("brelse");
    80003510:	00005517          	auipc	a0,0x5
    80003514:	11050513          	addi	a0,a0,272 # 80008620 <syscalls+0x100>
    80003518:	ffffd097          	auipc	ra,0xffffd
    8000351c:	028080e7          	jalr	40(ra) # 80000540 <panic>

0000000080003520 <bpin>:

void
bpin(struct buf *b) {
    80003520:	1101                	addi	sp,sp,-32
    80003522:	ec06                	sd	ra,24(sp)
    80003524:	e822                	sd	s0,16(sp)
    80003526:	e426                	sd	s1,8(sp)
    80003528:	1000                	addi	s0,sp,32
    8000352a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000352c:	00013517          	auipc	a0,0x13
    80003530:	7ac50513          	addi	a0,a0,1964 # 80016cd8 <bcache>
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	6a2080e7          	jalr	1698(ra) # 80000bd6 <acquire>
  b->refcnt++;
    8000353c:	40bc                	lw	a5,64(s1)
    8000353e:	2785                	addiw	a5,a5,1
    80003540:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003542:	00013517          	auipc	a0,0x13
    80003546:	79650513          	addi	a0,a0,1942 # 80016cd8 <bcache>
    8000354a:	ffffd097          	auipc	ra,0xffffd
    8000354e:	740080e7          	jalr	1856(ra) # 80000c8a <release>
}
    80003552:	60e2                	ld	ra,24(sp)
    80003554:	6442                	ld	s0,16(sp)
    80003556:	64a2                	ld	s1,8(sp)
    80003558:	6105                	addi	sp,sp,32
    8000355a:	8082                	ret

000000008000355c <bunpin>:

void
bunpin(struct buf *b) {
    8000355c:	1101                	addi	sp,sp,-32
    8000355e:	ec06                	sd	ra,24(sp)
    80003560:	e822                	sd	s0,16(sp)
    80003562:	e426                	sd	s1,8(sp)
    80003564:	1000                	addi	s0,sp,32
    80003566:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003568:	00013517          	auipc	a0,0x13
    8000356c:	77050513          	addi	a0,a0,1904 # 80016cd8 <bcache>
    80003570:	ffffd097          	auipc	ra,0xffffd
    80003574:	666080e7          	jalr	1638(ra) # 80000bd6 <acquire>
  b->refcnt--;
    80003578:	40bc                	lw	a5,64(s1)
    8000357a:	37fd                	addiw	a5,a5,-1
    8000357c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000357e:	00013517          	auipc	a0,0x13
    80003582:	75a50513          	addi	a0,a0,1882 # 80016cd8 <bcache>
    80003586:	ffffd097          	auipc	ra,0xffffd
    8000358a:	704080e7          	jalr	1796(ra) # 80000c8a <release>
}
    8000358e:	60e2                	ld	ra,24(sp)
    80003590:	6442                	ld	s0,16(sp)
    80003592:	64a2                	ld	s1,8(sp)
    80003594:	6105                	addi	sp,sp,32
    80003596:	8082                	ret

0000000080003598 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003598:	1101                	addi	sp,sp,-32
    8000359a:	ec06                	sd	ra,24(sp)
    8000359c:	e822                	sd	s0,16(sp)
    8000359e:	e426                	sd	s1,8(sp)
    800035a0:	e04a                	sd	s2,0(sp)
    800035a2:	1000                	addi	s0,sp,32
    800035a4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035a6:	00d5d59b          	srliw	a1,a1,0xd
    800035aa:	0001c797          	auipc	a5,0x1c
    800035ae:	e0a7a783          	lw	a5,-502(a5) # 8001f3b4 <sb+0x1c>
    800035b2:	9dbd                	addw	a1,a1,a5
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	d9e080e7          	jalr	-610(ra) # 80003352 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035bc:	0074f713          	andi	a4,s1,7
    800035c0:	4785                	li	a5,1
    800035c2:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035c6:	14ce                	slli	s1,s1,0x33
    800035c8:	90d9                	srli	s1,s1,0x36
    800035ca:	00950733          	add	a4,a0,s1
    800035ce:	05874703          	lbu	a4,88(a4)
    800035d2:	00e7f6b3          	and	a3,a5,a4
    800035d6:	c69d                	beqz	a3,80003604 <bfree+0x6c>
    800035d8:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800035da:	94aa                	add	s1,s1,a0
    800035dc:	fff7c793          	not	a5,a5
    800035e0:	8f7d                	and	a4,a4,a5
    800035e2:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800035e6:	00001097          	auipc	ra,0x1
    800035ea:	126080e7          	jalr	294(ra) # 8000470c <log_write>
  brelse(bp);
    800035ee:	854a                	mv	a0,s2
    800035f0:	00000097          	auipc	ra,0x0
    800035f4:	e92080e7          	jalr	-366(ra) # 80003482 <brelse>
}
    800035f8:	60e2                	ld	ra,24(sp)
    800035fa:	6442                	ld	s0,16(sp)
    800035fc:	64a2                	ld	s1,8(sp)
    800035fe:	6902                	ld	s2,0(sp)
    80003600:	6105                	addi	sp,sp,32
    80003602:	8082                	ret
    panic("freeing free block");
    80003604:	00005517          	auipc	a0,0x5
    80003608:	02450513          	addi	a0,a0,36 # 80008628 <syscalls+0x108>
    8000360c:	ffffd097          	auipc	ra,0xffffd
    80003610:	f34080e7          	jalr	-204(ra) # 80000540 <panic>

0000000080003614 <balloc>:
{
    80003614:	711d                	addi	sp,sp,-96
    80003616:	ec86                	sd	ra,88(sp)
    80003618:	e8a2                	sd	s0,80(sp)
    8000361a:	e4a6                	sd	s1,72(sp)
    8000361c:	e0ca                	sd	s2,64(sp)
    8000361e:	fc4e                	sd	s3,56(sp)
    80003620:	f852                	sd	s4,48(sp)
    80003622:	f456                	sd	s5,40(sp)
    80003624:	f05a                	sd	s6,32(sp)
    80003626:	ec5e                	sd	s7,24(sp)
    80003628:	e862                	sd	s8,16(sp)
    8000362a:	e466                	sd	s9,8(sp)
    8000362c:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000362e:	0001c797          	auipc	a5,0x1c
    80003632:	d6e7a783          	lw	a5,-658(a5) # 8001f39c <sb+0x4>
    80003636:	cff5                	beqz	a5,80003732 <balloc+0x11e>
    80003638:	8baa                	mv	s7,a0
    8000363a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000363c:	0001cb17          	auipc	s6,0x1c
    80003640:	d5cb0b13          	addi	s6,s6,-676 # 8001f398 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003644:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003646:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003648:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000364a:	6c89                	lui	s9,0x2
    8000364c:	a061                	j	800036d4 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000364e:	97ca                	add	a5,a5,s2
    80003650:	8e55                	or	a2,a2,a3
    80003652:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003656:	854a                	mv	a0,s2
    80003658:	00001097          	auipc	ra,0x1
    8000365c:	0b4080e7          	jalr	180(ra) # 8000470c <log_write>
        brelse(bp);
    80003660:	854a                	mv	a0,s2
    80003662:	00000097          	auipc	ra,0x0
    80003666:	e20080e7          	jalr	-480(ra) # 80003482 <brelse>
  bp = bread(dev, bno);
    8000366a:	85a6                	mv	a1,s1
    8000366c:	855e                	mv	a0,s7
    8000366e:	00000097          	auipc	ra,0x0
    80003672:	ce4080e7          	jalr	-796(ra) # 80003352 <bread>
    80003676:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003678:	40000613          	li	a2,1024
    8000367c:	4581                	li	a1,0
    8000367e:	05850513          	addi	a0,a0,88
    80003682:	ffffd097          	auipc	ra,0xffffd
    80003686:	650080e7          	jalr	1616(ra) # 80000cd2 <memset>
  log_write(bp);
    8000368a:	854a                	mv	a0,s2
    8000368c:	00001097          	auipc	ra,0x1
    80003690:	080080e7          	jalr	128(ra) # 8000470c <log_write>
  brelse(bp);
    80003694:	854a                	mv	a0,s2
    80003696:	00000097          	auipc	ra,0x0
    8000369a:	dec080e7          	jalr	-532(ra) # 80003482 <brelse>
}
    8000369e:	8526                	mv	a0,s1
    800036a0:	60e6                	ld	ra,88(sp)
    800036a2:	6446                	ld	s0,80(sp)
    800036a4:	64a6                	ld	s1,72(sp)
    800036a6:	6906                	ld	s2,64(sp)
    800036a8:	79e2                	ld	s3,56(sp)
    800036aa:	7a42                	ld	s4,48(sp)
    800036ac:	7aa2                	ld	s5,40(sp)
    800036ae:	7b02                	ld	s6,32(sp)
    800036b0:	6be2                	ld	s7,24(sp)
    800036b2:	6c42                	ld	s8,16(sp)
    800036b4:	6ca2                	ld	s9,8(sp)
    800036b6:	6125                	addi	sp,sp,96
    800036b8:	8082                	ret
    brelse(bp);
    800036ba:	854a                	mv	a0,s2
    800036bc:	00000097          	auipc	ra,0x0
    800036c0:	dc6080e7          	jalr	-570(ra) # 80003482 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036c4:	015c87bb          	addw	a5,s9,s5
    800036c8:	00078a9b          	sext.w	s5,a5
    800036cc:	004b2703          	lw	a4,4(s6)
    800036d0:	06eaf163          	bgeu	s5,a4,80003732 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800036d4:	41fad79b          	sraiw	a5,s5,0x1f
    800036d8:	0137d79b          	srliw	a5,a5,0x13
    800036dc:	015787bb          	addw	a5,a5,s5
    800036e0:	40d7d79b          	sraiw	a5,a5,0xd
    800036e4:	01cb2583          	lw	a1,28(s6)
    800036e8:	9dbd                	addw	a1,a1,a5
    800036ea:	855e                	mv	a0,s7
    800036ec:	00000097          	auipc	ra,0x0
    800036f0:	c66080e7          	jalr	-922(ra) # 80003352 <bread>
    800036f4:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800036f6:	004b2503          	lw	a0,4(s6)
    800036fa:	000a849b          	sext.w	s1,s5
    800036fe:	8762                	mv	a4,s8
    80003700:	faa4fde3          	bgeu	s1,a0,800036ba <balloc+0xa6>
      m = 1 << (bi % 8);
    80003704:	00777693          	andi	a3,a4,7
    80003708:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000370c:	41f7579b          	sraiw	a5,a4,0x1f
    80003710:	01d7d79b          	srliw	a5,a5,0x1d
    80003714:	9fb9                	addw	a5,a5,a4
    80003716:	4037d79b          	sraiw	a5,a5,0x3
    8000371a:	00f90633          	add	a2,s2,a5
    8000371e:	05864603          	lbu	a2,88(a2)
    80003722:	00c6f5b3          	and	a1,a3,a2
    80003726:	d585                	beqz	a1,8000364e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003728:	2705                	addiw	a4,a4,1
    8000372a:	2485                	addiw	s1,s1,1
    8000372c:	fd471ae3          	bne	a4,s4,80003700 <balloc+0xec>
    80003730:	b769                	j	800036ba <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003732:	00005517          	auipc	a0,0x5
    80003736:	f0e50513          	addi	a0,a0,-242 # 80008640 <syscalls+0x120>
    8000373a:	ffffd097          	auipc	ra,0xffffd
    8000373e:	e50080e7          	jalr	-432(ra) # 8000058a <printf>
  return 0;
    80003742:	4481                	li	s1,0
    80003744:	bfa9                	j	8000369e <balloc+0x8a>

0000000080003746 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003746:	7179                	addi	sp,sp,-48
    80003748:	f406                	sd	ra,40(sp)
    8000374a:	f022                	sd	s0,32(sp)
    8000374c:	ec26                	sd	s1,24(sp)
    8000374e:	e84a                	sd	s2,16(sp)
    80003750:	e44e                	sd	s3,8(sp)
    80003752:	e052                	sd	s4,0(sp)
    80003754:	1800                	addi	s0,sp,48
    80003756:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003758:	47ad                	li	a5,11
    8000375a:	02b7e863          	bltu	a5,a1,8000378a <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000375e:	02059793          	slli	a5,a1,0x20
    80003762:	01e7d593          	srli	a1,a5,0x1e
    80003766:	00b504b3          	add	s1,a0,a1
    8000376a:	0504a903          	lw	s2,80(s1)
    8000376e:	06091e63          	bnez	s2,800037ea <bmap+0xa4>
      addr = balloc(ip->dev);
    80003772:	4108                	lw	a0,0(a0)
    80003774:	00000097          	auipc	ra,0x0
    80003778:	ea0080e7          	jalr	-352(ra) # 80003614 <balloc>
    8000377c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003780:	06090563          	beqz	s2,800037ea <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003784:	0524a823          	sw	s2,80(s1)
    80003788:	a08d                	j	800037ea <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000378a:	ff45849b          	addiw	s1,a1,-12
    8000378e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003792:	0ff00793          	li	a5,255
    80003796:	08e7e563          	bltu	a5,a4,80003820 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000379a:	08052903          	lw	s2,128(a0)
    8000379e:	00091d63          	bnez	s2,800037b8 <bmap+0x72>
      addr = balloc(ip->dev);
    800037a2:	4108                	lw	a0,0(a0)
    800037a4:	00000097          	auipc	ra,0x0
    800037a8:	e70080e7          	jalr	-400(ra) # 80003614 <balloc>
    800037ac:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037b0:	02090d63          	beqz	s2,800037ea <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037b4:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037b8:	85ca                	mv	a1,s2
    800037ba:	0009a503          	lw	a0,0(s3)
    800037be:	00000097          	auipc	ra,0x0
    800037c2:	b94080e7          	jalr	-1132(ra) # 80003352 <bread>
    800037c6:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037c8:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800037cc:	02049713          	slli	a4,s1,0x20
    800037d0:	01e75593          	srli	a1,a4,0x1e
    800037d4:	00b784b3          	add	s1,a5,a1
    800037d8:	0004a903          	lw	s2,0(s1)
    800037dc:	02090063          	beqz	s2,800037fc <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800037e0:	8552                	mv	a0,s4
    800037e2:	00000097          	auipc	ra,0x0
    800037e6:	ca0080e7          	jalr	-864(ra) # 80003482 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800037ea:	854a                	mv	a0,s2
    800037ec:	70a2                	ld	ra,40(sp)
    800037ee:	7402                	ld	s0,32(sp)
    800037f0:	64e2                	ld	s1,24(sp)
    800037f2:	6942                	ld	s2,16(sp)
    800037f4:	69a2                	ld	s3,8(sp)
    800037f6:	6a02                	ld	s4,0(sp)
    800037f8:	6145                	addi	sp,sp,48
    800037fa:	8082                	ret
      addr = balloc(ip->dev);
    800037fc:	0009a503          	lw	a0,0(s3)
    80003800:	00000097          	auipc	ra,0x0
    80003804:	e14080e7          	jalr	-492(ra) # 80003614 <balloc>
    80003808:	0005091b          	sext.w	s2,a0
      if(addr){
    8000380c:	fc090ae3          	beqz	s2,800037e0 <bmap+0x9a>
        a[bn] = addr;
    80003810:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003814:	8552                	mv	a0,s4
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	ef6080e7          	jalr	-266(ra) # 8000470c <log_write>
    8000381e:	b7c9                	j	800037e0 <bmap+0x9a>
  panic("bmap: out of range");
    80003820:	00005517          	auipc	a0,0x5
    80003824:	e3850513          	addi	a0,a0,-456 # 80008658 <syscalls+0x138>
    80003828:	ffffd097          	auipc	ra,0xffffd
    8000382c:	d18080e7          	jalr	-744(ra) # 80000540 <panic>

0000000080003830 <iget>:
{
    80003830:	7179                	addi	sp,sp,-48
    80003832:	f406                	sd	ra,40(sp)
    80003834:	f022                	sd	s0,32(sp)
    80003836:	ec26                	sd	s1,24(sp)
    80003838:	e84a                	sd	s2,16(sp)
    8000383a:	e44e                	sd	s3,8(sp)
    8000383c:	e052                	sd	s4,0(sp)
    8000383e:	1800                	addi	s0,sp,48
    80003840:	89aa                	mv	s3,a0
    80003842:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003844:	0001c517          	auipc	a0,0x1c
    80003848:	b7450513          	addi	a0,a0,-1164 # 8001f3b8 <itable>
    8000384c:	ffffd097          	auipc	ra,0xffffd
    80003850:	38a080e7          	jalr	906(ra) # 80000bd6 <acquire>
  empty = 0;
    80003854:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003856:	0001c497          	auipc	s1,0x1c
    8000385a:	b7a48493          	addi	s1,s1,-1158 # 8001f3d0 <itable+0x18>
    8000385e:	0001d697          	auipc	a3,0x1d
    80003862:	60268693          	addi	a3,a3,1538 # 80020e60 <log>
    80003866:	a039                	j	80003874 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003868:	02090b63          	beqz	s2,8000389e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000386c:	08848493          	addi	s1,s1,136
    80003870:	02d48a63          	beq	s1,a3,800038a4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003874:	449c                	lw	a5,8(s1)
    80003876:	fef059e3          	blez	a5,80003868 <iget+0x38>
    8000387a:	4098                	lw	a4,0(s1)
    8000387c:	ff3716e3          	bne	a4,s3,80003868 <iget+0x38>
    80003880:	40d8                	lw	a4,4(s1)
    80003882:	ff4713e3          	bne	a4,s4,80003868 <iget+0x38>
      ip->ref++;
    80003886:	2785                	addiw	a5,a5,1
    80003888:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000388a:	0001c517          	auipc	a0,0x1c
    8000388e:	b2e50513          	addi	a0,a0,-1234 # 8001f3b8 <itable>
    80003892:	ffffd097          	auipc	ra,0xffffd
    80003896:	3f8080e7          	jalr	1016(ra) # 80000c8a <release>
      return ip;
    8000389a:	8926                	mv	s2,s1
    8000389c:	a03d                	j	800038ca <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000389e:	f7f9                	bnez	a5,8000386c <iget+0x3c>
    800038a0:	8926                	mv	s2,s1
    800038a2:	b7e9                	j	8000386c <iget+0x3c>
  if(empty == 0)
    800038a4:	02090c63          	beqz	s2,800038dc <iget+0xac>
  ip->dev = dev;
    800038a8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038ac:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038b0:	4785                	li	a5,1
    800038b2:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038b6:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038ba:	0001c517          	auipc	a0,0x1c
    800038be:	afe50513          	addi	a0,a0,-1282 # 8001f3b8 <itable>
    800038c2:	ffffd097          	auipc	ra,0xffffd
    800038c6:	3c8080e7          	jalr	968(ra) # 80000c8a <release>
}
    800038ca:	854a                	mv	a0,s2
    800038cc:	70a2                	ld	ra,40(sp)
    800038ce:	7402                	ld	s0,32(sp)
    800038d0:	64e2                	ld	s1,24(sp)
    800038d2:	6942                	ld	s2,16(sp)
    800038d4:	69a2                	ld	s3,8(sp)
    800038d6:	6a02                	ld	s4,0(sp)
    800038d8:	6145                	addi	sp,sp,48
    800038da:	8082                	ret
    panic("iget: no inodes");
    800038dc:	00005517          	auipc	a0,0x5
    800038e0:	d9450513          	addi	a0,a0,-620 # 80008670 <syscalls+0x150>
    800038e4:	ffffd097          	auipc	ra,0xffffd
    800038e8:	c5c080e7          	jalr	-932(ra) # 80000540 <panic>

00000000800038ec <fsinit>:
fsinit(int dev) {
    800038ec:	7179                	addi	sp,sp,-48
    800038ee:	f406                	sd	ra,40(sp)
    800038f0:	f022                	sd	s0,32(sp)
    800038f2:	ec26                	sd	s1,24(sp)
    800038f4:	e84a                	sd	s2,16(sp)
    800038f6:	e44e                	sd	s3,8(sp)
    800038f8:	1800                	addi	s0,sp,48
    800038fa:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800038fc:	4585                	li	a1,1
    800038fe:	00000097          	auipc	ra,0x0
    80003902:	a54080e7          	jalr	-1452(ra) # 80003352 <bread>
    80003906:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003908:	0001c997          	auipc	s3,0x1c
    8000390c:	a9098993          	addi	s3,s3,-1392 # 8001f398 <sb>
    80003910:	02000613          	li	a2,32
    80003914:	05850593          	addi	a1,a0,88
    80003918:	854e                	mv	a0,s3
    8000391a:	ffffd097          	auipc	ra,0xffffd
    8000391e:	414080e7          	jalr	1044(ra) # 80000d2e <memmove>
  brelse(bp);
    80003922:	8526                	mv	a0,s1
    80003924:	00000097          	auipc	ra,0x0
    80003928:	b5e080e7          	jalr	-1186(ra) # 80003482 <brelse>
  if(sb.magic != FSMAGIC)
    8000392c:	0009a703          	lw	a4,0(s3)
    80003930:	102037b7          	lui	a5,0x10203
    80003934:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003938:	02f71263          	bne	a4,a5,8000395c <fsinit+0x70>
  initlog(dev, &sb);
    8000393c:	0001c597          	auipc	a1,0x1c
    80003940:	a5c58593          	addi	a1,a1,-1444 # 8001f398 <sb>
    80003944:	854a                	mv	a0,s2
    80003946:	00001097          	auipc	ra,0x1
    8000394a:	b4a080e7          	jalr	-1206(ra) # 80004490 <initlog>
}
    8000394e:	70a2                	ld	ra,40(sp)
    80003950:	7402                	ld	s0,32(sp)
    80003952:	64e2                	ld	s1,24(sp)
    80003954:	6942                	ld	s2,16(sp)
    80003956:	69a2                	ld	s3,8(sp)
    80003958:	6145                	addi	sp,sp,48
    8000395a:	8082                	ret
    panic("invalid file system");
    8000395c:	00005517          	auipc	a0,0x5
    80003960:	d2450513          	addi	a0,a0,-732 # 80008680 <syscalls+0x160>
    80003964:	ffffd097          	auipc	ra,0xffffd
    80003968:	bdc080e7          	jalr	-1060(ra) # 80000540 <panic>

000000008000396c <iinit>:
{
    8000396c:	7179                	addi	sp,sp,-48
    8000396e:	f406                	sd	ra,40(sp)
    80003970:	f022                	sd	s0,32(sp)
    80003972:	ec26                	sd	s1,24(sp)
    80003974:	e84a                	sd	s2,16(sp)
    80003976:	e44e                	sd	s3,8(sp)
    80003978:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000397a:	00005597          	auipc	a1,0x5
    8000397e:	d1e58593          	addi	a1,a1,-738 # 80008698 <syscalls+0x178>
    80003982:	0001c517          	auipc	a0,0x1c
    80003986:	a3650513          	addi	a0,a0,-1482 # 8001f3b8 <itable>
    8000398a:	ffffd097          	auipc	ra,0xffffd
    8000398e:	1bc080e7          	jalr	444(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003992:	0001c497          	auipc	s1,0x1c
    80003996:	a4e48493          	addi	s1,s1,-1458 # 8001f3e0 <itable+0x28>
    8000399a:	0001d997          	auipc	s3,0x1d
    8000399e:	4d698993          	addi	s3,s3,1238 # 80020e70 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039a2:	00005917          	auipc	s2,0x5
    800039a6:	cfe90913          	addi	s2,s2,-770 # 800086a0 <syscalls+0x180>
    800039aa:	85ca                	mv	a1,s2
    800039ac:	8526                	mv	a0,s1
    800039ae:	00001097          	auipc	ra,0x1
    800039b2:	e42080e7          	jalr	-446(ra) # 800047f0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039b6:	08848493          	addi	s1,s1,136
    800039ba:	ff3498e3          	bne	s1,s3,800039aa <iinit+0x3e>
}
    800039be:	70a2                	ld	ra,40(sp)
    800039c0:	7402                	ld	s0,32(sp)
    800039c2:	64e2                	ld	s1,24(sp)
    800039c4:	6942                	ld	s2,16(sp)
    800039c6:	69a2                	ld	s3,8(sp)
    800039c8:	6145                	addi	sp,sp,48
    800039ca:	8082                	ret

00000000800039cc <ialloc>:
{
    800039cc:	715d                	addi	sp,sp,-80
    800039ce:	e486                	sd	ra,72(sp)
    800039d0:	e0a2                	sd	s0,64(sp)
    800039d2:	fc26                	sd	s1,56(sp)
    800039d4:	f84a                	sd	s2,48(sp)
    800039d6:	f44e                	sd	s3,40(sp)
    800039d8:	f052                	sd	s4,32(sp)
    800039da:	ec56                	sd	s5,24(sp)
    800039dc:	e85a                	sd	s6,16(sp)
    800039de:	e45e                	sd	s7,8(sp)
    800039e0:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    800039e2:	0001c717          	auipc	a4,0x1c
    800039e6:	9c272703          	lw	a4,-1598(a4) # 8001f3a4 <sb+0xc>
    800039ea:	4785                	li	a5,1
    800039ec:	04e7fa63          	bgeu	a5,a4,80003a40 <ialloc+0x74>
    800039f0:	8aaa                	mv	s5,a0
    800039f2:	8bae                	mv	s7,a1
    800039f4:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800039f6:	0001ca17          	auipc	s4,0x1c
    800039fa:	9a2a0a13          	addi	s4,s4,-1630 # 8001f398 <sb>
    800039fe:	00048b1b          	sext.w	s6,s1
    80003a02:	0044d593          	srli	a1,s1,0x4
    80003a06:	018a2783          	lw	a5,24(s4)
    80003a0a:	9dbd                	addw	a1,a1,a5
    80003a0c:	8556                	mv	a0,s5
    80003a0e:	00000097          	auipc	ra,0x0
    80003a12:	944080e7          	jalr	-1724(ra) # 80003352 <bread>
    80003a16:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a18:	05850993          	addi	s3,a0,88
    80003a1c:	00f4f793          	andi	a5,s1,15
    80003a20:	079a                	slli	a5,a5,0x6
    80003a22:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a24:	00099783          	lh	a5,0(s3)
    80003a28:	c3a1                	beqz	a5,80003a68 <ialloc+0x9c>
    brelse(bp);
    80003a2a:	00000097          	auipc	ra,0x0
    80003a2e:	a58080e7          	jalr	-1448(ra) # 80003482 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a32:	0485                	addi	s1,s1,1
    80003a34:	00ca2703          	lw	a4,12(s4)
    80003a38:	0004879b          	sext.w	a5,s1
    80003a3c:	fce7e1e3          	bltu	a5,a4,800039fe <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003a40:	00005517          	auipc	a0,0x5
    80003a44:	c6850513          	addi	a0,a0,-920 # 800086a8 <syscalls+0x188>
    80003a48:	ffffd097          	auipc	ra,0xffffd
    80003a4c:	b42080e7          	jalr	-1214(ra) # 8000058a <printf>
  return 0;
    80003a50:	4501                	li	a0,0
}
    80003a52:	60a6                	ld	ra,72(sp)
    80003a54:	6406                	ld	s0,64(sp)
    80003a56:	74e2                	ld	s1,56(sp)
    80003a58:	7942                	ld	s2,48(sp)
    80003a5a:	79a2                	ld	s3,40(sp)
    80003a5c:	7a02                	ld	s4,32(sp)
    80003a5e:	6ae2                	ld	s5,24(sp)
    80003a60:	6b42                	ld	s6,16(sp)
    80003a62:	6ba2                	ld	s7,8(sp)
    80003a64:	6161                	addi	sp,sp,80
    80003a66:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a68:	04000613          	li	a2,64
    80003a6c:	4581                	li	a1,0
    80003a6e:	854e                	mv	a0,s3
    80003a70:	ffffd097          	auipc	ra,0xffffd
    80003a74:	262080e7          	jalr	610(ra) # 80000cd2 <memset>
      dip->type = type;
    80003a78:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a7c:	854a                	mv	a0,s2
    80003a7e:	00001097          	auipc	ra,0x1
    80003a82:	c8e080e7          	jalr	-882(ra) # 8000470c <log_write>
      brelse(bp);
    80003a86:	854a                	mv	a0,s2
    80003a88:	00000097          	auipc	ra,0x0
    80003a8c:	9fa080e7          	jalr	-1542(ra) # 80003482 <brelse>
      return iget(dev, inum);
    80003a90:	85da                	mv	a1,s6
    80003a92:	8556                	mv	a0,s5
    80003a94:	00000097          	auipc	ra,0x0
    80003a98:	d9c080e7          	jalr	-612(ra) # 80003830 <iget>
    80003a9c:	bf5d                	j	80003a52 <ialloc+0x86>

0000000080003a9e <iupdate>:
{
    80003a9e:	1101                	addi	sp,sp,-32
    80003aa0:	ec06                	sd	ra,24(sp)
    80003aa2:	e822                	sd	s0,16(sp)
    80003aa4:	e426                	sd	s1,8(sp)
    80003aa6:	e04a                	sd	s2,0(sp)
    80003aa8:	1000                	addi	s0,sp,32
    80003aaa:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003aac:	415c                	lw	a5,4(a0)
    80003aae:	0047d79b          	srliw	a5,a5,0x4
    80003ab2:	0001c597          	auipc	a1,0x1c
    80003ab6:	8fe5a583          	lw	a1,-1794(a1) # 8001f3b0 <sb+0x18>
    80003aba:	9dbd                	addw	a1,a1,a5
    80003abc:	4108                	lw	a0,0(a0)
    80003abe:	00000097          	auipc	ra,0x0
    80003ac2:	894080e7          	jalr	-1900(ra) # 80003352 <bread>
    80003ac6:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003ac8:	05850793          	addi	a5,a0,88
    80003acc:	40d8                	lw	a4,4(s1)
    80003ace:	8b3d                	andi	a4,a4,15
    80003ad0:	071a                	slli	a4,a4,0x6
    80003ad2:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003ad4:	04449703          	lh	a4,68(s1)
    80003ad8:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003adc:	04649703          	lh	a4,70(s1)
    80003ae0:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003ae4:	04849703          	lh	a4,72(s1)
    80003ae8:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003aec:	04a49703          	lh	a4,74(s1)
    80003af0:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003af4:	44f8                	lw	a4,76(s1)
    80003af6:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003af8:	03400613          	li	a2,52
    80003afc:	05048593          	addi	a1,s1,80
    80003b00:	00c78513          	addi	a0,a5,12
    80003b04:	ffffd097          	auipc	ra,0xffffd
    80003b08:	22a080e7          	jalr	554(ra) # 80000d2e <memmove>
  log_write(bp);
    80003b0c:	854a                	mv	a0,s2
    80003b0e:	00001097          	auipc	ra,0x1
    80003b12:	bfe080e7          	jalr	-1026(ra) # 8000470c <log_write>
  brelse(bp);
    80003b16:	854a                	mv	a0,s2
    80003b18:	00000097          	auipc	ra,0x0
    80003b1c:	96a080e7          	jalr	-1686(ra) # 80003482 <brelse>
}
    80003b20:	60e2                	ld	ra,24(sp)
    80003b22:	6442                	ld	s0,16(sp)
    80003b24:	64a2                	ld	s1,8(sp)
    80003b26:	6902                	ld	s2,0(sp)
    80003b28:	6105                	addi	sp,sp,32
    80003b2a:	8082                	ret

0000000080003b2c <idup>:
{
    80003b2c:	1101                	addi	sp,sp,-32
    80003b2e:	ec06                	sd	ra,24(sp)
    80003b30:	e822                	sd	s0,16(sp)
    80003b32:	e426                	sd	s1,8(sp)
    80003b34:	1000                	addi	s0,sp,32
    80003b36:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b38:	0001c517          	auipc	a0,0x1c
    80003b3c:	88050513          	addi	a0,a0,-1920 # 8001f3b8 <itable>
    80003b40:	ffffd097          	auipc	ra,0xffffd
    80003b44:	096080e7          	jalr	150(ra) # 80000bd6 <acquire>
  ip->ref++;
    80003b48:	449c                	lw	a5,8(s1)
    80003b4a:	2785                	addiw	a5,a5,1
    80003b4c:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b4e:	0001c517          	auipc	a0,0x1c
    80003b52:	86a50513          	addi	a0,a0,-1942 # 8001f3b8 <itable>
    80003b56:	ffffd097          	auipc	ra,0xffffd
    80003b5a:	134080e7          	jalr	308(ra) # 80000c8a <release>
}
    80003b5e:	8526                	mv	a0,s1
    80003b60:	60e2                	ld	ra,24(sp)
    80003b62:	6442                	ld	s0,16(sp)
    80003b64:	64a2                	ld	s1,8(sp)
    80003b66:	6105                	addi	sp,sp,32
    80003b68:	8082                	ret

0000000080003b6a <ilock>:
{
    80003b6a:	1101                	addi	sp,sp,-32
    80003b6c:	ec06                	sd	ra,24(sp)
    80003b6e:	e822                	sd	s0,16(sp)
    80003b70:	e426                	sd	s1,8(sp)
    80003b72:	e04a                	sd	s2,0(sp)
    80003b74:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b76:	c115                	beqz	a0,80003b9a <ilock+0x30>
    80003b78:	84aa                	mv	s1,a0
    80003b7a:	451c                	lw	a5,8(a0)
    80003b7c:	00f05f63          	blez	a5,80003b9a <ilock+0x30>
  acquiresleep(&ip->lock);
    80003b80:	0541                	addi	a0,a0,16
    80003b82:	00001097          	auipc	ra,0x1
    80003b86:	ca8080e7          	jalr	-856(ra) # 8000482a <acquiresleep>
  if(ip->valid == 0){
    80003b8a:	40bc                	lw	a5,64(s1)
    80003b8c:	cf99                	beqz	a5,80003baa <ilock+0x40>
}
    80003b8e:	60e2                	ld	ra,24(sp)
    80003b90:	6442                	ld	s0,16(sp)
    80003b92:	64a2                	ld	s1,8(sp)
    80003b94:	6902                	ld	s2,0(sp)
    80003b96:	6105                	addi	sp,sp,32
    80003b98:	8082                	ret
    panic("ilock");
    80003b9a:	00005517          	auipc	a0,0x5
    80003b9e:	b2650513          	addi	a0,a0,-1242 # 800086c0 <syscalls+0x1a0>
    80003ba2:	ffffd097          	auipc	ra,0xffffd
    80003ba6:	99e080e7          	jalr	-1634(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003baa:	40dc                	lw	a5,4(s1)
    80003bac:	0047d79b          	srliw	a5,a5,0x4
    80003bb0:	0001c597          	auipc	a1,0x1c
    80003bb4:	8005a583          	lw	a1,-2048(a1) # 8001f3b0 <sb+0x18>
    80003bb8:	9dbd                	addw	a1,a1,a5
    80003bba:	4088                	lw	a0,0(s1)
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	796080e7          	jalr	1942(ra) # 80003352 <bread>
    80003bc4:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bc6:	05850593          	addi	a1,a0,88
    80003bca:	40dc                	lw	a5,4(s1)
    80003bcc:	8bbd                	andi	a5,a5,15
    80003bce:	079a                	slli	a5,a5,0x6
    80003bd0:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bd2:	00059783          	lh	a5,0(a1)
    80003bd6:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bda:	00259783          	lh	a5,2(a1)
    80003bde:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003be2:	00459783          	lh	a5,4(a1)
    80003be6:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003bea:	00659783          	lh	a5,6(a1)
    80003bee:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003bf2:	459c                	lw	a5,8(a1)
    80003bf4:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003bf6:	03400613          	li	a2,52
    80003bfa:	05b1                	addi	a1,a1,12
    80003bfc:	05048513          	addi	a0,s1,80
    80003c00:	ffffd097          	auipc	ra,0xffffd
    80003c04:	12e080e7          	jalr	302(ra) # 80000d2e <memmove>
    brelse(bp);
    80003c08:	854a                	mv	a0,s2
    80003c0a:	00000097          	auipc	ra,0x0
    80003c0e:	878080e7          	jalr	-1928(ra) # 80003482 <brelse>
    ip->valid = 1;
    80003c12:	4785                	li	a5,1
    80003c14:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c16:	04449783          	lh	a5,68(s1)
    80003c1a:	fbb5                	bnez	a5,80003b8e <ilock+0x24>
      panic("ilock: no type");
    80003c1c:	00005517          	auipc	a0,0x5
    80003c20:	aac50513          	addi	a0,a0,-1364 # 800086c8 <syscalls+0x1a8>
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	91c080e7          	jalr	-1764(ra) # 80000540 <panic>

0000000080003c2c <iunlock>:
{
    80003c2c:	1101                	addi	sp,sp,-32
    80003c2e:	ec06                	sd	ra,24(sp)
    80003c30:	e822                	sd	s0,16(sp)
    80003c32:	e426                	sd	s1,8(sp)
    80003c34:	e04a                	sd	s2,0(sp)
    80003c36:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c38:	c905                	beqz	a0,80003c68 <iunlock+0x3c>
    80003c3a:	84aa                	mv	s1,a0
    80003c3c:	01050913          	addi	s2,a0,16
    80003c40:	854a                	mv	a0,s2
    80003c42:	00001097          	auipc	ra,0x1
    80003c46:	c82080e7          	jalr	-894(ra) # 800048c4 <holdingsleep>
    80003c4a:	cd19                	beqz	a0,80003c68 <iunlock+0x3c>
    80003c4c:	449c                	lw	a5,8(s1)
    80003c4e:	00f05d63          	blez	a5,80003c68 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c52:	854a                	mv	a0,s2
    80003c54:	00001097          	auipc	ra,0x1
    80003c58:	c2c080e7          	jalr	-980(ra) # 80004880 <releasesleep>
}
    80003c5c:	60e2                	ld	ra,24(sp)
    80003c5e:	6442                	ld	s0,16(sp)
    80003c60:	64a2                	ld	s1,8(sp)
    80003c62:	6902                	ld	s2,0(sp)
    80003c64:	6105                	addi	sp,sp,32
    80003c66:	8082                	ret
    panic("iunlock");
    80003c68:	00005517          	auipc	a0,0x5
    80003c6c:	a7050513          	addi	a0,a0,-1424 # 800086d8 <syscalls+0x1b8>
    80003c70:	ffffd097          	auipc	ra,0xffffd
    80003c74:	8d0080e7          	jalr	-1840(ra) # 80000540 <panic>

0000000080003c78 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c78:	7179                	addi	sp,sp,-48
    80003c7a:	f406                	sd	ra,40(sp)
    80003c7c:	f022                	sd	s0,32(sp)
    80003c7e:	ec26                	sd	s1,24(sp)
    80003c80:	e84a                	sd	s2,16(sp)
    80003c82:	e44e                	sd	s3,8(sp)
    80003c84:	e052                	sd	s4,0(sp)
    80003c86:	1800                	addi	s0,sp,48
    80003c88:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003c8a:	05050493          	addi	s1,a0,80
    80003c8e:	08050913          	addi	s2,a0,128
    80003c92:	a021                	j	80003c9a <itrunc+0x22>
    80003c94:	0491                	addi	s1,s1,4
    80003c96:	01248d63          	beq	s1,s2,80003cb0 <itrunc+0x38>
    if(ip->addrs[i]){
    80003c9a:	408c                	lw	a1,0(s1)
    80003c9c:	dde5                	beqz	a1,80003c94 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003c9e:	0009a503          	lw	a0,0(s3)
    80003ca2:	00000097          	auipc	ra,0x0
    80003ca6:	8f6080e7          	jalr	-1802(ra) # 80003598 <bfree>
      ip->addrs[i] = 0;
    80003caa:	0004a023          	sw	zero,0(s1)
    80003cae:	b7dd                	j	80003c94 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cb0:	0809a583          	lw	a1,128(s3)
    80003cb4:	e185                	bnez	a1,80003cd4 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cb6:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cba:	854e                	mv	a0,s3
    80003cbc:	00000097          	auipc	ra,0x0
    80003cc0:	de2080e7          	jalr	-542(ra) # 80003a9e <iupdate>
}
    80003cc4:	70a2                	ld	ra,40(sp)
    80003cc6:	7402                	ld	s0,32(sp)
    80003cc8:	64e2                	ld	s1,24(sp)
    80003cca:	6942                	ld	s2,16(sp)
    80003ccc:	69a2                	ld	s3,8(sp)
    80003cce:	6a02                	ld	s4,0(sp)
    80003cd0:	6145                	addi	sp,sp,48
    80003cd2:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cd4:	0009a503          	lw	a0,0(s3)
    80003cd8:	fffff097          	auipc	ra,0xfffff
    80003cdc:	67a080e7          	jalr	1658(ra) # 80003352 <bread>
    80003ce0:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003ce2:	05850493          	addi	s1,a0,88
    80003ce6:	45850913          	addi	s2,a0,1112
    80003cea:	a021                	j	80003cf2 <itrunc+0x7a>
    80003cec:	0491                	addi	s1,s1,4
    80003cee:	01248b63          	beq	s1,s2,80003d04 <itrunc+0x8c>
      if(a[j])
    80003cf2:	408c                	lw	a1,0(s1)
    80003cf4:	dde5                	beqz	a1,80003cec <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003cf6:	0009a503          	lw	a0,0(s3)
    80003cfa:	00000097          	auipc	ra,0x0
    80003cfe:	89e080e7          	jalr	-1890(ra) # 80003598 <bfree>
    80003d02:	b7ed                	j	80003cec <itrunc+0x74>
    brelse(bp);
    80003d04:	8552                	mv	a0,s4
    80003d06:	fffff097          	auipc	ra,0xfffff
    80003d0a:	77c080e7          	jalr	1916(ra) # 80003482 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d0e:	0809a583          	lw	a1,128(s3)
    80003d12:	0009a503          	lw	a0,0(s3)
    80003d16:	00000097          	auipc	ra,0x0
    80003d1a:	882080e7          	jalr	-1918(ra) # 80003598 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d1e:	0809a023          	sw	zero,128(s3)
    80003d22:	bf51                	j	80003cb6 <itrunc+0x3e>

0000000080003d24 <iput>:
{
    80003d24:	1101                	addi	sp,sp,-32
    80003d26:	ec06                	sd	ra,24(sp)
    80003d28:	e822                	sd	s0,16(sp)
    80003d2a:	e426                	sd	s1,8(sp)
    80003d2c:	e04a                	sd	s2,0(sp)
    80003d2e:	1000                	addi	s0,sp,32
    80003d30:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d32:	0001b517          	auipc	a0,0x1b
    80003d36:	68650513          	addi	a0,a0,1670 # 8001f3b8 <itable>
    80003d3a:	ffffd097          	auipc	ra,0xffffd
    80003d3e:	e9c080e7          	jalr	-356(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d42:	4498                	lw	a4,8(s1)
    80003d44:	4785                	li	a5,1
    80003d46:	02f70363          	beq	a4,a5,80003d6c <iput+0x48>
  ip->ref--;
    80003d4a:	449c                	lw	a5,8(s1)
    80003d4c:	37fd                	addiw	a5,a5,-1
    80003d4e:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d50:	0001b517          	auipc	a0,0x1b
    80003d54:	66850513          	addi	a0,a0,1640 # 8001f3b8 <itable>
    80003d58:	ffffd097          	auipc	ra,0xffffd
    80003d5c:	f32080e7          	jalr	-206(ra) # 80000c8a <release>
}
    80003d60:	60e2                	ld	ra,24(sp)
    80003d62:	6442                	ld	s0,16(sp)
    80003d64:	64a2                	ld	s1,8(sp)
    80003d66:	6902                	ld	s2,0(sp)
    80003d68:	6105                	addi	sp,sp,32
    80003d6a:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d6c:	40bc                	lw	a5,64(s1)
    80003d6e:	dff1                	beqz	a5,80003d4a <iput+0x26>
    80003d70:	04a49783          	lh	a5,74(s1)
    80003d74:	fbf9                	bnez	a5,80003d4a <iput+0x26>
    acquiresleep(&ip->lock);
    80003d76:	01048913          	addi	s2,s1,16
    80003d7a:	854a                	mv	a0,s2
    80003d7c:	00001097          	auipc	ra,0x1
    80003d80:	aae080e7          	jalr	-1362(ra) # 8000482a <acquiresleep>
    release(&itable.lock);
    80003d84:	0001b517          	auipc	a0,0x1b
    80003d88:	63450513          	addi	a0,a0,1588 # 8001f3b8 <itable>
    80003d8c:	ffffd097          	auipc	ra,0xffffd
    80003d90:	efe080e7          	jalr	-258(ra) # 80000c8a <release>
    itrunc(ip);
    80003d94:	8526                	mv	a0,s1
    80003d96:	00000097          	auipc	ra,0x0
    80003d9a:	ee2080e7          	jalr	-286(ra) # 80003c78 <itrunc>
    ip->type = 0;
    80003d9e:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003da2:	8526                	mv	a0,s1
    80003da4:	00000097          	auipc	ra,0x0
    80003da8:	cfa080e7          	jalr	-774(ra) # 80003a9e <iupdate>
    ip->valid = 0;
    80003dac:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003db0:	854a                	mv	a0,s2
    80003db2:	00001097          	auipc	ra,0x1
    80003db6:	ace080e7          	jalr	-1330(ra) # 80004880 <releasesleep>
    acquire(&itable.lock);
    80003dba:	0001b517          	auipc	a0,0x1b
    80003dbe:	5fe50513          	addi	a0,a0,1534 # 8001f3b8 <itable>
    80003dc2:	ffffd097          	auipc	ra,0xffffd
    80003dc6:	e14080e7          	jalr	-492(ra) # 80000bd6 <acquire>
    80003dca:	b741                	j	80003d4a <iput+0x26>

0000000080003dcc <iunlockput>:
{
    80003dcc:	1101                	addi	sp,sp,-32
    80003dce:	ec06                	sd	ra,24(sp)
    80003dd0:	e822                	sd	s0,16(sp)
    80003dd2:	e426                	sd	s1,8(sp)
    80003dd4:	1000                	addi	s0,sp,32
    80003dd6:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dd8:	00000097          	auipc	ra,0x0
    80003ddc:	e54080e7          	jalr	-428(ra) # 80003c2c <iunlock>
  iput(ip);
    80003de0:	8526                	mv	a0,s1
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	f42080e7          	jalr	-190(ra) # 80003d24 <iput>
}
    80003dea:	60e2                	ld	ra,24(sp)
    80003dec:	6442                	ld	s0,16(sp)
    80003dee:	64a2                	ld	s1,8(sp)
    80003df0:	6105                	addi	sp,sp,32
    80003df2:	8082                	ret

0000000080003df4 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003df4:	1141                	addi	sp,sp,-16
    80003df6:	e422                	sd	s0,8(sp)
    80003df8:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003dfa:	411c                	lw	a5,0(a0)
    80003dfc:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003dfe:	415c                	lw	a5,4(a0)
    80003e00:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e02:	04451783          	lh	a5,68(a0)
    80003e06:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e0a:	04a51783          	lh	a5,74(a0)
    80003e0e:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e12:	04c56783          	lwu	a5,76(a0)
    80003e16:	e99c                	sd	a5,16(a1)
}
    80003e18:	6422                	ld	s0,8(sp)
    80003e1a:	0141                	addi	sp,sp,16
    80003e1c:	8082                	ret

0000000080003e1e <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e1e:	457c                	lw	a5,76(a0)
    80003e20:	0ed7e963          	bltu	a5,a3,80003f12 <readi+0xf4>
{
    80003e24:	7159                	addi	sp,sp,-112
    80003e26:	f486                	sd	ra,104(sp)
    80003e28:	f0a2                	sd	s0,96(sp)
    80003e2a:	eca6                	sd	s1,88(sp)
    80003e2c:	e8ca                	sd	s2,80(sp)
    80003e2e:	e4ce                	sd	s3,72(sp)
    80003e30:	e0d2                	sd	s4,64(sp)
    80003e32:	fc56                	sd	s5,56(sp)
    80003e34:	f85a                	sd	s6,48(sp)
    80003e36:	f45e                	sd	s7,40(sp)
    80003e38:	f062                	sd	s8,32(sp)
    80003e3a:	ec66                	sd	s9,24(sp)
    80003e3c:	e86a                	sd	s10,16(sp)
    80003e3e:	e46e                	sd	s11,8(sp)
    80003e40:	1880                	addi	s0,sp,112
    80003e42:	8b2a                	mv	s6,a0
    80003e44:	8bae                	mv	s7,a1
    80003e46:	8a32                	mv	s4,a2
    80003e48:	84b6                	mv	s1,a3
    80003e4a:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e4c:	9f35                	addw	a4,a4,a3
    return 0;
    80003e4e:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e50:	0ad76063          	bltu	a4,a3,80003ef0 <readi+0xd2>
  if(off + n > ip->size)
    80003e54:	00e7f463          	bgeu	a5,a4,80003e5c <readi+0x3e>
    n = ip->size - off;
    80003e58:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e5c:	0a0a8963          	beqz	s5,80003f0e <readi+0xf0>
    80003e60:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e62:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e66:	5c7d                	li	s8,-1
    80003e68:	a82d                	j	80003ea2 <readi+0x84>
    80003e6a:	020d1d93          	slli	s11,s10,0x20
    80003e6e:	020ddd93          	srli	s11,s11,0x20
    80003e72:	05890613          	addi	a2,s2,88
    80003e76:	86ee                	mv	a3,s11
    80003e78:	963a                	add	a2,a2,a4
    80003e7a:	85d2                	mv	a1,s4
    80003e7c:	855e                	mv	a0,s7
    80003e7e:	fffff097          	auipc	ra,0xfffff
    80003e82:	926080e7          	jalr	-1754(ra) # 800027a4 <either_copyout>
    80003e86:	05850d63          	beq	a0,s8,80003ee0 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003e8a:	854a                	mv	a0,s2
    80003e8c:	fffff097          	auipc	ra,0xfffff
    80003e90:	5f6080e7          	jalr	1526(ra) # 80003482 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e94:	013d09bb          	addw	s3,s10,s3
    80003e98:	009d04bb          	addw	s1,s10,s1
    80003e9c:	9a6e                	add	s4,s4,s11
    80003e9e:	0559f763          	bgeu	s3,s5,80003eec <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ea2:	00a4d59b          	srliw	a1,s1,0xa
    80003ea6:	855a                	mv	a0,s6
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	89e080e7          	jalr	-1890(ra) # 80003746 <bmap>
    80003eb0:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003eb4:	cd85                	beqz	a1,80003eec <readi+0xce>
    bp = bread(ip->dev, addr);
    80003eb6:	000b2503          	lw	a0,0(s6)
    80003eba:	fffff097          	auipc	ra,0xfffff
    80003ebe:	498080e7          	jalr	1176(ra) # 80003352 <bread>
    80003ec2:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ec4:	3ff4f713          	andi	a4,s1,1023
    80003ec8:	40ec87bb          	subw	a5,s9,a4
    80003ecc:	413a86bb          	subw	a3,s5,s3
    80003ed0:	8d3e                	mv	s10,a5
    80003ed2:	2781                	sext.w	a5,a5
    80003ed4:	0006861b          	sext.w	a2,a3
    80003ed8:	f8f679e3          	bgeu	a2,a5,80003e6a <readi+0x4c>
    80003edc:	8d36                	mv	s10,a3
    80003ede:	b771                	j	80003e6a <readi+0x4c>
      brelse(bp);
    80003ee0:	854a                	mv	a0,s2
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	5a0080e7          	jalr	1440(ra) # 80003482 <brelse>
      tot = -1;
    80003eea:	59fd                	li	s3,-1
  }
  return tot;
    80003eec:	0009851b          	sext.w	a0,s3
}
    80003ef0:	70a6                	ld	ra,104(sp)
    80003ef2:	7406                	ld	s0,96(sp)
    80003ef4:	64e6                	ld	s1,88(sp)
    80003ef6:	6946                	ld	s2,80(sp)
    80003ef8:	69a6                	ld	s3,72(sp)
    80003efa:	6a06                	ld	s4,64(sp)
    80003efc:	7ae2                	ld	s5,56(sp)
    80003efe:	7b42                	ld	s6,48(sp)
    80003f00:	7ba2                	ld	s7,40(sp)
    80003f02:	7c02                	ld	s8,32(sp)
    80003f04:	6ce2                	ld	s9,24(sp)
    80003f06:	6d42                	ld	s10,16(sp)
    80003f08:	6da2                	ld	s11,8(sp)
    80003f0a:	6165                	addi	sp,sp,112
    80003f0c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f0e:	89d6                	mv	s3,s5
    80003f10:	bff1                	j	80003eec <readi+0xce>
    return 0;
    80003f12:	4501                	li	a0,0
}
    80003f14:	8082                	ret

0000000080003f16 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f16:	457c                	lw	a5,76(a0)
    80003f18:	10d7e863          	bltu	a5,a3,80004028 <writei+0x112>
{
    80003f1c:	7159                	addi	sp,sp,-112
    80003f1e:	f486                	sd	ra,104(sp)
    80003f20:	f0a2                	sd	s0,96(sp)
    80003f22:	eca6                	sd	s1,88(sp)
    80003f24:	e8ca                	sd	s2,80(sp)
    80003f26:	e4ce                	sd	s3,72(sp)
    80003f28:	e0d2                	sd	s4,64(sp)
    80003f2a:	fc56                	sd	s5,56(sp)
    80003f2c:	f85a                	sd	s6,48(sp)
    80003f2e:	f45e                	sd	s7,40(sp)
    80003f30:	f062                	sd	s8,32(sp)
    80003f32:	ec66                	sd	s9,24(sp)
    80003f34:	e86a                	sd	s10,16(sp)
    80003f36:	e46e                	sd	s11,8(sp)
    80003f38:	1880                	addi	s0,sp,112
    80003f3a:	8aaa                	mv	s5,a0
    80003f3c:	8bae                	mv	s7,a1
    80003f3e:	8a32                	mv	s4,a2
    80003f40:	8936                	mv	s2,a3
    80003f42:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f44:	00e687bb          	addw	a5,a3,a4
    80003f48:	0ed7e263          	bltu	a5,a3,8000402c <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f4c:	00043737          	lui	a4,0x43
    80003f50:	0ef76063          	bltu	a4,a5,80004030 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f54:	0c0b0863          	beqz	s6,80004024 <writei+0x10e>
    80003f58:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f5a:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f5e:	5c7d                	li	s8,-1
    80003f60:	a091                	j	80003fa4 <writei+0x8e>
    80003f62:	020d1d93          	slli	s11,s10,0x20
    80003f66:	020ddd93          	srli	s11,s11,0x20
    80003f6a:	05848513          	addi	a0,s1,88
    80003f6e:	86ee                	mv	a3,s11
    80003f70:	8652                	mv	a2,s4
    80003f72:	85de                	mv	a1,s7
    80003f74:	953a                	add	a0,a0,a4
    80003f76:	fffff097          	auipc	ra,0xfffff
    80003f7a:	884080e7          	jalr	-1916(ra) # 800027fa <either_copyin>
    80003f7e:	07850263          	beq	a0,s8,80003fe2 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003f82:	8526                	mv	a0,s1
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	788080e7          	jalr	1928(ra) # 8000470c <log_write>
    brelse(bp);
    80003f8c:	8526                	mv	a0,s1
    80003f8e:	fffff097          	auipc	ra,0xfffff
    80003f92:	4f4080e7          	jalr	1268(ra) # 80003482 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f96:	013d09bb          	addw	s3,s10,s3
    80003f9a:	012d093b          	addw	s2,s10,s2
    80003f9e:	9a6e                	add	s4,s4,s11
    80003fa0:	0569f663          	bgeu	s3,s6,80003fec <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fa4:	00a9559b          	srliw	a1,s2,0xa
    80003fa8:	8556                	mv	a0,s5
    80003faa:	fffff097          	auipc	ra,0xfffff
    80003fae:	79c080e7          	jalr	1948(ra) # 80003746 <bmap>
    80003fb2:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fb6:	c99d                	beqz	a1,80003fec <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fb8:	000aa503          	lw	a0,0(s5)
    80003fbc:	fffff097          	auipc	ra,0xfffff
    80003fc0:	396080e7          	jalr	918(ra) # 80003352 <bread>
    80003fc4:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fc6:	3ff97713          	andi	a4,s2,1023
    80003fca:	40ec87bb          	subw	a5,s9,a4
    80003fce:	413b06bb          	subw	a3,s6,s3
    80003fd2:	8d3e                	mv	s10,a5
    80003fd4:	2781                	sext.w	a5,a5
    80003fd6:	0006861b          	sext.w	a2,a3
    80003fda:	f8f674e3          	bgeu	a2,a5,80003f62 <writei+0x4c>
    80003fde:	8d36                	mv	s10,a3
    80003fe0:	b749                	j	80003f62 <writei+0x4c>
      brelse(bp);
    80003fe2:	8526                	mv	a0,s1
    80003fe4:	fffff097          	auipc	ra,0xfffff
    80003fe8:	49e080e7          	jalr	1182(ra) # 80003482 <brelse>
  }

  if(off > ip->size)
    80003fec:	04caa783          	lw	a5,76(s5)
    80003ff0:	0127f463          	bgeu	a5,s2,80003ff8 <writei+0xe2>
    ip->size = off;
    80003ff4:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ff8:	8556                	mv	a0,s5
    80003ffa:	00000097          	auipc	ra,0x0
    80003ffe:	aa4080e7          	jalr	-1372(ra) # 80003a9e <iupdate>

  return tot;
    80004002:	0009851b          	sext.w	a0,s3
}
    80004006:	70a6                	ld	ra,104(sp)
    80004008:	7406                	ld	s0,96(sp)
    8000400a:	64e6                	ld	s1,88(sp)
    8000400c:	6946                	ld	s2,80(sp)
    8000400e:	69a6                	ld	s3,72(sp)
    80004010:	6a06                	ld	s4,64(sp)
    80004012:	7ae2                	ld	s5,56(sp)
    80004014:	7b42                	ld	s6,48(sp)
    80004016:	7ba2                	ld	s7,40(sp)
    80004018:	7c02                	ld	s8,32(sp)
    8000401a:	6ce2                	ld	s9,24(sp)
    8000401c:	6d42                	ld	s10,16(sp)
    8000401e:	6da2                	ld	s11,8(sp)
    80004020:	6165                	addi	sp,sp,112
    80004022:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004024:	89da                	mv	s3,s6
    80004026:	bfc9                	j	80003ff8 <writei+0xe2>
    return -1;
    80004028:	557d                	li	a0,-1
}
    8000402a:	8082                	ret
    return -1;
    8000402c:	557d                	li	a0,-1
    8000402e:	bfe1                	j	80004006 <writei+0xf0>
    return -1;
    80004030:	557d                	li	a0,-1
    80004032:	bfd1                	j	80004006 <writei+0xf0>

0000000080004034 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004034:	1141                	addi	sp,sp,-16
    80004036:	e406                	sd	ra,8(sp)
    80004038:	e022                	sd	s0,0(sp)
    8000403a:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    8000403c:	4639                	li	a2,14
    8000403e:	ffffd097          	auipc	ra,0xffffd
    80004042:	d64080e7          	jalr	-668(ra) # 80000da2 <strncmp>
}
    80004046:	60a2                	ld	ra,8(sp)
    80004048:	6402                	ld	s0,0(sp)
    8000404a:	0141                	addi	sp,sp,16
    8000404c:	8082                	ret

000000008000404e <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    8000404e:	7139                	addi	sp,sp,-64
    80004050:	fc06                	sd	ra,56(sp)
    80004052:	f822                	sd	s0,48(sp)
    80004054:	f426                	sd	s1,40(sp)
    80004056:	f04a                	sd	s2,32(sp)
    80004058:	ec4e                	sd	s3,24(sp)
    8000405a:	e852                	sd	s4,16(sp)
    8000405c:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    8000405e:	04451703          	lh	a4,68(a0)
    80004062:	4785                	li	a5,1
    80004064:	00f71a63          	bne	a4,a5,80004078 <dirlookup+0x2a>
    80004068:	892a                	mv	s2,a0
    8000406a:	89ae                	mv	s3,a1
    8000406c:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    8000406e:	457c                	lw	a5,76(a0)
    80004070:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004072:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004074:	e79d                	bnez	a5,800040a2 <dirlookup+0x54>
    80004076:	a8a5                	j	800040ee <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004078:	00004517          	auipc	a0,0x4
    8000407c:	66850513          	addi	a0,a0,1640 # 800086e0 <syscalls+0x1c0>
    80004080:	ffffc097          	auipc	ra,0xffffc
    80004084:	4c0080e7          	jalr	1216(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004088:	00004517          	auipc	a0,0x4
    8000408c:	67050513          	addi	a0,a0,1648 # 800086f8 <syscalls+0x1d8>
    80004090:	ffffc097          	auipc	ra,0xffffc
    80004094:	4b0080e7          	jalr	1200(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004098:	24c1                	addiw	s1,s1,16
    8000409a:	04c92783          	lw	a5,76(s2)
    8000409e:	04f4f763          	bgeu	s1,a5,800040ec <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040a2:	4741                	li	a4,16
    800040a4:	86a6                	mv	a3,s1
    800040a6:	fc040613          	addi	a2,s0,-64
    800040aa:	4581                	li	a1,0
    800040ac:	854a                	mv	a0,s2
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	d70080e7          	jalr	-656(ra) # 80003e1e <readi>
    800040b6:	47c1                	li	a5,16
    800040b8:	fcf518e3          	bne	a0,a5,80004088 <dirlookup+0x3a>
    if(de.inum == 0)
    800040bc:	fc045783          	lhu	a5,-64(s0)
    800040c0:	dfe1                	beqz	a5,80004098 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040c2:	fc240593          	addi	a1,s0,-62
    800040c6:	854e                	mv	a0,s3
    800040c8:	00000097          	auipc	ra,0x0
    800040cc:	f6c080e7          	jalr	-148(ra) # 80004034 <namecmp>
    800040d0:	f561                	bnez	a0,80004098 <dirlookup+0x4a>
      if(poff)
    800040d2:	000a0463          	beqz	s4,800040da <dirlookup+0x8c>
        *poff = off;
    800040d6:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040da:	fc045583          	lhu	a1,-64(s0)
    800040de:	00092503          	lw	a0,0(s2)
    800040e2:	fffff097          	auipc	ra,0xfffff
    800040e6:	74e080e7          	jalr	1870(ra) # 80003830 <iget>
    800040ea:	a011                	j	800040ee <dirlookup+0xa0>
  return 0;
    800040ec:	4501                	li	a0,0
}
    800040ee:	70e2                	ld	ra,56(sp)
    800040f0:	7442                	ld	s0,48(sp)
    800040f2:	74a2                	ld	s1,40(sp)
    800040f4:	7902                	ld	s2,32(sp)
    800040f6:	69e2                	ld	s3,24(sp)
    800040f8:	6a42                	ld	s4,16(sp)
    800040fa:	6121                	addi	sp,sp,64
    800040fc:	8082                	ret

00000000800040fe <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800040fe:	711d                	addi	sp,sp,-96
    80004100:	ec86                	sd	ra,88(sp)
    80004102:	e8a2                	sd	s0,80(sp)
    80004104:	e4a6                	sd	s1,72(sp)
    80004106:	e0ca                	sd	s2,64(sp)
    80004108:	fc4e                	sd	s3,56(sp)
    8000410a:	f852                	sd	s4,48(sp)
    8000410c:	f456                	sd	s5,40(sp)
    8000410e:	f05a                	sd	s6,32(sp)
    80004110:	ec5e                	sd	s7,24(sp)
    80004112:	e862                	sd	s8,16(sp)
    80004114:	e466                	sd	s9,8(sp)
    80004116:	e06a                	sd	s10,0(sp)
    80004118:	1080                	addi	s0,sp,96
    8000411a:	84aa                	mv	s1,a0
    8000411c:	8b2e                	mv	s6,a1
    8000411e:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004120:	00054703          	lbu	a4,0(a0)
    80004124:	02f00793          	li	a5,47
    80004128:	02f70363          	beq	a4,a5,8000414e <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000412c:	ffffe097          	auipc	ra,0xffffe
    80004130:	ac2080e7          	jalr	-1342(ra) # 80001bee <myproc>
    80004134:	15853503          	ld	a0,344(a0)
    80004138:	00000097          	auipc	ra,0x0
    8000413c:	9f4080e7          	jalr	-1548(ra) # 80003b2c <idup>
    80004140:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004142:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004146:	4cb5                	li	s9,13
  len = path - s;
    80004148:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000414a:	4c05                	li	s8,1
    8000414c:	a87d                	j	8000420a <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    8000414e:	4585                	li	a1,1
    80004150:	4505                	li	a0,1
    80004152:	fffff097          	auipc	ra,0xfffff
    80004156:	6de080e7          	jalr	1758(ra) # 80003830 <iget>
    8000415a:	8a2a                	mv	s4,a0
    8000415c:	b7dd                	j	80004142 <namex+0x44>
      iunlockput(ip);
    8000415e:	8552                	mv	a0,s4
    80004160:	00000097          	auipc	ra,0x0
    80004164:	c6c080e7          	jalr	-916(ra) # 80003dcc <iunlockput>
      return 0;
    80004168:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000416a:	8552                	mv	a0,s4
    8000416c:	60e6                	ld	ra,88(sp)
    8000416e:	6446                	ld	s0,80(sp)
    80004170:	64a6                	ld	s1,72(sp)
    80004172:	6906                	ld	s2,64(sp)
    80004174:	79e2                	ld	s3,56(sp)
    80004176:	7a42                	ld	s4,48(sp)
    80004178:	7aa2                	ld	s5,40(sp)
    8000417a:	7b02                	ld	s6,32(sp)
    8000417c:	6be2                	ld	s7,24(sp)
    8000417e:	6c42                	ld	s8,16(sp)
    80004180:	6ca2                	ld	s9,8(sp)
    80004182:	6d02                	ld	s10,0(sp)
    80004184:	6125                	addi	sp,sp,96
    80004186:	8082                	ret
      iunlock(ip);
    80004188:	8552                	mv	a0,s4
    8000418a:	00000097          	auipc	ra,0x0
    8000418e:	aa2080e7          	jalr	-1374(ra) # 80003c2c <iunlock>
      return ip;
    80004192:	bfe1                	j	8000416a <namex+0x6c>
      iunlockput(ip);
    80004194:	8552                	mv	a0,s4
    80004196:	00000097          	auipc	ra,0x0
    8000419a:	c36080e7          	jalr	-970(ra) # 80003dcc <iunlockput>
      return 0;
    8000419e:	8a4e                	mv	s4,s3
    800041a0:	b7e9                	j	8000416a <namex+0x6c>
  len = path - s;
    800041a2:	40998633          	sub	a2,s3,s1
    800041a6:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    800041aa:	09acd863          	bge	s9,s10,8000423a <namex+0x13c>
    memmove(name, s, DIRSIZ);
    800041ae:	4639                	li	a2,14
    800041b0:	85a6                	mv	a1,s1
    800041b2:	8556                	mv	a0,s5
    800041b4:	ffffd097          	auipc	ra,0xffffd
    800041b8:	b7a080e7          	jalr	-1158(ra) # 80000d2e <memmove>
    800041bc:	84ce                	mv	s1,s3
  while(*path == '/')
    800041be:	0004c783          	lbu	a5,0(s1)
    800041c2:	01279763          	bne	a5,s2,800041d0 <namex+0xd2>
    path++;
    800041c6:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041c8:	0004c783          	lbu	a5,0(s1)
    800041cc:	ff278de3          	beq	a5,s2,800041c6 <namex+0xc8>
    ilock(ip);
    800041d0:	8552                	mv	a0,s4
    800041d2:	00000097          	auipc	ra,0x0
    800041d6:	998080e7          	jalr	-1640(ra) # 80003b6a <ilock>
    if(ip->type != T_DIR){
    800041da:	044a1783          	lh	a5,68(s4)
    800041de:	f98790e3          	bne	a5,s8,8000415e <namex+0x60>
    if(nameiparent && *path == '\0'){
    800041e2:	000b0563          	beqz	s6,800041ec <namex+0xee>
    800041e6:	0004c783          	lbu	a5,0(s1)
    800041ea:	dfd9                	beqz	a5,80004188 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800041ec:	865e                	mv	a2,s7
    800041ee:	85d6                	mv	a1,s5
    800041f0:	8552                	mv	a0,s4
    800041f2:	00000097          	auipc	ra,0x0
    800041f6:	e5c080e7          	jalr	-420(ra) # 8000404e <dirlookup>
    800041fa:	89aa                	mv	s3,a0
    800041fc:	dd41                	beqz	a0,80004194 <namex+0x96>
    iunlockput(ip);
    800041fe:	8552                	mv	a0,s4
    80004200:	00000097          	auipc	ra,0x0
    80004204:	bcc080e7          	jalr	-1076(ra) # 80003dcc <iunlockput>
    ip = next;
    80004208:	8a4e                	mv	s4,s3
  while(*path == '/')
    8000420a:	0004c783          	lbu	a5,0(s1)
    8000420e:	01279763          	bne	a5,s2,8000421c <namex+0x11e>
    path++;
    80004212:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004214:	0004c783          	lbu	a5,0(s1)
    80004218:	ff278de3          	beq	a5,s2,80004212 <namex+0x114>
  if(*path == 0)
    8000421c:	cb9d                	beqz	a5,80004252 <namex+0x154>
  while(*path != '/' && *path != 0)
    8000421e:	0004c783          	lbu	a5,0(s1)
    80004222:	89a6                	mv	s3,s1
  len = path - s;
    80004224:	8d5e                	mv	s10,s7
    80004226:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80004228:	01278963          	beq	a5,s2,8000423a <namex+0x13c>
    8000422c:	dbbd                	beqz	a5,800041a2 <namex+0xa4>
    path++;
    8000422e:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80004230:	0009c783          	lbu	a5,0(s3)
    80004234:	ff279ce3          	bne	a5,s2,8000422c <namex+0x12e>
    80004238:	b7ad                	j	800041a2 <namex+0xa4>
    memmove(name, s, len);
    8000423a:	2601                	sext.w	a2,a2
    8000423c:	85a6                	mv	a1,s1
    8000423e:	8556                	mv	a0,s5
    80004240:	ffffd097          	auipc	ra,0xffffd
    80004244:	aee080e7          	jalr	-1298(ra) # 80000d2e <memmove>
    name[len] = 0;
    80004248:	9d56                	add	s10,s10,s5
    8000424a:	000d0023          	sb	zero,0(s10)
    8000424e:	84ce                	mv	s1,s3
    80004250:	b7bd                	j	800041be <namex+0xc0>
  if(nameiparent){
    80004252:	f00b0ce3          	beqz	s6,8000416a <namex+0x6c>
    iput(ip);
    80004256:	8552                	mv	a0,s4
    80004258:	00000097          	auipc	ra,0x0
    8000425c:	acc080e7          	jalr	-1332(ra) # 80003d24 <iput>
    return 0;
    80004260:	4a01                	li	s4,0
    80004262:	b721                	j	8000416a <namex+0x6c>

0000000080004264 <dirlink>:
{
    80004264:	7139                	addi	sp,sp,-64
    80004266:	fc06                	sd	ra,56(sp)
    80004268:	f822                	sd	s0,48(sp)
    8000426a:	f426                	sd	s1,40(sp)
    8000426c:	f04a                	sd	s2,32(sp)
    8000426e:	ec4e                	sd	s3,24(sp)
    80004270:	e852                	sd	s4,16(sp)
    80004272:	0080                	addi	s0,sp,64
    80004274:	892a                	mv	s2,a0
    80004276:	8a2e                	mv	s4,a1
    80004278:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000427a:	4601                	li	a2,0
    8000427c:	00000097          	auipc	ra,0x0
    80004280:	dd2080e7          	jalr	-558(ra) # 8000404e <dirlookup>
    80004284:	e93d                	bnez	a0,800042fa <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004286:	04c92483          	lw	s1,76(s2)
    8000428a:	c49d                	beqz	s1,800042b8 <dirlink+0x54>
    8000428c:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000428e:	4741                	li	a4,16
    80004290:	86a6                	mv	a3,s1
    80004292:	fc040613          	addi	a2,s0,-64
    80004296:	4581                	li	a1,0
    80004298:	854a                	mv	a0,s2
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	b84080e7          	jalr	-1148(ra) # 80003e1e <readi>
    800042a2:	47c1                	li	a5,16
    800042a4:	06f51163          	bne	a0,a5,80004306 <dirlink+0xa2>
    if(de.inum == 0)
    800042a8:	fc045783          	lhu	a5,-64(s0)
    800042ac:	c791                	beqz	a5,800042b8 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042ae:	24c1                	addiw	s1,s1,16
    800042b0:	04c92783          	lw	a5,76(s2)
    800042b4:	fcf4ede3          	bltu	s1,a5,8000428e <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042b8:	4639                	li	a2,14
    800042ba:	85d2                	mv	a1,s4
    800042bc:	fc240513          	addi	a0,s0,-62
    800042c0:	ffffd097          	auipc	ra,0xffffd
    800042c4:	b1e080e7          	jalr	-1250(ra) # 80000dde <strncpy>
  de.inum = inum;
    800042c8:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042cc:	4741                	li	a4,16
    800042ce:	86a6                	mv	a3,s1
    800042d0:	fc040613          	addi	a2,s0,-64
    800042d4:	4581                	li	a1,0
    800042d6:	854a                	mv	a0,s2
    800042d8:	00000097          	auipc	ra,0x0
    800042dc:	c3e080e7          	jalr	-962(ra) # 80003f16 <writei>
    800042e0:	1541                	addi	a0,a0,-16
    800042e2:	00a03533          	snez	a0,a0
    800042e6:	40a00533          	neg	a0,a0
}
    800042ea:	70e2                	ld	ra,56(sp)
    800042ec:	7442                	ld	s0,48(sp)
    800042ee:	74a2                	ld	s1,40(sp)
    800042f0:	7902                	ld	s2,32(sp)
    800042f2:	69e2                	ld	s3,24(sp)
    800042f4:	6a42                	ld	s4,16(sp)
    800042f6:	6121                	addi	sp,sp,64
    800042f8:	8082                	ret
    iput(ip);
    800042fa:	00000097          	auipc	ra,0x0
    800042fe:	a2a080e7          	jalr	-1494(ra) # 80003d24 <iput>
    return -1;
    80004302:	557d                	li	a0,-1
    80004304:	b7dd                	j	800042ea <dirlink+0x86>
      panic("dirlink read");
    80004306:	00004517          	auipc	a0,0x4
    8000430a:	40250513          	addi	a0,a0,1026 # 80008708 <syscalls+0x1e8>
    8000430e:	ffffc097          	auipc	ra,0xffffc
    80004312:	232080e7          	jalr	562(ra) # 80000540 <panic>

0000000080004316 <namei>:

struct inode*
namei(char *path)
{
    80004316:	1101                	addi	sp,sp,-32
    80004318:	ec06                	sd	ra,24(sp)
    8000431a:	e822                	sd	s0,16(sp)
    8000431c:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000431e:	fe040613          	addi	a2,s0,-32
    80004322:	4581                	li	a1,0
    80004324:	00000097          	auipc	ra,0x0
    80004328:	dda080e7          	jalr	-550(ra) # 800040fe <namex>
}
    8000432c:	60e2                	ld	ra,24(sp)
    8000432e:	6442                	ld	s0,16(sp)
    80004330:	6105                	addi	sp,sp,32
    80004332:	8082                	ret

0000000080004334 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004334:	1141                	addi	sp,sp,-16
    80004336:	e406                	sd	ra,8(sp)
    80004338:	e022                	sd	s0,0(sp)
    8000433a:	0800                	addi	s0,sp,16
    8000433c:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000433e:	4585                	li	a1,1
    80004340:	00000097          	auipc	ra,0x0
    80004344:	dbe080e7          	jalr	-578(ra) # 800040fe <namex>
}
    80004348:	60a2                	ld	ra,8(sp)
    8000434a:	6402                	ld	s0,0(sp)
    8000434c:	0141                	addi	sp,sp,16
    8000434e:	8082                	ret

0000000080004350 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004350:	1101                	addi	sp,sp,-32
    80004352:	ec06                	sd	ra,24(sp)
    80004354:	e822                	sd	s0,16(sp)
    80004356:	e426                	sd	s1,8(sp)
    80004358:	e04a                	sd	s2,0(sp)
    8000435a:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000435c:	0001d917          	auipc	s2,0x1d
    80004360:	b0490913          	addi	s2,s2,-1276 # 80020e60 <log>
    80004364:	01892583          	lw	a1,24(s2)
    80004368:	02892503          	lw	a0,40(s2)
    8000436c:	fffff097          	auipc	ra,0xfffff
    80004370:	fe6080e7          	jalr	-26(ra) # 80003352 <bread>
    80004374:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004376:	02c92683          	lw	a3,44(s2)
    8000437a:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000437c:	02d05863          	blez	a3,800043ac <write_head+0x5c>
    80004380:	0001d797          	auipc	a5,0x1d
    80004384:	b1078793          	addi	a5,a5,-1264 # 80020e90 <log+0x30>
    80004388:	05c50713          	addi	a4,a0,92
    8000438c:	36fd                	addiw	a3,a3,-1
    8000438e:	02069613          	slli	a2,a3,0x20
    80004392:	01e65693          	srli	a3,a2,0x1e
    80004396:	0001d617          	auipc	a2,0x1d
    8000439a:	afe60613          	addi	a2,a2,-1282 # 80020e94 <log+0x34>
    8000439e:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    800043a0:	4390                	lw	a2,0(a5)
    800043a2:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800043a4:	0791                	addi	a5,a5,4
    800043a6:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    800043a8:	fed79ce3          	bne	a5,a3,800043a0 <write_head+0x50>
  }
  bwrite(buf);
    800043ac:	8526                	mv	a0,s1
    800043ae:	fffff097          	auipc	ra,0xfffff
    800043b2:	096080e7          	jalr	150(ra) # 80003444 <bwrite>
  brelse(buf);
    800043b6:	8526                	mv	a0,s1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	0ca080e7          	jalr	202(ra) # 80003482 <brelse>
}
    800043c0:	60e2                	ld	ra,24(sp)
    800043c2:	6442                	ld	s0,16(sp)
    800043c4:	64a2                	ld	s1,8(sp)
    800043c6:	6902                	ld	s2,0(sp)
    800043c8:	6105                	addi	sp,sp,32
    800043ca:	8082                	ret

00000000800043cc <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043cc:	0001d797          	auipc	a5,0x1d
    800043d0:	ac07a783          	lw	a5,-1344(a5) # 80020e8c <log+0x2c>
    800043d4:	0af05d63          	blez	a5,8000448e <install_trans+0xc2>
{
    800043d8:	7139                	addi	sp,sp,-64
    800043da:	fc06                	sd	ra,56(sp)
    800043dc:	f822                	sd	s0,48(sp)
    800043de:	f426                	sd	s1,40(sp)
    800043e0:	f04a                	sd	s2,32(sp)
    800043e2:	ec4e                	sd	s3,24(sp)
    800043e4:	e852                	sd	s4,16(sp)
    800043e6:	e456                	sd	s5,8(sp)
    800043e8:	e05a                	sd	s6,0(sp)
    800043ea:	0080                	addi	s0,sp,64
    800043ec:	8b2a                	mv	s6,a0
    800043ee:	0001da97          	auipc	s5,0x1d
    800043f2:	aa2a8a93          	addi	s5,s5,-1374 # 80020e90 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800043f6:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800043f8:	0001d997          	auipc	s3,0x1d
    800043fc:	a6898993          	addi	s3,s3,-1432 # 80020e60 <log>
    80004400:	a00d                	j	80004422 <install_trans+0x56>
    brelse(lbuf);
    80004402:	854a                	mv	a0,s2
    80004404:	fffff097          	auipc	ra,0xfffff
    80004408:	07e080e7          	jalr	126(ra) # 80003482 <brelse>
    brelse(dbuf);
    8000440c:	8526                	mv	a0,s1
    8000440e:	fffff097          	auipc	ra,0xfffff
    80004412:	074080e7          	jalr	116(ra) # 80003482 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004416:	2a05                	addiw	s4,s4,1
    80004418:	0a91                	addi	s5,s5,4
    8000441a:	02c9a783          	lw	a5,44(s3)
    8000441e:	04fa5e63          	bge	s4,a5,8000447a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004422:	0189a583          	lw	a1,24(s3)
    80004426:	014585bb          	addw	a1,a1,s4
    8000442a:	2585                	addiw	a1,a1,1
    8000442c:	0289a503          	lw	a0,40(s3)
    80004430:	fffff097          	auipc	ra,0xfffff
    80004434:	f22080e7          	jalr	-222(ra) # 80003352 <bread>
    80004438:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000443a:	000aa583          	lw	a1,0(s5)
    8000443e:	0289a503          	lw	a0,40(s3)
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	f10080e7          	jalr	-240(ra) # 80003352 <bread>
    8000444a:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000444c:	40000613          	li	a2,1024
    80004450:	05890593          	addi	a1,s2,88
    80004454:	05850513          	addi	a0,a0,88
    80004458:	ffffd097          	auipc	ra,0xffffd
    8000445c:	8d6080e7          	jalr	-1834(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004460:	8526                	mv	a0,s1
    80004462:	fffff097          	auipc	ra,0xfffff
    80004466:	fe2080e7          	jalr	-30(ra) # 80003444 <bwrite>
    if(recovering == 0)
    8000446a:	f80b1ce3          	bnez	s6,80004402 <install_trans+0x36>
      bunpin(dbuf);
    8000446e:	8526                	mv	a0,s1
    80004470:	fffff097          	auipc	ra,0xfffff
    80004474:	0ec080e7          	jalr	236(ra) # 8000355c <bunpin>
    80004478:	b769                	j	80004402 <install_trans+0x36>
}
    8000447a:	70e2                	ld	ra,56(sp)
    8000447c:	7442                	ld	s0,48(sp)
    8000447e:	74a2                	ld	s1,40(sp)
    80004480:	7902                	ld	s2,32(sp)
    80004482:	69e2                	ld	s3,24(sp)
    80004484:	6a42                	ld	s4,16(sp)
    80004486:	6aa2                	ld	s5,8(sp)
    80004488:	6b02                	ld	s6,0(sp)
    8000448a:	6121                	addi	sp,sp,64
    8000448c:	8082                	ret
    8000448e:	8082                	ret

0000000080004490 <initlog>:
{
    80004490:	7179                	addi	sp,sp,-48
    80004492:	f406                	sd	ra,40(sp)
    80004494:	f022                	sd	s0,32(sp)
    80004496:	ec26                	sd	s1,24(sp)
    80004498:	e84a                	sd	s2,16(sp)
    8000449a:	e44e                	sd	s3,8(sp)
    8000449c:	1800                	addi	s0,sp,48
    8000449e:	892a                	mv	s2,a0
    800044a0:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044a2:	0001d497          	auipc	s1,0x1d
    800044a6:	9be48493          	addi	s1,s1,-1602 # 80020e60 <log>
    800044aa:	00004597          	auipc	a1,0x4
    800044ae:	26e58593          	addi	a1,a1,622 # 80008718 <syscalls+0x1f8>
    800044b2:	8526                	mv	a0,s1
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	692080e7          	jalr	1682(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    800044bc:	0149a583          	lw	a1,20(s3)
    800044c0:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044c2:	0109a783          	lw	a5,16(s3)
    800044c6:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044c8:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044cc:	854a                	mv	a0,s2
    800044ce:	fffff097          	auipc	ra,0xfffff
    800044d2:	e84080e7          	jalr	-380(ra) # 80003352 <bread>
  log.lh.n = lh->n;
    800044d6:	4d34                	lw	a3,88(a0)
    800044d8:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044da:	02d05663          	blez	a3,80004506 <initlog+0x76>
    800044de:	05c50793          	addi	a5,a0,92
    800044e2:	0001d717          	auipc	a4,0x1d
    800044e6:	9ae70713          	addi	a4,a4,-1618 # 80020e90 <log+0x30>
    800044ea:	36fd                	addiw	a3,a3,-1
    800044ec:	02069613          	slli	a2,a3,0x20
    800044f0:	01e65693          	srli	a3,a2,0x1e
    800044f4:	06050613          	addi	a2,a0,96
    800044f8:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800044fa:	4390                	lw	a2,0(a5)
    800044fc:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044fe:	0791                	addi	a5,a5,4
    80004500:	0711                	addi	a4,a4,4
    80004502:	fed79ce3          	bne	a5,a3,800044fa <initlog+0x6a>
  brelse(buf);
    80004506:	fffff097          	auipc	ra,0xfffff
    8000450a:	f7c080e7          	jalr	-132(ra) # 80003482 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000450e:	4505                	li	a0,1
    80004510:	00000097          	auipc	ra,0x0
    80004514:	ebc080e7          	jalr	-324(ra) # 800043cc <install_trans>
  log.lh.n = 0;
    80004518:	0001d797          	auipc	a5,0x1d
    8000451c:	9607aa23          	sw	zero,-1676(a5) # 80020e8c <log+0x2c>
  write_head(); // clear the log
    80004520:	00000097          	auipc	ra,0x0
    80004524:	e30080e7          	jalr	-464(ra) # 80004350 <write_head>
}
    80004528:	70a2                	ld	ra,40(sp)
    8000452a:	7402                	ld	s0,32(sp)
    8000452c:	64e2                	ld	s1,24(sp)
    8000452e:	6942                	ld	s2,16(sp)
    80004530:	69a2                	ld	s3,8(sp)
    80004532:	6145                	addi	sp,sp,48
    80004534:	8082                	ret

0000000080004536 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004536:	1101                	addi	sp,sp,-32
    80004538:	ec06                	sd	ra,24(sp)
    8000453a:	e822                	sd	s0,16(sp)
    8000453c:	e426                	sd	s1,8(sp)
    8000453e:	e04a                	sd	s2,0(sp)
    80004540:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004542:	0001d517          	auipc	a0,0x1d
    80004546:	91e50513          	addi	a0,a0,-1762 # 80020e60 <log>
    8000454a:	ffffc097          	auipc	ra,0xffffc
    8000454e:	68c080e7          	jalr	1676(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004552:	0001d497          	auipc	s1,0x1d
    80004556:	90e48493          	addi	s1,s1,-1778 # 80020e60 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000455a:	4979                	li	s2,30
    8000455c:	a039                	j	8000456a <begin_op+0x34>
      sleep(&log, &log.lock);
    8000455e:	85a6                	mv	a1,s1
    80004560:	8526                	mv	a0,s1
    80004562:	ffffe097          	auipc	ra,0xffffe
    80004566:	e3a080e7          	jalr	-454(ra) # 8000239c <sleep>
    if(log.committing){
    8000456a:	50dc                	lw	a5,36(s1)
    8000456c:	fbed                	bnez	a5,8000455e <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000456e:	5098                	lw	a4,32(s1)
    80004570:	2705                	addiw	a4,a4,1
    80004572:	0007069b          	sext.w	a3,a4
    80004576:	0027179b          	slliw	a5,a4,0x2
    8000457a:	9fb9                	addw	a5,a5,a4
    8000457c:	0017979b          	slliw	a5,a5,0x1
    80004580:	54d8                	lw	a4,44(s1)
    80004582:	9fb9                	addw	a5,a5,a4
    80004584:	00f95963          	bge	s2,a5,80004596 <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004588:	85a6                	mv	a1,s1
    8000458a:	8526                	mv	a0,s1
    8000458c:	ffffe097          	auipc	ra,0xffffe
    80004590:	e10080e7          	jalr	-496(ra) # 8000239c <sleep>
    80004594:	bfd9                	j	8000456a <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004596:	0001d517          	auipc	a0,0x1d
    8000459a:	8ca50513          	addi	a0,a0,-1846 # 80020e60 <log>
    8000459e:	d114                	sw	a3,32(a0)
      release(&log.lock);
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	6ea080e7          	jalr	1770(ra) # 80000c8a <release>
      break;
    }
  }
}
    800045a8:	60e2                	ld	ra,24(sp)
    800045aa:	6442                	ld	s0,16(sp)
    800045ac:	64a2                	ld	s1,8(sp)
    800045ae:	6902                	ld	s2,0(sp)
    800045b0:	6105                	addi	sp,sp,32
    800045b2:	8082                	ret

00000000800045b4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045b4:	7139                	addi	sp,sp,-64
    800045b6:	fc06                	sd	ra,56(sp)
    800045b8:	f822                	sd	s0,48(sp)
    800045ba:	f426                	sd	s1,40(sp)
    800045bc:	f04a                	sd	s2,32(sp)
    800045be:	ec4e                	sd	s3,24(sp)
    800045c0:	e852                	sd	s4,16(sp)
    800045c2:	e456                	sd	s5,8(sp)
    800045c4:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045c6:	0001d497          	auipc	s1,0x1d
    800045ca:	89a48493          	addi	s1,s1,-1894 # 80020e60 <log>
    800045ce:	8526                	mv	a0,s1
    800045d0:	ffffc097          	auipc	ra,0xffffc
    800045d4:	606080e7          	jalr	1542(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    800045d8:	509c                	lw	a5,32(s1)
    800045da:	37fd                	addiw	a5,a5,-1
    800045dc:	0007891b          	sext.w	s2,a5
    800045e0:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045e2:	50dc                	lw	a5,36(s1)
    800045e4:	e7b9                	bnez	a5,80004632 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045e6:	04091e63          	bnez	s2,80004642 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800045ea:	0001d497          	auipc	s1,0x1d
    800045ee:	87648493          	addi	s1,s1,-1930 # 80020e60 <log>
    800045f2:	4785                	li	a5,1
    800045f4:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045f6:	8526                	mv	a0,s1
    800045f8:	ffffc097          	auipc	ra,0xffffc
    800045fc:	692080e7          	jalr	1682(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004600:	54dc                	lw	a5,44(s1)
    80004602:	06f04763          	bgtz	a5,80004670 <end_op+0xbc>
    acquire(&log.lock);
    80004606:	0001d497          	auipc	s1,0x1d
    8000460a:	85a48493          	addi	s1,s1,-1958 # 80020e60 <log>
    8000460e:	8526                	mv	a0,s1
    80004610:	ffffc097          	auipc	ra,0xffffc
    80004614:	5c6080e7          	jalr	1478(ra) # 80000bd6 <acquire>
    log.committing = 0;
    80004618:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000461c:	8526                	mv	a0,s1
    8000461e:	ffffe097          	auipc	ra,0xffffe
    80004622:	de2080e7          	jalr	-542(ra) # 80002400 <wakeup>
    release(&log.lock);
    80004626:	8526                	mv	a0,s1
    80004628:	ffffc097          	auipc	ra,0xffffc
    8000462c:	662080e7          	jalr	1634(ra) # 80000c8a <release>
}
    80004630:	a03d                	j	8000465e <end_op+0xaa>
    panic("log.committing");
    80004632:	00004517          	auipc	a0,0x4
    80004636:	0ee50513          	addi	a0,a0,238 # 80008720 <syscalls+0x200>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	f06080e7          	jalr	-250(ra) # 80000540 <panic>
    wakeup(&log);
    80004642:	0001d497          	auipc	s1,0x1d
    80004646:	81e48493          	addi	s1,s1,-2018 # 80020e60 <log>
    8000464a:	8526                	mv	a0,s1
    8000464c:	ffffe097          	auipc	ra,0xffffe
    80004650:	db4080e7          	jalr	-588(ra) # 80002400 <wakeup>
  release(&log.lock);
    80004654:	8526                	mv	a0,s1
    80004656:	ffffc097          	auipc	ra,0xffffc
    8000465a:	634080e7          	jalr	1588(ra) # 80000c8a <release>
}
    8000465e:	70e2                	ld	ra,56(sp)
    80004660:	7442                	ld	s0,48(sp)
    80004662:	74a2                	ld	s1,40(sp)
    80004664:	7902                	ld	s2,32(sp)
    80004666:	69e2                	ld	s3,24(sp)
    80004668:	6a42                	ld	s4,16(sp)
    8000466a:	6aa2                	ld	s5,8(sp)
    8000466c:	6121                	addi	sp,sp,64
    8000466e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004670:	0001da97          	auipc	s5,0x1d
    80004674:	820a8a93          	addi	s5,s5,-2016 # 80020e90 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004678:	0001ca17          	auipc	s4,0x1c
    8000467c:	7e8a0a13          	addi	s4,s4,2024 # 80020e60 <log>
    80004680:	018a2583          	lw	a1,24(s4)
    80004684:	012585bb          	addw	a1,a1,s2
    80004688:	2585                	addiw	a1,a1,1
    8000468a:	028a2503          	lw	a0,40(s4)
    8000468e:	fffff097          	auipc	ra,0xfffff
    80004692:	cc4080e7          	jalr	-828(ra) # 80003352 <bread>
    80004696:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004698:	000aa583          	lw	a1,0(s5)
    8000469c:	028a2503          	lw	a0,40(s4)
    800046a0:	fffff097          	auipc	ra,0xfffff
    800046a4:	cb2080e7          	jalr	-846(ra) # 80003352 <bread>
    800046a8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046aa:	40000613          	li	a2,1024
    800046ae:	05850593          	addi	a1,a0,88
    800046b2:	05848513          	addi	a0,s1,88
    800046b6:	ffffc097          	auipc	ra,0xffffc
    800046ba:	678080e7          	jalr	1656(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    800046be:	8526                	mv	a0,s1
    800046c0:	fffff097          	auipc	ra,0xfffff
    800046c4:	d84080e7          	jalr	-636(ra) # 80003444 <bwrite>
    brelse(from);
    800046c8:	854e                	mv	a0,s3
    800046ca:	fffff097          	auipc	ra,0xfffff
    800046ce:	db8080e7          	jalr	-584(ra) # 80003482 <brelse>
    brelse(to);
    800046d2:	8526                	mv	a0,s1
    800046d4:	fffff097          	auipc	ra,0xfffff
    800046d8:	dae080e7          	jalr	-594(ra) # 80003482 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046dc:	2905                	addiw	s2,s2,1
    800046de:	0a91                	addi	s5,s5,4
    800046e0:	02ca2783          	lw	a5,44(s4)
    800046e4:	f8f94ee3          	blt	s2,a5,80004680 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046e8:	00000097          	auipc	ra,0x0
    800046ec:	c68080e7          	jalr	-920(ra) # 80004350 <write_head>
    install_trans(0); // Now install writes to home locations
    800046f0:	4501                	li	a0,0
    800046f2:	00000097          	auipc	ra,0x0
    800046f6:	cda080e7          	jalr	-806(ra) # 800043cc <install_trans>
    log.lh.n = 0;
    800046fa:	0001c797          	auipc	a5,0x1c
    800046fe:	7807a923          	sw	zero,1938(a5) # 80020e8c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004702:	00000097          	auipc	ra,0x0
    80004706:	c4e080e7          	jalr	-946(ra) # 80004350 <write_head>
    8000470a:	bdf5                	j	80004606 <end_op+0x52>

000000008000470c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000470c:	1101                	addi	sp,sp,-32
    8000470e:	ec06                	sd	ra,24(sp)
    80004710:	e822                	sd	s0,16(sp)
    80004712:	e426                	sd	s1,8(sp)
    80004714:	e04a                	sd	s2,0(sp)
    80004716:	1000                	addi	s0,sp,32
    80004718:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000471a:	0001c917          	auipc	s2,0x1c
    8000471e:	74690913          	addi	s2,s2,1862 # 80020e60 <log>
    80004722:	854a                	mv	a0,s2
    80004724:	ffffc097          	auipc	ra,0xffffc
    80004728:	4b2080e7          	jalr	1202(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000472c:	02c92603          	lw	a2,44(s2)
    80004730:	47f5                	li	a5,29
    80004732:	06c7c563          	blt	a5,a2,8000479c <log_write+0x90>
    80004736:	0001c797          	auipc	a5,0x1c
    8000473a:	7467a783          	lw	a5,1862(a5) # 80020e7c <log+0x1c>
    8000473e:	37fd                	addiw	a5,a5,-1
    80004740:	04f65e63          	bge	a2,a5,8000479c <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004744:	0001c797          	auipc	a5,0x1c
    80004748:	73c7a783          	lw	a5,1852(a5) # 80020e80 <log+0x20>
    8000474c:	06f05063          	blez	a5,800047ac <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004750:	4781                	li	a5,0
    80004752:	06c05563          	blez	a2,800047bc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004756:	44cc                	lw	a1,12(s1)
    80004758:	0001c717          	auipc	a4,0x1c
    8000475c:	73870713          	addi	a4,a4,1848 # 80020e90 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004760:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004762:	4314                	lw	a3,0(a4)
    80004764:	04b68c63          	beq	a3,a1,800047bc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004768:	2785                	addiw	a5,a5,1
    8000476a:	0711                	addi	a4,a4,4
    8000476c:	fef61be3          	bne	a2,a5,80004762 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004770:	0621                	addi	a2,a2,8
    80004772:	060a                	slli	a2,a2,0x2
    80004774:	0001c797          	auipc	a5,0x1c
    80004778:	6ec78793          	addi	a5,a5,1772 # 80020e60 <log>
    8000477c:	97b2                	add	a5,a5,a2
    8000477e:	44d8                	lw	a4,12(s1)
    80004780:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004782:	8526                	mv	a0,s1
    80004784:	fffff097          	auipc	ra,0xfffff
    80004788:	d9c080e7          	jalr	-612(ra) # 80003520 <bpin>
    log.lh.n++;
    8000478c:	0001c717          	auipc	a4,0x1c
    80004790:	6d470713          	addi	a4,a4,1748 # 80020e60 <log>
    80004794:	575c                	lw	a5,44(a4)
    80004796:	2785                	addiw	a5,a5,1
    80004798:	d75c                	sw	a5,44(a4)
    8000479a:	a82d                	j	800047d4 <log_write+0xc8>
    panic("too big a transaction");
    8000479c:	00004517          	auipc	a0,0x4
    800047a0:	f9450513          	addi	a0,a0,-108 # 80008730 <syscalls+0x210>
    800047a4:	ffffc097          	auipc	ra,0xffffc
    800047a8:	d9c080e7          	jalr	-612(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    800047ac:	00004517          	auipc	a0,0x4
    800047b0:	f9c50513          	addi	a0,a0,-100 # 80008748 <syscalls+0x228>
    800047b4:	ffffc097          	auipc	ra,0xffffc
    800047b8:	d8c080e7          	jalr	-628(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    800047bc:	00878693          	addi	a3,a5,8
    800047c0:	068a                	slli	a3,a3,0x2
    800047c2:	0001c717          	auipc	a4,0x1c
    800047c6:	69e70713          	addi	a4,a4,1694 # 80020e60 <log>
    800047ca:	9736                	add	a4,a4,a3
    800047cc:	44d4                	lw	a3,12(s1)
    800047ce:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047d0:	faf609e3          	beq	a2,a5,80004782 <log_write+0x76>
  }
  release(&log.lock);
    800047d4:	0001c517          	auipc	a0,0x1c
    800047d8:	68c50513          	addi	a0,a0,1676 # 80020e60 <log>
    800047dc:	ffffc097          	auipc	ra,0xffffc
    800047e0:	4ae080e7          	jalr	1198(ra) # 80000c8a <release>
}
    800047e4:	60e2                	ld	ra,24(sp)
    800047e6:	6442                	ld	s0,16(sp)
    800047e8:	64a2                	ld	s1,8(sp)
    800047ea:	6902                	ld	s2,0(sp)
    800047ec:	6105                	addi	sp,sp,32
    800047ee:	8082                	ret

00000000800047f0 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047f0:	1101                	addi	sp,sp,-32
    800047f2:	ec06                	sd	ra,24(sp)
    800047f4:	e822                	sd	s0,16(sp)
    800047f6:	e426                	sd	s1,8(sp)
    800047f8:	e04a                	sd	s2,0(sp)
    800047fa:	1000                	addi	s0,sp,32
    800047fc:	84aa                	mv	s1,a0
    800047fe:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004800:	00004597          	auipc	a1,0x4
    80004804:	f6858593          	addi	a1,a1,-152 # 80008768 <syscalls+0x248>
    80004808:	0521                	addi	a0,a0,8
    8000480a:	ffffc097          	auipc	ra,0xffffc
    8000480e:	33c080e7          	jalr	828(ra) # 80000b46 <initlock>
  lk->name = name;
    80004812:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004816:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000481a:	0204a423          	sw	zero,40(s1)
}
    8000481e:	60e2                	ld	ra,24(sp)
    80004820:	6442                	ld	s0,16(sp)
    80004822:	64a2                	ld	s1,8(sp)
    80004824:	6902                	ld	s2,0(sp)
    80004826:	6105                	addi	sp,sp,32
    80004828:	8082                	ret

000000008000482a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000482a:	1101                	addi	sp,sp,-32
    8000482c:	ec06                	sd	ra,24(sp)
    8000482e:	e822                	sd	s0,16(sp)
    80004830:	e426                	sd	s1,8(sp)
    80004832:	e04a                	sd	s2,0(sp)
    80004834:	1000                	addi	s0,sp,32
    80004836:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004838:	00850913          	addi	s2,a0,8
    8000483c:	854a                	mv	a0,s2
    8000483e:	ffffc097          	auipc	ra,0xffffc
    80004842:	398080e7          	jalr	920(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    80004846:	409c                	lw	a5,0(s1)
    80004848:	cb89                	beqz	a5,8000485a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000484a:	85ca                	mv	a1,s2
    8000484c:	8526                	mv	a0,s1
    8000484e:	ffffe097          	auipc	ra,0xffffe
    80004852:	b4e080e7          	jalr	-1202(ra) # 8000239c <sleep>
  while (lk->locked) {
    80004856:	409c                	lw	a5,0(s1)
    80004858:	fbed                	bnez	a5,8000484a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000485a:	4785                	li	a5,1
    8000485c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000485e:	ffffd097          	auipc	ra,0xffffd
    80004862:	390080e7          	jalr	912(ra) # 80001bee <myproc>
    80004866:	5d1c                	lw	a5,56(a0)
    80004868:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000486a:	854a                	mv	a0,s2
    8000486c:	ffffc097          	auipc	ra,0xffffc
    80004870:	41e080e7          	jalr	1054(ra) # 80000c8a <release>
}
    80004874:	60e2                	ld	ra,24(sp)
    80004876:	6442                	ld	s0,16(sp)
    80004878:	64a2                	ld	s1,8(sp)
    8000487a:	6902                	ld	s2,0(sp)
    8000487c:	6105                	addi	sp,sp,32
    8000487e:	8082                	ret

0000000080004880 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004880:	1101                	addi	sp,sp,-32
    80004882:	ec06                	sd	ra,24(sp)
    80004884:	e822                	sd	s0,16(sp)
    80004886:	e426                	sd	s1,8(sp)
    80004888:	e04a                	sd	s2,0(sp)
    8000488a:	1000                	addi	s0,sp,32
    8000488c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000488e:	00850913          	addi	s2,a0,8
    80004892:	854a                	mv	a0,s2
    80004894:	ffffc097          	auipc	ra,0xffffc
    80004898:	342080e7          	jalr	834(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    8000489c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800048a0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800048a4:	8526                	mv	a0,s1
    800048a6:	ffffe097          	auipc	ra,0xffffe
    800048aa:	b5a080e7          	jalr	-1190(ra) # 80002400 <wakeup>
  release(&lk->lk);
    800048ae:	854a                	mv	a0,s2
    800048b0:	ffffc097          	auipc	ra,0xffffc
    800048b4:	3da080e7          	jalr	986(ra) # 80000c8a <release>
}
    800048b8:	60e2                	ld	ra,24(sp)
    800048ba:	6442                	ld	s0,16(sp)
    800048bc:	64a2                	ld	s1,8(sp)
    800048be:	6902                	ld	s2,0(sp)
    800048c0:	6105                	addi	sp,sp,32
    800048c2:	8082                	ret

00000000800048c4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048c4:	7179                	addi	sp,sp,-48
    800048c6:	f406                	sd	ra,40(sp)
    800048c8:	f022                	sd	s0,32(sp)
    800048ca:	ec26                	sd	s1,24(sp)
    800048cc:	e84a                	sd	s2,16(sp)
    800048ce:	e44e                	sd	s3,8(sp)
    800048d0:	1800                	addi	s0,sp,48
    800048d2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048d4:	00850913          	addi	s2,a0,8
    800048d8:	854a                	mv	a0,s2
    800048da:	ffffc097          	auipc	ra,0xffffc
    800048de:	2fc080e7          	jalr	764(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048e2:	409c                	lw	a5,0(s1)
    800048e4:	ef99                	bnez	a5,80004902 <holdingsleep+0x3e>
    800048e6:	4481                	li	s1,0
  release(&lk->lk);
    800048e8:	854a                	mv	a0,s2
    800048ea:	ffffc097          	auipc	ra,0xffffc
    800048ee:	3a0080e7          	jalr	928(ra) # 80000c8a <release>
  return r;
}
    800048f2:	8526                	mv	a0,s1
    800048f4:	70a2                	ld	ra,40(sp)
    800048f6:	7402                	ld	s0,32(sp)
    800048f8:	64e2                	ld	s1,24(sp)
    800048fa:	6942                	ld	s2,16(sp)
    800048fc:	69a2                	ld	s3,8(sp)
    800048fe:	6145                	addi	sp,sp,48
    80004900:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004902:	0284a983          	lw	s3,40(s1)
    80004906:	ffffd097          	auipc	ra,0xffffd
    8000490a:	2e8080e7          	jalr	744(ra) # 80001bee <myproc>
    8000490e:	5d04                	lw	s1,56(a0)
    80004910:	413484b3          	sub	s1,s1,s3
    80004914:	0014b493          	seqz	s1,s1
    80004918:	bfc1                	j	800048e8 <holdingsleep+0x24>

000000008000491a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000491a:	1141                	addi	sp,sp,-16
    8000491c:	e406                	sd	ra,8(sp)
    8000491e:	e022                	sd	s0,0(sp)
    80004920:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004922:	00004597          	auipc	a1,0x4
    80004926:	e5658593          	addi	a1,a1,-426 # 80008778 <syscalls+0x258>
    8000492a:	0001c517          	auipc	a0,0x1c
    8000492e:	67e50513          	addi	a0,a0,1662 # 80020fa8 <ftable>
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	214080e7          	jalr	532(ra) # 80000b46 <initlock>
}
    8000493a:	60a2                	ld	ra,8(sp)
    8000493c:	6402                	ld	s0,0(sp)
    8000493e:	0141                	addi	sp,sp,16
    80004940:	8082                	ret

0000000080004942 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004942:	1101                	addi	sp,sp,-32
    80004944:	ec06                	sd	ra,24(sp)
    80004946:	e822                	sd	s0,16(sp)
    80004948:	e426                	sd	s1,8(sp)
    8000494a:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000494c:	0001c517          	auipc	a0,0x1c
    80004950:	65c50513          	addi	a0,a0,1628 # 80020fa8 <ftable>
    80004954:	ffffc097          	auipc	ra,0xffffc
    80004958:	282080e7          	jalr	642(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000495c:	0001c497          	auipc	s1,0x1c
    80004960:	66448493          	addi	s1,s1,1636 # 80020fc0 <ftable+0x18>
    80004964:	0001d717          	auipc	a4,0x1d
    80004968:	5fc70713          	addi	a4,a4,1532 # 80021f60 <disk>
    if(f->ref == 0){
    8000496c:	40dc                	lw	a5,4(s1)
    8000496e:	cf99                	beqz	a5,8000498c <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004970:	02848493          	addi	s1,s1,40
    80004974:	fee49ce3          	bne	s1,a4,8000496c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004978:	0001c517          	auipc	a0,0x1c
    8000497c:	63050513          	addi	a0,a0,1584 # 80020fa8 <ftable>
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	30a080e7          	jalr	778(ra) # 80000c8a <release>
  return 0;
    80004988:	4481                	li	s1,0
    8000498a:	a819                	j	800049a0 <filealloc+0x5e>
      f->ref = 1;
    8000498c:	4785                	li	a5,1
    8000498e:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004990:	0001c517          	auipc	a0,0x1c
    80004994:	61850513          	addi	a0,a0,1560 # 80020fa8 <ftable>
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	2f2080e7          	jalr	754(ra) # 80000c8a <release>
}
    800049a0:	8526                	mv	a0,s1
    800049a2:	60e2                	ld	ra,24(sp)
    800049a4:	6442                	ld	s0,16(sp)
    800049a6:	64a2                	ld	s1,8(sp)
    800049a8:	6105                	addi	sp,sp,32
    800049aa:	8082                	ret

00000000800049ac <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049ac:	1101                	addi	sp,sp,-32
    800049ae:	ec06                	sd	ra,24(sp)
    800049b0:	e822                	sd	s0,16(sp)
    800049b2:	e426                	sd	s1,8(sp)
    800049b4:	1000                	addi	s0,sp,32
    800049b6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049b8:	0001c517          	auipc	a0,0x1c
    800049bc:	5f050513          	addi	a0,a0,1520 # 80020fa8 <ftable>
    800049c0:	ffffc097          	auipc	ra,0xffffc
    800049c4:	216080e7          	jalr	534(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800049c8:	40dc                	lw	a5,4(s1)
    800049ca:	02f05263          	blez	a5,800049ee <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049ce:	2785                	addiw	a5,a5,1
    800049d0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049d2:	0001c517          	auipc	a0,0x1c
    800049d6:	5d650513          	addi	a0,a0,1494 # 80020fa8 <ftable>
    800049da:	ffffc097          	auipc	ra,0xffffc
    800049de:	2b0080e7          	jalr	688(ra) # 80000c8a <release>
  return f;
}
    800049e2:	8526                	mv	a0,s1
    800049e4:	60e2                	ld	ra,24(sp)
    800049e6:	6442                	ld	s0,16(sp)
    800049e8:	64a2                	ld	s1,8(sp)
    800049ea:	6105                	addi	sp,sp,32
    800049ec:	8082                	ret
    panic("filedup");
    800049ee:	00004517          	auipc	a0,0x4
    800049f2:	d9250513          	addi	a0,a0,-622 # 80008780 <syscalls+0x260>
    800049f6:	ffffc097          	auipc	ra,0xffffc
    800049fa:	b4a080e7          	jalr	-1206(ra) # 80000540 <panic>

00000000800049fe <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049fe:	7139                	addi	sp,sp,-64
    80004a00:	fc06                	sd	ra,56(sp)
    80004a02:	f822                	sd	s0,48(sp)
    80004a04:	f426                	sd	s1,40(sp)
    80004a06:	f04a                	sd	s2,32(sp)
    80004a08:	ec4e                	sd	s3,24(sp)
    80004a0a:	e852                	sd	s4,16(sp)
    80004a0c:	e456                	sd	s5,8(sp)
    80004a0e:	0080                	addi	s0,sp,64
    80004a10:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a12:	0001c517          	auipc	a0,0x1c
    80004a16:	59650513          	addi	a0,a0,1430 # 80020fa8 <ftable>
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	1bc080e7          	jalr	444(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    80004a22:	40dc                	lw	a5,4(s1)
    80004a24:	06f05163          	blez	a5,80004a86 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a28:	37fd                	addiw	a5,a5,-1
    80004a2a:	0007871b          	sext.w	a4,a5
    80004a2e:	c0dc                	sw	a5,4(s1)
    80004a30:	06e04363          	bgtz	a4,80004a96 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a34:	0004a903          	lw	s2,0(s1)
    80004a38:	0094ca83          	lbu	s5,9(s1)
    80004a3c:	0104ba03          	ld	s4,16(s1)
    80004a40:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a44:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a48:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a4c:	0001c517          	auipc	a0,0x1c
    80004a50:	55c50513          	addi	a0,a0,1372 # 80020fa8 <ftable>
    80004a54:	ffffc097          	auipc	ra,0xffffc
    80004a58:	236080e7          	jalr	566(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004a5c:	4785                	li	a5,1
    80004a5e:	04f90d63          	beq	s2,a5,80004ab8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a62:	3979                	addiw	s2,s2,-2
    80004a64:	4785                	li	a5,1
    80004a66:	0527e063          	bltu	a5,s2,80004aa6 <fileclose+0xa8>
    begin_op();
    80004a6a:	00000097          	auipc	ra,0x0
    80004a6e:	acc080e7          	jalr	-1332(ra) # 80004536 <begin_op>
    iput(ff.ip);
    80004a72:	854e                	mv	a0,s3
    80004a74:	fffff097          	auipc	ra,0xfffff
    80004a78:	2b0080e7          	jalr	688(ra) # 80003d24 <iput>
    end_op();
    80004a7c:	00000097          	auipc	ra,0x0
    80004a80:	b38080e7          	jalr	-1224(ra) # 800045b4 <end_op>
    80004a84:	a00d                	j	80004aa6 <fileclose+0xa8>
    panic("fileclose");
    80004a86:	00004517          	auipc	a0,0x4
    80004a8a:	d0250513          	addi	a0,a0,-766 # 80008788 <syscalls+0x268>
    80004a8e:	ffffc097          	auipc	ra,0xffffc
    80004a92:	ab2080e7          	jalr	-1358(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004a96:	0001c517          	auipc	a0,0x1c
    80004a9a:	51250513          	addi	a0,a0,1298 # 80020fa8 <ftable>
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	1ec080e7          	jalr	492(ra) # 80000c8a <release>
  }
}
    80004aa6:	70e2                	ld	ra,56(sp)
    80004aa8:	7442                	ld	s0,48(sp)
    80004aaa:	74a2                	ld	s1,40(sp)
    80004aac:	7902                	ld	s2,32(sp)
    80004aae:	69e2                	ld	s3,24(sp)
    80004ab0:	6a42                	ld	s4,16(sp)
    80004ab2:	6aa2                	ld	s5,8(sp)
    80004ab4:	6121                	addi	sp,sp,64
    80004ab6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ab8:	85d6                	mv	a1,s5
    80004aba:	8552                	mv	a0,s4
    80004abc:	00000097          	auipc	ra,0x0
    80004ac0:	34c080e7          	jalr	844(ra) # 80004e08 <pipeclose>
    80004ac4:	b7cd                	j	80004aa6 <fileclose+0xa8>

0000000080004ac6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ac6:	715d                	addi	sp,sp,-80
    80004ac8:	e486                	sd	ra,72(sp)
    80004aca:	e0a2                	sd	s0,64(sp)
    80004acc:	fc26                	sd	s1,56(sp)
    80004ace:	f84a                	sd	s2,48(sp)
    80004ad0:	f44e                	sd	s3,40(sp)
    80004ad2:	0880                	addi	s0,sp,80
    80004ad4:	84aa                	mv	s1,a0
    80004ad6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ad8:	ffffd097          	auipc	ra,0xffffd
    80004adc:	116080e7          	jalr	278(ra) # 80001bee <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ae0:	409c                	lw	a5,0(s1)
    80004ae2:	37f9                	addiw	a5,a5,-2
    80004ae4:	4705                	li	a4,1
    80004ae6:	04f76763          	bltu	a4,a5,80004b34 <filestat+0x6e>
    80004aea:	892a                	mv	s2,a0
    ilock(f->ip);
    80004aec:	6c88                	ld	a0,24(s1)
    80004aee:	fffff097          	auipc	ra,0xfffff
    80004af2:	07c080e7          	jalr	124(ra) # 80003b6a <ilock>
    stati(f->ip, &st);
    80004af6:	fb840593          	addi	a1,s0,-72
    80004afa:	6c88                	ld	a0,24(s1)
    80004afc:	fffff097          	auipc	ra,0xfffff
    80004b00:	2f8080e7          	jalr	760(ra) # 80003df4 <stati>
    iunlock(f->ip);
    80004b04:	6c88                	ld	a0,24(s1)
    80004b06:	fffff097          	auipc	ra,0xfffff
    80004b0a:	126080e7          	jalr	294(ra) # 80003c2c <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b0e:	46e1                	li	a3,24
    80004b10:	fb840613          	addi	a2,s0,-72
    80004b14:	85ce                	mv	a1,s3
    80004b16:	05893503          	ld	a0,88(s2)
    80004b1a:	ffffd097          	auipc	ra,0xffffd
    80004b1e:	b52080e7          	jalr	-1198(ra) # 8000166c <copyout>
    80004b22:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b26:	60a6                	ld	ra,72(sp)
    80004b28:	6406                	ld	s0,64(sp)
    80004b2a:	74e2                	ld	s1,56(sp)
    80004b2c:	7942                	ld	s2,48(sp)
    80004b2e:	79a2                	ld	s3,40(sp)
    80004b30:	6161                	addi	sp,sp,80
    80004b32:	8082                	ret
  return -1;
    80004b34:	557d                	li	a0,-1
    80004b36:	bfc5                	j	80004b26 <filestat+0x60>

0000000080004b38 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b38:	7179                	addi	sp,sp,-48
    80004b3a:	f406                	sd	ra,40(sp)
    80004b3c:	f022                	sd	s0,32(sp)
    80004b3e:	ec26                	sd	s1,24(sp)
    80004b40:	e84a                	sd	s2,16(sp)
    80004b42:	e44e                	sd	s3,8(sp)
    80004b44:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b46:	00854783          	lbu	a5,8(a0)
    80004b4a:	c3d5                	beqz	a5,80004bee <fileread+0xb6>
    80004b4c:	84aa                	mv	s1,a0
    80004b4e:	89ae                	mv	s3,a1
    80004b50:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b52:	411c                	lw	a5,0(a0)
    80004b54:	4705                	li	a4,1
    80004b56:	04e78963          	beq	a5,a4,80004ba8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b5a:	470d                	li	a4,3
    80004b5c:	04e78d63          	beq	a5,a4,80004bb6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b60:	4709                	li	a4,2
    80004b62:	06e79e63          	bne	a5,a4,80004bde <fileread+0xa6>
    ilock(f->ip);
    80004b66:	6d08                	ld	a0,24(a0)
    80004b68:	fffff097          	auipc	ra,0xfffff
    80004b6c:	002080e7          	jalr	2(ra) # 80003b6a <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b70:	874a                	mv	a4,s2
    80004b72:	5094                	lw	a3,32(s1)
    80004b74:	864e                	mv	a2,s3
    80004b76:	4585                	li	a1,1
    80004b78:	6c88                	ld	a0,24(s1)
    80004b7a:	fffff097          	auipc	ra,0xfffff
    80004b7e:	2a4080e7          	jalr	676(ra) # 80003e1e <readi>
    80004b82:	892a                	mv	s2,a0
    80004b84:	00a05563          	blez	a0,80004b8e <fileread+0x56>
      f->off += r;
    80004b88:	509c                	lw	a5,32(s1)
    80004b8a:	9fa9                	addw	a5,a5,a0
    80004b8c:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b8e:	6c88                	ld	a0,24(s1)
    80004b90:	fffff097          	auipc	ra,0xfffff
    80004b94:	09c080e7          	jalr	156(ra) # 80003c2c <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b98:	854a                	mv	a0,s2
    80004b9a:	70a2                	ld	ra,40(sp)
    80004b9c:	7402                	ld	s0,32(sp)
    80004b9e:	64e2                	ld	s1,24(sp)
    80004ba0:	6942                	ld	s2,16(sp)
    80004ba2:	69a2                	ld	s3,8(sp)
    80004ba4:	6145                	addi	sp,sp,48
    80004ba6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ba8:	6908                	ld	a0,16(a0)
    80004baa:	00000097          	auipc	ra,0x0
    80004bae:	3c6080e7          	jalr	966(ra) # 80004f70 <piperead>
    80004bb2:	892a                	mv	s2,a0
    80004bb4:	b7d5                	j	80004b98 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bb6:	02451783          	lh	a5,36(a0)
    80004bba:	03079693          	slli	a3,a5,0x30
    80004bbe:	92c1                	srli	a3,a3,0x30
    80004bc0:	4725                	li	a4,9
    80004bc2:	02d76863          	bltu	a4,a3,80004bf2 <fileread+0xba>
    80004bc6:	0792                	slli	a5,a5,0x4
    80004bc8:	0001c717          	auipc	a4,0x1c
    80004bcc:	34070713          	addi	a4,a4,832 # 80020f08 <devsw>
    80004bd0:	97ba                	add	a5,a5,a4
    80004bd2:	639c                	ld	a5,0(a5)
    80004bd4:	c38d                	beqz	a5,80004bf6 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bd6:	4505                	li	a0,1
    80004bd8:	9782                	jalr	a5
    80004bda:	892a                	mv	s2,a0
    80004bdc:	bf75                	j	80004b98 <fileread+0x60>
    panic("fileread");
    80004bde:	00004517          	auipc	a0,0x4
    80004be2:	bba50513          	addi	a0,a0,-1094 # 80008798 <syscalls+0x278>
    80004be6:	ffffc097          	auipc	ra,0xffffc
    80004bea:	95a080e7          	jalr	-1702(ra) # 80000540 <panic>
    return -1;
    80004bee:	597d                	li	s2,-1
    80004bf0:	b765                	j	80004b98 <fileread+0x60>
      return -1;
    80004bf2:	597d                	li	s2,-1
    80004bf4:	b755                	j	80004b98 <fileread+0x60>
    80004bf6:	597d                	li	s2,-1
    80004bf8:	b745                	j	80004b98 <fileread+0x60>

0000000080004bfa <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004bfa:	715d                	addi	sp,sp,-80
    80004bfc:	e486                	sd	ra,72(sp)
    80004bfe:	e0a2                	sd	s0,64(sp)
    80004c00:	fc26                	sd	s1,56(sp)
    80004c02:	f84a                	sd	s2,48(sp)
    80004c04:	f44e                	sd	s3,40(sp)
    80004c06:	f052                	sd	s4,32(sp)
    80004c08:	ec56                	sd	s5,24(sp)
    80004c0a:	e85a                	sd	s6,16(sp)
    80004c0c:	e45e                	sd	s7,8(sp)
    80004c0e:	e062                	sd	s8,0(sp)
    80004c10:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004c12:	00954783          	lbu	a5,9(a0)
    80004c16:	10078663          	beqz	a5,80004d22 <filewrite+0x128>
    80004c1a:	892a                	mv	s2,a0
    80004c1c:	8b2e                	mv	s6,a1
    80004c1e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c20:	411c                	lw	a5,0(a0)
    80004c22:	4705                	li	a4,1
    80004c24:	02e78263          	beq	a5,a4,80004c48 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c28:	470d                	li	a4,3
    80004c2a:	02e78663          	beq	a5,a4,80004c56 <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c2e:	4709                	li	a4,2
    80004c30:	0ee79163          	bne	a5,a4,80004d12 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c34:	0ac05d63          	blez	a2,80004cee <filewrite+0xf4>
    int i = 0;
    80004c38:	4981                	li	s3,0
    80004c3a:	6b85                	lui	s7,0x1
    80004c3c:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c40:	6c05                	lui	s8,0x1
    80004c42:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c46:	a861                	j	80004cde <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004c48:	6908                	ld	a0,16(a0)
    80004c4a:	00000097          	auipc	ra,0x0
    80004c4e:	22e080e7          	jalr	558(ra) # 80004e78 <pipewrite>
    80004c52:	8a2a                	mv	s4,a0
    80004c54:	a045                	j	80004cf4 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c56:	02451783          	lh	a5,36(a0)
    80004c5a:	03079693          	slli	a3,a5,0x30
    80004c5e:	92c1                	srli	a3,a3,0x30
    80004c60:	4725                	li	a4,9
    80004c62:	0cd76263          	bltu	a4,a3,80004d26 <filewrite+0x12c>
    80004c66:	0792                	slli	a5,a5,0x4
    80004c68:	0001c717          	auipc	a4,0x1c
    80004c6c:	2a070713          	addi	a4,a4,672 # 80020f08 <devsw>
    80004c70:	97ba                	add	a5,a5,a4
    80004c72:	679c                	ld	a5,8(a5)
    80004c74:	cbdd                	beqz	a5,80004d2a <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004c76:	4505                	li	a0,1
    80004c78:	9782                	jalr	a5
    80004c7a:	8a2a                	mv	s4,a0
    80004c7c:	a8a5                	j	80004cf4 <filewrite+0xfa>
    80004c7e:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004c82:	00000097          	auipc	ra,0x0
    80004c86:	8b4080e7          	jalr	-1868(ra) # 80004536 <begin_op>
      ilock(f->ip);
    80004c8a:	01893503          	ld	a0,24(s2)
    80004c8e:	fffff097          	auipc	ra,0xfffff
    80004c92:	edc080e7          	jalr	-292(ra) # 80003b6a <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c96:	8756                	mv	a4,s5
    80004c98:	02092683          	lw	a3,32(s2)
    80004c9c:	01698633          	add	a2,s3,s6
    80004ca0:	4585                	li	a1,1
    80004ca2:	01893503          	ld	a0,24(s2)
    80004ca6:	fffff097          	auipc	ra,0xfffff
    80004caa:	270080e7          	jalr	624(ra) # 80003f16 <writei>
    80004cae:	84aa                	mv	s1,a0
    80004cb0:	00a05763          	blez	a0,80004cbe <filewrite+0xc4>
        f->off += r;
    80004cb4:	02092783          	lw	a5,32(s2)
    80004cb8:	9fa9                	addw	a5,a5,a0
    80004cba:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cbe:	01893503          	ld	a0,24(s2)
    80004cc2:	fffff097          	auipc	ra,0xfffff
    80004cc6:	f6a080e7          	jalr	-150(ra) # 80003c2c <iunlock>
      end_op();
    80004cca:	00000097          	auipc	ra,0x0
    80004cce:	8ea080e7          	jalr	-1814(ra) # 800045b4 <end_op>

      if(r != n1){
    80004cd2:	009a9f63          	bne	s5,s1,80004cf0 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004cd6:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004cda:	0149db63          	bge	s3,s4,80004cf0 <filewrite+0xf6>
      int n1 = n - i;
    80004cde:	413a04bb          	subw	s1,s4,s3
    80004ce2:	0004879b          	sext.w	a5,s1
    80004ce6:	f8fbdce3          	bge	s7,a5,80004c7e <filewrite+0x84>
    80004cea:	84e2                	mv	s1,s8
    80004cec:	bf49                	j	80004c7e <filewrite+0x84>
    int i = 0;
    80004cee:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004cf0:	013a1f63          	bne	s4,s3,80004d0e <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cf4:	8552                	mv	a0,s4
    80004cf6:	60a6                	ld	ra,72(sp)
    80004cf8:	6406                	ld	s0,64(sp)
    80004cfa:	74e2                	ld	s1,56(sp)
    80004cfc:	7942                	ld	s2,48(sp)
    80004cfe:	79a2                	ld	s3,40(sp)
    80004d00:	7a02                	ld	s4,32(sp)
    80004d02:	6ae2                	ld	s5,24(sp)
    80004d04:	6b42                	ld	s6,16(sp)
    80004d06:	6ba2                	ld	s7,8(sp)
    80004d08:	6c02                	ld	s8,0(sp)
    80004d0a:	6161                	addi	sp,sp,80
    80004d0c:	8082                	ret
    ret = (i == n ? n : -1);
    80004d0e:	5a7d                	li	s4,-1
    80004d10:	b7d5                	j	80004cf4 <filewrite+0xfa>
    panic("filewrite");
    80004d12:	00004517          	auipc	a0,0x4
    80004d16:	a9650513          	addi	a0,a0,-1386 # 800087a8 <syscalls+0x288>
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	826080e7          	jalr	-2010(ra) # 80000540 <panic>
    return -1;
    80004d22:	5a7d                	li	s4,-1
    80004d24:	bfc1                	j	80004cf4 <filewrite+0xfa>
      return -1;
    80004d26:	5a7d                	li	s4,-1
    80004d28:	b7f1                	j	80004cf4 <filewrite+0xfa>
    80004d2a:	5a7d                	li	s4,-1
    80004d2c:	b7e1                	j	80004cf4 <filewrite+0xfa>

0000000080004d2e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d2e:	7179                	addi	sp,sp,-48
    80004d30:	f406                	sd	ra,40(sp)
    80004d32:	f022                	sd	s0,32(sp)
    80004d34:	ec26                	sd	s1,24(sp)
    80004d36:	e84a                	sd	s2,16(sp)
    80004d38:	e44e                	sd	s3,8(sp)
    80004d3a:	e052                	sd	s4,0(sp)
    80004d3c:	1800                	addi	s0,sp,48
    80004d3e:	84aa                	mv	s1,a0
    80004d40:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d42:	0005b023          	sd	zero,0(a1)
    80004d46:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d4a:	00000097          	auipc	ra,0x0
    80004d4e:	bf8080e7          	jalr	-1032(ra) # 80004942 <filealloc>
    80004d52:	e088                	sd	a0,0(s1)
    80004d54:	c551                	beqz	a0,80004de0 <pipealloc+0xb2>
    80004d56:	00000097          	auipc	ra,0x0
    80004d5a:	bec080e7          	jalr	-1044(ra) # 80004942 <filealloc>
    80004d5e:	00aa3023          	sd	a0,0(s4)
    80004d62:	c92d                	beqz	a0,80004dd4 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d64:	ffffc097          	auipc	ra,0xffffc
    80004d68:	d82080e7          	jalr	-638(ra) # 80000ae6 <kalloc>
    80004d6c:	892a                	mv	s2,a0
    80004d6e:	c125                	beqz	a0,80004dce <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d70:	4985                	li	s3,1
    80004d72:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d76:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d7a:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d7e:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d82:	00004597          	auipc	a1,0x4
    80004d86:	a3658593          	addi	a1,a1,-1482 # 800087b8 <syscalls+0x298>
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	dbc080e7          	jalr	-580(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004d92:	609c                	ld	a5,0(s1)
    80004d94:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d98:	609c                	ld	a5,0(s1)
    80004d9a:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d9e:	609c                	ld	a5,0(s1)
    80004da0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004da4:	609c                	ld	a5,0(s1)
    80004da6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004daa:	000a3783          	ld	a5,0(s4)
    80004dae:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004db2:	000a3783          	ld	a5,0(s4)
    80004db6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004dba:	000a3783          	ld	a5,0(s4)
    80004dbe:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004dc2:	000a3783          	ld	a5,0(s4)
    80004dc6:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dca:	4501                	li	a0,0
    80004dcc:	a025                	j	80004df4 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dce:	6088                	ld	a0,0(s1)
    80004dd0:	e501                	bnez	a0,80004dd8 <pipealloc+0xaa>
    80004dd2:	a039                	j	80004de0 <pipealloc+0xb2>
    80004dd4:	6088                	ld	a0,0(s1)
    80004dd6:	c51d                	beqz	a0,80004e04 <pipealloc+0xd6>
    fileclose(*f0);
    80004dd8:	00000097          	auipc	ra,0x0
    80004ddc:	c26080e7          	jalr	-986(ra) # 800049fe <fileclose>
  if(*f1)
    80004de0:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004de4:	557d                	li	a0,-1
  if(*f1)
    80004de6:	c799                	beqz	a5,80004df4 <pipealloc+0xc6>
    fileclose(*f1);
    80004de8:	853e                	mv	a0,a5
    80004dea:	00000097          	auipc	ra,0x0
    80004dee:	c14080e7          	jalr	-1004(ra) # 800049fe <fileclose>
  return -1;
    80004df2:	557d                	li	a0,-1
}
    80004df4:	70a2                	ld	ra,40(sp)
    80004df6:	7402                	ld	s0,32(sp)
    80004df8:	64e2                	ld	s1,24(sp)
    80004dfa:	6942                	ld	s2,16(sp)
    80004dfc:	69a2                	ld	s3,8(sp)
    80004dfe:	6a02                	ld	s4,0(sp)
    80004e00:	6145                	addi	sp,sp,48
    80004e02:	8082                	ret
  return -1;
    80004e04:	557d                	li	a0,-1
    80004e06:	b7fd                	j	80004df4 <pipealloc+0xc6>

0000000080004e08 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004e08:	1101                	addi	sp,sp,-32
    80004e0a:	ec06                	sd	ra,24(sp)
    80004e0c:	e822                	sd	s0,16(sp)
    80004e0e:	e426                	sd	s1,8(sp)
    80004e10:	e04a                	sd	s2,0(sp)
    80004e12:	1000                	addi	s0,sp,32
    80004e14:	84aa                	mv	s1,a0
    80004e16:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e18:	ffffc097          	auipc	ra,0xffffc
    80004e1c:	dbe080e7          	jalr	-578(ra) # 80000bd6 <acquire>
  if(writable){
    80004e20:	02090d63          	beqz	s2,80004e5a <pipeclose+0x52>
    pi->writeopen = 0;
    80004e24:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e28:	21848513          	addi	a0,s1,536
    80004e2c:	ffffd097          	auipc	ra,0xffffd
    80004e30:	5d4080e7          	jalr	1492(ra) # 80002400 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e34:	2204b783          	ld	a5,544(s1)
    80004e38:	eb95                	bnez	a5,80004e6c <pipeclose+0x64>
    release(&pi->lock);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	e4e080e7          	jalr	-434(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004e44:	8526                	mv	a0,s1
    80004e46:	ffffc097          	auipc	ra,0xffffc
    80004e4a:	ba2080e7          	jalr	-1118(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004e4e:	60e2                	ld	ra,24(sp)
    80004e50:	6442                	ld	s0,16(sp)
    80004e52:	64a2                	ld	s1,8(sp)
    80004e54:	6902                	ld	s2,0(sp)
    80004e56:	6105                	addi	sp,sp,32
    80004e58:	8082                	ret
    pi->readopen = 0;
    80004e5a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e5e:	21c48513          	addi	a0,s1,540
    80004e62:	ffffd097          	auipc	ra,0xffffd
    80004e66:	59e080e7          	jalr	1438(ra) # 80002400 <wakeup>
    80004e6a:	b7e9                	j	80004e34 <pipeclose+0x2c>
    release(&pi->lock);
    80004e6c:	8526                	mv	a0,s1
    80004e6e:	ffffc097          	auipc	ra,0xffffc
    80004e72:	e1c080e7          	jalr	-484(ra) # 80000c8a <release>
}
    80004e76:	bfe1                	j	80004e4e <pipeclose+0x46>

0000000080004e78 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e78:	711d                	addi	sp,sp,-96
    80004e7a:	ec86                	sd	ra,88(sp)
    80004e7c:	e8a2                	sd	s0,80(sp)
    80004e7e:	e4a6                	sd	s1,72(sp)
    80004e80:	e0ca                	sd	s2,64(sp)
    80004e82:	fc4e                	sd	s3,56(sp)
    80004e84:	f852                	sd	s4,48(sp)
    80004e86:	f456                	sd	s5,40(sp)
    80004e88:	f05a                	sd	s6,32(sp)
    80004e8a:	ec5e                	sd	s7,24(sp)
    80004e8c:	e862                	sd	s8,16(sp)
    80004e8e:	1080                	addi	s0,sp,96
    80004e90:	84aa                	mv	s1,a0
    80004e92:	8aae                	mv	s5,a1
    80004e94:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e96:	ffffd097          	auipc	ra,0xffffd
    80004e9a:	d58080e7          	jalr	-680(ra) # 80001bee <myproc>
    80004e9e:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ea0:	8526                	mv	a0,s1
    80004ea2:	ffffc097          	auipc	ra,0xffffc
    80004ea6:	d34080e7          	jalr	-716(ra) # 80000bd6 <acquire>
  while(i < n){
    80004eaa:	0b405663          	blez	s4,80004f56 <pipewrite+0xde>
  int i = 0;
    80004eae:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004eb0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004eb2:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004eb6:	21c48b93          	addi	s7,s1,540
    80004eba:	a089                	j	80004efc <pipewrite+0x84>
      release(&pi->lock);
    80004ebc:	8526                	mv	a0,s1
    80004ebe:	ffffc097          	auipc	ra,0xffffc
    80004ec2:	dcc080e7          	jalr	-564(ra) # 80000c8a <release>
      return -1;
    80004ec6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ec8:	854a                	mv	a0,s2
    80004eca:	60e6                	ld	ra,88(sp)
    80004ecc:	6446                	ld	s0,80(sp)
    80004ece:	64a6                	ld	s1,72(sp)
    80004ed0:	6906                	ld	s2,64(sp)
    80004ed2:	79e2                	ld	s3,56(sp)
    80004ed4:	7a42                	ld	s4,48(sp)
    80004ed6:	7aa2                	ld	s5,40(sp)
    80004ed8:	7b02                	ld	s6,32(sp)
    80004eda:	6be2                	ld	s7,24(sp)
    80004edc:	6c42                	ld	s8,16(sp)
    80004ede:	6125                	addi	sp,sp,96
    80004ee0:	8082                	ret
      wakeup(&pi->nread);
    80004ee2:	8562                	mv	a0,s8
    80004ee4:	ffffd097          	auipc	ra,0xffffd
    80004ee8:	51c080e7          	jalr	1308(ra) # 80002400 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004eec:	85a6                	mv	a1,s1
    80004eee:	855e                	mv	a0,s7
    80004ef0:	ffffd097          	auipc	ra,0xffffd
    80004ef4:	4ac080e7          	jalr	1196(ra) # 8000239c <sleep>
  while(i < n){
    80004ef8:	07495063          	bge	s2,s4,80004f58 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004efc:	2204a783          	lw	a5,544(s1)
    80004f00:	dfd5                	beqz	a5,80004ebc <pipewrite+0x44>
    80004f02:	854e                	mv	a0,s3
    80004f04:	ffffd097          	auipc	ra,0xffffd
    80004f08:	740080e7          	jalr	1856(ra) # 80002644 <killed>
    80004f0c:	f945                	bnez	a0,80004ebc <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f0e:	2184a783          	lw	a5,536(s1)
    80004f12:	21c4a703          	lw	a4,540(s1)
    80004f16:	2007879b          	addiw	a5,a5,512
    80004f1a:	fcf704e3          	beq	a4,a5,80004ee2 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f1e:	4685                	li	a3,1
    80004f20:	01590633          	add	a2,s2,s5
    80004f24:	faf40593          	addi	a1,s0,-81
    80004f28:	0589b503          	ld	a0,88(s3)
    80004f2c:	ffffc097          	auipc	ra,0xffffc
    80004f30:	7cc080e7          	jalr	1996(ra) # 800016f8 <copyin>
    80004f34:	03650263          	beq	a0,s6,80004f58 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f38:	21c4a783          	lw	a5,540(s1)
    80004f3c:	0017871b          	addiw	a4,a5,1
    80004f40:	20e4ae23          	sw	a4,540(s1)
    80004f44:	1ff7f793          	andi	a5,a5,511
    80004f48:	97a6                	add	a5,a5,s1
    80004f4a:	faf44703          	lbu	a4,-81(s0)
    80004f4e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f52:	2905                	addiw	s2,s2,1
    80004f54:	b755                	j	80004ef8 <pipewrite+0x80>
  int i = 0;
    80004f56:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f58:	21848513          	addi	a0,s1,536
    80004f5c:	ffffd097          	auipc	ra,0xffffd
    80004f60:	4a4080e7          	jalr	1188(ra) # 80002400 <wakeup>
  release(&pi->lock);
    80004f64:	8526                	mv	a0,s1
    80004f66:	ffffc097          	auipc	ra,0xffffc
    80004f6a:	d24080e7          	jalr	-732(ra) # 80000c8a <release>
  return i;
    80004f6e:	bfa9                	j	80004ec8 <pipewrite+0x50>

0000000080004f70 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f70:	715d                	addi	sp,sp,-80
    80004f72:	e486                	sd	ra,72(sp)
    80004f74:	e0a2                	sd	s0,64(sp)
    80004f76:	fc26                	sd	s1,56(sp)
    80004f78:	f84a                	sd	s2,48(sp)
    80004f7a:	f44e                	sd	s3,40(sp)
    80004f7c:	f052                	sd	s4,32(sp)
    80004f7e:	ec56                	sd	s5,24(sp)
    80004f80:	e85a                	sd	s6,16(sp)
    80004f82:	0880                	addi	s0,sp,80
    80004f84:	84aa                	mv	s1,a0
    80004f86:	892e                	mv	s2,a1
    80004f88:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f8a:	ffffd097          	auipc	ra,0xffffd
    80004f8e:	c64080e7          	jalr	-924(ra) # 80001bee <myproc>
    80004f92:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f94:	8526                	mv	a0,s1
    80004f96:	ffffc097          	auipc	ra,0xffffc
    80004f9a:	c40080e7          	jalr	-960(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f9e:	2184a703          	lw	a4,536(s1)
    80004fa2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fa6:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004faa:	02f71763          	bne	a4,a5,80004fd8 <piperead+0x68>
    80004fae:	2244a783          	lw	a5,548(s1)
    80004fb2:	c39d                	beqz	a5,80004fd8 <piperead+0x68>
    if(killed(pr)){
    80004fb4:	8552                	mv	a0,s4
    80004fb6:	ffffd097          	auipc	ra,0xffffd
    80004fba:	68e080e7          	jalr	1678(ra) # 80002644 <killed>
    80004fbe:	e949                	bnez	a0,80005050 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fc0:	85a6                	mv	a1,s1
    80004fc2:	854e                	mv	a0,s3
    80004fc4:	ffffd097          	auipc	ra,0xffffd
    80004fc8:	3d8080e7          	jalr	984(ra) # 8000239c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fcc:	2184a703          	lw	a4,536(s1)
    80004fd0:	21c4a783          	lw	a5,540(s1)
    80004fd4:	fcf70de3          	beq	a4,a5,80004fae <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd8:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fda:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fdc:	05505463          	blez	s5,80005024 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004fe0:	2184a783          	lw	a5,536(s1)
    80004fe4:	21c4a703          	lw	a4,540(s1)
    80004fe8:	02f70e63          	beq	a4,a5,80005024 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fec:	0017871b          	addiw	a4,a5,1
    80004ff0:	20e4ac23          	sw	a4,536(s1)
    80004ff4:	1ff7f793          	andi	a5,a5,511
    80004ff8:	97a6                	add	a5,a5,s1
    80004ffa:	0187c783          	lbu	a5,24(a5)
    80004ffe:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80005002:	4685                	li	a3,1
    80005004:	fbf40613          	addi	a2,s0,-65
    80005008:	85ca                	mv	a1,s2
    8000500a:	058a3503          	ld	a0,88(s4)
    8000500e:	ffffc097          	auipc	ra,0xffffc
    80005012:	65e080e7          	jalr	1630(ra) # 8000166c <copyout>
    80005016:	01650763          	beq	a0,s6,80005024 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000501a:	2985                	addiw	s3,s3,1
    8000501c:	0905                	addi	s2,s2,1
    8000501e:	fd3a91e3          	bne	s5,s3,80004fe0 <piperead+0x70>
    80005022:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80005024:	21c48513          	addi	a0,s1,540
    80005028:	ffffd097          	auipc	ra,0xffffd
    8000502c:	3d8080e7          	jalr	984(ra) # 80002400 <wakeup>
  release(&pi->lock);
    80005030:	8526                	mv	a0,s1
    80005032:	ffffc097          	auipc	ra,0xffffc
    80005036:	c58080e7          	jalr	-936(ra) # 80000c8a <release>
  return i;
}
    8000503a:	854e                	mv	a0,s3
    8000503c:	60a6                	ld	ra,72(sp)
    8000503e:	6406                	ld	s0,64(sp)
    80005040:	74e2                	ld	s1,56(sp)
    80005042:	7942                	ld	s2,48(sp)
    80005044:	79a2                	ld	s3,40(sp)
    80005046:	7a02                	ld	s4,32(sp)
    80005048:	6ae2                	ld	s5,24(sp)
    8000504a:	6b42                	ld	s6,16(sp)
    8000504c:	6161                	addi	sp,sp,80
    8000504e:	8082                	ret
      release(&pi->lock);
    80005050:	8526                	mv	a0,s1
    80005052:	ffffc097          	auipc	ra,0xffffc
    80005056:	c38080e7          	jalr	-968(ra) # 80000c8a <release>
      return -1;
    8000505a:	59fd                	li	s3,-1
    8000505c:	bff9                	j	8000503a <piperead+0xca>

000000008000505e <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    8000505e:	1141                	addi	sp,sp,-16
    80005060:	e422                	sd	s0,8(sp)
    80005062:	0800                	addi	s0,sp,16
    80005064:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80005066:	8905                	andi	a0,a0,1
    80005068:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    8000506a:	8b89                	andi	a5,a5,2
    8000506c:	c399                	beqz	a5,80005072 <flags2perm+0x14>
      perm |= PTE_W;
    8000506e:	00456513          	ori	a0,a0,4
    return perm;
}
    80005072:	6422                	ld	s0,8(sp)
    80005074:	0141                	addi	sp,sp,16
    80005076:	8082                	ret

0000000080005078 <exec>:

int
exec(char *path, char **argv)
{
    80005078:	de010113          	addi	sp,sp,-544
    8000507c:	20113c23          	sd	ra,536(sp)
    80005080:	20813823          	sd	s0,528(sp)
    80005084:	20913423          	sd	s1,520(sp)
    80005088:	21213023          	sd	s2,512(sp)
    8000508c:	ffce                	sd	s3,504(sp)
    8000508e:	fbd2                	sd	s4,496(sp)
    80005090:	f7d6                	sd	s5,488(sp)
    80005092:	f3da                	sd	s6,480(sp)
    80005094:	efde                	sd	s7,472(sp)
    80005096:	ebe2                	sd	s8,464(sp)
    80005098:	e7e6                	sd	s9,456(sp)
    8000509a:	e3ea                	sd	s10,448(sp)
    8000509c:	ff6e                	sd	s11,440(sp)
    8000509e:	1400                	addi	s0,sp,544
    800050a0:	892a                	mv	s2,a0
    800050a2:	dea43423          	sd	a0,-536(s0)
    800050a6:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    800050aa:	ffffd097          	auipc	ra,0xffffd
    800050ae:	b44080e7          	jalr	-1212(ra) # 80001bee <myproc>
    800050b2:	84aa                	mv	s1,a0

  begin_op();
    800050b4:	fffff097          	auipc	ra,0xfffff
    800050b8:	482080e7          	jalr	1154(ra) # 80004536 <begin_op>

  if((ip = namei(path)) == 0){
    800050bc:	854a                	mv	a0,s2
    800050be:	fffff097          	auipc	ra,0xfffff
    800050c2:	258080e7          	jalr	600(ra) # 80004316 <namei>
    800050c6:	c93d                	beqz	a0,8000513c <exec+0xc4>
    800050c8:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050ca:	fffff097          	auipc	ra,0xfffff
    800050ce:	aa0080e7          	jalr	-1376(ra) # 80003b6a <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050d2:	04000713          	li	a4,64
    800050d6:	4681                	li	a3,0
    800050d8:	e5040613          	addi	a2,s0,-432
    800050dc:	4581                	li	a1,0
    800050de:	8556                	mv	a0,s5
    800050e0:	fffff097          	auipc	ra,0xfffff
    800050e4:	d3e080e7          	jalr	-706(ra) # 80003e1e <readi>
    800050e8:	04000793          	li	a5,64
    800050ec:	00f51a63          	bne	a0,a5,80005100 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050f0:	e5042703          	lw	a4,-432(s0)
    800050f4:	464c47b7          	lui	a5,0x464c4
    800050f8:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050fc:	04f70663          	beq	a4,a5,80005148 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80005100:	8556                	mv	a0,s5
    80005102:	fffff097          	auipc	ra,0xfffff
    80005106:	cca080e7          	jalr	-822(ra) # 80003dcc <iunlockput>
    end_op();
    8000510a:	fffff097          	auipc	ra,0xfffff
    8000510e:	4aa080e7          	jalr	1194(ra) # 800045b4 <end_op>
  }
  return -1;
    80005112:	557d                	li	a0,-1
}
    80005114:	21813083          	ld	ra,536(sp)
    80005118:	21013403          	ld	s0,528(sp)
    8000511c:	20813483          	ld	s1,520(sp)
    80005120:	20013903          	ld	s2,512(sp)
    80005124:	79fe                	ld	s3,504(sp)
    80005126:	7a5e                	ld	s4,496(sp)
    80005128:	7abe                	ld	s5,488(sp)
    8000512a:	7b1e                	ld	s6,480(sp)
    8000512c:	6bfe                	ld	s7,472(sp)
    8000512e:	6c5e                	ld	s8,464(sp)
    80005130:	6cbe                	ld	s9,456(sp)
    80005132:	6d1e                	ld	s10,448(sp)
    80005134:	7dfa                	ld	s11,440(sp)
    80005136:	22010113          	addi	sp,sp,544
    8000513a:	8082                	ret
    end_op();
    8000513c:	fffff097          	auipc	ra,0xfffff
    80005140:	478080e7          	jalr	1144(ra) # 800045b4 <end_op>
    return -1;
    80005144:	557d                	li	a0,-1
    80005146:	b7f9                	j	80005114 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005148:	8526                	mv	a0,s1
    8000514a:	ffffd097          	auipc	ra,0xffffd
    8000514e:	b68080e7          	jalr	-1176(ra) # 80001cb2 <proc_pagetable>
    80005152:	8b2a                	mv	s6,a0
    80005154:	d555                	beqz	a0,80005100 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005156:	e7042783          	lw	a5,-400(s0)
    8000515a:	e8845703          	lhu	a4,-376(s0)
    8000515e:	c735                	beqz	a4,800051ca <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005160:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005162:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80005166:	6a05                	lui	s4,0x1
    80005168:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    8000516c:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005170:	6d85                	lui	s11,0x1
    80005172:	7d7d                	lui	s10,0xfffff
    80005174:	ac3d                	j	800053b2 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80005176:	00003517          	auipc	a0,0x3
    8000517a:	64a50513          	addi	a0,a0,1610 # 800087c0 <syscalls+0x2a0>
    8000517e:	ffffb097          	auipc	ra,0xffffb
    80005182:	3c2080e7          	jalr	962(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005186:	874a                	mv	a4,s2
    80005188:	009c86bb          	addw	a3,s9,s1
    8000518c:	4581                	li	a1,0
    8000518e:	8556                	mv	a0,s5
    80005190:	fffff097          	auipc	ra,0xfffff
    80005194:	c8e080e7          	jalr	-882(ra) # 80003e1e <readi>
    80005198:	2501                	sext.w	a0,a0
    8000519a:	1aa91963          	bne	s2,a0,8000534c <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    8000519e:	009d84bb          	addw	s1,s11,s1
    800051a2:	013d09bb          	addw	s3,s10,s3
    800051a6:	1f74f663          	bgeu	s1,s7,80005392 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    800051aa:	02049593          	slli	a1,s1,0x20
    800051ae:	9181                	srli	a1,a1,0x20
    800051b0:	95e2                	add	a1,a1,s8
    800051b2:	855a                	mv	a0,s6
    800051b4:	ffffc097          	auipc	ra,0xffffc
    800051b8:	ea8080e7          	jalr	-344(ra) # 8000105c <walkaddr>
    800051bc:	862a                	mv	a2,a0
    if(pa == 0)
    800051be:	dd45                	beqz	a0,80005176 <exec+0xfe>
      n = PGSIZE;
    800051c0:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    800051c2:	fd49f2e3          	bgeu	s3,s4,80005186 <exec+0x10e>
      n = sz - i;
    800051c6:	894e                	mv	s2,s3
    800051c8:	bf7d                	j	80005186 <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800051ca:	4901                	li	s2,0
  iunlockput(ip);
    800051cc:	8556                	mv	a0,s5
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	bfe080e7          	jalr	-1026(ra) # 80003dcc <iunlockput>
  end_op();
    800051d6:	fffff097          	auipc	ra,0xfffff
    800051da:	3de080e7          	jalr	990(ra) # 800045b4 <end_op>
  p = myproc();
    800051de:	ffffd097          	auipc	ra,0xffffd
    800051e2:	a10080e7          	jalr	-1520(ra) # 80001bee <myproc>
    800051e6:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800051e8:	05053d03          	ld	s10,80(a0)
  sz = PGROUNDUP(sz);
    800051ec:	6785                	lui	a5,0x1
    800051ee:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800051f0:	97ca                	add	a5,a5,s2
    800051f2:	777d                	lui	a4,0xfffff
    800051f4:	8ff9                	and	a5,a5,a4
    800051f6:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800051fa:	4691                	li	a3,4
    800051fc:	6609                	lui	a2,0x2
    800051fe:	963e                	add	a2,a2,a5
    80005200:	85be                	mv	a1,a5
    80005202:	855a                	mv	a0,s6
    80005204:	ffffc097          	auipc	ra,0xffffc
    80005208:	20c080e7          	jalr	524(ra) # 80001410 <uvmalloc>
    8000520c:	8c2a                	mv	s8,a0
  ip = 0;
    8000520e:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005210:	12050e63          	beqz	a0,8000534c <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80005214:	75f9                	lui	a1,0xffffe
    80005216:	95aa                	add	a1,a1,a0
    80005218:	855a                	mv	a0,s6
    8000521a:	ffffc097          	auipc	ra,0xffffc
    8000521e:	420080e7          	jalr	1056(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80005222:	7afd                	lui	s5,0xfffff
    80005224:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80005226:	df043783          	ld	a5,-528(s0)
    8000522a:	6388                	ld	a0,0(a5)
    8000522c:	c925                	beqz	a0,8000529c <exec+0x224>
    8000522e:	e9040993          	addi	s3,s0,-368
    80005232:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80005236:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005238:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    8000523a:	ffffc097          	auipc	ra,0xffffc
    8000523e:	c14080e7          	jalr	-1004(ra) # 80000e4e <strlen>
    80005242:	0015079b          	addiw	a5,a0,1
    80005246:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000524a:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    8000524e:	13596663          	bltu	s2,s5,8000537a <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005252:	df043d83          	ld	s11,-528(s0)
    80005256:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000525a:	8552                	mv	a0,s4
    8000525c:	ffffc097          	auipc	ra,0xffffc
    80005260:	bf2080e7          	jalr	-1038(ra) # 80000e4e <strlen>
    80005264:	0015069b          	addiw	a3,a0,1
    80005268:	8652                	mv	a2,s4
    8000526a:	85ca                	mv	a1,s2
    8000526c:	855a                	mv	a0,s6
    8000526e:	ffffc097          	auipc	ra,0xffffc
    80005272:	3fe080e7          	jalr	1022(ra) # 8000166c <copyout>
    80005276:	10054663          	bltz	a0,80005382 <exec+0x30a>
    ustack[argc] = sp;
    8000527a:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000527e:	0485                	addi	s1,s1,1
    80005280:	008d8793          	addi	a5,s11,8
    80005284:	def43823          	sd	a5,-528(s0)
    80005288:	008db503          	ld	a0,8(s11)
    8000528c:	c911                	beqz	a0,800052a0 <exec+0x228>
    if(argc >= MAXARG)
    8000528e:	09a1                	addi	s3,s3,8
    80005290:	fb3c95e3          	bne	s9,s3,8000523a <exec+0x1c2>
  sz = sz1;
    80005294:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005298:	4a81                	li	s5,0
    8000529a:	a84d                	j	8000534c <exec+0x2d4>
  sp = sz;
    8000529c:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    8000529e:	4481                	li	s1,0
  ustack[argc] = 0;
    800052a0:	00349793          	slli	a5,s1,0x3
    800052a4:	f9078793          	addi	a5,a5,-112
    800052a8:	97a2                	add	a5,a5,s0
    800052aa:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800052ae:	00148693          	addi	a3,s1,1
    800052b2:	068e                	slli	a3,a3,0x3
    800052b4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800052b8:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    800052bc:	01597663          	bgeu	s2,s5,800052c8 <exec+0x250>
  sz = sz1;
    800052c0:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    800052c4:	4a81                	li	s5,0
    800052c6:	a059                	j	8000534c <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800052c8:	e9040613          	addi	a2,s0,-368
    800052cc:	85ca                	mv	a1,s2
    800052ce:	855a                	mv	a0,s6
    800052d0:	ffffc097          	auipc	ra,0xffffc
    800052d4:	39c080e7          	jalr	924(ra) # 8000166c <copyout>
    800052d8:	0a054963          	bltz	a0,8000538a <exec+0x312>
  p->trapframe->a1 = sp;
    800052dc:	060bb783          	ld	a5,96(s7)
    800052e0:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800052e4:	de843783          	ld	a5,-536(s0)
    800052e8:	0007c703          	lbu	a4,0(a5)
    800052ec:	cf11                	beqz	a4,80005308 <exec+0x290>
    800052ee:	0785                	addi	a5,a5,1
    if(*s == '/')
    800052f0:	02f00693          	li	a3,47
    800052f4:	a039                	j	80005302 <exec+0x28a>
      last = s+1;
    800052f6:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800052fa:	0785                	addi	a5,a5,1
    800052fc:	fff7c703          	lbu	a4,-1(a5)
    80005300:	c701                	beqz	a4,80005308 <exec+0x290>
    if(*s == '/')
    80005302:	fed71ce3          	bne	a4,a3,800052fa <exec+0x282>
    80005306:	bfc5                	j	800052f6 <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    80005308:	4641                	li	a2,16
    8000530a:	de843583          	ld	a1,-536(s0)
    8000530e:	160b8513          	addi	a0,s7,352
    80005312:	ffffc097          	auipc	ra,0xffffc
    80005316:	b0a080e7          	jalr	-1270(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    8000531a:	058bb503          	ld	a0,88(s7)
  p->pagetable = pagetable;
    8000531e:	056bbc23          	sd	s6,88(s7)
  p->sz = sz;
    80005322:	058bb823          	sd	s8,80(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80005326:	060bb783          	ld	a5,96(s7)
    8000532a:	e6843703          	ld	a4,-408(s0)
    8000532e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005330:	060bb783          	ld	a5,96(s7)
    80005334:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005338:	85ea                	mv	a1,s10
    8000533a:	ffffd097          	auipc	ra,0xffffd
    8000533e:	a14080e7          	jalr	-1516(ra) # 80001d4e <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005342:	0004851b          	sext.w	a0,s1
    80005346:	b3f9                	j	80005114 <exec+0x9c>
    80005348:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    8000534c:	df843583          	ld	a1,-520(s0)
    80005350:	855a                	mv	a0,s6
    80005352:	ffffd097          	auipc	ra,0xffffd
    80005356:	9fc080e7          	jalr	-1540(ra) # 80001d4e <proc_freepagetable>
  if(ip){
    8000535a:	da0a93e3          	bnez	s5,80005100 <exec+0x88>
  return -1;
    8000535e:	557d                	li	a0,-1
    80005360:	bb55                	j	80005114 <exec+0x9c>
    80005362:	df243c23          	sd	s2,-520(s0)
    80005366:	b7dd                	j	8000534c <exec+0x2d4>
    80005368:	df243c23          	sd	s2,-520(s0)
    8000536c:	b7c5                	j	8000534c <exec+0x2d4>
    8000536e:	df243c23          	sd	s2,-520(s0)
    80005372:	bfe9                	j	8000534c <exec+0x2d4>
    80005374:	df243c23          	sd	s2,-520(s0)
    80005378:	bfd1                	j	8000534c <exec+0x2d4>
  sz = sz1;
    8000537a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000537e:	4a81                	li	s5,0
    80005380:	b7f1                	j	8000534c <exec+0x2d4>
  sz = sz1;
    80005382:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005386:	4a81                	li	s5,0
    80005388:	b7d1                	j	8000534c <exec+0x2d4>
  sz = sz1;
    8000538a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000538e:	4a81                	li	s5,0
    80005390:	bf75                	j	8000534c <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005392:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005396:	e0843783          	ld	a5,-504(s0)
    8000539a:	0017869b          	addiw	a3,a5,1
    8000539e:	e0d43423          	sd	a3,-504(s0)
    800053a2:	e0043783          	ld	a5,-512(s0)
    800053a6:	0387879b          	addiw	a5,a5,56
    800053aa:	e8845703          	lhu	a4,-376(s0)
    800053ae:	e0e6dfe3          	bge	a3,a4,800051cc <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800053b2:	2781                	sext.w	a5,a5
    800053b4:	e0f43023          	sd	a5,-512(s0)
    800053b8:	03800713          	li	a4,56
    800053bc:	86be                	mv	a3,a5
    800053be:	e1840613          	addi	a2,s0,-488
    800053c2:	4581                	li	a1,0
    800053c4:	8556                	mv	a0,s5
    800053c6:	fffff097          	auipc	ra,0xfffff
    800053ca:	a58080e7          	jalr	-1448(ra) # 80003e1e <readi>
    800053ce:	03800793          	li	a5,56
    800053d2:	f6f51be3          	bne	a0,a5,80005348 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    800053d6:	e1842783          	lw	a5,-488(s0)
    800053da:	4705                	li	a4,1
    800053dc:	fae79de3          	bne	a5,a4,80005396 <exec+0x31e>
    if(ph.memsz < ph.filesz)
    800053e0:	e4043483          	ld	s1,-448(s0)
    800053e4:	e3843783          	ld	a5,-456(s0)
    800053e8:	f6f4ede3          	bltu	s1,a5,80005362 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800053ec:	e2843783          	ld	a5,-472(s0)
    800053f0:	94be                	add	s1,s1,a5
    800053f2:	f6f4ebe3          	bltu	s1,a5,80005368 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800053f6:	de043703          	ld	a4,-544(s0)
    800053fa:	8ff9                	and	a5,a5,a4
    800053fc:	fbad                	bnez	a5,8000536e <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800053fe:	e1c42503          	lw	a0,-484(s0)
    80005402:	00000097          	auipc	ra,0x0
    80005406:	c5c080e7          	jalr	-932(ra) # 8000505e <flags2perm>
    8000540a:	86aa                	mv	a3,a0
    8000540c:	8626                	mv	a2,s1
    8000540e:	85ca                	mv	a1,s2
    80005410:	855a                	mv	a0,s6
    80005412:	ffffc097          	auipc	ra,0xffffc
    80005416:	ffe080e7          	jalr	-2(ra) # 80001410 <uvmalloc>
    8000541a:	dea43c23          	sd	a0,-520(s0)
    8000541e:	d939                	beqz	a0,80005374 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80005420:	e2843c03          	ld	s8,-472(s0)
    80005424:	e2042c83          	lw	s9,-480(s0)
    80005428:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    8000542c:	f60b83e3          	beqz	s7,80005392 <exec+0x31a>
    80005430:	89de                	mv	s3,s7
    80005432:	4481                	li	s1,0
    80005434:	bb9d                	j	800051aa <exec+0x132>

0000000080005436 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005436:	7179                	addi	sp,sp,-48
    80005438:	f406                	sd	ra,40(sp)
    8000543a:	f022                	sd	s0,32(sp)
    8000543c:	ec26                	sd	s1,24(sp)
    8000543e:	e84a                	sd	s2,16(sp)
    80005440:	1800                	addi	s0,sp,48
    80005442:	892e                	mv	s2,a1
    80005444:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005446:	fdc40593          	addi	a1,s0,-36
    8000544a:	ffffe097          	auipc	ra,0xffffe
    8000544e:	b0a080e7          	jalr	-1270(ra) # 80002f54 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005452:	fdc42703          	lw	a4,-36(s0)
    80005456:	47bd                	li	a5,15
    80005458:	02e7eb63          	bltu	a5,a4,8000548e <argfd+0x58>
    8000545c:	ffffc097          	auipc	ra,0xffffc
    80005460:	792080e7          	jalr	1938(ra) # 80001bee <myproc>
    80005464:	fdc42703          	lw	a4,-36(s0)
    80005468:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdcf7a>
    8000546c:	078e                	slli	a5,a5,0x3
    8000546e:	953e                	add	a0,a0,a5
    80005470:	651c                	ld	a5,8(a0)
    80005472:	c385                	beqz	a5,80005492 <argfd+0x5c>
    return -1;
  if(pfd)
    80005474:	00090463          	beqz	s2,8000547c <argfd+0x46>
    *pfd = fd;
    80005478:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000547c:	4501                	li	a0,0
  if(pf)
    8000547e:	c091                	beqz	s1,80005482 <argfd+0x4c>
    *pf = f;
    80005480:	e09c                	sd	a5,0(s1)
}
    80005482:	70a2                	ld	ra,40(sp)
    80005484:	7402                	ld	s0,32(sp)
    80005486:	64e2                	ld	s1,24(sp)
    80005488:	6942                	ld	s2,16(sp)
    8000548a:	6145                	addi	sp,sp,48
    8000548c:	8082                	ret
    return -1;
    8000548e:	557d                	li	a0,-1
    80005490:	bfcd                	j	80005482 <argfd+0x4c>
    80005492:	557d                	li	a0,-1
    80005494:	b7fd                	j	80005482 <argfd+0x4c>

0000000080005496 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005496:	1101                	addi	sp,sp,-32
    80005498:	ec06                	sd	ra,24(sp)
    8000549a:	e822                	sd	s0,16(sp)
    8000549c:	e426                	sd	s1,8(sp)
    8000549e:	1000                	addi	s0,sp,32
    800054a0:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800054a2:	ffffc097          	auipc	ra,0xffffc
    800054a6:	74c080e7          	jalr	1868(ra) # 80001bee <myproc>
    800054aa:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800054ac:	0d850793          	addi	a5,a0,216
    800054b0:	4501                	li	a0,0
    800054b2:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800054b4:	6398                	ld	a4,0(a5)
    800054b6:	cb19                	beqz	a4,800054cc <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800054b8:	2505                	addiw	a0,a0,1
    800054ba:	07a1                	addi	a5,a5,8
    800054bc:	fed51ce3          	bne	a0,a3,800054b4 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800054c0:	557d                	li	a0,-1
}
    800054c2:	60e2                	ld	ra,24(sp)
    800054c4:	6442                	ld	s0,16(sp)
    800054c6:	64a2                	ld	s1,8(sp)
    800054c8:	6105                	addi	sp,sp,32
    800054ca:	8082                	ret
      p->ofile[fd] = f;
    800054cc:	01a50793          	addi	a5,a0,26
    800054d0:	078e                	slli	a5,a5,0x3
    800054d2:	963e                	add	a2,a2,a5
    800054d4:	e604                	sd	s1,8(a2)
      return fd;
    800054d6:	b7f5                	j	800054c2 <fdalloc+0x2c>

00000000800054d8 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054d8:	715d                	addi	sp,sp,-80
    800054da:	e486                	sd	ra,72(sp)
    800054dc:	e0a2                	sd	s0,64(sp)
    800054de:	fc26                	sd	s1,56(sp)
    800054e0:	f84a                	sd	s2,48(sp)
    800054e2:	f44e                	sd	s3,40(sp)
    800054e4:	f052                	sd	s4,32(sp)
    800054e6:	ec56                	sd	s5,24(sp)
    800054e8:	e85a                	sd	s6,16(sp)
    800054ea:	0880                	addi	s0,sp,80
    800054ec:	8b2e                	mv	s6,a1
    800054ee:	89b2                	mv	s3,a2
    800054f0:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054f2:	fb040593          	addi	a1,s0,-80
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	e3e080e7          	jalr	-450(ra) # 80004334 <nameiparent>
    800054fe:	84aa                	mv	s1,a0
    80005500:	14050f63          	beqz	a0,8000565e <create+0x186>
    return 0;

  ilock(dp);
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	666080e7          	jalr	1638(ra) # 80003b6a <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000550c:	4601                	li	a2,0
    8000550e:	fb040593          	addi	a1,s0,-80
    80005512:	8526                	mv	a0,s1
    80005514:	fffff097          	auipc	ra,0xfffff
    80005518:	b3a080e7          	jalr	-1222(ra) # 8000404e <dirlookup>
    8000551c:	8aaa                	mv	s5,a0
    8000551e:	c931                	beqz	a0,80005572 <create+0x9a>
    iunlockput(dp);
    80005520:	8526                	mv	a0,s1
    80005522:	fffff097          	auipc	ra,0xfffff
    80005526:	8aa080e7          	jalr	-1878(ra) # 80003dcc <iunlockput>
    ilock(ip);
    8000552a:	8556                	mv	a0,s5
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	63e080e7          	jalr	1598(ra) # 80003b6a <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005534:	000b059b          	sext.w	a1,s6
    80005538:	4789                	li	a5,2
    8000553a:	02f59563          	bne	a1,a5,80005564 <create+0x8c>
    8000553e:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdcfa4>
    80005542:	37f9                	addiw	a5,a5,-2
    80005544:	17c2                	slli	a5,a5,0x30
    80005546:	93c1                	srli	a5,a5,0x30
    80005548:	4705                	li	a4,1
    8000554a:	00f76d63          	bltu	a4,a5,80005564 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000554e:	8556                	mv	a0,s5
    80005550:	60a6                	ld	ra,72(sp)
    80005552:	6406                	ld	s0,64(sp)
    80005554:	74e2                	ld	s1,56(sp)
    80005556:	7942                	ld	s2,48(sp)
    80005558:	79a2                	ld	s3,40(sp)
    8000555a:	7a02                	ld	s4,32(sp)
    8000555c:	6ae2                	ld	s5,24(sp)
    8000555e:	6b42                	ld	s6,16(sp)
    80005560:	6161                	addi	sp,sp,80
    80005562:	8082                	ret
    iunlockput(ip);
    80005564:	8556                	mv	a0,s5
    80005566:	fffff097          	auipc	ra,0xfffff
    8000556a:	866080e7          	jalr	-1946(ra) # 80003dcc <iunlockput>
    return 0;
    8000556e:	4a81                	li	s5,0
    80005570:	bff9                	j	8000554e <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005572:	85da                	mv	a1,s6
    80005574:	4088                	lw	a0,0(s1)
    80005576:	ffffe097          	auipc	ra,0xffffe
    8000557a:	456080e7          	jalr	1110(ra) # 800039cc <ialloc>
    8000557e:	8a2a                	mv	s4,a0
    80005580:	c539                	beqz	a0,800055ce <create+0xf6>
  ilock(ip);
    80005582:	ffffe097          	auipc	ra,0xffffe
    80005586:	5e8080e7          	jalr	1512(ra) # 80003b6a <ilock>
  ip->major = major;
    8000558a:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000558e:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005592:	4905                	li	s2,1
    80005594:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005598:	8552                	mv	a0,s4
    8000559a:	ffffe097          	auipc	ra,0xffffe
    8000559e:	504080e7          	jalr	1284(ra) # 80003a9e <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800055a2:	000b059b          	sext.w	a1,s6
    800055a6:	03258b63          	beq	a1,s2,800055dc <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    800055aa:	004a2603          	lw	a2,4(s4)
    800055ae:	fb040593          	addi	a1,s0,-80
    800055b2:	8526                	mv	a0,s1
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	cb0080e7          	jalr	-848(ra) # 80004264 <dirlink>
    800055bc:	06054f63          	bltz	a0,8000563a <create+0x162>
  iunlockput(dp);
    800055c0:	8526                	mv	a0,s1
    800055c2:	fffff097          	auipc	ra,0xfffff
    800055c6:	80a080e7          	jalr	-2038(ra) # 80003dcc <iunlockput>
  return ip;
    800055ca:	8ad2                	mv	s5,s4
    800055cc:	b749                	j	8000554e <create+0x76>
    iunlockput(dp);
    800055ce:	8526                	mv	a0,s1
    800055d0:	ffffe097          	auipc	ra,0xffffe
    800055d4:	7fc080e7          	jalr	2044(ra) # 80003dcc <iunlockput>
    return 0;
    800055d8:	8ad2                	mv	s5,s4
    800055da:	bf95                	j	8000554e <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055dc:	004a2603          	lw	a2,4(s4)
    800055e0:	00003597          	auipc	a1,0x3
    800055e4:	20058593          	addi	a1,a1,512 # 800087e0 <syscalls+0x2c0>
    800055e8:	8552                	mv	a0,s4
    800055ea:	fffff097          	auipc	ra,0xfffff
    800055ee:	c7a080e7          	jalr	-902(ra) # 80004264 <dirlink>
    800055f2:	04054463          	bltz	a0,8000563a <create+0x162>
    800055f6:	40d0                	lw	a2,4(s1)
    800055f8:	00003597          	auipc	a1,0x3
    800055fc:	1f058593          	addi	a1,a1,496 # 800087e8 <syscalls+0x2c8>
    80005600:	8552                	mv	a0,s4
    80005602:	fffff097          	auipc	ra,0xfffff
    80005606:	c62080e7          	jalr	-926(ra) # 80004264 <dirlink>
    8000560a:	02054863          	bltz	a0,8000563a <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    8000560e:	004a2603          	lw	a2,4(s4)
    80005612:	fb040593          	addi	a1,s0,-80
    80005616:	8526                	mv	a0,s1
    80005618:	fffff097          	auipc	ra,0xfffff
    8000561c:	c4c080e7          	jalr	-948(ra) # 80004264 <dirlink>
    80005620:	00054d63          	bltz	a0,8000563a <create+0x162>
    dp->nlink++;  // for ".."
    80005624:	04a4d783          	lhu	a5,74(s1)
    80005628:	2785                	addiw	a5,a5,1
    8000562a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000562e:	8526                	mv	a0,s1
    80005630:	ffffe097          	auipc	ra,0xffffe
    80005634:	46e080e7          	jalr	1134(ra) # 80003a9e <iupdate>
    80005638:	b761                	j	800055c0 <create+0xe8>
  ip->nlink = 0;
    8000563a:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    8000563e:	8552                	mv	a0,s4
    80005640:	ffffe097          	auipc	ra,0xffffe
    80005644:	45e080e7          	jalr	1118(ra) # 80003a9e <iupdate>
  iunlockput(ip);
    80005648:	8552                	mv	a0,s4
    8000564a:	ffffe097          	auipc	ra,0xffffe
    8000564e:	782080e7          	jalr	1922(ra) # 80003dcc <iunlockput>
  iunlockput(dp);
    80005652:	8526                	mv	a0,s1
    80005654:	ffffe097          	auipc	ra,0xffffe
    80005658:	778080e7          	jalr	1912(ra) # 80003dcc <iunlockput>
  return 0;
    8000565c:	bdcd                	j	8000554e <create+0x76>
    return 0;
    8000565e:	8aaa                	mv	s5,a0
    80005660:	b5fd                	j	8000554e <create+0x76>

0000000080005662 <sys_dup>:
{
    80005662:	7179                	addi	sp,sp,-48
    80005664:	f406                	sd	ra,40(sp)
    80005666:	f022                	sd	s0,32(sp)
    80005668:	ec26                	sd	s1,24(sp)
    8000566a:	e84a                	sd	s2,16(sp)
    8000566c:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    8000566e:	fd840613          	addi	a2,s0,-40
    80005672:	4581                	li	a1,0
    80005674:	4501                	li	a0,0
    80005676:	00000097          	auipc	ra,0x0
    8000567a:	dc0080e7          	jalr	-576(ra) # 80005436 <argfd>
    return -1;
    8000567e:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005680:	02054363          	bltz	a0,800056a6 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005684:	fd843903          	ld	s2,-40(s0)
    80005688:	854a                	mv	a0,s2
    8000568a:	00000097          	auipc	ra,0x0
    8000568e:	e0c080e7          	jalr	-500(ra) # 80005496 <fdalloc>
    80005692:	84aa                	mv	s1,a0
    return -1;
    80005694:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005696:	00054863          	bltz	a0,800056a6 <sys_dup+0x44>
  filedup(f);
    8000569a:	854a                	mv	a0,s2
    8000569c:	fffff097          	auipc	ra,0xfffff
    800056a0:	310080e7          	jalr	784(ra) # 800049ac <filedup>
  return fd;
    800056a4:	87a6                	mv	a5,s1
}
    800056a6:	853e                	mv	a0,a5
    800056a8:	70a2                	ld	ra,40(sp)
    800056aa:	7402                	ld	s0,32(sp)
    800056ac:	64e2                	ld	s1,24(sp)
    800056ae:	6942                	ld	s2,16(sp)
    800056b0:	6145                	addi	sp,sp,48
    800056b2:	8082                	ret

00000000800056b4 <sys_read>:
{
    800056b4:	7179                	addi	sp,sp,-48
    800056b6:	f406                	sd	ra,40(sp)
    800056b8:	f022                	sd	s0,32(sp)
    800056ba:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056bc:	fd840593          	addi	a1,s0,-40
    800056c0:	4505                	li	a0,1
    800056c2:	ffffe097          	auipc	ra,0xffffe
    800056c6:	8b2080e7          	jalr	-1870(ra) # 80002f74 <argaddr>
  argint(2, &n);
    800056ca:	fe440593          	addi	a1,s0,-28
    800056ce:	4509                	li	a0,2
    800056d0:	ffffe097          	auipc	ra,0xffffe
    800056d4:	884080e7          	jalr	-1916(ra) # 80002f54 <argint>
  if(argfd(0, 0, &f) < 0)
    800056d8:	fe840613          	addi	a2,s0,-24
    800056dc:	4581                	li	a1,0
    800056de:	4501                	li	a0,0
    800056e0:	00000097          	auipc	ra,0x0
    800056e4:	d56080e7          	jalr	-682(ra) # 80005436 <argfd>
    800056e8:	87aa                	mv	a5,a0
    return -1;
    800056ea:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056ec:	0007cc63          	bltz	a5,80005704 <sys_read+0x50>
  return fileread(f, p, n);
    800056f0:	fe442603          	lw	a2,-28(s0)
    800056f4:	fd843583          	ld	a1,-40(s0)
    800056f8:	fe843503          	ld	a0,-24(s0)
    800056fc:	fffff097          	auipc	ra,0xfffff
    80005700:	43c080e7          	jalr	1084(ra) # 80004b38 <fileread>
}
    80005704:	70a2                	ld	ra,40(sp)
    80005706:	7402                	ld	s0,32(sp)
    80005708:	6145                	addi	sp,sp,48
    8000570a:	8082                	ret

000000008000570c <sys_write>:
{
    8000570c:	7179                	addi	sp,sp,-48
    8000570e:	f406                	sd	ra,40(sp)
    80005710:	f022                	sd	s0,32(sp)
    80005712:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005714:	fd840593          	addi	a1,s0,-40
    80005718:	4505                	li	a0,1
    8000571a:	ffffe097          	auipc	ra,0xffffe
    8000571e:	85a080e7          	jalr	-1958(ra) # 80002f74 <argaddr>
  argint(2, &n);
    80005722:	fe440593          	addi	a1,s0,-28
    80005726:	4509                	li	a0,2
    80005728:	ffffe097          	auipc	ra,0xffffe
    8000572c:	82c080e7          	jalr	-2004(ra) # 80002f54 <argint>
  if(argfd(0, 0, &f) < 0)
    80005730:	fe840613          	addi	a2,s0,-24
    80005734:	4581                	li	a1,0
    80005736:	4501                	li	a0,0
    80005738:	00000097          	auipc	ra,0x0
    8000573c:	cfe080e7          	jalr	-770(ra) # 80005436 <argfd>
    80005740:	87aa                	mv	a5,a0
    return -1;
    80005742:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005744:	0007cc63          	bltz	a5,8000575c <sys_write+0x50>
  return filewrite(f, p, n);
    80005748:	fe442603          	lw	a2,-28(s0)
    8000574c:	fd843583          	ld	a1,-40(s0)
    80005750:	fe843503          	ld	a0,-24(s0)
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	4a6080e7          	jalr	1190(ra) # 80004bfa <filewrite>
}
    8000575c:	70a2                	ld	ra,40(sp)
    8000575e:	7402                	ld	s0,32(sp)
    80005760:	6145                	addi	sp,sp,48
    80005762:	8082                	ret

0000000080005764 <sys_close>:
{
    80005764:	1101                	addi	sp,sp,-32
    80005766:	ec06                	sd	ra,24(sp)
    80005768:	e822                	sd	s0,16(sp)
    8000576a:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000576c:	fe040613          	addi	a2,s0,-32
    80005770:	fec40593          	addi	a1,s0,-20
    80005774:	4501                	li	a0,0
    80005776:	00000097          	auipc	ra,0x0
    8000577a:	cc0080e7          	jalr	-832(ra) # 80005436 <argfd>
    return -1;
    8000577e:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005780:	02054463          	bltz	a0,800057a8 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005784:	ffffc097          	auipc	ra,0xffffc
    80005788:	46a080e7          	jalr	1130(ra) # 80001bee <myproc>
    8000578c:	fec42783          	lw	a5,-20(s0)
    80005790:	07e9                	addi	a5,a5,26
    80005792:	078e                	slli	a5,a5,0x3
    80005794:	953e                	add	a0,a0,a5
    80005796:	00053423          	sd	zero,8(a0)
  fileclose(f);
    8000579a:	fe043503          	ld	a0,-32(s0)
    8000579e:	fffff097          	auipc	ra,0xfffff
    800057a2:	260080e7          	jalr	608(ra) # 800049fe <fileclose>
  return 0;
    800057a6:	4781                	li	a5,0
}
    800057a8:	853e                	mv	a0,a5
    800057aa:	60e2                	ld	ra,24(sp)
    800057ac:	6442                	ld	s0,16(sp)
    800057ae:	6105                	addi	sp,sp,32
    800057b0:	8082                	ret

00000000800057b2 <sys_fstat>:
{
    800057b2:	1101                	addi	sp,sp,-32
    800057b4:	ec06                	sd	ra,24(sp)
    800057b6:	e822                	sd	s0,16(sp)
    800057b8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    800057ba:	fe040593          	addi	a1,s0,-32
    800057be:	4505                	li	a0,1
    800057c0:	ffffd097          	auipc	ra,0xffffd
    800057c4:	7b4080e7          	jalr	1972(ra) # 80002f74 <argaddr>
  if(argfd(0, 0, &f) < 0)
    800057c8:	fe840613          	addi	a2,s0,-24
    800057cc:	4581                	li	a1,0
    800057ce:	4501                	li	a0,0
    800057d0:	00000097          	auipc	ra,0x0
    800057d4:	c66080e7          	jalr	-922(ra) # 80005436 <argfd>
    800057d8:	87aa                	mv	a5,a0
    return -1;
    800057da:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057dc:	0007ca63          	bltz	a5,800057f0 <sys_fstat+0x3e>
  return filestat(f, st);
    800057e0:	fe043583          	ld	a1,-32(s0)
    800057e4:	fe843503          	ld	a0,-24(s0)
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	2de080e7          	jalr	734(ra) # 80004ac6 <filestat>
}
    800057f0:	60e2                	ld	ra,24(sp)
    800057f2:	6442                	ld	s0,16(sp)
    800057f4:	6105                	addi	sp,sp,32
    800057f6:	8082                	ret

00000000800057f8 <sys_link>:
{
    800057f8:	7169                	addi	sp,sp,-304
    800057fa:	f606                	sd	ra,296(sp)
    800057fc:	f222                	sd	s0,288(sp)
    800057fe:	ee26                	sd	s1,280(sp)
    80005800:	ea4a                	sd	s2,272(sp)
    80005802:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005804:	08000613          	li	a2,128
    80005808:	ed040593          	addi	a1,s0,-304
    8000580c:	4501                	li	a0,0
    8000580e:	ffffd097          	auipc	ra,0xffffd
    80005812:	786080e7          	jalr	1926(ra) # 80002f94 <argstr>
    return -1;
    80005816:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005818:	10054e63          	bltz	a0,80005934 <sys_link+0x13c>
    8000581c:	08000613          	li	a2,128
    80005820:	f5040593          	addi	a1,s0,-176
    80005824:	4505                	li	a0,1
    80005826:	ffffd097          	auipc	ra,0xffffd
    8000582a:	76e080e7          	jalr	1902(ra) # 80002f94 <argstr>
    return -1;
    8000582e:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005830:	10054263          	bltz	a0,80005934 <sys_link+0x13c>
  begin_op();
    80005834:	fffff097          	auipc	ra,0xfffff
    80005838:	d02080e7          	jalr	-766(ra) # 80004536 <begin_op>
  if((ip = namei(old)) == 0){
    8000583c:	ed040513          	addi	a0,s0,-304
    80005840:	fffff097          	auipc	ra,0xfffff
    80005844:	ad6080e7          	jalr	-1322(ra) # 80004316 <namei>
    80005848:	84aa                	mv	s1,a0
    8000584a:	c551                	beqz	a0,800058d6 <sys_link+0xde>
  ilock(ip);
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	31e080e7          	jalr	798(ra) # 80003b6a <ilock>
  if(ip->type == T_DIR){
    80005854:	04449703          	lh	a4,68(s1)
    80005858:	4785                	li	a5,1
    8000585a:	08f70463          	beq	a4,a5,800058e2 <sys_link+0xea>
  ip->nlink++;
    8000585e:	04a4d783          	lhu	a5,74(s1)
    80005862:	2785                	addiw	a5,a5,1
    80005864:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005868:	8526                	mv	a0,s1
    8000586a:	ffffe097          	auipc	ra,0xffffe
    8000586e:	234080e7          	jalr	564(ra) # 80003a9e <iupdate>
  iunlock(ip);
    80005872:	8526                	mv	a0,s1
    80005874:	ffffe097          	auipc	ra,0xffffe
    80005878:	3b8080e7          	jalr	952(ra) # 80003c2c <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    8000587c:	fd040593          	addi	a1,s0,-48
    80005880:	f5040513          	addi	a0,s0,-176
    80005884:	fffff097          	auipc	ra,0xfffff
    80005888:	ab0080e7          	jalr	-1360(ra) # 80004334 <nameiparent>
    8000588c:	892a                	mv	s2,a0
    8000588e:	c935                	beqz	a0,80005902 <sys_link+0x10a>
  ilock(dp);
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	2da080e7          	jalr	730(ra) # 80003b6a <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005898:	00092703          	lw	a4,0(s2)
    8000589c:	409c                	lw	a5,0(s1)
    8000589e:	04f71d63          	bne	a4,a5,800058f8 <sys_link+0x100>
    800058a2:	40d0                	lw	a2,4(s1)
    800058a4:	fd040593          	addi	a1,s0,-48
    800058a8:	854a                	mv	a0,s2
    800058aa:	fffff097          	auipc	ra,0xfffff
    800058ae:	9ba080e7          	jalr	-1606(ra) # 80004264 <dirlink>
    800058b2:	04054363          	bltz	a0,800058f8 <sys_link+0x100>
  iunlockput(dp);
    800058b6:	854a                	mv	a0,s2
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	514080e7          	jalr	1300(ra) # 80003dcc <iunlockput>
  iput(ip);
    800058c0:	8526                	mv	a0,s1
    800058c2:	ffffe097          	auipc	ra,0xffffe
    800058c6:	462080e7          	jalr	1122(ra) # 80003d24 <iput>
  end_op();
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	cea080e7          	jalr	-790(ra) # 800045b4 <end_op>
  return 0;
    800058d2:	4781                	li	a5,0
    800058d4:	a085                	j	80005934 <sys_link+0x13c>
    end_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	cde080e7          	jalr	-802(ra) # 800045b4 <end_op>
    return -1;
    800058de:	57fd                	li	a5,-1
    800058e0:	a891                	j	80005934 <sys_link+0x13c>
    iunlockput(ip);
    800058e2:	8526                	mv	a0,s1
    800058e4:	ffffe097          	auipc	ra,0xffffe
    800058e8:	4e8080e7          	jalr	1256(ra) # 80003dcc <iunlockput>
    end_op();
    800058ec:	fffff097          	auipc	ra,0xfffff
    800058f0:	cc8080e7          	jalr	-824(ra) # 800045b4 <end_op>
    return -1;
    800058f4:	57fd                	li	a5,-1
    800058f6:	a83d                	j	80005934 <sys_link+0x13c>
    iunlockput(dp);
    800058f8:	854a                	mv	a0,s2
    800058fa:	ffffe097          	auipc	ra,0xffffe
    800058fe:	4d2080e7          	jalr	1234(ra) # 80003dcc <iunlockput>
  ilock(ip);
    80005902:	8526                	mv	a0,s1
    80005904:	ffffe097          	auipc	ra,0xffffe
    80005908:	266080e7          	jalr	614(ra) # 80003b6a <ilock>
  ip->nlink--;
    8000590c:	04a4d783          	lhu	a5,74(s1)
    80005910:	37fd                	addiw	a5,a5,-1
    80005912:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005916:	8526                	mv	a0,s1
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	186080e7          	jalr	390(ra) # 80003a9e <iupdate>
  iunlockput(ip);
    80005920:	8526                	mv	a0,s1
    80005922:	ffffe097          	auipc	ra,0xffffe
    80005926:	4aa080e7          	jalr	1194(ra) # 80003dcc <iunlockput>
  end_op();
    8000592a:	fffff097          	auipc	ra,0xfffff
    8000592e:	c8a080e7          	jalr	-886(ra) # 800045b4 <end_op>
  return -1;
    80005932:	57fd                	li	a5,-1
}
    80005934:	853e                	mv	a0,a5
    80005936:	70b2                	ld	ra,296(sp)
    80005938:	7412                	ld	s0,288(sp)
    8000593a:	64f2                	ld	s1,280(sp)
    8000593c:	6952                	ld	s2,272(sp)
    8000593e:	6155                	addi	sp,sp,304
    80005940:	8082                	ret

0000000080005942 <sys_unlink>:
{
    80005942:	7151                	addi	sp,sp,-240
    80005944:	f586                	sd	ra,232(sp)
    80005946:	f1a2                	sd	s0,224(sp)
    80005948:	eda6                	sd	s1,216(sp)
    8000594a:	e9ca                	sd	s2,208(sp)
    8000594c:	e5ce                	sd	s3,200(sp)
    8000594e:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005950:	08000613          	li	a2,128
    80005954:	f3040593          	addi	a1,s0,-208
    80005958:	4501                	li	a0,0
    8000595a:	ffffd097          	auipc	ra,0xffffd
    8000595e:	63a080e7          	jalr	1594(ra) # 80002f94 <argstr>
    80005962:	18054163          	bltz	a0,80005ae4 <sys_unlink+0x1a2>
  begin_op();
    80005966:	fffff097          	auipc	ra,0xfffff
    8000596a:	bd0080e7          	jalr	-1072(ra) # 80004536 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    8000596e:	fb040593          	addi	a1,s0,-80
    80005972:	f3040513          	addi	a0,s0,-208
    80005976:	fffff097          	auipc	ra,0xfffff
    8000597a:	9be080e7          	jalr	-1602(ra) # 80004334 <nameiparent>
    8000597e:	84aa                	mv	s1,a0
    80005980:	c979                	beqz	a0,80005a56 <sys_unlink+0x114>
  ilock(dp);
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	1e8080e7          	jalr	488(ra) # 80003b6a <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000598a:	00003597          	auipc	a1,0x3
    8000598e:	e5658593          	addi	a1,a1,-426 # 800087e0 <syscalls+0x2c0>
    80005992:	fb040513          	addi	a0,s0,-80
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	69e080e7          	jalr	1694(ra) # 80004034 <namecmp>
    8000599e:	14050a63          	beqz	a0,80005af2 <sys_unlink+0x1b0>
    800059a2:	00003597          	auipc	a1,0x3
    800059a6:	e4658593          	addi	a1,a1,-442 # 800087e8 <syscalls+0x2c8>
    800059aa:	fb040513          	addi	a0,s0,-80
    800059ae:	ffffe097          	auipc	ra,0xffffe
    800059b2:	686080e7          	jalr	1670(ra) # 80004034 <namecmp>
    800059b6:	12050e63          	beqz	a0,80005af2 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800059ba:	f2c40613          	addi	a2,s0,-212
    800059be:	fb040593          	addi	a1,s0,-80
    800059c2:	8526                	mv	a0,s1
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	68a080e7          	jalr	1674(ra) # 8000404e <dirlookup>
    800059cc:	892a                	mv	s2,a0
    800059ce:	12050263          	beqz	a0,80005af2 <sys_unlink+0x1b0>
  ilock(ip);
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	198080e7          	jalr	408(ra) # 80003b6a <ilock>
  if(ip->nlink < 1)
    800059da:	04a91783          	lh	a5,74(s2)
    800059de:	08f05263          	blez	a5,80005a62 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059e2:	04491703          	lh	a4,68(s2)
    800059e6:	4785                	li	a5,1
    800059e8:	08f70563          	beq	a4,a5,80005a72 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059ec:	4641                	li	a2,16
    800059ee:	4581                	li	a1,0
    800059f0:	fc040513          	addi	a0,s0,-64
    800059f4:	ffffb097          	auipc	ra,0xffffb
    800059f8:	2de080e7          	jalr	734(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059fc:	4741                	li	a4,16
    800059fe:	f2c42683          	lw	a3,-212(s0)
    80005a02:	fc040613          	addi	a2,s0,-64
    80005a06:	4581                	li	a1,0
    80005a08:	8526                	mv	a0,s1
    80005a0a:	ffffe097          	auipc	ra,0xffffe
    80005a0e:	50c080e7          	jalr	1292(ra) # 80003f16 <writei>
    80005a12:	47c1                	li	a5,16
    80005a14:	0af51563          	bne	a0,a5,80005abe <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005a18:	04491703          	lh	a4,68(s2)
    80005a1c:	4785                	li	a5,1
    80005a1e:	0af70863          	beq	a4,a5,80005ace <sys_unlink+0x18c>
  iunlockput(dp);
    80005a22:	8526                	mv	a0,s1
    80005a24:	ffffe097          	auipc	ra,0xffffe
    80005a28:	3a8080e7          	jalr	936(ra) # 80003dcc <iunlockput>
  ip->nlink--;
    80005a2c:	04a95783          	lhu	a5,74(s2)
    80005a30:	37fd                	addiw	a5,a5,-1
    80005a32:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a36:	854a                	mv	a0,s2
    80005a38:	ffffe097          	auipc	ra,0xffffe
    80005a3c:	066080e7          	jalr	102(ra) # 80003a9e <iupdate>
  iunlockput(ip);
    80005a40:	854a                	mv	a0,s2
    80005a42:	ffffe097          	auipc	ra,0xffffe
    80005a46:	38a080e7          	jalr	906(ra) # 80003dcc <iunlockput>
  end_op();
    80005a4a:	fffff097          	auipc	ra,0xfffff
    80005a4e:	b6a080e7          	jalr	-1174(ra) # 800045b4 <end_op>
  return 0;
    80005a52:	4501                	li	a0,0
    80005a54:	a84d                	j	80005b06 <sys_unlink+0x1c4>
    end_op();
    80005a56:	fffff097          	auipc	ra,0xfffff
    80005a5a:	b5e080e7          	jalr	-1186(ra) # 800045b4 <end_op>
    return -1;
    80005a5e:	557d                	li	a0,-1
    80005a60:	a05d                	j	80005b06 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a62:	00003517          	auipc	a0,0x3
    80005a66:	d8e50513          	addi	a0,a0,-626 # 800087f0 <syscalls+0x2d0>
    80005a6a:	ffffb097          	auipc	ra,0xffffb
    80005a6e:	ad6080e7          	jalr	-1322(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a72:	04c92703          	lw	a4,76(s2)
    80005a76:	02000793          	li	a5,32
    80005a7a:	f6e7f9e3          	bgeu	a5,a4,800059ec <sys_unlink+0xaa>
    80005a7e:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a82:	4741                	li	a4,16
    80005a84:	86ce                	mv	a3,s3
    80005a86:	f1840613          	addi	a2,s0,-232
    80005a8a:	4581                	li	a1,0
    80005a8c:	854a                	mv	a0,s2
    80005a8e:	ffffe097          	auipc	ra,0xffffe
    80005a92:	390080e7          	jalr	912(ra) # 80003e1e <readi>
    80005a96:	47c1                	li	a5,16
    80005a98:	00f51b63          	bne	a0,a5,80005aae <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a9c:	f1845783          	lhu	a5,-232(s0)
    80005aa0:	e7a1                	bnez	a5,80005ae8 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005aa2:	29c1                	addiw	s3,s3,16
    80005aa4:	04c92783          	lw	a5,76(s2)
    80005aa8:	fcf9ede3          	bltu	s3,a5,80005a82 <sys_unlink+0x140>
    80005aac:	b781                	j	800059ec <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005aae:	00003517          	auipc	a0,0x3
    80005ab2:	d5a50513          	addi	a0,a0,-678 # 80008808 <syscalls+0x2e8>
    80005ab6:	ffffb097          	auipc	ra,0xffffb
    80005aba:	a8a080e7          	jalr	-1398(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005abe:	00003517          	auipc	a0,0x3
    80005ac2:	d6250513          	addi	a0,a0,-670 # 80008820 <syscalls+0x300>
    80005ac6:	ffffb097          	auipc	ra,0xffffb
    80005aca:	a7a080e7          	jalr	-1414(ra) # 80000540 <panic>
    dp->nlink--;
    80005ace:	04a4d783          	lhu	a5,74(s1)
    80005ad2:	37fd                	addiw	a5,a5,-1
    80005ad4:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005ad8:	8526                	mv	a0,s1
    80005ada:	ffffe097          	auipc	ra,0xffffe
    80005ade:	fc4080e7          	jalr	-60(ra) # 80003a9e <iupdate>
    80005ae2:	b781                	j	80005a22 <sys_unlink+0xe0>
    return -1;
    80005ae4:	557d                	li	a0,-1
    80005ae6:	a005                	j	80005b06 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005ae8:	854a                	mv	a0,s2
    80005aea:	ffffe097          	auipc	ra,0xffffe
    80005aee:	2e2080e7          	jalr	738(ra) # 80003dcc <iunlockput>
  iunlockput(dp);
    80005af2:	8526                	mv	a0,s1
    80005af4:	ffffe097          	auipc	ra,0xffffe
    80005af8:	2d8080e7          	jalr	728(ra) # 80003dcc <iunlockput>
  end_op();
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	ab8080e7          	jalr	-1352(ra) # 800045b4 <end_op>
  return -1;
    80005b04:	557d                	li	a0,-1
}
    80005b06:	70ae                	ld	ra,232(sp)
    80005b08:	740e                	ld	s0,224(sp)
    80005b0a:	64ee                	ld	s1,216(sp)
    80005b0c:	694e                	ld	s2,208(sp)
    80005b0e:	69ae                	ld	s3,200(sp)
    80005b10:	616d                	addi	sp,sp,240
    80005b12:	8082                	ret

0000000080005b14 <sys_open>:

uint64
sys_open(void)
{
    80005b14:	7131                	addi	sp,sp,-192
    80005b16:	fd06                	sd	ra,184(sp)
    80005b18:	f922                	sd	s0,176(sp)
    80005b1a:	f526                	sd	s1,168(sp)
    80005b1c:	f14a                	sd	s2,160(sp)
    80005b1e:	ed4e                	sd	s3,152(sp)
    80005b20:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005b22:	f4c40593          	addi	a1,s0,-180
    80005b26:	4505                	li	a0,1
    80005b28:	ffffd097          	auipc	ra,0xffffd
    80005b2c:	42c080e7          	jalr	1068(ra) # 80002f54 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b30:	08000613          	li	a2,128
    80005b34:	f5040593          	addi	a1,s0,-176
    80005b38:	4501                	li	a0,0
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	45a080e7          	jalr	1114(ra) # 80002f94 <argstr>
    80005b42:	87aa                	mv	a5,a0
    return -1;
    80005b44:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b46:	0a07c963          	bltz	a5,80005bf8 <sys_open+0xe4>

  begin_op();
    80005b4a:	fffff097          	auipc	ra,0xfffff
    80005b4e:	9ec080e7          	jalr	-1556(ra) # 80004536 <begin_op>

  if(omode & O_CREATE){
    80005b52:	f4c42783          	lw	a5,-180(s0)
    80005b56:	2007f793          	andi	a5,a5,512
    80005b5a:	cfc5                	beqz	a5,80005c12 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005b5c:	4681                	li	a3,0
    80005b5e:	4601                	li	a2,0
    80005b60:	4589                	li	a1,2
    80005b62:	f5040513          	addi	a0,s0,-176
    80005b66:	00000097          	auipc	ra,0x0
    80005b6a:	972080e7          	jalr	-1678(ra) # 800054d8 <create>
    80005b6e:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b70:	c959                	beqz	a0,80005c06 <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b72:	04449703          	lh	a4,68(s1)
    80005b76:	478d                	li	a5,3
    80005b78:	00f71763          	bne	a4,a5,80005b86 <sys_open+0x72>
    80005b7c:	0464d703          	lhu	a4,70(s1)
    80005b80:	47a5                	li	a5,9
    80005b82:	0ce7ed63          	bltu	a5,a4,80005c5c <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b86:	fffff097          	auipc	ra,0xfffff
    80005b8a:	dbc080e7          	jalr	-580(ra) # 80004942 <filealloc>
    80005b8e:	89aa                	mv	s3,a0
    80005b90:	10050363          	beqz	a0,80005c96 <sys_open+0x182>
    80005b94:	00000097          	auipc	ra,0x0
    80005b98:	902080e7          	jalr	-1790(ra) # 80005496 <fdalloc>
    80005b9c:	892a                	mv	s2,a0
    80005b9e:	0e054763          	bltz	a0,80005c8c <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005ba2:	04449703          	lh	a4,68(s1)
    80005ba6:	478d                	li	a5,3
    80005ba8:	0cf70563          	beq	a4,a5,80005c72 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005bac:	4789                	li	a5,2
    80005bae:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005bb2:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005bb6:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005bba:	f4c42783          	lw	a5,-180(s0)
    80005bbe:	0017c713          	xori	a4,a5,1
    80005bc2:	8b05                	andi	a4,a4,1
    80005bc4:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005bc8:	0037f713          	andi	a4,a5,3
    80005bcc:	00e03733          	snez	a4,a4
    80005bd0:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005bd4:	4007f793          	andi	a5,a5,1024
    80005bd8:	c791                	beqz	a5,80005be4 <sys_open+0xd0>
    80005bda:	04449703          	lh	a4,68(s1)
    80005bde:	4789                	li	a5,2
    80005be0:	0af70063          	beq	a4,a5,80005c80 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005be4:	8526                	mv	a0,s1
    80005be6:	ffffe097          	auipc	ra,0xffffe
    80005bea:	046080e7          	jalr	70(ra) # 80003c2c <iunlock>
  end_op();
    80005bee:	fffff097          	auipc	ra,0xfffff
    80005bf2:	9c6080e7          	jalr	-1594(ra) # 800045b4 <end_op>

  return fd;
    80005bf6:	854a                	mv	a0,s2
}
    80005bf8:	70ea                	ld	ra,184(sp)
    80005bfa:	744a                	ld	s0,176(sp)
    80005bfc:	74aa                	ld	s1,168(sp)
    80005bfe:	790a                	ld	s2,160(sp)
    80005c00:	69ea                	ld	s3,152(sp)
    80005c02:	6129                	addi	sp,sp,192
    80005c04:	8082                	ret
      end_op();
    80005c06:	fffff097          	auipc	ra,0xfffff
    80005c0a:	9ae080e7          	jalr	-1618(ra) # 800045b4 <end_op>
      return -1;
    80005c0e:	557d                	li	a0,-1
    80005c10:	b7e5                	j	80005bf8 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005c12:	f5040513          	addi	a0,s0,-176
    80005c16:	ffffe097          	auipc	ra,0xffffe
    80005c1a:	700080e7          	jalr	1792(ra) # 80004316 <namei>
    80005c1e:	84aa                	mv	s1,a0
    80005c20:	c905                	beqz	a0,80005c50 <sys_open+0x13c>
    ilock(ip);
    80005c22:	ffffe097          	auipc	ra,0xffffe
    80005c26:	f48080e7          	jalr	-184(ra) # 80003b6a <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005c2a:	04449703          	lh	a4,68(s1)
    80005c2e:	4785                	li	a5,1
    80005c30:	f4f711e3          	bne	a4,a5,80005b72 <sys_open+0x5e>
    80005c34:	f4c42783          	lw	a5,-180(s0)
    80005c38:	d7b9                	beqz	a5,80005b86 <sys_open+0x72>
      iunlockput(ip);
    80005c3a:	8526                	mv	a0,s1
    80005c3c:	ffffe097          	auipc	ra,0xffffe
    80005c40:	190080e7          	jalr	400(ra) # 80003dcc <iunlockput>
      end_op();
    80005c44:	fffff097          	auipc	ra,0xfffff
    80005c48:	970080e7          	jalr	-1680(ra) # 800045b4 <end_op>
      return -1;
    80005c4c:	557d                	li	a0,-1
    80005c4e:	b76d                	j	80005bf8 <sys_open+0xe4>
      end_op();
    80005c50:	fffff097          	auipc	ra,0xfffff
    80005c54:	964080e7          	jalr	-1692(ra) # 800045b4 <end_op>
      return -1;
    80005c58:	557d                	li	a0,-1
    80005c5a:	bf79                	j	80005bf8 <sys_open+0xe4>
    iunlockput(ip);
    80005c5c:	8526                	mv	a0,s1
    80005c5e:	ffffe097          	auipc	ra,0xffffe
    80005c62:	16e080e7          	jalr	366(ra) # 80003dcc <iunlockput>
    end_op();
    80005c66:	fffff097          	auipc	ra,0xfffff
    80005c6a:	94e080e7          	jalr	-1714(ra) # 800045b4 <end_op>
    return -1;
    80005c6e:	557d                	li	a0,-1
    80005c70:	b761                	j	80005bf8 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005c72:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005c76:	04649783          	lh	a5,70(s1)
    80005c7a:	02f99223          	sh	a5,36(s3)
    80005c7e:	bf25                	j	80005bb6 <sys_open+0xa2>
    itrunc(ip);
    80005c80:	8526                	mv	a0,s1
    80005c82:	ffffe097          	auipc	ra,0xffffe
    80005c86:	ff6080e7          	jalr	-10(ra) # 80003c78 <itrunc>
    80005c8a:	bfa9                	j	80005be4 <sys_open+0xd0>
      fileclose(f);
    80005c8c:	854e                	mv	a0,s3
    80005c8e:	fffff097          	auipc	ra,0xfffff
    80005c92:	d70080e7          	jalr	-656(ra) # 800049fe <fileclose>
    iunlockput(ip);
    80005c96:	8526                	mv	a0,s1
    80005c98:	ffffe097          	auipc	ra,0xffffe
    80005c9c:	134080e7          	jalr	308(ra) # 80003dcc <iunlockput>
    end_op();
    80005ca0:	fffff097          	auipc	ra,0xfffff
    80005ca4:	914080e7          	jalr	-1772(ra) # 800045b4 <end_op>
    return -1;
    80005ca8:	557d                	li	a0,-1
    80005caa:	b7b9                	j	80005bf8 <sys_open+0xe4>

0000000080005cac <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005cac:	7175                	addi	sp,sp,-144
    80005cae:	e506                	sd	ra,136(sp)
    80005cb0:	e122                	sd	s0,128(sp)
    80005cb2:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	882080e7          	jalr	-1918(ra) # 80004536 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005cbc:	08000613          	li	a2,128
    80005cc0:	f7040593          	addi	a1,s0,-144
    80005cc4:	4501                	li	a0,0
    80005cc6:	ffffd097          	auipc	ra,0xffffd
    80005cca:	2ce080e7          	jalr	718(ra) # 80002f94 <argstr>
    80005cce:	02054963          	bltz	a0,80005d00 <sys_mkdir+0x54>
    80005cd2:	4681                	li	a3,0
    80005cd4:	4601                	li	a2,0
    80005cd6:	4585                	li	a1,1
    80005cd8:	f7040513          	addi	a0,s0,-144
    80005cdc:	fffff097          	auipc	ra,0xfffff
    80005ce0:	7fc080e7          	jalr	2044(ra) # 800054d8 <create>
    80005ce4:	cd11                	beqz	a0,80005d00 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005ce6:	ffffe097          	auipc	ra,0xffffe
    80005cea:	0e6080e7          	jalr	230(ra) # 80003dcc <iunlockput>
  end_op();
    80005cee:	fffff097          	auipc	ra,0xfffff
    80005cf2:	8c6080e7          	jalr	-1850(ra) # 800045b4 <end_op>
  return 0;
    80005cf6:	4501                	li	a0,0
}
    80005cf8:	60aa                	ld	ra,136(sp)
    80005cfa:	640a                	ld	s0,128(sp)
    80005cfc:	6149                	addi	sp,sp,144
    80005cfe:	8082                	ret
    end_op();
    80005d00:	fffff097          	auipc	ra,0xfffff
    80005d04:	8b4080e7          	jalr	-1868(ra) # 800045b4 <end_op>
    return -1;
    80005d08:	557d                	li	a0,-1
    80005d0a:	b7fd                	j	80005cf8 <sys_mkdir+0x4c>

0000000080005d0c <sys_mknod>:

uint64
sys_mknod(void)
{
    80005d0c:	7135                	addi	sp,sp,-160
    80005d0e:	ed06                	sd	ra,152(sp)
    80005d10:	e922                	sd	s0,144(sp)
    80005d12:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005d14:	fffff097          	auipc	ra,0xfffff
    80005d18:	822080e7          	jalr	-2014(ra) # 80004536 <begin_op>
  argint(1, &major);
    80005d1c:	f6c40593          	addi	a1,s0,-148
    80005d20:	4505                	li	a0,1
    80005d22:	ffffd097          	auipc	ra,0xffffd
    80005d26:	232080e7          	jalr	562(ra) # 80002f54 <argint>
  argint(2, &minor);
    80005d2a:	f6840593          	addi	a1,s0,-152
    80005d2e:	4509                	li	a0,2
    80005d30:	ffffd097          	auipc	ra,0xffffd
    80005d34:	224080e7          	jalr	548(ra) # 80002f54 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d38:	08000613          	li	a2,128
    80005d3c:	f7040593          	addi	a1,s0,-144
    80005d40:	4501                	li	a0,0
    80005d42:	ffffd097          	auipc	ra,0xffffd
    80005d46:	252080e7          	jalr	594(ra) # 80002f94 <argstr>
    80005d4a:	02054b63          	bltz	a0,80005d80 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d4e:	f6841683          	lh	a3,-152(s0)
    80005d52:	f6c41603          	lh	a2,-148(s0)
    80005d56:	458d                	li	a1,3
    80005d58:	f7040513          	addi	a0,s0,-144
    80005d5c:	fffff097          	auipc	ra,0xfffff
    80005d60:	77c080e7          	jalr	1916(ra) # 800054d8 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d64:	cd11                	beqz	a0,80005d80 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d66:	ffffe097          	auipc	ra,0xffffe
    80005d6a:	066080e7          	jalr	102(ra) # 80003dcc <iunlockput>
  end_op();
    80005d6e:	fffff097          	auipc	ra,0xfffff
    80005d72:	846080e7          	jalr	-1978(ra) # 800045b4 <end_op>
  return 0;
    80005d76:	4501                	li	a0,0
}
    80005d78:	60ea                	ld	ra,152(sp)
    80005d7a:	644a                	ld	s0,144(sp)
    80005d7c:	610d                	addi	sp,sp,160
    80005d7e:	8082                	ret
    end_op();
    80005d80:	fffff097          	auipc	ra,0xfffff
    80005d84:	834080e7          	jalr	-1996(ra) # 800045b4 <end_op>
    return -1;
    80005d88:	557d                	li	a0,-1
    80005d8a:	b7fd                	j	80005d78 <sys_mknod+0x6c>

0000000080005d8c <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d8c:	7135                	addi	sp,sp,-160
    80005d8e:	ed06                	sd	ra,152(sp)
    80005d90:	e922                	sd	s0,144(sp)
    80005d92:	e526                	sd	s1,136(sp)
    80005d94:	e14a                	sd	s2,128(sp)
    80005d96:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d98:	ffffc097          	auipc	ra,0xffffc
    80005d9c:	e56080e7          	jalr	-426(ra) # 80001bee <myproc>
    80005da0:	892a                	mv	s2,a0
  
  begin_op();
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	794080e7          	jalr	1940(ra) # 80004536 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005daa:	08000613          	li	a2,128
    80005dae:	f6040593          	addi	a1,s0,-160
    80005db2:	4501                	li	a0,0
    80005db4:	ffffd097          	auipc	ra,0xffffd
    80005db8:	1e0080e7          	jalr	480(ra) # 80002f94 <argstr>
    80005dbc:	04054b63          	bltz	a0,80005e12 <sys_chdir+0x86>
    80005dc0:	f6040513          	addi	a0,s0,-160
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	552080e7          	jalr	1362(ra) # 80004316 <namei>
    80005dcc:	84aa                	mv	s1,a0
    80005dce:	c131                	beqz	a0,80005e12 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005dd0:	ffffe097          	auipc	ra,0xffffe
    80005dd4:	d9a080e7          	jalr	-614(ra) # 80003b6a <ilock>
  if(ip->type != T_DIR){
    80005dd8:	04449703          	lh	a4,68(s1)
    80005ddc:	4785                	li	a5,1
    80005dde:	04f71063          	bne	a4,a5,80005e1e <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005de2:	8526                	mv	a0,s1
    80005de4:	ffffe097          	auipc	ra,0xffffe
    80005de8:	e48080e7          	jalr	-440(ra) # 80003c2c <iunlock>
  iput(p->cwd);
    80005dec:	15893503          	ld	a0,344(s2)
    80005df0:	ffffe097          	auipc	ra,0xffffe
    80005df4:	f34080e7          	jalr	-204(ra) # 80003d24 <iput>
  end_op();
    80005df8:	ffffe097          	auipc	ra,0xffffe
    80005dfc:	7bc080e7          	jalr	1980(ra) # 800045b4 <end_op>
  p->cwd = ip;
    80005e00:	14993c23          	sd	s1,344(s2)
  return 0;
    80005e04:	4501                	li	a0,0
}
    80005e06:	60ea                	ld	ra,152(sp)
    80005e08:	644a                	ld	s0,144(sp)
    80005e0a:	64aa                	ld	s1,136(sp)
    80005e0c:	690a                	ld	s2,128(sp)
    80005e0e:	610d                	addi	sp,sp,160
    80005e10:	8082                	ret
    end_op();
    80005e12:	ffffe097          	auipc	ra,0xffffe
    80005e16:	7a2080e7          	jalr	1954(ra) # 800045b4 <end_op>
    return -1;
    80005e1a:	557d                	li	a0,-1
    80005e1c:	b7ed                	j	80005e06 <sys_chdir+0x7a>
    iunlockput(ip);
    80005e1e:	8526                	mv	a0,s1
    80005e20:	ffffe097          	auipc	ra,0xffffe
    80005e24:	fac080e7          	jalr	-84(ra) # 80003dcc <iunlockput>
    end_op();
    80005e28:	ffffe097          	auipc	ra,0xffffe
    80005e2c:	78c080e7          	jalr	1932(ra) # 800045b4 <end_op>
    return -1;
    80005e30:	557d                	li	a0,-1
    80005e32:	bfd1                	j	80005e06 <sys_chdir+0x7a>

0000000080005e34 <sys_exec>:

uint64
sys_exec(void)
{
    80005e34:	7145                	addi	sp,sp,-464
    80005e36:	e786                	sd	ra,456(sp)
    80005e38:	e3a2                	sd	s0,448(sp)
    80005e3a:	ff26                	sd	s1,440(sp)
    80005e3c:	fb4a                	sd	s2,432(sp)
    80005e3e:	f74e                	sd	s3,424(sp)
    80005e40:	f352                	sd	s4,416(sp)
    80005e42:	ef56                	sd	s5,408(sp)
    80005e44:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e46:	e3840593          	addi	a1,s0,-456
    80005e4a:	4505                	li	a0,1
    80005e4c:	ffffd097          	auipc	ra,0xffffd
    80005e50:	128080e7          	jalr	296(ra) # 80002f74 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e54:	08000613          	li	a2,128
    80005e58:	f4040593          	addi	a1,s0,-192
    80005e5c:	4501                	li	a0,0
    80005e5e:	ffffd097          	auipc	ra,0xffffd
    80005e62:	136080e7          	jalr	310(ra) # 80002f94 <argstr>
    80005e66:	87aa                	mv	a5,a0
    return -1;
    80005e68:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e6a:	0c07c363          	bltz	a5,80005f30 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005e6e:	10000613          	li	a2,256
    80005e72:	4581                	li	a1,0
    80005e74:	e4040513          	addi	a0,s0,-448
    80005e78:	ffffb097          	auipc	ra,0xffffb
    80005e7c:	e5a080e7          	jalr	-422(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e80:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005e84:	89a6                	mv	s3,s1
    80005e86:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e88:	02000a13          	li	s4,32
    80005e8c:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e90:	00391513          	slli	a0,s2,0x3
    80005e94:	e3040593          	addi	a1,s0,-464
    80005e98:	e3843783          	ld	a5,-456(s0)
    80005e9c:	953e                	add	a0,a0,a5
    80005e9e:	ffffd097          	auipc	ra,0xffffd
    80005ea2:	018080e7          	jalr	24(ra) # 80002eb6 <fetchaddr>
    80005ea6:	02054a63          	bltz	a0,80005eda <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005eaa:	e3043783          	ld	a5,-464(s0)
    80005eae:	c3b9                	beqz	a5,80005ef4 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	c36080e7          	jalr	-970(ra) # 80000ae6 <kalloc>
    80005eb8:	85aa                	mv	a1,a0
    80005eba:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ebe:	cd11                	beqz	a0,80005eda <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ec0:	6605                	lui	a2,0x1
    80005ec2:	e3043503          	ld	a0,-464(s0)
    80005ec6:	ffffd097          	auipc	ra,0xffffd
    80005eca:	042080e7          	jalr	66(ra) # 80002f08 <fetchstr>
    80005ece:	00054663          	bltz	a0,80005eda <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005ed2:	0905                	addi	s2,s2,1
    80005ed4:	09a1                	addi	s3,s3,8
    80005ed6:	fb491be3          	bne	s2,s4,80005e8c <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eda:	f4040913          	addi	s2,s0,-192
    80005ede:	6088                	ld	a0,0(s1)
    80005ee0:	c539                	beqz	a0,80005f2e <sys_exec+0xfa>
    kfree(argv[i]);
    80005ee2:	ffffb097          	auipc	ra,0xffffb
    80005ee6:	b06080e7          	jalr	-1274(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eea:	04a1                	addi	s1,s1,8
    80005eec:	ff2499e3          	bne	s1,s2,80005ede <sys_exec+0xaa>
  return -1;
    80005ef0:	557d                	li	a0,-1
    80005ef2:	a83d                	j	80005f30 <sys_exec+0xfc>
      argv[i] = 0;
    80005ef4:	0a8e                	slli	s5,s5,0x3
    80005ef6:	fc0a8793          	addi	a5,s5,-64
    80005efa:	00878ab3          	add	s5,a5,s0
    80005efe:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005f02:	e4040593          	addi	a1,s0,-448
    80005f06:	f4040513          	addi	a0,s0,-192
    80005f0a:	fffff097          	auipc	ra,0xfffff
    80005f0e:	16e080e7          	jalr	366(ra) # 80005078 <exec>
    80005f12:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f14:	f4040993          	addi	s3,s0,-192
    80005f18:	6088                	ld	a0,0(s1)
    80005f1a:	c901                	beqz	a0,80005f2a <sys_exec+0xf6>
    kfree(argv[i]);
    80005f1c:	ffffb097          	auipc	ra,0xffffb
    80005f20:	acc080e7          	jalr	-1332(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005f24:	04a1                	addi	s1,s1,8
    80005f26:	ff3499e3          	bne	s1,s3,80005f18 <sys_exec+0xe4>
  return ret;
    80005f2a:	854a                	mv	a0,s2
    80005f2c:	a011                	j	80005f30 <sys_exec+0xfc>
  return -1;
    80005f2e:	557d                	li	a0,-1
}
    80005f30:	60be                	ld	ra,456(sp)
    80005f32:	641e                	ld	s0,448(sp)
    80005f34:	74fa                	ld	s1,440(sp)
    80005f36:	795a                	ld	s2,432(sp)
    80005f38:	79ba                	ld	s3,424(sp)
    80005f3a:	7a1a                	ld	s4,416(sp)
    80005f3c:	6afa                	ld	s5,408(sp)
    80005f3e:	6179                	addi	sp,sp,464
    80005f40:	8082                	ret

0000000080005f42 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f42:	7139                	addi	sp,sp,-64
    80005f44:	fc06                	sd	ra,56(sp)
    80005f46:	f822                	sd	s0,48(sp)
    80005f48:	f426                	sd	s1,40(sp)
    80005f4a:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f4c:	ffffc097          	auipc	ra,0xffffc
    80005f50:	ca2080e7          	jalr	-862(ra) # 80001bee <myproc>
    80005f54:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f56:	fd840593          	addi	a1,s0,-40
    80005f5a:	4501                	li	a0,0
    80005f5c:	ffffd097          	auipc	ra,0xffffd
    80005f60:	018080e7          	jalr	24(ra) # 80002f74 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f64:	fc840593          	addi	a1,s0,-56
    80005f68:	fd040513          	addi	a0,s0,-48
    80005f6c:	fffff097          	auipc	ra,0xfffff
    80005f70:	dc2080e7          	jalr	-574(ra) # 80004d2e <pipealloc>
    return -1;
    80005f74:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f76:	0c054463          	bltz	a0,8000603e <sys_pipe+0xfc>
  fd0 = -1;
    80005f7a:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f7e:	fd043503          	ld	a0,-48(s0)
    80005f82:	fffff097          	auipc	ra,0xfffff
    80005f86:	514080e7          	jalr	1300(ra) # 80005496 <fdalloc>
    80005f8a:	fca42223          	sw	a0,-60(s0)
    80005f8e:	08054b63          	bltz	a0,80006024 <sys_pipe+0xe2>
    80005f92:	fc843503          	ld	a0,-56(s0)
    80005f96:	fffff097          	auipc	ra,0xfffff
    80005f9a:	500080e7          	jalr	1280(ra) # 80005496 <fdalloc>
    80005f9e:	fca42023          	sw	a0,-64(s0)
    80005fa2:	06054863          	bltz	a0,80006012 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fa6:	4691                	li	a3,4
    80005fa8:	fc440613          	addi	a2,s0,-60
    80005fac:	fd843583          	ld	a1,-40(s0)
    80005fb0:	6ca8                	ld	a0,88(s1)
    80005fb2:	ffffb097          	auipc	ra,0xffffb
    80005fb6:	6ba080e7          	jalr	1722(ra) # 8000166c <copyout>
    80005fba:	02054063          	bltz	a0,80005fda <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005fbe:	4691                	li	a3,4
    80005fc0:	fc040613          	addi	a2,s0,-64
    80005fc4:	fd843583          	ld	a1,-40(s0)
    80005fc8:	0591                	addi	a1,a1,4
    80005fca:	6ca8                	ld	a0,88(s1)
    80005fcc:	ffffb097          	auipc	ra,0xffffb
    80005fd0:	6a0080e7          	jalr	1696(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fd4:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fd6:	06055463          	bgez	a0,8000603e <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fda:	fc442783          	lw	a5,-60(s0)
    80005fde:	07e9                	addi	a5,a5,26
    80005fe0:	078e                	slli	a5,a5,0x3
    80005fe2:	97a6                	add	a5,a5,s1
    80005fe4:	0007b423          	sd	zero,8(a5)
    p->ofile[fd1] = 0;
    80005fe8:	fc042783          	lw	a5,-64(s0)
    80005fec:	07e9                	addi	a5,a5,26
    80005fee:	078e                	slli	a5,a5,0x3
    80005ff0:	94be                	add	s1,s1,a5
    80005ff2:	0004b423          	sd	zero,8(s1)
    fileclose(rf);
    80005ff6:	fd043503          	ld	a0,-48(s0)
    80005ffa:	fffff097          	auipc	ra,0xfffff
    80005ffe:	a04080e7          	jalr	-1532(ra) # 800049fe <fileclose>
    fileclose(wf);
    80006002:	fc843503          	ld	a0,-56(s0)
    80006006:	fffff097          	auipc	ra,0xfffff
    8000600a:	9f8080e7          	jalr	-1544(ra) # 800049fe <fileclose>
    return -1;
    8000600e:	57fd                	li	a5,-1
    80006010:	a03d                	j	8000603e <sys_pipe+0xfc>
    if(fd0 >= 0)
    80006012:	fc442783          	lw	a5,-60(s0)
    80006016:	0007c763          	bltz	a5,80006024 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    8000601a:	07e9                	addi	a5,a5,26
    8000601c:	078e                	slli	a5,a5,0x3
    8000601e:	97a6                	add	a5,a5,s1
    80006020:	0007b423          	sd	zero,8(a5)
    fileclose(rf);
    80006024:	fd043503          	ld	a0,-48(s0)
    80006028:	fffff097          	auipc	ra,0xfffff
    8000602c:	9d6080e7          	jalr	-1578(ra) # 800049fe <fileclose>
    fileclose(wf);
    80006030:	fc843503          	ld	a0,-56(s0)
    80006034:	fffff097          	auipc	ra,0xfffff
    80006038:	9ca080e7          	jalr	-1590(ra) # 800049fe <fileclose>
    return -1;
    8000603c:	57fd                	li	a5,-1
}
    8000603e:	853e                	mv	a0,a5
    80006040:	70e2                	ld	ra,56(sp)
    80006042:	7442                	ld	s0,48(sp)
    80006044:	74a2                	ld	s1,40(sp)
    80006046:	6121                	addi	sp,sp,64
    80006048:	8082                	ret
    8000604a:	0000                	unimp
    8000604c:	0000                	unimp
	...

0000000080006050 <kernelvec>:
    80006050:	7111                	addi	sp,sp,-256
    80006052:	e006                	sd	ra,0(sp)
    80006054:	e40a                	sd	sp,8(sp)
    80006056:	e80e                	sd	gp,16(sp)
    80006058:	ec12                	sd	tp,24(sp)
    8000605a:	f016                	sd	t0,32(sp)
    8000605c:	f41a                	sd	t1,40(sp)
    8000605e:	f81e                	sd	t2,48(sp)
    80006060:	fc22                	sd	s0,56(sp)
    80006062:	e0a6                	sd	s1,64(sp)
    80006064:	e4aa                	sd	a0,72(sp)
    80006066:	e8ae                	sd	a1,80(sp)
    80006068:	ecb2                	sd	a2,88(sp)
    8000606a:	f0b6                	sd	a3,96(sp)
    8000606c:	f4ba                	sd	a4,104(sp)
    8000606e:	f8be                	sd	a5,112(sp)
    80006070:	fcc2                	sd	a6,120(sp)
    80006072:	e146                	sd	a7,128(sp)
    80006074:	e54a                	sd	s2,136(sp)
    80006076:	e94e                	sd	s3,144(sp)
    80006078:	ed52                	sd	s4,152(sp)
    8000607a:	f156                	sd	s5,160(sp)
    8000607c:	f55a                	sd	s6,168(sp)
    8000607e:	f95e                	sd	s7,176(sp)
    80006080:	fd62                	sd	s8,184(sp)
    80006082:	e1e6                	sd	s9,192(sp)
    80006084:	e5ea                	sd	s10,200(sp)
    80006086:	e9ee                	sd	s11,208(sp)
    80006088:	edf2                	sd	t3,216(sp)
    8000608a:	f1f6                	sd	t4,224(sp)
    8000608c:	f5fa                	sd	t5,232(sp)
    8000608e:	f9fe                	sd	t6,240(sp)
    80006090:	cf1fc0ef          	jal	ra,80002d80 <kerneltrap>
    80006094:	6082                	ld	ra,0(sp)
    80006096:	6122                	ld	sp,8(sp)
    80006098:	61c2                	ld	gp,16(sp)
    8000609a:	7282                	ld	t0,32(sp)
    8000609c:	7322                	ld	t1,40(sp)
    8000609e:	73c2                	ld	t2,48(sp)
    800060a0:	7462                	ld	s0,56(sp)
    800060a2:	6486                	ld	s1,64(sp)
    800060a4:	6526                	ld	a0,72(sp)
    800060a6:	65c6                	ld	a1,80(sp)
    800060a8:	6666                	ld	a2,88(sp)
    800060aa:	7686                	ld	a3,96(sp)
    800060ac:	7726                	ld	a4,104(sp)
    800060ae:	77c6                	ld	a5,112(sp)
    800060b0:	7866                	ld	a6,120(sp)
    800060b2:	688a                	ld	a7,128(sp)
    800060b4:	692a                	ld	s2,136(sp)
    800060b6:	69ca                	ld	s3,144(sp)
    800060b8:	6a6a                	ld	s4,152(sp)
    800060ba:	7a8a                	ld	s5,160(sp)
    800060bc:	7b2a                	ld	s6,168(sp)
    800060be:	7bca                	ld	s7,176(sp)
    800060c0:	7c6a                	ld	s8,184(sp)
    800060c2:	6c8e                	ld	s9,192(sp)
    800060c4:	6d2e                	ld	s10,200(sp)
    800060c6:	6dce                	ld	s11,208(sp)
    800060c8:	6e6e                	ld	t3,216(sp)
    800060ca:	7e8e                	ld	t4,224(sp)
    800060cc:	7f2e                	ld	t5,232(sp)
    800060ce:	7fce                	ld	t6,240(sp)
    800060d0:	6111                	addi	sp,sp,256
    800060d2:	10200073          	sret
    800060d6:	00000013          	nop
    800060da:	00000013          	nop
    800060de:	0001                	nop

00000000800060e0 <timervec>:
    800060e0:	34051573          	csrrw	a0,mscratch,a0
    800060e4:	e10c                	sd	a1,0(a0)
    800060e6:	e510                	sd	a2,8(a0)
    800060e8:	e914                	sd	a3,16(a0)
    800060ea:	6d0c                	ld	a1,24(a0)
    800060ec:	7110                	ld	a2,32(a0)
    800060ee:	6194                	ld	a3,0(a1)
    800060f0:	96b2                	add	a3,a3,a2
    800060f2:	e194                	sd	a3,0(a1)
    800060f4:	4589                	li	a1,2
    800060f6:	14459073          	csrw	sip,a1
    800060fa:	6914                	ld	a3,16(a0)
    800060fc:	6510                	ld	a2,8(a0)
    800060fe:	610c                	ld	a1,0(a0)
    80006100:	34051573          	csrrw	a0,mscratch,a0
    80006104:	30200073          	mret
	...

000000008000610a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000610a:	1141                	addi	sp,sp,-16
    8000610c:	e422                	sd	s0,8(sp)
    8000610e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80006110:	0c0007b7          	lui	a5,0xc000
    80006114:	4705                	li	a4,1
    80006116:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80006118:	c3d8                	sw	a4,4(a5)
}
    8000611a:	6422                	ld	s0,8(sp)
    8000611c:	0141                	addi	sp,sp,16
    8000611e:	8082                	ret

0000000080006120 <plicinithart>:

void
plicinithart(void)
{
    80006120:	1141                	addi	sp,sp,-16
    80006122:	e406                	sd	ra,8(sp)
    80006124:	e022                	sd	s0,0(sp)
    80006126:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006128:	ffffc097          	auipc	ra,0xffffc
    8000612c:	a9a080e7          	jalr	-1382(ra) # 80001bc2 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006130:	0085171b          	slliw	a4,a0,0x8
    80006134:	0c0027b7          	lui	a5,0xc002
    80006138:	97ba                	add	a5,a5,a4
    8000613a:	40200713          	li	a4,1026
    8000613e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006142:	00d5151b          	slliw	a0,a0,0xd
    80006146:	0c2017b7          	lui	a5,0xc201
    8000614a:	97aa                	add	a5,a5,a0
    8000614c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006150:	60a2                	ld	ra,8(sp)
    80006152:	6402                	ld	s0,0(sp)
    80006154:	0141                	addi	sp,sp,16
    80006156:	8082                	ret

0000000080006158 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006158:	1141                	addi	sp,sp,-16
    8000615a:	e406                	sd	ra,8(sp)
    8000615c:	e022                	sd	s0,0(sp)
    8000615e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006160:	ffffc097          	auipc	ra,0xffffc
    80006164:	a62080e7          	jalr	-1438(ra) # 80001bc2 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006168:	00d5151b          	slliw	a0,a0,0xd
    8000616c:	0c2017b7          	lui	a5,0xc201
    80006170:	97aa                	add	a5,a5,a0
  return irq;
}
    80006172:	43c8                	lw	a0,4(a5)
    80006174:	60a2                	ld	ra,8(sp)
    80006176:	6402                	ld	s0,0(sp)
    80006178:	0141                	addi	sp,sp,16
    8000617a:	8082                	ret

000000008000617c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000617c:	1101                	addi	sp,sp,-32
    8000617e:	ec06                	sd	ra,24(sp)
    80006180:	e822                	sd	s0,16(sp)
    80006182:	e426                	sd	s1,8(sp)
    80006184:	1000                	addi	s0,sp,32
    80006186:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006188:	ffffc097          	auipc	ra,0xffffc
    8000618c:	a3a080e7          	jalr	-1478(ra) # 80001bc2 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006190:	00d5151b          	slliw	a0,a0,0xd
    80006194:	0c2017b7          	lui	a5,0xc201
    80006198:	97aa                	add	a5,a5,a0
    8000619a:	c3c4                	sw	s1,4(a5)
}
    8000619c:	60e2                	ld	ra,24(sp)
    8000619e:	6442                	ld	s0,16(sp)
    800061a0:	64a2                	ld	s1,8(sp)
    800061a2:	6105                	addi	sp,sp,32
    800061a4:	8082                	ret

00000000800061a6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800061a6:	1141                	addi	sp,sp,-16
    800061a8:	e406                	sd	ra,8(sp)
    800061aa:	e022                	sd	s0,0(sp)
    800061ac:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800061ae:	479d                	li	a5,7
    800061b0:	04a7cc63          	blt	a5,a0,80006208 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    800061b4:	0001c797          	auipc	a5,0x1c
    800061b8:	dac78793          	addi	a5,a5,-596 # 80021f60 <disk>
    800061bc:	97aa                	add	a5,a5,a0
    800061be:	0187c783          	lbu	a5,24(a5)
    800061c2:	ebb9                	bnez	a5,80006218 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800061c4:	00451693          	slli	a3,a0,0x4
    800061c8:	0001c797          	auipc	a5,0x1c
    800061cc:	d9878793          	addi	a5,a5,-616 # 80021f60 <disk>
    800061d0:	6398                	ld	a4,0(a5)
    800061d2:	9736                	add	a4,a4,a3
    800061d4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800061d8:	6398                	ld	a4,0(a5)
    800061da:	9736                	add	a4,a4,a3
    800061dc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061e0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061e4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061e8:	97aa                	add	a5,a5,a0
    800061ea:	4705                	li	a4,1
    800061ec:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800061f0:	0001c517          	auipc	a0,0x1c
    800061f4:	d8850513          	addi	a0,a0,-632 # 80021f78 <disk+0x18>
    800061f8:	ffffc097          	auipc	ra,0xffffc
    800061fc:	208080e7          	jalr	520(ra) # 80002400 <wakeup>
}
    80006200:	60a2                	ld	ra,8(sp)
    80006202:	6402                	ld	s0,0(sp)
    80006204:	0141                	addi	sp,sp,16
    80006206:	8082                	ret
    panic("free_desc 1");
    80006208:	00002517          	auipc	a0,0x2
    8000620c:	62850513          	addi	a0,a0,1576 # 80008830 <syscalls+0x310>
    80006210:	ffffa097          	auipc	ra,0xffffa
    80006214:	330080e7          	jalr	816(ra) # 80000540 <panic>
    panic("free_desc 2");
    80006218:	00002517          	auipc	a0,0x2
    8000621c:	62850513          	addi	a0,a0,1576 # 80008840 <syscalls+0x320>
    80006220:	ffffa097          	auipc	ra,0xffffa
    80006224:	320080e7          	jalr	800(ra) # 80000540 <panic>

0000000080006228 <virtio_disk_init>:
{
    80006228:	1101                	addi	sp,sp,-32
    8000622a:	ec06                	sd	ra,24(sp)
    8000622c:	e822                	sd	s0,16(sp)
    8000622e:	e426                	sd	s1,8(sp)
    80006230:	e04a                	sd	s2,0(sp)
    80006232:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006234:	00002597          	auipc	a1,0x2
    80006238:	61c58593          	addi	a1,a1,1564 # 80008850 <syscalls+0x330>
    8000623c:	0001c517          	auipc	a0,0x1c
    80006240:	e4c50513          	addi	a0,a0,-436 # 80022088 <disk+0x128>
    80006244:	ffffb097          	auipc	ra,0xffffb
    80006248:	902080e7          	jalr	-1790(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000624c:	100017b7          	lui	a5,0x10001
    80006250:	4398                	lw	a4,0(a5)
    80006252:	2701                	sext.w	a4,a4
    80006254:	747277b7          	lui	a5,0x74727
    80006258:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000625c:	14f71b63          	bne	a4,a5,800063b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006260:	100017b7          	lui	a5,0x10001
    80006264:	43dc                	lw	a5,4(a5)
    80006266:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006268:	4709                	li	a4,2
    8000626a:	14e79463          	bne	a5,a4,800063b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000626e:	100017b7          	lui	a5,0x10001
    80006272:	479c                	lw	a5,8(a5)
    80006274:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006276:	12e79e63          	bne	a5,a4,800063b2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000627a:	100017b7          	lui	a5,0x10001
    8000627e:	47d8                	lw	a4,12(a5)
    80006280:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006282:	554d47b7          	lui	a5,0x554d4
    80006286:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000628a:	12f71463          	bne	a4,a5,800063b2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000628e:	100017b7          	lui	a5,0x10001
    80006292:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006296:	4705                	li	a4,1
    80006298:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000629a:	470d                	li	a4,3
    8000629c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000629e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    800062a0:	c7ffe6b7          	lui	a3,0xc7ffe
    800062a4:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc6bf>
    800062a8:	8f75                	and	a4,a4,a3
    800062aa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800062ac:	472d                	li	a4,11
    800062ae:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    800062b0:	5bbc                	lw	a5,112(a5)
    800062b2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800062b6:	8ba1                	andi	a5,a5,8
    800062b8:	10078563          	beqz	a5,800063c2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800062bc:	100017b7          	lui	a5,0x10001
    800062c0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800062c4:	43fc                	lw	a5,68(a5)
    800062c6:	2781                	sext.w	a5,a5
    800062c8:	10079563          	bnez	a5,800063d2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800062cc:	100017b7          	lui	a5,0x10001
    800062d0:	5bdc                	lw	a5,52(a5)
    800062d2:	2781                	sext.w	a5,a5
  if(max == 0)
    800062d4:	10078763          	beqz	a5,800063e2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800062d8:	471d                	li	a4,7
    800062da:	10f77c63          	bgeu	a4,a5,800063f2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800062de:	ffffb097          	auipc	ra,0xffffb
    800062e2:	808080e7          	jalr	-2040(ra) # 80000ae6 <kalloc>
    800062e6:	0001c497          	auipc	s1,0x1c
    800062ea:	c7a48493          	addi	s1,s1,-902 # 80021f60 <disk>
    800062ee:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062f0:	ffffa097          	auipc	ra,0xffffa
    800062f4:	7f6080e7          	jalr	2038(ra) # 80000ae6 <kalloc>
    800062f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062fa:	ffffa097          	auipc	ra,0xffffa
    800062fe:	7ec080e7          	jalr	2028(ra) # 80000ae6 <kalloc>
    80006302:	87aa                	mv	a5,a0
    80006304:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80006306:	6088                	ld	a0,0(s1)
    80006308:	cd6d                	beqz	a0,80006402 <virtio_disk_init+0x1da>
    8000630a:	0001c717          	auipc	a4,0x1c
    8000630e:	c5e73703          	ld	a4,-930(a4) # 80021f68 <disk+0x8>
    80006312:	cb65                	beqz	a4,80006402 <virtio_disk_init+0x1da>
    80006314:	c7fd                	beqz	a5,80006402 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80006316:	6605                	lui	a2,0x1
    80006318:	4581                	li	a1,0
    8000631a:	ffffb097          	auipc	ra,0xffffb
    8000631e:	9b8080e7          	jalr	-1608(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    80006322:	0001c497          	auipc	s1,0x1c
    80006326:	c3e48493          	addi	s1,s1,-962 # 80021f60 <disk>
    8000632a:	6605                	lui	a2,0x1
    8000632c:	4581                	li	a1,0
    8000632e:	6488                	ld	a0,8(s1)
    80006330:	ffffb097          	auipc	ra,0xffffb
    80006334:	9a2080e7          	jalr	-1630(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    80006338:	6605                	lui	a2,0x1
    8000633a:	4581                	li	a1,0
    8000633c:	6888                	ld	a0,16(s1)
    8000633e:	ffffb097          	auipc	ra,0xffffb
    80006342:	994080e7          	jalr	-1644(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006346:	100017b7          	lui	a5,0x10001
    8000634a:	4721                	li	a4,8
    8000634c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000634e:	4098                	lw	a4,0(s1)
    80006350:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006354:	40d8                	lw	a4,4(s1)
    80006356:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000635a:	6498                	ld	a4,8(s1)
    8000635c:	0007069b          	sext.w	a3,a4
    80006360:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006364:	9701                	srai	a4,a4,0x20
    80006366:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000636a:	6898                	ld	a4,16(s1)
    8000636c:	0007069b          	sext.w	a3,a4
    80006370:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006374:	9701                	srai	a4,a4,0x20
    80006376:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000637a:	4705                	li	a4,1
    8000637c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000637e:	00e48c23          	sb	a4,24(s1)
    80006382:	00e48ca3          	sb	a4,25(s1)
    80006386:	00e48d23          	sb	a4,26(s1)
    8000638a:	00e48da3          	sb	a4,27(s1)
    8000638e:	00e48e23          	sb	a4,28(s1)
    80006392:	00e48ea3          	sb	a4,29(s1)
    80006396:	00e48f23          	sb	a4,30(s1)
    8000639a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000639e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800063a2:	0727a823          	sw	s2,112(a5)
}
    800063a6:	60e2                	ld	ra,24(sp)
    800063a8:	6442                	ld	s0,16(sp)
    800063aa:	64a2                	ld	s1,8(sp)
    800063ac:	6902                	ld	s2,0(sp)
    800063ae:	6105                	addi	sp,sp,32
    800063b0:	8082                	ret
    panic("could not find virtio disk");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	4ae50513          	addi	a0,a0,1198 # 80008860 <syscalls+0x340>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	186080e7          	jalr	390(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    800063c2:	00002517          	auipc	a0,0x2
    800063c6:	4be50513          	addi	a0,a0,1214 # 80008880 <syscalls+0x360>
    800063ca:	ffffa097          	auipc	ra,0xffffa
    800063ce:	176080e7          	jalr	374(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    800063d2:	00002517          	auipc	a0,0x2
    800063d6:	4ce50513          	addi	a0,a0,1230 # 800088a0 <syscalls+0x380>
    800063da:	ffffa097          	auipc	ra,0xffffa
    800063de:	166080e7          	jalr	358(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800063e2:	00002517          	auipc	a0,0x2
    800063e6:	4de50513          	addi	a0,a0,1246 # 800088c0 <syscalls+0x3a0>
    800063ea:	ffffa097          	auipc	ra,0xffffa
    800063ee:	156080e7          	jalr	342(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800063f2:	00002517          	auipc	a0,0x2
    800063f6:	4ee50513          	addi	a0,a0,1262 # 800088e0 <syscalls+0x3c0>
    800063fa:	ffffa097          	auipc	ra,0xffffa
    800063fe:	146080e7          	jalr	326(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    80006402:	00002517          	auipc	a0,0x2
    80006406:	4fe50513          	addi	a0,a0,1278 # 80008900 <syscalls+0x3e0>
    8000640a:	ffffa097          	auipc	ra,0xffffa
    8000640e:	136080e7          	jalr	310(ra) # 80000540 <panic>

0000000080006412 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006412:	7119                	addi	sp,sp,-128
    80006414:	fc86                	sd	ra,120(sp)
    80006416:	f8a2                	sd	s0,112(sp)
    80006418:	f4a6                	sd	s1,104(sp)
    8000641a:	f0ca                	sd	s2,96(sp)
    8000641c:	ecce                	sd	s3,88(sp)
    8000641e:	e8d2                	sd	s4,80(sp)
    80006420:	e4d6                	sd	s5,72(sp)
    80006422:	e0da                	sd	s6,64(sp)
    80006424:	fc5e                	sd	s7,56(sp)
    80006426:	f862                	sd	s8,48(sp)
    80006428:	f466                	sd	s9,40(sp)
    8000642a:	f06a                	sd	s10,32(sp)
    8000642c:	ec6e                	sd	s11,24(sp)
    8000642e:	0100                	addi	s0,sp,128
    80006430:	8aaa                	mv	s5,a0
    80006432:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006434:	00c52d03          	lw	s10,12(a0)
    80006438:	001d1d1b          	slliw	s10,s10,0x1
    8000643c:	1d02                	slli	s10,s10,0x20
    8000643e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006442:	0001c517          	auipc	a0,0x1c
    80006446:	c4650513          	addi	a0,a0,-954 # 80022088 <disk+0x128>
    8000644a:	ffffa097          	auipc	ra,0xffffa
    8000644e:	78c080e7          	jalr	1932(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006452:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006454:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006456:	0001cb97          	auipc	s7,0x1c
    8000645a:	b0ab8b93          	addi	s7,s7,-1270 # 80021f60 <disk>
  for(int i = 0; i < 3; i++){
    8000645e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006460:	0001cc97          	auipc	s9,0x1c
    80006464:	c28c8c93          	addi	s9,s9,-984 # 80022088 <disk+0x128>
    80006468:	a08d                	j	800064ca <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000646a:	00fb8733          	add	a4,s7,a5
    8000646e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006472:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006474:	0207c563          	bltz	a5,8000649e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006478:	2905                	addiw	s2,s2,1
    8000647a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000647c:	05690c63          	beq	s2,s6,800064d4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006480:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006482:	0001c717          	auipc	a4,0x1c
    80006486:	ade70713          	addi	a4,a4,-1314 # 80021f60 <disk>
    8000648a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000648c:	01874683          	lbu	a3,24(a4)
    80006490:	fee9                	bnez	a3,8000646a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006492:	2785                	addiw	a5,a5,1
    80006494:	0705                	addi	a4,a4,1
    80006496:	fe979be3          	bne	a5,s1,8000648c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000649a:	57fd                	li	a5,-1
    8000649c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000649e:	01205d63          	blez	s2,800064b8 <virtio_disk_rw+0xa6>
    800064a2:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    800064a4:	000a2503          	lw	a0,0(s4)
    800064a8:	00000097          	auipc	ra,0x0
    800064ac:	cfe080e7          	jalr	-770(ra) # 800061a6 <free_desc>
      for(int j = 0; j < i; j++)
    800064b0:	2d85                	addiw	s11,s11,1
    800064b2:	0a11                	addi	s4,s4,4
    800064b4:	ff2d98e3          	bne	s11,s2,800064a4 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800064b8:	85e6                	mv	a1,s9
    800064ba:	0001c517          	auipc	a0,0x1c
    800064be:	abe50513          	addi	a0,a0,-1346 # 80021f78 <disk+0x18>
    800064c2:	ffffc097          	auipc	ra,0xffffc
    800064c6:	eda080e7          	jalr	-294(ra) # 8000239c <sleep>
  for(int i = 0; i < 3; i++){
    800064ca:	f8040a13          	addi	s4,s0,-128
{
    800064ce:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800064d0:	894e                	mv	s2,s3
    800064d2:	b77d                	j	80006480 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064d4:	f8042503          	lw	a0,-128(s0)
    800064d8:	00a50713          	addi	a4,a0,10
    800064dc:	0712                	slli	a4,a4,0x4

  if(write)
    800064de:	0001c797          	auipc	a5,0x1c
    800064e2:	a8278793          	addi	a5,a5,-1406 # 80021f60 <disk>
    800064e6:	00e786b3          	add	a3,a5,a4
    800064ea:	01803633          	snez	a2,s8
    800064ee:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064f0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800064f4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064f8:	f6070613          	addi	a2,a4,-160
    800064fc:	6394                	ld	a3,0(a5)
    800064fe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006500:	00870593          	addi	a1,a4,8
    80006504:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006506:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006508:	0007b803          	ld	a6,0(a5)
    8000650c:	9642                	add	a2,a2,a6
    8000650e:	46c1                	li	a3,16
    80006510:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006512:	4585                	li	a1,1
    80006514:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006518:	f8442683          	lw	a3,-124(s0)
    8000651c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006520:	0692                	slli	a3,a3,0x4
    80006522:	9836                	add	a6,a6,a3
    80006524:	058a8613          	addi	a2,s5,88
    80006528:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    8000652c:	0007b803          	ld	a6,0(a5)
    80006530:	96c2                	add	a3,a3,a6
    80006532:	40000613          	li	a2,1024
    80006536:	c690                	sw	a2,8(a3)
  if(write)
    80006538:	001c3613          	seqz	a2,s8
    8000653c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006540:	00166613          	ori	a2,a2,1
    80006544:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006548:	f8842603          	lw	a2,-120(s0)
    8000654c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006550:	00250693          	addi	a3,a0,2
    80006554:	0692                	slli	a3,a3,0x4
    80006556:	96be                	add	a3,a3,a5
    80006558:	58fd                	li	a7,-1
    8000655a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000655e:	0612                	slli	a2,a2,0x4
    80006560:	9832                	add	a6,a6,a2
    80006562:	f9070713          	addi	a4,a4,-112
    80006566:	973e                	add	a4,a4,a5
    80006568:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000656c:	6398                	ld	a4,0(a5)
    8000656e:	9732                	add	a4,a4,a2
    80006570:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006572:	4609                	li	a2,2
    80006574:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006578:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000657c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006580:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006584:	6794                	ld	a3,8(a5)
    80006586:	0026d703          	lhu	a4,2(a3)
    8000658a:	8b1d                	andi	a4,a4,7
    8000658c:	0706                	slli	a4,a4,0x1
    8000658e:	96ba                	add	a3,a3,a4
    80006590:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006594:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006598:	6798                	ld	a4,8(a5)
    8000659a:	00275783          	lhu	a5,2(a4)
    8000659e:	2785                	addiw	a5,a5,1
    800065a0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800065a4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800065a8:	100017b7          	lui	a5,0x10001
    800065ac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800065b0:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    800065b4:	0001c917          	auipc	s2,0x1c
    800065b8:	ad490913          	addi	s2,s2,-1324 # 80022088 <disk+0x128>
  while(b->disk == 1) {
    800065bc:	4485                	li	s1,1
    800065be:	00b79c63          	bne	a5,a1,800065d6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800065c2:	85ca                	mv	a1,s2
    800065c4:	8556                	mv	a0,s5
    800065c6:	ffffc097          	auipc	ra,0xffffc
    800065ca:	dd6080e7          	jalr	-554(ra) # 8000239c <sleep>
  while(b->disk == 1) {
    800065ce:	004aa783          	lw	a5,4(s5)
    800065d2:	fe9788e3          	beq	a5,s1,800065c2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800065d6:	f8042903          	lw	s2,-128(s0)
    800065da:	00290713          	addi	a4,s2,2
    800065de:	0712                	slli	a4,a4,0x4
    800065e0:	0001c797          	auipc	a5,0x1c
    800065e4:	98078793          	addi	a5,a5,-1664 # 80021f60 <disk>
    800065e8:	97ba                	add	a5,a5,a4
    800065ea:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065ee:	0001c997          	auipc	s3,0x1c
    800065f2:	97298993          	addi	s3,s3,-1678 # 80021f60 <disk>
    800065f6:	00491713          	slli	a4,s2,0x4
    800065fa:	0009b783          	ld	a5,0(s3)
    800065fe:	97ba                	add	a5,a5,a4
    80006600:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006604:	854a                	mv	a0,s2
    80006606:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000660a:	00000097          	auipc	ra,0x0
    8000660e:	b9c080e7          	jalr	-1124(ra) # 800061a6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006612:	8885                	andi	s1,s1,1
    80006614:	f0ed                	bnez	s1,800065f6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006616:	0001c517          	auipc	a0,0x1c
    8000661a:	a7250513          	addi	a0,a0,-1422 # 80022088 <disk+0x128>
    8000661e:	ffffa097          	auipc	ra,0xffffa
    80006622:	66c080e7          	jalr	1644(ra) # 80000c8a <release>
}
    80006626:	70e6                	ld	ra,120(sp)
    80006628:	7446                	ld	s0,112(sp)
    8000662a:	74a6                	ld	s1,104(sp)
    8000662c:	7906                	ld	s2,96(sp)
    8000662e:	69e6                	ld	s3,88(sp)
    80006630:	6a46                	ld	s4,80(sp)
    80006632:	6aa6                	ld	s5,72(sp)
    80006634:	6b06                	ld	s6,64(sp)
    80006636:	7be2                	ld	s7,56(sp)
    80006638:	7c42                	ld	s8,48(sp)
    8000663a:	7ca2                	ld	s9,40(sp)
    8000663c:	7d02                	ld	s10,32(sp)
    8000663e:	6de2                	ld	s11,24(sp)
    80006640:	6109                	addi	sp,sp,128
    80006642:	8082                	ret

0000000080006644 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006644:	1101                	addi	sp,sp,-32
    80006646:	ec06                	sd	ra,24(sp)
    80006648:	e822                	sd	s0,16(sp)
    8000664a:	e426                	sd	s1,8(sp)
    8000664c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000664e:	0001c497          	auipc	s1,0x1c
    80006652:	91248493          	addi	s1,s1,-1774 # 80021f60 <disk>
    80006656:	0001c517          	auipc	a0,0x1c
    8000665a:	a3250513          	addi	a0,a0,-1486 # 80022088 <disk+0x128>
    8000665e:	ffffa097          	auipc	ra,0xffffa
    80006662:	578080e7          	jalr	1400(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006666:	10001737          	lui	a4,0x10001
    8000666a:	533c                	lw	a5,96(a4)
    8000666c:	8b8d                	andi	a5,a5,3
    8000666e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006670:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006674:	689c                	ld	a5,16(s1)
    80006676:	0204d703          	lhu	a4,32(s1)
    8000667a:	0027d783          	lhu	a5,2(a5)
    8000667e:	04f70863          	beq	a4,a5,800066ce <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006682:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006686:	6898                	ld	a4,16(s1)
    80006688:	0204d783          	lhu	a5,32(s1)
    8000668c:	8b9d                	andi	a5,a5,7
    8000668e:	078e                	slli	a5,a5,0x3
    80006690:	97ba                	add	a5,a5,a4
    80006692:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006694:	00278713          	addi	a4,a5,2
    80006698:	0712                	slli	a4,a4,0x4
    8000669a:	9726                	add	a4,a4,s1
    8000669c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800066a0:	e721                	bnez	a4,800066e8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800066a2:	0789                	addi	a5,a5,2
    800066a4:	0792                	slli	a5,a5,0x4
    800066a6:	97a6                	add	a5,a5,s1
    800066a8:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800066aa:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800066ae:	ffffc097          	auipc	ra,0xffffc
    800066b2:	d52080e7          	jalr	-686(ra) # 80002400 <wakeup>

    disk.used_idx += 1;
    800066b6:	0204d783          	lhu	a5,32(s1)
    800066ba:	2785                	addiw	a5,a5,1
    800066bc:	17c2                	slli	a5,a5,0x30
    800066be:	93c1                	srli	a5,a5,0x30
    800066c0:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800066c4:	6898                	ld	a4,16(s1)
    800066c6:	00275703          	lhu	a4,2(a4)
    800066ca:	faf71ce3          	bne	a4,a5,80006682 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800066ce:	0001c517          	auipc	a0,0x1c
    800066d2:	9ba50513          	addi	a0,a0,-1606 # 80022088 <disk+0x128>
    800066d6:	ffffa097          	auipc	ra,0xffffa
    800066da:	5b4080e7          	jalr	1460(ra) # 80000c8a <release>
}
    800066de:	60e2                	ld	ra,24(sp)
    800066e0:	6442                	ld	s0,16(sp)
    800066e2:	64a2                	ld	s1,8(sp)
    800066e4:	6105                	addi	sp,sp,32
    800066e6:	8082                	ret
      panic("virtio_disk_intr status");
    800066e8:	00002517          	auipc	a0,0x2
    800066ec:	23050513          	addi	a0,a0,560 # 80008918 <syscalls+0x3f8>
    800066f0:	ffffa097          	auipc	ra,0xffffa
    800066f4:	e50080e7          	jalr	-432(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
