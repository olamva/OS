
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a8013103          	ld	sp,-1408(sp) # 80008a80 <_GLOBAL_OFFSET_TABLE_+0x8>
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
    80000054:	aa070713          	addi	a4,a4,-1376 # 80008af0 <timer_scratch>
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
    80000066:	34e78793          	addi	a5,a5,846 # 800063b0 <timervec>
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
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc89f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	e9478793          	addi	a5,a5,-364 # 80000f40 <main>
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
    8000012a:	00003097          	auipc	ra,0x3
    8000012e:	852080e7          	jalr	-1966(ra) # 8000297c <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	796080e7          	jalr	1942(ra) # 800008d0 <uartputc>
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
    8000018e:	aa650513          	addi	a0,a0,-1370 # 80010c30 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	b0c080e7          	jalr	-1268(ra) # 80000c9e <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	a9648493          	addi	s1,s1,-1386 # 80010c30 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	b2690913          	addi	s2,s2,-1242 # 80010cc8 <cons+0x98>
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
    800001c4:	a70080e7          	jalr	-1424(ra) # 80001c30 <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	5fe080e7          	jalr	1534(ra) # 800027c6 <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
            sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	348080e7          	jalr	840(ra) # 8000251e <sleep>
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
    80000216:	714080e7          	jalr	1812(ra) # 80002926 <either_copyout>
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
    8000022a:	a0a50513          	addi	a0,a0,-1526 # 80010c30 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	b24080e7          	jalr	-1244(ra) # 80000d52 <release>

    return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
                release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	9f450513          	addi	a0,a0,-1548 # 80010c30 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	b0e080e7          	jalr	-1266(ra) # 80000d52 <release>
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
    80000276:	a4f72b23          	sw	a5,-1450(a4) # 80010cc8 <cons+0x98>
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
    80000290:	572080e7          	jalr	1394(ra) # 800007fe <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
        uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	560080e7          	jalr	1376(ra) # 800007fe <uartputc_sync>
        uartputc_sync(' ');
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	554080e7          	jalr	1364(ra) # 800007fe <uartputc_sync>
        uartputc_sync('\b');
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	54a080e7          	jalr	1354(ra) # 800007fe <uartputc_sync>
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
    800002d0:	96450513          	addi	a0,a0,-1692 # 80010c30 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	9ca080e7          	jalr	-1590(ra) # 80000c9e <acquire>

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
    800002f6:	6e0080e7          	jalr	1760(ra) # 800029d2 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002fa:	00011517          	auipc	a0,0x11
    800002fe:	93650513          	addi	a0,a0,-1738 # 80010c30 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	a50080e7          	jalr	-1456(ra) # 80000d52 <release>
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
    80000322:	91270713          	addi	a4,a4,-1774 # 80010c30 <cons>
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
    8000034c:	8e878793          	addi	a5,a5,-1816 # 80010c30 <cons>
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
    8000037a:	9527a783          	lw	a5,-1710(a5) # 80010cc8 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
        while (cons.e != cons.w &&
    8000038a:	00011717          	auipc	a4,0x11
    8000038e:	8a670713          	addi	a4,a4,-1882 # 80010c30 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    8000039a:	00011497          	auipc	s1,0x11
    8000039e:	89648493          	addi	s1,s1,-1898 # 80010c30 <cons>
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
    800003d6:	00011717          	auipc	a4,0x11
    800003da:	85a70713          	addi	a4,a4,-1958 # 80010c30 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
            cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00011717          	auipc	a4,0x11
    800003f0:	8ef72223          	sw	a5,-1820(a4) # 80010cd0 <cons+0xa0>
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
    80000412:	00011797          	auipc	a5,0x11
    80000416:	81e78793          	addi	a5,a5,-2018 # 80010c30 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000436:	00011797          	auipc	a5,0x11
    8000043a:	88c7ab23          	sw	a2,-1898(a5) # 80010ccc <cons+0x9c>
                wakeup(&cons.r);
    8000043e:	00011517          	auipc	a0,0x11
    80000442:	88a50513          	addi	a0,a0,-1910 # 80010cc8 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	13c080e7          	jalr	316(ra) # 80002582 <wakeup>
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
    8000045c:	bc858593          	addi	a1,a1,-1080 # 80008020 <__func__.1+0x18>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	7d050513          	addi	a0,a0,2000 # 80010c30 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	7a6080e7          	jalr	1958(ra) # 80000c0e <initlock>

    uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	33e080e7          	jalr	830(ra) # 800007ae <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000478:	00021797          	auipc	a5,0x21
    8000047c:	95078793          	addi	a5,a5,-1712 # 80020dc8 <devsw>
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

    if (sign && (sign = xx < 0))
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
    do
    {
        buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b9660613          	addi	a2,a2,-1130 # 80008050 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
    } while ((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

    if (sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
        buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

    while (--i >= 0)
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
    while (--i >= 0)
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
    if (sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
        x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    if (locking)
        release(&pr.lock);
}

void panic(char *s, ...)
{
    80000540:	711d                	addi	sp,sp,-96
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
    8000054c:	e40c                	sd	a1,8(s0)
    8000054e:	e810                	sd	a2,16(s0)
    80000550:	ec14                	sd	a3,24(s0)
    80000552:	f018                	sd	a4,32(s0)
    80000554:	f41c                	sd	a5,40(s0)
    80000556:	03043823          	sd	a6,48(s0)
    8000055a:	03143c23          	sd	a7,56(s0)
    pr.locking = 0;
    8000055e:	00010797          	auipc	a5,0x10
    80000562:	7807a923          	sw	zero,1938(a5) # 80010cf0 <pr+0x18>
    printf("panic: ");
    80000566:	00008517          	auipc	a0,0x8
    8000056a:	ac250513          	addi	a0,a0,-1342 # 80008028 <__func__.1+0x20>
    8000056e:	00000097          	auipc	ra,0x0
    80000572:	02e080e7          	jalr	46(ra) # 8000059c <printf>
    printf(s);
    80000576:	8526                	mv	a0,s1
    80000578:	00000097          	auipc	ra,0x0
    8000057c:	024080e7          	jalr	36(ra) # 8000059c <printf>
    printf("\n");
    80000580:	00008517          	auipc	a0,0x8
    80000584:	b0850513          	addi	a0,a0,-1272 # 80008088 <digits+0x38>
    80000588:	00000097          	auipc	ra,0x0
    8000058c:	014080e7          	jalr	20(ra) # 8000059c <printf>
    panicked = 1; // freeze uart output from other CPUs
    80000590:	4785                	li	a5,1
    80000592:	00008717          	auipc	a4,0x8
    80000596:	50f72723          	sw	a5,1294(a4) # 80008aa0 <panicked>
    for (;;)
    8000059a:	a001                	j	8000059a <panic+0x5a>

000000008000059c <printf>:
{
    8000059c:	7131                	addi	sp,sp,-192
    8000059e:	fc86                	sd	ra,120(sp)
    800005a0:	f8a2                	sd	s0,112(sp)
    800005a2:	f4a6                	sd	s1,104(sp)
    800005a4:	f0ca                	sd	s2,96(sp)
    800005a6:	ecce                	sd	s3,88(sp)
    800005a8:	e8d2                	sd	s4,80(sp)
    800005aa:	e4d6                	sd	s5,72(sp)
    800005ac:	e0da                	sd	s6,64(sp)
    800005ae:	fc5e                	sd	s7,56(sp)
    800005b0:	f862                	sd	s8,48(sp)
    800005b2:	f466                	sd	s9,40(sp)
    800005b4:	f06a                	sd	s10,32(sp)
    800005b6:	ec6e                	sd	s11,24(sp)
    800005b8:	0100                	addi	s0,sp,128
    800005ba:	8a2a                	mv	s4,a0
    800005bc:	e40c                	sd	a1,8(s0)
    800005be:	e810                	sd	a2,16(s0)
    800005c0:	ec14                	sd	a3,24(s0)
    800005c2:	f018                	sd	a4,32(s0)
    800005c4:	f41c                	sd	a5,40(s0)
    800005c6:	03043823          	sd	a6,48(s0)
    800005ca:	03143c23          	sd	a7,56(s0)
    locking = pr.locking;
    800005ce:	00010d97          	auipc	s11,0x10
    800005d2:	722dad83          	lw	s11,1826(s11) # 80010cf0 <pr+0x18>
    if (locking)
    800005d6:	020d9b63          	bnez	s11,8000060c <printf+0x70>
    if (fmt == 0)
    800005da:	040a0263          	beqz	s4,8000061e <printf+0x82>
    va_start(ap, fmt);
    800005de:	00840793          	addi	a5,s0,8
    800005e2:	f8f43423          	sd	a5,-120(s0)
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    800005e6:	000a4503          	lbu	a0,0(s4)
    800005ea:	14050f63          	beqz	a0,80000748 <printf+0x1ac>
    800005ee:	4981                	li	s3,0
        if (c != '%')
    800005f0:	02500a93          	li	s5,37
        switch (c)
    800005f4:	07000b93          	li	s7,112
    consputc('x');
    800005f8:	4d41                	li	s10,16
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005fa:	00008b17          	auipc	s6,0x8
    800005fe:	a56b0b13          	addi	s6,s6,-1450 # 80008050 <digits>
        switch (c)
    80000602:	07300c93          	li	s9,115
    80000606:	06400c13          	li	s8,100
    8000060a:	a82d                	j	80000644 <printf+0xa8>
        acquire(&pr.lock);
    8000060c:	00010517          	auipc	a0,0x10
    80000610:	6cc50513          	addi	a0,a0,1740 # 80010cd8 <pr>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	68a080e7          	jalr	1674(ra) # 80000c9e <acquire>
    8000061c:	bf7d                	j	800005da <printf+0x3e>
        panic("null fmt");
    8000061e:	00008517          	auipc	a0,0x8
    80000622:	a1a50513          	addi	a0,a0,-1510 # 80008038 <__func__.1+0x30>
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f1a080e7          	jalr	-230(ra) # 80000540 <panic>
            consputc(c);
    8000062e:	00000097          	auipc	ra,0x0
    80000632:	c4e080e7          	jalr	-946(ra) # 8000027c <consputc>
    for (i = 0; (c = fmt[i] & 0xff) != 0; i++)
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c503          	lbu	a0,0(a5)
    80000640:	10050463          	beqz	a0,80000748 <printf+0x1ac>
        if (c != '%')
    80000644:	ff5515e3          	bne	a0,s5,8000062e <printf+0x92>
        c = fmt[++i] & 0xff;
    80000648:	2985                	addiw	s3,s3,1
    8000064a:	013a07b3          	add	a5,s4,s3
    8000064e:	0007c783          	lbu	a5,0(a5)
    80000652:	0007849b          	sext.w	s1,a5
        if (c == 0)
    80000656:	cbed                	beqz	a5,80000748 <printf+0x1ac>
        switch (c)
    80000658:	05778a63          	beq	a5,s7,800006ac <printf+0x110>
    8000065c:	02fbf663          	bgeu	s7,a5,80000688 <printf+0xec>
    80000660:	09978863          	beq	a5,s9,800006f0 <printf+0x154>
    80000664:	07800713          	li	a4,120
    80000668:	0ce79563          	bne	a5,a4,80000732 <printf+0x196>
            printint(va_arg(ap, int), 16, 1);
    8000066c:	f8843783          	ld	a5,-120(s0)
    80000670:	00878713          	addi	a4,a5,8
    80000674:	f8e43423          	sd	a4,-120(s0)
    80000678:	4605                	li	a2,1
    8000067a:	85ea                	mv	a1,s10
    8000067c:	4388                	lw	a0,0(a5)
    8000067e:	00000097          	auipc	ra,0x0
    80000682:	e1e080e7          	jalr	-482(ra) # 8000049c <printint>
            break;
    80000686:	bf45                	j	80000636 <printf+0x9a>
        switch (c)
    80000688:	09578f63          	beq	a5,s5,80000726 <printf+0x18a>
    8000068c:	0b879363          	bne	a5,s8,80000732 <printf+0x196>
            printint(va_arg(ap, int), 10, 1);
    80000690:	f8843783          	ld	a5,-120(s0)
    80000694:	00878713          	addi	a4,a5,8
    80000698:	f8e43423          	sd	a4,-120(s0)
    8000069c:	4605                	li	a2,1
    8000069e:	45a9                	li	a1,10
    800006a0:	4388                	lw	a0,0(a5)
    800006a2:	00000097          	auipc	ra,0x0
    800006a6:	dfa080e7          	jalr	-518(ra) # 8000049c <printint>
            break;
    800006aa:	b771                	j	80000636 <printf+0x9a>
            printptr(va_arg(ap, uint64));
    800006ac:	f8843783          	ld	a5,-120(s0)
    800006b0:	00878713          	addi	a4,a5,8
    800006b4:	f8e43423          	sd	a4,-120(s0)
    800006b8:	0007b903          	ld	s2,0(a5)
    consputc('0');
    800006bc:	03000513          	li	a0,48
    800006c0:	00000097          	auipc	ra,0x0
    800006c4:	bbc080e7          	jalr	-1092(ra) # 8000027c <consputc>
    consputc('x');
    800006c8:	07800513          	li	a0,120
    800006cc:	00000097          	auipc	ra,0x0
    800006d0:	bb0080e7          	jalr	-1104(ra) # 8000027c <consputc>
    800006d4:	84ea                	mv	s1,s10
        consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006d6:	03c95793          	srli	a5,s2,0x3c
    800006da:	97da                	add	a5,a5,s6
    800006dc:	0007c503          	lbu	a0,0(a5)
    800006e0:	00000097          	auipc	ra,0x0
    800006e4:	b9c080e7          	jalr	-1124(ra) # 8000027c <consputc>
    for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006e8:	0912                	slli	s2,s2,0x4
    800006ea:	34fd                	addiw	s1,s1,-1
    800006ec:	f4ed                	bnez	s1,800006d6 <printf+0x13a>
    800006ee:	b7a1                	j	80000636 <printf+0x9a>
            if ((s = va_arg(ap, char *)) == 0)
    800006f0:	f8843783          	ld	a5,-120(s0)
    800006f4:	00878713          	addi	a4,a5,8
    800006f8:	f8e43423          	sd	a4,-120(s0)
    800006fc:	6384                	ld	s1,0(a5)
    800006fe:	cc89                	beqz	s1,80000718 <printf+0x17c>
            for (; *s; s++)
    80000700:	0004c503          	lbu	a0,0(s1)
    80000704:	d90d                	beqz	a0,80000636 <printf+0x9a>
                consputc(*s);
    80000706:	00000097          	auipc	ra,0x0
    8000070a:	b76080e7          	jalr	-1162(ra) # 8000027c <consputc>
            for (; *s; s++)
    8000070e:	0485                	addi	s1,s1,1
    80000710:	0004c503          	lbu	a0,0(s1)
    80000714:	f96d                	bnez	a0,80000706 <printf+0x16a>
    80000716:	b705                	j	80000636 <printf+0x9a>
                s = "(null)";
    80000718:	00008497          	auipc	s1,0x8
    8000071c:	91848493          	addi	s1,s1,-1768 # 80008030 <__func__.1+0x28>
            for (; *s; s++)
    80000720:	02800513          	li	a0,40
    80000724:	b7cd                	j	80000706 <printf+0x16a>
            consputc('%');
    80000726:	8556                	mv	a0,s5
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b54080e7          	jalr	-1196(ra) # 8000027c <consputc>
            break;
    80000730:	b719                	j	80000636 <printf+0x9a>
            consputc('%');
    80000732:	8556                	mv	a0,s5
    80000734:	00000097          	auipc	ra,0x0
    80000738:	b48080e7          	jalr	-1208(ra) # 8000027c <consputc>
            consputc(c);
    8000073c:	8526                	mv	a0,s1
    8000073e:	00000097          	auipc	ra,0x0
    80000742:	b3e080e7          	jalr	-1218(ra) # 8000027c <consputc>
            break;
    80000746:	bdc5                	j	80000636 <printf+0x9a>
    if (locking)
    80000748:	020d9163          	bnez	s11,8000076a <printf+0x1ce>
}
    8000074c:	70e6                	ld	ra,120(sp)
    8000074e:	7446                	ld	s0,112(sp)
    80000750:	74a6                	ld	s1,104(sp)
    80000752:	7906                	ld	s2,96(sp)
    80000754:	69e6                	ld	s3,88(sp)
    80000756:	6a46                	ld	s4,80(sp)
    80000758:	6aa6                	ld	s5,72(sp)
    8000075a:	6b06                	ld	s6,64(sp)
    8000075c:	7be2                	ld	s7,56(sp)
    8000075e:	7c42                	ld	s8,48(sp)
    80000760:	7ca2                	ld	s9,40(sp)
    80000762:	7d02                	ld	s10,32(sp)
    80000764:	6de2                	ld	s11,24(sp)
    80000766:	6129                	addi	sp,sp,192
    80000768:	8082                	ret
        release(&pr.lock);
    8000076a:	00010517          	auipc	a0,0x10
    8000076e:	56e50513          	addi	a0,a0,1390 # 80010cd8 <pr>
    80000772:	00000097          	auipc	ra,0x0
    80000776:	5e0080e7          	jalr	1504(ra) # 80000d52 <release>
}
    8000077a:	bfc9                	j	8000074c <printf+0x1b0>

000000008000077c <printfinit>:
        ;
}

void printfinit(void)
{
    8000077c:	1101                	addi	sp,sp,-32
    8000077e:	ec06                	sd	ra,24(sp)
    80000780:	e822                	sd	s0,16(sp)
    80000782:	e426                	sd	s1,8(sp)
    80000784:	1000                	addi	s0,sp,32
    initlock(&pr.lock, "pr");
    80000786:	00010497          	auipc	s1,0x10
    8000078a:	55248493          	addi	s1,s1,1362 # 80010cd8 <pr>
    8000078e:	00008597          	auipc	a1,0x8
    80000792:	8ba58593          	addi	a1,a1,-1862 # 80008048 <__func__.1+0x40>
    80000796:	8526                	mv	a0,s1
    80000798:	00000097          	auipc	ra,0x0
    8000079c:	476080e7          	jalr	1142(ra) # 80000c0e <initlock>
    pr.locking = 1;
    800007a0:	4785                	li	a5,1
    800007a2:	cc9c                	sw	a5,24(s1)
}
    800007a4:	60e2                	ld	ra,24(sp)
    800007a6:	6442                	ld	s0,16(sp)
    800007a8:	64a2                	ld	s1,8(sp)
    800007aa:	6105                	addi	sp,sp,32
    800007ac:	8082                	ret

00000000800007ae <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007ae:	1141                	addi	sp,sp,-16
    800007b0:	e406                	sd	ra,8(sp)
    800007b2:	e022                	sd	s0,0(sp)
    800007b4:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007b6:	100007b7          	lui	a5,0x10000
    800007ba:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007be:	f8000713          	li	a4,-128
    800007c2:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007c6:	470d                	li	a4,3
    800007c8:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007cc:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007d0:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007d4:	469d                	li	a3,7
    800007d6:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007da:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007de:	00008597          	auipc	a1,0x8
    800007e2:	88a58593          	addi	a1,a1,-1910 # 80008068 <digits+0x18>
    800007e6:	00010517          	auipc	a0,0x10
    800007ea:	51250513          	addi	a0,a0,1298 # 80010cf8 <uart_tx_lock>
    800007ee:	00000097          	auipc	ra,0x0
    800007f2:	420080e7          	jalr	1056(ra) # 80000c0e <initlock>
}
    800007f6:	60a2                	ld	ra,8(sp)
    800007f8:	6402                	ld	s0,0(sp)
    800007fa:	0141                	addi	sp,sp,16
    800007fc:	8082                	ret

00000000800007fe <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007fe:	1101                	addi	sp,sp,-32
    80000800:	ec06                	sd	ra,24(sp)
    80000802:	e822                	sd	s0,16(sp)
    80000804:	e426                	sd	s1,8(sp)
    80000806:	1000                	addi	s0,sp,32
    80000808:	84aa                	mv	s1,a0
  push_off();
    8000080a:	00000097          	auipc	ra,0x0
    8000080e:	448080e7          	jalr	1096(ra) # 80000c52 <push_off>

  if(panicked){
    80000812:	00008797          	auipc	a5,0x8
    80000816:	28e7a783          	lw	a5,654(a5) # 80008aa0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000081a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000081e:	c391                	beqz	a5,80000822 <uartputc_sync+0x24>
    for(;;)
    80000820:	a001                	j	80000820 <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000822:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000826:	0207f793          	andi	a5,a5,32
    8000082a:	dfe5                	beqz	a5,80000822 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000082c:	0ff4f513          	zext.b	a0,s1
    80000830:	100007b7          	lui	a5,0x10000
    80000834:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000838:	00000097          	auipc	ra,0x0
    8000083c:	4ba080e7          	jalr	1210(ra) # 80000cf2 <pop_off>
}
    80000840:	60e2                	ld	ra,24(sp)
    80000842:	6442                	ld	s0,16(sp)
    80000844:	64a2                	ld	s1,8(sp)
    80000846:	6105                	addi	sp,sp,32
    80000848:	8082                	ret

000000008000084a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000084a:	00008797          	auipc	a5,0x8
    8000084e:	25e7b783          	ld	a5,606(a5) # 80008aa8 <uart_tx_r>
    80000852:	00008717          	auipc	a4,0x8
    80000856:	25e73703          	ld	a4,606(a4) # 80008ab0 <uart_tx_w>
    8000085a:	06f70a63          	beq	a4,a5,800008ce <uartstart+0x84>
{
    8000085e:	7139                	addi	sp,sp,-64
    80000860:	fc06                	sd	ra,56(sp)
    80000862:	f822                	sd	s0,48(sp)
    80000864:	f426                	sd	s1,40(sp)
    80000866:	f04a                	sd	s2,32(sp)
    80000868:	ec4e                	sd	s3,24(sp)
    8000086a:	e852                	sd	s4,16(sp)
    8000086c:	e456                	sd	s5,8(sp)
    8000086e:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000870:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000874:	00010a17          	auipc	s4,0x10
    80000878:	484a0a13          	addi	s4,s4,1156 # 80010cf8 <uart_tx_lock>
    uart_tx_r += 1;
    8000087c:	00008497          	auipc	s1,0x8
    80000880:	22c48493          	addi	s1,s1,556 # 80008aa8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000884:	00008997          	auipc	s3,0x8
    80000888:	22c98993          	addi	s3,s3,556 # 80008ab0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000088c:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    80000890:	02077713          	andi	a4,a4,32
    80000894:	c705                	beqz	a4,800008bc <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000896:	01f7f713          	andi	a4,a5,31
    8000089a:	9752                	add	a4,a4,s4
    8000089c:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800008a0:	0785                	addi	a5,a5,1
    800008a2:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    800008a4:	8526                	mv	a0,s1
    800008a6:	00002097          	auipc	ra,0x2
    800008aa:	cdc080e7          	jalr	-804(ra) # 80002582 <wakeup>
    
    WriteReg(THR, c);
    800008ae:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008b2:	609c                	ld	a5,0(s1)
    800008b4:	0009b703          	ld	a4,0(s3)
    800008b8:	fcf71ae3          	bne	a4,a5,8000088c <uartstart+0x42>
  }
}
    800008bc:	70e2                	ld	ra,56(sp)
    800008be:	7442                	ld	s0,48(sp)
    800008c0:	74a2                	ld	s1,40(sp)
    800008c2:	7902                	ld	s2,32(sp)
    800008c4:	69e2                	ld	s3,24(sp)
    800008c6:	6a42                	ld	s4,16(sp)
    800008c8:	6aa2                	ld	s5,8(sp)
    800008ca:	6121                	addi	sp,sp,64
    800008cc:	8082                	ret
    800008ce:	8082                	ret

00000000800008d0 <uartputc>:
{
    800008d0:	7179                	addi	sp,sp,-48
    800008d2:	f406                	sd	ra,40(sp)
    800008d4:	f022                	sd	s0,32(sp)
    800008d6:	ec26                	sd	s1,24(sp)
    800008d8:	e84a                	sd	s2,16(sp)
    800008da:	e44e                	sd	s3,8(sp)
    800008dc:	e052                	sd	s4,0(sp)
    800008de:	1800                	addi	s0,sp,48
    800008e0:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008e2:	00010517          	auipc	a0,0x10
    800008e6:	41650513          	addi	a0,a0,1046 # 80010cf8 <uart_tx_lock>
    800008ea:	00000097          	auipc	ra,0x0
    800008ee:	3b4080e7          	jalr	948(ra) # 80000c9e <acquire>
  if(panicked){
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	1ae7a783          	lw	a5,430(a5) # 80008aa0 <panicked>
    800008fa:	e7c9                	bnez	a5,80000984 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008fc:	00008717          	auipc	a4,0x8
    80000900:	1b473703          	ld	a4,436(a4) # 80008ab0 <uart_tx_w>
    80000904:	00008797          	auipc	a5,0x8
    80000908:	1a47b783          	ld	a5,420(a5) # 80008aa8 <uart_tx_r>
    8000090c:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000910:	00010997          	auipc	s3,0x10
    80000914:	3e898993          	addi	s3,s3,1000 # 80010cf8 <uart_tx_lock>
    80000918:	00008497          	auipc	s1,0x8
    8000091c:	19048493          	addi	s1,s1,400 # 80008aa8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000920:	00008917          	auipc	s2,0x8
    80000924:	19090913          	addi	s2,s2,400 # 80008ab0 <uart_tx_w>
    80000928:	00e79f63          	bne	a5,a4,80000946 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000092c:	85ce                	mv	a1,s3
    8000092e:	8526                	mv	a0,s1
    80000930:	00002097          	auipc	ra,0x2
    80000934:	bee080e7          	jalr	-1042(ra) # 8000251e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000938:	00093703          	ld	a4,0(s2)
    8000093c:	609c                	ld	a5,0(s1)
    8000093e:	02078793          	addi	a5,a5,32
    80000942:	fee785e3          	beq	a5,a4,8000092c <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000946:	00010497          	auipc	s1,0x10
    8000094a:	3b248493          	addi	s1,s1,946 # 80010cf8 <uart_tx_lock>
    8000094e:	01f77793          	andi	a5,a4,31
    80000952:	97a6                	add	a5,a5,s1
    80000954:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000958:	0705                	addi	a4,a4,1
    8000095a:	00008797          	auipc	a5,0x8
    8000095e:	14e7bb23          	sd	a4,342(a5) # 80008ab0 <uart_tx_w>
  uartstart();
    80000962:	00000097          	auipc	ra,0x0
    80000966:	ee8080e7          	jalr	-280(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    8000096a:	8526                	mv	a0,s1
    8000096c:	00000097          	auipc	ra,0x0
    80000970:	3e6080e7          	jalr	998(ra) # 80000d52 <release>
}
    80000974:	70a2                	ld	ra,40(sp)
    80000976:	7402                	ld	s0,32(sp)
    80000978:	64e2                	ld	s1,24(sp)
    8000097a:	6942                	ld	s2,16(sp)
    8000097c:	69a2                	ld	s3,8(sp)
    8000097e:	6a02                	ld	s4,0(sp)
    80000980:	6145                	addi	sp,sp,48
    80000982:	8082                	ret
    for(;;)
    80000984:	a001                	j	80000984 <uartputc+0xb4>

0000000080000986 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000986:	1141                	addi	sp,sp,-16
    80000988:	e422                	sd	s0,8(sp)
    8000098a:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000098c:	100007b7          	lui	a5,0x10000
    80000990:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000994:	8b85                	andi	a5,a5,1
    80000996:	cb81                	beqz	a5,800009a6 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000998:	100007b7          	lui	a5,0x10000
    8000099c:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009a0:	6422                	ld	s0,8(sp)
    800009a2:	0141                	addi	sp,sp,16
    800009a4:	8082                	ret
    return -1;
    800009a6:	557d                	li	a0,-1
    800009a8:	bfe5                	j	800009a0 <uartgetc+0x1a>

00000000800009aa <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    800009aa:	1101                	addi	sp,sp,-32
    800009ac:	ec06                	sd	ra,24(sp)
    800009ae:	e822                	sd	s0,16(sp)
    800009b0:	e426                	sd	s1,8(sp)
    800009b2:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009b4:	54fd                	li	s1,-1
    800009b6:	a029                	j	800009c0 <uartintr+0x16>
      break;
    consoleintr(c);
    800009b8:	00000097          	auipc	ra,0x0
    800009bc:	906080e7          	jalr	-1786(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	fc6080e7          	jalr	-58(ra) # 80000986 <uartgetc>
    if(c == -1)
    800009c8:	fe9518e3          	bne	a0,s1,800009b8 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009cc:	00010497          	auipc	s1,0x10
    800009d0:	32c48493          	addi	s1,s1,812 # 80010cf8 <uart_tx_lock>
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2c8080e7          	jalr	712(ra) # 80000c9e <acquire>
  uartstart();
    800009de:	00000097          	auipc	ra,0x0
    800009e2:	e6c080e7          	jalr	-404(ra) # 8000084a <uartstart>
  release(&uart_tx_lock);
    800009e6:	8526                	mv	a0,s1
    800009e8:	00000097          	auipc	ra,0x0
    800009ec:	36a080e7          	jalr	874(ra) # 80000d52 <release>
}
    800009f0:	60e2                	ld	ra,24(sp)
    800009f2:	6442                	ld	s0,16(sp)
    800009f4:	64a2                	ld	s1,8(sp)
    800009f6:	6105                	addi	sp,sp,32
    800009f8:	8082                	ret

00000000800009fa <kfree>:
// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    800009fa:	1101                	addi	sp,sp,-32
    800009fc:	ec06                	sd	ra,24(sp)
    800009fe:	e822                	sd	s0,16(sp)
    80000a00:	e426                	sd	s1,8(sp)
    80000a02:	e04a                	sd	s2,0(sp)
    80000a04:	1000                	addi	s0,sp,32
    80000a06:	84aa                	mv	s1,a0
    if (MAX_PAGES != 0)
    80000a08:	00008797          	auipc	a5,0x8
    80000a0c:	0b87b783          	ld	a5,184(a5) # 80008ac0 <MAX_PAGES>
    80000a10:	c799                	beqz	a5,80000a1e <kfree+0x24>
        assert(FREE_PAGES < MAX_PAGES);
    80000a12:	00008717          	auipc	a4,0x8
    80000a16:	0a673703          	ld	a4,166(a4) # 80008ab8 <FREE_PAGES>
    80000a1a:	06f77663          	bgeu	a4,a5,80000a86 <kfree+0x8c>
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
    80000a1e:	03449793          	slli	a5,s1,0x34
    80000a22:	efc1                	bnez	a5,80000aba <kfree+0xc0>
    80000a24:	00021797          	auipc	a5,0x21
    80000a28:	53c78793          	addi	a5,a5,1340 # 80021f60 <end>
    80000a2c:	08f4e763          	bltu	s1,a5,80000aba <kfree+0xc0>
    80000a30:	47c5                	li	a5,17
    80000a32:	07ee                	slli	a5,a5,0x1b
    80000a34:	08f4f363          	bgeu	s1,a5,80000aba <kfree+0xc0>
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);
    80000a38:	6605                	lui	a2,0x1
    80000a3a:	4585                	li	a1,1
    80000a3c:	8526                	mv	a0,s1
    80000a3e:	00000097          	auipc	ra,0x0
    80000a42:	35c080e7          	jalr	860(ra) # 80000d9a <memset>

    r = (struct run *)pa;

    acquire(&kmem.lock);
    80000a46:	00010917          	auipc	s2,0x10
    80000a4a:	2ea90913          	addi	s2,s2,746 # 80010d30 <kmem>
    80000a4e:	854a                	mv	a0,s2
    80000a50:	00000097          	auipc	ra,0x0
    80000a54:	24e080e7          	jalr	590(ra) # 80000c9e <acquire>
    r->next = kmem.freelist;
    80000a58:	01893783          	ld	a5,24(s2)
    80000a5c:	e09c                	sd	a5,0(s1)
    kmem.freelist = r;
    80000a5e:	00993c23          	sd	s1,24(s2)
    FREE_PAGES++;
    80000a62:	00008717          	auipc	a4,0x8
    80000a66:	05670713          	addi	a4,a4,86 # 80008ab8 <FREE_PAGES>
    80000a6a:	631c                	ld	a5,0(a4)
    80000a6c:	0785                	addi	a5,a5,1
    80000a6e:	e31c                	sd	a5,0(a4)
    release(&kmem.lock);
    80000a70:	854a                	mv	a0,s2
    80000a72:	00000097          	auipc	ra,0x0
    80000a76:	2e0080e7          	jalr	736(ra) # 80000d52 <release>
}
    80000a7a:	60e2                	ld	ra,24(sp)
    80000a7c:	6442                	ld	s0,16(sp)
    80000a7e:	64a2                	ld	s1,8(sp)
    80000a80:	6902                	ld	s2,0(sp)
    80000a82:	6105                	addi	sp,sp,32
    80000a84:	8082                	ret
        assert(FREE_PAGES < MAX_PAGES);
    80000a86:	03700693          	li	a3,55
    80000a8a:	00007617          	auipc	a2,0x7
    80000a8e:	57e60613          	addi	a2,a2,1406 # 80008008 <__func__.1>
    80000a92:	00007597          	auipc	a1,0x7
    80000a96:	5de58593          	addi	a1,a1,1502 # 80008070 <digits+0x20>
    80000a9a:	00007517          	auipc	a0,0x7
    80000a9e:	5e650513          	addi	a0,a0,1510 # 80008080 <digits+0x30>
    80000aa2:	00000097          	auipc	ra,0x0
    80000aa6:	afa080e7          	jalr	-1286(ra) # 8000059c <printf>
    80000aaa:	00007517          	auipc	a0,0x7
    80000aae:	5e650513          	addi	a0,a0,1510 # 80008090 <digits+0x40>
    80000ab2:	00000097          	auipc	ra,0x0
    80000ab6:	a8e080e7          	jalr	-1394(ra) # 80000540 <panic>
        panic("kfree");
    80000aba:	00007517          	auipc	a0,0x7
    80000abe:	5e650513          	addi	a0,a0,1510 # 800080a0 <digits+0x50>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	a7e080e7          	jalr	-1410(ra) # 80000540 <panic>

0000000080000aca <freerange>:
{
    80000aca:	7179                	addi	sp,sp,-48
    80000acc:	f406                	sd	ra,40(sp)
    80000ace:	f022                	sd	s0,32(sp)
    80000ad0:	ec26                	sd	s1,24(sp)
    80000ad2:	e84a                	sd	s2,16(sp)
    80000ad4:	e44e                	sd	s3,8(sp)
    80000ad6:	e052                	sd	s4,0(sp)
    80000ad8:	1800                	addi	s0,sp,48
    p = (char *)PGROUNDUP((uint64)pa_start);
    80000ada:	6785                	lui	a5,0x1
    80000adc:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ae0:	00e504b3          	add	s1,a0,a4
    80000ae4:	777d                	lui	a4,0xfffff
    80000ae6:	8cf9                	and	s1,s1,a4
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000ae8:	94be                	add	s1,s1,a5
    80000aea:	0095ee63          	bltu	a1,s1,80000b06 <freerange+0x3c>
    80000aee:	892e                	mv	s2,a1
        kfree(p);
    80000af0:	7a7d                	lui	s4,0xfffff
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000af2:	6985                	lui	s3,0x1
        kfree(p);
    80000af4:	01448533          	add	a0,s1,s4
    80000af8:	00000097          	auipc	ra,0x0
    80000afc:	f02080e7          	jalr	-254(ra) # 800009fa <kfree>
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    80000b00:	94ce                	add	s1,s1,s3
    80000b02:	fe9979e3          	bgeu	s2,s1,80000af4 <freerange+0x2a>
}
    80000b06:	70a2                	ld	ra,40(sp)
    80000b08:	7402                	ld	s0,32(sp)
    80000b0a:	64e2                	ld	s1,24(sp)
    80000b0c:	6942                	ld	s2,16(sp)
    80000b0e:	69a2                	ld	s3,8(sp)
    80000b10:	6a02                	ld	s4,0(sp)
    80000b12:	6145                	addi	sp,sp,48
    80000b14:	8082                	ret

0000000080000b16 <kinit>:
{
    80000b16:	1141                	addi	sp,sp,-16
    80000b18:	e406                	sd	ra,8(sp)
    80000b1a:	e022                	sd	s0,0(sp)
    80000b1c:	0800                	addi	s0,sp,16
    initlock(&kmem.lock, "kmem");
    80000b1e:	00007597          	auipc	a1,0x7
    80000b22:	58a58593          	addi	a1,a1,1418 # 800080a8 <digits+0x58>
    80000b26:	00010517          	auipc	a0,0x10
    80000b2a:	20a50513          	addi	a0,a0,522 # 80010d30 <kmem>
    80000b2e:	00000097          	auipc	ra,0x0
    80000b32:	0e0080e7          	jalr	224(ra) # 80000c0e <initlock>
    freerange(end, (void *)PHYSTOP);
    80000b36:	45c5                	li	a1,17
    80000b38:	05ee                	slli	a1,a1,0x1b
    80000b3a:	00021517          	auipc	a0,0x21
    80000b3e:	42650513          	addi	a0,a0,1062 # 80021f60 <end>
    80000b42:	00000097          	auipc	ra,0x0
    80000b46:	f88080e7          	jalr	-120(ra) # 80000aca <freerange>
    MAX_PAGES = FREE_PAGES;
    80000b4a:	00008797          	auipc	a5,0x8
    80000b4e:	f6e7b783          	ld	a5,-146(a5) # 80008ab8 <FREE_PAGES>
    80000b52:	00008717          	auipc	a4,0x8
    80000b56:	f6f73723          	sd	a5,-146(a4) # 80008ac0 <MAX_PAGES>
}
    80000b5a:	60a2                	ld	ra,8(sp)
    80000b5c:	6402                	ld	s0,0(sp)
    80000b5e:	0141                	addi	sp,sp,16
    80000b60:	8082                	ret

0000000080000b62 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b62:	1101                	addi	sp,sp,-32
    80000b64:	ec06                	sd	ra,24(sp)
    80000b66:	e822                	sd	s0,16(sp)
    80000b68:	e426                	sd	s1,8(sp)
    80000b6a:	1000                	addi	s0,sp,32
    assert(FREE_PAGES > 0);
    80000b6c:	00008797          	auipc	a5,0x8
    80000b70:	f4c7b783          	ld	a5,-180(a5) # 80008ab8 <FREE_PAGES>
    80000b74:	cbb1                	beqz	a5,80000bc8 <kalloc+0x66>
    struct run *r;

    acquire(&kmem.lock);
    80000b76:	00010497          	auipc	s1,0x10
    80000b7a:	1ba48493          	addi	s1,s1,442 # 80010d30 <kmem>
    80000b7e:	8526                	mv	a0,s1
    80000b80:	00000097          	auipc	ra,0x0
    80000b84:	11e080e7          	jalr	286(ra) # 80000c9e <acquire>
    r = kmem.freelist;
    80000b88:	6c84                	ld	s1,24(s1)
    if (r)
    80000b8a:	c8ad                	beqz	s1,80000bfc <kalloc+0x9a>
        kmem.freelist = r->next;
    80000b8c:	609c                	ld	a5,0(s1)
    80000b8e:	00010517          	auipc	a0,0x10
    80000b92:	1a250513          	addi	a0,a0,418 # 80010d30 <kmem>
    80000b96:	ed1c                	sd	a5,24(a0)
    release(&kmem.lock);
    80000b98:	00000097          	auipc	ra,0x0
    80000b9c:	1ba080e7          	jalr	442(ra) # 80000d52 <release>

    if (r)
        memset((char *)r, 5, PGSIZE); // fill with junk
    80000ba0:	6605                	lui	a2,0x1
    80000ba2:	4595                	li	a1,5
    80000ba4:	8526                	mv	a0,s1
    80000ba6:	00000097          	auipc	ra,0x0
    80000baa:	1f4080e7          	jalr	500(ra) # 80000d9a <memset>
    FREE_PAGES--;
    80000bae:	00008717          	auipc	a4,0x8
    80000bb2:	f0a70713          	addi	a4,a4,-246 # 80008ab8 <FREE_PAGES>
    80000bb6:	631c                	ld	a5,0(a4)
    80000bb8:	17fd                	addi	a5,a5,-1
    80000bba:	e31c                	sd	a5,0(a4)
    return (void *)r;
}
    80000bbc:	8526                	mv	a0,s1
    80000bbe:	60e2                	ld	ra,24(sp)
    80000bc0:	6442                	ld	s0,16(sp)
    80000bc2:	64a2                	ld	s1,8(sp)
    80000bc4:	6105                	addi	sp,sp,32
    80000bc6:	8082                	ret
    assert(FREE_PAGES > 0);
    80000bc8:	04f00693          	li	a3,79
    80000bcc:	00007617          	auipc	a2,0x7
    80000bd0:	43460613          	addi	a2,a2,1076 # 80008000 <etext>
    80000bd4:	00007597          	auipc	a1,0x7
    80000bd8:	49c58593          	addi	a1,a1,1180 # 80008070 <digits+0x20>
    80000bdc:	00007517          	auipc	a0,0x7
    80000be0:	4a450513          	addi	a0,a0,1188 # 80008080 <digits+0x30>
    80000be4:	00000097          	auipc	ra,0x0
    80000be8:	9b8080e7          	jalr	-1608(ra) # 8000059c <printf>
    80000bec:	00007517          	auipc	a0,0x7
    80000bf0:	4a450513          	addi	a0,a0,1188 # 80008090 <digits+0x40>
    80000bf4:	00000097          	auipc	ra,0x0
    80000bf8:	94c080e7          	jalr	-1716(ra) # 80000540 <panic>
    release(&kmem.lock);
    80000bfc:	00010517          	auipc	a0,0x10
    80000c00:	13450513          	addi	a0,a0,308 # 80010d30 <kmem>
    80000c04:	00000097          	auipc	ra,0x0
    80000c08:	14e080e7          	jalr	334(ra) # 80000d52 <release>
    if (r)
    80000c0c:	b74d                	j	80000bae <kalloc+0x4c>

0000000080000c0e <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000c0e:	1141                	addi	sp,sp,-16
    80000c10:	e422                	sd	s0,8(sp)
    80000c12:	0800                	addi	s0,sp,16
  lk->name = name;
    80000c14:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000c16:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000c1a:	00053823          	sd	zero,16(a0)
}
    80000c1e:	6422                	ld	s0,8(sp)
    80000c20:	0141                	addi	sp,sp,16
    80000c22:	8082                	ret

0000000080000c24 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000c24:	411c                	lw	a5,0(a0)
    80000c26:	e399                	bnez	a5,80000c2c <holding+0x8>
    80000c28:	4501                	li	a0,0
  return r;
}
    80000c2a:	8082                	ret
{
    80000c2c:	1101                	addi	sp,sp,-32
    80000c2e:	ec06                	sd	ra,24(sp)
    80000c30:	e822                	sd	s0,16(sp)
    80000c32:	e426                	sd	s1,8(sp)
    80000c34:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000c36:	6904                	ld	s1,16(a0)
    80000c38:	00001097          	auipc	ra,0x1
    80000c3c:	fdc080e7          	jalr	-36(ra) # 80001c14 <mycpu>
    80000c40:	40a48533          	sub	a0,s1,a0
    80000c44:	00153513          	seqz	a0,a0
}
    80000c48:	60e2                	ld	ra,24(sp)
    80000c4a:	6442                	ld	s0,16(sp)
    80000c4c:	64a2                	ld	s1,8(sp)
    80000c4e:	6105                	addi	sp,sp,32
    80000c50:	8082                	ret

0000000080000c52 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000c52:	1101                	addi	sp,sp,-32
    80000c54:	ec06                	sd	ra,24(sp)
    80000c56:	e822                	sd	s0,16(sp)
    80000c58:	e426                	sd	s1,8(sp)
    80000c5a:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c5c:	100024f3          	csrr	s1,sstatus
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000c64:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c66:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000c6a:	00001097          	auipc	ra,0x1
    80000c6e:	faa080e7          	jalr	-86(ra) # 80001c14 <mycpu>
    80000c72:	5d3c                	lw	a5,120(a0)
    80000c74:	cf89                	beqz	a5,80000c8e <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000c76:	00001097          	auipc	ra,0x1
    80000c7a:	f9e080e7          	jalr	-98(ra) # 80001c14 <mycpu>
    80000c7e:	5d3c                	lw	a5,120(a0)
    80000c80:	2785                	addiw	a5,a5,1
    80000c82:	dd3c                	sw	a5,120(a0)
}
    80000c84:	60e2                	ld	ra,24(sp)
    80000c86:	6442                	ld	s0,16(sp)
    80000c88:	64a2                	ld	s1,8(sp)
    80000c8a:	6105                	addi	sp,sp,32
    80000c8c:	8082                	ret
    mycpu()->intena = old;
    80000c8e:	00001097          	auipc	ra,0x1
    80000c92:	f86080e7          	jalr	-122(ra) # 80001c14 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000c96:	8085                	srli	s1,s1,0x1
    80000c98:	8885                	andi	s1,s1,1
    80000c9a:	dd64                	sw	s1,124(a0)
    80000c9c:	bfe9                	j	80000c76 <push_off+0x24>

0000000080000c9e <acquire>:
{
    80000c9e:	1101                	addi	sp,sp,-32
    80000ca0:	ec06                	sd	ra,24(sp)
    80000ca2:	e822                	sd	s0,16(sp)
    80000ca4:	e426                	sd	s1,8(sp)
    80000ca6:	1000                	addi	s0,sp,32
    80000ca8:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000caa:	00000097          	auipc	ra,0x0
    80000cae:	fa8080e7          	jalr	-88(ra) # 80000c52 <push_off>
  if(holding(lk))
    80000cb2:	8526                	mv	a0,s1
    80000cb4:	00000097          	auipc	ra,0x0
    80000cb8:	f70080e7          	jalr	-144(ra) # 80000c24 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cbc:	4705                	li	a4,1
  if(holding(lk))
    80000cbe:	e115                	bnez	a0,80000ce2 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000cc0:	87ba                	mv	a5,a4
    80000cc2:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000cc6:	2781                	sext.w	a5,a5
    80000cc8:	ffe5                	bnez	a5,80000cc0 <acquire+0x22>
  __sync_synchronize();
    80000cca:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000cce:	00001097          	auipc	ra,0x1
    80000cd2:	f46080e7          	jalr	-186(ra) # 80001c14 <mycpu>
    80000cd6:	e888                	sd	a0,16(s1)
}
    80000cd8:	60e2                	ld	ra,24(sp)
    80000cda:	6442                	ld	s0,16(sp)
    80000cdc:	64a2                	ld	s1,8(sp)
    80000cde:	6105                	addi	sp,sp,32
    80000ce0:	8082                	ret
    panic("acquire");
    80000ce2:	00007517          	auipc	a0,0x7
    80000ce6:	3ce50513          	addi	a0,a0,974 # 800080b0 <digits+0x60>
    80000cea:	00000097          	auipc	ra,0x0
    80000cee:	856080e7          	jalr	-1962(ra) # 80000540 <panic>

0000000080000cf2 <pop_off>:

void
pop_off(void)
{
    80000cf2:	1141                	addi	sp,sp,-16
    80000cf4:	e406                	sd	ra,8(sp)
    80000cf6:	e022                	sd	s0,0(sp)
    80000cf8:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000cfa:	00001097          	auipc	ra,0x1
    80000cfe:	f1a080e7          	jalr	-230(ra) # 80001c14 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d02:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000d06:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000d08:	e78d                	bnez	a5,80000d32 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000d0a:	5d3c                	lw	a5,120(a0)
    80000d0c:	02f05b63          	blez	a5,80000d42 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000d10:	37fd                	addiw	a5,a5,-1
    80000d12:	0007871b          	sext.w	a4,a5
    80000d16:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000d18:	eb09                	bnez	a4,80000d2a <pop_off+0x38>
    80000d1a:	5d7c                	lw	a5,124(a0)
    80000d1c:	c799                	beqz	a5,80000d2a <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000d1e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000d22:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000d26:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000d2a:	60a2                	ld	ra,8(sp)
    80000d2c:	6402                	ld	s0,0(sp)
    80000d2e:	0141                	addi	sp,sp,16
    80000d30:	8082                	ret
    panic("pop_off - interruptible");
    80000d32:	00007517          	auipc	a0,0x7
    80000d36:	38650513          	addi	a0,a0,902 # 800080b8 <digits+0x68>
    80000d3a:	00000097          	auipc	ra,0x0
    80000d3e:	806080e7          	jalr	-2042(ra) # 80000540 <panic>
    panic("pop_off");
    80000d42:	00007517          	auipc	a0,0x7
    80000d46:	38e50513          	addi	a0,a0,910 # 800080d0 <digits+0x80>
    80000d4a:	fffff097          	auipc	ra,0xfffff
    80000d4e:	7f6080e7          	jalr	2038(ra) # 80000540 <panic>

0000000080000d52 <release>:
{
    80000d52:	1101                	addi	sp,sp,-32
    80000d54:	ec06                	sd	ra,24(sp)
    80000d56:	e822                	sd	s0,16(sp)
    80000d58:	e426                	sd	s1,8(sp)
    80000d5a:	1000                	addi	s0,sp,32
    80000d5c:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000d5e:	00000097          	auipc	ra,0x0
    80000d62:	ec6080e7          	jalr	-314(ra) # 80000c24 <holding>
    80000d66:	c115                	beqz	a0,80000d8a <release+0x38>
  lk->cpu = 0;
    80000d68:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000d6c:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000d70:	0f50000f          	fence	iorw,ow
    80000d74:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000d78:	00000097          	auipc	ra,0x0
    80000d7c:	f7a080e7          	jalr	-134(ra) # 80000cf2 <pop_off>
}
    80000d80:	60e2                	ld	ra,24(sp)
    80000d82:	6442                	ld	s0,16(sp)
    80000d84:	64a2                	ld	s1,8(sp)
    80000d86:	6105                	addi	sp,sp,32
    80000d88:	8082                	ret
    panic("release");
    80000d8a:	00007517          	auipc	a0,0x7
    80000d8e:	34e50513          	addi	a0,a0,846 # 800080d8 <digits+0x88>
    80000d92:	fffff097          	auipc	ra,0xfffff
    80000d96:	7ae080e7          	jalr	1966(ra) # 80000540 <panic>

0000000080000d9a <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000d9a:	1141                	addi	sp,sp,-16
    80000d9c:	e422                	sd	s0,8(sp)
    80000d9e:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000da0:	ca19                	beqz	a2,80000db6 <memset+0x1c>
    80000da2:	87aa                	mv	a5,a0
    80000da4:	1602                	slli	a2,a2,0x20
    80000da6:	9201                	srli	a2,a2,0x20
    80000da8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000dac:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000db0:	0785                	addi	a5,a5,1
    80000db2:	fee79de3          	bne	a5,a4,80000dac <memset+0x12>
  }
  return dst;
}
    80000db6:	6422                	ld	s0,8(sp)
    80000db8:	0141                	addi	sp,sp,16
    80000dba:	8082                	ret

0000000080000dbc <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000dbc:	1141                	addi	sp,sp,-16
    80000dbe:	e422                	sd	s0,8(sp)
    80000dc0:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000dc2:	ca05                	beqz	a2,80000df2 <memcmp+0x36>
    80000dc4:	fff6069b          	addiw	a3,a2,-1
    80000dc8:	1682                	slli	a3,a3,0x20
    80000dca:	9281                	srli	a3,a3,0x20
    80000dcc:	0685                	addi	a3,a3,1
    80000dce:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000dd0:	00054783          	lbu	a5,0(a0)
    80000dd4:	0005c703          	lbu	a4,0(a1)
    80000dd8:	00e79863          	bne	a5,a4,80000de8 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000ddc:	0505                	addi	a0,a0,1
    80000dde:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000de0:	fed518e3          	bne	a0,a3,80000dd0 <memcmp+0x14>
  }

  return 0;
    80000de4:	4501                	li	a0,0
    80000de6:	a019                	j	80000dec <memcmp+0x30>
      return *s1 - *s2;
    80000de8:	40e7853b          	subw	a0,a5,a4
}
    80000dec:	6422                	ld	s0,8(sp)
    80000dee:	0141                	addi	sp,sp,16
    80000df0:	8082                	ret
  return 0;
    80000df2:	4501                	li	a0,0
    80000df4:	bfe5                	j	80000dec <memcmp+0x30>

0000000080000df6 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000df6:	1141                	addi	sp,sp,-16
    80000df8:	e422                	sd	s0,8(sp)
    80000dfa:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000dfc:	c205                	beqz	a2,80000e1c <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000dfe:	02a5e263          	bltu	a1,a0,80000e22 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000e02:	1602                	slli	a2,a2,0x20
    80000e04:	9201                	srli	a2,a2,0x20
    80000e06:	00c587b3          	add	a5,a1,a2
{
    80000e0a:	872a                	mv	a4,a0
      *d++ = *s++;
    80000e0c:	0585                	addi	a1,a1,1
    80000e0e:	0705                	addi	a4,a4,1
    80000e10:	fff5c683          	lbu	a3,-1(a1)
    80000e14:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000e18:	fef59ae3          	bne	a1,a5,80000e0c <memmove+0x16>

  return dst;
}
    80000e1c:	6422                	ld	s0,8(sp)
    80000e1e:	0141                	addi	sp,sp,16
    80000e20:	8082                	ret
  if(s < d && s + n > d){
    80000e22:	02061693          	slli	a3,a2,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	00d58733          	add	a4,a1,a3
    80000e2c:	fce57be3          	bgeu	a0,a4,80000e02 <memmove+0xc>
    d += n;
    80000e30:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000e32:	fff6079b          	addiw	a5,a2,-1
    80000e36:	1782                	slli	a5,a5,0x20
    80000e38:	9381                	srli	a5,a5,0x20
    80000e3a:	fff7c793          	not	a5,a5
    80000e3e:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000e40:	177d                	addi	a4,a4,-1
    80000e42:	16fd                	addi	a3,a3,-1
    80000e44:	00074603          	lbu	a2,0(a4)
    80000e48:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000e4c:	fee79ae3          	bne	a5,a4,80000e40 <memmove+0x4a>
    80000e50:	b7f1                	j	80000e1c <memmove+0x26>

0000000080000e52 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000e52:	1141                	addi	sp,sp,-16
    80000e54:	e406                	sd	ra,8(sp)
    80000e56:	e022                	sd	s0,0(sp)
    80000e58:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000e5a:	00000097          	auipc	ra,0x0
    80000e5e:	f9c080e7          	jalr	-100(ra) # 80000df6 <memmove>
}
    80000e62:	60a2                	ld	ra,8(sp)
    80000e64:	6402                	ld	s0,0(sp)
    80000e66:	0141                	addi	sp,sp,16
    80000e68:	8082                	ret

0000000080000e6a <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000e6a:	1141                	addi	sp,sp,-16
    80000e6c:	e422                	sd	s0,8(sp)
    80000e6e:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000e70:	ce11                	beqz	a2,80000e8c <strncmp+0x22>
    80000e72:	00054783          	lbu	a5,0(a0)
    80000e76:	cf89                	beqz	a5,80000e90 <strncmp+0x26>
    80000e78:	0005c703          	lbu	a4,0(a1)
    80000e7c:	00f71a63          	bne	a4,a5,80000e90 <strncmp+0x26>
    n--, p++, q++;
    80000e80:	367d                	addiw	a2,a2,-1
    80000e82:	0505                	addi	a0,a0,1
    80000e84:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000e86:	f675                	bnez	a2,80000e72 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000e88:	4501                	li	a0,0
    80000e8a:	a809                	j	80000e9c <strncmp+0x32>
    80000e8c:	4501                	li	a0,0
    80000e8e:	a039                	j	80000e9c <strncmp+0x32>
  if(n == 0)
    80000e90:	ca09                	beqz	a2,80000ea2 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000e92:	00054503          	lbu	a0,0(a0)
    80000e96:	0005c783          	lbu	a5,0(a1)
    80000e9a:	9d1d                	subw	a0,a0,a5
}
    80000e9c:	6422                	ld	s0,8(sp)
    80000e9e:	0141                	addi	sp,sp,16
    80000ea0:	8082                	ret
    return 0;
    80000ea2:	4501                	li	a0,0
    80000ea4:	bfe5                	j	80000e9c <strncmp+0x32>

0000000080000ea6 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000ea6:	1141                	addi	sp,sp,-16
    80000ea8:	e422                	sd	s0,8(sp)
    80000eaa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000eac:	872a                	mv	a4,a0
    80000eae:	8832                	mv	a6,a2
    80000eb0:	367d                	addiw	a2,a2,-1
    80000eb2:	01005963          	blez	a6,80000ec4 <strncpy+0x1e>
    80000eb6:	0705                	addi	a4,a4,1
    80000eb8:	0005c783          	lbu	a5,0(a1)
    80000ebc:	fef70fa3          	sb	a5,-1(a4)
    80000ec0:	0585                	addi	a1,a1,1
    80000ec2:	f7f5                	bnez	a5,80000eae <strncpy+0x8>
    ;
  while(n-- > 0)
    80000ec4:	86ba                	mv	a3,a4
    80000ec6:	00c05c63          	blez	a2,80000ede <strncpy+0x38>
    *s++ = 0;
    80000eca:	0685                	addi	a3,a3,1
    80000ecc:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000ed0:	40d707bb          	subw	a5,a4,a3
    80000ed4:	37fd                	addiw	a5,a5,-1
    80000ed6:	010787bb          	addw	a5,a5,a6
    80000eda:	fef048e3          	bgtz	a5,80000eca <strncpy+0x24>
  return os;
}
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret

0000000080000ee4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000eea:	02c05363          	blez	a2,80000f10 <safestrcpy+0x2c>
    80000eee:	fff6069b          	addiw	a3,a2,-1
    80000ef2:	1682                	slli	a3,a3,0x20
    80000ef4:	9281                	srli	a3,a3,0x20
    80000ef6:	96ae                	add	a3,a3,a1
    80000ef8:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000efa:	00d58963          	beq	a1,a3,80000f0c <safestrcpy+0x28>
    80000efe:	0585                	addi	a1,a1,1
    80000f00:	0785                	addi	a5,a5,1
    80000f02:	fff5c703          	lbu	a4,-1(a1)
    80000f06:	fee78fa3          	sb	a4,-1(a5)
    80000f0a:	fb65                	bnez	a4,80000efa <safestrcpy+0x16>
    ;
  *s = 0;
    80000f0c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000f10:	6422                	ld	s0,8(sp)
    80000f12:	0141                	addi	sp,sp,16
    80000f14:	8082                	ret

0000000080000f16 <strlen>:

int
strlen(const char *s)
{
    80000f16:	1141                	addi	sp,sp,-16
    80000f18:	e422                	sd	s0,8(sp)
    80000f1a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000f1c:	00054783          	lbu	a5,0(a0)
    80000f20:	cf91                	beqz	a5,80000f3c <strlen+0x26>
    80000f22:	0505                	addi	a0,a0,1
    80000f24:	87aa                	mv	a5,a0
    80000f26:	4685                	li	a3,1
    80000f28:	9e89                	subw	a3,a3,a0
    80000f2a:	00f6853b          	addw	a0,a3,a5
    80000f2e:	0785                	addi	a5,a5,1
    80000f30:	fff7c703          	lbu	a4,-1(a5)
    80000f34:	fb7d                	bnez	a4,80000f2a <strlen+0x14>
    ;
  return n;
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret
  for(n = 0; s[n]; n++)
    80000f3c:	4501                	li	a0,0
    80000f3e:	bfe5                	j	80000f36 <strlen+0x20>

0000000080000f40 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000f40:	1141                	addi	sp,sp,-16
    80000f42:	e406                	sd	ra,8(sp)
    80000f44:	e022                	sd	s0,0(sp)
    80000f46:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000f48:	00001097          	auipc	ra,0x1
    80000f4c:	cbc080e7          	jalr	-836(ra) # 80001c04 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000f50:	00008717          	auipc	a4,0x8
    80000f54:	b7870713          	addi	a4,a4,-1160 # 80008ac8 <started>
  if(cpuid() == 0){
    80000f58:	c139                	beqz	a0,80000f9e <main+0x5e>
    while(started == 0)
    80000f5a:	431c                	lw	a5,0(a4)
    80000f5c:	2781                	sext.w	a5,a5
    80000f5e:	dff5                	beqz	a5,80000f5a <main+0x1a>
      ;
    __sync_synchronize();
    80000f60:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000f64:	00001097          	auipc	ra,0x1
    80000f68:	ca0080e7          	jalr	-864(ra) # 80001c04 <cpuid>
    80000f6c:	85aa                	mv	a1,a0
    80000f6e:	00007517          	auipc	a0,0x7
    80000f72:	18a50513          	addi	a0,a0,394 # 800080f8 <digits+0xa8>
    80000f76:	fffff097          	auipc	ra,0xfffff
    80000f7a:	626080e7          	jalr	1574(ra) # 8000059c <printf>
    kvminithart();    // turn on paging
    80000f7e:	00000097          	auipc	ra,0x0
    80000f82:	0d8080e7          	jalr	216(ra) # 80001056 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000f86:	00002097          	auipc	ra,0x2
    80000f8a:	cf2080e7          	jalr	-782(ra) # 80002c78 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000f8e:	00005097          	auipc	ra,0x5
    80000f92:	462080e7          	jalr	1122(ra) # 800063f0 <plicinithart>
  }

  scheduler();        
    80000f96:	00001097          	auipc	ra,0x1
    80000f9a:	466080e7          	jalr	1126(ra) # 800023fc <scheduler>
    consoleinit();
    80000f9e:	fffff097          	auipc	ra,0xfffff
    80000fa2:	4b2080e7          	jalr	1202(ra) # 80000450 <consoleinit>
    printfinit();
    80000fa6:	fffff097          	auipc	ra,0xfffff
    80000faa:	7d6080e7          	jalr	2006(ra) # 8000077c <printfinit>
    printf("\n");
    80000fae:	00007517          	auipc	a0,0x7
    80000fb2:	0da50513          	addi	a0,a0,218 # 80008088 <digits+0x38>
    80000fb6:	fffff097          	auipc	ra,0xfffff
    80000fba:	5e6080e7          	jalr	1510(ra) # 8000059c <printf>
    printf("xv6 kernel is booting\n");
    80000fbe:	00007517          	auipc	a0,0x7
    80000fc2:	12250513          	addi	a0,a0,290 # 800080e0 <digits+0x90>
    80000fc6:	fffff097          	auipc	ra,0xfffff
    80000fca:	5d6080e7          	jalr	1494(ra) # 8000059c <printf>
    printf("\n");
    80000fce:	00007517          	auipc	a0,0x7
    80000fd2:	0ba50513          	addi	a0,a0,186 # 80008088 <digits+0x38>
    80000fd6:	fffff097          	auipc	ra,0xfffff
    80000fda:	5c6080e7          	jalr	1478(ra) # 8000059c <printf>
    kinit();         // physical page allocator
    80000fde:	00000097          	auipc	ra,0x0
    80000fe2:	b38080e7          	jalr	-1224(ra) # 80000b16 <kinit>
    kvminit();       // create kernel page table
    80000fe6:	00000097          	auipc	ra,0x0
    80000fea:	346080e7          	jalr	838(ra) # 8000132c <kvminit>
    kvminithart();   // turn on paging
    80000fee:	00000097          	auipc	ra,0x0
    80000ff2:	068080e7          	jalr	104(ra) # 80001056 <kvminithart>
    procinit();      // process table
    80000ff6:	00001097          	auipc	ra,0x1
    80000ffa:	b2c080e7          	jalr	-1236(ra) # 80001b22 <procinit>
    trapinit();      // trap vectors
    80000ffe:	00002097          	auipc	ra,0x2
    80001002:	c52080e7          	jalr	-942(ra) # 80002c50 <trapinit>
    trapinithart();  // install kernel trap vector
    80001006:	00002097          	auipc	ra,0x2
    8000100a:	c72080e7          	jalr	-910(ra) # 80002c78 <trapinithart>
    plicinit();      // set up interrupt controller
    8000100e:	00005097          	auipc	ra,0x5
    80001012:	3cc080e7          	jalr	972(ra) # 800063da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80001016:	00005097          	auipc	ra,0x5
    8000101a:	3da080e7          	jalr	986(ra) # 800063f0 <plicinithart>
    binit();         // buffer cache
    8000101e:	00002097          	auipc	ra,0x2
    80001022:	56e080e7          	jalr	1390(ra) # 8000358c <binit>
    iinit();         // inode table
    80001026:	00003097          	auipc	ra,0x3
    8000102a:	c0e080e7          	jalr	-1010(ra) # 80003c34 <iinit>
    fileinit();      // file table
    8000102e:	00004097          	auipc	ra,0x4
    80001032:	bb4080e7          	jalr	-1100(ra) # 80004be2 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80001036:	00005097          	auipc	ra,0x5
    8000103a:	4c2080e7          	jalr	1218(ra) # 800064f8 <virtio_disk_init>
    userinit();      // first user process
    8000103e:	00001097          	auipc	ra,0x1
    80001042:	eca080e7          	jalr	-310(ra) # 80001f08 <userinit>
    __sync_synchronize();
    80001046:	0ff0000f          	fence
    started = 1;
    8000104a:	4785                	li	a5,1
    8000104c:	00008717          	auipc	a4,0x8
    80001050:	a6f72e23          	sw	a5,-1412(a4) # 80008ac8 <started>
    80001054:	b789                	j	80000f96 <main+0x56>

0000000080001056 <kvminithart>:
}

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void kvminithart()
{
    80001056:	1141                	addi	sp,sp,-16
    80001058:	e422                	sd	s0,8(sp)
    8000105a:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000105c:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80001060:	00008797          	auipc	a5,0x8
    80001064:	a707b783          	ld	a5,-1424(a5) # 80008ad0 <kernel_pagetable>
    80001068:	83b1                	srli	a5,a5,0xc
    8000106a:	577d                	li	a4,-1
    8000106c:	177e                	slli	a4,a4,0x3f
    8000106e:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80001070:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80001074:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80001078:	6422                	ld	s0,8(sp)
    8000107a:	0141                	addi	sp,sp,16
    8000107c:	8082                	ret

000000008000107e <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    8000107e:	7139                	addi	sp,sp,-64
    80001080:	fc06                	sd	ra,56(sp)
    80001082:	f822                	sd	s0,48(sp)
    80001084:	f426                	sd	s1,40(sp)
    80001086:	f04a                	sd	s2,32(sp)
    80001088:	ec4e                	sd	s3,24(sp)
    8000108a:	e852                	sd	s4,16(sp)
    8000108c:	e456                	sd	s5,8(sp)
    8000108e:	e05a                	sd	s6,0(sp)
    80001090:	0080                	addi	s0,sp,64
    80001092:	84aa                	mv	s1,a0
    80001094:	89ae                	mv	s3,a1
    80001096:	8ab2                	mv	s5,a2
  if (va >= MAXVA)
    80001098:	57fd                	li	a5,-1
    8000109a:	83e9                	srli	a5,a5,0x1a
    8000109c:	4a79                	li	s4,30
    panic("walk");

  for (int level = 2; level > 0; level--)
    8000109e:	4b31                	li	s6,12
  if (va >= MAXVA)
    800010a0:	04b7f263          	bgeu	a5,a1,800010e4 <walk+0x66>
    panic("walk");
    800010a4:	00007517          	auipc	a0,0x7
    800010a8:	06c50513          	addi	a0,a0,108 # 80008110 <digits+0xc0>
    800010ac:	fffff097          	auipc	ra,0xfffff
    800010b0:	494080e7          	jalr	1172(ra) # 80000540 <panic>
    {
      pagetable = (pagetable_t)PTE2PA(*pte);
    }
    else
    {
      if (!alloc || (pagetable = (pde_t *)kalloc()) == 0)
    800010b4:	060a8663          	beqz	s5,80001120 <walk+0xa2>
    800010b8:	00000097          	auipc	ra,0x0
    800010bc:	aaa080e7          	jalr	-1366(ra) # 80000b62 <kalloc>
    800010c0:	84aa                	mv	s1,a0
    800010c2:	c529                	beqz	a0,8000110c <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800010c4:	6605                	lui	a2,0x1
    800010c6:	4581                	li	a1,0
    800010c8:	00000097          	auipc	ra,0x0
    800010cc:	cd2080e7          	jalr	-814(ra) # 80000d9a <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800010d0:	00c4d793          	srli	a5,s1,0xc
    800010d4:	07aa                	slli	a5,a5,0xa
    800010d6:	0017e793          	ori	a5,a5,1
    800010da:	00f93023          	sd	a5,0(s2)
  for (int level = 2; level > 0; level--)
    800010de:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd097>
    800010e0:	036a0063          	beq	s4,s6,80001100 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    800010e4:	0149d933          	srl	s2,s3,s4
    800010e8:	1ff97913          	andi	s2,s2,511
    800010ec:	090e                	slli	s2,s2,0x3
    800010ee:	9926                	add	s2,s2,s1
    if (*pte & PTE_V)
    800010f0:	00093483          	ld	s1,0(s2)
    800010f4:	0014f793          	andi	a5,s1,1
    800010f8:	dfd5                	beqz	a5,800010b4 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    800010fa:	80a9                	srli	s1,s1,0xa
    800010fc:	04b2                	slli	s1,s1,0xc
    800010fe:	b7c5                	j	800010de <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001100:	00c9d513          	srli	a0,s3,0xc
    80001104:	1ff57513          	andi	a0,a0,511
    80001108:	050e                	slli	a0,a0,0x3
    8000110a:	9526                	add	a0,a0,s1
}
    8000110c:	70e2                	ld	ra,56(sp)
    8000110e:	7442                	ld	s0,48(sp)
    80001110:	74a2                	ld	s1,40(sp)
    80001112:	7902                	ld	s2,32(sp)
    80001114:	69e2                	ld	s3,24(sp)
    80001116:	6a42                	ld	s4,16(sp)
    80001118:	6aa2                	ld	s5,8(sp)
    8000111a:	6b02                	ld	s6,0(sp)
    8000111c:	6121                	addi	sp,sp,64
    8000111e:	8082                	ret
        return 0;
    80001120:	4501                	li	a0,0
    80001122:	b7ed                	j	8000110c <walk+0x8e>

0000000080001124 <walkaddr>:
// Look up a virtual address, return the physical address,
// or 0 if not mapped.
// Can only be used to look up user pages.
uint64
walkaddr(pagetable_t pagetable, uint64 va)
{
    80001124:	1101                	addi	sp,sp,-32
    80001126:	ec06                	sd	ra,24(sp)
    80001128:	e822                	sd	s0,16(sp)
    8000112a:	e426                	sd	s1,8(sp)
    8000112c:	e04a                	sd	s2,0(sp)
    8000112e:	1000                	addi	s0,sp,32
  pte_t *pte;
  uint64 pa;

  if (va >= MAXVA)
    80001130:	57fd                	li	a5,-1
    80001132:	83e9                	srli	a5,a5,0x1a
  {
    return 0;
    80001134:	4901                	li	s2,0
  if (va >= MAXVA)
    80001136:	00b7f963          	bgeu	a5,a1,80001148 <walkaddr+0x24>
  if (va == 2)
  {
    printf("60000\n");
  }
  return pa;
}
    8000113a:	854a                	mv	a0,s2
    8000113c:	60e2                	ld	ra,24(sp)
    8000113e:	6442                	ld	s0,16(sp)
    80001140:	64a2                	ld	s1,8(sp)
    80001142:	6902                	ld	s2,0(sp)
    80001144:	6105                	addi	sp,sp,32
    80001146:	8082                	ret
    80001148:	84ae                	mv	s1,a1
  pte = walk(pagetable, va, 0);
    8000114a:	4601                	li	a2,0
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f32080e7          	jalr	-206(ra) # 8000107e <walk>
  if (pte == 0)
    80001154:	c51d                	beqz	a0,80001182 <walkaddr+0x5e>
  if ((*pte & PTE_V) == 0)
    80001156:	611c                	ld	a5,0(a0)
  if ((*pte & PTE_U) == 0)
    80001158:	0117f693          	andi	a3,a5,17
    8000115c:	4745                	li	a4,17
    return 0;
    8000115e:	4901                	li	s2,0
  if ((*pte & PTE_U) == 0)
    80001160:	fce69de3          	bne	a3,a4,8000113a <walkaddr+0x16>
  pa = PTE2PA(*pte);
    80001164:	83a9                	srli	a5,a5,0xa
    80001166:	00c79913          	slli	s2,a5,0xc
  if (va == 2)
    8000116a:	4789                	li	a5,2
    8000116c:	fcf497e3          	bne	s1,a5,8000113a <walkaddr+0x16>
    printf("60000\n");
    80001170:	00007517          	auipc	a0,0x7
    80001174:	fa850513          	addi	a0,a0,-88 # 80008118 <digits+0xc8>
    80001178:	fffff097          	auipc	ra,0xfffff
    8000117c:	424080e7          	jalr	1060(ra) # 8000059c <printf>
    80001180:	bf6d                	j	8000113a <walkaddr+0x16>
    return 0;
    80001182:	4901                	li	s2,0
    80001184:	bf5d                	j	8000113a <walkaddr+0x16>

0000000080001186 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001186:	715d                	addi	sp,sp,-80
    80001188:	e486                	sd	ra,72(sp)
    8000118a:	e0a2                	sd	s0,64(sp)
    8000118c:	fc26                	sd	s1,56(sp)
    8000118e:	f84a                	sd	s2,48(sp)
    80001190:	f44e                	sd	s3,40(sp)
    80001192:	f052                	sd	s4,32(sp)
    80001194:	ec56                	sd	s5,24(sp)
    80001196:	e85a                	sd	s6,16(sp)
    80001198:	e45e                	sd	s7,8(sp)
    8000119a:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if (size == 0)
    8000119c:	c639                	beqz	a2,800011ea <mappages+0x64>
    8000119e:	8aaa                	mv	s5,a0
    800011a0:	8b3a                	mv	s6,a4
    panic("mappages: size");

  a = PGROUNDDOWN(va);
    800011a2:	777d                	lui	a4,0xfffff
    800011a4:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800011a8:	fff58993          	addi	s3,a1,-1
    800011ac:	99b2                	add	s3,s3,a2
    800011ae:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800011b2:	893e                	mv	s2,a5
    800011b4:	40f68a33          	sub	s4,a3,a5
    if (*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if (a == last)
      break;
    a += PGSIZE;
    800011b8:	6b85                	lui	s7,0x1
    800011ba:	012a04b3          	add	s1,s4,s2
    if ((pte = walk(pagetable, a, 1)) == 0)
    800011be:	4605                	li	a2,1
    800011c0:	85ca                	mv	a1,s2
    800011c2:	8556                	mv	a0,s5
    800011c4:	00000097          	auipc	ra,0x0
    800011c8:	eba080e7          	jalr	-326(ra) # 8000107e <walk>
    800011cc:	cd1d                	beqz	a0,8000120a <mappages+0x84>
    if (*pte & PTE_V)
    800011ce:	611c                	ld	a5,0(a0)
    800011d0:	8b85                	andi	a5,a5,1
    800011d2:	e785                	bnez	a5,800011fa <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800011d4:	80b1                	srli	s1,s1,0xc
    800011d6:	04aa                	slli	s1,s1,0xa
    800011d8:	0164e4b3          	or	s1,s1,s6
    800011dc:	0014e493          	ori	s1,s1,1
    800011e0:	e104                	sd	s1,0(a0)
    if (a == last)
    800011e2:	05390063          	beq	s2,s3,80001222 <mappages+0x9c>
    a += PGSIZE;
    800011e6:	995e                	add	s2,s2,s7
    if ((pte = walk(pagetable, a, 1)) == 0)
    800011e8:	bfc9                	j	800011ba <mappages+0x34>
    panic("mappages: size");
    800011ea:	00007517          	auipc	a0,0x7
    800011ee:	f3650513          	addi	a0,a0,-202 # 80008120 <digits+0xd0>
    800011f2:	fffff097          	auipc	ra,0xfffff
    800011f6:	34e080e7          	jalr	846(ra) # 80000540 <panic>
      panic("mappages: remap");
    800011fa:	00007517          	auipc	a0,0x7
    800011fe:	f3650513          	addi	a0,a0,-202 # 80008130 <digits+0xe0>
    80001202:	fffff097          	auipc	ra,0xfffff
    80001206:	33e080e7          	jalr	830(ra) # 80000540 <panic>
      return -1;
    8000120a:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000120c:	60a6                	ld	ra,72(sp)
    8000120e:	6406                	ld	s0,64(sp)
    80001210:	74e2                	ld	s1,56(sp)
    80001212:	7942                	ld	s2,48(sp)
    80001214:	79a2                	ld	s3,40(sp)
    80001216:	7a02                	ld	s4,32(sp)
    80001218:	6ae2                	ld	s5,24(sp)
    8000121a:	6b42                	ld	s6,16(sp)
    8000121c:	6ba2                	ld	s7,8(sp)
    8000121e:	6161                	addi	sp,sp,80
    80001220:	8082                	ret
  return 0;
    80001222:	4501                	li	a0,0
    80001224:	b7e5                	j	8000120c <mappages+0x86>

0000000080001226 <kvmmap>:
{
    80001226:	1141                	addi	sp,sp,-16
    80001228:	e406                	sd	ra,8(sp)
    8000122a:	e022                	sd	s0,0(sp)
    8000122c:	0800                	addi	s0,sp,16
    8000122e:	87b6                	mv	a5,a3
  if (mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001230:	86b2                	mv	a3,a2
    80001232:	863e                	mv	a2,a5
    80001234:	00000097          	auipc	ra,0x0
    80001238:	f52080e7          	jalr	-174(ra) # 80001186 <mappages>
    8000123c:	e509                	bnez	a0,80001246 <kvmmap+0x20>
}
    8000123e:	60a2                	ld	ra,8(sp)
    80001240:	6402                	ld	s0,0(sp)
    80001242:	0141                	addi	sp,sp,16
    80001244:	8082                	ret
    panic("kvmmap");
    80001246:	00007517          	auipc	a0,0x7
    8000124a:	efa50513          	addi	a0,a0,-262 # 80008140 <digits+0xf0>
    8000124e:	fffff097          	auipc	ra,0xfffff
    80001252:	2f2080e7          	jalr	754(ra) # 80000540 <panic>

0000000080001256 <kvmmake>:
{
    80001256:	1101                	addi	sp,sp,-32
    80001258:	ec06                	sd	ra,24(sp)
    8000125a:	e822                	sd	s0,16(sp)
    8000125c:	e426                	sd	s1,8(sp)
    8000125e:	e04a                	sd	s2,0(sp)
    80001260:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t)kalloc();
    80001262:	00000097          	auipc	ra,0x0
    80001266:	900080e7          	jalr	-1792(ra) # 80000b62 <kalloc>
    8000126a:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000126c:	6605                	lui	a2,0x1
    8000126e:	4581                	li	a1,0
    80001270:	00000097          	auipc	ra,0x0
    80001274:	b2a080e7          	jalr	-1238(ra) # 80000d9a <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001278:	4719                	li	a4,6
    8000127a:	6685                	lui	a3,0x1
    8000127c:	10000637          	lui	a2,0x10000
    80001280:	100005b7          	lui	a1,0x10000
    80001284:	8526                	mv	a0,s1
    80001286:	00000097          	auipc	ra,0x0
    8000128a:	fa0080e7          	jalr	-96(ra) # 80001226 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    8000128e:	4719                	li	a4,6
    80001290:	6685                	lui	a3,0x1
    80001292:	10001637          	lui	a2,0x10001
    80001296:	100015b7          	lui	a1,0x10001
    8000129a:	8526                	mv	a0,s1
    8000129c:	00000097          	auipc	ra,0x0
    800012a0:	f8a080e7          	jalr	-118(ra) # 80001226 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800012a4:	4719                	li	a4,6
    800012a6:	004006b7          	lui	a3,0x400
    800012aa:	0c000637          	lui	a2,0xc000
    800012ae:	0c0005b7          	lui	a1,0xc000
    800012b2:	8526                	mv	a0,s1
    800012b4:	00000097          	auipc	ra,0x0
    800012b8:	f72080e7          	jalr	-142(ra) # 80001226 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext - KERNBASE, PTE_R | PTE_X);
    800012bc:	00007917          	auipc	s2,0x7
    800012c0:	d4490913          	addi	s2,s2,-700 # 80008000 <etext>
    800012c4:	4729                	li	a4,10
    800012c6:	80007697          	auipc	a3,0x80007
    800012ca:	d3a68693          	addi	a3,a3,-710 # 8000 <_entry-0x7fff8000>
    800012ce:	4605                	li	a2,1
    800012d0:	067e                	slli	a2,a2,0x1f
    800012d2:	85b2                	mv	a1,a2
    800012d4:	8526                	mv	a0,s1
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	f50080e7          	jalr	-176(ra) # 80001226 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP - (uint64)etext, PTE_R | PTE_W);
    800012de:	4719                	li	a4,6
    800012e0:	46c5                	li	a3,17
    800012e2:	06ee                	slli	a3,a3,0x1b
    800012e4:	412686b3          	sub	a3,a3,s2
    800012e8:	864a                	mv	a2,s2
    800012ea:	85ca                	mv	a1,s2
    800012ec:	8526                	mv	a0,s1
    800012ee:	00000097          	auipc	ra,0x0
    800012f2:	f38080e7          	jalr	-200(ra) # 80001226 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    800012f6:	4729                	li	a4,10
    800012f8:	6685                	lui	a3,0x1
    800012fa:	00006617          	auipc	a2,0x6
    800012fe:	d0660613          	addi	a2,a2,-762 # 80007000 <_trampoline>
    80001302:	040005b7          	lui	a1,0x4000
    80001306:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001308:	05b2                	slli	a1,a1,0xc
    8000130a:	8526                	mv	a0,s1
    8000130c:	00000097          	auipc	ra,0x0
    80001310:	f1a080e7          	jalr	-230(ra) # 80001226 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001314:	8526                	mv	a0,s1
    80001316:	00000097          	auipc	ra,0x0
    8000131a:	776080e7          	jalr	1910(ra) # 80001a8c <proc_mapstacks>
}
    8000131e:	8526                	mv	a0,s1
    80001320:	60e2                	ld	ra,24(sp)
    80001322:	6442                	ld	s0,16(sp)
    80001324:	64a2                	ld	s1,8(sp)
    80001326:	6902                	ld	s2,0(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret

000000008000132c <kvminit>:
{
    8000132c:	1141                	addi	sp,sp,-16
    8000132e:	e406                	sd	ra,8(sp)
    80001330:	e022                	sd	s0,0(sp)
    80001332:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001334:	00000097          	auipc	ra,0x0
    80001338:	f22080e7          	jalr	-222(ra) # 80001256 <kvmmake>
    8000133c:	00007797          	auipc	a5,0x7
    80001340:	78a7ba23          	sd	a0,1940(a5) # 80008ad0 <kernel_pagetable>
}
    80001344:	60a2                	ld	ra,8(sp)
    80001346:	6402                	ld	s0,0(sp)
    80001348:	0141                	addi	sp,sp,16
    8000134a:	8082                	ret

000000008000134c <uvmunmap>:

// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000134c:	715d                	addi	sp,sp,-80
    8000134e:	e486                	sd	ra,72(sp)
    80001350:	e0a2                	sd	s0,64(sp)
    80001352:	fc26                	sd	s1,56(sp)
    80001354:	f84a                	sd	s2,48(sp)
    80001356:	f44e                	sd	s3,40(sp)
    80001358:	f052                	sd	s4,32(sp)
    8000135a:	ec56                	sd	s5,24(sp)
    8000135c:	e85a                	sd	s6,16(sp)
    8000135e:	e45e                	sd	s7,8(sp)
    80001360:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if ((va % PGSIZE) != 0)
    80001362:	03459793          	slli	a5,a1,0x34
    80001366:	e795                	bnez	a5,80001392 <uvmunmap+0x46>
    80001368:	8a2a                	mv	s4,a0
    8000136a:	892e                	mv	s2,a1
    8000136c:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    8000136e:	0632                	slli	a2,a2,0xc
    80001370:	00b609b3          	add	s3,a2,a1
  {
    if ((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if ((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if (PTE_FLAGS(*pte) == PTE_V)
    80001374:	4b85                	li	s7,1
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    80001376:	6b05                	lui	s6,0x1
    80001378:	0735e263          	bltu	a1,s3,800013dc <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void *)pa);
    }
    *pte = 0;
  }
}
    8000137c:	60a6                	ld	ra,72(sp)
    8000137e:	6406                	ld	s0,64(sp)
    80001380:	74e2                	ld	s1,56(sp)
    80001382:	7942                	ld	s2,48(sp)
    80001384:	79a2                	ld	s3,40(sp)
    80001386:	7a02                	ld	s4,32(sp)
    80001388:	6ae2                	ld	s5,24(sp)
    8000138a:	6b42                	ld	s6,16(sp)
    8000138c:	6ba2                	ld	s7,8(sp)
    8000138e:	6161                	addi	sp,sp,80
    80001390:	8082                	ret
    panic("uvmunmap: not aligned");
    80001392:	00007517          	auipc	a0,0x7
    80001396:	db650513          	addi	a0,a0,-586 # 80008148 <digits+0xf8>
    8000139a:	fffff097          	auipc	ra,0xfffff
    8000139e:	1a6080e7          	jalr	422(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800013a2:	00007517          	auipc	a0,0x7
    800013a6:	dbe50513          	addi	a0,a0,-578 # 80008160 <digits+0x110>
    800013aa:	fffff097          	auipc	ra,0xfffff
    800013ae:	196080e7          	jalr	406(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	dbe50513          	addi	a0,a0,-578 # 80008170 <digits+0x120>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	186080e7          	jalr	390(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800013c2:	00007517          	auipc	a0,0x7
    800013c6:	dc650513          	addi	a0,a0,-570 # 80008188 <digits+0x138>
    800013ca:	fffff097          	auipc	ra,0xfffff
    800013ce:	176080e7          	jalr	374(ra) # 80000540 <panic>
    *pte = 0;
    800013d2:	0004b023          	sd	zero,0(s1)
  for (a = va; a < va + npages * PGSIZE; a += PGSIZE)
    800013d6:	995a                	add	s2,s2,s6
    800013d8:	fb3972e3          	bgeu	s2,s3,8000137c <uvmunmap+0x30>
    if ((pte = walk(pagetable, a, 0)) == 0)
    800013dc:	4601                	li	a2,0
    800013de:	85ca                	mv	a1,s2
    800013e0:	8552                	mv	a0,s4
    800013e2:	00000097          	auipc	ra,0x0
    800013e6:	c9c080e7          	jalr	-868(ra) # 8000107e <walk>
    800013ea:	84aa                	mv	s1,a0
    800013ec:	d95d                	beqz	a0,800013a2 <uvmunmap+0x56>
    if ((*pte & PTE_V) == 0)
    800013ee:	6108                	ld	a0,0(a0)
    800013f0:	00157793          	andi	a5,a0,1
    800013f4:	dfdd                	beqz	a5,800013b2 <uvmunmap+0x66>
    if (PTE_FLAGS(*pte) == PTE_V)
    800013f6:	3ff57793          	andi	a5,a0,1023
    800013fa:	fd7784e3          	beq	a5,s7,800013c2 <uvmunmap+0x76>
    if (do_free)
    800013fe:	fc0a8ae3          	beqz	s5,800013d2 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001402:	8129                	srli	a0,a0,0xa
      kfree((void *)pa);
    80001404:	0532                	slli	a0,a0,0xc
    80001406:	fffff097          	auipc	ra,0xfffff
    8000140a:	5f4080e7          	jalr	1524(ra) # 800009fa <kfree>
    8000140e:	b7d1                	j	800013d2 <uvmunmap+0x86>

0000000080001410 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001410:	1101                	addi	sp,sp,-32
    80001412:	ec06                	sd	ra,24(sp)
    80001414:	e822                	sd	s0,16(sp)
    80001416:	e426                	sd	s1,8(sp)
    80001418:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t)kalloc();
    8000141a:	fffff097          	auipc	ra,0xfffff
    8000141e:	748080e7          	jalr	1864(ra) # 80000b62 <kalloc>
    80001422:	84aa                	mv	s1,a0
  if (pagetable == 0)
    80001424:	c519                	beqz	a0,80001432 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001426:	6605                	lui	a2,0x1
    80001428:	4581                	li	a1,0
    8000142a:	00000097          	auipc	ra,0x0
    8000142e:	970080e7          	jalr	-1680(ra) # 80000d9a <memset>
  return pagetable;
}
    80001432:	8526                	mv	a0,s1
    80001434:	60e2                	ld	ra,24(sp)
    80001436:	6442                	ld	s0,16(sp)
    80001438:	64a2                	ld	s1,8(sp)
    8000143a:	6105                	addi	sp,sp,32
    8000143c:	8082                	ret

000000008000143e <uvmfirst>:

// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000143e:	7179                	addi	sp,sp,-48
    80001440:	f406                	sd	ra,40(sp)
    80001442:	f022                	sd	s0,32(sp)
    80001444:	ec26                	sd	s1,24(sp)
    80001446:	e84a                	sd	s2,16(sp)
    80001448:	e44e                	sd	s3,8(sp)
    8000144a:	e052                	sd	s4,0(sp)
    8000144c:	1800                	addi	s0,sp,48
  char *mem;

  if (sz >= PGSIZE)
    8000144e:	6785                	lui	a5,0x1
    80001450:	04f67863          	bgeu	a2,a5,800014a0 <uvmfirst+0x62>
    80001454:	8a2a                	mv	s4,a0
    80001456:	89ae                	mv	s3,a1
    80001458:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000145a:	fffff097          	auipc	ra,0xfffff
    8000145e:	708080e7          	jalr	1800(ra) # 80000b62 <kalloc>
    80001462:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001464:	6605                	lui	a2,0x1
    80001466:	4581                	li	a1,0
    80001468:	00000097          	auipc	ra,0x0
    8000146c:	932080e7          	jalr	-1742(ra) # 80000d9a <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W | PTE_R | PTE_X | PTE_U);
    80001470:	4779                	li	a4,30
    80001472:	86ca                	mv	a3,s2
    80001474:	6605                	lui	a2,0x1
    80001476:	4581                	li	a1,0
    80001478:	8552                	mv	a0,s4
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	d0c080e7          	jalr	-756(ra) # 80001186 <mappages>
  memmove(mem, src, sz);
    80001482:	8626                	mv	a2,s1
    80001484:	85ce                	mv	a1,s3
    80001486:	854a                	mv	a0,s2
    80001488:	00000097          	auipc	ra,0x0
    8000148c:	96e080e7          	jalr	-1682(ra) # 80000df6 <memmove>
}
    80001490:	70a2                	ld	ra,40(sp)
    80001492:	7402                	ld	s0,32(sp)
    80001494:	64e2                	ld	s1,24(sp)
    80001496:	6942                	ld	s2,16(sp)
    80001498:	69a2                	ld	s3,8(sp)
    8000149a:	6a02                	ld	s4,0(sp)
    8000149c:	6145                	addi	sp,sp,48
    8000149e:	8082                	ret
    panic("uvmfirst: more than a page");
    800014a0:	00007517          	auipc	a0,0x7
    800014a4:	d0050513          	addi	a0,a0,-768 # 800081a0 <digits+0x150>
    800014a8:	fffff097          	auipc	ra,0xfffff
    800014ac:	098080e7          	jalr	152(ra) # 80000540 <panic>

00000000800014b0 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800014b0:	1101                	addi	sp,sp,-32
    800014b2:	ec06                	sd	ra,24(sp)
    800014b4:	e822                	sd	s0,16(sp)
    800014b6:	e426                	sd	s1,8(sp)
    800014b8:	1000                	addi	s0,sp,32
  if (newsz >= oldsz)
    return oldsz;
    800014ba:	84ae                	mv	s1,a1
  if (newsz >= oldsz)
    800014bc:	00b67d63          	bgeu	a2,a1,800014d6 <uvmdealloc+0x26>
    800014c0:	84b2                	mv	s1,a2

  if (PGROUNDUP(newsz) < PGROUNDUP(oldsz))
    800014c2:	6785                	lui	a5,0x1
    800014c4:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800014c6:	00f60733          	add	a4,a2,a5
    800014ca:	76fd                	lui	a3,0xfffff
    800014cc:	8f75                	and	a4,a4,a3
    800014ce:	97ae                	add	a5,a5,a1
    800014d0:	8ff5                	and	a5,a5,a3
    800014d2:	00f76863          	bltu	a4,a5,800014e2 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800014d6:	8526                	mv	a0,s1
    800014d8:	60e2                	ld	ra,24(sp)
    800014da:	6442                	ld	s0,16(sp)
    800014dc:	64a2                	ld	s1,8(sp)
    800014de:	6105                	addi	sp,sp,32
    800014e0:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800014e2:	8f99                	sub	a5,a5,a4
    800014e4:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800014e6:	4685                	li	a3,1
    800014e8:	0007861b          	sext.w	a2,a5
    800014ec:	85ba                	mv	a1,a4
    800014ee:	00000097          	auipc	ra,0x0
    800014f2:	e5e080e7          	jalr	-418(ra) # 8000134c <uvmunmap>
    800014f6:	b7c5                	j	800014d6 <uvmdealloc+0x26>

00000000800014f8 <uvmalloc>:
  if (newsz < oldsz)
    800014f8:	0ab66563          	bltu	a2,a1,800015a2 <uvmalloc+0xaa>
{
    800014fc:	7139                	addi	sp,sp,-64
    800014fe:	fc06                	sd	ra,56(sp)
    80001500:	f822                	sd	s0,48(sp)
    80001502:	f426                	sd	s1,40(sp)
    80001504:	f04a                	sd	s2,32(sp)
    80001506:	ec4e                	sd	s3,24(sp)
    80001508:	e852                	sd	s4,16(sp)
    8000150a:	e456                	sd	s5,8(sp)
    8000150c:	e05a                	sd	s6,0(sp)
    8000150e:	0080                	addi	s0,sp,64
    80001510:	8aaa                	mv	s5,a0
    80001512:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001514:	6785                	lui	a5,0x1
    80001516:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001518:	95be                	add	a1,a1,a5
    8000151a:	77fd                	lui	a5,0xfffff
    8000151c:	00f5f9b3          	and	s3,a1,a5
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001520:	08c9f363          	bgeu	s3,a2,800015a6 <uvmalloc+0xae>
    80001524:	894e                	mv	s2,s3
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80001526:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000152a:	fffff097          	auipc	ra,0xfffff
    8000152e:	638080e7          	jalr	1592(ra) # 80000b62 <kalloc>
    80001532:	84aa                	mv	s1,a0
    if (mem == 0)
    80001534:	c51d                	beqz	a0,80001562 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001536:	6605                	lui	a2,0x1
    80001538:	4581                	li	a1,0
    8000153a:	00000097          	auipc	ra,0x0
    8000153e:	860080e7          	jalr	-1952(ra) # 80000d9a <memset>
    if (mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R | PTE_U | xperm) != 0)
    80001542:	875a                	mv	a4,s6
    80001544:	86a6                	mv	a3,s1
    80001546:	6605                	lui	a2,0x1
    80001548:	85ca                	mv	a1,s2
    8000154a:	8556                	mv	a0,s5
    8000154c:	00000097          	auipc	ra,0x0
    80001550:	c3a080e7          	jalr	-966(ra) # 80001186 <mappages>
    80001554:	e90d                	bnez	a0,80001586 <uvmalloc+0x8e>
  for (a = oldsz; a < newsz; a += PGSIZE)
    80001556:	6785                	lui	a5,0x1
    80001558:	993e                	add	s2,s2,a5
    8000155a:	fd4968e3          	bltu	s2,s4,8000152a <uvmalloc+0x32>
  return newsz;
    8000155e:	8552                	mv	a0,s4
    80001560:	a809                	j	80001572 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001562:	864e                	mv	a2,s3
    80001564:	85ca                	mv	a1,s2
    80001566:	8556                	mv	a0,s5
    80001568:	00000097          	auipc	ra,0x0
    8000156c:	f48080e7          	jalr	-184(ra) # 800014b0 <uvmdealloc>
      return 0;
    80001570:	4501                	li	a0,0
}
    80001572:	70e2                	ld	ra,56(sp)
    80001574:	7442                	ld	s0,48(sp)
    80001576:	74a2                	ld	s1,40(sp)
    80001578:	7902                	ld	s2,32(sp)
    8000157a:	69e2                	ld	s3,24(sp)
    8000157c:	6a42                	ld	s4,16(sp)
    8000157e:	6aa2                	ld	s5,8(sp)
    80001580:	6b02                	ld	s6,0(sp)
    80001582:	6121                	addi	sp,sp,64
    80001584:	8082                	ret
      kfree(mem);
    80001586:	8526                	mv	a0,s1
    80001588:	fffff097          	auipc	ra,0xfffff
    8000158c:	472080e7          	jalr	1138(ra) # 800009fa <kfree>
      uvmdealloc(pagetable, a, oldsz);
    80001590:	864e                	mv	a2,s3
    80001592:	85ca                	mv	a1,s2
    80001594:	8556                	mv	a0,s5
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	f1a080e7          	jalr	-230(ra) # 800014b0 <uvmdealloc>
      return 0;
    8000159e:	4501                	li	a0,0
    800015a0:	bfc9                	j	80001572 <uvmalloc+0x7a>
    return oldsz;
    800015a2:	852e                	mv	a0,a1
}
    800015a4:	8082                	ret
  return newsz;
    800015a6:	8532                	mv	a0,a2
    800015a8:	b7e9                	j	80001572 <uvmalloc+0x7a>

00000000800015aa <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void freewalk(pagetable_t pagetable)
{
    800015aa:	7179                	addi	sp,sp,-48
    800015ac:	f406                	sd	ra,40(sp)
    800015ae:	f022                	sd	s0,32(sp)
    800015b0:	ec26                	sd	s1,24(sp)
    800015b2:	e84a                	sd	s2,16(sp)
    800015b4:	e44e                	sd	s3,8(sp)
    800015b6:	e052                	sd	s4,0(sp)
    800015b8:	1800                	addi	s0,sp,48
    800015ba:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for (int i = 0; i < 512; i++)
    800015bc:	84aa                	mv	s1,a0
    800015be:	6905                	lui	s2,0x1
    800015c0:	992a                	add	s2,s2,a0
  {
    pte_t pte = pagetable[i];
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800015c2:	4985                	li	s3,1
    800015c4:	a829                	j	800015de <freewalk+0x34>
    {
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800015c6:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800015c8:	00c79513          	slli	a0,a5,0xc
    800015cc:	00000097          	auipc	ra,0x0
    800015d0:	fde080e7          	jalr	-34(ra) # 800015aa <freewalk>
      pagetable[i] = 0;
    800015d4:	0004b023          	sd	zero,0(s1)
  for (int i = 0; i < 512; i++)
    800015d8:	04a1                	addi	s1,s1,8
    800015da:	03248163          	beq	s1,s2,800015fc <freewalk+0x52>
    pte_t pte = pagetable[i];
    800015de:	609c                	ld	a5,0(s1)
    if ((pte & PTE_V) && (pte & (PTE_R | PTE_W | PTE_X)) == 0)
    800015e0:	00f7f713          	andi	a4,a5,15
    800015e4:	ff3701e3          	beq	a4,s3,800015c6 <freewalk+0x1c>
    }
    else if (pte & PTE_V)
    800015e8:	8b85                	andi	a5,a5,1
    800015ea:	d7fd                	beqz	a5,800015d8 <freewalk+0x2e>
    {
      panic("freewalk: leaf");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bd450513          	addi	a0,a0,-1068 # 800081c0 <digits+0x170>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f4c080e7          	jalr	-180(ra) # 80000540 <panic>
    }
  }
  kfree((void *)pagetable);
    800015fc:	8552                	mv	a0,s4
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3fc080e7          	jalr	1020(ra) # 800009fa <kfree>
}
    80001606:	70a2                	ld	ra,40(sp)
    80001608:	7402                	ld	s0,32(sp)
    8000160a:	64e2                	ld	s1,24(sp)
    8000160c:	6942                	ld	s2,16(sp)
    8000160e:	69a2                	ld	s3,8(sp)
    80001610:	6a02                	ld	s4,0(sp)
    80001612:	6145                	addi	sp,sp,48
    80001614:	8082                	ret

0000000080001616 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001616:	1101                	addi	sp,sp,-32
    80001618:	ec06                	sd	ra,24(sp)
    8000161a:	e822                	sd	s0,16(sp)
    8000161c:	e426                	sd	s1,8(sp)
    8000161e:	1000                	addi	s0,sp,32
    80001620:	84aa                	mv	s1,a0
  if (sz > 0)
    80001622:	e999                	bnez	a1,80001638 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
  freewalk(pagetable);
    80001624:	8526                	mv	a0,s1
    80001626:	00000097          	auipc	ra,0x0
    8000162a:	f84080e7          	jalr	-124(ra) # 800015aa <freewalk>
}
    8000162e:	60e2                	ld	ra,24(sp)
    80001630:	6442                	ld	s0,16(sp)
    80001632:	64a2                	ld	s1,8(sp)
    80001634:	6105                	addi	sp,sp,32
    80001636:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz) / PGSIZE, 1);
    80001638:	6785                	lui	a5,0x1
    8000163a:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000163c:	95be                	add	a1,a1,a5
    8000163e:	4685                	li	a3,1
    80001640:	00c5d613          	srli	a2,a1,0xc
    80001644:	4581                	li	a1,0
    80001646:	00000097          	auipc	ra,0x0
    8000164a:	d06080e7          	jalr	-762(ra) # 8000134c <uvmunmap>
    8000164e:	bfd9                	j	80001624 <uvmfree+0xe>

0000000080001650 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for (i = 0; i < sz; i += PGSIZE)
    80001650:	c679                	beqz	a2,8000171e <uvmcopy+0xce>
{
    80001652:	715d                	addi	sp,sp,-80
    80001654:	e486                	sd	ra,72(sp)
    80001656:	e0a2                	sd	s0,64(sp)
    80001658:	fc26                	sd	s1,56(sp)
    8000165a:	f84a                	sd	s2,48(sp)
    8000165c:	f44e                	sd	s3,40(sp)
    8000165e:	f052                	sd	s4,32(sp)
    80001660:	ec56                	sd	s5,24(sp)
    80001662:	e85a                	sd	s6,16(sp)
    80001664:	e45e                	sd	s7,8(sp)
    80001666:	0880                	addi	s0,sp,80
    80001668:	8b2a                	mv	s6,a0
    8000166a:	8aae                	mv	s5,a1
    8000166c:	8a32                	mv	s4,a2
  for (i = 0; i < sz; i += PGSIZE)
    8000166e:	4981                	li	s3,0
  {
    if ((pte = walk(old, i, 0)) == 0)
    80001670:	4601                	li	a2,0
    80001672:	85ce                	mv	a1,s3
    80001674:	855a                	mv	a0,s6
    80001676:	00000097          	auipc	ra,0x0
    8000167a:	a08080e7          	jalr	-1528(ra) # 8000107e <walk>
    8000167e:	c531                	beqz	a0,800016ca <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if ((*pte & PTE_V) == 0)
    80001680:	6118                	ld	a4,0(a0)
    80001682:	00177793          	andi	a5,a4,1
    80001686:	cbb1                	beqz	a5,800016da <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001688:	00a75593          	srli	a1,a4,0xa
    8000168c:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    80001690:	3ff77493          	andi	s1,a4,1023
    if ((mem = kalloc()) == 0)
    80001694:	fffff097          	auipc	ra,0xfffff
    80001698:	4ce080e7          	jalr	1230(ra) # 80000b62 <kalloc>
    8000169c:	892a                	mv	s2,a0
    8000169e:	c939                	beqz	a0,800016f4 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char *)pa, PGSIZE);
    800016a0:	6605                	lui	a2,0x1
    800016a2:	85de                	mv	a1,s7
    800016a4:	fffff097          	auipc	ra,0xfffff
    800016a8:	752080e7          	jalr	1874(ra) # 80000df6 <memmove>
    if (mappages(new, i, PGSIZE, (uint64)mem, flags) != 0)
    800016ac:	8726                	mv	a4,s1
    800016ae:	86ca                	mv	a3,s2
    800016b0:	6605                	lui	a2,0x1
    800016b2:	85ce                	mv	a1,s3
    800016b4:	8556                	mv	a0,s5
    800016b6:	00000097          	auipc	ra,0x0
    800016ba:	ad0080e7          	jalr	-1328(ra) # 80001186 <mappages>
    800016be:	e515                	bnez	a0,800016ea <uvmcopy+0x9a>
  for (i = 0; i < sz; i += PGSIZE)
    800016c0:	6785                	lui	a5,0x1
    800016c2:	99be                	add	s3,s3,a5
    800016c4:	fb49e6e3          	bltu	s3,s4,80001670 <uvmcopy+0x20>
    800016c8:	a081                	j	80001708 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800016ca:	00007517          	auipc	a0,0x7
    800016ce:	b0650513          	addi	a0,a0,-1274 # 800081d0 <digits+0x180>
    800016d2:	fffff097          	auipc	ra,0xfffff
    800016d6:	e6e080e7          	jalr	-402(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800016da:	00007517          	auipc	a0,0x7
    800016de:	b1650513          	addi	a0,a0,-1258 # 800081f0 <digits+0x1a0>
    800016e2:	fffff097          	auipc	ra,0xfffff
    800016e6:	e5e080e7          	jalr	-418(ra) # 80000540 <panic>
    {
      kfree(mem);
    800016ea:	854a                	mv	a0,s2
    800016ec:	fffff097          	auipc	ra,0xfffff
    800016f0:	30e080e7          	jalr	782(ra) # 800009fa <kfree>
    }
  }
  return 0;

err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800016f4:	4685                	li	a3,1
    800016f6:	00c9d613          	srli	a2,s3,0xc
    800016fa:	4581                	li	a1,0
    800016fc:	8556                	mv	a0,s5
    800016fe:	00000097          	auipc	ra,0x0
    80001702:	c4e080e7          	jalr	-946(ra) # 8000134c <uvmunmap>
  return -1;
    80001706:	557d                	li	a0,-1
}
    80001708:	60a6                	ld	ra,72(sp)
    8000170a:	6406                	ld	s0,64(sp)
    8000170c:	74e2                	ld	s1,56(sp)
    8000170e:	7942                	ld	s2,48(sp)
    80001710:	79a2                	ld	s3,40(sp)
    80001712:	7a02                	ld	s4,32(sp)
    80001714:	6ae2                	ld	s5,24(sp)
    80001716:	6b42                	ld	s6,16(sp)
    80001718:	6ba2                	ld	s7,8(sp)
    8000171a:	6161                	addi	sp,sp,80
    8000171c:	8082                	ret
  return 0;
    8000171e:	4501                	li	a0,0
}
    80001720:	8082                	ret

0000000080001722 <uvmshare>:
int uvmshare(pagetable_t old, pagetable_t new, uint64 sz)
{
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  for (i = 0; i < sz; i += PGSIZE)
    80001722:	ce49                	beqz	a2,800017bc <uvmshare+0x9a>
{
    80001724:	7179                	addi	sp,sp,-48
    80001726:	f406                	sd	ra,40(sp)
    80001728:	f022                	sd	s0,32(sp)
    8000172a:	ec26                	sd	s1,24(sp)
    8000172c:	e84a                	sd	s2,16(sp)
    8000172e:	e44e                	sd	s3,8(sp)
    80001730:	e052                	sd	s4,0(sp)
    80001732:	1800                	addi	s0,sp,48
    80001734:	8a2a                	mv	s4,a0
    80001736:	89ae                	mv	s3,a1
    80001738:	8932                	mv	s2,a2
  for (i = 0; i < sz; i += PGSIZE)
    8000173a:	4481                	li	s1,0
  {
    if ((pte = walk(old, i, 0)) == 0)
    8000173c:	4601                	li	a2,0
    8000173e:	85a6                	mv	a1,s1
    80001740:	8552                	mv	a0,s4
    80001742:	00000097          	auipc	ra,0x0
    80001746:	93c080e7          	jalr	-1732(ra) # 8000107e <walk>
    8000174a:	c51d                	beqz	a0,80001778 <uvmshare+0x56>
      panic("uvmshare: pte should exist");
    if ((*pte & PTE_V) == 0)
    8000174c:	6118                	ld	a4,0(a0)
    8000174e:	00177793          	andi	a5,a4,1
    80001752:	cb9d                	beqz	a5,80001788 <uvmshare+0x66>
      panic("uvmshare: page not present");
    pa = PTE2PA(*pte);
    80001754:	00a75693          	srli	a3,a4,0xa
    flags = PTE_FLAGS(*pte);
    // Make the page read-only for the child process
    flags &= ~PTE_W; // Remove write permission
    if (mappages(new, i, PGSIZE, pa, flags) != 0)
    80001758:	3fb77713          	andi	a4,a4,1019
    8000175c:	06b2                	slli	a3,a3,0xc
    8000175e:	6605                	lui	a2,0x1
    80001760:	85a6                	mv	a1,s1
    80001762:	854e                	mv	a0,s3
    80001764:	00000097          	auipc	ra,0x0
    80001768:	a22080e7          	jalr	-1502(ra) # 80001186 <mappages>
    8000176c:	e515                	bnez	a0,80001798 <uvmshare+0x76>
  for (i = 0; i < sz; i += PGSIZE)
    8000176e:	6785                	lui	a5,0x1
    80001770:	94be                	add	s1,s1,a5
    80001772:	fd24e5e3          	bltu	s1,s2,8000173c <uvmshare+0x1a>
    80001776:	a81d                	j	800017ac <uvmshare+0x8a>
      panic("uvmshare: pte should exist");
    80001778:	00007517          	auipc	a0,0x7
    8000177c:	a9850513          	addi	a0,a0,-1384 # 80008210 <digits+0x1c0>
    80001780:	fffff097          	auipc	ra,0xfffff
    80001784:	dc0080e7          	jalr	-576(ra) # 80000540 <panic>
      panic("uvmshare: page not present");
    80001788:	00007517          	auipc	a0,0x7
    8000178c:	aa850513          	addi	a0,a0,-1368 # 80008230 <digits+0x1e0>
    80001790:	fffff097          	auipc	ra,0xfffff
    80001794:	db0080e7          	jalr	-592(ra) # 80000540 <panic>
      goto err;
    }
  }
  return 0;
err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001798:	4685                	li	a3,1
    8000179a:	00c4d613          	srli	a2,s1,0xc
    8000179e:	4581                	li	a1,0
    800017a0:	854e                	mv	a0,s3
    800017a2:	00000097          	auipc	ra,0x0
    800017a6:	baa080e7          	jalr	-1110(ra) # 8000134c <uvmunmap>
  return -1;
    800017aa:	557d                	li	a0,-1
}
    800017ac:	70a2                	ld	ra,40(sp)
    800017ae:	7402                	ld	s0,32(sp)
    800017b0:	64e2                	ld	s1,24(sp)
    800017b2:	6942                	ld	s2,16(sp)
    800017b4:	69a2                	ld	s3,8(sp)
    800017b6:	6a02                	ld	s4,0(sp)
    800017b8:	6145                	addi	sp,sp,48
    800017ba:	8082                	ret
  return 0;
    800017bc:	4501                	li	a0,0
}
    800017be:	8082                	ret

00000000800017c0 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void uvmclear(pagetable_t pagetable, uint64 va)
{
    800017c0:	1141                	addi	sp,sp,-16
    800017c2:	e406                	sd	ra,8(sp)
    800017c4:	e022                	sd	s0,0(sp)
    800017c6:	0800                	addi	s0,sp,16
  pte_t *pte;

  pte = walk(pagetable, va, 0);
    800017c8:	4601                	li	a2,0
    800017ca:	00000097          	auipc	ra,0x0
    800017ce:	8b4080e7          	jalr	-1868(ra) # 8000107e <walk>
  if (pte == 0)
    800017d2:	c901                	beqz	a0,800017e2 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    800017d4:	611c                	ld	a5,0(a0)
    800017d6:	9bbd                	andi	a5,a5,-17
    800017d8:	e11c                	sd	a5,0(a0)
}
    800017da:	60a2                	ld	ra,8(sp)
    800017dc:	6402                	ld	s0,0(sp)
    800017de:	0141                	addi	sp,sp,16
    800017e0:	8082                	ret
    panic("uvmclear");
    800017e2:	00007517          	auipc	a0,0x7
    800017e6:	a6e50513          	addi	a0,a0,-1426 # 80008250 <digits+0x200>
    800017ea:	fffff097          	auipc	ra,0xfffff
    800017ee:	d56080e7          	jalr	-682(ra) # 80000540 <panic>

00000000800017f2 <copyout>:
// Return 0 on success, -1 on error.
int copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    800017f2:	c6bd                	beqz	a3,80001860 <copyout+0x6e>
{
    800017f4:	715d                	addi	sp,sp,-80
    800017f6:	e486                	sd	ra,72(sp)
    800017f8:	e0a2                	sd	s0,64(sp)
    800017fa:	fc26                	sd	s1,56(sp)
    800017fc:	f84a                	sd	s2,48(sp)
    800017fe:	f44e                	sd	s3,40(sp)
    80001800:	f052                	sd	s4,32(sp)
    80001802:	ec56                	sd	s5,24(sp)
    80001804:	e85a                	sd	s6,16(sp)
    80001806:	e45e                	sd	s7,8(sp)
    80001808:	e062                	sd	s8,0(sp)
    8000180a:	0880                	addi	s0,sp,80
    8000180c:	8b2a                	mv	s6,a0
    8000180e:	8c2e                	mv	s8,a1
    80001810:	8a32                	mv	s4,a2
    80001812:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(dstva);
    80001814:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001816:	6a85                	lui	s5,0x1
    80001818:	a015                	j	8000183c <copyout+0x4a>
    if (n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000181a:	9562                	add	a0,a0,s8
    8000181c:	0004861b          	sext.w	a2,s1
    80001820:	85d2                	mv	a1,s4
    80001822:	41250533          	sub	a0,a0,s2
    80001826:	fffff097          	auipc	ra,0xfffff
    8000182a:	5d0080e7          	jalr	1488(ra) # 80000df6 <memmove>

    len -= n;
    8000182e:	409989b3          	sub	s3,s3,s1
    src += n;
    80001832:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    80001834:	01590c33          	add	s8,s2,s5
  while (len > 0)
    80001838:	02098263          	beqz	s3,8000185c <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    8000183c:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001840:	85ca                	mv	a1,s2
    80001842:	855a                	mv	a0,s6
    80001844:	00000097          	auipc	ra,0x0
    80001848:	8e0080e7          	jalr	-1824(ra) # 80001124 <walkaddr>
    if (pa0 == 0)
    8000184c:	cd01                	beqz	a0,80001864 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    8000184e:	418904b3          	sub	s1,s2,s8
    80001852:	94d6                	add	s1,s1,s5
    80001854:	fc99f3e3          	bgeu	s3,s1,8000181a <copyout+0x28>
    80001858:	84ce                	mv	s1,s3
    8000185a:	b7c1                	j	8000181a <copyout+0x28>
  }
  return 0;
    8000185c:	4501                	li	a0,0
    8000185e:	a021                	j	80001866 <copyout+0x74>
    80001860:	4501                	li	a0,0
}
    80001862:	8082                	ret
      return -1;
    80001864:	557d                	li	a0,-1
}
    80001866:	60a6                	ld	ra,72(sp)
    80001868:	6406                	ld	s0,64(sp)
    8000186a:	74e2                	ld	s1,56(sp)
    8000186c:	7942                	ld	s2,48(sp)
    8000186e:	79a2                	ld	s3,40(sp)
    80001870:	7a02                	ld	s4,32(sp)
    80001872:	6ae2                	ld	s5,24(sp)
    80001874:	6b42                	ld	s6,16(sp)
    80001876:	6ba2                	ld	s7,8(sp)
    80001878:	6c02                	ld	s8,0(sp)
    8000187a:	6161                	addi	sp,sp,80
    8000187c:	8082                	ret

000000008000187e <copyin>:
// Return 0 on success, -1 on error.
int copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while (len > 0)
    8000187e:	caa5                	beqz	a3,800018ee <copyin+0x70>
{
    80001880:	715d                	addi	sp,sp,-80
    80001882:	e486                	sd	ra,72(sp)
    80001884:	e0a2                	sd	s0,64(sp)
    80001886:	fc26                	sd	s1,56(sp)
    80001888:	f84a                	sd	s2,48(sp)
    8000188a:	f44e                	sd	s3,40(sp)
    8000188c:	f052                	sd	s4,32(sp)
    8000188e:	ec56                	sd	s5,24(sp)
    80001890:	e85a                	sd	s6,16(sp)
    80001892:	e45e                	sd	s7,8(sp)
    80001894:	e062                	sd	s8,0(sp)
    80001896:	0880                	addi	s0,sp,80
    80001898:	8b2a                	mv	s6,a0
    8000189a:	8a2e                	mv	s4,a1
    8000189c:	8c32                	mv	s8,a2
    8000189e:	89b6                	mv	s3,a3
  {
    va0 = PGROUNDDOWN(srcva);
    800018a0:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800018a2:	6a85                	lui	s5,0x1
    800018a4:	a01d                	j	800018ca <copyin+0x4c>
    if (n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    800018a6:	018505b3          	add	a1,a0,s8
    800018aa:	0004861b          	sext.w	a2,s1
    800018ae:	412585b3          	sub	a1,a1,s2
    800018b2:	8552                	mv	a0,s4
    800018b4:	fffff097          	auipc	ra,0xfffff
    800018b8:	542080e7          	jalr	1346(ra) # 80000df6 <memmove>

    len -= n;
    800018bc:	409989b3          	sub	s3,s3,s1
    dst += n;
    800018c0:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    800018c2:	01590c33          	add	s8,s2,s5
  while (len > 0)
    800018c6:	02098263          	beqz	s3,800018ea <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    800018ca:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800018ce:	85ca                	mv	a1,s2
    800018d0:	855a                	mv	a0,s6
    800018d2:	00000097          	auipc	ra,0x0
    800018d6:	852080e7          	jalr	-1966(ra) # 80001124 <walkaddr>
    if (pa0 == 0)
    800018da:	cd01                	beqz	a0,800018f2 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    800018dc:	418904b3          	sub	s1,s2,s8
    800018e0:	94d6                	add	s1,s1,s5
    800018e2:	fc99f2e3          	bgeu	s3,s1,800018a6 <copyin+0x28>
    800018e6:	84ce                	mv	s1,s3
    800018e8:	bf7d                	j	800018a6 <copyin+0x28>
  }
  return 0;
    800018ea:	4501                	li	a0,0
    800018ec:	a021                	j	800018f4 <copyin+0x76>
    800018ee:	4501                	li	a0,0
}
    800018f0:	8082                	ret
      return -1;
    800018f2:	557d                	li	a0,-1
}
    800018f4:	60a6                	ld	ra,72(sp)
    800018f6:	6406                	ld	s0,64(sp)
    800018f8:	74e2                	ld	s1,56(sp)
    800018fa:	7942                	ld	s2,48(sp)
    800018fc:	79a2                	ld	s3,40(sp)
    800018fe:	7a02                	ld	s4,32(sp)
    80001900:	6ae2                	ld	s5,24(sp)
    80001902:	6b42                	ld	s6,16(sp)
    80001904:	6ba2                	ld	s7,8(sp)
    80001906:	6c02                	ld	s8,0(sp)
    80001908:	6161                	addi	sp,sp,80
    8000190a:	8082                	ret

000000008000190c <copyinstr>:
int copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while (got_null == 0 && max > 0)
    8000190c:	c2dd                	beqz	a3,800019b2 <copyinstr+0xa6>
{
    8000190e:	715d                	addi	sp,sp,-80
    80001910:	e486                	sd	ra,72(sp)
    80001912:	e0a2                	sd	s0,64(sp)
    80001914:	fc26                	sd	s1,56(sp)
    80001916:	f84a                	sd	s2,48(sp)
    80001918:	f44e                	sd	s3,40(sp)
    8000191a:	f052                	sd	s4,32(sp)
    8000191c:	ec56                	sd	s5,24(sp)
    8000191e:	e85a                	sd	s6,16(sp)
    80001920:	e45e                	sd	s7,8(sp)
    80001922:	0880                	addi	s0,sp,80
    80001924:	8a2a                	mv	s4,a0
    80001926:	8b2e                	mv	s6,a1
    80001928:	8bb2                	mv	s7,a2
    8000192a:	84b6                	mv	s1,a3
  {
    va0 = PGROUNDDOWN(srcva);
    8000192c:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000192e:	6985                	lui	s3,0x1
    80001930:	a02d                	j	8000195a <copyinstr+0x4e>
    char *p = (char *)(pa0 + (srcva - va0));
    while (n > 0)
    {
      if (*p == '\0')
      {
        *dst = '\0';
    80001932:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    80001936:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if (got_null)
    80001938:	37fd                	addiw	a5,a5,-1
    8000193a:	0007851b          	sext.w	a0,a5
  }
  else
  {
    return -1;
  }
}
    8000193e:	60a6                	ld	ra,72(sp)
    80001940:	6406                	ld	s0,64(sp)
    80001942:	74e2                	ld	s1,56(sp)
    80001944:	7942                	ld	s2,48(sp)
    80001946:	79a2                	ld	s3,40(sp)
    80001948:	7a02                	ld	s4,32(sp)
    8000194a:	6ae2                	ld	s5,24(sp)
    8000194c:	6b42                	ld	s6,16(sp)
    8000194e:	6ba2                	ld	s7,8(sp)
    80001950:	6161                	addi	sp,sp,80
    80001952:	8082                	ret
    srcva = va0 + PGSIZE;
    80001954:	01390bb3          	add	s7,s2,s3
  while (got_null == 0 && max > 0)
    80001958:	c8a9                	beqz	s1,800019aa <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000195a:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000195e:	85ca                	mv	a1,s2
    80001960:	8552                	mv	a0,s4
    80001962:	fffff097          	auipc	ra,0xfffff
    80001966:	7c2080e7          	jalr	1986(ra) # 80001124 <walkaddr>
    if (pa0 == 0)
    8000196a:	c131                	beqz	a0,800019ae <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000196c:	417906b3          	sub	a3,s2,s7
    80001970:	96ce                	add	a3,a3,s3
    80001972:	00d4f363          	bgeu	s1,a3,80001978 <copyinstr+0x6c>
    80001976:	86a6                	mv	a3,s1
    char *p = (char *)(pa0 + (srcva - va0));
    80001978:	955e                	add	a0,a0,s7
    8000197a:	41250533          	sub	a0,a0,s2
    while (n > 0)
    8000197e:	daf9                	beqz	a3,80001954 <copyinstr+0x48>
    80001980:	87da                	mv	a5,s6
      if (*p == '\0')
    80001982:	41650633          	sub	a2,a0,s6
    80001986:	fff48593          	addi	a1,s1,-1
    8000198a:	95da                	add	a1,a1,s6
    while (n > 0)
    8000198c:	96da                	add	a3,a3,s6
      if (*p == '\0')
    8000198e:	00f60733          	add	a4,a2,a5
    80001992:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd0a0>
    80001996:	df51                	beqz	a4,80001932 <copyinstr+0x26>
        *dst = *p;
    80001998:	00e78023          	sb	a4,0(a5)
      --max;
    8000199c:	40f584b3          	sub	s1,a1,a5
      dst++;
    800019a0:	0785                	addi	a5,a5,1
    while (n > 0)
    800019a2:	fed796e3          	bne	a5,a3,8000198e <copyinstr+0x82>
      dst++;
    800019a6:	8b3e                	mv	s6,a5
    800019a8:	b775                	j	80001954 <copyinstr+0x48>
    800019aa:	4781                	li	a5,0
    800019ac:	b771                	j	80001938 <copyinstr+0x2c>
      return -1;
    800019ae:	557d                	li	a0,-1
    800019b0:	b779                	j	8000193e <copyinstr+0x32>
  int got_null = 0;
    800019b2:	4781                	li	a5,0
  if (got_null)
    800019b4:	37fd                	addiw	a5,a5,-1
    800019b6:	0007851b          	sext.w	a0,a5
}
    800019ba:	8082                	ret

00000000800019bc <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    800019bc:	715d                	addi	sp,sp,-80
    800019be:	e486                	sd	ra,72(sp)
    800019c0:	e0a2                	sd	s0,64(sp)
    800019c2:	fc26                	sd	s1,56(sp)
    800019c4:	f84a                	sd	s2,48(sp)
    800019c6:	f44e                	sd	s3,40(sp)
    800019c8:	f052                	sd	s4,32(sp)
    800019ca:	ec56                	sd	s5,24(sp)
    800019cc:	e85a                	sd	s6,16(sp)
    800019ce:	e45e                	sd	s7,8(sp)
    800019d0:	e062                	sd	s8,0(sp)
    800019d2:	0880                	addi	s0,sp,80
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d4:	8792                	mv	a5,tp
    int id = r_tp();
    800019d6:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    800019d8:	0000fa97          	auipc	s5,0xf
    800019dc:	378a8a93          	addi	s5,s5,888 # 80010d50 <cpus>
    800019e0:	00779713          	slli	a4,a5,0x7
    800019e4:	00ea86b3          	add	a3,s5,a4
    800019e8:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd0a0>
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    800019ec:	0721                	addi	a4,a4,8
    800019ee:	9aba                	add	s5,s5,a4
                c->proc = p;
    800019f0:	8936                	mv	s2,a3
                // check if we are still the right scheduler (or if schedset changed)
                if (sched_pointer != &rr_scheduler)
    800019f2:	00007c17          	auipc	s8,0x7
    800019f6:	016c0c13          	addi	s8,s8,22 # 80008a08 <sched_pointer>
    800019fa:	00000b97          	auipc	s7,0x0
    800019fe:	fc2b8b93          	addi	s7,s7,-62 # 800019bc <rr_scheduler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001a02:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001a06:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001a0a:	10079073          	csrw	sstatus,a5
        for (p = proc; p < &proc[NPROC]; p++)
    80001a0e:	0000f497          	auipc	s1,0xf
    80001a12:	77248493          	addi	s1,s1,1906 # 80011180 <proc>
            if (p->state == RUNNABLE)
    80001a16:	498d                	li	s3,3
                p->state = RUNNING;
    80001a18:	4b11                	li	s6,4
        for (p = proc; p < &proc[NPROC]; p++)
    80001a1a:	00015a17          	auipc	s4,0x15
    80001a1e:	166a0a13          	addi	s4,s4,358 # 80016b80 <tickslock>
    80001a22:	a81d                	j	80001a58 <rr_scheduler+0x9c>
                {
                    release(&p->lock);
    80001a24:	8526                	mv	a0,s1
    80001a26:	fffff097          	auipc	ra,0xfffff
    80001a2a:	32c080e7          	jalr	812(ra) # 80000d52 <release>
                c->proc = 0;
            }
            release(&p->lock);
        }
    }
}
    80001a2e:	60a6                	ld	ra,72(sp)
    80001a30:	6406                	ld	s0,64(sp)
    80001a32:	74e2                	ld	s1,56(sp)
    80001a34:	7942                	ld	s2,48(sp)
    80001a36:	79a2                	ld	s3,40(sp)
    80001a38:	7a02                	ld	s4,32(sp)
    80001a3a:	6ae2                	ld	s5,24(sp)
    80001a3c:	6b42                	ld	s6,16(sp)
    80001a3e:	6ba2                	ld	s7,8(sp)
    80001a40:	6c02                	ld	s8,0(sp)
    80001a42:	6161                	addi	sp,sp,80
    80001a44:	8082                	ret
            release(&p->lock);
    80001a46:	8526                	mv	a0,s1
    80001a48:	fffff097          	auipc	ra,0xfffff
    80001a4c:	30a080e7          	jalr	778(ra) # 80000d52 <release>
        for (p = proc; p < &proc[NPROC]; p++)
    80001a50:	16848493          	addi	s1,s1,360
    80001a54:	fb4487e3          	beq	s1,s4,80001a02 <rr_scheduler+0x46>
            acquire(&p->lock);
    80001a58:	8526                	mv	a0,s1
    80001a5a:	fffff097          	auipc	ra,0xfffff
    80001a5e:	244080e7          	jalr	580(ra) # 80000c9e <acquire>
            if (p->state == RUNNABLE)
    80001a62:	4c9c                	lw	a5,24(s1)
    80001a64:	ff3791e3          	bne	a5,s3,80001a46 <rr_scheduler+0x8a>
                p->state = RUNNING;
    80001a68:	0164ac23          	sw	s6,24(s1)
                c->proc = p;
    80001a6c:	00993023          	sd	s1,0(s2) # 1000 <_entry-0x7ffff000>
                swtch(&c->context, &p->context);
    80001a70:	06048593          	addi	a1,s1,96
    80001a74:	8556                	mv	a0,s5
    80001a76:	00001097          	auipc	ra,0x1
    80001a7a:	170080e7          	jalr	368(ra) # 80002be6 <swtch>
                if (sched_pointer != &rr_scheduler)
    80001a7e:	000c3783          	ld	a5,0(s8)
    80001a82:	fb7791e3          	bne	a5,s7,80001a24 <rr_scheduler+0x68>
                c->proc = 0;
    80001a86:	00093023          	sd	zero,0(s2)
    80001a8a:	bf75                	j	80001a46 <rr_scheduler+0x8a>

0000000080001a8c <proc_mapstacks>:
{
    80001a8c:	7139                	addi	sp,sp,-64
    80001a8e:	fc06                	sd	ra,56(sp)
    80001a90:	f822                	sd	s0,48(sp)
    80001a92:	f426                	sd	s1,40(sp)
    80001a94:	f04a                	sd	s2,32(sp)
    80001a96:	ec4e                	sd	s3,24(sp)
    80001a98:	e852                	sd	s4,16(sp)
    80001a9a:	e456                	sd	s5,8(sp)
    80001a9c:	e05a                	sd	s6,0(sp)
    80001a9e:	0080                	addi	s0,sp,64
    80001aa0:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001aa2:	0000f497          	auipc	s1,0xf
    80001aa6:	6de48493          	addi	s1,s1,1758 # 80011180 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001aaa:	8b26                	mv	s6,s1
    80001aac:	00006a97          	auipc	s5,0x6
    80001ab0:	564a8a93          	addi	s5,s5,1380 # 80008010 <__func__.1+0x8>
    80001ab4:	04000937          	lui	s2,0x4000
    80001ab8:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001aba:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001abc:	00015a17          	auipc	s4,0x15
    80001ac0:	0c4a0a13          	addi	s4,s4,196 # 80016b80 <tickslock>
        char *pa = kalloc();
    80001ac4:	fffff097          	auipc	ra,0xfffff
    80001ac8:	09e080e7          	jalr	158(ra) # 80000b62 <kalloc>
    80001acc:	862a                	mv	a2,a0
        if (pa == 0)
    80001ace:	c131                	beqz	a0,80001b12 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001ad0:	416485b3          	sub	a1,s1,s6
    80001ad4:	858d                	srai	a1,a1,0x3
    80001ad6:	000ab783          	ld	a5,0(s5)
    80001ada:	02f585b3          	mul	a1,a1,a5
    80001ade:	2585                	addiw	a1,a1,1
    80001ae0:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001ae4:	4719                	li	a4,6
    80001ae6:	6685                	lui	a3,0x1
    80001ae8:	40b905b3          	sub	a1,s2,a1
    80001aec:	854e                	mv	a0,s3
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	738080e7          	jalr	1848(ra) # 80001226 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001af6:	16848493          	addi	s1,s1,360
    80001afa:	fd4495e3          	bne	s1,s4,80001ac4 <proc_mapstacks+0x38>
}
    80001afe:	70e2                	ld	ra,56(sp)
    80001b00:	7442                	ld	s0,48(sp)
    80001b02:	74a2                	ld	s1,40(sp)
    80001b04:	7902                	ld	s2,32(sp)
    80001b06:	69e2                	ld	s3,24(sp)
    80001b08:	6a42                	ld	s4,16(sp)
    80001b0a:	6aa2                	ld	s5,8(sp)
    80001b0c:	6b02                	ld	s6,0(sp)
    80001b0e:	6121                	addi	sp,sp,64
    80001b10:	8082                	ret
            panic("kalloc");
    80001b12:	00006517          	auipc	a0,0x6
    80001b16:	74e50513          	addi	a0,a0,1870 # 80008260 <digits+0x210>
    80001b1a:	fffff097          	auipc	ra,0xfffff
    80001b1e:	a26080e7          	jalr	-1498(ra) # 80000540 <panic>

0000000080001b22 <procinit>:
{
    80001b22:	7139                	addi	sp,sp,-64
    80001b24:	fc06                	sd	ra,56(sp)
    80001b26:	f822                	sd	s0,48(sp)
    80001b28:	f426                	sd	s1,40(sp)
    80001b2a:	f04a                	sd	s2,32(sp)
    80001b2c:	ec4e                	sd	s3,24(sp)
    80001b2e:	e852                	sd	s4,16(sp)
    80001b30:	e456                	sd	s5,8(sp)
    80001b32:	e05a                	sd	s6,0(sp)
    80001b34:	0080                	addi	s0,sp,64
    initlock(&pid_lock, "nextpid");
    80001b36:	00006597          	auipc	a1,0x6
    80001b3a:	73258593          	addi	a1,a1,1842 # 80008268 <digits+0x218>
    80001b3e:	0000f517          	auipc	a0,0xf
    80001b42:	61250513          	addi	a0,a0,1554 # 80011150 <pid_lock>
    80001b46:	fffff097          	auipc	ra,0xfffff
    80001b4a:	0c8080e7          	jalr	200(ra) # 80000c0e <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b4e:	00006597          	auipc	a1,0x6
    80001b52:	72258593          	addi	a1,a1,1826 # 80008270 <digits+0x220>
    80001b56:	0000f517          	auipc	a0,0xf
    80001b5a:	61250513          	addi	a0,a0,1554 # 80011168 <wait_lock>
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	0b0080e7          	jalr	176(ra) # 80000c0e <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b66:	0000f497          	auipc	s1,0xf
    80001b6a:	61a48493          	addi	s1,s1,1562 # 80011180 <proc>
        initlock(&p->lock, "proc");
    80001b6e:	00006b17          	auipc	s6,0x6
    80001b72:	712b0b13          	addi	s6,s6,1810 # 80008280 <digits+0x230>
        p->kstack = KSTACK((int)(p - proc));
    80001b76:	8aa6                	mv	s5,s1
    80001b78:	00006a17          	auipc	s4,0x6
    80001b7c:	498a0a13          	addi	s4,s4,1176 # 80008010 <__func__.1+0x8>
    80001b80:	04000937          	lui	s2,0x4000
    80001b84:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001b86:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001b88:	00015997          	auipc	s3,0x15
    80001b8c:	ff898993          	addi	s3,s3,-8 # 80016b80 <tickslock>
        initlock(&p->lock, "proc");
    80001b90:	85da                	mv	a1,s6
    80001b92:	8526                	mv	a0,s1
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	07a080e7          	jalr	122(ra) # 80000c0e <initlock>
        p->state = UNUSED;
    80001b9c:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001ba0:	415487b3          	sub	a5,s1,s5
    80001ba4:	878d                	srai	a5,a5,0x3
    80001ba6:	000a3703          	ld	a4,0(s4)
    80001baa:	02e787b3          	mul	a5,a5,a4
    80001bae:	2785                	addiw	a5,a5,1
    80001bb0:	00d7979b          	slliw	a5,a5,0xd
    80001bb4:	40f907b3          	sub	a5,s2,a5
    80001bb8:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001bba:	16848493          	addi	s1,s1,360
    80001bbe:	fd3499e3          	bne	s1,s3,80001b90 <procinit+0x6e>
}
    80001bc2:	70e2                	ld	ra,56(sp)
    80001bc4:	7442                	ld	s0,48(sp)
    80001bc6:	74a2                	ld	s1,40(sp)
    80001bc8:	7902                	ld	s2,32(sp)
    80001bca:	69e2                	ld	s3,24(sp)
    80001bcc:	6a42                	ld	s4,16(sp)
    80001bce:	6aa2                	ld	s5,8(sp)
    80001bd0:	6b02                	ld	s6,0(sp)
    80001bd2:	6121                	addi	sp,sp,64
    80001bd4:	8082                	ret

0000000080001bd6 <copy_array>:
{
    80001bd6:	1141                	addi	sp,sp,-16
    80001bd8:	e422                	sd	s0,8(sp)
    80001bda:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001bdc:	02c05163          	blez	a2,80001bfe <copy_array+0x28>
    80001be0:	87aa                	mv	a5,a0
    80001be2:	0505                	addi	a0,a0,1
    80001be4:	367d                	addiw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001be6:	1602                	slli	a2,a2,0x20
    80001be8:	9201                	srli	a2,a2,0x20
    80001bea:	00c506b3          	add	a3,a0,a2
        dst[i] = src[i];
    80001bee:	0007c703          	lbu	a4,0(a5)
    80001bf2:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001bf6:	0785                	addi	a5,a5,1
    80001bf8:	0585                	addi	a1,a1,1
    80001bfa:	fed79ae3          	bne	a5,a3,80001bee <copy_array+0x18>
}
    80001bfe:	6422                	ld	s0,8(sp)
    80001c00:	0141                	addi	sp,sp,16
    80001c02:	8082                	ret

0000000080001c04 <cpuid>:
{
    80001c04:	1141                	addi	sp,sp,-16
    80001c06:	e422                	sd	s0,8(sp)
    80001c08:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c0a:	8512                	mv	a0,tp
}
    80001c0c:	2501                	sext.w	a0,a0
    80001c0e:	6422                	ld	s0,8(sp)
    80001c10:	0141                	addi	sp,sp,16
    80001c12:	8082                	ret

0000000080001c14 <mycpu>:
{
    80001c14:	1141                	addi	sp,sp,-16
    80001c16:	e422                	sd	s0,8(sp)
    80001c18:	0800                	addi	s0,sp,16
    80001c1a:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c1c:	2781                	sext.w	a5,a5
    80001c1e:	079e                	slli	a5,a5,0x7
}
    80001c20:	0000f517          	auipc	a0,0xf
    80001c24:	13050513          	addi	a0,a0,304 # 80010d50 <cpus>
    80001c28:	953e                	add	a0,a0,a5
    80001c2a:	6422                	ld	s0,8(sp)
    80001c2c:	0141                	addi	sp,sp,16
    80001c2e:	8082                	ret

0000000080001c30 <myproc>:
{
    80001c30:	1101                	addi	sp,sp,-32
    80001c32:	ec06                	sd	ra,24(sp)
    80001c34:	e822                	sd	s0,16(sp)
    80001c36:	e426                	sd	s1,8(sp)
    80001c38:	1000                	addi	s0,sp,32
    push_off();
    80001c3a:	fffff097          	auipc	ra,0xfffff
    80001c3e:	018080e7          	jalr	24(ra) # 80000c52 <push_off>
    80001c42:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c44:	2781                	sext.w	a5,a5
    80001c46:	079e                	slli	a5,a5,0x7
    80001c48:	0000f717          	auipc	a4,0xf
    80001c4c:	10870713          	addi	a4,a4,264 # 80010d50 <cpus>
    80001c50:	97ba                	add	a5,a5,a4
    80001c52:	6384                	ld	s1,0(a5)
    pop_off();
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	09e080e7          	jalr	158(ra) # 80000cf2 <pop_off>
}
    80001c5c:	8526                	mv	a0,s1
    80001c5e:	60e2                	ld	ra,24(sp)
    80001c60:	6442                	ld	s0,16(sp)
    80001c62:	64a2                	ld	s1,8(sp)
    80001c64:	6105                	addi	sp,sp,32
    80001c66:	8082                	ret

0000000080001c68 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c68:	1141                	addi	sp,sp,-16
    80001c6a:	e406                	sd	ra,8(sp)
    80001c6c:	e022                	sd	s0,0(sp)
    80001c6e:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c70:	00000097          	auipc	ra,0x0
    80001c74:	fc0080e7          	jalr	-64(ra) # 80001c30 <myproc>
    80001c78:	fffff097          	auipc	ra,0xfffff
    80001c7c:	0da080e7          	jalr	218(ra) # 80000d52 <release>

    if (first)
    80001c80:	00007797          	auipc	a5,0x7
    80001c84:	d807a783          	lw	a5,-640(a5) # 80008a00 <first.1>
    80001c88:	eb89                	bnez	a5,80001c9a <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001c8a:	00001097          	auipc	ra,0x1
    80001c8e:	0c6080e7          	jalr	198(ra) # 80002d50 <usertrapret>
}
    80001c92:	60a2                	ld	ra,8(sp)
    80001c94:	6402                	ld	s0,0(sp)
    80001c96:	0141                	addi	sp,sp,16
    80001c98:	8082                	ret
        first = 0;
    80001c9a:	00007797          	auipc	a5,0x7
    80001c9e:	d607a323          	sw	zero,-666(a5) # 80008a00 <first.1>
        fsinit(ROOTDEV);
    80001ca2:	4505                	li	a0,1
    80001ca4:	00002097          	auipc	ra,0x2
    80001ca8:	f10080e7          	jalr	-240(ra) # 80003bb4 <fsinit>
    80001cac:	bff9                	j	80001c8a <forkret+0x22>

0000000080001cae <allocpid>:
{
    80001cae:	1101                	addi	sp,sp,-32
    80001cb0:	ec06                	sd	ra,24(sp)
    80001cb2:	e822                	sd	s0,16(sp)
    80001cb4:	e426                	sd	s1,8(sp)
    80001cb6:	e04a                	sd	s2,0(sp)
    80001cb8:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001cba:	0000f917          	auipc	s2,0xf
    80001cbe:	49690913          	addi	s2,s2,1174 # 80011150 <pid_lock>
    80001cc2:	854a                	mv	a0,s2
    80001cc4:	fffff097          	auipc	ra,0xfffff
    80001cc8:	fda080e7          	jalr	-38(ra) # 80000c9e <acquire>
    pid = nextpid;
    80001ccc:	00007797          	auipc	a5,0x7
    80001cd0:	d4478793          	addi	a5,a5,-700 # 80008a10 <nextpid>
    80001cd4:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001cd6:	0014871b          	addiw	a4,s1,1
    80001cda:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001cdc:	854a                	mv	a0,s2
    80001cde:	fffff097          	auipc	ra,0xfffff
    80001ce2:	074080e7          	jalr	116(ra) # 80000d52 <release>
}
    80001ce6:	8526                	mv	a0,s1
    80001ce8:	60e2                	ld	ra,24(sp)
    80001cea:	6442                	ld	s0,16(sp)
    80001cec:	64a2                	ld	s1,8(sp)
    80001cee:	6902                	ld	s2,0(sp)
    80001cf0:	6105                	addi	sp,sp,32
    80001cf2:	8082                	ret

0000000080001cf4 <proc_pagetable>:
{
    80001cf4:	1101                	addi	sp,sp,-32
    80001cf6:	ec06                	sd	ra,24(sp)
    80001cf8:	e822                	sd	s0,16(sp)
    80001cfa:	e426                	sd	s1,8(sp)
    80001cfc:	e04a                	sd	s2,0(sp)
    80001cfe:	1000                	addi	s0,sp,32
    80001d00:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d02:	fffff097          	auipc	ra,0xfffff
    80001d06:	70e080e7          	jalr	1806(ra) # 80001410 <uvmcreate>
    80001d0a:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d0c:	c121                	beqz	a0,80001d4c <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d0e:	4729                	li	a4,10
    80001d10:	00005697          	auipc	a3,0x5
    80001d14:	2f068693          	addi	a3,a3,752 # 80007000 <_trampoline>
    80001d18:	6605                	lui	a2,0x1
    80001d1a:	040005b7          	lui	a1,0x4000
    80001d1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d20:	05b2                	slli	a1,a1,0xc
    80001d22:	fffff097          	auipc	ra,0xfffff
    80001d26:	464080e7          	jalr	1124(ra) # 80001186 <mappages>
    80001d2a:	02054863          	bltz	a0,80001d5a <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d2e:	4719                	li	a4,6
    80001d30:	05893683          	ld	a3,88(s2)
    80001d34:	6605                	lui	a2,0x1
    80001d36:	020005b7          	lui	a1,0x2000
    80001d3a:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d3c:	05b6                	slli	a1,a1,0xd
    80001d3e:	8526                	mv	a0,s1
    80001d40:	fffff097          	auipc	ra,0xfffff
    80001d44:	446080e7          	jalr	1094(ra) # 80001186 <mappages>
    80001d48:	02054163          	bltz	a0,80001d6a <proc_pagetable+0x76>
}
    80001d4c:	8526                	mv	a0,s1
    80001d4e:	60e2                	ld	ra,24(sp)
    80001d50:	6442                	ld	s0,16(sp)
    80001d52:	64a2                	ld	s1,8(sp)
    80001d54:	6902                	ld	s2,0(sp)
    80001d56:	6105                	addi	sp,sp,32
    80001d58:	8082                	ret
        uvmfree(pagetable, 0);
    80001d5a:	4581                	li	a1,0
    80001d5c:	8526                	mv	a0,s1
    80001d5e:	00000097          	auipc	ra,0x0
    80001d62:	8b8080e7          	jalr	-1864(ra) # 80001616 <uvmfree>
        return 0;
    80001d66:	4481                	li	s1,0
    80001d68:	b7d5                	j	80001d4c <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d6a:	4681                	li	a3,0
    80001d6c:	4605                	li	a2,1
    80001d6e:	040005b7          	lui	a1,0x4000
    80001d72:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d74:	05b2                	slli	a1,a1,0xc
    80001d76:	8526                	mv	a0,s1
    80001d78:	fffff097          	auipc	ra,0xfffff
    80001d7c:	5d4080e7          	jalr	1492(ra) # 8000134c <uvmunmap>
        uvmfree(pagetable, 0);
    80001d80:	4581                	li	a1,0
    80001d82:	8526                	mv	a0,s1
    80001d84:	00000097          	auipc	ra,0x0
    80001d88:	892080e7          	jalr	-1902(ra) # 80001616 <uvmfree>
        return 0;
    80001d8c:	4481                	li	s1,0
    80001d8e:	bf7d                	j	80001d4c <proc_pagetable+0x58>

0000000080001d90 <proc_freepagetable>:
{
    80001d90:	1101                	addi	sp,sp,-32
    80001d92:	ec06                	sd	ra,24(sp)
    80001d94:	e822                	sd	s0,16(sp)
    80001d96:	e426                	sd	s1,8(sp)
    80001d98:	e04a                	sd	s2,0(sp)
    80001d9a:	1000                	addi	s0,sp,32
    80001d9c:	84aa                	mv	s1,a0
    80001d9e:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001da0:	4681                	li	a3,0
    80001da2:	4605                	li	a2,1
    80001da4:	040005b7          	lui	a1,0x4000
    80001da8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001daa:	05b2                	slli	a1,a1,0xc
    80001dac:	fffff097          	auipc	ra,0xfffff
    80001db0:	5a0080e7          	jalr	1440(ra) # 8000134c <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001db4:	4681                	li	a3,0
    80001db6:	4605                	li	a2,1
    80001db8:	020005b7          	lui	a1,0x2000
    80001dbc:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001dbe:	05b6                	slli	a1,a1,0xd
    80001dc0:	8526                	mv	a0,s1
    80001dc2:	fffff097          	auipc	ra,0xfffff
    80001dc6:	58a080e7          	jalr	1418(ra) # 8000134c <uvmunmap>
    uvmfree(pagetable, sz);
    80001dca:	85ca                	mv	a1,s2
    80001dcc:	8526                	mv	a0,s1
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	848080e7          	jalr	-1976(ra) # 80001616 <uvmfree>
}
    80001dd6:	60e2                	ld	ra,24(sp)
    80001dd8:	6442                	ld	s0,16(sp)
    80001dda:	64a2                	ld	s1,8(sp)
    80001ddc:	6902                	ld	s2,0(sp)
    80001dde:	6105                	addi	sp,sp,32
    80001de0:	8082                	ret

0000000080001de2 <freeproc>:
{
    80001de2:	1101                	addi	sp,sp,-32
    80001de4:	ec06                	sd	ra,24(sp)
    80001de6:	e822                	sd	s0,16(sp)
    80001de8:	e426                	sd	s1,8(sp)
    80001dea:	1000                	addi	s0,sp,32
    80001dec:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001dee:	6d28                	ld	a0,88(a0)
    80001df0:	c509                	beqz	a0,80001dfa <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001df2:	fffff097          	auipc	ra,0xfffff
    80001df6:	c08080e7          	jalr	-1016(ra) # 800009fa <kfree>
    p->trapframe = 0;
    80001dfa:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001dfe:	68a8                	ld	a0,80(s1)
    80001e00:	c511                	beqz	a0,80001e0c <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e02:	64ac                	ld	a1,72(s1)
    80001e04:	00000097          	auipc	ra,0x0
    80001e08:	f8c080e7          	jalr	-116(ra) # 80001d90 <proc_freepagetable>
    p->pagetable = 0;
    80001e0c:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001e10:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001e14:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e18:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001e1c:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001e20:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e24:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001e28:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e2c:	0004ac23          	sw	zero,24(s1)
}
    80001e30:	60e2                	ld	ra,24(sp)
    80001e32:	6442                	ld	s0,16(sp)
    80001e34:	64a2                	ld	s1,8(sp)
    80001e36:	6105                	addi	sp,sp,32
    80001e38:	8082                	ret

0000000080001e3a <allocproc>:
{
    80001e3a:	1101                	addi	sp,sp,-32
    80001e3c:	ec06                	sd	ra,24(sp)
    80001e3e:	e822                	sd	s0,16(sp)
    80001e40:	e426                	sd	s1,8(sp)
    80001e42:	e04a                	sd	s2,0(sp)
    80001e44:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e46:	0000f497          	auipc	s1,0xf
    80001e4a:	33a48493          	addi	s1,s1,826 # 80011180 <proc>
    80001e4e:	00015917          	auipc	s2,0x15
    80001e52:	d3290913          	addi	s2,s2,-718 # 80016b80 <tickslock>
        acquire(&p->lock);
    80001e56:	8526                	mv	a0,s1
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	e46080e7          	jalr	-442(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    80001e60:	4c9c                	lw	a5,24(s1)
    80001e62:	cf81                	beqz	a5,80001e7a <allocproc+0x40>
            release(&p->lock);
    80001e64:	8526                	mv	a0,s1
    80001e66:	fffff097          	auipc	ra,0xfffff
    80001e6a:	eec080e7          	jalr	-276(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e6e:	16848493          	addi	s1,s1,360
    80001e72:	ff2492e3          	bne	s1,s2,80001e56 <allocproc+0x1c>
    return 0;
    80001e76:	4481                	li	s1,0
    80001e78:	a889                	j	80001eca <allocproc+0x90>
    p->pid = allocpid();
    80001e7a:	00000097          	auipc	ra,0x0
    80001e7e:	e34080e7          	jalr	-460(ra) # 80001cae <allocpid>
    80001e82:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001e84:	4785                	li	a5,1
    80001e86:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001e88:	fffff097          	auipc	ra,0xfffff
    80001e8c:	cda080e7          	jalr	-806(ra) # 80000b62 <kalloc>
    80001e90:	892a                	mv	s2,a0
    80001e92:	eca8                	sd	a0,88(s1)
    80001e94:	c131                	beqz	a0,80001ed8 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001e96:	8526                	mv	a0,s1
    80001e98:	00000097          	auipc	ra,0x0
    80001e9c:	e5c080e7          	jalr	-420(ra) # 80001cf4 <proc_pagetable>
    80001ea0:	892a                	mv	s2,a0
    80001ea2:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001ea4:	c531                	beqz	a0,80001ef0 <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001ea6:	07000613          	li	a2,112
    80001eaa:	4581                	li	a1,0
    80001eac:	06048513          	addi	a0,s1,96
    80001eb0:	fffff097          	auipc	ra,0xfffff
    80001eb4:	eea080e7          	jalr	-278(ra) # 80000d9a <memset>
    p->context.ra = (uint64)forkret;
    80001eb8:	00000797          	auipc	a5,0x0
    80001ebc:	db078793          	addi	a5,a5,-592 # 80001c68 <forkret>
    80001ec0:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001ec2:	60bc                	ld	a5,64(s1)
    80001ec4:	6705                	lui	a4,0x1
    80001ec6:	97ba                	add	a5,a5,a4
    80001ec8:	f4bc                	sd	a5,104(s1)
}
    80001eca:	8526                	mv	a0,s1
    80001ecc:	60e2                	ld	ra,24(sp)
    80001ece:	6442                	ld	s0,16(sp)
    80001ed0:	64a2                	ld	s1,8(sp)
    80001ed2:	6902                	ld	s2,0(sp)
    80001ed4:	6105                	addi	sp,sp,32
    80001ed6:	8082                	ret
        freeproc(p);
    80001ed8:	8526                	mv	a0,s1
    80001eda:	00000097          	auipc	ra,0x0
    80001ede:	f08080e7          	jalr	-248(ra) # 80001de2 <freeproc>
        release(&p->lock);
    80001ee2:	8526                	mv	a0,s1
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	e6e080e7          	jalr	-402(ra) # 80000d52 <release>
        return 0;
    80001eec:	84ca                	mv	s1,s2
    80001eee:	bff1                	j	80001eca <allocproc+0x90>
        freeproc(p);
    80001ef0:	8526                	mv	a0,s1
    80001ef2:	00000097          	auipc	ra,0x0
    80001ef6:	ef0080e7          	jalr	-272(ra) # 80001de2 <freeproc>
        release(&p->lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	e56080e7          	jalr	-426(ra) # 80000d52 <release>
        return 0;
    80001f04:	84ca                	mv	s1,s2
    80001f06:	b7d1                	j	80001eca <allocproc+0x90>

0000000080001f08 <userinit>:
{
    80001f08:	1101                	addi	sp,sp,-32
    80001f0a:	ec06                	sd	ra,24(sp)
    80001f0c:	e822                	sd	s0,16(sp)
    80001f0e:	e426                	sd	s1,8(sp)
    80001f10:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f12:	00000097          	auipc	ra,0x0
    80001f16:	f28080e7          	jalr	-216(ra) # 80001e3a <allocproc>
    80001f1a:	84aa                	mv	s1,a0
    initproc = p;
    80001f1c:	00007797          	auipc	a5,0x7
    80001f20:	baa7be23          	sd	a0,-1092(a5) # 80008ad8 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f24:	03400613          	li	a2,52
    80001f28:	00007597          	auipc	a1,0x7
    80001f2c:	af858593          	addi	a1,a1,-1288 # 80008a20 <initcode>
    80001f30:	6928                	ld	a0,80(a0)
    80001f32:	fffff097          	auipc	ra,0xfffff
    80001f36:	50c080e7          	jalr	1292(ra) # 8000143e <uvmfirst>
    p->sz = PGSIZE;
    80001f3a:	6785                	lui	a5,0x1
    80001f3c:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f3e:	6cb8                	ld	a4,88(s1)
    80001f40:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f44:	6cb8                	ld	a4,88(s1)
    80001f46:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f48:	4641                	li	a2,16
    80001f4a:	00006597          	auipc	a1,0x6
    80001f4e:	33e58593          	addi	a1,a1,830 # 80008288 <digits+0x238>
    80001f52:	15848513          	addi	a0,s1,344
    80001f56:	fffff097          	auipc	ra,0xfffff
    80001f5a:	f8e080e7          	jalr	-114(ra) # 80000ee4 <safestrcpy>
    p->cwd = namei("/");
    80001f5e:	00006517          	auipc	a0,0x6
    80001f62:	33a50513          	addi	a0,a0,826 # 80008298 <digits+0x248>
    80001f66:	00002097          	auipc	ra,0x2
    80001f6a:	678080e7          	jalr	1656(ra) # 800045de <namei>
    80001f6e:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001f72:	478d                	li	a5,3
    80001f74:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	dda080e7          	jalr	-550(ra) # 80000d52 <release>
}
    80001f80:	60e2                	ld	ra,24(sp)
    80001f82:	6442                	ld	s0,16(sp)
    80001f84:	64a2                	ld	s1,8(sp)
    80001f86:	6105                	addi	sp,sp,32
    80001f88:	8082                	ret

0000000080001f8a <growproc>:
{
    80001f8a:	1101                	addi	sp,sp,-32
    80001f8c:	ec06                	sd	ra,24(sp)
    80001f8e:	e822                	sd	s0,16(sp)
    80001f90:	e426                	sd	s1,8(sp)
    80001f92:	e04a                	sd	s2,0(sp)
    80001f94:	1000                	addi	s0,sp,32
    80001f96:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001f98:	00000097          	auipc	ra,0x0
    80001f9c:	c98080e7          	jalr	-872(ra) # 80001c30 <myproc>
    80001fa0:	84aa                	mv	s1,a0
    sz = p->sz;
    80001fa2:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001fa4:	01204c63          	bgtz	s2,80001fbc <growproc+0x32>
    else if (n < 0)
    80001fa8:	02094663          	bltz	s2,80001fd4 <growproc+0x4a>
    p->sz = sz;
    80001fac:	e4ac                	sd	a1,72(s1)
    return 0;
    80001fae:	4501                	li	a0,0
}
    80001fb0:	60e2                	ld	ra,24(sp)
    80001fb2:	6442                	ld	s0,16(sp)
    80001fb4:	64a2                	ld	s1,8(sp)
    80001fb6:	6902                	ld	s2,0(sp)
    80001fb8:	6105                	addi	sp,sp,32
    80001fba:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fbc:	4691                	li	a3,4
    80001fbe:	00b90633          	add	a2,s2,a1
    80001fc2:	6928                	ld	a0,80(a0)
    80001fc4:	fffff097          	auipc	ra,0xfffff
    80001fc8:	534080e7          	jalr	1332(ra) # 800014f8 <uvmalloc>
    80001fcc:	85aa                	mv	a1,a0
    80001fce:	fd79                	bnez	a0,80001fac <growproc+0x22>
            return -1;
    80001fd0:	557d                	li	a0,-1
    80001fd2:	bff9                	j	80001fb0 <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001fd4:	00b90633          	add	a2,s2,a1
    80001fd8:	6928                	ld	a0,80(a0)
    80001fda:	fffff097          	auipc	ra,0xfffff
    80001fde:	4d6080e7          	jalr	1238(ra) # 800014b0 <uvmdealloc>
    80001fe2:	85aa                	mv	a1,a0
    80001fe4:	b7e1                	j	80001fac <growproc+0x22>

0000000080001fe6 <ps>:
{
    80001fe6:	715d                	addi	sp,sp,-80
    80001fe8:	e486                	sd	ra,72(sp)
    80001fea:	e0a2                	sd	s0,64(sp)
    80001fec:	fc26                	sd	s1,56(sp)
    80001fee:	f84a                	sd	s2,48(sp)
    80001ff0:	f44e                	sd	s3,40(sp)
    80001ff2:	f052                	sd	s4,32(sp)
    80001ff4:	ec56                	sd	s5,24(sp)
    80001ff6:	e85a                	sd	s6,16(sp)
    80001ff8:	e45e                	sd	s7,8(sp)
    80001ffa:	e062                	sd	s8,0(sp)
    80001ffc:	0880                	addi	s0,sp,80
    80001ffe:	84aa                	mv	s1,a0
    80002000:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    80002002:	00000097          	auipc	ra,0x0
    80002006:	c2e080e7          	jalr	-978(ra) # 80001c30 <myproc>
        return result;
    8000200a:	4901                	li	s2,0
    if (count == 0)
    8000200c:	0c0b8563          	beqz	s7,800020d6 <ps+0xf0>
    void *result = (void *)myproc()->sz;
    80002010:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    80002014:	003b951b          	slliw	a0,s7,0x3
    80002018:	0175053b          	addw	a0,a0,s7
    8000201c:	0025151b          	slliw	a0,a0,0x2
    80002020:	00000097          	auipc	ra,0x0
    80002024:	f6a080e7          	jalr	-150(ra) # 80001f8a <growproc>
    80002028:	12054f63          	bltz	a0,80002166 <ps+0x180>
    struct user_proc loc_result[count];
    8000202c:	003b9a13          	slli	s4,s7,0x3
    80002030:	9a5e                	add	s4,s4,s7
    80002032:	0a0a                	slli	s4,s4,0x2
    80002034:	00fa0793          	addi	a5,s4,15
    80002038:	8391                	srli	a5,a5,0x4
    8000203a:	0792                	slli	a5,a5,0x4
    8000203c:	40f10133          	sub	sp,sp,a5
    80002040:	8a8a                	mv	s5,sp
    struct proc *p = proc + start;
    80002042:	16800793          	li	a5,360
    80002046:	02f484b3          	mul	s1,s1,a5
    8000204a:	0000f797          	auipc	a5,0xf
    8000204e:	13678793          	addi	a5,a5,310 # 80011180 <proc>
    80002052:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    80002054:	00015797          	auipc	a5,0x15
    80002058:	b2c78793          	addi	a5,a5,-1236 # 80016b80 <tickslock>
        return result;
    8000205c:	4901                	li	s2,0
    if (p >= &proc[NPROC])
    8000205e:	06f4fc63          	bgeu	s1,a5,800020d6 <ps+0xf0>
    acquire(&wait_lock);
    80002062:	0000f517          	auipc	a0,0xf
    80002066:	10650513          	addi	a0,a0,262 # 80011168 <wait_lock>
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	c34080e7          	jalr	-972(ra) # 80000c9e <acquire>
        if (localCount == count)
    80002072:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    80002076:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002078:	00015c17          	auipc	s8,0x15
    8000207c:	b08c0c13          	addi	s8,s8,-1272 # 80016b80 <tickslock>
    80002080:	a851                	j	80002114 <ps+0x12e>
            loc_result[localCount].state = UNUSED;
    80002082:	00399793          	slli	a5,s3,0x3
    80002086:	97ce                	add	a5,a5,s3
    80002088:	078a                	slli	a5,a5,0x2
    8000208a:	97d6                	add	a5,a5,s5
    8000208c:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	cc0080e7          	jalr	-832(ra) # 80000d52 <release>
    release(&wait_lock);
    8000209a:	0000f517          	auipc	a0,0xf
    8000209e:	0ce50513          	addi	a0,a0,206 # 80011168 <wait_lock>
    800020a2:	fffff097          	auipc	ra,0xfffff
    800020a6:	cb0080e7          	jalr	-848(ra) # 80000d52 <release>
    if (localCount < count)
    800020aa:	0179f963          	bgeu	s3,s7,800020bc <ps+0xd6>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    800020ae:	00399793          	slli	a5,s3,0x3
    800020b2:	97ce                	add	a5,a5,s3
    800020b4:	078a                	slli	a5,a5,0x2
    800020b6:	97d6                	add	a5,a5,s5
    800020b8:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    800020bc:	895a                	mv	s2,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    800020be:	00000097          	auipc	ra,0x0
    800020c2:	b72080e7          	jalr	-1166(ra) # 80001c30 <myproc>
    800020c6:	86d2                	mv	a3,s4
    800020c8:	8656                	mv	a2,s5
    800020ca:	85da                	mv	a1,s6
    800020cc:	6928                	ld	a0,80(a0)
    800020ce:	fffff097          	auipc	ra,0xfffff
    800020d2:	724080e7          	jalr	1828(ra) # 800017f2 <copyout>
}
    800020d6:	854a                	mv	a0,s2
    800020d8:	fb040113          	addi	sp,s0,-80
    800020dc:	60a6                	ld	ra,72(sp)
    800020de:	6406                	ld	s0,64(sp)
    800020e0:	74e2                	ld	s1,56(sp)
    800020e2:	7942                	ld	s2,48(sp)
    800020e4:	79a2                	ld	s3,40(sp)
    800020e6:	7a02                	ld	s4,32(sp)
    800020e8:	6ae2                	ld	s5,24(sp)
    800020ea:	6b42                	ld	s6,16(sp)
    800020ec:	6ba2                	ld	s7,8(sp)
    800020ee:	6c02                	ld	s8,0(sp)
    800020f0:	6161                	addi	sp,sp,80
    800020f2:	8082                	ret
        release(&p->lock);
    800020f4:	8526                	mv	a0,s1
    800020f6:	fffff097          	auipc	ra,0xfffff
    800020fa:	c5c080e7          	jalr	-932(ra) # 80000d52 <release>
        localCount++;
    800020fe:	2985                	addiw	s3,s3,1
    80002100:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    80002104:	16848493          	addi	s1,s1,360
    80002108:	f984f9e3          	bgeu	s1,s8,8000209a <ps+0xb4>
        if (localCount == count)
    8000210c:	02490913          	addi	s2,s2,36
    80002110:	053b8d63          	beq	s7,s3,8000216a <ps+0x184>
        acquire(&p->lock);
    80002114:	8526                	mv	a0,s1
    80002116:	fffff097          	auipc	ra,0xfffff
    8000211a:	b88080e7          	jalr	-1144(ra) # 80000c9e <acquire>
        if (p->state == UNUSED)
    8000211e:	4c9c                	lw	a5,24(s1)
    80002120:	d3ad                	beqz	a5,80002082 <ps+0x9c>
        loc_result[localCount].state = p->state;
    80002122:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    80002126:	549c                	lw	a5,40(s1)
    80002128:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    8000212c:	54dc                	lw	a5,44(s1)
    8000212e:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    80002132:	589c                	lw	a5,48(s1)
    80002134:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002138:	4641                	li	a2,16
    8000213a:	85ca                	mv	a1,s2
    8000213c:	15848513          	addi	a0,s1,344
    80002140:	00000097          	auipc	ra,0x0
    80002144:	a96080e7          	jalr	-1386(ra) # 80001bd6 <copy_array>
        if (p->parent != 0) // init
    80002148:	7c88                	ld	a0,56(s1)
    8000214a:	d54d                	beqz	a0,800020f4 <ps+0x10e>
            acquire(&p->parent->lock);
    8000214c:	fffff097          	auipc	ra,0xfffff
    80002150:	b52080e7          	jalr	-1198(ra) # 80000c9e <acquire>
            loc_result[localCount].parent_id = p->parent->pid;
    80002154:	7c88                	ld	a0,56(s1)
    80002156:	591c                	lw	a5,48(a0)
    80002158:	fef92e23          	sw	a5,-4(s2)
            release(&p->parent->lock);
    8000215c:	fffff097          	auipc	ra,0xfffff
    80002160:	bf6080e7          	jalr	-1034(ra) # 80000d52 <release>
    80002164:	bf41                	j	800020f4 <ps+0x10e>
        return result;
    80002166:	4901                	li	s2,0
    80002168:	b7bd                	j	800020d6 <ps+0xf0>
    release(&wait_lock);
    8000216a:	0000f517          	auipc	a0,0xf
    8000216e:	ffe50513          	addi	a0,a0,-2 # 80011168 <wait_lock>
    80002172:	fffff097          	auipc	ra,0xfffff
    80002176:	be0080e7          	jalr	-1056(ra) # 80000d52 <release>
    if (localCount < count)
    8000217a:	b789                	j	800020bc <ps+0xd6>

000000008000217c <fork>:
{
    8000217c:	7139                	addi	sp,sp,-64
    8000217e:	fc06                	sd	ra,56(sp)
    80002180:	f822                	sd	s0,48(sp)
    80002182:	f426                	sd	s1,40(sp)
    80002184:	f04a                	sd	s2,32(sp)
    80002186:	ec4e                	sd	s3,24(sp)
    80002188:	e852                	sd	s4,16(sp)
    8000218a:	e456                	sd	s5,8(sp)
    8000218c:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    8000218e:	00000097          	auipc	ra,0x0
    80002192:	aa2080e7          	jalr	-1374(ra) # 80001c30 <myproc>
    80002196:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    80002198:	00000097          	auipc	ra,0x0
    8000219c:	ca2080e7          	jalr	-862(ra) # 80001e3a <allocproc>
    800021a0:	10050c63          	beqz	a0,800022b8 <fork+0x13c>
    800021a4:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    800021a6:	048ab603          	ld	a2,72(s5)
    800021aa:	692c                	ld	a1,80(a0)
    800021ac:	050ab503          	ld	a0,80(s5)
    800021b0:	fffff097          	auipc	ra,0xfffff
    800021b4:	4a0080e7          	jalr	1184(ra) # 80001650 <uvmcopy>
    800021b8:	04054863          	bltz	a0,80002208 <fork+0x8c>
    np->sz = p->sz;
    800021bc:	048ab783          	ld	a5,72(s5)
    800021c0:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800021c4:	058ab683          	ld	a3,88(s5)
    800021c8:	87b6                	mv	a5,a3
    800021ca:	058a3703          	ld	a4,88(s4)
    800021ce:	12068693          	addi	a3,a3,288
    800021d2:	0007b803          	ld	a6,0(a5)
    800021d6:	6788                	ld	a0,8(a5)
    800021d8:	6b8c                	ld	a1,16(a5)
    800021da:	6f90                	ld	a2,24(a5)
    800021dc:	01073023          	sd	a6,0(a4)
    800021e0:	e708                	sd	a0,8(a4)
    800021e2:	eb0c                	sd	a1,16(a4)
    800021e4:	ef10                	sd	a2,24(a4)
    800021e6:	02078793          	addi	a5,a5,32
    800021ea:	02070713          	addi	a4,a4,32
    800021ee:	fed792e3          	bne	a5,a3,800021d2 <fork+0x56>
    np->trapframe->a0 = 0;
    800021f2:	058a3783          	ld	a5,88(s4)
    800021f6:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800021fa:	0d0a8493          	addi	s1,s5,208
    800021fe:	0d0a0913          	addi	s2,s4,208
    80002202:	150a8993          	addi	s3,s5,336
    80002206:	a00d                	j	80002228 <fork+0xac>
        freeproc(np);
    80002208:	8552                	mv	a0,s4
    8000220a:	00000097          	auipc	ra,0x0
    8000220e:	bd8080e7          	jalr	-1064(ra) # 80001de2 <freeproc>
        release(&np->lock);
    80002212:	8552                	mv	a0,s4
    80002214:	fffff097          	auipc	ra,0xfffff
    80002218:	b3e080e7          	jalr	-1218(ra) # 80000d52 <release>
        return -1;
    8000221c:	597d                	li	s2,-1
    8000221e:	a059                	j	800022a4 <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    80002220:	04a1                	addi	s1,s1,8
    80002222:	0921                	addi	s2,s2,8
    80002224:	01348b63          	beq	s1,s3,8000223a <fork+0xbe>
        if (p->ofile[i])
    80002228:	6088                	ld	a0,0(s1)
    8000222a:	d97d                	beqz	a0,80002220 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    8000222c:	00003097          	auipc	ra,0x3
    80002230:	a48080e7          	jalr	-1464(ra) # 80004c74 <filedup>
    80002234:	00a93023          	sd	a0,0(s2)
    80002238:	b7e5                	j	80002220 <fork+0xa4>
    np->cwd = idup(p->cwd);
    8000223a:	150ab503          	ld	a0,336(s5)
    8000223e:	00002097          	auipc	ra,0x2
    80002242:	bb6080e7          	jalr	-1098(ra) # 80003df4 <idup>
    80002246:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    8000224a:	4641                	li	a2,16
    8000224c:	158a8593          	addi	a1,s5,344
    80002250:	158a0513          	addi	a0,s4,344
    80002254:	fffff097          	auipc	ra,0xfffff
    80002258:	c90080e7          	jalr	-880(ra) # 80000ee4 <safestrcpy>
    pid = np->pid;
    8000225c:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    80002260:	8552                	mv	a0,s4
    80002262:	fffff097          	auipc	ra,0xfffff
    80002266:	af0080e7          	jalr	-1296(ra) # 80000d52 <release>
    acquire(&wait_lock);
    8000226a:	0000f497          	auipc	s1,0xf
    8000226e:	efe48493          	addi	s1,s1,-258 # 80011168 <wait_lock>
    80002272:	8526                	mv	a0,s1
    80002274:	fffff097          	auipc	ra,0xfffff
    80002278:	a2a080e7          	jalr	-1494(ra) # 80000c9e <acquire>
    np->parent = p;
    8000227c:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002280:	8526                	mv	a0,s1
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	ad0080e7          	jalr	-1328(ra) # 80000d52 <release>
    acquire(&np->lock);
    8000228a:	8552                	mv	a0,s4
    8000228c:	fffff097          	auipc	ra,0xfffff
    80002290:	a12080e7          	jalr	-1518(ra) # 80000c9e <acquire>
    np->state = RUNNABLE;
    80002294:	478d                	li	a5,3
    80002296:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    8000229a:	8552                	mv	a0,s4
    8000229c:	fffff097          	auipc	ra,0xfffff
    800022a0:	ab6080e7          	jalr	-1354(ra) # 80000d52 <release>
}
    800022a4:	854a                	mv	a0,s2
    800022a6:	70e2                	ld	ra,56(sp)
    800022a8:	7442                	ld	s0,48(sp)
    800022aa:	74a2                	ld	s1,40(sp)
    800022ac:	7902                	ld	s2,32(sp)
    800022ae:	69e2                	ld	s3,24(sp)
    800022b0:	6a42                	ld	s4,16(sp)
    800022b2:	6aa2                	ld	s5,8(sp)
    800022b4:	6121                	addi	sp,sp,64
    800022b6:	8082                	ret
        return -1;
    800022b8:	597d                	li	s2,-1
    800022ba:	b7ed                	j	800022a4 <fork+0x128>

00000000800022bc <vfork>:
{
    800022bc:	7139                	addi	sp,sp,-64
    800022be:	fc06                	sd	ra,56(sp)
    800022c0:	f822                	sd	s0,48(sp)
    800022c2:	f426                	sd	s1,40(sp)
    800022c4:	f04a                	sd	s2,32(sp)
    800022c6:	ec4e                	sd	s3,24(sp)
    800022c8:	e852                	sd	s4,16(sp)
    800022ca:	e456                	sd	s5,8(sp)
    800022cc:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    800022ce:	00000097          	auipc	ra,0x0
    800022d2:	962080e7          	jalr	-1694(ra) # 80001c30 <myproc>
    800022d6:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    800022d8:	00000097          	auipc	ra,0x0
    800022dc:	b62080e7          	jalr	-1182(ra) # 80001e3a <allocproc>
    800022e0:	10050c63          	beqz	a0,800023f8 <vfork+0x13c>
    800022e4:	8a2a                	mv	s4,a0
    if (uvmshare(p->pagetable, np->pagetable, p->sz) < 0)
    800022e6:	048ab603          	ld	a2,72(s5)
    800022ea:	692c                	ld	a1,80(a0)
    800022ec:	050ab503          	ld	a0,80(s5)
    800022f0:	fffff097          	auipc	ra,0xfffff
    800022f4:	432080e7          	jalr	1074(ra) # 80001722 <uvmshare>
    800022f8:	04054863          	bltz	a0,80002348 <vfork+0x8c>
    np->sz = p->sz;
    800022fc:	048ab783          	ld	a5,72(s5)
    80002300:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    80002304:	058ab683          	ld	a3,88(s5)
    80002308:	87b6                	mv	a5,a3
    8000230a:	058a3703          	ld	a4,88(s4)
    8000230e:	12068693          	addi	a3,a3,288
    80002312:	0007b803          	ld	a6,0(a5)
    80002316:	6788                	ld	a0,8(a5)
    80002318:	6b8c                	ld	a1,16(a5)
    8000231a:	6f90                	ld	a2,24(a5)
    8000231c:	01073023          	sd	a6,0(a4)
    80002320:	e708                	sd	a0,8(a4)
    80002322:	eb0c                	sd	a1,16(a4)
    80002324:	ef10                	sd	a2,24(a4)
    80002326:	02078793          	addi	a5,a5,32
    8000232a:	02070713          	addi	a4,a4,32
    8000232e:	fed792e3          	bne	a5,a3,80002312 <vfork+0x56>
    np->trapframe->a0 = 0;
    80002332:	058a3783          	ld	a5,88(s4)
    80002336:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    8000233a:	0d0a8493          	addi	s1,s5,208
    8000233e:	0d0a0913          	addi	s2,s4,208
    80002342:	150a8993          	addi	s3,s5,336
    80002346:	a00d                	j	80002368 <vfork+0xac>
        freeproc(np);
    80002348:	8552                	mv	a0,s4
    8000234a:	00000097          	auipc	ra,0x0
    8000234e:	a98080e7          	jalr	-1384(ra) # 80001de2 <freeproc>
        release(&np->lock);
    80002352:	8552                	mv	a0,s4
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	9fe080e7          	jalr	-1538(ra) # 80000d52 <release>
        return -1;
    8000235c:	597d                	li	s2,-1
    8000235e:	a059                	j	800023e4 <vfork+0x128>
    for (i = 0; i < NOFILE; i++)
    80002360:	04a1                	addi	s1,s1,8
    80002362:	0921                	addi	s2,s2,8
    80002364:	01348b63          	beq	s1,s3,8000237a <vfork+0xbe>
        if (p->ofile[i])
    80002368:	6088                	ld	a0,0(s1)
    8000236a:	d97d                	beqz	a0,80002360 <vfork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    8000236c:	00003097          	auipc	ra,0x3
    80002370:	908080e7          	jalr	-1784(ra) # 80004c74 <filedup>
    80002374:	00a93023          	sd	a0,0(s2)
    80002378:	b7e5                	j	80002360 <vfork+0xa4>
    np->cwd = idup(p->cwd);
    8000237a:	150ab503          	ld	a0,336(s5)
    8000237e:	00002097          	auipc	ra,0x2
    80002382:	a76080e7          	jalr	-1418(ra) # 80003df4 <idup>
    80002386:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    8000238a:	4641                	li	a2,16
    8000238c:	158a8593          	addi	a1,s5,344
    80002390:	158a0513          	addi	a0,s4,344
    80002394:	fffff097          	auipc	ra,0xfffff
    80002398:	b50080e7          	jalr	-1200(ra) # 80000ee4 <safestrcpy>
    pid = np->pid;
    8000239c:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    800023a0:	8552                	mv	a0,s4
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	9b0080e7          	jalr	-1616(ra) # 80000d52 <release>
    acquire(&wait_lock);
    800023aa:	0000f497          	auipc	s1,0xf
    800023ae:	dbe48493          	addi	s1,s1,-578 # 80011168 <wait_lock>
    800023b2:	8526                	mv	a0,s1
    800023b4:	fffff097          	auipc	ra,0xfffff
    800023b8:	8ea080e7          	jalr	-1814(ra) # 80000c9e <acquire>
    np->parent = p;
    800023bc:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    800023c0:	8526                	mv	a0,s1
    800023c2:	fffff097          	auipc	ra,0xfffff
    800023c6:	990080e7          	jalr	-1648(ra) # 80000d52 <release>
    acquire(&np->lock);
    800023ca:	8552                	mv	a0,s4
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8d2080e7          	jalr	-1838(ra) # 80000c9e <acquire>
    np->state = RUNNABLE;
    800023d4:	478d                	li	a5,3
    800023d6:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    800023da:	8552                	mv	a0,s4
    800023dc:	fffff097          	auipc	ra,0xfffff
    800023e0:	976080e7          	jalr	-1674(ra) # 80000d52 <release>
}
    800023e4:	854a                	mv	a0,s2
    800023e6:	70e2                	ld	ra,56(sp)
    800023e8:	7442                	ld	s0,48(sp)
    800023ea:	74a2                	ld	s1,40(sp)
    800023ec:	7902                	ld	s2,32(sp)
    800023ee:	69e2                	ld	s3,24(sp)
    800023f0:	6a42                	ld	s4,16(sp)
    800023f2:	6aa2                	ld	s5,8(sp)
    800023f4:	6121                	addi	sp,sp,64
    800023f6:	8082                	ret
        return -1;
    800023f8:	597d                	li	s2,-1
    800023fa:	b7ed                	j	800023e4 <vfork+0x128>

00000000800023fc <scheduler>:
{
    800023fc:	1101                	addi	sp,sp,-32
    800023fe:	ec06                	sd	ra,24(sp)
    80002400:	e822                	sd	s0,16(sp)
    80002402:	e426                	sd	s1,8(sp)
    80002404:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    80002406:	00006497          	auipc	s1,0x6
    8000240a:	60248493          	addi	s1,s1,1538 # 80008a08 <sched_pointer>
    8000240e:	609c                	ld	a5,0(s1)
    80002410:	9782                	jalr	a5
    while (1)
    80002412:	bff5                	j	8000240e <scheduler+0x12>

0000000080002414 <sched>:
{
    80002414:	7179                	addi	sp,sp,-48
    80002416:	f406                	sd	ra,40(sp)
    80002418:	f022                	sd	s0,32(sp)
    8000241a:	ec26                	sd	s1,24(sp)
    8000241c:	e84a                	sd	s2,16(sp)
    8000241e:	e44e                	sd	s3,8(sp)
    80002420:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    80002422:	00000097          	auipc	ra,0x0
    80002426:	80e080e7          	jalr	-2034(ra) # 80001c30 <myproc>
    8000242a:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    8000242c:	ffffe097          	auipc	ra,0xffffe
    80002430:	7f8080e7          	jalr	2040(ra) # 80000c24 <holding>
    80002434:	c53d                	beqz	a0,800024a2 <sched+0x8e>
    80002436:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    80002438:	2781                	sext.w	a5,a5
    8000243a:	079e                	slli	a5,a5,0x7
    8000243c:	0000f717          	auipc	a4,0xf
    80002440:	91470713          	addi	a4,a4,-1772 # 80010d50 <cpus>
    80002444:	97ba                	add	a5,a5,a4
    80002446:	5fb8                	lw	a4,120(a5)
    80002448:	4785                	li	a5,1
    8000244a:	06f71463          	bne	a4,a5,800024b2 <sched+0x9e>
    if (p->state == RUNNING)
    8000244e:	4c98                	lw	a4,24(s1)
    80002450:	4791                	li	a5,4
    80002452:	06f70863          	beq	a4,a5,800024c2 <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002456:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000245a:	8b89                	andi	a5,a5,2
    if (intr_get())
    8000245c:	ebbd                	bnez	a5,800024d2 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000245e:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002460:	0000f917          	auipc	s2,0xf
    80002464:	8f090913          	addi	s2,s2,-1808 # 80010d50 <cpus>
    80002468:	2781                	sext.w	a5,a5
    8000246a:	079e                	slli	a5,a5,0x7
    8000246c:	97ca                	add	a5,a5,s2
    8000246e:	07c7a983          	lw	s3,124(a5)
    80002472:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    80002474:	2581                	sext.w	a1,a1
    80002476:	059e                	slli	a1,a1,0x7
    80002478:	05a1                	addi	a1,a1,8
    8000247a:	95ca                	add	a1,a1,s2
    8000247c:	06048513          	addi	a0,s1,96
    80002480:	00000097          	auipc	ra,0x0
    80002484:	766080e7          	jalr	1894(ra) # 80002be6 <swtch>
    80002488:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    8000248a:	2781                	sext.w	a5,a5
    8000248c:	079e                	slli	a5,a5,0x7
    8000248e:	993e                	add	s2,s2,a5
    80002490:	07392e23          	sw	s3,124(s2)
}
    80002494:	70a2                	ld	ra,40(sp)
    80002496:	7402                	ld	s0,32(sp)
    80002498:	64e2                	ld	s1,24(sp)
    8000249a:	6942                	ld	s2,16(sp)
    8000249c:	69a2                	ld	s3,8(sp)
    8000249e:	6145                	addi	sp,sp,48
    800024a0:	8082                	ret
        panic("sched p->lock");
    800024a2:	00006517          	auipc	a0,0x6
    800024a6:	dfe50513          	addi	a0,a0,-514 # 800082a0 <digits+0x250>
    800024aa:	ffffe097          	auipc	ra,0xffffe
    800024ae:	096080e7          	jalr	150(ra) # 80000540 <panic>
        panic("sched locks");
    800024b2:	00006517          	auipc	a0,0x6
    800024b6:	dfe50513          	addi	a0,a0,-514 # 800082b0 <digits+0x260>
    800024ba:	ffffe097          	auipc	ra,0xffffe
    800024be:	086080e7          	jalr	134(ra) # 80000540 <panic>
        panic("sched running");
    800024c2:	00006517          	auipc	a0,0x6
    800024c6:	dfe50513          	addi	a0,a0,-514 # 800082c0 <digits+0x270>
    800024ca:	ffffe097          	auipc	ra,0xffffe
    800024ce:	076080e7          	jalr	118(ra) # 80000540 <panic>
        panic("sched interruptible");
    800024d2:	00006517          	auipc	a0,0x6
    800024d6:	dfe50513          	addi	a0,a0,-514 # 800082d0 <digits+0x280>
    800024da:	ffffe097          	auipc	ra,0xffffe
    800024de:	066080e7          	jalr	102(ra) # 80000540 <panic>

00000000800024e2 <yield>:
{
    800024e2:	1101                	addi	sp,sp,-32
    800024e4:	ec06                	sd	ra,24(sp)
    800024e6:	e822                	sd	s0,16(sp)
    800024e8:	e426                	sd	s1,8(sp)
    800024ea:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800024ec:	fffff097          	auipc	ra,0xfffff
    800024f0:	744080e7          	jalr	1860(ra) # 80001c30 <myproc>
    800024f4:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800024f6:	ffffe097          	auipc	ra,0xffffe
    800024fa:	7a8080e7          	jalr	1960(ra) # 80000c9e <acquire>
    p->state = RUNNABLE;
    800024fe:	478d                	li	a5,3
    80002500:	cc9c                	sw	a5,24(s1)
    sched();
    80002502:	00000097          	auipc	ra,0x0
    80002506:	f12080e7          	jalr	-238(ra) # 80002414 <sched>
    release(&p->lock);
    8000250a:	8526                	mv	a0,s1
    8000250c:	fffff097          	auipc	ra,0xfffff
    80002510:	846080e7          	jalr	-1978(ra) # 80000d52 <release>
}
    80002514:	60e2                	ld	ra,24(sp)
    80002516:	6442                	ld	s0,16(sp)
    80002518:	64a2                	ld	s1,8(sp)
    8000251a:	6105                	addi	sp,sp,32
    8000251c:	8082                	ret

000000008000251e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    8000251e:	7179                	addi	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	1800                	addi	s0,sp,48
    8000252c:	89aa                	mv	s3,a0
    8000252e:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002530:	fffff097          	auipc	ra,0xfffff
    80002534:	700080e7          	jalr	1792(ra) # 80001c30 <myproc>
    80002538:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    8000253a:	ffffe097          	auipc	ra,0xffffe
    8000253e:	764080e7          	jalr	1892(ra) # 80000c9e <acquire>
    release(lk);
    80002542:	854a                	mv	a0,s2
    80002544:	fffff097          	auipc	ra,0xfffff
    80002548:	80e080e7          	jalr	-2034(ra) # 80000d52 <release>

    // Go to sleep.
    p->chan = chan;
    8000254c:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002550:	4789                	li	a5,2
    80002552:	cc9c                	sw	a5,24(s1)

    sched();
    80002554:	00000097          	auipc	ra,0x0
    80002558:	ec0080e7          	jalr	-320(ra) # 80002414 <sched>

    // Tidy up.
    p->chan = 0;
    8000255c:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002560:	8526                	mv	a0,s1
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	7f0080e7          	jalr	2032(ra) # 80000d52 <release>
    acquire(lk);
    8000256a:	854a                	mv	a0,s2
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	732080e7          	jalr	1842(ra) # 80000c9e <acquire>
}
    80002574:	70a2                	ld	ra,40(sp)
    80002576:	7402                	ld	s0,32(sp)
    80002578:	64e2                	ld	s1,24(sp)
    8000257a:	6942                	ld	s2,16(sp)
    8000257c:	69a2                	ld	s3,8(sp)
    8000257e:	6145                	addi	sp,sp,48
    80002580:	8082                	ret

0000000080002582 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002582:	7139                	addi	sp,sp,-64
    80002584:	fc06                	sd	ra,56(sp)
    80002586:	f822                	sd	s0,48(sp)
    80002588:	f426                	sd	s1,40(sp)
    8000258a:	f04a                	sd	s2,32(sp)
    8000258c:	ec4e                	sd	s3,24(sp)
    8000258e:	e852                	sd	s4,16(sp)
    80002590:	e456                	sd	s5,8(sp)
    80002592:	0080                	addi	s0,sp,64
    80002594:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002596:	0000f497          	auipc	s1,0xf
    8000259a:	bea48493          	addi	s1,s1,-1046 # 80011180 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    8000259e:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    800025a0:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    800025a2:	00014917          	auipc	s2,0x14
    800025a6:	5de90913          	addi	s2,s2,1502 # 80016b80 <tickslock>
    800025aa:	a811                	j	800025be <wakeup+0x3c>
            }
            release(&p->lock);
    800025ac:	8526                	mv	a0,s1
    800025ae:	ffffe097          	auipc	ra,0xffffe
    800025b2:	7a4080e7          	jalr	1956(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    800025b6:	16848493          	addi	s1,s1,360
    800025ba:	03248663          	beq	s1,s2,800025e6 <wakeup+0x64>
        if (p != myproc())
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	672080e7          	jalr	1650(ra) # 80001c30 <myproc>
    800025c6:	fea488e3          	beq	s1,a0,800025b6 <wakeup+0x34>
            acquire(&p->lock);
    800025ca:	8526                	mv	a0,s1
    800025cc:	ffffe097          	auipc	ra,0xffffe
    800025d0:	6d2080e7          	jalr	1746(ra) # 80000c9e <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    800025d4:	4c9c                	lw	a5,24(s1)
    800025d6:	fd379be3          	bne	a5,s3,800025ac <wakeup+0x2a>
    800025da:	709c                	ld	a5,32(s1)
    800025dc:	fd4798e3          	bne	a5,s4,800025ac <wakeup+0x2a>
                p->state = RUNNABLE;
    800025e0:	0154ac23          	sw	s5,24(s1)
    800025e4:	b7e1                	j	800025ac <wakeup+0x2a>
        }
    }
}
    800025e6:	70e2                	ld	ra,56(sp)
    800025e8:	7442                	ld	s0,48(sp)
    800025ea:	74a2                	ld	s1,40(sp)
    800025ec:	7902                	ld	s2,32(sp)
    800025ee:	69e2                	ld	s3,24(sp)
    800025f0:	6a42                	ld	s4,16(sp)
    800025f2:	6aa2                	ld	s5,8(sp)
    800025f4:	6121                	addi	sp,sp,64
    800025f6:	8082                	ret

00000000800025f8 <reparent>:
{
    800025f8:	7179                	addi	sp,sp,-48
    800025fa:	f406                	sd	ra,40(sp)
    800025fc:	f022                	sd	s0,32(sp)
    800025fe:	ec26                	sd	s1,24(sp)
    80002600:	e84a                	sd	s2,16(sp)
    80002602:	e44e                	sd	s3,8(sp)
    80002604:	e052                	sd	s4,0(sp)
    80002606:	1800                	addi	s0,sp,48
    80002608:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000260a:	0000f497          	auipc	s1,0xf
    8000260e:	b7648493          	addi	s1,s1,-1162 # 80011180 <proc>
            pp->parent = initproc;
    80002612:	00006a17          	auipc	s4,0x6
    80002616:	4c6a0a13          	addi	s4,s4,1222 # 80008ad8 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    8000261a:	00014997          	auipc	s3,0x14
    8000261e:	56698993          	addi	s3,s3,1382 # 80016b80 <tickslock>
    80002622:	a029                	j	8000262c <reparent+0x34>
    80002624:	16848493          	addi	s1,s1,360
    80002628:	01348d63          	beq	s1,s3,80002642 <reparent+0x4a>
        if (pp->parent == p)
    8000262c:	7c9c                	ld	a5,56(s1)
    8000262e:	ff279be3          	bne	a5,s2,80002624 <reparent+0x2c>
            pp->parent = initproc;
    80002632:	000a3503          	ld	a0,0(s4)
    80002636:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    80002638:	00000097          	auipc	ra,0x0
    8000263c:	f4a080e7          	jalr	-182(ra) # 80002582 <wakeup>
    80002640:	b7d5                	j	80002624 <reparent+0x2c>
}
    80002642:	70a2                	ld	ra,40(sp)
    80002644:	7402                	ld	s0,32(sp)
    80002646:	64e2                	ld	s1,24(sp)
    80002648:	6942                	ld	s2,16(sp)
    8000264a:	69a2                	ld	s3,8(sp)
    8000264c:	6a02                	ld	s4,0(sp)
    8000264e:	6145                	addi	sp,sp,48
    80002650:	8082                	ret

0000000080002652 <exit>:
{
    80002652:	7179                	addi	sp,sp,-48
    80002654:	f406                	sd	ra,40(sp)
    80002656:	f022                	sd	s0,32(sp)
    80002658:	ec26                	sd	s1,24(sp)
    8000265a:	e84a                	sd	s2,16(sp)
    8000265c:	e44e                	sd	s3,8(sp)
    8000265e:	e052                	sd	s4,0(sp)
    80002660:	1800                	addi	s0,sp,48
    80002662:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    80002664:	fffff097          	auipc	ra,0xfffff
    80002668:	5cc080e7          	jalr	1484(ra) # 80001c30 <myproc>
    8000266c:	89aa                	mv	s3,a0
    if (p == initproc)
    8000266e:	00006797          	auipc	a5,0x6
    80002672:	46a7b783          	ld	a5,1130(a5) # 80008ad8 <initproc>
    80002676:	0d050493          	addi	s1,a0,208
    8000267a:	15050913          	addi	s2,a0,336
    8000267e:	02a79363          	bne	a5,a0,800026a4 <exit+0x52>
        panic("init exiting");
    80002682:	00006517          	auipc	a0,0x6
    80002686:	c6650513          	addi	a0,a0,-922 # 800082e8 <digits+0x298>
    8000268a:	ffffe097          	auipc	ra,0xffffe
    8000268e:	eb6080e7          	jalr	-330(ra) # 80000540 <panic>
            fileclose(f);
    80002692:	00002097          	auipc	ra,0x2
    80002696:	634080e7          	jalr	1588(ra) # 80004cc6 <fileclose>
            p->ofile[fd] = 0;
    8000269a:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    8000269e:	04a1                	addi	s1,s1,8
    800026a0:	01248563          	beq	s1,s2,800026aa <exit+0x58>
        if (p->ofile[fd])
    800026a4:	6088                	ld	a0,0(s1)
    800026a6:	f575                	bnez	a0,80002692 <exit+0x40>
    800026a8:	bfdd                	j	8000269e <exit+0x4c>
    begin_op();
    800026aa:	00002097          	auipc	ra,0x2
    800026ae:	154080e7          	jalr	340(ra) # 800047fe <begin_op>
    iput(p->cwd);
    800026b2:	1509b503          	ld	a0,336(s3)
    800026b6:	00002097          	auipc	ra,0x2
    800026ba:	936080e7          	jalr	-1738(ra) # 80003fec <iput>
    end_op();
    800026be:	00002097          	auipc	ra,0x2
    800026c2:	1be080e7          	jalr	446(ra) # 8000487c <end_op>
    p->cwd = 0;
    800026c6:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    800026ca:	0000f497          	auipc	s1,0xf
    800026ce:	a9e48493          	addi	s1,s1,-1378 # 80011168 <wait_lock>
    800026d2:	8526                	mv	a0,s1
    800026d4:	ffffe097          	auipc	ra,0xffffe
    800026d8:	5ca080e7          	jalr	1482(ra) # 80000c9e <acquire>
    reparent(p);
    800026dc:	854e                	mv	a0,s3
    800026de:	00000097          	auipc	ra,0x0
    800026e2:	f1a080e7          	jalr	-230(ra) # 800025f8 <reparent>
    wakeup(p->parent);
    800026e6:	0389b503          	ld	a0,56(s3)
    800026ea:	00000097          	auipc	ra,0x0
    800026ee:	e98080e7          	jalr	-360(ra) # 80002582 <wakeup>
    acquire(&p->lock);
    800026f2:	854e                	mv	a0,s3
    800026f4:	ffffe097          	auipc	ra,0xffffe
    800026f8:	5aa080e7          	jalr	1450(ra) # 80000c9e <acquire>
    p->xstate = status;
    800026fc:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    80002700:	4795                	li	a5,5
    80002702:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    80002706:	8526                	mv	a0,s1
    80002708:	ffffe097          	auipc	ra,0xffffe
    8000270c:	64a080e7          	jalr	1610(ra) # 80000d52 <release>
    sched();
    80002710:	00000097          	auipc	ra,0x0
    80002714:	d04080e7          	jalr	-764(ra) # 80002414 <sched>
    panic("zombie exit");
    80002718:	00006517          	auipc	a0,0x6
    8000271c:	be050513          	addi	a0,a0,-1056 # 800082f8 <digits+0x2a8>
    80002720:	ffffe097          	auipc	ra,0xffffe
    80002724:	e20080e7          	jalr	-480(ra) # 80000540 <panic>

0000000080002728 <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    80002728:	7179                	addi	sp,sp,-48
    8000272a:	f406                	sd	ra,40(sp)
    8000272c:	f022                	sd	s0,32(sp)
    8000272e:	ec26                	sd	s1,24(sp)
    80002730:	e84a                	sd	s2,16(sp)
    80002732:	e44e                	sd	s3,8(sp)
    80002734:	1800                	addi	s0,sp,48
    80002736:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    80002738:	0000f497          	auipc	s1,0xf
    8000273c:	a4848493          	addi	s1,s1,-1464 # 80011180 <proc>
    80002740:	00014997          	auipc	s3,0x14
    80002744:	44098993          	addi	s3,s3,1088 # 80016b80 <tickslock>
    {
        acquire(&p->lock);
    80002748:	8526                	mv	a0,s1
    8000274a:	ffffe097          	auipc	ra,0xffffe
    8000274e:	554080e7          	jalr	1364(ra) # 80000c9e <acquire>
        if (p->pid == pid)
    80002752:	589c                	lw	a5,48(s1)
    80002754:	01278d63          	beq	a5,s2,8000276e <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    80002758:	8526                	mv	a0,s1
    8000275a:	ffffe097          	auipc	ra,0xffffe
    8000275e:	5f8080e7          	jalr	1528(ra) # 80000d52 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002762:	16848493          	addi	s1,s1,360
    80002766:	ff3491e3          	bne	s1,s3,80002748 <kill+0x20>
    }
    return -1;
    8000276a:	557d                	li	a0,-1
    8000276c:	a829                	j	80002786 <kill+0x5e>
            p->killed = 1;
    8000276e:	4785                	li	a5,1
    80002770:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    80002772:	4c98                	lw	a4,24(s1)
    80002774:	4789                	li	a5,2
    80002776:	00f70f63          	beq	a4,a5,80002794 <kill+0x6c>
            release(&p->lock);
    8000277a:	8526                	mv	a0,s1
    8000277c:	ffffe097          	auipc	ra,0xffffe
    80002780:	5d6080e7          	jalr	1494(ra) # 80000d52 <release>
            return 0;
    80002784:	4501                	li	a0,0
}
    80002786:	70a2                	ld	ra,40(sp)
    80002788:	7402                	ld	s0,32(sp)
    8000278a:	64e2                	ld	s1,24(sp)
    8000278c:	6942                	ld	s2,16(sp)
    8000278e:	69a2                	ld	s3,8(sp)
    80002790:	6145                	addi	sp,sp,48
    80002792:	8082                	ret
                p->state = RUNNABLE;
    80002794:	478d                	li	a5,3
    80002796:	cc9c                	sw	a5,24(s1)
    80002798:	b7cd                	j	8000277a <kill+0x52>

000000008000279a <setkilled>:

void setkilled(struct proc *p)
{
    8000279a:	1101                	addi	sp,sp,-32
    8000279c:	ec06                	sd	ra,24(sp)
    8000279e:	e822                	sd	s0,16(sp)
    800027a0:	e426                	sd	s1,8(sp)
    800027a2:	1000                	addi	s0,sp,32
    800027a4:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4f8080e7          	jalr	1272(ra) # 80000c9e <acquire>
    p->killed = 1;
    800027ae:	4785                	li	a5,1
    800027b0:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    800027b2:	8526                	mv	a0,s1
    800027b4:	ffffe097          	auipc	ra,0xffffe
    800027b8:	59e080e7          	jalr	1438(ra) # 80000d52 <release>
}
    800027bc:	60e2                	ld	ra,24(sp)
    800027be:	6442                	ld	s0,16(sp)
    800027c0:	64a2                	ld	s1,8(sp)
    800027c2:	6105                	addi	sp,sp,32
    800027c4:	8082                	ret

00000000800027c6 <killed>:

int killed(struct proc *p)
{
    800027c6:	1101                	addi	sp,sp,-32
    800027c8:	ec06                	sd	ra,24(sp)
    800027ca:	e822                	sd	s0,16(sp)
    800027cc:	e426                	sd	s1,8(sp)
    800027ce:	e04a                	sd	s2,0(sp)
    800027d0:	1000                	addi	s0,sp,32
    800027d2:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    800027d4:	ffffe097          	auipc	ra,0xffffe
    800027d8:	4ca080e7          	jalr	1226(ra) # 80000c9e <acquire>
    k = p->killed;
    800027dc:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	570080e7          	jalr	1392(ra) # 80000d52 <release>
    return k;
}
    800027ea:	854a                	mv	a0,s2
    800027ec:	60e2                	ld	ra,24(sp)
    800027ee:	6442                	ld	s0,16(sp)
    800027f0:	64a2                	ld	s1,8(sp)
    800027f2:	6902                	ld	s2,0(sp)
    800027f4:	6105                	addi	sp,sp,32
    800027f6:	8082                	ret

00000000800027f8 <wait>:
{
    800027f8:	715d                	addi	sp,sp,-80
    800027fa:	e486                	sd	ra,72(sp)
    800027fc:	e0a2                	sd	s0,64(sp)
    800027fe:	fc26                	sd	s1,56(sp)
    80002800:	f84a                	sd	s2,48(sp)
    80002802:	f44e                	sd	s3,40(sp)
    80002804:	f052                	sd	s4,32(sp)
    80002806:	ec56                	sd	s5,24(sp)
    80002808:	e85a                	sd	s6,16(sp)
    8000280a:	e45e                	sd	s7,8(sp)
    8000280c:	e062                	sd	s8,0(sp)
    8000280e:	0880                	addi	s0,sp,80
    80002810:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    80002812:	fffff097          	auipc	ra,0xfffff
    80002816:	41e080e7          	jalr	1054(ra) # 80001c30 <myproc>
    8000281a:	892a                	mv	s2,a0
    acquire(&wait_lock);
    8000281c:	0000f517          	auipc	a0,0xf
    80002820:	94c50513          	addi	a0,a0,-1716 # 80011168 <wait_lock>
    80002824:	ffffe097          	auipc	ra,0xffffe
    80002828:	47a080e7          	jalr	1146(ra) # 80000c9e <acquire>
        havekids = 0;
    8000282c:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    8000282e:	4a15                	li	s4,5
                havekids = 1;
    80002830:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002832:	00014997          	auipc	s3,0x14
    80002836:	34e98993          	addi	s3,s3,846 # 80016b80 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    8000283a:	0000fc17          	auipc	s8,0xf
    8000283e:	92ec0c13          	addi	s8,s8,-1746 # 80011168 <wait_lock>
        havekids = 0;
    80002842:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002844:	0000f497          	auipc	s1,0xf
    80002848:	93c48493          	addi	s1,s1,-1732 # 80011180 <proc>
    8000284c:	a0bd                	j	800028ba <wait+0xc2>
                    pid = pp->pid;
    8000284e:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002852:	000b0e63          	beqz	s6,8000286e <wait+0x76>
    80002856:	4691                	li	a3,4
    80002858:	02c48613          	addi	a2,s1,44
    8000285c:	85da                	mv	a1,s6
    8000285e:	05093503          	ld	a0,80(s2)
    80002862:	fffff097          	auipc	ra,0xfffff
    80002866:	f90080e7          	jalr	-112(ra) # 800017f2 <copyout>
    8000286a:	02054563          	bltz	a0,80002894 <wait+0x9c>
                    freeproc(pp);
    8000286e:	8526                	mv	a0,s1
    80002870:	fffff097          	auipc	ra,0xfffff
    80002874:	572080e7          	jalr	1394(ra) # 80001de2 <freeproc>
                    release(&pp->lock);
    80002878:	8526                	mv	a0,s1
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	4d8080e7          	jalr	1240(ra) # 80000d52 <release>
                    release(&wait_lock);
    80002882:	0000f517          	auipc	a0,0xf
    80002886:	8e650513          	addi	a0,a0,-1818 # 80011168 <wait_lock>
    8000288a:	ffffe097          	auipc	ra,0xffffe
    8000288e:	4c8080e7          	jalr	1224(ra) # 80000d52 <release>
                    return pid;
    80002892:	a0b5                	j	800028fe <wait+0x106>
                        release(&pp->lock);
    80002894:	8526                	mv	a0,s1
    80002896:	ffffe097          	auipc	ra,0xffffe
    8000289a:	4bc080e7          	jalr	1212(ra) # 80000d52 <release>
                        release(&wait_lock);
    8000289e:	0000f517          	auipc	a0,0xf
    800028a2:	8ca50513          	addi	a0,a0,-1846 # 80011168 <wait_lock>
    800028a6:	ffffe097          	auipc	ra,0xffffe
    800028aa:	4ac080e7          	jalr	1196(ra) # 80000d52 <release>
                        return -1;
    800028ae:	59fd                	li	s3,-1
    800028b0:	a0b9                	j	800028fe <wait+0x106>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800028b2:	16848493          	addi	s1,s1,360
    800028b6:	03348463          	beq	s1,s3,800028de <wait+0xe6>
            if (pp->parent == p)
    800028ba:	7c9c                	ld	a5,56(s1)
    800028bc:	ff279be3          	bne	a5,s2,800028b2 <wait+0xba>
                acquire(&pp->lock);
    800028c0:	8526                	mv	a0,s1
    800028c2:	ffffe097          	auipc	ra,0xffffe
    800028c6:	3dc080e7          	jalr	988(ra) # 80000c9e <acquire>
                if (pp->state == ZOMBIE)
    800028ca:	4c9c                	lw	a5,24(s1)
    800028cc:	f94781e3          	beq	a5,s4,8000284e <wait+0x56>
                release(&pp->lock);
    800028d0:	8526                	mv	a0,s1
    800028d2:	ffffe097          	auipc	ra,0xffffe
    800028d6:	480080e7          	jalr	1152(ra) # 80000d52 <release>
                havekids = 1;
    800028da:	8756                	mv	a4,s5
    800028dc:	bfd9                	j	800028b2 <wait+0xba>
        if (!havekids || killed(p))
    800028de:	c719                	beqz	a4,800028ec <wait+0xf4>
    800028e0:	854a                	mv	a0,s2
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	ee4080e7          	jalr	-284(ra) # 800027c6 <killed>
    800028ea:	c51d                	beqz	a0,80002918 <wait+0x120>
            release(&wait_lock);
    800028ec:	0000f517          	auipc	a0,0xf
    800028f0:	87c50513          	addi	a0,a0,-1924 # 80011168 <wait_lock>
    800028f4:	ffffe097          	auipc	ra,0xffffe
    800028f8:	45e080e7          	jalr	1118(ra) # 80000d52 <release>
            return -1;
    800028fc:	59fd                	li	s3,-1
}
    800028fe:	854e                	mv	a0,s3
    80002900:	60a6                	ld	ra,72(sp)
    80002902:	6406                	ld	s0,64(sp)
    80002904:	74e2                	ld	s1,56(sp)
    80002906:	7942                	ld	s2,48(sp)
    80002908:	79a2                	ld	s3,40(sp)
    8000290a:	7a02                	ld	s4,32(sp)
    8000290c:	6ae2                	ld	s5,24(sp)
    8000290e:	6b42                	ld	s6,16(sp)
    80002910:	6ba2                	ld	s7,8(sp)
    80002912:	6c02                	ld	s8,0(sp)
    80002914:	6161                	addi	sp,sp,80
    80002916:	8082                	ret
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002918:	85e2                	mv	a1,s8
    8000291a:	854a                	mv	a0,s2
    8000291c:	00000097          	auipc	ra,0x0
    80002920:	c02080e7          	jalr	-1022(ra) # 8000251e <sleep>
        havekids = 0;
    80002924:	bf39                	j	80002842 <wait+0x4a>

0000000080002926 <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002926:	7179                	addi	sp,sp,-48
    80002928:	f406                	sd	ra,40(sp)
    8000292a:	f022                	sd	s0,32(sp)
    8000292c:	ec26                	sd	s1,24(sp)
    8000292e:	e84a                	sd	s2,16(sp)
    80002930:	e44e                	sd	s3,8(sp)
    80002932:	e052                	sd	s4,0(sp)
    80002934:	1800                	addi	s0,sp,48
    80002936:	84aa                	mv	s1,a0
    80002938:	892e                	mv	s2,a1
    8000293a:	89b2                	mv	s3,a2
    8000293c:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000293e:	fffff097          	auipc	ra,0xfffff
    80002942:	2f2080e7          	jalr	754(ra) # 80001c30 <myproc>
    if (user_dst)
    80002946:	c08d                	beqz	s1,80002968 <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    80002948:	86d2                	mv	a3,s4
    8000294a:	864e                	mv	a2,s3
    8000294c:	85ca                	mv	a1,s2
    8000294e:	6928                	ld	a0,80(a0)
    80002950:	fffff097          	auipc	ra,0xfffff
    80002954:	ea2080e7          	jalr	-350(ra) # 800017f2 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    80002958:	70a2                	ld	ra,40(sp)
    8000295a:	7402                	ld	s0,32(sp)
    8000295c:	64e2                	ld	s1,24(sp)
    8000295e:	6942                	ld	s2,16(sp)
    80002960:	69a2                	ld	s3,8(sp)
    80002962:	6a02                	ld	s4,0(sp)
    80002964:	6145                	addi	sp,sp,48
    80002966:	8082                	ret
        memmove((char *)dst, src, len);
    80002968:	000a061b          	sext.w	a2,s4
    8000296c:	85ce                	mv	a1,s3
    8000296e:	854a                	mv	a0,s2
    80002970:	ffffe097          	auipc	ra,0xffffe
    80002974:	486080e7          	jalr	1158(ra) # 80000df6 <memmove>
        return 0;
    80002978:	8526                	mv	a0,s1
    8000297a:	bff9                	j	80002958 <either_copyout+0x32>

000000008000297c <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    8000297c:	7179                	addi	sp,sp,-48
    8000297e:	f406                	sd	ra,40(sp)
    80002980:	f022                	sd	s0,32(sp)
    80002982:	ec26                	sd	s1,24(sp)
    80002984:	e84a                	sd	s2,16(sp)
    80002986:	e44e                	sd	s3,8(sp)
    80002988:	e052                	sd	s4,0(sp)
    8000298a:	1800                	addi	s0,sp,48
    8000298c:	892a                	mv	s2,a0
    8000298e:	84ae                	mv	s1,a1
    80002990:	89b2                	mv	s3,a2
    80002992:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002994:	fffff097          	auipc	ra,0xfffff
    80002998:	29c080e7          	jalr	668(ra) # 80001c30 <myproc>
    if (user_src)
    8000299c:	c08d                	beqz	s1,800029be <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    8000299e:	86d2                	mv	a3,s4
    800029a0:	864e                	mv	a2,s3
    800029a2:	85ca                	mv	a1,s2
    800029a4:	6928                	ld	a0,80(a0)
    800029a6:	fffff097          	auipc	ra,0xfffff
    800029aa:	ed8080e7          	jalr	-296(ra) # 8000187e <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    800029ae:	70a2                	ld	ra,40(sp)
    800029b0:	7402                	ld	s0,32(sp)
    800029b2:	64e2                	ld	s1,24(sp)
    800029b4:	6942                	ld	s2,16(sp)
    800029b6:	69a2                	ld	s3,8(sp)
    800029b8:	6a02                	ld	s4,0(sp)
    800029ba:	6145                	addi	sp,sp,48
    800029bc:	8082                	ret
        memmove(dst, (char *)src, len);
    800029be:	000a061b          	sext.w	a2,s4
    800029c2:	85ce                	mv	a1,s3
    800029c4:	854a                	mv	a0,s2
    800029c6:	ffffe097          	auipc	ra,0xffffe
    800029ca:	430080e7          	jalr	1072(ra) # 80000df6 <memmove>
        return 0;
    800029ce:	8526                	mv	a0,s1
    800029d0:	bff9                	j	800029ae <either_copyin+0x32>

00000000800029d2 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    800029d2:	715d                	addi	sp,sp,-80
    800029d4:	e486                	sd	ra,72(sp)
    800029d6:	e0a2                	sd	s0,64(sp)
    800029d8:	fc26                	sd	s1,56(sp)
    800029da:	f84a                	sd	s2,48(sp)
    800029dc:	f44e                	sd	s3,40(sp)
    800029de:	f052                	sd	s4,32(sp)
    800029e0:	ec56                	sd	s5,24(sp)
    800029e2:	e85a                	sd	s6,16(sp)
    800029e4:	e45e                	sd	s7,8(sp)
    800029e6:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800029e8:	00005517          	auipc	a0,0x5
    800029ec:	6a050513          	addi	a0,a0,1696 # 80008088 <digits+0x38>
    800029f0:	ffffe097          	auipc	ra,0xffffe
    800029f4:	bac080e7          	jalr	-1108(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800029f8:	0000f497          	auipc	s1,0xf
    800029fc:	8e048493          	addi	s1,s1,-1824 # 800112d8 <proc+0x158>
    80002a00:	00014917          	auipc	s2,0x14
    80002a04:	2d890913          	addi	s2,s2,728 # 80016cd8 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a08:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    80002a0a:	00006997          	auipc	s3,0x6
    80002a0e:	8fe98993          	addi	s3,s3,-1794 # 80008308 <digits+0x2b8>
        printf("%d <%s %s", p->pid, state, p->name);
    80002a12:	00006a97          	auipc	s5,0x6
    80002a16:	8fea8a93          	addi	s5,s5,-1794 # 80008310 <digits+0x2c0>
        printf("\n");
    80002a1a:	00005a17          	auipc	s4,0x5
    80002a1e:	66ea0a13          	addi	s4,s4,1646 # 80008088 <digits+0x38>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a22:	00006b97          	auipc	s7,0x6
    80002a26:	9feb8b93          	addi	s7,s7,-1538 # 80008420 <states.0>
    80002a2a:	a00d                	j	80002a4c <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    80002a2c:	ed86a583          	lw	a1,-296(a3)
    80002a30:	8556                	mv	a0,s5
    80002a32:	ffffe097          	auipc	ra,0xffffe
    80002a36:	b6a080e7          	jalr	-1174(ra) # 8000059c <printf>
        printf("\n");
    80002a3a:	8552                	mv	a0,s4
    80002a3c:	ffffe097          	auipc	ra,0xffffe
    80002a40:	b60080e7          	jalr	-1184(ra) # 8000059c <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    80002a44:	16848493          	addi	s1,s1,360
    80002a48:	03248263          	beq	s1,s2,80002a6c <procdump+0x9a>
        if (p->state == UNUSED)
    80002a4c:	86a6                	mv	a3,s1
    80002a4e:	ec04a783          	lw	a5,-320(s1)
    80002a52:	dbed                	beqz	a5,80002a44 <procdump+0x72>
            state = "???";
    80002a54:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002a56:	fcfb6be3          	bltu	s6,a5,80002a2c <procdump+0x5a>
    80002a5a:	02079713          	slli	a4,a5,0x20
    80002a5e:	01d75793          	srli	a5,a4,0x1d
    80002a62:	97de                	add	a5,a5,s7
    80002a64:	6390                	ld	a2,0(a5)
    80002a66:	f279                	bnez	a2,80002a2c <procdump+0x5a>
            state = "???";
    80002a68:	864e                	mv	a2,s3
    80002a6a:	b7c9                	j	80002a2c <procdump+0x5a>
    }
}
    80002a6c:	60a6                	ld	ra,72(sp)
    80002a6e:	6406                	ld	s0,64(sp)
    80002a70:	74e2                	ld	s1,56(sp)
    80002a72:	7942                	ld	s2,48(sp)
    80002a74:	79a2                	ld	s3,40(sp)
    80002a76:	7a02                	ld	s4,32(sp)
    80002a78:	6ae2                	ld	s5,24(sp)
    80002a7a:	6b42                	ld	s6,16(sp)
    80002a7c:	6ba2                	ld	s7,8(sp)
    80002a7e:	6161                	addi	sp,sp,80
    80002a80:	8082                	ret

0000000080002a82 <schedls>:

void schedls()
{
    80002a82:	1141                	addi	sp,sp,-16
    80002a84:	e406                	sd	ra,8(sp)
    80002a86:	e022                	sd	s0,0(sp)
    80002a88:	0800                	addi	s0,sp,16
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002a8a:	00006517          	auipc	a0,0x6
    80002a8e:	89650513          	addi	a0,a0,-1898 # 80008320 <digits+0x2d0>
    80002a92:	ffffe097          	auipc	ra,0xffffe
    80002a96:	b0a080e7          	jalr	-1270(ra) # 8000059c <printf>
    printf("====================================\n");
    80002a9a:	00006517          	auipc	a0,0x6
    80002a9e:	8ae50513          	addi	a0,a0,-1874 # 80008348 <digits+0x2f8>
    80002aa2:	ffffe097          	auipc	ra,0xffffe
    80002aa6:	afa080e7          	jalr	-1286(ra) # 8000059c <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002aaa:	00006717          	auipc	a4,0x6
    80002aae:	fbe73703          	ld	a4,-66(a4) # 80008a68 <available_schedulers+0x10>
    80002ab2:	00006797          	auipc	a5,0x6
    80002ab6:	f567b783          	ld	a5,-170(a5) # 80008a08 <sched_pointer>
    80002aba:	04f70663          	beq	a4,a5,80002b06 <schedls+0x84>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002abe:	00006517          	auipc	a0,0x6
    80002ac2:	8ba50513          	addi	a0,a0,-1862 # 80008378 <digits+0x328>
    80002ac6:	ffffe097          	auipc	ra,0xffffe
    80002aca:	ad6080e7          	jalr	-1322(ra) # 8000059c <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002ace:	00006617          	auipc	a2,0x6
    80002ad2:	fa262603          	lw	a2,-94(a2) # 80008a70 <available_schedulers+0x18>
    80002ad6:	00006597          	auipc	a1,0x6
    80002ada:	f8258593          	addi	a1,a1,-126 # 80008a58 <available_schedulers>
    80002ade:	00006517          	auipc	a0,0x6
    80002ae2:	8a250513          	addi	a0,a0,-1886 # 80008380 <digits+0x330>
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	ab6080e7          	jalr	-1354(ra) # 8000059c <printf>
    }
    printf("\n*: current scheduler\n\n");
    80002aee:	00006517          	auipc	a0,0x6
    80002af2:	89a50513          	addi	a0,a0,-1894 # 80008388 <digits+0x338>
    80002af6:	ffffe097          	auipc	ra,0xffffe
    80002afa:	aa6080e7          	jalr	-1370(ra) # 8000059c <printf>
}
    80002afe:	60a2                	ld	ra,8(sp)
    80002b00:	6402                	ld	s0,0(sp)
    80002b02:	0141                	addi	sp,sp,16
    80002b04:	8082                	ret
            printf("[*]\t");
    80002b06:	00006517          	auipc	a0,0x6
    80002b0a:	86a50513          	addi	a0,a0,-1942 # 80008370 <digits+0x320>
    80002b0e:	ffffe097          	auipc	ra,0xffffe
    80002b12:	a8e080e7          	jalr	-1394(ra) # 8000059c <printf>
    80002b16:	bf65                	j	80002ace <schedls+0x4c>

0000000080002b18 <schedset>:

void schedset(int id)
{
    80002b18:	1141                	addi	sp,sp,-16
    80002b1a:	e406                	sd	ra,8(sp)
    80002b1c:	e022                	sd	s0,0(sp)
    80002b1e:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002b20:	e90d                	bnez	a0,80002b52 <schedset+0x3a>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002b22:	00006797          	auipc	a5,0x6
    80002b26:	f467b783          	ld	a5,-186(a5) # 80008a68 <available_schedulers+0x10>
    80002b2a:	00006717          	auipc	a4,0x6
    80002b2e:	ecf73f23          	sd	a5,-290(a4) # 80008a08 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002b32:	00006597          	auipc	a1,0x6
    80002b36:	f2658593          	addi	a1,a1,-218 # 80008a58 <available_schedulers>
    80002b3a:	00006517          	auipc	a0,0x6
    80002b3e:	88e50513          	addi	a0,a0,-1906 # 800083c8 <digits+0x378>
    80002b42:	ffffe097          	auipc	ra,0xffffe
    80002b46:	a5a080e7          	jalr	-1446(ra) # 8000059c <printf>
}
    80002b4a:	60a2                	ld	ra,8(sp)
    80002b4c:	6402                	ld	s0,0(sp)
    80002b4e:	0141                	addi	sp,sp,16
    80002b50:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002b52:	00006517          	auipc	a0,0x6
    80002b56:	84e50513          	addi	a0,a0,-1970 # 800083a0 <digits+0x350>
    80002b5a:	ffffe097          	auipc	ra,0xffffe
    80002b5e:	a42080e7          	jalr	-1470(ra) # 8000059c <printf>
        return;
    80002b62:	b7e5                	j	80002b4a <schedset+0x32>

0000000080002b64 <va2pa>:
uint64 va2pa(uint64 va, int pid)
{
    80002b64:	1101                	addi	sp,sp,-32
    80002b66:	ec06                	sd	ra,24(sp)
    80002b68:	e822                	sd	s0,16(sp)
    80002b6a:	e426                	sd	s1,8(sp)
    80002b6c:	e04a                	sd	s2,0(sp)
    80002b6e:	1000                	addi	s0,sp,32
    80002b70:	892a                	mv	s2,a0
    80002b72:	84ae                	mv	s1,a1
    struct proc *p;
    pagetable_t pagetable = 0;

    acquire(&pid_lock);
    80002b74:	0000e517          	auipc	a0,0xe
    80002b78:	5dc50513          	addi	a0,a0,1500 # 80011150 <pid_lock>
    80002b7c:	ffffe097          	auipc	ra,0xffffe
    80002b80:	122080e7          	jalr	290(ra) # 80000c9e <acquire>

    for (p = proc; p < &proc[NPROC]; p++)
    80002b84:	0000e797          	auipc	a5,0xe
    80002b88:	5fc78793          	addi	a5,a5,1532 # 80011180 <proc>
    80002b8c:	00014697          	auipc	a3,0x14
    80002b90:	ff468693          	addi	a3,a3,-12 # 80016b80 <tickslock>
    {
        if (p->pid == pid)
    80002b94:	5b98                	lw	a4,48(a5)
    80002b96:	02970063          	beq	a4,s1,80002bb6 <va2pa+0x52>
    for (p = proc; p < &proc[NPROC]; p++)
    80002b9a:	16878793          	addi	a5,a5,360
    80002b9e:	fed79be3          	bne	a5,a3,80002b94 <va2pa+0x30>
        {
            pagetable = p->pagetable;
            break;
        }
    }
    release(&pid_lock);
    80002ba2:	0000e517          	auipc	a0,0xe
    80002ba6:	5ae50513          	addi	a0,a0,1454 # 80011150 <pid_lock>
    80002baa:	ffffe097          	auipc	ra,0xffffe
    80002bae:	1a8080e7          	jalr	424(ra) # 80000d52 <release>
    if (pagetable == 0)
    {
        return -1;
    80002bb2:	557d                	li	a0,-1
    80002bb4:	a00d                	j	80002bd6 <va2pa+0x72>
            pagetable = p->pagetable;
    80002bb6:	6ba4                	ld	s1,80(a5)
    release(&pid_lock);
    80002bb8:	0000e517          	auipc	a0,0xe
    80002bbc:	59850513          	addi	a0,a0,1432 # 80011150 <pid_lock>
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	192080e7          	jalr	402(ra) # 80000d52 <release>
    if (pagetable == 0)
    80002bc8:	cc89                	beqz	s1,80002be2 <va2pa+0x7e>
    }
    return walkaddr(pagetable, va);
    80002bca:	85ca                	mv	a1,s2
    80002bcc:	8526                	mv	a0,s1
    80002bce:	ffffe097          	auipc	ra,0xffffe
    80002bd2:	556080e7          	jalr	1366(ra) # 80001124 <walkaddr>
    80002bd6:	60e2                	ld	ra,24(sp)
    80002bd8:	6442                	ld	s0,16(sp)
    80002bda:	64a2                	ld	s1,8(sp)
    80002bdc:	6902                	ld	s2,0(sp)
    80002bde:	6105                	addi	sp,sp,32
    80002be0:	8082                	ret
        return -1;
    80002be2:	557d                	li	a0,-1
    80002be4:	bfcd                	j	80002bd6 <va2pa+0x72>

0000000080002be6 <swtch>:
    80002be6:	00153023          	sd	ra,0(a0)
    80002bea:	00253423          	sd	sp,8(a0)
    80002bee:	e900                	sd	s0,16(a0)
    80002bf0:	ed04                	sd	s1,24(a0)
    80002bf2:	03253023          	sd	s2,32(a0)
    80002bf6:	03353423          	sd	s3,40(a0)
    80002bfa:	03453823          	sd	s4,48(a0)
    80002bfe:	03553c23          	sd	s5,56(a0)
    80002c02:	05653023          	sd	s6,64(a0)
    80002c06:	05753423          	sd	s7,72(a0)
    80002c0a:	05853823          	sd	s8,80(a0)
    80002c0e:	05953c23          	sd	s9,88(a0)
    80002c12:	07a53023          	sd	s10,96(a0)
    80002c16:	07b53423          	sd	s11,104(a0)
    80002c1a:	0005b083          	ld	ra,0(a1)
    80002c1e:	0085b103          	ld	sp,8(a1)
    80002c22:	6980                	ld	s0,16(a1)
    80002c24:	6d84                	ld	s1,24(a1)
    80002c26:	0205b903          	ld	s2,32(a1)
    80002c2a:	0285b983          	ld	s3,40(a1)
    80002c2e:	0305ba03          	ld	s4,48(a1)
    80002c32:	0385ba83          	ld	s5,56(a1)
    80002c36:	0405bb03          	ld	s6,64(a1)
    80002c3a:	0485bb83          	ld	s7,72(a1)
    80002c3e:	0505bc03          	ld	s8,80(a1)
    80002c42:	0585bc83          	ld	s9,88(a1)
    80002c46:	0605bd03          	ld	s10,96(a1)
    80002c4a:	0685bd83          	ld	s11,104(a1)
    80002c4e:	8082                	ret

0000000080002c50 <trapinit>:
void kernelvec();

extern int devintr();

void trapinit(void)
{
    80002c50:	1141                	addi	sp,sp,-16
    80002c52:	e406                	sd	ra,8(sp)
    80002c54:	e022                	sd	s0,0(sp)
    80002c56:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002c58:	00005597          	auipc	a1,0x5
    80002c5c:	7f858593          	addi	a1,a1,2040 # 80008450 <states.0+0x30>
    80002c60:	00014517          	auipc	a0,0x14
    80002c64:	f2050513          	addi	a0,a0,-224 # 80016b80 <tickslock>
    80002c68:	ffffe097          	auipc	ra,0xffffe
    80002c6c:	fa6080e7          	jalr	-90(ra) # 80000c0e <initlock>
}
    80002c70:	60a2                	ld	ra,8(sp)
    80002c72:	6402                	ld	s0,0(sp)
    80002c74:	0141                	addi	sp,sp,16
    80002c76:	8082                	ret

0000000080002c78 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void trapinithart(void)
{
    80002c78:	1141                	addi	sp,sp,-16
    80002c7a:	e422                	sd	s0,8(sp)
    80002c7c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002c7e:	00003797          	auipc	a5,0x3
    80002c82:	6a278793          	addi	a5,a5,1698 # 80006320 <kernelvec>
    80002c86:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002c8a:	6422                	ld	s0,8(sp)
    80002c8c:	0141                	addi	sp,sp,16
    80002c8e:	8082                	ret

0000000080002c90 <handle_cow_fault>:
  if (which_dev == 2)
    yield();
  usertrapret();
}
int handle_cow_fault(uint64 va)
{
    80002c90:	7139                	addi	sp,sp,-64
    80002c92:	fc06                	sd	ra,56(sp)
    80002c94:	f822                	sd	s0,48(sp)
    80002c96:	f426                	sd	s1,40(sp)
    80002c98:	f04a                	sd	s2,32(sp)
    80002c9a:	ec4e                	sd	s3,24(sp)
    80002c9c:	e852                	sd	s4,16(sp)
    80002c9e:	e456                	sd	s5,8(sp)
    80002ca0:	0080                	addi	s0,sp,64
    80002ca2:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ca4:	fffff097          	auipc	ra,0xfffff
    80002ca8:	f8c080e7          	jalr	-116(ra) # 80001c30 <myproc>
    80002cac:	8a2a                	mv	s4,a0
  pte_t *pte;
  uint64 pa;
  char *mem;
  // Walk the page table to find the page table entry for the faulting address
  if ((pte = walk(p->pagetable, va, 0)) == 0)
    80002cae:	4601                	li	a2,0
    80002cb0:	85a6                	mv	a1,s1
    80002cb2:	6928                	ld	a0,80(a0)
    80002cb4:	ffffe097          	auipc	ra,0xffffe
    80002cb8:	3ca080e7          	jalr	970(ra) # 8000107e <walk>
    80002cbc:	c541                	beqz	a0,80002d44 <handle_cow_fault+0xb4>
    80002cbe:	89aa                	mv	s3,a0
    return -1; // Page table entry does not exist
  if ((*pte & PTE_V) == 0 || (*pte & PTE_W) != 0)
    80002cc0:	610c                	ld	a1,0(a0)
    80002cc2:	0055f713          	andi	a4,a1,5
    80002cc6:	4785                	li	a5,1
    80002cc8:	08f71063          	bne	a4,a5,80002d48 <handle_cow_fault+0xb8>
    return -1; // Page not present or already writable
  pa = PTE2PA(*pte);
    80002ccc:	81a9                	srli	a1,a1,0xa
    80002cce:	00c59913          	slli	s2,a1,0xc
  // Allocate a new page to copy the contents
  if ((mem = kalloc()) == 0)
    80002cd2:	ffffe097          	auipc	ra,0xffffe
    80002cd6:	e90080e7          	jalr	-368(ra) # 80000b62 <kalloc>
    80002cda:	8aaa                	mv	s5,a0
    80002cdc:	c925                	beqz	a0,80002d4c <handle_cow_fault+0xbc>
    return -1;
  memmove(mem, (char *)pa, PGSIZE);
    80002cde:	6605                	lui	a2,0x1
    80002ce0:	85ca                	mv	a1,s2
    80002ce2:	ffffe097          	auipc	ra,0xffffe
    80002ce6:	114080e7          	jalr	276(ra) # 80000df6 <memmove>
  // Map the new page as writable
  if (mappages(p->pagetable, PGROUNDDOWN(va), PGSIZE, (uint64)mem, PTE_FLAGS(*pte) | PTE_W) != 0)
    80002cea:	77fd                	lui	a5,0xfffff
    80002cec:	8cfd                	and	s1,s1,a5
    80002cee:	0009b703          	ld	a4,0(s3)
    80002cf2:	3fb77713          	andi	a4,a4,1019
    80002cf6:	00476713          	ori	a4,a4,4
    80002cfa:	86d6                	mv	a3,s5
    80002cfc:	6605                	lui	a2,0x1
    80002cfe:	85a6                	mv	a1,s1
    80002d00:	050a3503          	ld	a0,80(s4)
    80002d04:	ffffe097          	auipc	ra,0xffffe
    80002d08:	482080e7          	jalr	1154(ra) # 80001186 <mappages>
    80002d0c:	892a                	mv	s2,a0
    80002d0e:	e505                	bnez	a0,80002d36 <handle_cow_fault+0xa6>
  {
    kfree(mem);
    return -1;
  }
  // Unmap the old page
  uvmunmap(p->pagetable, PGROUNDDOWN(va), 1, 1);
    80002d10:	4685                	li	a3,1
    80002d12:	4605                	li	a2,1
    80002d14:	85a6                	mv	a1,s1
    80002d16:	050a3503          	ld	a0,80(s4)
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	632080e7          	jalr	1586(ra) # 8000134c <uvmunmap>
  return 0;
}
    80002d22:	854a                	mv	a0,s2
    80002d24:	70e2                	ld	ra,56(sp)
    80002d26:	7442                	ld	s0,48(sp)
    80002d28:	74a2                	ld	s1,40(sp)
    80002d2a:	7902                	ld	s2,32(sp)
    80002d2c:	69e2                	ld	s3,24(sp)
    80002d2e:	6a42                	ld	s4,16(sp)
    80002d30:	6aa2                	ld	s5,8(sp)
    80002d32:	6121                	addi	sp,sp,64
    80002d34:	8082                	ret
    kfree(mem);
    80002d36:	8556                	mv	a0,s5
    80002d38:	ffffe097          	auipc	ra,0xffffe
    80002d3c:	cc2080e7          	jalr	-830(ra) # 800009fa <kfree>
    return -1;
    80002d40:	597d                	li	s2,-1
    80002d42:	b7c5                	j	80002d22 <handle_cow_fault+0x92>
    return -1; // Page table entry does not exist
    80002d44:	597d                	li	s2,-1
    80002d46:	bff1                	j	80002d22 <handle_cow_fault+0x92>
    return -1; // Page not present or already writable
    80002d48:	597d                	li	s2,-1
    80002d4a:	bfe1                	j	80002d22 <handle_cow_fault+0x92>
    return -1;
    80002d4c:	597d                	li	s2,-1
    80002d4e:	bfd1                	j	80002d22 <handle_cow_fault+0x92>

0000000080002d50 <usertrapret>:

//
// return to user space
//
void usertrapret(void)
{
    80002d50:	1141                	addi	sp,sp,-16
    80002d52:	e406                	sd	ra,8(sp)
    80002d54:	e022                	sd	s0,0(sp)
    80002d56:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	ed8080e7          	jalr	-296(ra) # 80001c30 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002d64:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d66:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002d6a:	00004697          	auipc	a3,0x4
    80002d6e:	29668693          	addi	a3,a3,662 # 80007000 <_trampoline>
    80002d72:	00004717          	auipc	a4,0x4
    80002d76:	28e70713          	addi	a4,a4,654 # 80007000 <_trampoline>
    80002d7a:	8f15                	sub	a4,a4,a3
    80002d7c:	040007b7          	lui	a5,0x4000
    80002d80:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002d82:	07b2                	slli	a5,a5,0xc
    80002d84:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002d86:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002d8a:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002d8c:	18002673          	csrr	a2,satp
    80002d90:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002d92:	6d30                	ld	a2,88(a0)
    80002d94:	6138                	ld	a4,64(a0)
    80002d96:	6585                	lui	a1,0x1
    80002d98:	972e                	add	a4,a4,a1
    80002d9a:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002d9c:	6d38                	ld	a4,88(a0)
    80002d9e:	00000617          	auipc	a2,0x0
    80002da2:	13060613          	addi	a2,a2,304 # 80002ece <usertrap>
    80002da6:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp(); // hartid for cpuid()
    80002da8:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002daa:	8612                	mv	a2,tp
    80002dac:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dae:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.

  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002db2:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002db6:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002dba:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002dbe:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002dc0:	6f18                	ld	a4,24(a4)
    80002dc2:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002dc6:	6928                	ld	a0,80(a0)
    80002dc8:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002dca:	00004717          	auipc	a4,0x4
    80002dce:	2d270713          	addi	a4,a4,722 # 8000709c <userret>
    80002dd2:	8f15                	sub	a4,a4,a3
    80002dd4:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002dd6:	577d                	li	a4,-1
    80002dd8:	177e                	slli	a4,a4,0x3f
    80002dda:	8d59                	or	a0,a0,a4
    80002ddc:	9782                	jalr	a5
}
    80002dde:	60a2                	ld	ra,8(sp)
    80002de0:	6402                	ld	s0,0(sp)
    80002de2:	0141                	addi	sp,sp,16
    80002de4:	8082                	ret

0000000080002de6 <clockintr>:
  w_sepc(sepc);
  w_sstatus(sstatus);
}

void clockintr()
{
    80002de6:	1101                	addi	sp,sp,-32
    80002de8:	ec06                	sd	ra,24(sp)
    80002dea:	e822                	sd	s0,16(sp)
    80002dec:	e426                	sd	s1,8(sp)
    80002dee:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002df0:	00014497          	auipc	s1,0x14
    80002df4:	d9048493          	addi	s1,s1,-624 # 80016b80 <tickslock>
    80002df8:	8526                	mv	a0,s1
    80002dfa:	ffffe097          	auipc	ra,0xffffe
    80002dfe:	ea4080e7          	jalr	-348(ra) # 80000c9e <acquire>
  ticks++;
    80002e02:	00006517          	auipc	a0,0x6
    80002e06:	cde50513          	addi	a0,a0,-802 # 80008ae0 <ticks>
    80002e0a:	411c                	lw	a5,0(a0)
    80002e0c:	2785                	addiw	a5,a5,1
    80002e0e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	772080e7          	jalr	1906(ra) # 80002582 <wakeup>
  release(&tickslock);
    80002e18:	8526                	mv	a0,s1
    80002e1a:	ffffe097          	auipc	ra,0xffffe
    80002e1e:	f38080e7          	jalr	-200(ra) # 80000d52 <release>
}
    80002e22:	60e2                	ld	ra,24(sp)
    80002e24:	6442                	ld	s0,16(sp)
    80002e26:	64a2                	ld	s1,8(sp)
    80002e28:	6105                	addi	sp,sp,32
    80002e2a:	8082                	ret

0000000080002e2c <devintr>:
// and handle it.
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int devintr()
{
    80002e2c:	1101                	addi	sp,sp,-32
    80002e2e:	ec06                	sd	ra,24(sp)
    80002e30:	e822                	sd	s0,16(sp)
    80002e32:	e426                	sd	s1,8(sp)
    80002e34:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002e36:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if ((scause & 0x8000000000000000L) &&
    80002e3a:	00074d63          	bltz	a4,80002e54 <devintr+0x28>
    if (irq)
      plic_complete(irq);

    return 1;
  }
  else if (scause == 0x8000000000000001L)
    80002e3e:	57fd                	li	a5,-1
    80002e40:	17fe                	slli	a5,a5,0x3f
    80002e42:	0785                	addi	a5,a5,1

    return 2;
  }
  else
  {
    return 0;
    80002e44:	4501                	li	a0,0
  else if (scause == 0x8000000000000001L)
    80002e46:	06f70363          	beq	a4,a5,80002eac <devintr+0x80>
  }
}
    80002e4a:	60e2                	ld	ra,24(sp)
    80002e4c:	6442                	ld	s0,16(sp)
    80002e4e:	64a2                	ld	s1,8(sp)
    80002e50:	6105                	addi	sp,sp,32
    80002e52:	8082                	ret
      (scause & 0xff) == 9)
    80002e54:	0ff77793          	zext.b	a5,a4
  if ((scause & 0x8000000000000000L) &&
    80002e58:	46a5                	li	a3,9
    80002e5a:	fed792e3          	bne	a5,a3,80002e3e <devintr+0x12>
    int irq = plic_claim();
    80002e5e:	00003097          	auipc	ra,0x3
    80002e62:	5ca080e7          	jalr	1482(ra) # 80006428 <plic_claim>
    80002e66:	84aa                	mv	s1,a0
    if (irq == UART0_IRQ)
    80002e68:	47a9                	li	a5,10
    80002e6a:	02f50763          	beq	a0,a5,80002e98 <devintr+0x6c>
    else if (irq == VIRTIO0_IRQ)
    80002e6e:	4785                	li	a5,1
    80002e70:	02f50963          	beq	a0,a5,80002ea2 <devintr+0x76>
    return 1;
    80002e74:	4505                	li	a0,1
    else if (irq)
    80002e76:	d8f1                	beqz	s1,80002e4a <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80002e78:	85a6                	mv	a1,s1
    80002e7a:	00005517          	auipc	a0,0x5
    80002e7e:	5de50513          	addi	a0,a0,1502 # 80008458 <states.0+0x38>
    80002e82:	ffffd097          	auipc	ra,0xffffd
    80002e86:	71a080e7          	jalr	1818(ra) # 8000059c <printf>
      plic_complete(irq);
    80002e8a:	8526                	mv	a0,s1
    80002e8c:	00003097          	auipc	ra,0x3
    80002e90:	5c0080e7          	jalr	1472(ra) # 8000644c <plic_complete>
    return 1;
    80002e94:	4505                	li	a0,1
    80002e96:	bf55                	j	80002e4a <devintr+0x1e>
      uartintr();
    80002e98:	ffffe097          	auipc	ra,0xffffe
    80002e9c:	b12080e7          	jalr	-1262(ra) # 800009aa <uartintr>
    80002ea0:	b7ed                	j	80002e8a <devintr+0x5e>
      virtio_disk_intr();
    80002ea2:	00004097          	auipc	ra,0x4
    80002ea6:	a72080e7          	jalr	-1422(ra) # 80006914 <virtio_disk_intr>
    80002eaa:	b7c5                	j	80002e8a <devintr+0x5e>
    if (cpuid() == 0)
    80002eac:	fffff097          	auipc	ra,0xfffff
    80002eb0:	d58080e7          	jalr	-680(ra) # 80001c04 <cpuid>
    80002eb4:	c901                	beqz	a0,80002ec4 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002eb6:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002eba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ebc:	14479073          	csrw	sip,a5
    return 2;
    80002ec0:	4509                	li	a0,2
    80002ec2:	b761                	j	80002e4a <devintr+0x1e>
      clockintr();
    80002ec4:	00000097          	auipc	ra,0x0
    80002ec8:	f22080e7          	jalr	-222(ra) # 80002de6 <clockintr>
    80002ecc:	b7ed                	j	80002eb6 <devintr+0x8a>

0000000080002ece <usertrap>:
{
    80002ece:	7179                	addi	sp,sp,-48
    80002ed0:	f406                	sd	ra,40(sp)
    80002ed2:	f022                	sd	s0,32(sp)
    80002ed4:	ec26                	sd	s1,24(sp)
    80002ed6:	e84a                	sd	s2,16(sp)
    80002ed8:	e44e                	sd	s3,8(sp)
    80002eda:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002edc:	100027f3          	csrr	a5,sstatus
  if ((r_sstatus() & SSTATUS_SPP) != 0)
    80002ee0:	1007f793          	andi	a5,a5,256
    80002ee4:	e7b1                	bnez	a5,80002f30 <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002ee6:	00003797          	auipc	a5,0x3
    80002eea:	43a78793          	addi	a5,a5,1082 # 80006320 <kernelvec>
    80002eee:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002ef2:	fffff097          	auipc	ra,0xfffff
    80002ef6:	d3e080e7          	jalr	-706(ra) # 80001c30 <myproc>
    80002efa:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002efc:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002efe:	14102773          	csrr	a4,sepc
    80002f02:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002f04:	142029f3          	csrr	s3,scause
  if (scause == 8)
    80002f08:	47a1                	li	a5,8
    80002f0a:	02f99b63          	bne	s3,a5,80002f40 <usertrap+0x72>
  if (killed(p))
    80002f0e:	8526                	mv	a0,s1
    80002f10:	00000097          	auipc	ra,0x0
    80002f14:	8b6080e7          	jalr	-1866(ra) # 800027c6 <killed>
    80002f18:	e555                	bnez	a0,80002fc4 <usertrap+0xf6>
  usertrapret();
    80002f1a:	00000097          	auipc	ra,0x0
    80002f1e:	e36080e7          	jalr	-458(ra) # 80002d50 <usertrapret>
}
    80002f22:	70a2                	ld	ra,40(sp)
    80002f24:	7402                	ld	s0,32(sp)
    80002f26:	64e2                	ld	s1,24(sp)
    80002f28:	6942                	ld	s2,16(sp)
    80002f2a:	69a2                	ld	s3,8(sp)
    80002f2c:	6145                	addi	sp,sp,48
    80002f2e:	8082                	ret
    panic("usertrap: not from user mode");
    80002f30:	00005517          	auipc	a0,0x5
    80002f34:	54850513          	addi	a0,a0,1352 # 80008478 <states.0+0x58>
    80002f38:	ffffd097          	auipc	ra,0xffffd
    80002f3c:	608080e7          	jalr	1544(ra) # 80000540 <panic>
  else if ((which_dev = devintr()) != 0)
    80002f40:	00000097          	auipc	ra,0x0
    80002f44:	eec080e7          	jalr	-276(ra) # 80002e2c <devintr>
    80002f48:	892a                	mv	s2,a0
    80002f4a:	e535                	bnez	a0,80002fb6 <usertrap+0xe8>
  else if (scause == 15)
    80002f4c:	47bd                	li	a5,15
    80002f4e:	02f98e63          	beq	s3,a5,80002f8a <usertrap+0xbc>
    printf("usertrap(): unexpected scause %p pid=%d\n", scause, p->pid);
    80002f52:	5890                	lw	a2,48(s1)
    80002f54:	85ce                	mv	a1,s3
    80002f56:	00005517          	auipc	a0,0x5
    80002f5a:	57a50513          	addi	a0,a0,1402 # 800084d0 <states.0+0xb0>
    80002f5e:	ffffd097          	auipc	ra,0xffffd
    80002f62:	63e080e7          	jalr	1598(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002f66:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002f6a:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002f6e:	00005517          	auipc	a0,0x5
    80002f72:	59250513          	addi	a0,a0,1426 # 80008500 <states.0+0xe0>
    80002f76:	ffffd097          	auipc	ra,0xffffd
    80002f7a:	626080e7          	jalr	1574(ra) # 8000059c <printf>
    setkilled(p);
    80002f7e:	8526                	mv	a0,s1
    80002f80:	00000097          	auipc	ra,0x0
    80002f84:	81a080e7          	jalr	-2022(ra) # 8000279a <setkilled>
    80002f88:	b759                	j	80002f0e <usertrap+0x40>
    80002f8a:	14302573          	csrr	a0,stval
    if (handle_cow_fault(faulting_address) != 0)
    80002f8e:	00000097          	auipc	ra,0x0
    80002f92:	d02080e7          	jalr	-766(ra) # 80002c90 <handle_cow_fault>
    80002f96:	dd25                	beqz	a0,80002f0e <usertrap+0x40>
      printf("usertrap(): page fault handling failed for pid=%d\n", p->pid);
    80002f98:	588c                	lw	a1,48(s1)
    80002f9a:	00005517          	auipc	a0,0x5
    80002f9e:	4fe50513          	addi	a0,a0,1278 # 80008498 <states.0+0x78>
    80002fa2:	ffffd097          	auipc	ra,0xffffd
    80002fa6:	5fa080e7          	jalr	1530(ra) # 8000059c <printf>
      setkilled(p);
    80002faa:	8526                	mv	a0,s1
    80002fac:	fffff097          	auipc	ra,0xfffff
    80002fb0:	7ee080e7          	jalr	2030(ra) # 8000279a <setkilled>
    80002fb4:	bfa9                	j	80002f0e <usertrap+0x40>
  if (killed(p))
    80002fb6:	8526                	mv	a0,s1
    80002fb8:	00000097          	auipc	ra,0x0
    80002fbc:	80e080e7          	jalr	-2034(ra) # 800027c6 <killed>
    80002fc0:	c901                	beqz	a0,80002fd0 <usertrap+0x102>
    80002fc2:	a011                	j	80002fc6 <usertrap+0xf8>
    80002fc4:	4901                	li	s2,0
    exit(-1);
    80002fc6:	557d                	li	a0,-1
    80002fc8:	fffff097          	auipc	ra,0xfffff
    80002fcc:	68a080e7          	jalr	1674(ra) # 80002652 <exit>
  if (which_dev == 2)
    80002fd0:	4789                	li	a5,2
    80002fd2:	f4f914e3          	bne	s2,a5,80002f1a <usertrap+0x4c>
    yield();
    80002fd6:	fffff097          	auipc	ra,0xfffff
    80002fda:	50c080e7          	jalr	1292(ra) # 800024e2 <yield>
    80002fde:	bf35                	j	80002f1a <usertrap+0x4c>

0000000080002fe0 <kerneltrap>:
{
    80002fe0:	7179                	addi	sp,sp,-48
    80002fe2:	f406                	sd	ra,40(sp)
    80002fe4:	f022                	sd	s0,32(sp)
    80002fe6:	ec26                	sd	s1,24(sp)
    80002fe8:	e84a                	sd	s2,16(sp)
    80002fea:	e44e                	sd	s3,8(sp)
    80002fec:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002fee:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ff2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002ff6:	142029f3          	csrr	s3,scause
  if ((sstatus & SSTATUS_SPP) == 0)
    80002ffa:	1004f793          	andi	a5,s1,256
    80002ffe:	cb85                	beqz	a5,8000302e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80003000:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80003004:	8b89                	andi	a5,a5,2
  if (intr_get() != 0)
    80003006:	ef85                	bnez	a5,8000303e <kerneltrap+0x5e>
  if ((which_dev = devintr()) == 0)
    80003008:	00000097          	auipc	ra,0x0
    8000300c:	e24080e7          	jalr	-476(ra) # 80002e2c <devintr>
    80003010:	cd1d                	beqz	a0,8000304e <kerneltrap+0x6e>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003012:	4789                	li	a5,2
    80003014:	06f50a63          	beq	a0,a5,80003088 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80003018:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000301c:	10049073          	csrw	sstatus,s1
}
    80003020:	70a2                	ld	ra,40(sp)
    80003022:	7402                	ld	s0,32(sp)
    80003024:	64e2                	ld	s1,24(sp)
    80003026:	6942                	ld	s2,16(sp)
    80003028:	69a2                	ld	s3,8(sp)
    8000302a:	6145                	addi	sp,sp,48
    8000302c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000302e:	00005517          	auipc	a0,0x5
    80003032:	4f250513          	addi	a0,a0,1266 # 80008520 <states.0+0x100>
    80003036:	ffffd097          	auipc	ra,0xffffd
    8000303a:	50a080e7          	jalr	1290(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    8000303e:	00005517          	auipc	a0,0x5
    80003042:	50a50513          	addi	a0,a0,1290 # 80008548 <states.0+0x128>
    80003046:	ffffd097          	auipc	ra,0xffffd
    8000304a:	4fa080e7          	jalr	1274(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    8000304e:	85ce                	mv	a1,s3
    80003050:	00005517          	auipc	a0,0x5
    80003054:	51850513          	addi	a0,a0,1304 # 80008568 <states.0+0x148>
    80003058:	ffffd097          	auipc	ra,0xffffd
    8000305c:	544080e7          	jalr	1348(ra) # 8000059c <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80003060:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80003064:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80003068:	00005517          	auipc	a0,0x5
    8000306c:	51050513          	addi	a0,a0,1296 # 80008578 <states.0+0x158>
    80003070:	ffffd097          	auipc	ra,0xffffd
    80003074:	52c080e7          	jalr	1324(ra) # 8000059c <printf>
    panic("kerneltrap");
    80003078:	00005517          	auipc	a0,0x5
    8000307c:	51850513          	addi	a0,a0,1304 # 80008590 <states.0+0x170>
    80003080:	ffffd097          	auipc	ra,0xffffd
    80003084:	4c0080e7          	jalr	1216(ra) # 80000540 <panic>
  if (which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80003088:	fffff097          	auipc	ra,0xfffff
    8000308c:	ba8080e7          	jalr	-1112(ra) # 80001c30 <myproc>
    80003090:	d541                	beqz	a0,80003018 <kerneltrap+0x38>
    80003092:	fffff097          	auipc	ra,0xfffff
    80003096:	b9e080e7          	jalr	-1122(ra) # 80001c30 <myproc>
    8000309a:	4d18                	lw	a4,24(a0)
    8000309c:	4791                	li	a5,4
    8000309e:	f6f71de3          	bne	a4,a5,80003018 <kerneltrap+0x38>
    yield();
    800030a2:	fffff097          	auipc	ra,0xfffff
    800030a6:	440080e7          	jalr	1088(ra) # 800024e2 <yield>
    800030aa:	b7bd                	j	80003018 <kerneltrap+0x38>

00000000800030ac <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    800030ac:	1101                	addi	sp,sp,-32
    800030ae:	ec06                	sd	ra,24(sp)
    800030b0:	e822                	sd	s0,16(sp)
    800030b2:	e426                	sd	s1,8(sp)
    800030b4:	1000                	addi	s0,sp,32
    800030b6:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    800030b8:	fffff097          	auipc	ra,0xfffff
    800030bc:	b78080e7          	jalr	-1160(ra) # 80001c30 <myproc>
    switch (n)
    800030c0:	4795                	li	a5,5
    800030c2:	0497e163          	bltu	a5,s1,80003104 <argraw+0x58>
    800030c6:	048a                	slli	s1,s1,0x2
    800030c8:	00005717          	auipc	a4,0x5
    800030cc:	50070713          	addi	a4,a4,1280 # 800085c8 <states.0+0x1a8>
    800030d0:	94ba                	add	s1,s1,a4
    800030d2:	409c                	lw	a5,0(s1)
    800030d4:	97ba                	add	a5,a5,a4
    800030d6:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    800030d8:	6d3c                	ld	a5,88(a0)
    800030da:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    800030dc:	60e2                	ld	ra,24(sp)
    800030de:	6442                	ld	s0,16(sp)
    800030e0:	64a2                	ld	s1,8(sp)
    800030e2:	6105                	addi	sp,sp,32
    800030e4:	8082                	ret
        return p->trapframe->a1;
    800030e6:	6d3c                	ld	a5,88(a0)
    800030e8:	7fa8                	ld	a0,120(a5)
    800030ea:	bfcd                	j	800030dc <argraw+0x30>
        return p->trapframe->a2;
    800030ec:	6d3c                	ld	a5,88(a0)
    800030ee:	63c8                	ld	a0,128(a5)
    800030f0:	b7f5                	j	800030dc <argraw+0x30>
        return p->trapframe->a3;
    800030f2:	6d3c                	ld	a5,88(a0)
    800030f4:	67c8                	ld	a0,136(a5)
    800030f6:	b7dd                	j	800030dc <argraw+0x30>
        return p->trapframe->a4;
    800030f8:	6d3c                	ld	a5,88(a0)
    800030fa:	6bc8                	ld	a0,144(a5)
    800030fc:	b7c5                	j	800030dc <argraw+0x30>
        return p->trapframe->a5;
    800030fe:	6d3c                	ld	a5,88(a0)
    80003100:	6fc8                	ld	a0,152(a5)
    80003102:	bfe9                	j	800030dc <argraw+0x30>
    panic("argraw");
    80003104:	00005517          	auipc	a0,0x5
    80003108:	49c50513          	addi	a0,a0,1180 # 800085a0 <states.0+0x180>
    8000310c:	ffffd097          	auipc	ra,0xffffd
    80003110:	434080e7          	jalr	1076(ra) # 80000540 <panic>

0000000080003114 <fetchaddr>:
{
    80003114:	1101                	addi	sp,sp,-32
    80003116:	ec06                	sd	ra,24(sp)
    80003118:	e822                	sd	s0,16(sp)
    8000311a:	e426                	sd	s1,8(sp)
    8000311c:	e04a                	sd	s2,0(sp)
    8000311e:	1000                	addi	s0,sp,32
    80003120:	84aa                	mv	s1,a0
    80003122:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80003124:	fffff097          	auipc	ra,0xfffff
    80003128:	b0c080e7          	jalr	-1268(ra) # 80001c30 <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000312c:	653c                	ld	a5,72(a0)
    8000312e:	02f4f863          	bgeu	s1,a5,8000315e <fetchaddr+0x4a>
    80003132:	00848713          	addi	a4,s1,8
    80003136:	02e7e663          	bltu	a5,a4,80003162 <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    8000313a:	46a1                	li	a3,8
    8000313c:	8626                	mv	a2,s1
    8000313e:	85ca                	mv	a1,s2
    80003140:	6928                	ld	a0,80(a0)
    80003142:	ffffe097          	auipc	ra,0xffffe
    80003146:	73c080e7          	jalr	1852(ra) # 8000187e <copyin>
    8000314a:	00a03533          	snez	a0,a0
    8000314e:	40a00533          	neg	a0,a0
}
    80003152:	60e2                	ld	ra,24(sp)
    80003154:	6442                	ld	s0,16(sp)
    80003156:	64a2                	ld	s1,8(sp)
    80003158:	6902                	ld	s2,0(sp)
    8000315a:	6105                	addi	sp,sp,32
    8000315c:	8082                	ret
        return -1;
    8000315e:	557d                	li	a0,-1
    80003160:	bfcd                	j	80003152 <fetchaddr+0x3e>
    80003162:	557d                	li	a0,-1
    80003164:	b7fd                	j	80003152 <fetchaddr+0x3e>

0000000080003166 <fetchstr>:
{
    80003166:	7179                	addi	sp,sp,-48
    80003168:	f406                	sd	ra,40(sp)
    8000316a:	f022                	sd	s0,32(sp)
    8000316c:	ec26                	sd	s1,24(sp)
    8000316e:	e84a                	sd	s2,16(sp)
    80003170:	e44e                	sd	s3,8(sp)
    80003172:	1800                	addi	s0,sp,48
    80003174:	892a                	mv	s2,a0
    80003176:	84ae                	mv	s1,a1
    80003178:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    8000317a:	fffff097          	auipc	ra,0xfffff
    8000317e:	ab6080e7          	jalr	-1354(ra) # 80001c30 <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80003182:	86ce                	mv	a3,s3
    80003184:	864a                	mv	a2,s2
    80003186:	85a6                	mv	a1,s1
    80003188:	6928                	ld	a0,80(a0)
    8000318a:	ffffe097          	auipc	ra,0xffffe
    8000318e:	782080e7          	jalr	1922(ra) # 8000190c <copyinstr>
    80003192:	00054e63          	bltz	a0,800031ae <fetchstr+0x48>
    return strlen(buf);
    80003196:	8526                	mv	a0,s1
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	d7e080e7          	jalr	-642(ra) # 80000f16 <strlen>
}
    800031a0:	70a2                	ld	ra,40(sp)
    800031a2:	7402                	ld	s0,32(sp)
    800031a4:	64e2                	ld	s1,24(sp)
    800031a6:	6942                	ld	s2,16(sp)
    800031a8:	69a2                	ld	s3,8(sp)
    800031aa:	6145                	addi	sp,sp,48
    800031ac:	8082                	ret
        return -1;
    800031ae:	557d                	li	a0,-1
    800031b0:	bfc5                	j	800031a0 <fetchstr+0x3a>

00000000800031b2 <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    800031b2:	1101                	addi	sp,sp,-32
    800031b4:	ec06                	sd	ra,24(sp)
    800031b6:	e822                	sd	s0,16(sp)
    800031b8:	e426                	sd	s1,8(sp)
    800031ba:	1000                	addi	s0,sp,32
    800031bc:	84ae                	mv	s1,a1
    *ip = argraw(n);
    800031be:	00000097          	auipc	ra,0x0
    800031c2:	eee080e7          	jalr	-274(ra) # 800030ac <argraw>
    800031c6:	c088                	sw	a0,0(s1)
}
    800031c8:	60e2                	ld	ra,24(sp)
    800031ca:	6442                	ld	s0,16(sp)
    800031cc:	64a2                	ld	s1,8(sp)
    800031ce:	6105                	addi	sp,sp,32
    800031d0:	8082                	ret

00000000800031d2 <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    800031d2:	1101                	addi	sp,sp,-32
    800031d4:	ec06                	sd	ra,24(sp)
    800031d6:	e822                	sd	s0,16(sp)
    800031d8:	e426                	sd	s1,8(sp)
    800031da:	1000                	addi	s0,sp,32
    800031dc:	84ae                	mv	s1,a1
    *ip = argraw(n);
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	ece080e7          	jalr	-306(ra) # 800030ac <argraw>
    800031e6:	e088                	sd	a0,0(s1)
}
    800031e8:	60e2                	ld	ra,24(sp)
    800031ea:	6442                	ld	s0,16(sp)
    800031ec:	64a2                	ld	s1,8(sp)
    800031ee:	6105                	addi	sp,sp,32
    800031f0:	8082                	ret

00000000800031f2 <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    800031f2:	7179                	addi	sp,sp,-48
    800031f4:	f406                	sd	ra,40(sp)
    800031f6:	f022                	sd	s0,32(sp)
    800031f8:	ec26                	sd	s1,24(sp)
    800031fa:	e84a                	sd	s2,16(sp)
    800031fc:	1800                	addi	s0,sp,48
    800031fe:	84ae                	mv	s1,a1
    80003200:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80003202:	fd840593          	addi	a1,s0,-40
    80003206:	00000097          	auipc	ra,0x0
    8000320a:	fcc080e7          	jalr	-52(ra) # 800031d2 <argaddr>
    return fetchstr(addr, buf, max);
    8000320e:	864a                	mv	a2,s2
    80003210:	85a6                	mv	a1,s1
    80003212:	fd843503          	ld	a0,-40(s0)
    80003216:	00000097          	auipc	ra,0x0
    8000321a:	f50080e7          	jalr	-176(ra) # 80003166 <fetchstr>
}
    8000321e:	70a2                	ld	ra,40(sp)
    80003220:	7402                	ld	s0,32(sp)
    80003222:	64e2                	ld	s1,24(sp)
    80003224:	6942                	ld	s2,16(sp)
    80003226:	6145                	addi	sp,sp,48
    80003228:	8082                	ret

000000008000322a <syscall>:
    [SYS_va2pa] sys_va2pa,
    [SYS_vfork] sys_vfork,
};

void syscall(void)
{
    8000322a:	1101                	addi	sp,sp,-32
    8000322c:	ec06                	sd	ra,24(sp)
    8000322e:	e822                	sd	s0,16(sp)
    80003230:	e426                	sd	s1,8(sp)
    80003232:	e04a                	sd	s2,0(sp)
    80003234:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80003236:	fffff097          	auipc	ra,0xfffff
    8000323a:	9fa080e7          	jalr	-1542(ra) # 80001c30 <myproc>
    8000323e:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    80003240:	05853903          	ld	s2,88(a0)
    80003244:	0a893783          	ld	a5,168(s2)
    80003248:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    8000324c:	37fd                	addiw	a5,a5,-1
    8000324e:	4765                	li	a4,25
    80003250:	00f76f63          	bltu	a4,a5,8000326e <syscall+0x44>
    80003254:	00369713          	slli	a4,a3,0x3
    80003258:	00005797          	auipc	a5,0x5
    8000325c:	38878793          	addi	a5,a5,904 # 800085e0 <syscalls>
    80003260:	97ba                	add	a5,a5,a4
    80003262:	639c                	ld	a5,0(a5)
    80003264:	c789                	beqz	a5,8000326e <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003266:	9782                	jalr	a5
    80003268:	06a93823          	sd	a0,112(s2)
    8000326c:	a839                	j	8000328a <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    8000326e:	15848613          	addi	a2,s1,344
    80003272:	588c                	lw	a1,48(s1)
    80003274:	00005517          	auipc	a0,0x5
    80003278:	33450513          	addi	a0,a0,820 # 800085a8 <states.0+0x188>
    8000327c:	ffffd097          	auipc	ra,0xffffd
    80003280:	320080e7          	jalr	800(ra) # 8000059c <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    80003284:	6cbc                	ld	a5,88(s1)
    80003286:	577d                	li	a4,-1
    80003288:	fbb8                	sd	a4,112(a5)
    }
}
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	64a2                	ld	s1,8(sp)
    80003290:	6902                	ld	s2,0(sp)
    80003292:	6105                	addi	sp,sp,32
    80003294:	8082                	ret

0000000080003296 <sys_exit>:

extern uint64 FREE_PAGES; // kalloc.c keeps track of those

uint64
sys_exit(void)
{
    80003296:	1101                	addi	sp,sp,-32
    80003298:	ec06                	sd	ra,24(sp)
    8000329a:	e822                	sd	s0,16(sp)
    8000329c:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    8000329e:	fec40593          	addi	a1,s0,-20
    800032a2:	4501                	li	a0,0
    800032a4:	00000097          	auipc	ra,0x0
    800032a8:	f0e080e7          	jalr	-242(ra) # 800031b2 <argint>
    exit(n);
    800032ac:	fec42503          	lw	a0,-20(s0)
    800032b0:	fffff097          	auipc	ra,0xfffff
    800032b4:	3a2080e7          	jalr	930(ra) # 80002652 <exit>
    return 0; // not reached
}
    800032b8:	4501                	li	a0,0
    800032ba:	60e2                	ld	ra,24(sp)
    800032bc:	6442                	ld	s0,16(sp)
    800032be:	6105                	addi	sp,sp,32
    800032c0:	8082                	ret

00000000800032c2 <sys_getpid>:

uint64
sys_getpid(void)
{
    800032c2:	1141                	addi	sp,sp,-16
    800032c4:	e406                	sd	ra,8(sp)
    800032c6:	e022                	sd	s0,0(sp)
    800032c8:	0800                	addi	s0,sp,16
    return myproc()->pid;
    800032ca:	fffff097          	auipc	ra,0xfffff
    800032ce:	966080e7          	jalr	-1690(ra) # 80001c30 <myproc>
}
    800032d2:	5908                	lw	a0,48(a0)
    800032d4:	60a2                	ld	ra,8(sp)
    800032d6:	6402                	ld	s0,0(sp)
    800032d8:	0141                	addi	sp,sp,16
    800032da:	8082                	ret

00000000800032dc <sys_fork>:

uint64
sys_fork(void)
{
    800032dc:	1141                	addi	sp,sp,-16
    800032de:	e406                	sd	ra,8(sp)
    800032e0:	e022                	sd	s0,0(sp)
    800032e2:	0800                	addi	s0,sp,16
    return fork();
    800032e4:	fffff097          	auipc	ra,0xfffff
    800032e8:	e98080e7          	jalr	-360(ra) # 8000217c <fork>
}
    800032ec:	60a2                	ld	ra,8(sp)
    800032ee:	6402                	ld	s0,0(sp)
    800032f0:	0141                	addi	sp,sp,16
    800032f2:	8082                	ret

00000000800032f4 <sys_vfork>:
uint64
sys_vfork(void)
{
    800032f4:	1141                	addi	sp,sp,-16
    800032f6:	e406                	sd	ra,8(sp)
    800032f8:	e022                	sd	s0,0(sp)
    800032fa:	0800                	addi	s0,sp,16
    return vfork();
    800032fc:	fffff097          	auipc	ra,0xfffff
    80003300:	fc0080e7          	jalr	-64(ra) # 800022bc <vfork>
}
    80003304:	60a2                	ld	ra,8(sp)
    80003306:	6402                	ld	s0,0(sp)
    80003308:	0141                	addi	sp,sp,16
    8000330a:	8082                	ret

000000008000330c <sys_wait>:

uint64
sys_wait(void)
{
    8000330c:	1101                	addi	sp,sp,-32
    8000330e:	ec06                	sd	ra,24(sp)
    80003310:	e822                	sd	s0,16(sp)
    80003312:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    80003314:	fe840593          	addi	a1,s0,-24
    80003318:	4501                	li	a0,0
    8000331a:	00000097          	auipc	ra,0x0
    8000331e:	eb8080e7          	jalr	-328(ra) # 800031d2 <argaddr>
    return wait(p);
    80003322:	fe843503          	ld	a0,-24(s0)
    80003326:	fffff097          	auipc	ra,0xfffff
    8000332a:	4d2080e7          	jalr	1234(ra) # 800027f8 <wait>
}
    8000332e:	60e2                	ld	ra,24(sp)
    80003330:	6442                	ld	s0,16(sp)
    80003332:	6105                	addi	sp,sp,32
    80003334:	8082                	ret

0000000080003336 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003336:	7179                	addi	sp,sp,-48
    80003338:	f406                	sd	ra,40(sp)
    8000333a:	f022                	sd	s0,32(sp)
    8000333c:	ec26                	sd	s1,24(sp)
    8000333e:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003340:	fdc40593          	addi	a1,s0,-36
    80003344:	4501                	li	a0,0
    80003346:	00000097          	auipc	ra,0x0
    8000334a:	e6c080e7          	jalr	-404(ra) # 800031b2 <argint>
    addr = myproc()->sz;
    8000334e:	fffff097          	auipc	ra,0xfffff
    80003352:	8e2080e7          	jalr	-1822(ra) # 80001c30 <myproc>
    80003356:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    80003358:	fdc42503          	lw	a0,-36(s0)
    8000335c:	fffff097          	auipc	ra,0xfffff
    80003360:	c2e080e7          	jalr	-978(ra) # 80001f8a <growproc>
    80003364:	00054863          	bltz	a0,80003374 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    80003368:	8526                	mv	a0,s1
    8000336a:	70a2                	ld	ra,40(sp)
    8000336c:	7402                	ld	s0,32(sp)
    8000336e:	64e2                	ld	s1,24(sp)
    80003370:	6145                	addi	sp,sp,48
    80003372:	8082                	ret
        return -1;
    80003374:	54fd                	li	s1,-1
    80003376:	bfcd                	j	80003368 <sys_sbrk+0x32>

0000000080003378 <sys_sleep>:

uint64
sys_sleep(void)
{
    80003378:	7139                	addi	sp,sp,-64
    8000337a:	fc06                	sd	ra,56(sp)
    8000337c:	f822                	sd	s0,48(sp)
    8000337e:	f426                	sd	s1,40(sp)
    80003380:	f04a                	sd	s2,32(sp)
    80003382:	ec4e                	sd	s3,24(sp)
    80003384:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003386:	fcc40593          	addi	a1,s0,-52
    8000338a:	4501                	li	a0,0
    8000338c:	00000097          	auipc	ra,0x0
    80003390:	e26080e7          	jalr	-474(ra) # 800031b2 <argint>
    acquire(&tickslock);
    80003394:	00013517          	auipc	a0,0x13
    80003398:	7ec50513          	addi	a0,a0,2028 # 80016b80 <tickslock>
    8000339c:	ffffe097          	auipc	ra,0xffffe
    800033a0:	902080e7          	jalr	-1790(ra) # 80000c9e <acquire>
    ticks0 = ticks;
    800033a4:	00005917          	auipc	s2,0x5
    800033a8:	73c92903          	lw	s2,1852(s2) # 80008ae0 <ticks>
    while (ticks - ticks0 < n)
    800033ac:	fcc42783          	lw	a5,-52(s0)
    800033b0:	cf9d                	beqz	a5,800033ee <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    800033b2:	00013997          	auipc	s3,0x13
    800033b6:	7ce98993          	addi	s3,s3,1998 # 80016b80 <tickslock>
    800033ba:	00005497          	auipc	s1,0x5
    800033be:	72648493          	addi	s1,s1,1830 # 80008ae0 <ticks>
        if (killed(myproc()))
    800033c2:	fffff097          	auipc	ra,0xfffff
    800033c6:	86e080e7          	jalr	-1938(ra) # 80001c30 <myproc>
    800033ca:	fffff097          	auipc	ra,0xfffff
    800033ce:	3fc080e7          	jalr	1020(ra) # 800027c6 <killed>
    800033d2:	ed15                	bnez	a0,8000340e <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800033d4:	85ce                	mv	a1,s3
    800033d6:	8526                	mv	a0,s1
    800033d8:	fffff097          	auipc	ra,0xfffff
    800033dc:	146080e7          	jalr	326(ra) # 8000251e <sleep>
    while (ticks - ticks0 < n)
    800033e0:	409c                	lw	a5,0(s1)
    800033e2:	412787bb          	subw	a5,a5,s2
    800033e6:	fcc42703          	lw	a4,-52(s0)
    800033ea:	fce7ece3          	bltu	a5,a4,800033c2 <sys_sleep+0x4a>
    }
    release(&tickslock);
    800033ee:	00013517          	auipc	a0,0x13
    800033f2:	79250513          	addi	a0,a0,1938 # 80016b80 <tickslock>
    800033f6:	ffffe097          	auipc	ra,0xffffe
    800033fa:	95c080e7          	jalr	-1700(ra) # 80000d52 <release>
    return 0;
    800033fe:	4501                	li	a0,0
}
    80003400:	70e2                	ld	ra,56(sp)
    80003402:	7442                	ld	s0,48(sp)
    80003404:	74a2                	ld	s1,40(sp)
    80003406:	7902                	ld	s2,32(sp)
    80003408:	69e2                	ld	s3,24(sp)
    8000340a:	6121                	addi	sp,sp,64
    8000340c:	8082                	ret
            release(&tickslock);
    8000340e:	00013517          	auipc	a0,0x13
    80003412:	77250513          	addi	a0,a0,1906 # 80016b80 <tickslock>
    80003416:	ffffe097          	auipc	ra,0xffffe
    8000341a:	93c080e7          	jalr	-1732(ra) # 80000d52 <release>
            return -1;
    8000341e:	557d                	li	a0,-1
    80003420:	b7c5                	j	80003400 <sys_sleep+0x88>

0000000080003422 <sys_kill>:

uint64
sys_kill(void)
{
    80003422:	1101                	addi	sp,sp,-32
    80003424:	ec06                	sd	ra,24(sp)
    80003426:	e822                	sd	s0,16(sp)
    80003428:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    8000342a:	fec40593          	addi	a1,s0,-20
    8000342e:	4501                	li	a0,0
    80003430:	00000097          	auipc	ra,0x0
    80003434:	d82080e7          	jalr	-638(ra) # 800031b2 <argint>
    return kill(pid);
    80003438:	fec42503          	lw	a0,-20(s0)
    8000343c:	fffff097          	auipc	ra,0xfffff
    80003440:	2ec080e7          	jalr	748(ra) # 80002728 <kill>
}
    80003444:	60e2                	ld	ra,24(sp)
    80003446:	6442                	ld	s0,16(sp)
    80003448:	6105                	addi	sp,sp,32
    8000344a:	8082                	ret

000000008000344c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000344c:	1101                	addi	sp,sp,-32
    8000344e:	ec06                	sd	ra,24(sp)
    80003450:	e822                	sd	s0,16(sp)
    80003452:	e426                	sd	s1,8(sp)
    80003454:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003456:	00013517          	auipc	a0,0x13
    8000345a:	72a50513          	addi	a0,a0,1834 # 80016b80 <tickslock>
    8000345e:	ffffe097          	auipc	ra,0xffffe
    80003462:	840080e7          	jalr	-1984(ra) # 80000c9e <acquire>
    xticks = ticks;
    80003466:	00005497          	auipc	s1,0x5
    8000346a:	67a4a483          	lw	s1,1658(s1) # 80008ae0 <ticks>
    release(&tickslock);
    8000346e:	00013517          	auipc	a0,0x13
    80003472:	71250513          	addi	a0,a0,1810 # 80016b80 <tickslock>
    80003476:	ffffe097          	auipc	ra,0xffffe
    8000347a:	8dc080e7          	jalr	-1828(ra) # 80000d52 <release>
    return xticks;
}
    8000347e:	02049513          	slli	a0,s1,0x20
    80003482:	9101                	srli	a0,a0,0x20
    80003484:	60e2                	ld	ra,24(sp)
    80003486:	6442                	ld	s0,16(sp)
    80003488:	64a2                	ld	s1,8(sp)
    8000348a:	6105                	addi	sp,sp,32
    8000348c:	8082                	ret

000000008000348e <sys_ps>:

void *
sys_ps(void)
{
    8000348e:	1101                	addi	sp,sp,-32
    80003490:	ec06                	sd	ra,24(sp)
    80003492:	e822                	sd	s0,16(sp)
    80003494:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003496:	fe042623          	sw	zero,-20(s0)
    8000349a:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    8000349e:	fec40593          	addi	a1,s0,-20
    800034a2:	4501                	li	a0,0
    800034a4:	00000097          	auipc	ra,0x0
    800034a8:	d0e080e7          	jalr	-754(ra) # 800031b2 <argint>
    argint(1, &count);
    800034ac:	fe840593          	addi	a1,s0,-24
    800034b0:	4505                	li	a0,1
    800034b2:	00000097          	auipc	ra,0x0
    800034b6:	d00080e7          	jalr	-768(ra) # 800031b2 <argint>
    return ps((uint8)start, (uint8)count);
    800034ba:	fe844583          	lbu	a1,-24(s0)
    800034be:	fec44503          	lbu	a0,-20(s0)
    800034c2:	fffff097          	auipc	ra,0xfffff
    800034c6:	b24080e7          	jalr	-1244(ra) # 80001fe6 <ps>
}
    800034ca:	60e2                	ld	ra,24(sp)
    800034cc:	6442                	ld	s0,16(sp)
    800034ce:	6105                	addi	sp,sp,32
    800034d0:	8082                	ret

00000000800034d2 <sys_schedls>:

uint64 sys_schedls(void)
{
    800034d2:	1141                	addi	sp,sp,-16
    800034d4:	e406                	sd	ra,8(sp)
    800034d6:	e022                	sd	s0,0(sp)
    800034d8:	0800                	addi	s0,sp,16
    schedls();
    800034da:	fffff097          	auipc	ra,0xfffff
    800034de:	5a8080e7          	jalr	1448(ra) # 80002a82 <schedls>
    return 0;
}
    800034e2:	4501                	li	a0,0
    800034e4:	60a2                	ld	ra,8(sp)
    800034e6:	6402                	ld	s0,0(sp)
    800034e8:	0141                	addi	sp,sp,16
    800034ea:	8082                	ret

00000000800034ec <sys_schedset>:

uint64 sys_schedset(void)
{
    800034ec:	1101                	addi	sp,sp,-32
    800034ee:	ec06                	sd	ra,24(sp)
    800034f0:	e822                	sd	s0,16(sp)
    800034f2:	1000                	addi	s0,sp,32
    int id = 0;
    800034f4:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800034f8:	fec40593          	addi	a1,s0,-20
    800034fc:	4501                	li	a0,0
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	cb4080e7          	jalr	-844(ra) # 800031b2 <argint>
    schedset(id - 1);
    80003506:	fec42503          	lw	a0,-20(s0)
    8000350a:	357d                	addiw	a0,a0,-1
    8000350c:	fffff097          	auipc	ra,0xfffff
    80003510:	60c080e7          	jalr	1548(ra) # 80002b18 <schedset>
    return 0;
}
    80003514:	4501                	li	a0,0
    80003516:	60e2                	ld	ra,24(sp)
    80003518:	6442                	ld	s0,16(sp)
    8000351a:	6105                	addi	sp,sp,32
    8000351c:	8082                	ret

000000008000351e <sys_va2pa>:

uint64 sys_va2pa(void)
{
    8000351e:	1101                	addi	sp,sp,-32
    80003520:	ec06                	sd	ra,24(sp)
    80003522:	e822                	sd	s0,16(sp)
    80003524:	1000                	addi	s0,sp,32
    uint64 va = 0;
    80003526:	fe043423          	sd	zero,-24(s0)
    int pid = 0;
    8000352a:	fe042223          	sw	zero,-28(s0)
    argaddr(0, &va);
    8000352e:	fe840593          	addi	a1,s0,-24
    80003532:	4501                	li	a0,0
    80003534:	00000097          	auipc	ra,0x0
    80003538:	c9e080e7          	jalr	-866(ra) # 800031d2 <argaddr>
    argint(1, &pid);
    8000353c:	fe440593          	addi	a1,s0,-28
    80003540:	4505                	li	a0,1
    80003542:	00000097          	auipc	ra,0x0
    80003546:	c70080e7          	jalr	-912(ra) # 800031b2 <argint>
    return va2pa(va, pid);
    8000354a:	fe442583          	lw	a1,-28(s0)
    8000354e:	fe843503          	ld	a0,-24(s0)
    80003552:	fffff097          	auipc	ra,0xfffff
    80003556:	612080e7          	jalr	1554(ra) # 80002b64 <va2pa>
}
    8000355a:	60e2                	ld	ra,24(sp)
    8000355c:	6442                	ld	s0,16(sp)
    8000355e:	6105                	addi	sp,sp,32
    80003560:	8082                	ret

0000000080003562 <sys_pfreepages>:

uint64 sys_pfreepages(void)
{
    80003562:	1141                	addi	sp,sp,-16
    80003564:	e406                	sd	ra,8(sp)
    80003566:	e022                	sd	s0,0(sp)
    80003568:	0800                	addi	s0,sp,16
    printf("%d\n", FREE_PAGES);
    8000356a:	00005597          	auipc	a1,0x5
    8000356e:	54e5b583          	ld	a1,1358(a1) # 80008ab8 <FREE_PAGES>
    80003572:	00005517          	auipc	a0,0x5
    80003576:	04e50513          	addi	a0,a0,78 # 800085c0 <states.0+0x1a0>
    8000357a:	ffffd097          	auipc	ra,0xffffd
    8000357e:	022080e7          	jalr	34(ra) # 8000059c <printf>
    return 0;
    80003582:	4501                	li	a0,0
    80003584:	60a2                	ld	ra,8(sp)
    80003586:	6402                	ld	s0,0(sp)
    80003588:	0141                	addi	sp,sp,16
    8000358a:	8082                	ret

000000008000358c <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    8000358c:	7179                	addi	sp,sp,-48
    8000358e:	f406                	sd	ra,40(sp)
    80003590:	f022                	sd	s0,32(sp)
    80003592:	ec26                	sd	s1,24(sp)
    80003594:	e84a                	sd	s2,16(sp)
    80003596:	e44e                	sd	s3,8(sp)
    80003598:	e052                	sd	s4,0(sp)
    8000359a:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    8000359c:	00005597          	auipc	a1,0x5
    800035a0:	11c58593          	addi	a1,a1,284 # 800086b8 <syscalls+0xd8>
    800035a4:	00013517          	auipc	a0,0x13
    800035a8:	5f450513          	addi	a0,a0,1524 # 80016b98 <bcache>
    800035ac:	ffffd097          	auipc	ra,0xffffd
    800035b0:	662080e7          	jalr	1634(ra) # 80000c0e <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800035b4:	0001b797          	auipc	a5,0x1b
    800035b8:	5e478793          	addi	a5,a5,1508 # 8001eb98 <bcache+0x8000>
    800035bc:	0001c717          	auipc	a4,0x1c
    800035c0:	84470713          	addi	a4,a4,-1980 # 8001ee00 <bcache+0x8268>
    800035c4:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800035c8:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800035cc:	00013497          	auipc	s1,0x13
    800035d0:	5e448493          	addi	s1,s1,1508 # 80016bb0 <bcache+0x18>
    b->next = bcache.head.next;
    800035d4:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800035d6:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800035d8:	00005a17          	auipc	s4,0x5
    800035dc:	0e8a0a13          	addi	s4,s4,232 # 800086c0 <syscalls+0xe0>
    b->next = bcache.head.next;
    800035e0:	2b893783          	ld	a5,696(s2)
    800035e4:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800035e6:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800035ea:	85d2                	mv	a1,s4
    800035ec:	01048513          	addi	a0,s1,16
    800035f0:	00001097          	auipc	ra,0x1
    800035f4:	4c8080e7          	jalr	1224(ra) # 80004ab8 <initsleeplock>
    bcache.head.next->prev = b;
    800035f8:	2b893783          	ld	a5,696(s2)
    800035fc:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800035fe:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003602:	45848493          	addi	s1,s1,1112
    80003606:	fd349de3          	bne	s1,s3,800035e0 <binit+0x54>
  }
}
    8000360a:	70a2                	ld	ra,40(sp)
    8000360c:	7402                	ld	s0,32(sp)
    8000360e:	64e2                	ld	s1,24(sp)
    80003610:	6942                	ld	s2,16(sp)
    80003612:	69a2                	ld	s3,8(sp)
    80003614:	6a02                	ld	s4,0(sp)
    80003616:	6145                	addi	sp,sp,48
    80003618:	8082                	ret

000000008000361a <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000361a:	7179                	addi	sp,sp,-48
    8000361c:	f406                	sd	ra,40(sp)
    8000361e:	f022                	sd	s0,32(sp)
    80003620:	ec26                	sd	s1,24(sp)
    80003622:	e84a                	sd	s2,16(sp)
    80003624:	e44e                	sd	s3,8(sp)
    80003626:	1800                	addi	s0,sp,48
    80003628:	892a                	mv	s2,a0
    8000362a:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    8000362c:	00013517          	auipc	a0,0x13
    80003630:	56c50513          	addi	a0,a0,1388 # 80016b98 <bcache>
    80003634:	ffffd097          	auipc	ra,0xffffd
    80003638:	66a080e7          	jalr	1642(ra) # 80000c9e <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000363c:	0001c497          	auipc	s1,0x1c
    80003640:	8144b483          	ld	s1,-2028(s1) # 8001ee50 <bcache+0x82b8>
    80003644:	0001b797          	auipc	a5,0x1b
    80003648:	7bc78793          	addi	a5,a5,1980 # 8001ee00 <bcache+0x8268>
    8000364c:	02f48f63          	beq	s1,a5,8000368a <bread+0x70>
    80003650:	873e                	mv	a4,a5
    80003652:	a021                	j	8000365a <bread+0x40>
    80003654:	68a4                	ld	s1,80(s1)
    80003656:	02e48a63          	beq	s1,a4,8000368a <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    8000365a:	449c                	lw	a5,8(s1)
    8000365c:	ff279ce3          	bne	a5,s2,80003654 <bread+0x3a>
    80003660:	44dc                	lw	a5,12(s1)
    80003662:	ff3799e3          	bne	a5,s3,80003654 <bread+0x3a>
      b->refcnt++;
    80003666:	40bc                	lw	a5,64(s1)
    80003668:	2785                	addiw	a5,a5,1
    8000366a:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000366c:	00013517          	auipc	a0,0x13
    80003670:	52c50513          	addi	a0,a0,1324 # 80016b98 <bcache>
    80003674:	ffffd097          	auipc	ra,0xffffd
    80003678:	6de080e7          	jalr	1758(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    8000367c:	01048513          	addi	a0,s1,16
    80003680:	00001097          	auipc	ra,0x1
    80003684:	472080e7          	jalr	1138(ra) # 80004af2 <acquiresleep>
      return b;
    80003688:	a8b9                	j	800036e6 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000368a:	0001b497          	auipc	s1,0x1b
    8000368e:	7be4b483          	ld	s1,1982(s1) # 8001ee48 <bcache+0x82b0>
    80003692:	0001b797          	auipc	a5,0x1b
    80003696:	76e78793          	addi	a5,a5,1902 # 8001ee00 <bcache+0x8268>
    8000369a:	00f48863          	beq	s1,a5,800036aa <bread+0x90>
    8000369e:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    800036a0:	40bc                	lw	a5,64(s1)
    800036a2:	cf81                	beqz	a5,800036ba <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800036a4:	64a4                	ld	s1,72(s1)
    800036a6:	fee49de3          	bne	s1,a4,800036a0 <bread+0x86>
  panic("bget: no buffers");
    800036aa:	00005517          	auipc	a0,0x5
    800036ae:	01e50513          	addi	a0,a0,30 # 800086c8 <syscalls+0xe8>
    800036b2:	ffffd097          	auipc	ra,0xffffd
    800036b6:	e8e080e7          	jalr	-370(ra) # 80000540 <panic>
      b->dev = dev;
    800036ba:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800036be:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800036c2:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800036c6:	4785                	li	a5,1
    800036c8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800036ca:	00013517          	auipc	a0,0x13
    800036ce:	4ce50513          	addi	a0,a0,1230 # 80016b98 <bcache>
    800036d2:	ffffd097          	auipc	ra,0xffffd
    800036d6:	680080e7          	jalr	1664(ra) # 80000d52 <release>
      acquiresleep(&b->lock);
    800036da:	01048513          	addi	a0,s1,16
    800036de:	00001097          	auipc	ra,0x1
    800036e2:	414080e7          	jalr	1044(ra) # 80004af2 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800036e6:	409c                	lw	a5,0(s1)
    800036e8:	cb89                	beqz	a5,800036fa <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800036ea:	8526                	mv	a0,s1
    800036ec:	70a2                	ld	ra,40(sp)
    800036ee:	7402                	ld	s0,32(sp)
    800036f0:	64e2                	ld	s1,24(sp)
    800036f2:	6942                	ld	s2,16(sp)
    800036f4:	69a2                	ld	s3,8(sp)
    800036f6:	6145                	addi	sp,sp,48
    800036f8:	8082                	ret
    virtio_disk_rw(b, 0);
    800036fa:	4581                	li	a1,0
    800036fc:	8526                	mv	a0,s1
    800036fe:	00003097          	auipc	ra,0x3
    80003702:	fe4080e7          	jalr	-28(ra) # 800066e2 <virtio_disk_rw>
    b->valid = 1;
    80003706:	4785                	li	a5,1
    80003708:	c09c                	sw	a5,0(s1)
  return b;
    8000370a:	b7c5                	j	800036ea <bread+0xd0>

000000008000370c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000370c:	1101                	addi	sp,sp,-32
    8000370e:	ec06                	sd	ra,24(sp)
    80003710:	e822                	sd	s0,16(sp)
    80003712:	e426                	sd	s1,8(sp)
    80003714:	1000                	addi	s0,sp,32
    80003716:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003718:	0541                	addi	a0,a0,16
    8000371a:	00001097          	auipc	ra,0x1
    8000371e:	472080e7          	jalr	1138(ra) # 80004b8c <holdingsleep>
    80003722:	cd01                	beqz	a0,8000373a <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003724:	4585                	li	a1,1
    80003726:	8526                	mv	a0,s1
    80003728:	00003097          	auipc	ra,0x3
    8000372c:	fba080e7          	jalr	-70(ra) # 800066e2 <virtio_disk_rw>
}
    80003730:	60e2                	ld	ra,24(sp)
    80003732:	6442                	ld	s0,16(sp)
    80003734:	64a2                	ld	s1,8(sp)
    80003736:	6105                	addi	sp,sp,32
    80003738:	8082                	ret
    panic("bwrite");
    8000373a:	00005517          	auipc	a0,0x5
    8000373e:	fa650513          	addi	a0,a0,-90 # 800086e0 <syscalls+0x100>
    80003742:	ffffd097          	auipc	ra,0xffffd
    80003746:	dfe080e7          	jalr	-514(ra) # 80000540 <panic>

000000008000374a <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000374a:	1101                	addi	sp,sp,-32
    8000374c:	ec06                	sd	ra,24(sp)
    8000374e:	e822                	sd	s0,16(sp)
    80003750:	e426                	sd	s1,8(sp)
    80003752:	e04a                	sd	s2,0(sp)
    80003754:	1000                	addi	s0,sp,32
    80003756:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003758:	01050913          	addi	s2,a0,16
    8000375c:	854a                	mv	a0,s2
    8000375e:	00001097          	auipc	ra,0x1
    80003762:	42e080e7          	jalr	1070(ra) # 80004b8c <holdingsleep>
    80003766:	c92d                	beqz	a0,800037d8 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003768:	854a                	mv	a0,s2
    8000376a:	00001097          	auipc	ra,0x1
    8000376e:	3de080e7          	jalr	990(ra) # 80004b48 <releasesleep>

  acquire(&bcache.lock);
    80003772:	00013517          	auipc	a0,0x13
    80003776:	42650513          	addi	a0,a0,1062 # 80016b98 <bcache>
    8000377a:	ffffd097          	auipc	ra,0xffffd
    8000377e:	524080e7          	jalr	1316(ra) # 80000c9e <acquire>
  b->refcnt--;
    80003782:	40bc                	lw	a5,64(s1)
    80003784:	37fd                	addiw	a5,a5,-1
    80003786:	0007871b          	sext.w	a4,a5
    8000378a:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000378c:	eb05                	bnez	a4,800037bc <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000378e:	68bc                	ld	a5,80(s1)
    80003790:	64b8                	ld	a4,72(s1)
    80003792:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003794:	64bc                	ld	a5,72(s1)
    80003796:	68b8                	ld	a4,80(s1)
    80003798:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000379a:	0001b797          	auipc	a5,0x1b
    8000379e:	3fe78793          	addi	a5,a5,1022 # 8001eb98 <bcache+0x8000>
    800037a2:	2b87b703          	ld	a4,696(a5)
    800037a6:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800037a8:	0001b717          	auipc	a4,0x1b
    800037ac:	65870713          	addi	a4,a4,1624 # 8001ee00 <bcache+0x8268>
    800037b0:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800037b2:	2b87b703          	ld	a4,696(a5)
    800037b6:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800037b8:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800037bc:	00013517          	auipc	a0,0x13
    800037c0:	3dc50513          	addi	a0,a0,988 # 80016b98 <bcache>
    800037c4:	ffffd097          	auipc	ra,0xffffd
    800037c8:	58e080e7          	jalr	1422(ra) # 80000d52 <release>
}
    800037cc:	60e2                	ld	ra,24(sp)
    800037ce:	6442                	ld	s0,16(sp)
    800037d0:	64a2                	ld	s1,8(sp)
    800037d2:	6902                	ld	s2,0(sp)
    800037d4:	6105                	addi	sp,sp,32
    800037d6:	8082                	ret
    panic("brelse");
    800037d8:	00005517          	auipc	a0,0x5
    800037dc:	f1050513          	addi	a0,a0,-240 # 800086e8 <syscalls+0x108>
    800037e0:	ffffd097          	auipc	ra,0xffffd
    800037e4:	d60080e7          	jalr	-672(ra) # 80000540 <panic>

00000000800037e8 <bpin>:

void
bpin(struct buf *b) {
    800037e8:	1101                	addi	sp,sp,-32
    800037ea:	ec06                	sd	ra,24(sp)
    800037ec:	e822                	sd	s0,16(sp)
    800037ee:	e426                	sd	s1,8(sp)
    800037f0:	1000                	addi	s0,sp,32
    800037f2:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800037f4:	00013517          	auipc	a0,0x13
    800037f8:	3a450513          	addi	a0,a0,932 # 80016b98 <bcache>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	4a2080e7          	jalr	1186(ra) # 80000c9e <acquire>
  b->refcnt++;
    80003804:	40bc                	lw	a5,64(s1)
    80003806:	2785                	addiw	a5,a5,1
    80003808:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000380a:	00013517          	auipc	a0,0x13
    8000380e:	38e50513          	addi	a0,a0,910 # 80016b98 <bcache>
    80003812:	ffffd097          	auipc	ra,0xffffd
    80003816:	540080e7          	jalr	1344(ra) # 80000d52 <release>
}
    8000381a:	60e2                	ld	ra,24(sp)
    8000381c:	6442                	ld	s0,16(sp)
    8000381e:	64a2                	ld	s1,8(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret

0000000080003824 <bunpin>:

void
bunpin(struct buf *b) {
    80003824:	1101                	addi	sp,sp,-32
    80003826:	ec06                	sd	ra,24(sp)
    80003828:	e822                	sd	s0,16(sp)
    8000382a:	e426                	sd	s1,8(sp)
    8000382c:	1000                	addi	s0,sp,32
    8000382e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003830:	00013517          	auipc	a0,0x13
    80003834:	36850513          	addi	a0,a0,872 # 80016b98 <bcache>
    80003838:	ffffd097          	auipc	ra,0xffffd
    8000383c:	466080e7          	jalr	1126(ra) # 80000c9e <acquire>
  b->refcnt--;
    80003840:	40bc                	lw	a5,64(s1)
    80003842:	37fd                	addiw	a5,a5,-1
    80003844:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003846:	00013517          	auipc	a0,0x13
    8000384a:	35250513          	addi	a0,a0,850 # 80016b98 <bcache>
    8000384e:	ffffd097          	auipc	ra,0xffffd
    80003852:	504080e7          	jalr	1284(ra) # 80000d52 <release>
}
    80003856:	60e2                	ld	ra,24(sp)
    80003858:	6442                	ld	s0,16(sp)
    8000385a:	64a2                	ld	s1,8(sp)
    8000385c:	6105                	addi	sp,sp,32
    8000385e:	8082                	ret

0000000080003860 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003860:	1101                	addi	sp,sp,-32
    80003862:	ec06                	sd	ra,24(sp)
    80003864:	e822                	sd	s0,16(sp)
    80003866:	e426                	sd	s1,8(sp)
    80003868:	e04a                	sd	s2,0(sp)
    8000386a:	1000                	addi	s0,sp,32
    8000386c:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000386e:	00d5d59b          	srliw	a1,a1,0xd
    80003872:	0001c797          	auipc	a5,0x1c
    80003876:	a027a783          	lw	a5,-1534(a5) # 8001f274 <sb+0x1c>
    8000387a:	9dbd                	addw	a1,a1,a5
    8000387c:	00000097          	auipc	ra,0x0
    80003880:	d9e080e7          	jalr	-610(ra) # 8000361a <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003884:	0074f713          	andi	a4,s1,7
    80003888:	4785                	li	a5,1
    8000388a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000388e:	14ce                	slli	s1,s1,0x33
    80003890:	90d9                	srli	s1,s1,0x36
    80003892:	00950733          	add	a4,a0,s1
    80003896:	05874703          	lbu	a4,88(a4)
    8000389a:	00e7f6b3          	and	a3,a5,a4
    8000389e:	c69d                	beqz	a3,800038cc <bfree+0x6c>
    800038a0:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800038a2:	94aa                	add	s1,s1,a0
    800038a4:	fff7c793          	not	a5,a5
    800038a8:	8f7d                	and	a4,a4,a5
    800038aa:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800038ae:	00001097          	auipc	ra,0x1
    800038b2:	126080e7          	jalr	294(ra) # 800049d4 <log_write>
  brelse(bp);
    800038b6:	854a                	mv	a0,s2
    800038b8:	00000097          	auipc	ra,0x0
    800038bc:	e92080e7          	jalr	-366(ra) # 8000374a <brelse>
}
    800038c0:	60e2                	ld	ra,24(sp)
    800038c2:	6442                	ld	s0,16(sp)
    800038c4:	64a2                	ld	s1,8(sp)
    800038c6:	6902                	ld	s2,0(sp)
    800038c8:	6105                	addi	sp,sp,32
    800038ca:	8082                	ret
    panic("freeing free block");
    800038cc:	00005517          	auipc	a0,0x5
    800038d0:	e2450513          	addi	a0,a0,-476 # 800086f0 <syscalls+0x110>
    800038d4:	ffffd097          	auipc	ra,0xffffd
    800038d8:	c6c080e7          	jalr	-916(ra) # 80000540 <panic>

00000000800038dc <balloc>:
{
    800038dc:	711d                	addi	sp,sp,-96
    800038de:	ec86                	sd	ra,88(sp)
    800038e0:	e8a2                	sd	s0,80(sp)
    800038e2:	e4a6                	sd	s1,72(sp)
    800038e4:	e0ca                	sd	s2,64(sp)
    800038e6:	fc4e                	sd	s3,56(sp)
    800038e8:	f852                	sd	s4,48(sp)
    800038ea:	f456                	sd	s5,40(sp)
    800038ec:	f05a                	sd	s6,32(sp)
    800038ee:	ec5e                	sd	s7,24(sp)
    800038f0:	e862                	sd	s8,16(sp)
    800038f2:	e466                	sd	s9,8(sp)
    800038f4:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800038f6:	0001c797          	auipc	a5,0x1c
    800038fa:	9667a783          	lw	a5,-1690(a5) # 8001f25c <sb+0x4>
    800038fe:	cff5                	beqz	a5,800039fa <balloc+0x11e>
    80003900:	8baa                	mv	s7,a0
    80003902:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003904:	0001cb17          	auipc	s6,0x1c
    80003908:	954b0b13          	addi	s6,s6,-1708 # 8001f258 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000390c:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    8000390e:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003910:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003912:	6c89                	lui	s9,0x2
    80003914:	a061                	j	8000399c <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003916:	97ca                	add	a5,a5,s2
    80003918:	8e55                	or	a2,a2,a3
    8000391a:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000391e:	854a                	mv	a0,s2
    80003920:	00001097          	auipc	ra,0x1
    80003924:	0b4080e7          	jalr	180(ra) # 800049d4 <log_write>
        brelse(bp);
    80003928:	854a                	mv	a0,s2
    8000392a:	00000097          	auipc	ra,0x0
    8000392e:	e20080e7          	jalr	-480(ra) # 8000374a <brelse>
  bp = bread(dev, bno);
    80003932:	85a6                	mv	a1,s1
    80003934:	855e                	mv	a0,s7
    80003936:	00000097          	auipc	ra,0x0
    8000393a:	ce4080e7          	jalr	-796(ra) # 8000361a <bread>
    8000393e:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003940:	40000613          	li	a2,1024
    80003944:	4581                	li	a1,0
    80003946:	05850513          	addi	a0,a0,88
    8000394a:	ffffd097          	auipc	ra,0xffffd
    8000394e:	450080e7          	jalr	1104(ra) # 80000d9a <memset>
  log_write(bp);
    80003952:	854a                	mv	a0,s2
    80003954:	00001097          	auipc	ra,0x1
    80003958:	080080e7          	jalr	128(ra) # 800049d4 <log_write>
  brelse(bp);
    8000395c:	854a                	mv	a0,s2
    8000395e:	00000097          	auipc	ra,0x0
    80003962:	dec080e7          	jalr	-532(ra) # 8000374a <brelse>
}
    80003966:	8526                	mv	a0,s1
    80003968:	60e6                	ld	ra,88(sp)
    8000396a:	6446                	ld	s0,80(sp)
    8000396c:	64a6                	ld	s1,72(sp)
    8000396e:	6906                	ld	s2,64(sp)
    80003970:	79e2                	ld	s3,56(sp)
    80003972:	7a42                	ld	s4,48(sp)
    80003974:	7aa2                	ld	s5,40(sp)
    80003976:	7b02                	ld	s6,32(sp)
    80003978:	6be2                	ld	s7,24(sp)
    8000397a:	6c42                	ld	s8,16(sp)
    8000397c:	6ca2                	ld	s9,8(sp)
    8000397e:	6125                	addi	sp,sp,96
    80003980:	8082                	ret
    brelse(bp);
    80003982:	854a                	mv	a0,s2
    80003984:	00000097          	auipc	ra,0x0
    80003988:	dc6080e7          	jalr	-570(ra) # 8000374a <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000398c:	015c87bb          	addw	a5,s9,s5
    80003990:	00078a9b          	sext.w	s5,a5
    80003994:	004b2703          	lw	a4,4(s6)
    80003998:	06eaf163          	bgeu	s5,a4,800039fa <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    8000399c:	41fad79b          	sraiw	a5,s5,0x1f
    800039a0:	0137d79b          	srliw	a5,a5,0x13
    800039a4:	015787bb          	addw	a5,a5,s5
    800039a8:	40d7d79b          	sraiw	a5,a5,0xd
    800039ac:	01cb2583          	lw	a1,28(s6)
    800039b0:	9dbd                	addw	a1,a1,a5
    800039b2:	855e                	mv	a0,s7
    800039b4:	00000097          	auipc	ra,0x0
    800039b8:	c66080e7          	jalr	-922(ra) # 8000361a <bread>
    800039bc:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039be:	004b2503          	lw	a0,4(s6)
    800039c2:	000a849b          	sext.w	s1,s5
    800039c6:	8762                	mv	a4,s8
    800039c8:	faa4fde3          	bgeu	s1,a0,80003982 <balloc+0xa6>
      m = 1 << (bi % 8);
    800039cc:	00777693          	andi	a3,a4,7
    800039d0:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800039d4:	41f7579b          	sraiw	a5,a4,0x1f
    800039d8:	01d7d79b          	srliw	a5,a5,0x1d
    800039dc:	9fb9                	addw	a5,a5,a4
    800039de:	4037d79b          	sraiw	a5,a5,0x3
    800039e2:	00f90633          	add	a2,s2,a5
    800039e6:	05864603          	lbu	a2,88(a2)
    800039ea:	00c6f5b3          	and	a1,a3,a2
    800039ee:	d585                	beqz	a1,80003916 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800039f0:	2705                	addiw	a4,a4,1
    800039f2:	2485                	addiw	s1,s1,1
    800039f4:	fd471ae3          	bne	a4,s4,800039c8 <balloc+0xec>
    800039f8:	b769                	j	80003982 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800039fa:	00005517          	auipc	a0,0x5
    800039fe:	d0e50513          	addi	a0,a0,-754 # 80008708 <syscalls+0x128>
    80003a02:	ffffd097          	auipc	ra,0xffffd
    80003a06:	b9a080e7          	jalr	-1126(ra) # 8000059c <printf>
  return 0;
    80003a0a:	4481                	li	s1,0
    80003a0c:	bfa9                	j	80003966 <balloc+0x8a>

0000000080003a0e <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003a0e:	7179                	addi	sp,sp,-48
    80003a10:	f406                	sd	ra,40(sp)
    80003a12:	f022                	sd	s0,32(sp)
    80003a14:	ec26                	sd	s1,24(sp)
    80003a16:	e84a                	sd	s2,16(sp)
    80003a18:	e44e                	sd	s3,8(sp)
    80003a1a:	e052                	sd	s4,0(sp)
    80003a1c:	1800                	addi	s0,sp,48
    80003a1e:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003a20:	47ad                	li	a5,11
    80003a22:	02b7e863          	bltu	a5,a1,80003a52 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003a26:	02059793          	slli	a5,a1,0x20
    80003a2a:	01e7d593          	srli	a1,a5,0x1e
    80003a2e:	00b504b3          	add	s1,a0,a1
    80003a32:	0504a903          	lw	s2,80(s1)
    80003a36:	06091e63          	bnez	s2,80003ab2 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003a3a:	4108                	lw	a0,0(a0)
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	ea0080e7          	jalr	-352(ra) # 800038dc <balloc>
    80003a44:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a48:	06090563          	beqz	s2,80003ab2 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003a4c:	0524a823          	sw	s2,80(s1)
    80003a50:	a08d                	j	80003ab2 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003a52:	ff45849b          	addiw	s1,a1,-12
    80003a56:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003a5a:	0ff00793          	li	a5,255
    80003a5e:	08e7e563          	bltu	a5,a4,80003ae8 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003a62:	08052903          	lw	s2,128(a0)
    80003a66:	00091d63          	bnez	s2,80003a80 <bmap+0x72>
      addr = balloc(ip->dev);
    80003a6a:	4108                	lw	a0,0(a0)
    80003a6c:	00000097          	auipc	ra,0x0
    80003a70:	e70080e7          	jalr	-400(ra) # 800038dc <balloc>
    80003a74:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003a78:	02090d63          	beqz	s2,80003ab2 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003a7c:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003a80:	85ca                	mv	a1,s2
    80003a82:	0009a503          	lw	a0,0(s3)
    80003a86:	00000097          	auipc	ra,0x0
    80003a8a:	b94080e7          	jalr	-1132(ra) # 8000361a <bread>
    80003a8e:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003a90:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003a94:	02049713          	slli	a4,s1,0x20
    80003a98:	01e75593          	srli	a1,a4,0x1e
    80003a9c:	00b784b3          	add	s1,a5,a1
    80003aa0:	0004a903          	lw	s2,0(s1)
    80003aa4:	02090063          	beqz	s2,80003ac4 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003aa8:	8552                	mv	a0,s4
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	ca0080e7          	jalr	-864(ra) # 8000374a <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003ab2:	854a                	mv	a0,s2
    80003ab4:	70a2                	ld	ra,40(sp)
    80003ab6:	7402                	ld	s0,32(sp)
    80003ab8:	64e2                	ld	s1,24(sp)
    80003aba:	6942                	ld	s2,16(sp)
    80003abc:	69a2                	ld	s3,8(sp)
    80003abe:	6a02                	ld	s4,0(sp)
    80003ac0:	6145                	addi	sp,sp,48
    80003ac2:	8082                	ret
      addr = balloc(ip->dev);
    80003ac4:	0009a503          	lw	a0,0(s3)
    80003ac8:	00000097          	auipc	ra,0x0
    80003acc:	e14080e7          	jalr	-492(ra) # 800038dc <balloc>
    80003ad0:	0005091b          	sext.w	s2,a0
      if(addr){
    80003ad4:	fc090ae3          	beqz	s2,80003aa8 <bmap+0x9a>
        a[bn] = addr;
    80003ad8:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003adc:	8552                	mv	a0,s4
    80003ade:	00001097          	auipc	ra,0x1
    80003ae2:	ef6080e7          	jalr	-266(ra) # 800049d4 <log_write>
    80003ae6:	b7c9                	j	80003aa8 <bmap+0x9a>
  panic("bmap: out of range");
    80003ae8:	00005517          	auipc	a0,0x5
    80003aec:	c3850513          	addi	a0,a0,-968 # 80008720 <syscalls+0x140>
    80003af0:	ffffd097          	auipc	ra,0xffffd
    80003af4:	a50080e7          	jalr	-1456(ra) # 80000540 <panic>

0000000080003af8 <iget>:
{
    80003af8:	7179                	addi	sp,sp,-48
    80003afa:	f406                	sd	ra,40(sp)
    80003afc:	f022                	sd	s0,32(sp)
    80003afe:	ec26                	sd	s1,24(sp)
    80003b00:	e84a                	sd	s2,16(sp)
    80003b02:	e44e                	sd	s3,8(sp)
    80003b04:	e052                	sd	s4,0(sp)
    80003b06:	1800                	addi	s0,sp,48
    80003b08:	89aa                	mv	s3,a0
    80003b0a:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003b0c:	0001b517          	auipc	a0,0x1b
    80003b10:	76c50513          	addi	a0,a0,1900 # 8001f278 <itable>
    80003b14:	ffffd097          	auipc	ra,0xffffd
    80003b18:	18a080e7          	jalr	394(ra) # 80000c9e <acquire>
  empty = 0;
    80003b1c:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b1e:	0001b497          	auipc	s1,0x1b
    80003b22:	77248493          	addi	s1,s1,1906 # 8001f290 <itable+0x18>
    80003b26:	0001d697          	auipc	a3,0x1d
    80003b2a:	1fa68693          	addi	a3,a3,506 # 80020d20 <log>
    80003b2e:	a039                	j	80003b3c <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b30:	02090b63          	beqz	s2,80003b66 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003b34:	08848493          	addi	s1,s1,136
    80003b38:	02d48a63          	beq	s1,a3,80003b6c <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003b3c:	449c                	lw	a5,8(s1)
    80003b3e:	fef059e3          	blez	a5,80003b30 <iget+0x38>
    80003b42:	4098                	lw	a4,0(s1)
    80003b44:	ff3716e3          	bne	a4,s3,80003b30 <iget+0x38>
    80003b48:	40d8                	lw	a4,4(s1)
    80003b4a:	ff4713e3          	bne	a4,s4,80003b30 <iget+0x38>
      ip->ref++;
    80003b4e:	2785                	addiw	a5,a5,1
    80003b50:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003b52:	0001b517          	auipc	a0,0x1b
    80003b56:	72650513          	addi	a0,a0,1830 # 8001f278 <itable>
    80003b5a:	ffffd097          	auipc	ra,0xffffd
    80003b5e:	1f8080e7          	jalr	504(ra) # 80000d52 <release>
      return ip;
    80003b62:	8926                	mv	s2,s1
    80003b64:	a03d                	j	80003b92 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003b66:	f7f9                	bnez	a5,80003b34 <iget+0x3c>
    80003b68:	8926                	mv	s2,s1
    80003b6a:	b7e9                	j	80003b34 <iget+0x3c>
  if(empty == 0)
    80003b6c:	02090c63          	beqz	s2,80003ba4 <iget+0xac>
  ip->dev = dev;
    80003b70:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003b74:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003b78:	4785                	li	a5,1
    80003b7a:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003b7e:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003b82:	0001b517          	auipc	a0,0x1b
    80003b86:	6f650513          	addi	a0,a0,1782 # 8001f278 <itable>
    80003b8a:	ffffd097          	auipc	ra,0xffffd
    80003b8e:	1c8080e7          	jalr	456(ra) # 80000d52 <release>
}
    80003b92:	854a                	mv	a0,s2
    80003b94:	70a2                	ld	ra,40(sp)
    80003b96:	7402                	ld	s0,32(sp)
    80003b98:	64e2                	ld	s1,24(sp)
    80003b9a:	6942                	ld	s2,16(sp)
    80003b9c:	69a2                	ld	s3,8(sp)
    80003b9e:	6a02                	ld	s4,0(sp)
    80003ba0:	6145                	addi	sp,sp,48
    80003ba2:	8082                	ret
    panic("iget: no inodes");
    80003ba4:	00005517          	auipc	a0,0x5
    80003ba8:	b9450513          	addi	a0,a0,-1132 # 80008738 <syscalls+0x158>
    80003bac:	ffffd097          	auipc	ra,0xffffd
    80003bb0:	994080e7          	jalr	-1644(ra) # 80000540 <panic>

0000000080003bb4 <fsinit>:
fsinit(int dev) {
    80003bb4:	7179                	addi	sp,sp,-48
    80003bb6:	f406                	sd	ra,40(sp)
    80003bb8:	f022                	sd	s0,32(sp)
    80003bba:	ec26                	sd	s1,24(sp)
    80003bbc:	e84a                	sd	s2,16(sp)
    80003bbe:	e44e                	sd	s3,8(sp)
    80003bc0:	1800                	addi	s0,sp,48
    80003bc2:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003bc4:	4585                	li	a1,1
    80003bc6:	00000097          	auipc	ra,0x0
    80003bca:	a54080e7          	jalr	-1452(ra) # 8000361a <bread>
    80003bce:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003bd0:	0001b997          	auipc	s3,0x1b
    80003bd4:	68898993          	addi	s3,s3,1672 # 8001f258 <sb>
    80003bd8:	02000613          	li	a2,32
    80003bdc:	05850593          	addi	a1,a0,88
    80003be0:	854e                	mv	a0,s3
    80003be2:	ffffd097          	auipc	ra,0xffffd
    80003be6:	214080e7          	jalr	532(ra) # 80000df6 <memmove>
  brelse(bp);
    80003bea:	8526                	mv	a0,s1
    80003bec:	00000097          	auipc	ra,0x0
    80003bf0:	b5e080e7          	jalr	-1186(ra) # 8000374a <brelse>
  if(sb.magic != FSMAGIC)
    80003bf4:	0009a703          	lw	a4,0(s3)
    80003bf8:	102037b7          	lui	a5,0x10203
    80003bfc:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003c00:	02f71263          	bne	a4,a5,80003c24 <fsinit+0x70>
  initlog(dev, &sb);
    80003c04:	0001b597          	auipc	a1,0x1b
    80003c08:	65458593          	addi	a1,a1,1620 # 8001f258 <sb>
    80003c0c:	854a                	mv	a0,s2
    80003c0e:	00001097          	auipc	ra,0x1
    80003c12:	b4a080e7          	jalr	-1206(ra) # 80004758 <initlog>
}
    80003c16:	70a2                	ld	ra,40(sp)
    80003c18:	7402                	ld	s0,32(sp)
    80003c1a:	64e2                	ld	s1,24(sp)
    80003c1c:	6942                	ld	s2,16(sp)
    80003c1e:	69a2                	ld	s3,8(sp)
    80003c20:	6145                	addi	sp,sp,48
    80003c22:	8082                	ret
    panic("invalid file system");
    80003c24:	00005517          	auipc	a0,0x5
    80003c28:	b2450513          	addi	a0,a0,-1244 # 80008748 <syscalls+0x168>
    80003c2c:	ffffd097          	auipc	ra,0xffffd
    80003c30:	914080e7          	jalr	-1772(ra) # 80000540 <panic>

0000000080003c34 <iinit>:
{
    80003c34:	7179                	addi	sp,sp,-48
    80003c36:	f406                	sd	ra,40(sp)
    80003c38:	f022                	sd	s0,32(sp)
    80003c3a:	ec26                	sd	s1,24(sp)
    80003c3c:	e84a                	sd	s2,16(sp)
    80003c3e:	e44e                	sd	s3,8(sp)
    80003c40:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003c42:	00005597          	auipc	a1,0x5
    80003c46:	b1e58593          	addi	a1,a1,-1250 # 80008760 <syscalls+0x180>
    80003c4a:	0001b517          	auipc	a0,0x1b
    80003c4e:	62e50513          	addi	a0,a0,1582 # 8001f278 <itable>
    80003c52:	ffffd097          	auipc	ra,0xffffd
    80003c56:	fbc080e7          	jalr	-68(ra) # 80000c0e <initlock>
  for(i = 0; i < NINODE; i++) {
    80003c5a:	0001b497          	auipc	s1,0x1b
    80003c5e:	64648493          	addi	s1,s1,1606 # 8001f2a0 <itable+0x28>
    80003c62:	0001d997          	auipc	s3,0x1d
    80003c66:	0ce98993          	addi	s3,s3,206 # 80020d30 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003c6a:	00005917          	auipc	s2,0x5
    80003c6e:	afe90913          	addi	s2,s2,-1282 # 80008768 <syscalls+0x188>
    80003c72:	85ca                	mv	a1,s2
    80003c74:	8526                	mv	a0,s1
    80003c76:	00001097          	auipc	ra,0x1
    80003c7a:	e42080e7          	jalr	-446(ra) # 80004ab8 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003c7e:	08848493          	addi	s1,s1,136
    80003c82:	ff3498e3          	bne	s1,s3,80003c72 <iinit+0x3e>
}
    80003c86:	70a2                	ld	ra,40(sp)
    80003c88:	7402                	ld	s0,32(sp)
    80003c8a:	64e2                	ld	s1,24(sp)
    80003c8c:	6942                	ld	s2,16(sp)
    80003c8e:	69a2                	ld	s3,8(sp)
    80003c90:	6145                	addi	sp,sp,48
    80003c92:	8082                	ret

0000000080003c94 <ialloc>:
{
    80003c94:	715d                	addi	sp,sp,-80
    80003c96:	e486                	sd	ra,72(sp)
    80003c98:	e0a2                	sd	s0,64(sp)
    80003c9a:	fc26                	sd	s1,56(sp)
    80003c9c:	f84a                	sd	s2,48(sp)
    80003c9e:	f44e                	sd	s3,40(sp)
    80003ca0:	f052                	sd	s4,32(sp)
    80003ca2:	ec56                	sd	s5,24(sp)
    80003ca4:	e85a                	sd	s6,16(sp)
    80003ca6:	e45e                	sd	s7,8(sp)
    80003ca8:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003caa:	0001b717          	auipc	a4,0x1b
    80003cae:	5ba72703          	lw	a4,1466(a4) # 8001f264 <sb+0xc>
    80003cb2:	4785                	li	a5,1
    80003cb4:	04e7fa63          	bgeu	a5,a4,80003d08 <ialloc+0x74>
    80003cb8:	8aaa                	mv	s5,a0
    80003cba:	8bae                	mv	s7,a1
    80003cbc:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003cbe:	0001ba17          	auipc	s4,0x1b
    80003cc2:	59aa0a13          	addi	s4,s4,1434 # 8001f258 <sb>
    80003cc6:	00048b1b          	sext.w	s6,s1
    80003cca:	0044d593          	srli	a1,s1,0x4
    80003cce:	018a2783          	lw	a5,24(s4)
    80003cd2:	9dbd                	addw	a1,a1,a5
    80003cd4:	8556                	mv	a0,s5
    80003cd6:	00000097          	auipc	ra,0x0
    80003cda:	944080e7          	jalr	-1724(ra) # 8000361a <bread>
    80003cde:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003ce0:	05850993          	addi	s3,a0,88
    80003ce4:	00f4f793          	andi	a5,s1,15
    80003ce8:	079a                	slli	a5,a5,0x6
    80003cea:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003cec:	00099783          	lh	a5,0(s3)
    80003cf0:	c3a1                	beqz	a5,80003d30 <ialloc+0x9c>
    brelse(bp);
    80003cf2:	00000097          	auipc	ra,0x0
    80003cf6:	a58080e7          	jalr	-1448(ra) # 8000374a <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003cfa:	0485                	addi	s1,s1,1
    80003cfc:	00ca2703          	lw	a4,12(s4)
    80003d00:	0004879b          	sext.w	a5,s1
    80003d04:	fce7e1e3          	bltu	a5,a4,80003cc6 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    80003d08:	00005517          	auipc	a0,0x5
    80003d0c:	a6850513          	addi	a0,a0,-1432 # 80008770 <syscalls+0x190>
    80003d10:	ffffd097          	auipc	ra,0xffffd
    80003d14:	88c080e7          	jalr	-1908(ra) # 8000059c <printf>
  return 0;
    80003d18:	4501                	li	a0,0
}
    80003d1a:	60a6                	ld	ra,72(sp)
    80003d1c:	6406                	ld	s0,64(sp)
    80003d1e:	74e2                	ld	s1,56(sp)
    80003d20:	7942                	ld	s2,48(sp)
    80003d22:	79a2                	ld	s3,40(sp)
    80003d24:	7a02                	ld	s4,32(sp)
    80003d26:	6ae2                	ld	s5,24(sp)
    80003d28:	6b42                	ld	s6,16(sp)
    80003d2a:	6ba2                	ld	s7,8(sp)
    80003d2c:	6161                	addi	sp,sp,80
    80003d2e:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003d30:	04000613          	li	a2,64
    80003d34:	4581                	li	a1,0
    80003d36:	854e                	mv	a0,s3
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	062080e7          	jalr	98(ra) # 80000d9a <memset>
      dip->type = type;
    80003d40:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003d44:	854a                	mv	a0,s2
    80003d46:	00001097          	auipc	ra,0x1
    80003d4a:	c8e080e7          	jalr	-882(ra) # 800049d4 <log_write>
      brelse(bp);
    80003d4e:	854a                	mv	a0,s2
    80003d50:	00000097          	auipc	ra,0x0
    80003d54:	9fa080e7          	jalr	-1542(ra) # 8000374a <brelse>
      return iget(dev, inum);
    80003d58:	85da                	mv	a1,s6
    80003d5a:	8556                	mv	a0,s5
    80003d5c:	00000097          	auipc	ra,0x0
    80003d60:	d9c080e7          	jalr	-612(ra) # 80003af8 <iget>
    80003d64:	bf5d                	j	80003d1a <ialloc+0x86>

0000000080003d66 <iupdate>:
{
    80003d66:	1101                	addi	sp,sp,-32
    80003d68:	ec06                	sd	ra,24(sp)
    80003d6a:	e822                	sd	s0,16(sp)
    80003d6c:	e426                	sd	s1,8(sp)
    80003d6e:	e04a                	sd	s2,0(sp)
    80003d70:	1000                	addi	s0,sp,32
    80003d72:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003d74:	415c                	lw	a5,4(a0)
    80003d76:	0047d79b          	srliw	a5,a5,0x4
    80003d7a:	0001b597          	auipc	a1,0x1b
    80003d7e:	4f65a583          	lw	a1,1270(a1) # 8001f270 <sb+0x18>
    80003d82:	9dbd                	addw	a1,a1,a5
    80003d84:	4108                	lw	a0,0(a0)
    80003d86:	00000097          	auipc	ra,0x0
    80003d8a:	894080e7          	jalr	-1900(ra) # 8000361a <bread>
    80003d8e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003d90:	05850793          	addi	a5,a0,88
    80003d94:	40d8                	lw	a4,4(s1)
    80003d96:	8b3d                	andi	a4,a4,15
    80003d98:	071a                	slli	a4,a4,0x6
    80003d9a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003d9c:	04449703          	lh	a4,68(s1)
    80003da0:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003da4:	04649703          	lh	a4,70(s1)
    80003da8:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003dac:	04849703          	lh	a4,72(s1)
    80003db0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003db4:	04a49703          	lh	a4,74(s1)
    80003db8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003dbc:	44f8                	lw	a4,76(s1)
    80003dbe:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003dc0:	03400613          	li	a2,52
    80003dc4:	05048593          	addi	a1,s1,80
    80003dc8:	00c78513          	addi	a0,a5,12
    80003dcc:	ffffd097          	auipc	ra,0xffffd
    80003dd0:	02a080e7          	jalr	42(ra) # 80000df6 <memmove>
  log_write(bp);
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	00001097          	auipc	ra,0x1
    80003dda:	bfe080e7          	jalr	-1026(ra) # 800049d4 <log_write>
  brelse(bp);
    80003dde:	854a                	mv	a0,s2
    80003de0:	00000097          	auipc	ra,0x0
    80003de4:	96a080e7          	jalr	-1686(ra) # 8000374a <brelse>
}
    80003de8:	60e2                	ld	ra,24(sp)
    80003dea:	6442                	ld	s0,16(sp)
    80003dec:	64a2                	ld	s1,8(sp)
    80003dee:	6902                	ld	s2,0(sp)
    80003df0:	6105                	addi	sp,sp,32
    80003df2:	8082                	ret

0000000080003df4 <idup>:
{
    80003df4:	1101                	addi	sp,sp,-32
    80003df6:	ec06                	sd	ra,24(sp)
    80003df8:	e822                	sd	s0,16(sp)
    80003dfa:	e426                	sd	s1,8(sp)
    80003dfc:	1000                	addi	s0,sp,32
    80003dfe:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003e00:	0001b517          	auipc	a0,0x1b
    80003e04:	47850513          	addi	a0,a0,1144 # 8001f278 <itable>
    80003e08:	ffffd097          	auipc	ra,0xffffd
    80003e0c:	e96080e7          	jalr	-362(ra) # 80000c9e <acquire>
  ip->ref++;
    80003e10:	449c                	lw	a5,8(s1)
    80003e12:	2785                	addiw	a5,a5,1
    80003e14:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003e16:	0001b517          	auipc	a0,0x1b
    80003e1a:	46250513          	addi	a0,a0,1122 # 8001f278 <itable>
    80003e1e:	ffffd097          	auipc	ra,0xffffd
    80003e22:	f34080e7          	jalr	-204(ra) # 80000d52 <release>
}
    80003e26:	8526                	mv	a0,s1
    80003e28:	60e2                	ld	ra,24(sp)
    80003e2a:	6442                	ld	s0,16(sp)
    80003e2c:	64a2                	ld	s1,8(sp)
    80003e2e:	6105                	addi	sp,sp,32
    80003e30:	8082                	ret

0000000080003e32 <ilock>:
{
    80003e32:	1101                	addi	sp,sp,-32
    80003e34:	ec06                	sd	ra,24(sp)
    80003e36:	e822                	sd	s0,16(sp)
    80003e38:	e426                	sd	s1,8(sp)
    80003e3a:	e04a                	sd	s2,0(sp)
    80003e3c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003e3e:	c115                	beqz	a0,80003e62 <ilock+0x30>
    80003e40:	84aa                	mv	s1,a0
    80003e42:	451c                	lw	a5,8(a0)
    80003e44:	00f05f63          	blez	a5,80003e62 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003e48:	0541                	addi	a0,a0,16
    80003e4a:	00001097          	auipc	ra,0x1
    80003e4e:	ca8080e7          	jalr	-856(ra) # 80004af2 <acquiresleep>
  if(ip->valid == 0){
    80003e52:	40bc                	lw	a5,64(s1)
    80003e54:	cf99                	beqz	a5,80003e72 <ilock+0x40>
}
    80003e56:	60e2                	ld	ra,24(sp)
    80003e58:	6442                	ld	s0,16(sp)
    80003e5a:	64a2                	ld	s1,8(sp)
    80003e5c:	6902                	ld	s2,0(sp)
    80003e5e:	6105                	addi	sp,sp,32
    80003e60:	8082                	ret
    panic("ilock");
    80003e62:	00005517          	auipc	a0,0x5
    80003e66:	92650513          	addi	a0,a0,-1754 # 80008788 <syscalls+0x1a8>
    80003e6a:	ffffc097          	auipc	ra,0xffffc
    80003e6e:	6d6080e7          	jalr	1750(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003e72:	40dc                	lw	a5,4(s1)
    80003e74:	0047d79b          	srliw	a5,a5,0x4
    80003e78:	0001b597          	auipc	a1,0x1b
    80003e7c:	3f85a583          	lw	a1,1016(a1) # 8001f270 <sb+0x18>
    80003e80:	9dbd                	addw	a1,a1,a5
    80003e82:	4088                	lw	a0,0(s1)
    80003e84:	fffff097          	auipc	ra,0xfffff
    80003e88:	796080e7          	jalr	1942(ra) # 8000361a <bread>
    80003e8c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003e8e:	05850593          	addi	a1,a0,88
    80003e92:	40dc                	lw	a5,4(s1)
    80003e94:	8bbd                	andi	a5,a5,15
    80003e96:	079a                	slli	a5,a5,0x6
    80003e98:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003e9a:	00059783          	lh	a5,0(a1)
    80003e9e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003ea2:	00259783          	lh	a5,2(a1)
    80003ea6:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003eaa:	00459783          	lh	a5,4(a1)
    80003eae:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003eb2:	00659783          	lh	a5,6(a1)
    80003eb6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003eba:	459c                	lw	a5,8(a1)
    80003ebc:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003ebe:	03400613          	li	a2,52
    80003ec2:	05b1                	addi	a1,a1,12
    80003ec4:	05048513          	addi	a0,s1,80
    80003ec8:	ffffd097          	auipc	ra,0xffffd
    80003ecc:	f2e080e7          	jalr	-210(ra) # 80000df6 <memmove>
    brelse(bp);
    80003ed0:	854a                	mv	a0,s2
    80003ed2:	00000097          	auipc	ra,0x0
    80003ed6:	878080e7          	jalr	-1928(ra) # 8000374a <brelse>
    ip->valid = 1;
    80003eda:	4785                	li	a5,1
    80003edc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003ede:	04449783          	lh	a5,68(s1)
    80003ee2:	fbb5                	bnez	a5,80003e56 <ilock+0x24>
      panic("ilock: no type");
    80003ee4:	00005517          	auipc	a0,0x5
    80003ee8:	8ac50513          	addi	a0,a0,-1876 # 80008790 <syscalls+0x1b0>
    80003eec:	ffffc097          	auipc	ra,0xffffc
    80003ef0:	654080e7          	jalr	1620(ra) # 80000540 <panic>

0000000080003ef4 <iunlock>:
{
    80003ef4:	1101                	addi	sp,sp,-32
    80003ef6:	ec06                	sd	ra,24(sp)
    80003ef8:	e822                	sd	s0,16(sp)
    80003efa:	e426                	sd	s1,8(sp)
    80003efc:	e04a                	sd	s2,0(sp)
    80003efe:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003f00:	c905                	beqz	a0,80003f30 <iunlock+0x3c>
    80003f02:	84aa                	mv	s1,a0
    80003f04:	01050913          	addi	s2,a0,16
    80003f08:	854a                	mv	a0,s2
    80003f0a:	00001097          	auipc	ra,0x1
    80003f0e:	c82080e7          	jalr	-894(ra) # 80004b8c <holdingsleep>
    80003f12:	cd19                	beqz	a0,80003f30 <iunlock+0x3c>
    80003f14:	449c                	lw	a5,8(s1)
    80003f16:	00f05d63          	blez	a5,80003f30 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	00001097          	auipc	ra,0x1
    80003f20:	c2c080e7          	jalr	-980(ra) # 80004b48 <releasesleep>
}
    80003f24:	60e2                	ld	ra,24(sp)
    80003f26:	6442                	ld	s0,16(sp)
    80003f28:	64a2                	ld	s1,8(sp)
    80003f2a:	6902                	ld	s2,0(sp)
    80003f2c:	6105                	addi	sp,sp,32
    80003f2e:	8082                	ret
    panic("iunlock");
    80003f30:	00005517          	auipc	a0,0x5
    80003f34:	87050513          	addi	a0,a0,-1936 # 800087a0 <syscalls+0x1c0>
    80003f38:	ffffc097          	auipc	ra,0xffffc
    80003f3c:	608080e7          	jalr	1544(ra) # 80000540 <panic>

0000000080003f40 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003f40:	7179                	addi	sp,sp,-48
    80003f42:	f406                	sd	ra,40(sp)
    80003f44:	f022                	sd	s0,32(sp)
    80003f46:	ec26                	sd	s1,24(sp)
    80003f48:	e84a                	sd	s2,16(sp)
    80003f4a:	e44e                	sd	s3,8(sp)
    80003f4c:	e052                	sd	s4,0(sp)
    80003f4e:	1800                	addi	s0,sp,48
    80003f50:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003f52:	05050493          	addi	s1,a0,80
    80003f56:	08050913          	addi	s2,a0,128
    80003f5a:	a021                	j	80003f62 <itrunc+0x22>
    80003f5c:	0491                	addi	s1,s1,4
    80003f5e:	01248d63          	beq	s1,s2,80003f78 <itrunc+0x38>
    if(ip->addrs[i]){
    80003f62:	408c                	lw	a1,0(s1)
    80003f64:	dde5                	beqz	a1,80003f5c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003f66:	0009a503          	lw	a0,0(s3)
    80003f6a:	00000097          	auipc	ra,0x0
    80003f6e:	8f6080e7          	jalr	-1802(ra) # 80003860 <bfree>
      ip->addrs[i] = 0;
    80003f72:	0004a023          	sw	zero,0(s1)
    80003f76:	b7dd                	j	80003f5c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003f78:	0809a583          	lw	a1,128(s3)
    80003f7c:	e185                	bnez	a1,80003f9c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003f7e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003f82:	854e                	mv	a0,s3
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	de2080e7          	jalr	-542(ra) # 80003d66 <iupdate>
}
    80003f8c:	70a2                	ld	ra,40(sp)
    80003f8e:	7402                	ld	s0,32(sp)
    80003f90:	64e2                	ld	s1,24(sp)
    80003f92:	6942                	ld	s2,16(sp)
    80003f94:	69a2                	ld	s3,8(sp)
    80003f96:	6a02                	ld	s4,0(sp)
    80003f98:	6145                	addi	sp,sp,48
    80003f9a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003f9c:	0009a503          	lw	a0,0(s3)
    80003fa0:	fffff097          	auipc	ra,0xfffff
    80003fa4:	67a080e7          	jalr	1658(ra) # 8000361a <bread>
    80003fa8:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003faa:	05850493          	addi	s1,a0,88
    80003fae:	45850913          	addi	s2,a0,1112
    80003fb2:	a021                	j	80003fba <itrunc+0x7a>
    80003fb4:	0491                	addi	s1,s1,4
    80003fb6:	01248b63          	beq	s1,s2,80003fcc <itrunc+0x8c>
      if(a[j])
    80003fba:	408c                	lw	a1,0(s1)
    80003fbc:	dde5                	beqz	a1,80003fb4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003fbe:	0009a503          	lw	a0,0(s3)
    80003fc2:	00000097          	auipc	ra,0x0
    80003fc6:	89e080e7          	jalr	-1890(ra) # 80003860 <bfree>
    80003fca:	b7ed                	j	80003fb4 <itrunc+0x74>
    brelse(bp);
    80003fcc:	8552                	mv	a0,s4
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	77c080e7          	jalr	1916(ra) # 8000374a <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003fd6:	0809a583          	lw	a1,128(s3)
    80003fda:	0009a503          	lw	a0,0(s3)
    80003fde:	00000097          	auipc	ra,0x0
    80003fe2:	882080e7          	jalr	-1918(ra) # 80003860 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003fe6:	0809a023          	sw	zero,128(s3)
    80003fea:	bf51                	j	80003f7e <itrunc+0x3e>

0000000080003fec <iput>:
{
    80003fec:	1101                	addi	sp,sp,-32
    80003fee:	ec06                	sd	ra,24(sp)
    80003ff0:	e822                	sd	s0,16(sp)
    80003ff2:	e426                	sd	s1,8(sp)
    80003ff4:	e04a                	sd	s2,0(sp)
    80003ff6:	1000                	addi	s0,sp,32
    80003ff8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ffa:	0001b517          	auipc	a0,0x1b
    80003ffe:	27e50513          	addi	a0,a0,638 # 8001f278 <itable>
    80004002:	ffffd097          	auipc	ra,0xffffd
    80004006:	c9c080e7          	jalr	-868(ra) # 80000c9e <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000400a:	4498                	lw	a4,8(s1)
    8000400c:	4785                	li	a5,1
    8000400e:	02f70363          	beq	a4,a5,80004034 <iput+0x48>
  ip->ref--;
    80004012:	449c                	lw	a5,8(s1)
    80004014:	37fd                	addiw	a5,a5,-1
    80004016:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80004018:	0001b517          	auipc	a0,0x1b
    8000401c:	26050513          	addi	a0,a0,608 # 8001f278 <itable>
    80004020:	ffffd097          	auipc	ra,0xffffd
    80004024:	d32080e7          	jalr	-718(ra) # 80000d52 <release>
}
    80004028:	60e2                	ld	ra,24(sp)
    8000402a:	6442                	ld	s0,16(sp)
    8000402c:	64a2                	ld	s1,8(sp)
    8000402e:	6902                	ld	s2,0(sp)
    80004030:	6105                	addi	sp,sp,32
    80004032:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80004034:	40bc                	lw	a5,64(s1)
    80004036:	dff1                	beqz	a5,80004012 <iput+0x26>
    80004038:	04a49783          	lh	a5,74(s1)
    8000403c:	fbf9                	bnez	a5,80004012 <iput+0x26>
    acquiresleep(&ip->lock);
    8000403e:	01048913          	addi	s2,s1,16
    80004042:	854a                	mv	a0,s2
    80004044:	00001097          	auipc	ra,0x1
    80004048:	aae080e7          	jalr	-1362(ra) # 80004af2 <acquiresleep>
    release(&itable.lock);
    8000404c:	0001b517          	auipc	a0,0x1b
    80004050:	22c50513          	addi	a0,a0,556 # 8001f278 <itable>
    80004054:	ffffd097          	auipc	ra,0xffffd
    80004058:	cfe080e7          	jalr	-770(ra) # 80000d52 <release>
    itrunc(ip);
    8000405c:	8526                	mv	a0,s1
    8000405e:	00000097          	auipc	ra,0x0
    80004062:	ee2080e7          	jalr	-286(ra) # 80003f40 <itrunc>
    ip->type = 0;
    80004066:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000406a:	8526                	mv	a0,s1
    8000406c:	00000097          	auipc	ra,0x0
    80004070:	cfa080e7          	jalr	-774(ra) # 80003d66 <iupdate>
    ip->valid = 0;
    80004074:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80004078:	854a                	mv	a0,s2
    8000407a:	00001097          	auipc	ra,0x1
    8000407e:	ace080e7          	jalr	-1330(ra) # 80004b48 <releasesleep>
    acquire(&itable.lock);
    80004082:	0001b517          	auipc	a0,0x1b
    80004086:	1f650513          	addi	a0,a0,502 # 8001f278 <itable>
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	c14080e7          	jalr	-1004(ra) # 80000c9e <acquire>
    80004092:	b741                	j	80004012 <iput+0x26>

0000000080004094 <iunlockput>:
{
    80004094:	1101                	addi	sp,sp,-32
    80004096:	ec06                	sd	ra,24(sp)
    80004098:	e822                	sd	s0,16(sp)
    8000409a:	e426                	sd	s1,8(sp)
    8000409c:	1000                	addi	s0,sp,32
    8000409e:	84aa                	mv	s1,a0
  iunlock(ip);
    800040a0:	00000097          	auipc	ra,0x0
    800040a4:	e54080e7          	jalr	-428(ra) # 80003ef4 <iunlock>
  iput(ip);
    800040a8:	8526                	mv	a0,s1
    800040aa:	00000097          	auipc	ra,0x0
    800040ae:	f42080e7          	jalr	-190(ra) # 80003fec <iput>
}
    800040b2:	60e2                	ld	ra,24(sp)
    800040b4:	6442                	ld	s0,16(sp)
    800040b6:	64a2                	ld	s1,8(sp)
    800040b8:	6105                	addi	sp,sp,32
    800040ba:	8082                	ret

00000000800040bc <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800040bc:	1141                	addi	sp,sp,-16
    800040be:	e422                	sd	s0,8(sp)
    800040c0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800040c2:	411c                	lw	a5,0(a0)
    800040c4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800040c6:	415c                	lw	a5,4(a0)
    800040c8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800040ca:	04451783          	lh	a5,68(a0)
    800040ce:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800040d2:	04a51783          	lh	a5,74(a0)
    800040d6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800040da:	04c56783          	lwu	a5,76(a0)
    800040de:	e99c                	sd	a5,16(a1)
}
    800040e0:	6422                	ld	s0,8(sp)
    800040e2:	0141                	addi	sp,sp,16
    800040e4:	8082                	ret

00000000800040e6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800040e6:	457c                	lw	a5,76(a0)
    800040e8:	0ed7e963          	bltu	a5,a3,800041da <readi+0xf4>
{
    800040ec:	7159                	addi	sp,sp,-112
    800040ee:	f486                	sd	ra,104(sp)
    800040f0:	f0a2                	sd	s0,96(sp)
    800040f2:	eca6                	sd	s1,88(sp)
    800040f4:	e8ca                	sd	s2,80(sp)
    800040f6:	e4ce                	sd	s3,72(sp)
    800040f8:	e0d2                	sd	s4,64(sp)
    800040fa:	fc56                	sd	s5,56(sp)
    800040fc:	f85a                	sd	s6,48(sp)
    800040fe:	f45e                	sd	s7,40(sp)
    80004100:	f062                	sd	s8,32(sp)
    80004102:	ec66                	sd	s9,24(sp)
    80004104:	e86a                	sd	s10,16(sp)
    80004106:	e46e                	sd	s11,8(sp)
    80004108:	1880                	addi	s0,sp,112
    8000410a:	8b2a                	mv	s6,a0
    8000410c:	8bae                	mv	s7,a1
    8000410e:	8a32                	mv	s4,a2
    80004110:	84b6                	mv	s1,a3
    80004112:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80004114:	9f35                	addw	a4,a4,a3
    return 0;
    80004116:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80004118:	0ad76063          	bltu	a4,a3,800041b8 <readi+0xd2>
  if(off + n > ip->size)
    8000411c:	00e7f463          	bgeu	a5,a4,80004124 <readi+0x3e>
    n = ip->size - off;
    80004120:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80004124:	0a0a8963          	beqz	s5,800041d6 <readi+0xf0>
    80004128:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000412a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000412e:	5c7d                	li	s8,-1
    80004130:	a82d                	j	8000416a <readi+0x84>
    80004132:	020d1d93          	slli	s11,s10,0x20
    80004136:	020ddd93          	srli	s11,s11,0x20
    8000413a:	05890613          	addi	a2,s2,88
    8000413e:	86ee                	mv	a3,s11
    80004140:	963a                	add	a2,a2,a4
    80004142:	85d2                	mv	a1,s4
    80004144:	855e                	mv	a0,s7
    80004146:	ffffe097          	auipc	ra,0xffffe
    8000414a:	7e0080e7          	jalr	2016(ra) # 80002926 <either_copyout>
    8000414e:	05850d63          	beq	a0,s8,800041a8 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80004152:	854a                	mv	a0,s2
    80004154:	fffff097          	auipc	ra,0xfffff
    80004158:	5f6080e7          	jalr	1526(ra) # 8000374a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000415c:	013d09bb          	addw	s3,s10,s3
    80004160:	009d04bb          	addw	s1,s10,s1
    80004164:	9a6e                	add	s4,s4,s11
    80004166:	0559f763          	bgeu	s3,s5,800041b4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000416a:	00a4d59b          	srliw	a1,s1,0xa
    8000416e:	855a                	mv	a0,s6
    80004170:	00000097          	auipc	ra,0x0
    80004174:	89e080e7          	jalr	-1890(ra) # 80003a0e <bmap>
    80004178:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000417c:	cd85                	beqz	a1,800041b4 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000417e:	000b2503          	lw	a0,0(s6)
    80004182:	fffff097          	auipc	ra,0xfffff
    80004186:	498080e7          	jalr	1176(ra) # 8000361a <bread>
    8000418a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000418c:	3ff4f713          	andi	a4,s1,1023
    80004190:	40ec87bb          	subw	a5,s9,a4
    80004194:	413a86bb          	subw	a3,s5,s3
    80004198:	8d3e                	mv	s10,a5
    8000419a:	2781                	sext.w	a5,a5
    8000419c:	0006861b          	sext.w	a2,a3
    800041a0:	f8f679e3          	bgeu	a2,a5,80004132 <readi+0x4c>
    800041a4:	8d36                	mv	s10,a3
    800041a6:	b771                	j	80004132 <readi+0x4c>
      brelse(bp);
    800041a8:	854a                	mv	a0,s2
    800041aa:	fffff097          	auipc	ra,0xfffff
    800041ae:	5a0080e7          	jalr	1440(ra) # 8000374a <brelse>
      tot = -1;
    800041b2:	59fd                	li	s3,-1
  }
  return tot;
    800041b4:	0009851b          	sext.w	a0,s3
}
    800041b8:	70a6                	ld	ra,104(sp)
    800041ba:	7406                	ld	s0,96(sp)
    800041bc:	64e6                	ld	s1,88(sp)
    800041be:	6946                	ld	s2,80(sp)
    800041c0:	69a6                	ld	s3,72(sp)
    800041c2:	6a06                	ld	s4,64(sp)
    800041c4:	7ae2                	ld	s5,56(sp)
    800041c6:	7b42                	ld	s6,48(sp)
    800041c8:	7ba2                	ld	s7,40(sp)
    800041ca:	7c02                	ld	s8,32(sp)
    800041cc:	6ce2                	ld	s9,24(sp)
    800041ce:	6d42                	ld	s10,16(sp)
    800041d0:	6da2                	ld	s11,8(sp)
    800041d2:	6165                	addi	sp,sp,112
    800041d4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800041d6:	89d6                	mv	s3,s5
    800041d8:	bff1                	j	800041b4 <readi+0xce>
    return 0;
    800041da:	4501                	li	a0,0
}
    800041dc:	8082                	ret

00000000800041de <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800041de:	457c                	lw	a5,76(a0)
    800041e0:	10d7e863          	bltu	a5,a3,800042f0 <writei+0x112>
{
    800041e4:	7159                	addi	sp,sp,-112
    800041e6:	f486                	sd	ra,104(sp)
    800041e8:	f0a2                	sd	s0,96(sp)
    800041ea:	eca6                	sd	s1,88(sp)
    800041ec:	e8ca                	sd	s2,80(sp)
    800041ee:	e4ce                	sd	s3,72(sp)
    800041f0:	e0d2                	sd	s4,64(sp)
    800041f2:	fc56                	sd	s5,56(sp)
    800041f4:	f85a                	sd	s6,48(sp)
    800041f6:	f45e                	sd	s7,40(sp)
    800041f8:	f062                	sd	s8,32(sp)
    800041fa:	ec66                	sd	s9,24(sp)
    800041fc:	e86a                	sd	s10,16(sp)
    800041fe:	e46e                	sd	s11,8(sp)
    80004200:	1880                	addi	s0,sp,112
    80004202:	8aaa                	mv	s5,a0
    80004204:	8bae                	mv	s7,a1
    80004206:	8a32                	mv	s4,a2
    80004208:	8936                	mv	s2,a3
    8000420a:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    8000420c:	00e687bb          	addw	a5,a3,a4
    80004210:	0ed7e263          	bltu	a5,a3,800042f4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80004214:	00043737          	lui	a4,0x43
    80004218:	0ef76063          	bltu	a4,a5,800042f8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000421c:	0c0b0863          	beqz	s6,800042ec <writei+0x10e>
    80004220:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80004222:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80004226:	5c7d                	li	s8,-1
    80004228:	a091                	j	8000426c <writei+0x8e>
    8000422a:	020d1d93          	slli	s11,s10,0x20
    8000422e:	020ddd93          	srli	s11,s11,0x20
    80004232:	05848513          	addi	a0,s1,88
    80004236:	86ee                	mv	a3,s11
    80004238:	8652                	mv	a2,s4
    8000423a:	85de                	mv	a1,s7
    8000423c:	953a                	add	a0,a0,a4
    8000423e:	ffffe097          	auipc	ra,0xffffe
    80004242:	73e080e7          	jalr	1854(ra) # 8000297c <either_copyin>
    80004246:	07850263          	beq	a0,s8,800042aa <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000424a:	8526                	mv	a0,s1
    8000424c:	00000097          	auipc	ra,0x0
    80004250:	788080e7          	jalr	1928(ra) # 800049d4 <log_write>
    brelse(bp);
    80004254:	8526                	mv	a0,s1
    80004256:	fffff097          	auipc	ra,0xfffff
    8000425a:	4f4080e7          	jalr	1268(ra) # 8000374a <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000425e:	013d09bb          	addw	s3,s10,s3
    80004262:	012d093b          	addw	s2,s10,s2
    80004266:	9a6e                	add	s4,s4,s11
    80004268:	0569f663          	bgeu	s3,s6,800042b4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    8000426c:	00a9559b          	srliw	a1,s2,0xa
    80004270:	8556                	mv	a0,s5
    80004272:	fffff097          	auipc	ra,0xfffff
    80004276:	79c080e7          	jalr	1948(ra) # 80003a0e <bmap>
    8000427a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000427e:	c99d                	beqz	a1,800042b4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80004280:	000aa503          	lw	a0,0(s5)
    80004284:	fffff097          	auipc	ra,0xfffff
    80004288:	396080e7          	jalr	918(ra) # 8000361a <bread>
    8000428c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000428e:	3ff97713          	andi	a4,s2,1023
    80004292:	40ec87bb          	subw	a5,s9,a4
    80004296:	413b06bb          	subw	a3,s6,s3
    8000429a:	8d3e                	mv	s10,a5
    8000429c:	2781                	sext.w	a5,a5
    8000429e:	0006861b          	sext.w	a2,a3
    800042a2:	f8f674e3          	bgeu	a2,a5,8000422a <writei+0x4c>
    800042a6:	8d36                	mv	s10,a3
    800042a8:	b749                	j	8000422a <writei+0x4c>
      brelse(bp);
    800042aa:	8526                	mv	a0,s1
    800042ac:	fffff097          	auipc	ra,0xfffff
    800042b0:	49e080e7          	jalr	1182(ra) # 8000374a <brelse>
  }

  if(off > ip->size)
    800042b4:	04caa783          	lw	a5,76(s5)
    800042b8:	0127f463          	bgeu	a5,s2,800042c0 <writei+0xe2>
    ip->size = off;
    800042bc:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800042c0:	8556                	mv	a0,s5
    800042c2:	00000097          	auipc	ra,0x0
    800042c6:	aa4080e7          	jalr	-1372(ra) # 80003d66 <iupdate>

  return tot;
    800042ca:	0009851b          	sext.w	a0,s3
}
    800042ce:	70a6                	ld	ra,104(sp)
    800042d0:	7406                	ld	s0,96(sp)
    800042d2:	64e6                	ld	s1,88(sp)
    800042d4:	6946                	ld	s2,80(sp)
    800042d6:	69a6                	ld	s3,72(sp)
    800042d8:	6a06                	ld	s4,64(sp)
    800042da:	7ae2                	ld	s5,56(sp)
    800042dc:	7b42                	ld	s6,48(sp)
    800042de:	7ba2                	ld	s7,40(sp)
    800042e0:	7c02                	ld	s8,32(sp)
    800042e2:	6ce2                	ld	s9,24(sp)
    800042e4:	6d42                	ld	s10,16(sp)
    800042e6:	6da2                	ld	s11,8(sp)
    800042e8:	6165                	addi	sp,sp,112
    800042ea:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800042ec:	89da                	mv	s3,s6
    800042ee:	bfc9                	j	800042c0 <writei+0xe2>
    return -1;
    800042f0:	557d                	li	a0,-1
}
    800042f2:	8082                	ret
    return -1;
    800042f4:	557d                	li	a0,-1
    800042f6:	bfe1                	j	800042ce <writei+0xf0>
    return -1;
    800042f8:	557d                	li	a0,-1
    800042fa:	bfd1                	j	800042ce <writei+0xf0>

00000000800042fc <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800042fc:	1141                	addi	sp,sp,-16
    800042fe:	e406                	sd	ra,8(sp)
    80004300:	e022                	sd	s0,0(sp)
    80004302:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004304:	4639                	li	a2,14
    80004306:	ffffd097          	auipc	ra,0xffffd
    8000430a:	b64080e7          	jalr	-1180(ra) # 80000e6a <strncmp>
}
    8000430e:	60a2                	ld	ra,8(sp)
    80004310:	6402                	ld	s0,0(sp)
    80004312:	0141                	addi	sp,sp,16
    80004314:	8082                	ret

0000000080004316 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004316:	7139                	addi	sp,sp,-64
    80004318:	fc06                	sd	ra,56(sp)
    8000431a:	f822                	sd	s0,48(sp)
    8000431c:	f426                	sd	s1,40(sp)
    8000431e:	f04a                	sd	s2,32(sp)
    80004320:	ec4e                	sd	s3,24(sp)
    80004322:	e852                	sd	s4,16(sp)
    80004324:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004326:	04451703          	lh	a4,68(a0)
    8000432a:	4785                	li	a5,1
    8000432c:	00f71a63          	bne	a4,a5,80004340 <dirlookup+0x2a>
    80004330:	892a                	mv	s2,a0
    80004332:	89ae                	mv	s3,a1
    80004334:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004336:	457c                	lw	a5,76(a0)
    80004338:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000433a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000433c:	e79d                	bnez	a5,8000436a <dirlookup+0x54>
    8000433e:	a8a5                	j	800043b6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80004340:	00004517          	auipc	a0,0x4
    80004344:	46850513          	addi	a0,a0,1128 # 800087a8 <syscalls+0x1c8>
    80004348:	ffffc097          	auipc	ra,0xffffc
    8000434c:	1f8080e7          	jalr	504(ra) # 80000540 <panic>
      panic("dirlookup read");
    80004350:	00004517          	auipc	a0,0x4
    80004354:	47050513          	addi	a0,a0,1136 # 800087c0 <syscalls+0x1e0>
    80004358:	ffffc097          	auipc	ra,0xffffc
    8000435c:	1e8080e7          	jalr	488(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004360:	24c1                	addiw	s1,s1,16
    80004362:	04c92783          	lw	a5,76(s2)
    80004366:	04f4f763          	bgeu	s1,a5,800043b4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000436a:	4741                	li	a4,16
    8000436c:	86a6                	mv	a3,s1
    8000436e:	fc040613          	addi	a2,s0,-64
    80004372:	4581                	li	a1,0
    80004374:	854a                	mv	a0,s2
    80004376:	00000097          	auipc	ra,0x0
    8000437a:	d70080e7          	jalr	-656(ra) # 800040e6 <readi>
    8000437e:	47c1                	li	a5,16
    80004380:	fcf518e3          	bne	a0,a5,80004350 <dirlookup+0x3a>
    if(de.inum == 0)
    80004384:	fc045783          	lhu	a5,-64(s0)
    80004388:	dfe1                	beqz	a5,80004360 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000438a:	fc240593          	addi	a1,s0,-62
    8000438e:	854e                	mv	a0,s3
    80004390:	00000097          	auipc	ra,0x0
    80004394:	f6c080e7          	jalr	-148(ra) # 800042fc <namecmp>
    80004398:	f561                	bnez	a0,80004360 <dirlookup+0x4a>
      if(poff)
    8000439a:	000a0463          	beqz	s4,800043a2 <dirlookup+0x8c>
        *poff = off;
    8000439e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800043a2:	fc045583          	lhu	a1,-64(s0)
    800043a6:	00092503          	lw	a0,0(s2)
    800043aa:	fffff097          	auipc	ra,0xfffff
    800043ae:	74e080e7          	jalr	1870(ra) # 80003af8 <iget>
    800043b2:	a011                	j	800043b6 <dirlookup+0xa0>
  return 0;
    800043b4:	4501                	li	a0,0
}
    800043b6:	70e2                	ld	ra,56(sp)
    800043b8:	7442                	ld	s0,48(sp)
    800043ba:	74a2                	ld	s1,40(sp)
    800043bc:	7902                	ld	s2,32(sp)
    800043be:	69e2                	ld	s3,24(sp)
    800043c0:	6a42                	ld	s4,16(sp)
    800043c2:	6121                	addi	sp,sp,64
    800043c4:	8082                	ret

00000000800043c6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800043c6:	711d                	addi	sp,sp,-96
    800043c8:	ec86                	sd	ra,88(sp)
    800043ca:	e8a2                	sd	s0,80(sp)
    800043cc:	e4a6                	sd	s1,72(sp)
    800043ce:	e0ca                	sd	s2,64(sp)
    800043d0:	fc4e                	sd	s3,56(sp)
    800043d2:	f852                	sd	s4,48(sp)
    800043d4:	f456                	sd	s5,40(sp)
    800043d6:	f05a                	sd	s6,32(sp)
    800043d8:	ec5e                	sd	s7,24(sp)
    800043da:	e862                	sd	s8,16(sp)
    800043dc:	e466                	sd	s9,8(sp)
    800043de:	e06a                	sd	s10,0(sp)
    800043e0:	1080                	addi	s0,sp,96
    800043e2:	84aa                	mv	s1,a0
    800043e4:	8b2e                	mv	s6,a1
    800043e6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800043e8:	00054703          	lbu	a4,0(a0)
    800043ec:	02f00793          	li	a5,47
    800043f0:	02f70363          	beq	a4,a5,80004416 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800043f4:	ffffe097          	auipc	ra,0xffffe
    800043f8:	83c080e7          	jalr	-1988(ra) # 80001c30 <myproc>
    800043fc:	15053503          	ld	a0,336(a0)
    80004400:	00000097          	auipc	ra,0x0
    80004404:	9f4080e7          	jalr	-1548(ra) # 80003df4 <idup>
    80004408:	8a2a                	mv	s4,a0
  while(*path == '/')
    8000440a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    8000440e:	4cb5                	li	s9,13
  len = path - s;
    80004410:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80004412:	4c05                	li	s8,1
    80004414:	a87d                	j	800044d2 <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80004416:	4585                	li	a1,1
    80004418:	4505                	li	a0,1
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	6de080e7          	jalr	1758(ra) # 80003af8 <iget>
    80004422:	8a2a                	mv	s4,a0
    80004424:	b7dd                	j	8000440a <namex+0x44>
      iunlockput(ip);
    80004426:	8552                	mv	a0,s4
    80004428:	00000097          	auipc	ra,0x0
    8000442c:	c6c080e7          	jalr	-916(ra) # 80004094 <iunlockput>
      return 0;
    80004430:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80004432:	8552                	mv	a0,s4
    80004434:	60e6                	ld	ra,88(sp)
    80004436:	6446                	ld	s0,80(sp)
    80004438:	64a6                	ld	s1,72(sp)
    8000443a:	6906                	ld	s2,64(sp)
    8000443c:	79e2                	ld	s3,56(sp)
    8000443e:	7a42                	ld	s4,48(sp)
    80004440:	7aa2                	ld	s5,40(sp)
    80004442:	7b02                	ld	s6,32(sp)
    80004444:	6be2                	ld	s7,24(sp)
    80004446:	6c42                	ld	s8,16(sp)
    80004448:	6ca2                	ld	s9,8(sp)
    8000444a:	6d02                	ld	s10,0(sp)
    8000444c:	6125                	addi	sp,sp,96
    8000444e:	8082                	ret
      iunlock(ip);
    80004450:	8552                	mv	a0,s4
    80004452:	00000097          	auipc	ra,0x0
    80004456:	aa2080e7          	jalr	-1374(ra) # 80003ef4 <iunlock>
      return ip;
    8000445a:	bfe1                	j	80004432 <namex+0x6c>
      iunlockput(ip);
    8000445c:	8552                	mv	a0,s4
    8000445e:	00000097          	auipc	ra,0x0
    80004462:	c36080e7          	jalr	-970(ra) # 80004094 <iunlockput>
      return 0;
    80004466:	8a4e                	mv	s4,s3
    80004468:	b7e9                	j	80004432 <namex+0x6c>
  len = path - s;
    8000446a:	40998633          	sub	a2,s3,s1
    8000446e:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80004472:	09acd863          	bge	s9,s10,80004502 <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80004476:	4639                	li	a2,14
    80004478:	85a6                	mv	a1,s1
    8000447a:	8556                	mv	a0,s5
    8000447c:	ffffd097          	auipc	ra,0xffffd
    80004480:	97a080e7          	jalr	-1670(ra) # 80000df6 <memmove>
    80004484:	84ce                	mv	s1,s3
  while(*path == '/')
    80004486:	0004c783          	lbu	a5,0(s1)
    8000448a:	01279763          	bne	a5,s2,80004498 <namex+0xd2>
    path++;
    8000448e:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004490:	0004c783          	lbu	a5,0(s1)
    80004494:	ff278de3          	beq	a5,s2,8000448e <namex+0xc8>
    ilock(ip);
    80004498:	8552                	mv	a0,s4
    8000449a:	00000097          	auipc	ra,0x0
    8000449e:	998080e7          	jalr	-1640(ra) # 80003e32 <ilock>
    if(ip->type != T_DIR){
    800044a2:	044a1783          	lh	a5,68(s4)
    800044a6:	f98790e3          	bne	a5,s8,80004426 <namex+0x60>
    if(nameiparent && *path == '\0'){
    800044aa:	000b0563          	beqz	s6,800044b4 <namex+0xee>
    800044ae:	0004c783          	lbu	a5,0(s1)
    800044b2:	dfd9                	beqz	a5,80004450 <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    800044b4:	865e                	mv	a2,s7
    800044b6:	85d6                	mv	a1,s5
    800044b8:	8552                	mv	a0,s4
    800044ba:	00000097          	auipc	ra,0x0
    800044be:	e5c080e7          	jalr	-420(ra) # 80004316 <dirlookup>
    800044c2:	89aa                	mv	s3,a0
    800044c4:	dd41                	beqz	a0,8000445c <namex+0x96>
    iunlockput(ip);
    800044c6:	8552                	mv	a0,s4
    800044c8:	00000097          	auipc	ra,0x0
    800044cc:	bcc080e7          	jalr	-1076(ra) # 80004094 <iunlockput>
    ip = next;
    800044d0:	8a4e                	mv	s4,s3
  while(*path == '/')
    800044d2:	0004c783          	lbu	a5,0(s1)
    800044d6:	01279763          	bne	a5,s2,800044e4 <namex+0x11e>
    path++;
    800044da:	0485                	addi	s1,s1,1
  while(*path == '/')
    800044dc:	0004c783          	lbu	a5,0(s1)
    800044e0:	ff278de3          	beq	a5,s2,800044da <namex+0x114>
  if(*path == 0)
    800044e4:	cb9d                	beqz	a5,8000451a <namex+0x154>
  while(*path != '/' && *path != 0)
    800044e6:	0004c783          	lbu	a5,0(s1)
    800044ea:	89a6                	mv	s3,s1
  len = path - s;
    800044ec:	8d5e                	mv	s10,s7
    800044ee:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    800044f0:	01278963          	beq	a5,s2,80004502 <namex+0x13c>
    800044f4:	dbbd                	beqz	a5,8000446a <namex+0xa4>
    path++;
    800044f6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800044f8:	0009c783          	lbu	a5,0(s3)
    800044fc:	ff279ce3          	bne	a5,s2,800044f4 <namex+0x12e>
    80004500:	b7ad                	j	8000446a <namex+0xa4>
    memmove(name, s, len);
    80004502:	2601                	sext.w	a2,a2
    80004504:	85a6                	mv	a1,s1
    80004506:	8556                	mv	a0,s5
    80004508:	ffffd097          	auipc	ra,0xffffd
    8000450c:	8ee080e7          	jalr	-1810(ra) # 80000df6 <memmove>
    name[len] = 0;
    80004510:	9d56                	add	s10,s10,s5
    80004512:	000d0023          	sb	zero,0(s10)
    80004516:	84ce                	mv	s1,s3
    80004518:	b7bd                	j	80004486 <namex+0xc0>
  if(nameiparent){
    8000451a:	f00b0ce3          	beqz	s6,80004432 <namex+0x6c>
    iput(ip);
    8000451e:	8552                	mv	a0,s4
    80004520:	00000097          	auipc	ra,0x0
    80004524:	acc080e7          	jalr	-1332(ra) # 80003fec <iput>
    return 0;
    80004528:	4a01                	li	s4,0
    8000452a:	b721                	j	80004432 <namex+0x6c>

000000008000452c <dirlink>:
{
    8000452c:	7139                	addi	sp,sp,-64
    8000452e:	fc06                	sd	ra,56(sp)
    80004530:	f822                	sd	s0,48(sp)
    80004532:	f426                	sd	s1,40(sp)
    80004534:	f04a                	sd	s2,32(sp)
    80004536:	ec4e                	sd	s3,24(sp)
    80004538:	e852                	sd	s4,16(sp)
    8000453a:	0080                	addi	s0,sp,64
    8000453c:	892a                	mv	s2,a0
    8000453e:	8a2e                	mv	s4,a1
    80004540:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004542:	4601                	li	a2,0
    80004544:	00000097          	auipc	ra,0x0
    80004548:	dd2080e7          	jalr	-558(ra) # 80004316 <dirlookup>
    8000454c:	e93d                	bnez	a0,800045c2 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000454e:	04c92483          	lw	s1,76(s2)
    80004552:	c49d                	beqz	s1,80004580 <dirlink+0x54>
    80004554:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004556:	4741                	li	a4,16
    80004558:	86a6                	mv	a3,s1
    8000455a:	fc040613          	addi	a2,s0,-64
    8000455e:	4581                	li	a1,0
    80004560:	854a                	mv	a0,s2
    80004562:	00000097          	auipc	ra,0x0
    80004566:	b84080e7          	jalr	-1148(ra) # 800040e6 <readi>
    8000456a:	47c1                	li	a5,16
    8000456c:	06f51163          	bne	a0,a5,800045ce <dirlink+0xa2>
    if(de.inum == 0)
    80004570:	fc045783          	lhu	a5,-64(s0)
    80004574:	c791                	beqz	a5,80004580 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004576:	24c1                	addiw	s1,s1,16
    80004578:	04c92783          	lw	a5,76(s2)
    8000457c:	fcf4ede3          	bltu	s1,a5,80004556 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80004580:	4639                	li	a2,14
    80004582:	85d2                	mv	a1,s4
    80004584:	fc240513          	addi	a0,s0,-62
    80004588:	ffffd097          	auipc	ra,0xffffd
    8000458c:	91e080e7          	jalr	-1762(ra) # 80000ea6 <strncpy>
  de.inum = inum;
    80004590:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004594:	4741                	li	a4,16
    80004596:	86a6                	mv	a3,s1
    80004598:	fc040613          	addi	a2,s0,-64
    8000459c:	4581                	li	a1,0
    8000459e:	854a                	mv	a0,s2
    800045a0:	00000097          	auipc	ra,0x0
    800045a4:	c3e080e7          	jalr	-962(ra) # 800041de <writei>
    800045a8:	1541                	addi	a0,a0,-16
    800045aa:	00a03533          	snez	a0,a0
    800045ae:	40a00533          	neg	a0,a0
}
    800045b2:	70e2                	ld	ra,56(sp)
    800045b4:	7442                	ld	s0,48(sp)
    800045b6:	74a2                	ld	s1,40(sp)
    800045b8:	7902                	ld	s2,32(sp)
    800045ba:	69e2                	ld	s3,24(sp)
    800045bc:	6a42                	ld	s4,16(sp)
    800045be:	6121                	addi	sp,sp,64
    800045c0:	8082                	ret
    iput(ip);
    800045c2:	00000097          	auipc	ra,0x0
    800045c6:	a2a080e7          	jalr	-1494(ra) # 80003fec <iput>
    return -1;
    800045ca:	557d                	li	a0,-1
    800045cc:	b7dd                	j	800045b2 <dirlink+0x86>
      panic("dirlink read");
    800045ce:	00004517          	auipc	a0,0x4
    800045d2:	20250513          	addi	a0,a0,514 # 800087d0 <syscalls+0x1f0>
    800045d6:	ffffc097          	auipc	ra,0xffffc
    800045da:	f6a080e7          	jalr	-150(ra) # 80000540 <panic>

00000000800045de <namei>:

struct inode*
namei(char *path)
{
    800045de:	1101                	addi	sp,sp,-32
    800045e0:	ec06                	sd	ra,24(sp)
    800045e2:	e822                	sd	s0,16(sp)
    800045e4:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800045e6:	fe040613          	addi	a2,s0,-32
    800045ea:	4581                	li	a1,0
    800045ec:	00000097          	auipc	ra,0x0
    800045f0:	dda080e7          	jalr	-550(ra) # 800043c6 <namex>
}
    800045f4:	60e2                	ld	ra,24(sp)
    800045f6:	6442                	ld	s0,16(sp)
    800045f8:	6105                	addi	sp,sp,32
    800045fa:	8082                	ret

00000000800045fc <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800045fc:	1141                	addi	sp,sp,-16
    800045fe:	e406                	sd	ra,8(sp)
    80004600:	e022                	sd	s0,0(sp)
    80004602:	0800                	addi	s0,sp,16
    80004604:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80004606:	4585                	li	a1,1
    80004608:	00000097          	auipc	ra,0x0
    8000460c:	dbe080e7          	jalr	-578(ra) # 800043c6 <namex>
}
    80004610:	60a2                	ld	ra,8(sp)
    80004612:	6402                	ld	s0,0(sp)
    80004614:	0141                	addi	sp,sp,16
    80004616:	8082                	ret

0000000080004618 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004618:	1101                	addi	sp,sp,-32
    8000461a:	ec06                	sd	ra,24(sp)
    8000461c:	e822                	sd	s0,16(sp)
    8000461e:	e426                	sd	s1,8(sp)
    80004620:	e04a                	sd	s2,0(sp)
    80004622:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004624:	0001c917          	auipc	s2,0x1c
    80004628:	6fc90913          	addi	s2,s2,1788 # 80020d20 <log>
    8000462c:	01892583          	lw	a1,24(s2)
    80004630:	02892503          	lw	a0,40(s2)
    80004634:	fffff097          	auipc	ra,0xfffff
    80004638:	fe6080e7          	jalr	-26(ra) # 8000361a <bread>
    8000463c:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000463e:	02c92683          	lw	a3,44(s2)
    80004642:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004644:	02d05863          	blez	a3,80004674 <write_head+0x5c>
    80004648:	0001c797          	auipc	a5,0x1c
    8000464c:	70878793          	addi	a5,a5,1800 # 80020d50 <log+0x30>
    80004650:	05c50713          	addi	a4,a0,92
    80004654:	36fd                	addiw	a3,a3,-1
    80004656:	02069613          	slli	a2,a3,0x20
    8000465a:	01e65693          	srli	a3,a2,0x1e
    8000465e:	0001c617          	auipc	a2,0x1c
    80004662:	6f660613          	addi	a2,a2,1782 # 80020d54 <log+0x34>
    80004666:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004668:	4390                	lw	a2,0(a5)
    8000466a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000466c:	0791                	addi	a5,a5,4
    8000466e:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    80004670:	fed79ce3          	bne	a5,a3,80004668 <write_head+0x50>
  }
  bwrite(buf);
    80004674:	8526                	mv	a0,s1
    80004676:	fffff097          	auipc	ra,0xfffff
    8000467a:	096080e7          	jalr	150(ra) # 8000370c <bwrite>
  brelse(buf);
    8000467e:	8526                	mv	a0,s1
    80004680:	fffff097          	auipc	ra,0xfffff
    80004684:	0ca080e7          	jalr	202(ra) # 8000374a <brelse>
}
    80004688:	60e2                	ld	ra,24(sp)
    8000468a:	6442                	ld	s0,16(sp)
    8000468c:	64a2                	ld	s1,8(sp)
    8000468e:	6902                	ld	s2,0(sp)
    80004690:	6105                	addi	sp,sp,32
    80004692:	8082                	ret

0000000080004694 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004694:	0001c797          	auipc	a5,0x1c
    80004698:	6b87a783          	lw	a5,1720(a5) # 80020d4c <log+0x2c>
    8000469c:	0af05d63          	blez	a5,80004756 <install_trans+0xc2>
{
    800046a0:	7139                	addi	sp,sp,-64
    800046a2:	fc06                	sd	ra,56(sp)
    800046a4:	f822                	sd	s0,48(sp)
    800046a6:	f426                	sd	s1,40(sp)
    800046a8:	f04a                	sd	s2,32(sp)
    800046aa:	ec4e                	sd	s3,24(sp)
    800046ac:	e852                	sd	s4,16(sp)
    800046ae:	e456                	sd	s5,8(sp)
    800046b0:	e05a                	sd	s6,0(sp)
    800046b2:	0080                	addi	s0,sp,64
    800046b4:	8b2a                	mv	s6,a0
    800046b6:	0001ca97          	auipc	s5,0x1c
    800046ba:	69aa8a93          	addi	s5,s5,1690 # 80020d50 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046be:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046c0:	0001c997          	auipc	s3,0x1c
    800046c4:	66098993          	addi	s3,s3,1632 # 80020d20 <log>
    800046c8:	a00d                	j	800046ea <install_trans+0x56>
    brelse(lbuf);
    800046ca:	854a                	mv	a0,s2
    800046cc:	fffff097          	auipc	ra,0xfffff
    800046d0:	07e080e7          	jalr	126(ra) # 8000374a <brelse>
    brelse(dbuf);
    800046d4:	8526                	mv	a0,s1
    800046d6:	fffff097          	auipc	ra,0xfffff
    800046da:	074080e7          	jalr	116(ra) # 8000374a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046de:	2a05                	addiw	s4,s4,1
    800046e0:	0a91                	addi	s5,s5,4
    800046e2:	02c9a783          	lw	a5,44(s3)
    800046e6:	04fa5e63          	bge	s4,a5,80004742 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800046ea:	0189a583          	lw	a1,24(s3)
    800046ee:	014585bb          	addw	a1,a1,s4
    800046f2:	2585                	addiw	a1,a1,1
    800046f4:	0289a503          	lw	a0,40(s3)
    800046f8:	fffff097          	auipc	ra,0xfffff
    800046fc:	f22080e7          	jalr	-222(ra) # 8000361a <bread>
    80004700:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004702:	000aa583          	lw	a1,0(s5)
    80004706:	0289a503          	lw	a0,40(s3)
    8000470a:	fffff097          	auipc	ra,0xfffff
    8000470e:	f10080e7          	jalr	-240(ra) # 8000361a <bread>
    80004712:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004714:	40000613          	li	a2,1024
    80004718:	05890593          	addi	a1,s2,88
    8000471c:	05850513          	addi	a0,a0,88
    80004720:	ffffc097          	auipc	ra,0xffffc
    80004724:	6d6080e7          	jalr	1750(ra) # 80000df6 <memmove>
    bwrite(dbuf);  // write dst to disk
    80004728:	8526                	mv	a0,s1
    8000472a:	fffff097          	auipc	ra,0xfffff
    8000472e:	fe2080e7          	jalr	-30(ra) # 8000370c <bwrite>
    if(recovering == 0)
    80004732:	f80b1ce3          	bnez	s6,800046ca <install_trans+0x36>
      bunpin(dbuf);
    80004736:	8526                	mv	a0,s1
    80004738:	fffff097          	auipc	ra,0xfffff
    8000473c:	0ec080e7          	jalr	236(ra) # 80003824 <bunpin>
    80004740:	b769                	j	800046ca <install_trans+0x36>
}
    80004742:	70e2                	ld	ra,56(sp)
    80004744:	7442                	ld	s0,48(sp)
    80004746:	74a2                	ld	s1,40(sp)
    80004748:	7902                	ld	s2,32(sp)
    8000474a:	69e2                	ld	s3,24(sp)
    8000474c:	6a42                	ld	s4,16(sp)
    8000474e:	6aa2                	ld	s5,8(sp)
    80004750:	6b02                	ld	s6,0(sp)
    80004752:	6121                	addi	sp,sp,64
    80004754:	8082                	ret
    80004756:	8082                	ret

0000000080004758 <initlog>:
{
    80004758:	7179                	addi	sp,sp,-48
    8000475a:	f406                	sd	ra,40(sp)
    8000475c:	f022                	sd	s0,32(sp)
    8000475e:	ec26                	sd	s1,24(sp)
    80004760:	e84a                	sd	s2,16(sp)
    80004762:	e44e                	sd	s3,8(sp)
    80004764:	1800                	addi	s0,sp,48
    80004766:	892a                	mv	s2,a0
    80004768:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000476a:	0001c497          	auipc	s1,0x1c
    8000476e:	5b648493          	addi	s1,s1,1462 # 80020d20 <log>
    80004772:	00004597          	auipc	a1,0x4
    80004776:	06e58593          	addi	a1,a1,110 # 800087e0 <syscalls+0x200>
    8000477a:	8526                	mv	a0,s1
    8000477c:	ffffc097          	auipc	ra,0xffffc
    80004780:	492080e7          	jalr	1170(ra) # 80000c0e <initlock>
  log.start = sb->logstart;
    80004784:	0149a583          	lw	a1,20(s3)
    80004788:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000478a:	0109a783          	lw	a5,16(s3)
    8000478e:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004790:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004794:	854a                	mv	a0,s2
    80004796:	fffff097          	auipc	ra,0xfffff
    8000479a:	e84080e7          	jalr	-380(ra) # 8000361a <bread>
  log.lh.n = lh->n;
    8000479e:	4d34                	lw	a3,88(a0)
    800047a0:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800047a2:	02d05663          	blez	a3,800047ce <initlog+0x76>
    800047a6:	05c50793          	addi	a5,a0,92
    800047aa:	0001c717          	auipc	a4,0x1c
    800047ae:	5a670713          	addi	a4,a4,1446 # 80020d50 <log+0x30>
    800047b2:	36fd                	addiw	a3,a3,-1
    800047b4:	02069613          	slli	a2,a3,0x20
    800047b8:	01e65693          	srli	a3,a2,0x1e
    800047bc:	06050613          	addi	a2,a0,96
    800047c0:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800047c2:	4390                	lw	a2,0(a5)
    800047c4:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800047c6:	0791                	addi	a5,a5,4
    800047c8:	0711                	addi	a4,a4,4
    800047ca:	fed79ce3          	bne	a5,a3,800047c2 <initlog+0x6a>
  brelse(buf);
    800047ce:	fffff097          	auipc	ra,0xfffff
    800047d2:	f7c080e7          	jalr	-132(ra) # 8000374a <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800047d6:	4505                	li	a0,1
    800047d8:	00000097          	auipc	ra,0x0
    800047dc:	ebc080e7          	jalr	-324(ra) # 80004694 <install_trans>
  log.lh.n = 0;
    800047e0:	0001c797          	auipc	a5,0x1c
    800047e4:	5607a623          	sw	zero,1388(a5) # 80020d4c <log+0x2c>
  write_head(); // clear the log
    800047e8:	00000097          	auipc	ra,0x0
    800047ec:	e30080e7          	jalr	-464(ra) # 80004618 <write_head>
}
    800047f0:	70a2                	ld	ra,40(sp)
    800047f2:	7402                	ld	s0,32(sp)
    800047f4:	64e2                	ld	s1,24(sp)
    800047f6:	6942                	ld	s2,16(sp)
    800047f8:	69a2                	ld	s3,8(sp)
    800047fa:	6145                	addi	sp,sp,48
    800047fc:	8082                	ret

00000000800047fe <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800047fe:	1101                	addi	sp,sp,-32
    80004800:	ec06                	sd	ra,24(sp)
    80004802:	e822                	sd	s0,16(sp)
    80004804:	e426                	sd	s1,8(sp)
    80004806:	e04a                	sd	s2,0(sp)
    80004808:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    8000480a:	0001c517          	auipc	a0,0x1c
    8000480e:	51650513          	addi	a0,a0,1302 # 80020d20 <log>
    80004812:	ffffc097          	auipc	ra,0xffffc
    80004816:	48c080e7          	jalr	1164(ra) # 80000c9e <acquire>
  while(1){
    if(log.committing){
    8000481a:	0001c497          	auipc	s1,0x1c
    8000481e:	50648493          	addi	s1,s1,1286 # 80020d20 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004822:	4979                	li	s2,30
    80004824:	a039                	j	80004832 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004826:	85a6                	mv	a1,s1
    80004828:	8526                	mv	a0,s1
    8000482a:	ffffe097          	auipc	ra,0xffffe
    8000482e:	cf4080e7          	jalr	-780(ra) # 8000251e <sleep>
    if(log.committing){
    80004832:	50dc                	lw	a5,36(s1)
    80004834:	fbed                	bnez	a5,80004826 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004836:	5098                	lw	a4,32(s1)
    80004838:	2705                	addiw	a4,a4,1
    8000483a:	0007069b          	sext.w	a3,a4
    8000483e:	0027179b          	slliw	a5,a4,0x2
    80004842:	9fb9                	addw	a5,a5,a4
    80004844:	0017979b          	slliw	a5,a5,0x1
    80004848:	54d8                	lw	a4,44(s1)
    8000484a:	9fb9                	addw	a5,a5,a4
    8000484c:	00f95963          	bge	s2,a5,8000485e <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004850:	85a6                	mv	a1,s1
    80004852:	8526                	mv	a0,s1
    80004854:	ffffe097          	auipc	ra,0xffffe
    80004858:	cca080e7          	jalr	-822(ra) # 8000251e <sleep>
    8000485c:	bfd9                	j	80004832 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000485e:	0001c517          	auipc	a0,0x1c
    80004862:	4c250513          	addi	a0,a0,1218 # 80020d20 <log>
    80004866:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004868:	ffffc097          	auipc	ra,0xffffc
    8000486c:	4ea080e7          	jalr	1258(ra) # 80000d52 <release>
      break;
    }
  }
}
    80004870:	60e2                	ld	ra,24(sp)
    80004872:	6442                	ld	s0,16(sp)
    80004874:	64a2                	ld	s1,8(sp)
    80004876:	6902                	ld	s2,0(sp)
    80004878:	6105                	addi	sp,sp,32
    8000487a:	8082                	ret

000000008000487c <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000487c:	7139                	addi	sp,sp,-64
    8000487e:	fc06                	sd	ra,56(sp)
    80004880:	f822                	sd	s0,48(sp)
    80004882:	f426                	sd	s1,40(sp)
    80004884:	f04a                	sd	s2,32(sp)
    80004886:	ec4e                	sd	s3,24(sp)
    80004888:	e852                	sd	s4,16(sp)
    8000488a:	e456                	sd	s5,8(sp)
    8000488c:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000488e:	0001c497          	auipc	s1,0x1c
    80004892:	49248493          	addi	s1,s1,1170 # 80020d20 <log>
    80004896:	8526                	mv	a0,s1
    80004898:	ffffc097          	auipc	ra,0xffffc
    8000489c:	406080e7          	jalr	1030(ra) # 80000c9e <acquire>
  log.outstanding -= 1;
    800048a0:	509c                	lw	a5,32(s1)
    800048a2:	37fd                	addiw	a5,a5,-1
    800048a4:	0007891b          	sext.w	s2,a5
    800048a8:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800048aa:	50dc                	lw	a5,36(s1)
    800048ac:	e7b9                	bnez	a5,800048fa <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800048ae:	04091e63          	bnez	s2,8000490a <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800048b2:	0001c497          	auipc	s1,0x1c
    800048b6:	46e48493          	addi	s1,s1,1134 # 80020d20 <log>
    800048ba:	4785                	li	a5,1
    800048bc:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800048be:	8526                	mv	a0,s1
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	492080e7          	jalr	1170(ra) # 80000d52 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800048c8:	54dc                	lw	a5,44(s1)
    800048ca:	06f04763          	bgtz	a5,80004938 <end_op+0xbc>
    acquire(&log.lock);
    800048ce:	0001c497          	auipc	s1,0x1c
    800048d2:	45248493          	addi	s1,s1,1106 # 80020d20 <log>
    800048d6:	8526                	mv	a0,s1
    800048d8:	ffffc097          	auipc	ra,0xffffc
    800048dc:	3c6080e7          	jalr	966(ra) # 80000c9e <acquire>
    log.committing = 0;
    800048e0:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800048e4:	8526                	mv	a0,s1
    800048e6:	ffffe097          	auipc	ra,0xffffe
    800048ea:	c9c080e7          	jalr	-868(ra) # 80002582 <wakeup>
    release(&log.lock);
    800048ee:	8526                	mv	a0,s1
    800048f0:	ffffc097          	auipc	ra,0xffffc
    800048f4:	462080e7          	jalr	1122(ra) # 80000d52 <release>
}
    800048f8:	a03d                	j	80004926 <end_op+0xaa>
    panic("log.committing");
    800048fa:	00004517          	auipc	a0,0x4
    800048fe:	eee50513          	addi	a0,a0,-274 # 800087e8 <syscalls+0x208>
    80004902:	ffffc097          	auipc	ra,0xffffc
    80004906:	c3e080e7          	jalr	-962(ra) # 80000540 <panic>
    wakeup(&log);
    8000490a:	0001c497          	auipc	s1,0x1c
    8000490e:	41648493          	addi	s1,s1,1046 # 80020d20 <log>
    80004912:	8526                	mv	a0,s1
    80004914:	ffffe097          	auipc	ra,0xffffe
    80004918:	c6e080e7          	jalr	-914(ra) # 80002582 <wakeup>
  release(&log.lock);
    8000491c:	8526                	mv	a0,s1
    8000491e:	ffffc097          	auipc	ra,0xffffc
    80004922:	434080e7          	jalr	1076(ra) # 80000d52 <release>
}
    80004926:	70e2                	ld	ra,56(sp)
    80004928:	7442                	ld	s0,48(sp)
    8000492a:	74a2                	ld	s1,40(sp)
    8000492c:	7902                	ld	s2,32(sp)
    8000492e:	69e2                	ld	s3,24(sp)
    80004930:	6a42                	ld	s4,16(sp)
    80004932:	6aa2                	ld	s5,8(sp)
    80004934:	6121                	addi	sp,sp,64
    80004936:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004938:	0001ca97          	auipc	s5,0x1c
    8000493c:	418a8a93          	addi	s5,s5,1048 # 80020d50 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004940:	0001ca17          	auipc	s4,0x1c
    80004944:	3e0a0a13          	addi	s4,s4,992 # 80020d20 <log>
    80004948:	018a2583          	lw	a1,24(s4)
    8000494c:	012585bb          	addw	a1,a1,s2
    80004950:	2585                	addiw	a1,a1,1
    80004952:	028a2503          	lw	a0,40(s4)
    80004956:	fffff097          	auipc	ra,0xfffff
    8000495a:	cc4080e7          	jalr	-828(ra) # 8000361a <bread>
    8000495e:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004960:	000aa583          	lw	a1,0(s5)
    80004964:	028a2503          	lw	a0,40(s4)
    80004968:	fffff097          	auipc	ra,0xfffff
    8000496c:	cb2080e7          	jalr	-846(ra) # 8000361a <bread>
    80004970:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004972:	40000613          	li	a2,1024
    80004976:	05850593          	addi	a1,a0,88
    8000497a:	05848513          	addi	a0,s1,88
    8000497e:	ffffc097          	auipc	ra,0xffffc
    80004982:	478080e7          	jalr	1144(ra) # 80000df6 <memmove>
    bwrite(to);  // write the log
    80004986:	8526                	mv	a0,s1
    80004988:	fffff097          	auipc	ra,0xfffff
    8000498c:	d84080e7          	jalr	-636(ra) # 8000370c <bwrite>
    brelse(from);
    80004990:	854e                	mv	a0,s3
    80004992:	fffff097          	auipc	ra,0xfffff
    80004996:	db8080e7          	jalr	-584(ra) # 8000374a <brelse>
    brelse(to);
    8000499a:	8526                	mv	a0,s1
    8000499c:	fffff097          	auipc	ra,0xfffff
    800049a0:	dae080e7          	jalr	-594(ra) # 8000374a <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800049a4:	2905                	addiw	s2,s2,1
    800049a6:	0a91                	addi	s5,s5,4
    800049a8:	02ca2783          	lw	a5,44(s4)
    800049ac:	f8f94ee3          	blt	s2,a5,80004948 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800049b0:	00000097          	auipc	ra,0x0
    800049b4:	c68080e7          	jalr	-920(ra) # 80004618 <write_head>
    install_trans(0); // Now install writes to home locations
    800049b8:	4501                	li	a0,0
    800049ba:	00000097          	auipc	ra,0x0
    800049be:	cda080e7          	jalr	-806(ra) # 80004694 <install_trans>
    log.lh.n = 0;
    800049c2:	0001c797          	auipc	a5,0x1c
    800049c6:	3807a523          	sw	zero,906(a5) # 80020d4c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800049ca:	00000097          	auipc	ra,0x0
    800049ce:	c4e080e7          	jalr	-946(ra) # 80004618 <write_head>
    800049d2:	bdf5                	j	800048ce <end_op+0x52>

00000000800049d4 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800049d4:	1101                	addi	sp,sp,-32
    800049d6:	ec06                	sd	ra,24(sp)
    800049d8:	e822                	sd	s0,16(sp)
    800049da:	e426                	sd	s1,8(sp)
    800049dc:	e04a                	sd	s2,0(sp)
    800049de:	1000                	addi	s0,sp,32
    800049e0:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800049e2:	0001c917          	auipc	s2,0x1c
    800049e6:	33e90913          	addi	s2,s2,830 # 80020d20 <log>
    800049ea:	854a                	mv	a0,s2
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	2b2080e7          	jalr	690(ra) # 80000c9e <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800049f4:	02c92603          	lw	a2,44(s2)
    800049f8:	47f5                	li	a5,29
    800049fa:	06c7c563          	blt	a5,a2,80004a64 <log_write+0x90>
    800049fe:	0001c797          	auipc	a5,0x1c
    80004a02:	33e7a783          	lw	a5,830(a5) # 80020d3c <log+0x1c>
    80004a06:	37fd                	addiw	a5,a5,-1
    80004a08:	04f65e63          	bge	a2,a5,80004a64 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004a0c:	0001c797          	auipc	a5,0x1c
    80004a10:	3347a783          	lw	a5,820(a5) # 80020d40 <log+0x20>
    80004a14:	06f05063          	blez	a5,80004a74 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004a18:	4781                	li	a5,0
    80004a1a:	06c05563          	blez	a2,80004a84 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a1e:	44cc                	lw	a1,12(s1)
    80004a20:	0001c717          	auipc	a4,0x1c
    80004a24:	33070713          	addi	a4,a4,816 # 80020d50 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004a28:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004a2a:	4314                	lw	a3,0(a4)
    80004a2c:	04b68c63          	beq	a3,a1,80004a84 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004a30:	2785                	addiw	a5,a5,1
    80004a32:	0711                	addi	a4,a4,4
    80004a34:	fef61be3          	bne	a2,a5,80004a2a <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004a38:	0621                	addi	a2,a2,8
    80004a3a:	060a                	slli	a2,a2,0x2
    80004a3c:	0001c797          	auipc	a5,0x1c
    80004a40:	2e478793          	addi	a5,a5,740 # 80020d20 <log>
    80004a44:	97b2                	add	a5,a5,a2
    80004a46:	44d8                	lw	a4,12(s1)
    80004a48:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	fffff097          	auipc	ra,0xfffff
    80004a50:	d9c080e7          	jalr	-612(ra) # 800037e8 <bpin>
    log.lh.n++;
    80004a54:	0001c717          	auipc	a4,0x1c
    80004a58:	2cc70713          	addi	a4,a4,716 # 80020d20 <log>
    80004a5c:	575c                	lw	a5,44(a4)
    80004a5e:	2785                	addiw	a5,a5,1
    80004a60:	d75c                	sw	a5,44(a4)
    80004a62:	a82d                	j	80004a9c <log_write+0xc8>
    panic("too big a transaction");
    80004a64:	00004517          	auipc	a0,0x4
    80004a68:	d9450513          	addi	a0,a0,-620 # 800087f8 <syscalls+0x218>
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	ad4080e7          	jalr	-1324(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004a74:	00004517          	auipc	a0,0x4
    80004a78:	d9c50513          	addi	a0,a0,-612 # 80008810 <syscalls+0x230>
    80004a7c:	ffffc097          	auipc	ra,0xffffc
    80004a80:	ac4080e7          	jalr	-1340(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004a84:	00878693          	addi	a3,a5,8
    80004a88:	068a                	slli	a3,a3,0x2
    80004a8a:	0001c717          	auipc	a4,0x1c
    80004a8e:	29670713          	addi	a4,a4,662 # 80020d20 <log>
    80004a92:	9736                	add	a4,a4,a3
    80004a94:	44d4                	lw	a3,12(s1)
    80004a96:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004a98:	faf609e3          	beq	a2,a5,80004a4a <log_write+0x76>
  }
  release(&log.lock);
    80004a9c:	0001c517          	auipc	a0,0x1c
    80004aa0:	28450513          	addi	a0,a0,644 # 80020d20 <log>
    80004aa4:	ffffc097          	auipc	ra,0xffffc
    80004aa8:	2ae080e7          	jalr	686(ra) # 80000d52 <release>
}
    80004aac:	60e2                	ld	ra,24(sp)
    80004aae:	6442                	ld	s0,16(sp)
    80004ab0:	64a2                	ld	s1,8(sp)
    80004ab2:	6902                	ld	s2,0(sp)
    80004ab4:	6105                	addi	sp,sp,32
    80004ab6:	8082                	ret

0000000080004ab8 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004ab8:	1101                	addi	sp,sp,-32
    80004aba:	ec06                	sd	ra,24(sp)
    80004abc:	e822                	sd	s0,16(sp)
    80004abe:	e426                	sd	s1,8(sp)
    80004ac0:	e04a                	sd	s2,0(sp)
    80004ac2:	1000                	addi	s0,sp,32
    80004ac4:	84aa                	mv	s1,a0
    80004ac6:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004ac8:	00004597          	auipc	a1,0x4
    80004acc:	d6858593          	addi	a1,a1,-664 # 80008830 <syscalls+0x250>
    80004ad0:	0521                	addi	a0,a0,8
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	13c080e7          	jalr	316(ra) # 80000c0e <initlock>
  lk->name = name;
    80004ada:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004ade:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004ae2:	0204a423          	sw	zero,40(s1)
}
    80004ae6:	60e2                	ld	ra,24(sp)
    80004ae8:	6442                	ld	s0,16(sp)
    80004aea:	64a2                	ld	s1,8(sp)
    80004aec:	6902                	ld	s2,0(sp)
    80004aee:	6105                	addi	sp,sp,32
    80004af0:	8082                	ret

0000000080004af2 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004af2:	1101                	addi	sp,sp,-32
    80004af4:	ec06                	sd	ra,24(sp)
    80004af6:	e822                	sd	s0,16(sp)
    80004af8:	e426                	sd	s1,8(sp)
    80004afa:	e04a                	sd	s2,0(sp)
    80004afc:	1000                	addi	s0,sp,32
    80004afe:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b00:	00850913          	addi	s2,a0,8
    80004b04:	854a                	mv	a0,s2
    80004b06:	ffffc097          	auipc	ra,0xffffc
    80004b0a:	198080e7          	jalr	408(ra) # 80000c9e <acquire>
  while (lk->locked) {
    80004b0e:	409c                	lw	a5,0(s1)
    80004b10:	cb89                	beqz	a5,80004b22 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004b12:	85ca                	mv	a1,s2
    80004b14:	8526                	mv	a0,s1
    80004b16:	ffffe097          	auipc	ra,0xffffe
    80004b1a:	a08080e7          	jalr	-1528(ra) # 8000251e <sleep>
  while (lk->locked) {
    80004b1e:	409c                	lw	a5,0(s1)
    80004b20:	fbed                	bnez	a5,80004b12 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004b22:	4785                	li	a5,1
    80004b24:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004b26:	ffffd097          	auipc	ra,0xffffd
    80004b2a:	10a080e7          	jalr	266(ra) # 80001c30 <myproc>
    80004b2e:	591c                	lw	a5,48(a0)
    80004b30:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004b32:	854a                	mv	a0,s2
    80004b34:	ffffc097          	auipc	ra,0xffffc
    80004b38:	21e080e7          	jalr	542(ra) # 80000d52 <release>
}
    80004b3c:	60e2                	ld	ra,24(sp)
    80004b3e:	6442                	ld	s0,16(sp)
    80004b40:	64a2                	ld	s1,8(sp)
    80004b42:	6902                	ld	s2,0(sp)
    80004b44:	6105                	addi	sp,sp,32
    80004b46:	8082                	ret

0000000080004b48 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004b48:	1101                	addi	sp,sp,-32
    80004b4a:	ec06                	sd	ra,24(sp)
    80004b4c:	e822                	sd	s0,16(sp)
    80004b4e:	e426                	sd	s1,8(sp)
    80004b50:	e04a                	sd	s2,0(sp)
    80004b52:	1000                	addi	s0,sp,32
    80004b54:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004b56:	00850913          	addi	s2,a0,8
    80004b5a:	854a                	mv	a0,s2
    80004b5c:	ffffc097          	auipc	ra,0xffffc
    80004b60:	142080e7          	jalr	322(ra) # 80000c9e <acquire>
  lk->locked = 0;
    80004b64:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004b68:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004b6c:	8526                	mv	a0,s1
    80004b6e:	ffffe097          	auipc	ra,0xffffe
    80004b72:	a14080e7          	jalr	-1516(ra) # 80002582 <wakeup>
  release(&lk->lk);
    80004b76:	854a                	mv	a0,s2
    80004b78:	ffffc097          	auipc	ra,0xffffc
    80004b7c:	1da080e7          	jalr	474(ra) # 80000d52 <release>
}
    80004b80:	60e2                	ld	ra,24(sp)
    80004b82:	6442                	ld	s0,16(sp)
    80004b84:	64a2                	ld	s1,8(sp)
    80004b86:	6902                	ld	s2,0(sp)
    80004b88:	6105                	addi	sp,sp,32
    80004b8a:	8082                	ret

0000000080004b8c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004b8c:	7179                	addi	sp,sp,-48
    80004b8e:	f406                	sd	ra,40(sp)
    80004b90:	f022                	sd	s0,32(sp)
    80004b92:	ec26                	sd	s1,24(sp)
    80004b94:	e84a                	sd	s2,16(sp)
    80004b96:	e44e                	sd	s3,8(sp)
    80004b98:	1800                	addi	s0,sp,48
    80004b9a:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004b9c:	00850913          	addi	s2,a0,8
    80004ba0:	854a                	mv	a0,s2
    80004ba2:	ffffc097          	auipc	ra,0xffffc
    80004ba6:	0fc080e7          	jalr	252(ra) # 80000c9e <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004baa:	409c                	lw	a5,0(s1)
    80004bac:	ef99                	bnez	a5,80004bca <holdingsleep+0x3e>
    80004bae:	4481                	li	s1,0
  release(&lk->lk);
    80004bb0:	854a                	mv	a0,s2
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	1a0080e7          	jalr	416(ra) # 80000d52 <release>
  return r;
}
    80004bba:	8526                	mv	a0,s1
    80004bbc:	70a2                	ld	ra,40(sp)
    80004bbe:	7402                	ld	s0,32(sp)
    80004bc0:	64e2                	ld	s1,24(sp)
    80004bc2:	6942                	ld	s2,16(sp)
    80004bc4:	69a2                	ld	s3,8(sp)
    80004bc6:	6145                	addi	sp,sp,48
    80004bc8:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004bca:	0284a983          	lw	s3,40(s1)
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	062080e7          	jalr	98(ra) # 80001c30 <myproc>
    80004bd6:	5904                	lw	s1,48(a0)
    80004bd8:	413484b3          	sub	s1,s1,s3
    80004bdc:	0014b493          	seqz	s1,s1
    80004be0:	bfc1                	j	80004bb0 <holdingsleep+0x24>

0000000080004be2 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004be2:	1141                	addi	sp,sp,-16
    80004be4:	e406                	sd	ra,8(sp)
    80004be6:	e022                	sd	s0,0(sp)
    80004be8:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004bea:	00004597          	auipc	a1,0x4
    80004bee:	c5658593          	addi	a1,a1,-938 # 80008840 <syscalls+0x260>
    80004bf2:	0001c517          	auipc	a0,0x1c
    80004bf6:	27650513          	addi	a0,a0,630 # 80020e68 <ftable>
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	014080e7          	jalr	20(ra) # 80000c0e <initlock>
}
    80004c02:	60a2                	ld	ra,8(sp)
    80004c04:	6402                	ld	s0,0(sp)
    80004c06:	0141                	addi	sp,sp,16
    80004c08:	8082                	ret

0000000080004c0a <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004c0a:	1101                	addi	sp,sp,-32
    80004c0c:	ec06                	sd	ra,24(sp)
    80004c0e:	e822                	sd	s0,16(sp)
    80004c10:	e426                	sd	s1,8(sp)
    80004c12:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004c14:	0001c517          	auipc	a0,0x1c
    80004c18:	25450513          	addi	a0,a0,596 # 80020e68 <ftable>
    80004c1c:	ffffc097          	auipc	ra,0xffffc
    80004c20:	082080e7          	jalr	130(ra) # 80000c9e <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c24:	0001c497          	auipc	s1,0x1c
    80004c28:	25c48493          	addi	s1,s1,604 # 80020e80 <ftable+0x18>
    80004c2c:	0001d717          	auipc	a4,0x1d
    80004c30:	1f470713          	addi	a4,a4,500 # 80021e20 <disk>
    if(f->ref == 0){
    80004c34:	40dc                	lw	a5,4(s1)
    80004c36:	cf99                	beqz	a5,80004c54 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004c38:	02848493          	addi	s1,s1,40
    80004c3c:	fee49ce3          	bne	s1,a4,80004c34 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004c40:	0001c517          	auipc	a0,0x1c
    80004c44:	22850513          	addi	a0,a0,552 # 80020e68 <ftable>
    80004c48:	ffffc097          	auipc	ra,0xffffc
    80004c4c:	10a080e7          	jalr	266(ra) # 80000d52 <release>
  return 0;
    80004c50:	4481                	li	s1,0
    80004c52:	a819                	j	80004c68 <filealloc+0x5e>
      f->ref = 1;
    80004c54:	4785                	li	a5,1
    80004c56:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004c58:	0001c517          	auipc	a0,0x1c
    80004c5c:	21050513          	addi	a0,a0,528 # 80020e68 <ftable>
    80004c60:	ffffc097          	auipc	ra,0xffffc
    80004c64:	0f2080e7          	jalr	242(ra) # 80000d52 <release>
}
    80004c68:	8526                	mv	a0,s1
    80004c6a:	60e2                	ld	ra,24(sp)
    80004c6c:	6442                	ld	s0,16(sp)
    80004c6e:	64a2                	ld	s1,8(sp)
    80004c70:	6105                	addi	sp,sp,32
    80004c72:	8082                	ret

0000000080004c74 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004c74:	1101                	addi	sp,sp,-32
    80004c76:	ec06                	sd	ra,24(sp)
    80004c78:	e822                	sd	s0,16(sp)
    80004c7a:	e426                	sd	s1,8(sp)
    80004c7c:	1000                	addi	s0,sp,32
    80004c7e:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004c80:	0001c517          	auipc	a0,0x1c
    80004c84:	1e850513          	addi	a0,a0,488 # 80020e68 <ftable>
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	016080e7          	jalr	22(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    80004c90:	40dc                	lw	a5,4(s1)
    80004c92:	02f05263          	blez	a5,80004cb6 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004c96:	2785                	addiw	a5,a5,1
    80004c98:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004c9a:	0001c517          	auipc	a0,0x1c
    80004c9e:	1ce50513          	addi	a0,a0,462 # 80020e68 <ftable>
    80004ca2:	ffffc097          	auipc	ra,0xffffc
    80004ca6:	0b0080e7          	jalr	176(ra) # 80000d52 <release>
  return f;
}
    80004caa:	8526                	mv	a0,s1
    80004cac:	60e2                	ld	ra,24(sp)
    80004cae:	6442                	ld	s0,16(sp)
    80004cb0:	64a2                	ld	s1,8(sp)
    80004cb2:	6105                	addi	sp,sp,32
    80004cb4:	8082                	ret
    panic("filedup");
    80004cb6:	00004517          	auipc	a0,0x4
    80004cba:	b9250513          	addi	a0,a0,-1134 # 80008848 <syscalls+0x268>
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	882080e7          	jalr	-1918(ra) # 80000540 <panic>

0000000080004cc6 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004cc6:	7139                	addi	sp,sp,-64
    80004cc8:	fc06                	sd	ra,56(sp)
    80004cca:	f822                	sd	s0,48(sp)
    80004ccc:	f426                	sd	s1,40(sp)
    80004cce:	f04a                	sd	s2,32(sp)
    80004cd0:	ec4e                	sd	s3,24(sp)
    80004cd2:	e852                	sd	s4,16(sp)
    80004cd4:	e456                	sd	s5,8(sp)
    80004cd6:	0080                	addi	s0,sp,64
    80004cd8:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004cda:	0001c517          	auipc	a0,0x1c
    80004cde:	18e50513          	addi	a0,a0,398 # 80020e68 <ftable>
    80004ce2:	ffffc097          	auipc	ra,0xffffc
    80004ce6:	fbc080e7          	jalr	-68(ra) # 80000c9e <acquire>
  if(f->ref < 1)
    80004cea:	40dc                	lw	a5,4(s1)
    80004cec:	06f05163          	blez	a5,80004d4e <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004cf0:	37fd                	addiw	a5,a5,-1
    80004cf2:	0007871b          	sext.w	a4,a5
    80004cf6:	c0dc                	sw	a5,4(s1)
    80004cf8:	06e04363          	bgtz	a4,80004d5e <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004cfc:	0004a903          	lw	s2,0(s1)
    80004d00:	0094ca83          	lbu	s5,9(s1)
    80004d04:	0104ba03          	ld	s4,16(s1)
    80004d08:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004d0c:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004d10:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004d14:	0001c517          	auipc	a0,0x1c
    80004d18:	15450513          	addi	a0,a0,340 # 80020e68 <ftable>
    80004d1c:	ffffc097          	auipc	ra,0xffffc
    80004d20:	036080e7          	jalr	54(ra) # 80000d52 <release>

  if(ff.type == FD_PIPE){
    80004d24:	4785                	li	a5,1
    80004d26:	04f90d63          	beq	s2,a5,80004d80 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004d2a:	3979                	addiw	s2,s2,-2
    80004d2c:	4785                	li	a5,1
    80004d2e:	0527e063          	bltu	a5,s2,80004d6e <fileclose+0xa8>
    begin_op();
    80004d32:	00000097          	auipc	ra,0x0
    80004d36:	acc080e7          	jalr	-1332(ra) # 800047fe <begin_op>
    iput(ff.ip);
    80004d3a:	854e                	mv	a0,s3
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	2b0080e7          	jalr	688(ra) # 80003fec <iput>
    end_op();
    80004d44:	00000097          	auipc	ra,0x0
    80004d48:	b38080e7          	jalr	-1224(ra) # 8000487c <end_op>
    80004d4c:	a00d                	j	80004d6e <fileclose+0xa8>
    panic("fileclose");
    80004d4e:	00004517          	auipc	a0,0x4
    80004d52:	b0250513          	addi	a0,a0,-1278 # 80008850 <syscalls+0x270>
    80004d56:	ffffb097          	auipc	ra,0xffffb
    80004d5a:	7ea080e7          	jalr	2026(ra) # 80000540 <panic>
    release(&ftable.lock);
    80004d5e:	0001c517          	auipc	a0,0x1c
    80004d62:	10a50513          	addi	a0,a0,266 # 80020e68 <ftable>
    80004d66:	ffffc097          	auipc	ra,0xffffc
    80004d6a:	fec080e7          	jalr	-20(ra) # 80000d52 <release>
  }
}
    80004d6e:	70e2                	ld	ra,56(sp)
    80004d70:	7442                	ld	s0,48(sp)
    80004d72:	74a2                	ld	s1,40(sp)
    80004d74:	7902                	ld	s2,32(sp)
    80004d76:	69e2                	ld	s3,24(sp)
    80004d78:	6a42                	ld	s4,16(sp)
    80004d7a:	6aa2                	ld	s5,8(sp)
    80004d7c:	6121                	addi	sp,sp,64
    80004d7e:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004d80:	85d6                	mv	a1,s5
    80004d82:	8552                	mv	a0,s4
    80004d84:	00000097          	auipc	ra,0x0
    80004d88:	34c080e7          	jalr	844(ra) # 800050d0 <pipeclose>
    80004d8c:	b7cd                	j	80004d6e <fileclose+0xa8>

0000000080004d8e <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004d8e:	715d                	addi	sp,sp,-80
    80004d90:	e486                	sd	ra,72(sp)
    80004d92:	e0a2                	sd	s0,64(sp)
    80004d94:	fc26                	sd	s1,56(sp)
    80004d96:	f84a                	sd	s2,48(sp)
    80004d98:	f44e                	sd	s3,40(sp)
    80004d9a:	0880                	addi	s0,sp,80
    80004d9c:	84aa                	mv	s1,a0
    80004d9e:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004da0:	ffffd097          	auipc	ra,0xffffd
    80004da4:	e90080e7          	jalr	-368(ra) # 80001c30 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004da8:	409c                	lw	a5,0(s1)
    80004daa:	37f9                	addiw	a5,a5,-2
    80004dac:	4705                	li	a4,1
    80004dae:	04f76763          	bltu	a4,a5,80004dfc <filestat+0x6e>
    80004db2:	892a                	mv	s2,a0
    ilock(f->ip);
    80004db4:	6c88                	ld	a0,24(s1)
    80004db6:	fffff097          	auipc	ra,0xfffff
    80004dba:	07c080e7          	jalr	124(ra) # 80003e32 <ilock>
    stati(f->ip, &st);
    80004dbe:	fb840593          	addi	a1,s0,-72
    80004dc2:	6c88                	ld	a0,24(s1)
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	2f8080e7          	jalr	760(ra) # 800040bc <stati>
    iunlock(f->ip);
    80004dcc:	6c88                	ld	a0,24(s1)
    80004dce:	fffff097          	auipc	ra,0xfffff
    80004dd2:	126080e7          	jalr	294(ra) # 80003ef4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004dd6:	46e1                	li	a3,24
    80004dd8:	fb840613          	addi	a2,s0,-72
    80004ddc:	85ce                	mv	a1,s3
    80004dde:	05093503          	ld	a0,80(s2)
    80004de2:	ffffd097          	auipc	ra,0xffffd
    80004de6:	a10080e7          	jalr	-1520(ra) # 800017f2 <copyout>
    80004dea:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004dee:	60a6                	ld	ra,72(sp)
    80004df0:	6406                	ld	s0,64(sp)
    80004df2:	74e2                	ld	s1,56(sp)
    80004df4:	7942                	ld	s2,48(sp)
    80004df6:	79a2                	ld	s3,40(sp)
    80004df8:	6161                	addi	sp,sp,80
    80004dfa:	8082                	ret
  return -1;
    80004dfc:	557d                	li	a0,-1
    80004dfe:	bfc5                	j	80004dee <filestat+0x60>

0000000080004e00 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004e00:	7179                	addi	sp,sp,-48
    80004e02:	f406                	sd	ra,40(sp)
    80004e04:	f022                	sd	s0,32(sp)
    80004e06:	ec26                	sd	s1,24(sp)
    80004e08:	e84a                	sd	s2,16(sp)
    80004e0a:	e44e                	sd	s3,8(sp)
    80004e0c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004e0e:	00854783          	lbu	a5,8(a0)
    80004e12:	c3d5                	beqz	a5,80004eb6 <fileread+0xb6>
    80004e14:	84aa                	mv	s1,a0
    80004e16:	89ae                	mv	s3,a1
    80004e18:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004e1a:	411c                	lw	a5,0(a0)
    80004e1c:	4705                	li	a4,1
    80004e1e:	04e78963          	beq	a5,a4,80004e70 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004e22:	470d                	li	a4,3
    80004e24:	04e78d63          	beq	a5,a4,80004e7e <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004e28:	4709                	li	a4,2
    80004e2a:	06e79e63          	bne	a5,a4,80004ea6 <fileread+0xa6>
    ilock(f->ip);
    80004e2e:	6d08                	ld	a0,24(a0)
    80004e30:	fffff097          	auipc	ra,0xfffff
    80004e34:	002080e7          	jalr	2(ra) # 80003e32 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004e38:	874a                	mv	a4,s2
    80004e3a:	5094                	lw	a3,32(s1)
    80004e3c:	864e                	mv	a2,s3
    80004e3e:	4585                	li	a1,1
    80004e40:	6c88                	ld	a0,24(s1)
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	2a4080e7          	jalr	676(ra) # 800040e6 <readi>
    80004e4a:	892a                	mv	s2,a0
    80004e4c:	00a05563          	blez	a0,80004e56 <fileread+0x56>
      f->off += r;
    80004e50:	509c                	lw	a5,32(s1)
    80004e52:	9fa9                	addw	a5,a5,a0
    80004e54:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004e56:	6c88                	ld	a0,24(s1)
    80004e58:	fffff097          	auipc	ra,0xfffff
    80004e5c:	09c080e7          	jalr	156(ra) # 80003ef4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004e60:	854a                	mv	a0,s2
    80004e62:	70a2                	ld	ra,40(sp)
    80004e64:	7402                	ld	s0,32(sp)
    80004e66:	64e2                	ld	s1,24(sp)
    80004e68:	6942                	ld	s2,16(sp)
    80004e6a:	69a2                	ld	s3,8(sp)
    80004e6c:	6145                	addi	sp,sp,48
    80004e6e:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004e70:	6908                	ld	a0,16(a0)
    80004e72:	00000097          	auipc	ra,0x0
    80004e76:	3c6080e7          	jalr	966(ra) # 80005238 <piperead>
    80004e7a:	892a                	mv	s2,a0
    80004e7c:	b7d5                	j	80004e60 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004e7e:	02451783          	lh	a5,36(a0)
    80004e82:	03079693          	slli	a3,a5,0x30
    80004e86:	92c1                	srli	a3,a3,0x30
    80004e88:	4725                	li	a4,9
    80004e8a:	02d76863          	bltu	a4,a3,80004eba <fileread+0xba>
    80004e8e:	0792                	slli	a5,a5,0x4
    80004e90:	0001c717          	auipc	a4,0x1c
    80004e94:	f3870713          	addi	a4,a4,-200 # 80020dc8 <devsw>
    80004e98:	97ba                	add	a5,a5,a4
    80004e9a:	639c                	ld	a5,0(a5)
    80004e9c:	c38d                	beqz	a5,80004ebe <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004e9e:	4505                	li	a0,1
    80004ea0:	9782                	jalr	a5
    80004ea2:	892a                	mv	s2,a0
    80004ea4:	bf75                	j	80004e60 <fileread+0x60>
    panic("fileread");
    80004ea6:	00004517          	auipc	a0,0x4
    80004eaa:	9ba50513          	addi	a0,a0,-1606 # 80008860 <syscalls+0x280>
    80004eae:	ffffb097          	auipc	ra,0xffffb
    80004eb2:	692080e7          	jalr	1682(ra) # 80000540 <panic>
    return -1;
    80004eb6:	597d                	li	s2,-1
    80004eb8:	b765                	j	80004e60 <fileread+0x60>
      return -1;
    80004eba:	597d                	li	s2,-1
    80004ebc:	b755                	j	80004e60 <fileread+0x60>
    80004ebe:	597d                	li	s2,-1
    80004ec0:	b745                	j	80004e60 <fileread+0x60>

0000000080004ec2 <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    80004ec2:	715d                	addi	sp,sp,-80
    80004ec4:	e486                	sd	ra,72(sp)
    80004ec6:	e0a2                	sd	s0,64(sp)
    80004ec8:	fc26                	sd	s1,56(sp)
    80004eca:	f84a                	sd	s2,48(sp)
    80004ecc:	f44e                	sd	s3,40(sp)
    80004ece:	f052                	sd	s4,32(sp)
    80004ed0:	ec56                	sd	s5,24(sp)
    80004ed2:	e85a                	sd	s6,16(sp)
    80004ed4:	e45e                	sd	s7,8(sp)
    80004ed6:	e062                	sd	s8,0(sp)
    80004ed8:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    80004eda:	00954783          	lbu	a5,9(a0)
    80004ede:	10078663          	beqz	a5,80004fea <filewrite+0x128>
    80004ee2:	892a                	mv	s2,a0
    80004ee4:	8b2e                	mv	s6,a1
    80004ee6:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004ee8:	411c                	lw	a5,0(a0)
    80004eea:	4705                	li	a4,1
    80004eec:	02e78263          	beq	a5,a4,80004f10 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004ef0:	470d                	li	a4,3
    80004ef2:	02e78663          	beq	a5,a4,80004f1e <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004ef6:	4709                	li	a4,2
    80004ef8:	0ee79163          	bne	a5,a4,80004fda <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004efc:	0ac05d63          	blez	a2,80004fb6 <filewrite+0xf4>
    int i = 0;
    80004f00:	4981                	li	s3,0
    80004f02:	6b85                	lui	s7,0x1
    80004f04:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004f08:	6c05                	lui	s8,0x1
    80004f0a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004f0e:	a861                	j	80004fa6 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    80004f10:	6908                	ld	a0,16(a0)
    80004f12:	00000097          	auipc	ra,0x0
    80004f16:	22e080e7          	jalr	558(ra) # 80005140 <pipewrite>
    80004f1a:	8a2a                	mv	s4,a0
    80004f1c:	a045                	j	80004fbc <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004f1e:	02451783          	lh	a5,36(a0)
    80004f22:	03079693          	slli	a3,a5,0x30
    80004f26:	92c1                	srli	a3,a3,0x30
    80004f28:	4725                	li	a4,9
    80004f2a:	0cd76263          	bltu	a4,a3,80004fee <filewrite+0x12c>
    80004f2e:	0792                	slli	a5,a5,0x4
    80004f30:	0001c717          	auipc	a4,0x1c
    80004f34:	e9870713          	addi	a4,a4,-360 # 80020dc8 <devsw>
    80004f38:	97ba                	add	a5,a5,a4
    80004f3a:	679c                	ld	a5,8(a5)
    80004f3c:	cbdd                	beqz	a5,80004ff2 <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004f3e:	4505                	li	a0,1
    80004f40:	9782                	jalr	a5
    80004f42:	8a2a                	mv	s4,a0
    80004f44:	a8a5                	j	80004fbc <filewrite+0xfa>
    80004f46:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004f4a:	00000097          	auipc	ra,0x0
    80004f4e:	8b4080e7          	jalr	-1868(ra) # 800047fe <begin_op>
      ilock(f->ip);
    80004f52:	01893503          	ld	a0,24(s2)
    80004f56:	fffff097          	auipc	ra,0xfffff
    80004f5a:	edc080e7          	jalr	-292(ra) # 80003e32 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004f5e:	8756                	mv	a4,s5
    80004f60:	02092683          	lw	a3,32(s2)
    80004f64:	01698633          	add	a2,s3,s6
    80004f68:	4585                	li	a1,1
    80004f6a:	01893503          	ld	a0,24(s2)
    80004f6e:	fffff097          	auipc	ra,0xfffff
    80004f72:	270080e7          	jalr	624(ra) # 800041de <writei>
    80004f76:	84aa                	mv	s1,a0
    80004f78:	00a05763          	blez	a0,80004f86 <filewrite+0xc4>
        f->off += r;
    80004f7c:	02092783          	lw	a5,32(s2)
    80004f80:	9fa9                	addw	a5,a5,a0
    80004f82:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004f86:	01893503          	ld	a0,24(s2)
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	f6a080e7          	jalr	-150(ra) # 80003ef4 <iunlock>
      end_op();
    80004f92:	00000097          	auipc	ra,0x0
    80004f96:	8ea080e7          	jalr	-1814(ra) # 8000487c <end_op>

      if(r != n1){
    80004f9a:	009a9f63          	bne	s5,s1,80004fb8 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004f9e:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004fa2:	0149db63          	bge	s3,s4,80004fb8 <filewrite+0xf6>
      int n1 = n - i;
    80004fa6:	413a04bb          	subw	s1,s4,s3
    80004faa:	0004879b          	sext.w	a5,s1
    80004fae:	f8fbdce3          	bge	s7,a5,80004f46 <filewrite+0x84>
    80004fb2:	84e2                	mv	s1,s8
    80004fb4:	bf49                	j	80004f46 <filewrite+0x84>
    int i = 0;
    80004fb6:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004fb8:	013a1f63          	bne	s4,s3,80004fd6 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004fbc:	8552                	mv	a0,s4
    80004fbe:	60a6                	ld	ra,72(sp)
    80004fc0:	6406                	ld	s0,64(sp)
    80004fc2:	74e2                	ld	s1,56(sp)
    80004fc4:	7942                	ld	s2,48(sp)
    80004fc6:	79a2                	ld	s3,40(sp)
    80004fc8:	7a02                	ld	s4,32(sp)
    80004fca:	6ae2                	ld	s5,24(sp)
    80004fcc:	6b42                	ld	s6,16(sp)
    80004fce:	6ba2                	ld	s7,8(sp)
    80004fd0:	6c02                	ld	s8,0(sp)
    80004fd2:	6161                	addi	sp,sp,80
    80004fd4:	8082                	ret
    ret = (i == n ? n : -1);
    80004fd6:	5a7d                	li	s4,-1
    80004fd8:	b7d5                	j	80004fbc <filewrite+0xfa>
    panic("filewrite");
    80004fda:	00004517          	auipc	a0,0x4
    80004fde:	89650513          	addi	a0,a0,-1898 # 80008870 <syscalls+0x290>
    80004fe2:	ffffb097          	auipc	ra,0xffffb
    80004fe6:	55e080e7          	jalr	1374(ra) # 80000540 <panic>
    return -1;
    80004fea:	5a7d                	li	s4,-1
    80004fec:	bfc1                	j	80004fbc <filewrite+0xfa>
      return -1;
    80004fee:	5a7d                	li	s4,-1
    80004ff0:	b7f1                	j	80004fbc <filewrite+0xfa>
    80004ff2:	5a7d                	li	s4,-1
    80004ff4:	b7e1                	j	80004fbc <filewrite+0xfa>

0000000080004ff6 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ff6:	7179                	addi	sp,sp,-48
    80004ff8:	f406                	sd	ra,40(sp)
    80004ffa:	f022                	sd	s0,32(sp)
    80004ffc:	ec26                	sd	s1,24(sp)
    80004ffe:	e84a                	sd	s2,16(sp)
    80005000:	e44e                	sd	s3,8(sp)
    80005002:	e052                	sd	s4,0(sp)
    80005004:	1800                	addi	s0,sp,48
    80005006:	84aa                	mv	s1,a0
    80005008:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000500a:	0005b023          	sd	zero,0(a1)
    8000500e:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80005012:	00000097          	auipc	ra,0x0
    80005016:	bf8080e7          	jalr	-1032(ra) # 80004c0a <filealloc>
    8000501a:	e088                	sd	a0,0(s1)
    8000501c:	c551                	beqz	a0,800050a8 <pipealloc+0xb2>
    8000501e:	00000097          	auipc	ra,0x0
    80005022:	bec080e7          	jalr	-1044(ra) # 80004c0a <filealloc>
    80005026:	00aa3023          	sd	a0,0(s4)
    8000502a:	c92d                	beqz	a0,8000509c <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	b36080e7          	jalr	-1226(ra) # 80000b62 <kalloc>
    80005034:	892a                	mv	s2,a0
    80005036:	c125                	beqz	a0,80005096 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80005038:	4985                	li	s3,1
    8000503a:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000503e:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80005042:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80005046:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000504a:	00004597          	auipc	a1,0x4
    8000504e:	83658593          	addi	a1,a1,-1994 # 80008880 <syscalls+0x2a0>
    80005052:	ffffc097          	auipc	ra,0xffffc
    80005056:	bbc080e7          	jalr	-1092(ra) # 80000c0e <initlock>
  (*f0)->type = FD_PIPE;
    8000505a:	609c                	ld	a5,0(s1)
    8000505c:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80005060:	609c                	ld	a5,0(s1)
    80005062:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80005066:	609c                	ld	a5,0(s1)
    80005068:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000506c:	609c                	ld	a5,0(s1)
    8000506e:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80005072:	000a3783          	ld	a5,0(s4)
    80005076:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000507a:	000a3783          	ld	a5,0(s4)
    8000507e:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80005082:	000a3783          	ld	a5,0(s4)
    80005086:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000508a:	000a3783          	ld	a5,0(s4)
    8000508e:	0127b823          	sd	s2,16(a5)
  return 0;
    80005092:	4501                	li	a0,0
    80005094:	a025                	j	800050bc <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80005096:	6088                	ld	a0,0(s1)
    80005098:	e501                	bnez	a0,800050a0 <pipealloc+0xaa>
    8000509a:	a039                	j	800050a8 <pipealloc+0xb2>
    8000509c:	6088                	ld	a0,0(s1)
    8000509e:	c51d                	beqz	a0,800050cc <pipealloc+0xd6>
    fileclose(*f0);
    800050a0:	00000097          	auipc	ra,0x0
    800050a4:	c26080e7          	jalr	-986(ra) # 80004cc6 <fileclose>
  if(*f1)
    800050a8:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800050ac:	557d                	li	a0,-1
  if(*f1)
    800050ae:	c799                	beqz	a5,800050bc <pipealloc+0xc6>
    fileclose(*f1);
    800050b0:	853e                	mv	a0,a5
    800050b2:	00000097          	auipc	ra,0x0
    800050b6:	c14080e7          	jalr	-1004(ra) # 80004cc6 <fileclose>
  return -1;
    800050ba:	557d                	li	a0,-1
}
    800050bc:	70a2                	ld	ra,40(sp)
    800050be:	7402                	ld	s0,32(sp)
    800050c0:	64e2                	ld	s1,24(sp)
    800050c2:	6942                	ld	s2,16(sp)
    800050c4:	69a2                	ld	s3,8(sp)
    800050c6:	6a02                	ld	s4,0(sp)
    800050c8:	6145                	addi	sp,sp,48
    800050ca:	8082                	ret
  return -1;
    800050cc:	557d                	li	a0,-1
    800050ce:	b7fd                	j	800050bc <pipealloc+0xc6>

00000000800050d0 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800050d0:	1101                	addi	sp,sp,-32
    800050d2:	ec06                	sd	ra,24(sp)
    800050d4:	e822                	sd	s0,16(sp)
    800050d6:	e426                	sd	s1,8(sp)
    800050d8:	e04a                	sd	s2,0(sp)
    800050da:	1000                	addi	s0,sp,32
    800050dc:	84aa                	mv	s1,a0
    800050de:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800050e0:	ffffc097          	auipc	ra,0xffffc
    800050e4:	bbe080e7          	jalr	-1090(ra) # 80000c9e <acquire>
  if(writable){
    800050e8:	02090d63          	beqz	s2,80005122 <pipeclose+0x52>
    pi->writeopen = 0;
    800050ec:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800050f0:	21848513          	addi	a0,s1,536
    800050f4:	ffffd097          	auipc	ra,0xffffd
    800050f8:	48e080e7          	jalr	1166(ra) # 80002582 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800050fc:	2204b783          	ld	a5,544(s1)
    80005100:	eb95                	bnez	a5,80005134 <pipeclose+0x64>
    release(&pi->lock);
    80005102:	8526                	mv	a0,s1
    80005104:	ffffc097          	auipc	ra,0xffffc
    80005108:	c4e080e7          	jalr	-946(ra) # 80000d52 <release>
    kfree((char*)pi);
    8000510c:	8526                	mv	a0,s1
    8000510e:	ffffc097          	auipc	ra,0xffffc
    80005112:	8ec080e7          	jalr	-1812(ra) # 800009fa <kfree>
  } else
    release(&pi->lock);
}
    80005116:	60e2                	ld	ra,24(sp)
    80005118:	6442                	ld	s0,16(sp)
    8000511a:	64a2                	ld	s1,8(sp)
    8000511c:	6902                	ld	s2,0(sp)
    8000511e:	6105                	addi	sp,sp,32
    80005120:	8082                	ret
    pi->readopen = 0;
    80005122:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80005126:	21c48513          	addi	a0,s1,540
    8000512a:	ffffd097          	auipc	ra,0xffffd
    8000512e:	458080e7          	jalr	1112(ra) # 80002582 <wakeup>
    80005132:	b7e9                	j	800050fc <pipeclose+0x2c>
    release(&pi->lock);
    80005134:	8526                	mv	a0,s1
    80005136:	ffffc097          	auipc	ra,0xffffc
    8000513a:	c1c080e7          	jalr	-996(ra) # 80000d52 <release>
}
    8000513e:	bfe1                	j	80005116 <pipeclose+0x46>

0000000080005140 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80005140:	711d                	addi	sp,sp,-96
    80005142:	ec86                	sd	ra,88(sp)
    80005144:	e8a2                	sd	s0,80(sp)
    80005146:	e4a6                	sd	s1,72(sp)
    80005148:	e0ca                	sd	s2,64(sp)
    8000514a:	fc4e                	sd	s3,56(sp)
    8000514c:	f852                	sd	s4,48(sp)
    8000514e:	f456                	sd	s5,40(sp)
    80005150:	f05a                	sd	s6,32(sp)
    80005152:	ec5e                	sd	s7,24(sp)
    80005154:	e862                	sd	s8,16(sp)
    80005156:	1080                	addi	s0,sp,96
    80005158:	84aa                	mv	s1,a0
    8000515a:	8aae                	mv	s5,a1
    8000515c:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    8000515e:	ffffd097          	auipc	ra,0xffffd
    80005162:	ad2080e7          	jalr	-1326(ra) # 80001c30 <myproc>
    80005166:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80005168:	8526                	mv	a0,s1
    8000516a:	ffffc097          	auipc	ra,0xffffc
    8000516e:	b34080e7          	jalr	-1228(ra) # 80000c9e <acquire>
  while(i < n){
    80005172:	0b405663          	blez	s4,8000521e <pipewrite+0xde>
  int i = 0;
    80005176:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80005178:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000517a:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    8000517e:	21c48b93          	addi	s7,s1,540
    80005182:	a089                	j	800051c4 <pipewrite+0x84>
      release(&pi->lock);
    80005184:	8526                	mv	a0,s1
    80005186:	ffffc097          	auipc	ra,0xffffc
    8000518a:	bcc080e7          	jalr	-1076(ra) # 80000d52 <release>
      return -1;
    8000518e:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80005190:	854a                	mv	a0,s2
    80005192:	60e6                	ld	ra,88(sp)
    80005194:	6446                	ld	s0,80(sp)
    80005196:	64a6                	ld	s1,72(sp)
    80005198:	6906                	ld	s2,64(sp)
    8000519a:	79e2                	ld	s3,56(sp)
    8000519c:	7a42                	ld	s4,48(sp)
    8000519e:	7aa2                	ld	s5,40(sp)
    800051a0:	7b02                	ld	s6,32(sp)
    800051a2:	6be2                	ld	s7,24(sp)
    800051a4:	6c42                	ld	s8,16(sp)
    800051a6:	6125                	addi	sp,sp,96
    800051a8:	8082                	ret
      wakeup(&pi->nread);
    800051aa:	8562                	mv	a0,s8
    800051ac:	ffffd097          	auipc	ra,0xffffd
    800051b0:	3d6080e7          	jalr	982(ra) # 80002582 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800051b4:	85a6                	mv	a1,s1
    800051b6:	855e                	mv	a0,s7
    800051b8:	ffffd097          	auipc	ra,0xffffd
    800051bc:	366080e7          	jalr	870(ra) # 8000251e <sleep>
  while(i < n){
    800051c0:	07495063          	bge	s2,s4,80005220 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    800051c4:	2204a783          	lw	a5,544(s1)
    800051c8:	dfd5                	beqz	a5,80005184 <pipewrite+0x44>
    800051ca:	854e                	mv	a0,s3
    800051cc:	ffffd097          	auipc	ra,0xffffd
    800051d0:	5fa080e7          	jalr	1530(ra) # 800027c6 <killed>
    800051d4:	f945                	bnez	a0,80005184 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800051d6:	2184a783          	lw	a5,536(s1)
    800051da:	21c4a703          	lw	a4,540(s1)
    800051de:	2007879b          	addiw	a5,a5,512
    800051e2:	fcf704e3          	beq	a4,a5,800051aa <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800051e6:	4685                	li	a3,1
    800051e8:	01590633          	add	a2,s2,s5
    800051ec:	faf40593          	addi	a1,s0,-81
    800051f0:	0509b503          	ld	a0,80(s3)
    800051f4:	ffffc097          	auipc	ra,0xffffc
    800051f8:	68a080e7          	jalr	1674(ra) # 8000187e <copyin>
    800051fc:	03650263          	beq	a0,s6,80005220 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80005200:	21c4a783          	lw	a5,540(s1)
    80005204:	0017871b          	addiw	a4,a5,1
    80005208:	20e4ae23          	sw	a4,540(s1)
    8000520c:	1ff7f793          	andi	a5,a5,511
    80005210:	97a6                	add	a5,a5,s1
    80005212:	faf44703          	lbu	a4,-81(s0)
    80005216:	00e78c23          	sb	a4,24(a5)
      i++;
    8000521a:	2905                	addiw	s2,s2,1
    8000521c:	b755                	j	800051c0 <pipewrite+0x80>
  int i = 0;
    8000521e:	4901                	li	s2,0
  wakeup(&pi->nread);
    80005220:	21848513          	addi	a0,s1,536
    80005224:	ffffd097          	auipc	ra,0xffffd
    80005228:	35e080e7          	jalr	862(ra) # 80002582 <wakeup>
  release(&pi->lock);
    8000522c:	8526                	mv	a0,s1
    8000522e:	ffffc097          	auipc	ra,0xffffc
    80005232:	b24080e7          	jalr	-1244(ra) # 80000d52 <release>
  return i;
    80005236:	bfa9                	j	80005190 <pipewrite+0x50>

0000000080005238 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80005238:	715d                	addi	sp,sp,-80
    8000523a:	e486                	sd	ra,72(sp)
    8000523c:	e0a2                	sd	s0,64(sp)
    8000523e:	fc26                	sd	s1,56(sp)
    80005240:	f84a                	sd	s2,48(sp)
    80005242:	f44e                	sd	s3,40(sp)
    80005244:	f052                	sd	s4,32(sp)
    80005246:	ec56                	sd	s5,24(sp)
    80005248:	e85a                	sd	s6,16(sp)
    8000524a:	0880                	addi	s0,sp,80
    8000524c:	84aa                	mv	s1,a0
    8000524e:	892e                	mv	s2,a1
    80005250:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80005252:	ffffd097          	auipc	ra,0xffffd
    80005256:	9de080e7          	jalr	-1570(ra) # 80001c30 <myproc>
    8000525a:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    8000525c:	8526                	mv	a0,s1
    8000525e:	ffffc097          	auipc	ra,0xffffc
    80005262:	a40080e7          	jalr	-1472(ra) # 80000c9e <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005266:	2184a703          	lw	a4,536(s1)
    8000526a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000526e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005272:	02f71763          	bne	a4,a5,800052a0 <piperead+0x68>
    80005276:	2244a783          	lw	a5,548(s1)
    8000527a:	c39d                	beqz	a5,800052a0 <piperead+0x68>
    if(killed(pr)){
    8000527c:	8552                	mv	a0,s4
    8000527e:	ffffd097          	auipc	ra,0xffffd
    80005282:	548080e7          	jalr	1352(ra) # 800027c6 <killed>
    80005286:	e949                	bnez	a0,80005318 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80005288:	85a6                	mv	a1,s1
    8000528a:	854e                	mv	a0,s3
    8000528c:	ffffd097          	auipc	ra,0xffffd
    80005290:	292080e7          	jalr	658(ra) # 8000251e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80005294:	2184a703          	lw	a4,536(s1)
    80005298:	21c4a783          	lw	a5,540(s1)
    8000529c:	fcf70de3          	beq	a4,a5,80005276 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052a0:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052a2:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052a4:	05505463          	blez	s5,800052ec <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    800052a8:	2184a783          	lw	a5,536(s1)
    800052ac:	21c4a703          	lw	a4,540(s1)
    800052b0:	02f70e63          	beq	a4,a5,800052ec <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800052b4:	0017871b          	addiw	a4,a5,1
    800052b8:	20e4ac23          	sw	a4,536(s1)
    800052bc:	1ff7f793          	andi	a5,a5,511
    800052c0:	97a6                	add	a5,a5,s1
    800052c2:	0187c783          	lbu	a5,24(a5)
    800052c6:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800052ca:	4685                	li	a3,1
    800052cc:	fbf40613          	addi	a2,s0,-65
    800052d0:	85ca                	mv	a1,s2
    800052d2:	050a3503          	ld	a0,80(s4)
    800052d6:	ffffc097          	auipc	ra,0xffffc
    800052da:	51c080e7          	jalr	1308(ra) # 800017f2 <copyout>
    800052de:	01650763          	beq	a0,s6,800052ec <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800052e2:	2985                	addiw	s3,s3,1
    800052e4:	0905                	addi	s2,s2,1
    800052e6:	fd3a91e3          	bne	s5,s3,800052a8 <piperead+0x70>
    800052ea:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800052ec:	21c48513          	addi	a0,s1,540
    800052f0:	ffffd097          	auipc	ra,0xffffd
    800052f4:	292080e7          	jalr	658(ra) # 80002582 <wakeup>
  release(&pi->lock);
    800052f8:	8526                	mv	a0,s1
    800052fa:	ffffc097          	auipc	ra,0xffffc
    800052fe:	a58080e7          	jalr	-1448(ra) # 80000d52 <release>
  return i;
}
    80005302:	854e                	mv	a0,s3
    80005304:	60a6                	ld	ra,72(sp)
    80005306:	6406                	ld	s0,64(sp)
    80005308:	74e2                	ld	s1,56(sp)
    8000530a:	7942                	ld	s2,48(sp)
    8000530c:	79a2                	ld	s3,40(sp)
    8000530e:	7a02                	ld	s4,32(sp)
    80005310:	6ae2                	ld	s5,24(sp)
    80005312:	6b42                	ld	s6,16(sp)
    80005314:	6161                	addi	sp,sp,80
    80005316:	8082                	ret
      release(&pi->lock);
    80005318:	8526                	mv	a0,s1
    8000531a:	ffffc097          	auipc	ra,0xffffc
    8000531e:	a38080e7          	jalr	-1480(ra) # 80000d52 <release>
      return -1;
    80005322:	59fd                	li	s3,-1
    80005324:	bff9                	j	80005302 <piperead+0xca>

0000000080005326 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005326:	1141                	addi	sp,sp,-16
    80005328:	e422                	sd	s0,8(sp)
    8000532a:	0800                	addi	s0,sp,16
    8000532c:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000532e:	8905                	andi	a0,a0,1
    80005330:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005332:	8b89                	andi	a5,a5,2
    80005334:	c399                	beqz	a5,8000533a <flags2perm+0x14>
      perm |= PTE_W;
    80005336:	00456513          	ori	a0,a0,4
    return perm;
}
    8000533a:	6422                	ld	s0,8(sp)
    8000533c:	0141                	addi	sp,sp,16
    8000533e:	8082                	ret

0000000080005340 <exec>:

int
exec(char *path, char **argv)
{
    80005340:	de010113          	addi	sp,sp,-544
    80005344:	20113c23          	sd	ra,536(sp)
    80005348:	20813823          	sd	s0,528(sp)
    8000534c:	20913423          	sd	s1,520(sp)
    80005350:	21213023          	sd	s2,512(sp)
    80005354:	ffce                	sd	s3,504(sp)
    80005356:	fbd2                	sd	s4,496(sp)
    80005358:	f7d6                	sd	s5,488(sp)
    8000535a:	f3da                	sd	s6,480(sp)
    8000535c:	efde                	sd	s7,472(sp)
    8000535e:	ebe2                	sd	s8,464(sp)
    80005360:	e7e6                	sd	s9,456(sp)
    80005362:	e3ea                	sd	s10,448(sp)
    80005364:	ff6e                	sd	s11,440(sp)
    80005366:	1400                	addi	s0,sp,544
    80005368:	892a                	mv	s2,a0
    8000536a:	dea43423          	sd	a0,-536(s0)
    8000536e:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80005372:	ffffd097          	auipc	ra,0xffffd
    80005376:	8be080e7          	jalr	-1858(ra) # 80001c30 <myproc>
    8000537a:	84aa                	mv	s1,a0

  begin_op();
    8000537c:	fffff097          	auipc	ra,0xfffff
    80005380:	482080e7          	jalr	1154(ra) # 800047fe <begin_op>

  if((ip = namei(path)) == 0){
    80005384:	854a                	mv	a0,s2
    80005386:	fffff097          	auipc	ra,0xfffff
    8000538a:	258080e7          	jalr	600(ra) # 800045de <namei>
    8000538e:	c93d                	beqz	a0,80005404 <exec+0xc4>
    80005390:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80005392:	fffff097          	auipc	ra,0xfffff
    80005396:	aa0080e7          	jalr	-1376(ra) # 80003e32 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000539a:	04000713          	li	a4,64
    8000539e:	4681                	li	a3,0
    800053a0:	e5040613          	addi	a2,s0,-432
    800053a4:	4581                	li	a1,0
    800053a6:	8556                	mv	a0,s5
    800053a8:	fffff097          	auipc	ra,0xfffff
    800053ac:	d3e080e7          	jalr	-706(ra) # 800040e6 <readi>
    800053b0:	04000793          	li	a5,64
    800053b4:	00f51a63          	bne	a0,a5,800053c8 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800053b8:	e5042703          	lw	a4,-432(s0)
    800053bc:	464c47b7          	lui	a5,0x464c4
    800053c0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800053c4:	04f70663          	beq	a4,a5,80005410 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800053c8:	8556                	mv	a0,s5
    800053ca:	fffff097          	auipc	ra,0xfffff
    800053ce:	cca080e7          	jalr	-822(ra) # 80004094 <iunlockput>
    end_op();
    800053d2:	fffff097          	auipc	ra,0xfffff
    800053d6:	4aa080e7          	jalr	1194(ra) # 8000487c <end_op>
  }
  return -1;
    800053da:	557d                	li	a0,-1
}
    800053dc:	21813083          	ld	ra,536(sp)
    800053e0:	21013403          	ld	s0,528(sp)
    800053e4:	20813483          	ld	s1,520(sp)
    800053e8:	20013903          	ld	s2,512(sp)
    800053ec:	79fe                	ld	s3,504(sp)
    800053ee:	7a5e                	ld	s4,496(sp)
    800053f0:	7abe                	ld	s5,488(sp)
    800053f2:	7b1e                	ld	s6,480(sp)
    800053f4:	6bfe                	ld	s7,472(sp)
    800053f6:	6c5e                	ld	s8,464(sp)
    800053f8:	6cbe                	ld	s9,456(sp)
    800053fa:	6d1e                	ld	s10,448(sp)
    800053fc:	7dfa                	ld	s11,440(sp)
    800053fe:	22010113          	addi	sp,sp,544
    80005402:	8082                	ret
    end_op();
    80005404:	fffff097          	auipc	ra,0xfffff
    80005408:	478080e7          	jalr	1144(ra) # 8000487c <end_op>
    return -1;
    8000540c:	557d                	li	a0,-1
    8000540e:	b7f9                	j	800053dc <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80005410:	8526                	mv	a0,s1
    80005412:	ffffd097          	auipc	ra,0xffffd
    80005416:	8e2080e7          	jalr	-1822(ra) # 80001cf4 <proc_pagetable>
    8000541a:	8b2a                	mv	s6,a0
    8000541c:	d555                	beqz	a0,800053c8 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000541e:	e7042783          	lw	a5,-400(s0)
    80005422:	e8845703          	lhu	a4,-376(s0)
    80005426:	c735                	beqz	a4,80005492 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005428:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000542a:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    8000542e:	6a05                	lui	s4,0x1
    80005430:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80005434:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80005438:	6d85                	lui	s11,0x1
    8000543a:	7d7d                	lui	s10,0xfffff
    8000543c:	ac3d                	j	8000567a <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000543e:	00003517          	auipc	a0,0x3
    80005442:	44a50513          	addi	a0,a0,1098 # 80008888 <syscalls+0x2a8>
    80005446:	ffffb097          	auipc	ra,0xffffb
    8000544a:	0fa080e7          	jalr	250(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000544e:	874a                	mv	a4,s2
    80005450:	009c86bb          	addw	a3,s9,s1
    80005454:	4581                	li	a1,0
    80005456:	8556                	mv	a0,s5
    80005458:	fffff097          	auipc	ra,0xfffff
    8000545c:	c8e080e7          	jalr	-882(ra) # 800040e6 <readi>
    80005460:	2501                	sext.w	a0,a0
    80005462:	1aa91963          	bne	s2,a0,80005614 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80005466:	009d84bb          	addw	s1,s11,s1
    8000546a:	013d09bb          	addw	s3,s10,s3
    8000546e:	1f74f663          	bgeu	s1,s7,8000565a <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80005472:	02049593          	slli	a1,s1,0x20
    80005476:	9181                	srli	a1,a1,0x20
    80005478:	95e2                	add	a1,a1,s8
    8000547a:	855a                	mv	a0,s6
    8000547c:	ffffc097          	auipc	ra,0xffffc
    80005480:	ca8080e7          	jalr	-856(ra) # 80001124 <walkaddr>
    80005484:	862a                	mv	a2,a0
    if(pa == 0)
    80005486:	dd45                	beqz	a0,8000543e <exec+0xfe>
      n = PGSIZE;
    80005488:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    8000548a:	fd49f2e3          	bgeu	s3,s4,8000544e <exec+0x10e>
      n = sz - i;
    8000548e:	894e                	mv	s2,s3
    80005490:	bf7d                	j	8000544e <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005492:	4901                	li	s2,0
  iunlockput(ip);
    80005494:	8556                	mv	a0,s5
    80005496:	fffff097          	auipc	ra,0xfffff
    8000549a:	bfe080e7          	jalr	-1026(ra) # 80004094 <iunlockput>
  end_op();
    8000549e:	fffff097          	auipc	ra,0xfffff
    800054a2:	3de080e7          	jalr	990(ra) # 8000487c <end_op>
  p = myproc();
    800054a6:	ffffc097          	auipc	ra,0xffffc
    800054aa:	78a080e7          	jalr	1930(ra) # 80001c30 <myproc>
    800054ae:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    800054b0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800054b4:	6785                	lui	a5,0x1
    800054b6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800054b8:	97ca                	add	a5,a5,s2
    800054ba:	777d                	lui	a4,0xfffff
    800054bc:	8ff9                	and	a5,a5,a4
    800054be:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800054c2:	4691                	li	a3,4
    800054c4:	6609                	lui	a2,0x2
    800054c6:	963e                	add	a2,a2,a5
    800054c8:	85be                	mv	a1,a5
    800054ca:	855a                	mv	a0,s6
    800054cc:	ffffc097          	auipc	ra,0xffffc
    800054d0:	02c080e7          	jalr	44(ra) # 800014f8 <uvmalloc>
    800054d4:	8c2a                	mv	s8,a0
  ip = 0;
    800054d6:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    800054d8:	12050e63          	beqz	a0,80005614 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    800054dc:	75f9                	lui	a1,0xffffe
    800054de:	95aa                	add	a1,a1,a0
    800054e0:	855a                	mv	a0,s6
    800054e2:	ffffc097          	auipc	ra,0xffffc
    800054e6:	2de080e7          	jalr	734(ra) # 800017c0 <uvmclear>
  stackbase = sp - PGSIZE;
    800054ea:	7afd                	lui	s5,0xfffff
    800054ec:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    800054ee:	df043783          	ld	a5,-528(s0)
    800054f2:	6388                	ld	a0,0(a5)
    800054f4:	c925                	beqz	a0,80005564 <exec+0x224>
    800054f6:	e9040993          	addi	s3,s0,-368
    800054fa:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    800054fe:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005500:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80005502:	ffffc097          	auipc	ra,0xffffc
    80005506:	a14080e7          	jalr	-1516(ra) # 80000f16 <strlen>
    8000550a:	0015079b          	addiw	a5,a0,1
    8000550e:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80005512:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005516:	13596663          	bltu	s2,s5,80005642 <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000551a:	df043d83          	ld	s11,-528(s0)
    8000551e:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    80005522:	8552                	mv	a0,s4
    80005524:	ffffc097          	auipc	ra,0xffffc
    80005528:	9f2080e7          	jalr	-1550(ra) # 80000f16 <strlen>
    8000552c:	0015069b          	addiw	a3,a0,1
    80005530:	8652                	mv	a2,s4
    80005532:	85ca                	mv	a1,s2
    80005534:	855a                	mv	a0,s6
    80005536:	ffffc097          	auipc	ra,0xffffc
    8000553a:	2bc080e7          	jalr	700(ra) # 800017f2 <copyout>
    8000553e:	10054663          	bltz	a0,8000564a <exec+0x30a>
    ustack[argc] = sp;
    80005542:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005546:	0485                	addi	s1,s1,1
    80005548:	008d8793          	addi	a5,s11,8
    8000554c:	def43823          	sd	a5,-528(s0)
    80005550:	008db503          	ld	a0,8(s11)
    80005554:	c911                	beqz	a0,80005568 <exec+0x228>
    if(argc >= MAXARG)
    80005556:	09a1                	addi	s3,s3,8
    80005558:	fb3c95e3          	bne	s9,s3,80005502 <exec+0x1c2>
  sz = sz1;
    8000555c:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005560:	4a81                	li	s5,0
    80005562:	a84d                	j	80005614 <exec+0x2d4>
  sp = sz;
    80005564:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005566:	4481                	li	s1,0
  ustack[argc] = 0;
    80005568:	00349793          	slli	a5,s1,0x3
    8000556c:	f9078793          	addi	a5,a5,-112
    80005570:	97a2                	add	a5,a5,s0
    80005572:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005576:	00148693          	addi	a3,s1,1
    8000557a:	068e                	slli	a3,a3,0x3
    8000557c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005580:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005584:	01597663          	bgeu	s2,s5,80005590 <exec+0x250>
  sz = sz1;
    80005588:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000558c:	4a81                	li	s5,0
    8000558e:	a059                	j	80005614 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005590:	e9040613          	addi	a2,s0,-368
    80005594:	85ca                	mv	a1,s2
    80005596:	855a                	mv	a0,s6
    80005598:	ffffc097          	auipc	ra,0xffffc
    8000559c:	25a080e7          	jalr	602(ra) # 800017f2 <copyout>
    800055a0:	0a054963          	bltz	a0,80005652 <exec+0x312>
  p->trapframe->a1 = sp;
    800055a4:	058bb783          	ld	a5,88(s7)
    800055a8:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800055ac:	de843783          	ld	a5,-536(s0)
    800055b0:	0007c703          	lbu	a4,0(a5)
    800055b4:	cf11                	beqz	a4,800055d0 <exec+0x290>
    800055b6:	0785                	addi	a5,a5,1
    if(*s == '/')
    800055b8:	02f00693          	li	a3,47
    800055bc:	a039                	j	800055ca <exec+0x28a>
      last = s+1;
    800055be:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800055c2:	0785                	addi	a5,a5,1
    800055c4:	fff7c703          	lbu	a4,-1(a5)
    800055c8:	c701                	beqz	a4,800055d0 <exec+0x290>
    if(*s == '/')
    800055ca:	fed71ce3          	bne	a4,a3,800055c2 <exec+0x282>
    800055ce:	bfc5                	j	800055be <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800055d0:	4641                	li	a2,16
    800055d2:	de843583          	ld	a1,-536(s0)
    800055d6:	158b8513          	addi	a0,s7,344
    800055da:	ffffc097          	auipc	ra,0xffffc
    800055de:	90a080e7          	jalr	-1782(ra) # 80000ee4 <safestrcpy>
  oldpagetable = p->pagetable;
    800055e2:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800055e6:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800055ea:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800055ee:	058bb783          	ld	a5,88(s7)
    800055f2:	e6843703          	ld	a4,-408(s0)
    800055f6:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800055f8:	058bb783          	ld	a5,88(s7)
    800055fc:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005600:	85ea                	mv	a1,s10
    80005602:	ffffc097          	auipc	ra,0xffffc
    80005606:	78e080e7          	jalr	1934(ra) # 80001d90 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    8000560a:	0004851b          	sext.w	a0,s1
    8000560e:	b3f9                	j	800053dc <exec+0x9c>
    80005610:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005614:	df843583          	ld	a1,-520(s0)
    80005618:	855a                	mv	a0,s6
    8000561a:	ffffc097          	auipc	ra,0xffffc
    8000561e:	776080e7          	jalr	1910(ra) # 80001d90 <proc_freepagetable>
  if(ip){
    80005622:	da0a93e3          	bnez	s5,800053c8 <exec+0x88>
  return -1;
    80005626:	557d                	li	a0,-1
    80005628:	bb55                	j	800053dc <exec+0x9c>
    8000562a:	df243c23          	sd	s2,-520(s0)
    8000562e:	b7dd                	j	80005614 <exec+0x2d4>
    80005630:	df243c23          	sd	s2,-520(s0)
    80005634:	b7c5                	j	80005614 <exec+0x2d4>
    80005636:	df243c23          	sd	s2,-520(s0)
    8000563a:	bfe9                	j	80005614 <exec+0x2d4>
    8000563c:	df243c23          	sd	s2,-520(s0)
    80005640:	bfd1                	j	80005614 <exec+0x2d4>
  sz = sz1;
    80005642:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005646:	4a81                	li	s5,0
    80005648:	b7f1                	j	80005614 <exec+0x2d4>
  sz = sz1;
    8000564a:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000564e:	4a81                	li	s5,0
    80005650:	b7d1                	j	80005614 <exec+0x2d4>
  sz = sz1;
    80005652:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005656:	4a81                	li	s5,0
    80005658:	bf75                	j	80005614 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000565a:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000565e:	e0843783          	ld	a5,-504(s0)
    80005662:	0017869b          	addiw	a3,a5,1
    80005666:	e0d43423          	sd	a3,-504(s0)
    8000566a:	e0043783          	ld	a5,-512(s0)
    8000566e:	0387879b          	addiw	a5,a5,56
    80005672:	e8845703          	lhu	a4,-376(s0)
    80005676:	e0e6dfe3          	bge	a3,a4,80005494 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    8000567a:	2781                	sext.w	a5,a5
    8000567c:	e0f43023          	sd	a5,-512(s0)
    80005680:	03800713          	li	a4,56
    80005684:	86be                	mv	a3,a5
    80005686:	e1840613          	addi	a2,s0,-488
    8000568a:	4581                	li	a1,0
    8000568c:	8556                	mv	a0,s5
    8000568e:	fffff097          	auipc	ra,0xfffff
    80005692:	a58080e7          	jalr	-1448(ra) # 800040e6 <readi>
    80005696:	03800793          	li	a5,56
    8000569a:	f6f51be3          	bne	a0,a5,80005610 <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000569e:	e1842783          	lw	a5,-488(s0)
    800056a2:	4705                	li	a4,1
    800056a4:	fae79de3          	bne	a5,a4,8000565e <exec+0x31e>
    if(ph.memsz < ph.filesz)
    800056a8:	e4043483          	ld	s1,-448(s0)
    800056ac:	e3843783          	ld	a5,-456(s0)
    800056b0:	f6f4ede3          	bltu	s1,a5,8000562a <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800056b4:	e2843783          	ld	a5,-472(s0)
    800056b8:	94be                	add	s1,s1,a5
    800056ba:	f6f4ebe3          	bltu	s1,a5,80005630 <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800056be:	de043703          	ld	a4,-544(s0)
    800056c2:	8ff9                	and	a5,a5,a4
    800056c4:	fbad                	bnez	a5,80005636 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800056c6:	e1c42503          	lw	a0,-484(s0)
    800056ca:	00000097          	auipc	ra,0x0
    800056ce:	c5c080e7          	jalr	-932(ra) # 80005326 <flags2perm>
    800056d2:	86aa                	mv	a3,a0
    800056d4:	8626                	mv	a2,s1
    800056d6:	85ca                	mv	a1,s2
    800056d8:	855a                	mv	a0,s6
    800056da:	ffffc097          	auipc	ra,0xffffc
    800056de:	e1e080e7          	jalr	-482(ra) # 800014f8 <uvmalloc>
    800056e2:	dea43c23          	sd	a0,-520(s0)
    800056e6:	d939                	beqz	a0,8000563c <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800056e8:	e2843c03          	ld	s8,-472(s0)
    800056ec:	e2042c83          	lw	s9,-480(s0)
    800056f0:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800056f4:	f60b83e3          	beqz	s7,8000565a <exec+0x31a>
    800056f8:	89de                	mv	s3,s7
    800056fa:	4481                	li	s1,0
    800056fc:	bb9d                	j	80005472 <exec+0x132>

00000000800056fe <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800056fe:	7179                	addi	sp,sp,-48
    80005700:	f406                	sd	ra,40(sp)
    80005702:	f022                	sd	s0,32(sp)
    80005704:	ec26                	sd	s1,24(sp)
    80005706:	e84a                	sd	s2,16(sp)
    80005708:	1800                	addi	s0,sp,48
    8000570a:	892e                	mv	s2,a1
    8000570c:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    8000570e:	fdc40593          	addi	a1,s0,-36
    80005712:	ffffe097          	auipc	ra,0xffffe
    80005716:	aa0080e7          	jalr	-1376(ra) # 800031b2 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000571a:	fdc42703          	lw	a4,-36(s0)
    8000571e:	47bd                	li	a5,15
    80005720:	02e7eb63          	bltu	a5,a4,80005756 <argfd+0x58>
    80005724:	ffffc097          	auipc	ra,0xffffc
    80005728:	50c080e7          	jalr	1292(ra) # 80001c30 <myproc>
    8000572c:	fdc42703          	lw	a4,-36(s0)
    80005730:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd0ba>
    80005734:	078e                	slli	a5,a5,0x3
    80005736:	953e                	add	a0,a0,a5
    80005738:	611c                	ld	a5,0(a0)
    8000573a:	c385                	beqz	a5,8000575a <argfd+0x5c>
    return -1;
  if(pfd)
    8000573c:	00090463          	beqz	s2,80005744 <argfd+0x46>
    *pfd = fd;
    80005740:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005744:	4501                	li	a0,0
  if(pf)
    80005746:	c091                	beqz	s1,8000574a <argfd+0x4c>
    *pf = f;
    80005748:	e09c                	sd	a5,0(s1)
}
    8000574a:	70a2                	ld	ra,40(sp)
    8000574c:	7402                	ld	s0,32(sp)
    8000574e:	64e2                	ld	s1,24(sp)
    80005750:	6942                	ld	s2,16(sp)
    80005752:	6145                	addi	sp,sp,48
    80005754:	8082                	ret
    return -1;
    80005756:	557d                	li	a0,-1
    80005758:	bfcd                	j	8000574a <argfd+0x4c>
    8000575a:	557d                	li	a0,-1
    8000575c:	b7fd                	j	8000574a <argfd+0x4c>

000000008000575e <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000575e:	1101                	addi	sp,sp,-32
    80005760:	ec06                	sd	ra,24(sp)
    80005762:	e822                	sd	s0,16(sp)
    80005764:	e426                	sd	s1,8(sp)
    80005766:	1000                	addi	s0,sp,32
    80005768:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000576a:	ffffc097          	auipc	ra,0xffffc
    8000576e:	4c6080e7          	jalr	1222(ra) # 80001c30 <myproc>
    80005772:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005774:	0d050793          	addi	a5,a0,208
    80005778:	4501                	li	a0,0
    8000577a:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    8000577c:	6398                	ld	a4,0(a5)
    8000577e:	cb19                	beqz	a4,80005794 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005780:	2505                	addiw	a0,a0,1
    80005782:	07a1                	addi	a5,a5,8
    80005784:	fed51ce3          	bne	a0,a3,8000577c <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005788:	557d                	li	a0,-1
}
    8000578a:	60e2                	ld	ra,24(sp)
    8000578c:	6442                	ld	s0,16(sp)
    8000578e:	64a2                	ld	s1,8(sp)
    80005790:	6105                	addi	sp,sp,32
    80005792:	8082                	ret
      p->ofile[fd] = f;
    80005794:	01a50793          	addi	a5,a0,26
    80005798:	078e                	slli	a5,a5,0x3
    8000579a:	963e                	add	a2,a2,a5
    8000579c:	e204                	sd	s1,0(a2)
      return fd;
    8000579e:	b7f5                	j	8000578a <fdalloc+0x2c>

00000000800057a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800057a0:	715d                	addi	sp,sp,-80
    800057a2:	e486                	sd	ra,72(sp)
    800057a4:	e0a2                	sd	s0,64(sp)
    800057a6:	fc26                	sd	s1,56(sp)
    800057a8:	f84a                	sd	s2,48(sp)
    800057aa:	f44e                	sd	s3,40(sp)
    800057ac:	f052                	sd	s4,32(sp)
    800057ae:	ec56                	sd	s5,24(sp)
    800057b0:	e85a                	sd	s6,16(sp)
    800057b2:	0880                	addi	s0,sp,80
    800057b4:	8b2e                	mv	s6,a1
    800057b6:	89b2                	mv	s3,a2
    800057b8:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800057ba:	fb040593          	addi	a1,s0,-80
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	e3e080e7          	jalr	-450(ra) # 800045fc <nameiparent>
    800057c6:	84aa                	mv	s1,a0
    800057c8:	14050f63          	beqz	a0,80005926 <create+0x186>
    return 0;

  ilock(dp);
    800057cc:	ffffe097          	auipc	ra,0xffffe
    800057d0:	666080e7          	jalr	1638(ra) # 80003e32 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800057d4:	4601                	li	a2,0
    800057d6:	fb040593          	addi	a1,s0,-80
    800057da:	8526                	mv	a0,s1
    800057dc:	fffff097          	auipc	ra,0xfffff
    800057e0:	b3a080e7          	jalr	-1222(ra) # 80004316 <dirlookup>
    800057e4:	8aaa                	mv	s5,a0
    800057e6:	c931                	beqz	a0,8000583a <create+0x9a>
    iunlockput(dp);
    800057e8:	8526                	mv	a0,s1
    800057ea:	fffff097          	auipc	ra,0xfffff
    800057ee:	8aa080e7          	jalr	-1878(ra) # 80004094 <iunlockput>
    ilock(ip);
    800057f2:	8556                	mv	a0,s5
    800057f4:	ffffe097          	auipc	ra,0xffffe
    800057f8:	63e080e7          	jalr	1598(ra) # 80003e32 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800057fc:	000b059b          	sext.w	a1,s6
    80005800:	4789                	li	a5,2
    80005802:	02f59563          	bne	a1,a5,8000582c <create+0x8c>
    80005806:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd0e4>
    8000580a:	37f9                	addiw	a5,a5,-2
    8000580c:	17c2                	slli	a5,a5,0x30
    8000580e:	93c1                	srli	a5,a5,0x30
    80005810:	4705                	li	a4,1
    80005812:	00f76d63          	bltu	a4,a5,8000582c <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005816:	8556                	mv	a0,s5
    80005818:	60a6                	ld	ra,72(sp)
    8000581a:	6406                	ld	s0,64(sp)
    8000581c:	74e2                	ld	s1,56(sp)
    8000581e:	7942                	ld	s2,48(sp)
    80005820:	79a2                	ld	s3,40(sp)
    80005822:	7a02                	ld	s4,32(sp)
    80005824:	6ae2                	ld	s5,24(sp)
    80005826:	6b42                	ld	s6,16(sp)
    80005828:	6161                	addi	sp,sp,80
    8000582a:	8082                	ret
    iunlockput(ip);
    8000582c:	8556                	mv	a0,s5
    8000582e:	fffff097          	auipc	ra,0xfffff
    80005832:	866080e7          	jalr	-1946(ra) # 80004094 <iunlockput>
    return 0;
    80005836:	4a81                	li	s5,0
    80005838:	bff9                	j	80005816 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000583a:	85da                	mv	a1,s6
    8000583c:	4088                	lw	a0,0(s1)
    8000583e:	ffffe097          	auipc	ra,0xffffe
    80005842:	456080e7          	jalr	1110(ra) # 80003c94 <ialloc>
    80005846:	8a2a                	mv	s4,a0
    80005848:	c539                	beqz	a0,80005896 <create+0xf6>
  ilock(ip);
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	5e8080e7          	jalr	1512(ra) # 80003e32 <ilock>
  ip->major = major;
    80005852:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005856:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000585a:	4905                	li	s2,1
    8000585c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005860:	8552                	mv	a0,s4
    80005862:	ffffe097          	auipc	ra,0xffffe
    80005866:	504080e7          	jalr	1284(ra) # 80003d66 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000586a:	000b059b          	sext.w	a1,s6
    8000586e:	03258b63          	beq	a1,s2,800058a4 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    80005872:	004a2603          	lw	a2,4(s4)
    80005876:	fb040593          	addi	a1,s0,-80
    8000587a:	8526                	mv	a0,s1
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	cb0080e7          	jalr	-848(ra) # 8000452c <dirlink>
    80005884:	06054f63          	bltz	a0,80005902 <create+0x162>
  iunlockput(dp);
    80005888:	8526                	mv	a0,s1
    8000588a:	fffff097          	auipc	ra,0xfffff
    8000588e:	80a080e7          	jalr	-2038(ra) # 80004094 <iunlockput>
  return ip;
    80005892:	8ad2                	mv	s5,s4
    80005894:	b749                	j	80005816 <create+0x76>
    iunlockput(dp);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	7fc080e7          	jalr	2044(ra) # 80004094 <iunlockput>
    return 0;
    800058a0:	8ad2                	mv	s5,s4
    800058a2:	bf95                	j	80005816 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800058a4:	004a2603          	lw	a2,4(s4)
    800058a8:	00003597          	auipc	a1,0x3
    800058ac:	00058593          	mv	a1,a1
    800058b0:	8552                	mv	a0,s4
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	c7a080e7          	jalr	-902(ra) # 8000452c <dirlink>
    800058ba:	04054463          	bltz	a0,80005902 <create+0x162>
    800058be:	40d0                	lw	a2,4(s1)
    800058c0:	00003597          	auipc	a1,0x3
    800058c4:	ff058593          	addi	a1,a1,-16 # 800088b0 <syscalls+0x2d0>
    800058c8:	8552                	mv	a0,s4
    800058ca:	fffff097          	auipc	ra,0xfffff
    800058ce:	c62080e7          	jalr	-926(ra) # 8000452c <dirlink>
    800058d2:	02054863          	bltz	a0,80005902 <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800058d6:	004a2603          	lw	a2,4(s4)
    800058da:	fb040593          	addi	a1,s0,-80
    800058de:	8526                	mv	a0,s1
    800058e0:	fffff097          	auipc	ra,0xfffff
    800058e4:	c4c080e7          	jalr	-948(ra) # 8000452c <dirlink>
    800058e8:	00054d63          	bltz	a0,80005902 <create+0x162>
    dp->nlink++;  // for ".."
    800058ec:	04a4d783          	lhu	a5,74(s1)
    800058f0:	2785                	addiw	a5,a5,1
    800058f2:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	46e080e7          	jalr	1134(ra) # 80003d66 <iupdate>
    80005900:	b761                	j	80005888 <create+0xe8>
  ip->nlink = 0;
    80005902:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005906:	8552                	mv	a0,s4
    80005908:	ffffe097          	auipc	ra,0xffffe
    8000590c:	45e080e7          	jalr	1118(ra) # 80003d66 <iupdate>
  iunlockput(ip);
    80005910:	8552                	mv	a0,s4
    80005912:	ffffe097          	auipc	ra,0xffffe
    80005916:	782080e7          	jalr	1922(ra) # 80004094 <iunlockput>
  iunlockput(dp);
    8000591a:	8526                	mv	a0,s1
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	778080e7          	jalr	1912(ra) # 80004094 <iunlockput>
  return 0;
    80005924:	bdcd                	j	80005816 <create+0x76>
    return 0;
    80005926:	8aaa                	mv	s5,a0
    80005928:	b5fd                	j	80005816 <create+0x76>

000000008000592a <sys_dup>:
{
    8000592a:	7179                	addi	sp,sp,-48
    8000592c:	f406                	sd	ra,40(sp)
    8000592e:	f022                	sd	s0,32(sp)
    80005930:	ec26                	sd	s1,24(sp)
    80005932:	e84a                	sd	s2,16(sp)
    80005934:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005936:	fd840613          	addi	a2,s0,-40
    8000593a:	4581                	li	a1,0
    8000593c:	4501                	li	a0,0
    8000593e:	00000097          	auipc	ra,0x0
    80005942:	dc0080e7          	jalr	-576(ra) # 800056fe <argfd>
    return -1;
    80005946:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005948:	02054363          	bltz	a0,8000596e <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000594c:	fd843903          	ld	s2,-40(s0)
    80005950:	854a                	mv	a0,s2
    80005952:	00000097          	auipc	ra,0x0
    80005956:	e0c080e7          	jalr	-500(ra) # 8000575e <fdalloc>
    8000595a:	84aa                	mv	s1,a0
    return -1;
    8000595c:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000595e:	00054863          	bltz	a0,8000596e <sys_dup+0x44>
  filedup(f);
    80005962:	854a                	mv	a0,s2
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	310080e7          	jalr	784(ra) # 80004c74 <filedup>
  return fd;
    8000596c:	87a6                	mv	a5,s1
}
    8000596e:	853e                	mv	a0,a5
    80005970:	70a2                	ld	ra,40(sp)
    80005972:	7402                	ld	s0,32(sp)
    80005974:	64e2                	ld	s1,24(sp)
    80005976:	6942                	ld	s2,16(sp)
    80005978:	6145                	addi	sp,sp,48
    8000597a:	8082                	ret

000000008000597c <sys_read>:
{
    8000597c:	7179                	addi	sp,sp,-48
    8000597e:	f406                	sd	ra,40(sp)
    80005980:	f022                	sd	s0,32(sp)
    80005982:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005984:	fd840593          	addi	a1,s0,-40
    80005988:	4505                	li	a0,1
    8000598a:	ffffe097          	auipc	ra,0xffffe
    8000598e:	848080e7          	jalr	-1976(ra) # 800031d2 <argaddr>
  argint(2, &n);
    80005992:	fe440593          	addi	a1,s0,-28
    80005996:	4509                	li	a0,2
    80005998:	ffffe097          	auipc	ra,0xffffe
    8000599c:	81a080e7          	jalr	-2022(ra) # 800031b2 <argint>
  if(argfd(0, 0, &f) < 0)
    800059a0:	fe840613          	addi	a2,s0,-24
    800059a4:	4581                	li	a1,0
    800059a6:	4501                	li	a0,0
    800059a8:	00000097          	auipc	ra,0x0
    800059ac:	d56080e7          	jalr	-682(ra) # 800056fe <argfd>
    800059b0:	87aa                	mv	a5,a0
    return -1;
    800059b2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800059b4:	0007cc63          	bltz	a5,800059cc <sys_read+0x50>
  return fileread(f, p, n);
    800059b8:	fe442603          	lw	a2,-28(s0)
    800059bc:	fd843583          	ld	a1,-40(s0)
    800059c0:	fe843503          	ld	a0,-24(s0)
    800059c4:	fffff097          	auipc	ra,0xfffff
    800059c8:	43c080e7          	jalr	1084(ra) # 80004e00 <fileread>
}
    800059cc:	70a2                	ld	ra,40(sp)
    800059ce:	7402                	ld	s0,32(sp)
    800059d0:	6145                	addi	sp,sp,48
    800059d2:	8082                	ret

00000000800059d4 <sys_write>:
{
    800059d4:	7179                	addi	sp,sp,-48
    800059d6:	f406                	sd	ra,40(sp)
    800059d8:	f022                	sd	s0,32(sp)
    800059da:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800059dc:	fd840593          	addi	a1,s0,-40
    800059e0:	4505                	li	a0,1
    800059e2:	ffffd097          	auipc	ra,0xffffd
    800059e6:	7f0080e7          	jalr	2032(ra) # 800031d2 <argaddr>
  argint(2, &n);
    800059ea:	fe440593          	addi	a1,s0,-28
    800059ee:	4509                	li	a0,2
    800059f0:	ffffd097          	auipc	ra,0xffffd
    800059f4:	7c2080e7          	jalr	1986(ra) # 800031b2 <argint>
  if(argfd(0, 0, &f) < 0)
    800059f8:	fe840613          	addi	a2,s0,-24
    800059fc:	4581                	li	a1,0
    800059fe:	4501                	li	a0,0
    80005a00:	00000097          	auipc	ra,0x0
    80005a04:	cfe080e7          	jalr	-770(ra) # 800056fe <argfd>
    80005a08:	87aa                	mv	a5,a0
    return -1;
    80005a0a:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005a0c:	0007cc63          	bltz	a5,80005a24 <sys_write+0x50>
  return filewrite(f, p, n);
    80005a10:	fe442603          	lw	a2,-28(s0)
    80005a14:	fd843583          	ld	a1,-40(s0)
    80005a18:	fe843503          	ld	a0,-24(s0)
    80005a1c:	fffff097          	auipc	ra,0xfffff
    80005a20:	4a6080e7          	jalr	1190(ra) # 80004ec2 <filewrite>
}
    80005a24:	70a2                	ld	ra,40(sp)
    80005a26:	7402                	ld	s0,32(sp)
    80005a28:	6145                	addi	sp,sp,48
    80005a2a:	8082                	ret

0000000080005a2c <sys_close>:
{
    80005a2c:	1101                	addi	sp,sp,-32
    80005a2e:	ec06                	sd	ra,24(sp)
    80005a30:	e822                	sd	s0,16(sp)
    80005a32:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005a34:	fe040613          	addi	a2,s0,-32
    80005a38:	fec40593          	addi	a1,s0,-20
    80005a3c:	4501                	li	a0,0
    80005a3e:	00000097          	auipc	ra,0x0
    80005a42:	cc0080e7          	jalr	-832(ra) # 800056fe <argfd>
    return -1;
    80005a46:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005a48:	02054463          	bltz	a0,80005a70 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005a4c:	ffffc097          	auipc	ra,0xffffc
    80005a50:	1e4080e7          	jalr	484(ra) # 80001c30 <myproc>
    80005a54:	fec42783          	lw	a5,-20(s0)
    80005a58:	07e9                	addi	a5,a5,26
    80005a5a:	078e                	slli	a5,a5,0x3
    80005a5c:	953e                	add	a0,a0,a5
    80005a5e:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005a62:	fe043503          	ld	a0,-32(s0)
    80005a66:	fffff097          	auipc	ra,0xfffff
    80005a6a:	260080e7          	jalr	608(ra) # 80004cc6 <fileclose>
  return 0;
    80005a6e:	4781                	li	a5,0
}
    80005a70:	853e                	mv	a0,a5
    80005a72:	60e2                	ld	ra,24(sp)
    80005a74:	6442                	ld	s0,16(sp)
    80005a76:	6105                	addi	sp,sp,32
    80005a78:	8082                	ret

0000000080005a7a <sys_fstat>:
{
    80005a7a:	1101                	addi	sp,sp,-32
    80005a7c:	ec06                	sd	ra,24(sp)
    80005a7e:	e822                	sd	s0,16(sp)
    80005a80:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005a82:	fe040593          	addi	a1,s0,-32
    80005a86:	4505                	li	a0,1
    80005a88:	ffffd097          	auipc	ra,0xffffd
    80005a8c:	74a080e7          	jalr	1866(ra) # 800031d2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005a90:	fe840613          	addi	a2,s0,-24
    80005a94:	4581                	li	a1,0
    80005a96:	4501                	li	a0,0
    80005a98:	00000097          	auipc	ra,0x0
    80005a9c:	c66080e7          	jalr	-922(ra) # 800056fe <argfd>
    80005aa0:	87aa                	mv	a5,a0
    return -1;
    80005aa2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005aa4:	0007ca63          	bltz	a5,80005ab8 <sys_fstat+0x3e>
  return filestat(f, st);
    80005aa8:	fe043583          	ld	a1,-32(s0)
    80005aac:	fe843503          	ld	a0,-24(s0)
    80005ab0:	fffff097          	auipc	ra,0xfffff
    80005ab4:	2de080e7          	jalr	734(ra) # 80004d8e <filestat>
}
    80005ab8:	60e2                	ld	ra,24(sp)
    80005aba:	6442                	ld	s0,16(sp)
    80005abc:	6105                	addi	sp,sp,32
    80005abe:	8082                	ret

0000000080005ac0 <sys_link>:
{
    80005ac0:	7169                	addi	sp,sp,-304
    80005ac2:	f606                	sd	ra,296(sp)
    80005ac4:	f222                	sd	s0,288(sp)
    80005ac6:	ee26                	sd	s1,280(sp)
    80005ac8:	ea4a                	sd	s2,272(sp)
    80005aca:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005acc:	08000613          	li	a2,128
    80005ad0:	ed040593          	addi	a1,s0,-304
    80005ad4:	4501                	li	a0,0
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	71c080e7          	jalr	1820(ra) # 800031f2 <argstr>
    return -1;
    80005ade:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005ae0:	10054e63          	bltz	a0,80005bfc <sys_link+0x13c>
    80005ae4:	08000613          	li	a2,128
    80005ae8:	f5040593          	addi	a1,s0,-176
    80005aec:	4505                	li	a0,1
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	704080e7          	jalr	1796(ra) # 800031f2 <argstr>
    return -1;
    80005af6:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005af8:	10054263          	bltz	a0,80005bfc <sys_link+0x13c>
  begin_op();
    80005afc:	fffff097          	auipc	ra,0xfffff
    80005b00:	d02080e7          	jalr	-766(ra) # 800047fe <begin_op>
  if((ip = namei(old)) == 0){
    80005b04:	ed040513          	addi	a0,s0,-304
    80005b08:	fffff097          	auipc	ra,0xfffff
    80005b0c:	ad6080e7          	jalr	-1322(ra) # 800045de <namei>
    80005b10:	84aa                	mv	s1,a0
    80005b12:	c551                	beqz	a0,80005b9e <sys_link+0xde>
  ilock(ip);
    80005b14:	ffffe097          	auipc	ra,0xffffe
    80005b18:	31e080e7          	jalr	798(ra) # 80003e32 <ilock>
  if(ip->type == T_DIR){
    80005b1c:	04449703          	lh	a4,68(s1)
    80005b20:	4785                	li	a5,1
    80005b22:	08f70463          	beq	a4,a5,80005baa <sys_link+0xea>
  ip->nlink++;
    80005b26:	04a4d783          	lhu	a5,74(s1)
    80005b2a:	2785                	addiw	a5,a5,1
    80005b2c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005b30:	8526                	mv	a0,s1
    80005b32:	ffffe097          	auipc	ra,0xffffe
    80005b36:	234080e7          	jalr	564(ra) # 80003d66 <iupdate>
  iunlock(ip);
    80005b3a:	8526                	mv	a0,s1
    80005b3c:	ffffe097          	auipc	ra,0xffffe
    80005b40:	3b8080e7          	jalr	952(ra) # 80003ef4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005b44:	fd040593          	addi	a1,s0,-48
    80005b48:	f5040513          	addi	a0,s0,-176
    80005b4c:	fffff097          	auipc	ra,0xfffff
    80005b50:	ab0080e7          	jalr	-1360(ra) # 800045fc <nameiparent>
    80005b54:	892a                	mv	s2,a0
    80005b56:	c935                	beqz	a0,80005bca <sys_link+0x10a>
  ilock(dp);
    80005b58:	ffffe097          	auipc	ra,0xffffe
    80005b5c:	2da080e7          	jalr	730(ra) # 80003e32 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005b60:	00092703          	lw	a4,0(s2)
    80005b64:	409c                	lw	a5,0(s1)
    80005b66:	04f71d63          	bne	a4,a5,80005bc0 <sys_link+0x100>
    80005b6a:	40d0                	lw	a2,4(s1)
    80005b6c:	fd040593          	addi	a1,s0,-48
    80005b70:	854a                	mv	a0,s2
    80005b72:	fffff097          	auipc	ra,0xfffff
    80005b76:	9ba080e7          	jalr	-1606(ra) # 8000452c <dirlink>
    80005b7a:	04054363          	bltz	a0,80005bc0 <sys_link+0x100>
  iunlockput(dp);
    80005b7e:	854a                	mv	a0,s2
    80005b80:	ffffe097          	auipc	ra,0xffffe
    80005b84:	514080e7          	jalr	1300(ra) # 80004094 <iunlockput>
  iput(ip);
    80005b88:	8526                	mv	a0,s1
    80005b8a:	ffffe097          	auipc	ra,0xffffe
    80005b8e:	462080e7          	jalr	1122(ra) # 80003fec <iput>
  end_op();
    80005b92:	fffff097          	auipc	ra,0xfffff
    80005b96:	cea080e7          	jalr	-790(ra) # 8000487c <end_op>
  return 0;
    80005b9a:	4781                	li	a5,0
    80005b9c:	a085                	j	80005bfc <sys_link+0x13c>
    end_op();
    80005b9e:	fffff097          	auipc	ra,0xfffff
    80005ba2:	cde080e7          	jalr	-802(ra) # 8000487c <end_op>
    return -1;
    80005ba6:	57fd                	li	a5,-1
    80005ba8:	a891                	j	80005bfc <sys_link+0x13c>
    iunlockput(ip);
    80005baa:	8526                	mv	a0,s1
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	4e8080e7          	jalr	1256(ra) # 80004094 <iunlockput>
    end_op();
    80005bb4:	fffff097          	auipc	ra,0xfffff
    80005bb8:	cc8080e7          	jalr	-824(ra) # 8000487c <end_op>
    return -1;
    80005bbc:	57fd                	li	a5,-1
    80005bbe:	a83d                	j	80005bfc <sys_link+0x13c>
    iunlockput(dp);
    80005bc0:	854a                	mv	a0,s2
    80005bc2:	ffffe097          	auipc	ra,0xffffe
    80005bc6:	4d2080e7          	jalr	1234(ra) # 80004094 <iunlockput>
  ilock(ip);
    80005bca:	8526                	mv	a0,s1
    80005bcc:	ffffe097          	auipc	ra,0xffffe
    80005bd0:	266080e7          	jalr	614(ra) # 80003e32 <ilock>
  ip->nlink--;
    80005bd4:	04a4d783          	lhu	a5,74(s1)
    80005bd8:	37fd                	addiw	a5,a5,-1
    80005bda:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005bde:	8526                	mv	a0,s1
    80005be0:	ffffe097          	auipc	ra,0xffffe
    80005be4:	186080e7          	jalr	390(ra) # 80003d66 <iupdate>
  iunlockput(ip);
    80005be8:	8526                	mv	a0,s1
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	4aa080e7          	jalr	1194(ra) # 80004094 <iunlockput>
  end_op();
    80005bf2:	fffff097          	auipc	ra,0xfffff
    80005bf6:	c8a080e7          	jalr	-886(ra) # 8000487c <end_op>
  return -1;
    80005bfa:	57fd                	li	a5,-1
}
    80005bfc:	853e                	mv	a0,a5
    80005bfe:	70b2                	ld	ra,296(sp)
    80005c00:	7412                	ld	s0,288(sp)
    80005c02:	64f2                	ld	s1,280(sp)
    80005c04:	6952                	ld	s2,272(sp)
    80005c06:	6155                	addi	sp,sp,304
    80005c08:	8082                	ret

0000000080005c0a <sys_unlink>:
{
    80005c0a:	7151                	addi	sp,sp,-240
    80005c0c:	f586                	sd	ra,232(sp)
    80005c0e:	f1a2                	sd	s0,224(sp)
    80005c10:	eda6                	sd	s1,216(sp)
    80005c12:	e9ca                	sd	s2,208(sp)
    80005c14:	e5ce                	sd	s3,200(sp)
    80005c16:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005c18:	08000613          	li	a2,128
    80005c1c:	f3040593          	addi	a1,s0,-208
    80005c20:	4501                	li	a0,0
    80005c22:	ffffd097          	auipc	ra,0xffffd
    80005c26:	5d0080e7          	jalr	1488(ra) # 800031f2 <argstr>
    80005c2a:	18054163          	bltz	a0,80005dac <sys_unlink+0x1a2>
  begin_op();
    80005c2e:	fffff097          	auipc	ra,0xfffff
    80005c32:	bd0080e7          	jalr	-1072(ra) # 800047fe <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005c36:	fb040593          	addi	a1,s0,-80
    80005c3a:	f3040513          	addi	a0,s0,-208
    80005c3e:	fffff097          	auipc	ra,0xfffff
    80005c42:	9be080e7          	jalr	-1602(ra) # 800045fc <nameiparent>
    80005c46:	84aa                	mv	s1,a0
    80005c48:	c979                	beqz	a0,80005d1e <sys_unlink+0x114>
  ilock(dp);
    80005c4a:	ffffe097          	auipc	ra,0xffffe
    80005c4e:	1e8080e7          	jalr	488(ra) # 80003e32 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005c52:	00003597          	auipc	a1,0x3
    80005c56:	c5658593          	addi	a1,a1,-938 # 800088a8 <syscalls+0x2c8>
    80005c5a:	fb040513          	addi	a0,s0,-80
    80005c5e:	ffffe097          	auipc	ra,0xffffe
    80005c62:	69e080e7          	jalr	1694(ra) # 800042fc <namecmp>
    80005c66:	14050a63          	beqz	a0,80005dba <sys_unlink+0x1b0>
    80005c6a:	00003597          	auipc	a1,0x3
    80005c6e:	c4658593          	addi	a1,a1,-954 # 800088b0 <syscalls+0x2d0>
    80005c72:	fb040513          	addi	a0,s0,-80
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	686080e7          	jalr	1670(ra) # 800042fc <namecmp>
    80005c7e:	12050e63          	beqz	a0,80005dba <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005c82:	f2c40613          	addi	a2,s0,-212
    80005c86:	fb040593          	addi	a1,s0,-80
    80005c8a:	8526                	mv	a0,s1
    80005c8c:	ffffe097          	auipc	ra,0xffffe
    80005c90:	68a080e7          	jalr	1674(ra) # 80004316 <dirlookup>
    80005c94:	892a                	mv	s2,a0
    80005c96:	12050263          	beqz	a0,80005dba <sys_unlink+0x1b0>
  ilock(ip);
    80005c9a:	ffffe097          	auipc	ra,0xffffe
    80005c9e:	198080e7          	jalr	408(ra) # 80003e32 <ilock>
  if(ip->nlink < 1)
    80005ca2:	04a91783          	lh	a5,74(s2)
    80005ca6:	08f05263          	blez	a5,80005d2a <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005caa:	04491703          	lh	a4,68(s2)
    80005cae:	4785                	li	a5,1
    80005cb0:	08f70563          	beq	a4,a5,80005d3a <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005cb4:	4641                	li	a2,16
    80005cb6:	4581                	li	a1,0
    80005cb8:	fc040513          	addi	a0,s0,-64
    80005cbc:	ffffb097          	auipc	ra,0xffffb
    80005cc0:	0de080e7          	jalr	222(ra) # 80000d9a <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005cc4:	4741                	li	a4,16
    80005cc6:	f2c42683          	lw	a3,-212(s0)
    80005cca:	fc040613          	addi	a2,s0,-64
    80005cce:	4581                	li	a1,0
    80005cd0:	8526                	mv	a0,s1
    80005cd2:	ffffe097          	auipc	ra,0xffffe
    80005cd6:	50c080e7          	jalr	1292(ra) # 800041de <writei>
    80005cda:	47c1                	li	a5,16
    80005cdc:	0af51563          	bne	a0,a5,80005d86 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005ce0:	04491703          	lh	a4,68(s2)
    80005ce4:	4785                	li	a5,1
    80005ce6:	0af70863          	beq	a4,a5,80005d96 <sys_unlink+0x18c>
  iunlockput(dp);
    80005cea:	8526                	mv	a0,s1
    80005cec:	ffffe097          	auipc	ra,0xffffe
    80005cf0:	3a8080e7          	jalr	936(ra) # 80004094 <iunlockput>
  ip->nlink--;
    80005cf4:	04a95783          	lhu	a5,74(s2)
    80005cf8:	37fd                	addiw	a5,a5,-1
    80005cfa:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005cfe:	854a                	mv	a0,s2
    80005d00:	ffffe097          	auipc	ra,0xffffe
    80005d04:	066080e7          	jalr	102(ra) # 80003d66 <iupdate>
  iunlockput(ip);
    80005d08:	854a                	mv	a0,s2
    80005d0a:	ffffe097          	auipc	ra,0xffffe
    80005d0e:	38a080e7          	jalr	906(ra) # 80004094 <iunlockput>
  end_op();
    80005d12:	fffff097          	auipc	ra,0xfffff
    80005d16:	b6a080e7          	jalr	-1174(ra) # 8000487c <end_op>
  return 0;
    80005d1a:	4501                	li	a0,0
    80005d1c:	a84d                	j	80005dce <sys_unlink+0x1c4>
    end_op();
    80005d1e:	fffff097          	auipc	ra,0xfffff
    80005d22:	b5e080e7          	jalr	-1186(ra) # 8000487c <end_op>
    return -1;
    80005d26:	557d                	li	a0,-1
    80005d28:	a05d                	j	80005dce <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005d2a:	00003517          	auipc	a0,0x3
    80005d2e:	b8e50513          	addi	a0,a0,-1138 # 800088b8 <syscalls+0x2d8>
    80005d32:	ffffb097          	auipc	ra,0xffffb
    80005d36:	80e080e7          	jalr	-2034(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d3a:	04c92703          	lw	a4,76(s2)
    80005d3e:	02000793          	li	a5,32
    80005d42:	f6e7f9e3          	bgeu	a5,a4,80005cb4 <sys_unlink+0xaa>
    80005d46:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005d4a:	4741                	li	a4,16
    80005d4c:	86ce                	mv	a3,s3
    80005d4e:	f1840613          	addi	a2,s0,-232
    80005d52:	4581                	li	a1,0
    80005d54:	854a                	mv	a0,s2
    80005d56:	ffffe097          	auipc	ra,0xffffe
    80005d5a:	390080e7          	jalr	912(ra) # 800040e6 <readi>
    80005d5e:	47c1                	li	a5,16
    80005d60:	00f51b63          	bne	a0,a5,80005d76 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005d64:	f1845783          	lhu	a5,-232(s0)
    80005d68:	e7a1                	bnez	a5,80005db0 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005d6a:	29c1                	addiw	s3,s3,16
    80005d6c:	04c92783          	lw	a5,76(s2)
    80005d70:	fcf9ede3          	bltu	s3,a5,80005d4a <sys_unlink+0x140>
    80005d74:	b781                	j	80005cb4 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005d76:	00003517          	auipc	a0,0x3
    80005d7a:	b5a50513          	addi	a0,a0,-1190 # 800088d0 <syscalls+0x2f0>
    80005d7e:	ffffa097          	auipc	ra,0xffffa
    80005d82:	7c2080e7          	jalr	1986(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005d86:	00003517          	auipc	a0,0x3
    80005d8a:	b6250513          	addi	a0,a0,-1182 # 800088e8 <syscalls+0x308>
    80005d8e:	ffffa097          	auipc	ra,0xffffa
    80005d92:	7b2080e7          	jalr	1970(ra) # 80000540 <panic>
    dp->nlink--;
    80005d96:	04a4d783          	lhu	a5,74(s1)
    80005d9a:	37fd                	addiw	a5,a5,-1
    80005d9c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005da0:	8526                	mv	a0,s1
    80005da2:	ffffe097          	auipc	ra,0xffffe
    80005da6:	fc4080e7          	jalr	-60(ra) # 80003d66 <iupdate>
    80005daa:	b781                	j	80005cea <sys_unlink+0xe0>
    return -1;
    80005dac:	557d                	li	a0,-1
    80005dae:	a005                	j	80005dce <sys_unlink+0x1c4>
    iunlockput(ip);
    80005db0:	854a                	mv	a0,s2
    80005db2:	ffffe097          	auipc	ra,0xffffe
    80005db6:	2e2080e7          	jalr	738(ra) # 80004094 <iunlockput>
  iunlockput(dp);
    80005dba:	8526                	mv	a0,s1
    80005dbc:	ffffe097          	auipc	ra,0xffffe
    80005dc0:	2d8080e7          	jalr	728(ra) # 80004094 <iunlockput>
  end_op();
    80005dc4:	fffff097          	auipc	ra,0xfffff
    80005dc8:	ab8080e7          	jalr	-1352(ra) # 8000487c <end_op>
  return -1;
    80005dcc:	557d                	li	a0,-1
}
    80005dce:	70ae                	ld	ra,232(sp)
    80005dd0:	740e                	ld	s0,224(sp)
    80005dd2:	64ee                	ld	s1,216(sp)
    80005dd4:	694e                	ld	s2,208(sp)
    80005dd6:	69ae                	ld	s3,200(sp)
    80005dd8:	616d                	addi	sp,sp,240
    80005dda:	8082                	ret

0000000080005ddc <sys_open>:

uint64
sys_open(void)
{
    80005ddc:	7131                	addi	sp,sp,-192
    80005dde:	fd06                	sd	ra,184(sp)
    80005de0:	f922                	sd	s0,176(sp)
    80005de2:	f526                	sd	s1,168(sp)
    80005de4:	f14a                	sd	s2,160(sp)
    80005de6:	ed4e                	sd	s3,152(sp)
    80005de8:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005dea:	f4c40593          	addi	a1,s0,-180
    80005dee:	4505                	li	a0,1
    80005df0:	ffffd097          	auipc	ra,0xffffd
    80005df4:	3c2080e7          	jalr	962(ra) # 800031b2 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005df8:	08000613          	li	a2,128
    80005dfc:	f5040593          	addi	a1,s0,-176
    80005e00:	4501                	li	a0,0
    80005e02:	ffffd097          	auipc	ra,0xffffd
    80005e06:	3f0080e7          	jalr	1008(ra) # 800031f2 <argstr>
    80005e0a:	87aa                	mv	a5,a0
    return -1;
    80005e0c:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005e0e:	0a07c963          	bltz	a5,80005ec0 <sys_open+0xe4>

  begin_op();
    80005e12:	fffff097          	auipc	ra,0xfffff
    80005e16:	9ec080e7          	jalr	-1556(ra) # 800047fe <begin_op>

  if(omode & O_CREATE){
    80005e1a:	f4c42783          	lw	a5,-180(s0)
    80005e1e:	2007f793          	andi	a5,a5,512
    80005e22:	cfc5                	beqz	a5,80005eda <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005e24:	4681                	li	a3,0
    80005e26:	4601                	li	a2,0
    80005e28:	4589                	li	a1,2
    80005e2a:	f5040513          	addi	a0,s0,-176
    80005e2e:	00000097          	auipc	ra,0x0
    80005e32:	972080e7          	jalr	-1678(ra) # 800057a0 <create>
    80005e36:	84aa                	mv	s1,a0
    if(ip == 0){
    80005e38:	c959                	beqz	a0,80005ece <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005e3a:	04449703          	lh	a4,68(s1)
    80005e3e:	478d                	li	a5,3
    80005e40:	00f71763          	bne	a4,a5,80005e4e <sys_open+0x72>
    80005e44:	0464d703          	lhu	a4,70(s1)
    80005e48:	47a5                	li	a5,9
    80005e4a:	0ce7ed63          	bltu	a5,a4,80005f24 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005e4e:	fffff097          	auipc	ra,0xfffff
    80005e52:	dbc080e7          	jalr	-580(ra) # 80004c0a <filealloc>
    80005e56:	89aa                	mv	s3,a0
    80005e58:	10050363          	beqz	a0,80005f5e <sys_open+0x182>
    80005e5c:	00000097          	auipc	ra,0x0
    80005e60:	902080e7          	jalr	-1790(ra) # 8000575e <fdalloc>
    80005e64:	892a                	mv	s2,a0
    80005e66:	0e054763          	bltz	a0,80005f54 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005e6a:	04449703          	lh	a4,68(s1)
    80005e6e:	478d                	li	a5,3
    80005e70:	0cf70563          	beq	a4,a5,80005f3a <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005e74:	4789                	li	a5,2
    80005e76:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005e7a:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    80005e7e:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    80005e82:	f4c42783          	lw	a5,-180(s0)
    80005e86:	0017c713          	xori	a4,a5,1
    80005e8a:	8b05                	andi	a4,a4,1
    80005e8c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005e90:	0037f713          	andi	a4,a5,3
    80005e94:	00e03733          	snez	a4,a4
    80005e98:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005e9c:	4007f793          	andi	a5,a5,1024
    80005ea0:	c791                	beqz	a5,80005eac <sys_open+0xd0>
    80005ea2:	04449703          	lh	a4,68(s1)
    80005ea6:	4789                	li	a5,2
    80005ea8:	0af70063          	beq	a4,a5,80005f48 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005eac:	8526                	mv	a0,s1
    80005eae:	ffffe097          	auipc	ra,0xffffe
    80005eb2:	046080e7          	jalr	70(ra) # 80003ef4 <iunlock>
  end_op();
    80005eb6:	fffff097          	auipc	ra,0xfffff
    80005eba:	9c6080e7          	jalr	-1594(ra) # 8000487c <end_op>

  return fd;
    80005ebe:	854a                	mv	a0,s2
}
    80005ec0:	70ea                	ld	ra,184(sp)
    80005ec2:	744a                	ld	s0,176(sp)
    80005ec4:	74aa                	ld	s1,168(sp)
    80005ec6:	790a                	ld	s2,160(sp)
    80005ec8:	69ea                	ld	s3,152(sp)
    80005eca:	6129                	addi	sp,sp,192
    80005ecc:	8082                	ret
      end_op();
    80005ece:	fffff097          	auipc	ra,0xfffff
    80005ed2:	9ae080e7          	jalr	-1618(ra) # 8000487c <end_op>
      return -1;
    80005ed6:	557d                	li	a0,-1
    80005ed8:	b7e5                	j	80005ec0 <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80005eda:	f5040513          	addi	a0,s0,-176
    80005ede:	ffffe097          	auipc	ra,0xffffe
    80005ee2:	700080e7          	jalr	1792(ra) # 800045de <namei>
    80005ee6:	84aa                	mv	s1,a0
    80005ee8:	c905                	beqz	a0,80005f18 <sys_open+0x13c>
    ilock(ip);
    80005eea:	ffffe097          	auipc	ra,0xffffe
    80005eee:	f48080e7          	jalr	-184(ra) # 80003e32 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005ef2:	04449703          	lh	a4,68(s1)
    80005ef6:	4785                	li	a5,1
    80005ef8:	f4f711e3          	bne	a4,a5,80005e3a <sys_open+0x5e>
    80005efc:	f4c42783          	lw	a5,-180(s0)
    80005f00:	d7b9                	beqz	a5,80005e4e <sys_open+0x72>
      iunlockput(ip);
    80005f02:	8526                	mv	a0,s1
    80005f04:	ffffe097          	auipc	ra,0xffffe
    80005f08:	190080e7          	jalr	400(ra) # 80004094 <iunlockput>
      end_op();
    80005f0c:	fffff097          	auipc	ra,0xfffff
    80005f10:	970080e7          	jalr	-1680(ra) # 8000487c <end_op>
      return -1;
    80005f14:	557d                	li	a0,-1
    80005f16:	b76d                	j	80005ec0 <sys_open+0xe4>
      end_op();
    80005f18:	fffff097          	auipc	ra,0xfffff
    80005f1c:	964080e7          	jalr	-1692(ra) # 8000487c <end_op>
      return -1;
    80005f20:	557d                	li	a0,-1
    80005f22:	bf79                	j	80005ec0 <sys_open+0xe4>
    iunlockput(ip);
    80005f24:	8526                	mv	a0,s1
    80005f26:	ffffe097          	auipc	ra,0xffffe
    80005f2a:	16e080e7          	jalr	366(ra) # 80004094 <iunlockput>
    end_op();
    80005f2e:	fffff097          	auipc	ra,0xfffff
    80005f32:	94e080e7          	jalr	-1714(ra) # 8000487c <end_op>
    return -1;
    80005f36:	557d                	li	a0,-1
    80005f38:	b761                	j	80005ec0 <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005f3a:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005f3e:	04649783          	lh	a5,70(s1)
    80005f42:	02f99223          	sh	a5,36(s3)
    80005f46:	bf25                	j	80005e7e <sys_open+0xa2>
    itrunc(ip);
    80005f48:	8526                	mv	a0,s1
    80005f4a:	ffffe097          	auipc	ra,0xffffe
    80005f4e:	ff6080e7          	jalr	-10(ra) # 80003f40 <itrunc>
    80005f52:	bfa9                	j	80005eac <sys_open+0xd0>
      fileclose(f);
    80005f54:	854e                	mv	a0,s3
    80005f56:	fffff097          	auipc	ra,0xfffff
    80005f5a:	d70080e7          	jalr	-656(ra) # 80004cc6 <fileclose>
    iunlockput(ip);
    80005f5e:	8526                	mv	a0,s1
    80005f60:	ffffe097          	auipc	ra,0xffffe
    80005f64:	134080e7          	jalr	308(ra) # 80004094 <iunlockput>
    end_op();
    80005f68:	fffff097          	auipc	ra,0xfffff
    80005f6c:	914080e7          	jalr	-1772(ra) # 8000487c <end_op>
    return -1;
    80005f70:	557d                	li	a0,-1
    80005f72:	b7b9                	j	80005ec0 <sys_open+0xe4>

0000000080005f74 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005f74:	7175                	addi	sp,sp,-144
    80005f76:	e506                	sd	ra,136(sp)
    80005f78:	e122                	sd	s0,128(sp)
    80005f7a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005f7c:	fffff097          	auipc	ra,0xfffff
    80005f80:	882080e7          	jalr	-1918(ra) # 800047fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005f84:	08000613          	li	a2,128
    80005f88:	f7040593          	addi	a1,s0,-144
    80005f8c:	4501                	li	a0,0
    80005f8e:	ffffd097          	auipc	ra,0xffffd
    80005f92:	264080e7          	jalr	612(ra) # 800031f2 <argstr>
    80005f96:	02054963          	bltz	a0,80005fc8 <sys_mkdir+0x54>
    80005f9a:	4681                	li	a3,0
    80005f9c:	4601                	li	a2,0
    80005f9e:	4585                	li	a1,1
    80005fa0:	f7040513          	addi	a0,s0,-144
    80005fa4:	fffff097          	auipc	ra,0xfffff
    80005fa8:	7fc080e7          	jalr	2044(ra) # 800057a0 <create>
    80005fac:	cd11                	beqz	a0,80005fc8 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005fae:	ffffe097          	auipc	ra,0xffffe
    80005fb2:	0e6080e7          	jalr	230(ra) # 80004094 <iunlockput>
  end_op();
    80005fb6:	fffff097          	auipc	ra,0xfffff
    80005fba:	8c6080e7          	jalr	-1850(ra) # 8000487c <end_op>
  return 0;
    80005fbe:	4501                	li	a0,0
}
    80005fc0:	60aa                	ld	ra,136(sp)
    80005fc2:	640a                	ld	s0,128(sp)
    80005fc4:	6149                	addi	sp,sp,144
    80005fc6:	8082                	ret
    end_op();
    80005fc8:	fffff097          	auipc	ra,0xfffff
    80005fcc:	8b4080e7          	jalr	-1868(ra) # 8000487c <end_op>
    return -1;
    80005fd0:	557d                	li	a0,-1
    80005fd2:	b7fd                	j	80005fc0 <sys_mkdir+0x4c>

0000000080005fd4 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005fd4:	7135                	addi	sp,sp,-160
    80005fd6:	ed06                	sd	ra,152(sp)
    80005fd8:	e922                	sd	s0,144(sp)
    80005fda:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005fdc:	fffff097          	auipc	ra,0xfffff
    80005fe0:	822080e7          	jalr	-2014(ra) # 800047fe <begin_op>
  argint(1, &major);
    80005fe4:	f6c40593          	addi	a1,s0,-148
    80005fe8:	4505                	li	a0,1
    80005fea:	ffffd097          	auipc	ra,0xffffd
    80005fee:	1c8080e7          	jalr	456(ra) # 800031b2 <argint>
  argint(2, &minor);
    80005ff2:	f6840593          	addi	a1,s0,-152
    80005ff6:	4509                	li	a0,2
    80005ff8:	ffffd097          	auipc	ra,0xffffd
    80005ffc:	1ba080e7          	jalr	442(ra) # 800031b2 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80006000:	08000613          	li	a2,128
    80006004:	f7040593          	addi	a1,s0,-144
    80006008:	4501                	li	a0,0
    8000600a:	ffffd097          	auipc	ra,0xffffd
    8000600e:	1e8080e7          	jalr	488(ra) # 800031f2 <argstr>
    80006012:	02054b63          	bltz	a0,80006048 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80006016:	f6841683          	lh	a3,-152(s0)
    8000601a:	f6c41603          	lh	a2,-148(s0)
    8000601e:	458d                	li	a1,3
    80006020:	f7040513          	addi	a0,s0,-144
    80006024:	fffff097          	auipc	ra,0xfffff
    80006028:	77c080e7          	jalr	1916(ra) # 800057a0 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000602c:	cd11                	beqz	a0,80006048 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000602e:	ffffe097          	auipc	ra,0xffffe
    80006032:	066080e7          	jalr	102(ra) # 80004094 <iunlockput>
  end_op();
    80006036:	fffff097          	auipc	ra,0xfffff
    8000603a:	846080e7          	jalr	-1978(ra) # 8000487c <end_op>
  return 0;
    8000603e:	4501                	li	a0,0
}
    80006040:	60ea                	ld	ra,152(sp)
    80006042:	644a                	ld	s0,144(sp)
    80006044:	610d                	addi	sp,sp,160
    80006046:	8082                	ret
    end_op();
    80006048:	fffff097          	auipc	ra,0xfffff
    8000604c:	834080e7          	jalr	-1996(ra) # 8000487c <end_op>
    return -1;
    80006050:	557d                	li	a0,-1
    80006052:	b7fd                	j	80006040 <sys_mknod+0x6c>

0000000080006054 <sys_chdir>:

uint64
sys_chdir(void)
{
    80006054:	7135                	addi	sp,sp,-160
    80006056:	ed06                	sd	ra,152(sp)
    80006058:	e922                	sd	s0,144(sp)
    8000605a:	e526                	sd	s1,136(sp)
    8000605c:	e14a                	sd	s2,128(sp)
    8000605e:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80006060:	ffffc097          	auipc	ra,0xffffc
    80006064:	bd0080e7          	jalr	-1072(ra) # 80001c30 <myproc>
    80006068:	892a                	mv	s2,a0
  
  begin_op();
    8000606a:	ffffe097          	auipc	ra,0xffffe
    8000606e:	794080e7          	jalr	1940(ra) # 800047fe <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80006072:	08000613          	li	a2,128
    80006076:	f6040593          	addi	a1,s0,-160
    8000607a:	4501                	li	a0,0
    8000607c:	ffffd097          	auipc	ra,0xffffd
    80006080:	176080e7          	jalr	374(ra) # 800031f2 <argstr>
    80006084:	04054b63          	bltz	a0,800060da <sys_chdir+0x86>
    80006088:	f6040513          	addi	a0,s0,-160
    8000608c:	ffffe097          	auipc	ra,0xffffe
    80006090:	552080e7          	jalr	1362(ra) # 800045de <namei>
    80006094:	84aa                	mv	s1,a0
    80006096:	c131                	beqz	a0,800060da <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80006098:	ffffe097          	auipc	ra,0xffffe
    8000609c:	d9a080e7          	jalr	-614(ra) # 80003e32 <ilock>
  if(ip->type != T_DIR){
    800060a0:	04449703          	lh	a4,68(s1)
    800060a4:	4785                	li	a5,1
    800060a6:	04f71063          	bne	a4,a5,800060e6 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800060aa:	8526                	mv	a0,s1
    800060ac:	ffffe097          	auipc	ra,0xffffe
    800060b0:	e48080e7          	jalr	-440(ra) # 80003ef4 <iunlock>
  iput(p->cwd);
    800060b4:	15093503          	ld	a0,336(s2)
    800060b8:	ffffe097          	auipc	ra,0xffffe
    800060bc:	f34080e7          	jalr	-204(ra) # 80003fec <iput>
  end_op();
    800060c0:	ffffe097          	auipc	ra,0xffffe
    800060c4:	7bc080e7          	jalr	1980(ra) # 8000487c <end_op>
  p->cwd = ip;
    800060c8:	14993823          	sd	s1,336(s2)
  return 0;
    800060cc:	4501                	li	a0,0
}
    800060ce:	60ea                	ld	ra,152(sp)
    800060d0:	644a                	ld	s0,144(sp)
    800060d2:	64aa                	ld	s1,136(sp)
    800060d4:	690a                	ld	s2,128(sp)
    800060d6:	610d                	addi	sp,sp,160
    800060d8:	8082                	ret
    end_op();
    800060da:	ffffe097          	auipc	ra,0xffffe
    800060de:	7a2080e7          	jalr	1954(ra) # 8000487c <end_op>
    return -1;
    800060e2:	557d                	li	a0,-1
    800060e4:	b7ed                	j	800060ce <sys_chdir+0x7a>
    iunlockput(ip);
    800060e6:	8526                	mv	a0,s1
    800060e8:	ffffe097          	auipc	ra,0xffffe
    800060ec:	fac080e7          	jalr	-84(ra) # 80004094 <iunlockput>
    end_op();
    800060f0:	ffffe097          	auipc	ra,0xffffe
    800060f4:	78c080e7          	jalr	1932(ra) # 8000487c <end_op>
    return -1;
    800060f8:	557d                	li	a0,-1
    800060fa:	bfd1                	j	800060ce <sys_chdir+0x7a>

00000000800060fc <sys_exec>:

uint64
sys_exec(void)
{
    800060fc:	7145                	addi	sp,sp,-464
    800060fe:	e786                	sd	ra,456(sp)
    80006100:	e3a2                	sd	s0,448(sp)
    80006102:	ff26                	sd	s1,440(sp)
    80006104:	fb4a                	sd	s2,432(sp)
    80006106:	f74e                	sd	s3,424(sp)
    80006108:	f352                	sd	s4,416(sp)
    8000610a:	ef56                	sd	s5,408(sp)
    8000610c:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    8000610e:	e3840593          	addi	a1,s0,-456
    80006112:	4505                	li	a0,1
    80006114:	ffffd097          	auipc	ra,0xffffd
    80006118:	0be080e7          	jalr	190(ra) # 800031d2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    8000611c:	08000613          	li	a2,128
    80006120:	f4040593          	addi	a1,s0,-192
    80006124:	4501                	li	a0,0
    80006126:	ffffd097          	auipc	ra,0xffffd
    8000612a:	0cc080e7          	jalr	204(ra) # 800031f2 <argstr>
    8000612e:	87aa                	mv	a5,a0
    return -1;
    80006130:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80006132:	0c07c363          	bltz	a5,800061f8 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80006136:	10000613          	li	a2,256
    8000613a:	4581                	li	a1,0
    8000613c:	e4040513          	addi	a0,s0,-448
    80006140:	ffffb097          	auipc	ra,0xffffb
    80006144:	c5a080e7          	jalr	-934(ra) # 80000d9a <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80006148:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    8000614c:	89a6                	mv	s3,s1
    8000614e:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80006150:	02000a13          	li	s4,32
    80006154:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80006158:	00391513          	slli	a0,s2,0x3
    8000615c:	e3040593          	addi	a1,s0,-464
    80006160:	e3843783          	ld	a5,-456(s0)
    80006164:	953e                	add	a0,a0,a5
    80006166:	ffffd097          	auipc	ra,0xffffd
    8000616a:	fae080e7          	jalr	-82(ra) # 80003114 <fetchaddr>
    8000616e:	02054a63          	bltz	a0,800061a2 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80006172:	e3043783          	ld	a5,-464(s0)
    80006176:	c3b9                	beqz	a5,800061bc <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80006178:	ffffb097          	auipc	ra,0xffffb
    8000617c:	9ea080e7          	jalr	-1558(ra) # 80000b62 <kalloc>
    80006180:	85aa                	mv	a1,a0
    80006182:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80006186:	cd11                	beqz	a0,800061a2 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80006188:	6605                	lui	a2,0x1
    8000618a:	e3043503          	ld	a0,-464(s0)
    8000618e:	ffffd097          	auipc	ra,0xffffd
    80006192:	fd8080e7          	jalr	-40(ra) # 80003166 <fetchstr>
    80006196:	00054663          	bltz	a0,800061a2 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    8000619a:	0905                	addi	s2,s2,1
    8000619c:	09a1                	addi	s3,s3,8
    8000619e:	fb491be3          	bne	s2,s4,80006154 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061a2:	f4040913          	addi	s2,s0,-192
    800061a6:	6088                	ld	a0,0(s1)
    800061a8:	c539                	beqz	a0,800061f6 <sys_exec+0xfa>
    kfree(argv[i]);
    800061aa:	ffffb097          	auipc	ra,0xffffb
    800061ae:	850080e7          	jalr	-1968(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061b2:	04a1                	addi	s1,s1,8
    800061b4:	ff2499e3          	bne	s1,s2,800061a6 <sys_exec+0xaa>
  return -1;
    800061b8:	557d                	li	a0,-1
    800061ba:	a83d                	j	800061f8 <sys_exec+0xfc>
      argv[i] = 0;
    800061bc:	0a8e                	slli	s5,s5,0x3
    800061be:	fc0a8793          	addi	a5,s5,-64
    800061c2:	00878ab3          	add	s5,a5,s0
    800061c6:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    800061ca:	e4040593          	addi	a1,s0,-448
    800061ce:	f4040513          	addi	a0,s0,-192
    800061d2:	fffff097          	auipc	ra,0xfffff
    800061d6:	16e080e7          	jalr	366(ra) # 80005340 <exec>
    800061da:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061dc:	f4040993          	addi	s3,s0,-192
    800061e0:	6088                	ld	a0,0(s1)
    800061e2:	c901                	beqz	a0,800061f2 <sys_exec+0xf6>
    kfree(argv[i]);
    800061e4:	ffffb097          	auipc	ra,0xffffb
    800061e8:	816080e7          	jalr	-2026(ra) # 800009fa <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800061ec:	04a1                	addi	s1,s1,8
    800061ee:	ff3499e3          	bne	s1,s3,800061e0 <sys_exec+0xe4>
  return ret;
    800061f2:	854a                	mv	a0,s2
    800061f4:	a011                	j	800061f8 <sys_exec+0xfc>
  return -1;
    800061f6:	557d                	li	a0,-1
}
    800061f8:	60be                	ld	ra,456(sp)
    800061fa:	641e                	ld	s0,448(sp)
    800061fc:	74fa                	ld	s1,440(sp)
    800061fe:	795a                	ld	s2,432(sp)
    80006200:	79ba                	ld	s3,424(sp)
    80006202:	7a1a                	ld	s4,416(sp)
    80006204:	6afa                	ld	s5,408(sp)
    80006206:	6179                	addi	sp,sp,464
    80006208:	8082                	ret

000000008000620a <sys_pipe>:

uint64
sys_pipe(void)
{
    8000620a:	7139                	addi	sp,sp,-64
    8000620c:	fc06                	sd	ra,56(sp)
    8000620e:	f822                	sd	s0,48(sp)
    80006210:	f426                	sd	s1,40(sp)
    80006212:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80006214:	ffffc097          	auipc	ra,0xffffc
    80006218:	a1c080e7          	jalr	-1508(ra) # 80001c30 <myproc>
    8000621c:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    8000621e:	fd840593          	addi	a1,s0,-40
    80006222:	4501                	li	a0,0
    80006224:	ffffd097          	auipc	ra,0xffffd
    80006228:	fae080e7          	jalr	-82(ra) # 800031d2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    8000622c:	fc840593          	addi	a1,s0,-56
    80006230:	fd040513          	addi	a0,s0,-48
    80006234:	fffff097          	auipc	ra,0xfffff
    80006238:	dc2080e7          	jalr	-574(ra) # 80004ff6 <pipealloc>
    return -1;
    8000623c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000623e:	0c054463          	bltz	a0,80006306 <sys_pipe+0xfc>
  fd0 = -1;
    80006242:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80006246:	fd043503          	ld	a0,-48(s0)
    8000624a:	fffff097          	auipc	ra,0xfffff
    8000624e:	514080e7          	jalr	1300(ra) # 8000575e <fdalloc>
    80006252:	fca42223          	sw	a0,-60(s0)
    80006256:	08054b63          	bltz	a0,800062ec <sys_pipe+0xe2>
    8000625a:	fc843503          	ld	a0,-56(s0)
    8000625e:	fffff097          	auipc	ra,0xfffff
    80006262:	500080e7          	jalr	1280(ra) # 8000575e <fdalloc>
    80006266:	fca42023          	sw	a0,-64(s0)
    8000626a:	06054863          	bltz	a0,800062da <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000626e:	4691                	li	a3,4
    80006270:	fc440613          	addi	a2,s0,-60
    80006274:	fd843583          	ld	a1,-40(s0)
    80006278:	68a8                	ld	a0,80(s1)
    8000627a:	ffffb097          	auipc	ra,0xffffb
    8000627e:	578080e7          	jalr	1400(ra) # 800017f2 <copyout>
    80006282:	02054063          	bltz	a0,800062a2 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80006286:	4691                	li	a3,4
    80006288:	fc040613          	addi	a2,s0,-64
    8000628c:	fd843583          	ld	a1,-40(s0)
    80006290:	0591                	addi	a1,a1,4
    80006292:	68a8                	ld	a0,80(s1)
    80006294:	ffffb097          	auipc	ra,0xffffb
    80006298:	55e080e7          	jalr	1374(ra) # 800017f2 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    8000629c:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000629e:	06055463          	bgez	a0,80006306 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    800062a2:	fc442783          	lw	a5,-60(s0)
    800062a6:	07e9                	addi	a5,a5,26
    800062a8:	078e                	slli	a5,a5,0x3
    800062aa:	97a6                	add	a5,a5,s1
    800062ac:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800062b0:	fc042783          	lw	a5,-64(s0)
    800062b4:	07e9                	addi	a5,a5,26
    800062b6:	078e                	slli	a5,a5,0x3
    800062b8:	94be                	add	s1,s1,a5
    800062ba:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800062be:	fd043503          	ld	a0,-48(s0)
    800062c2:	fffff097          	auipc	ra,0xfffff
    800062c6:	a04080e7          	jalr	-1532(ra) # 80004cc6 <fileclose>
    fileclose(wf);
    800062ca:	fc843503          	ld	a0,-56(s0)
    800062ce:	fffff097          	auipc	ra,0xfffff
    800062d2:	9f8080e7          	jalr	-1544(ra) # 80004cc6 <fileclose>
    return -1;
    800062d6:	57fd                	li	a5,-1
    800062d8:	a03d                	j	80006306 <sys_pipe+0xfc>
    if(fd0 >= 0)
    800062da:	fc442783          	lw	a5,-60(s0)
    800062de:	0007c763          	bltz	a5,800062ec <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    800062e2:	07e9                	addi	a5,a5,26
    800062e4:	078e                	slli	a5,a5,0x3
    800062e6:	97a6                	add	a5,a5,s1
    800062e8:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    800062ec:	fd043503          	ld	a0,-48(s0)
    800062f0:	fffff097          	auipc	ra,0xfffff
    800062f4:	9d6080e7          	jalr	-1578(ra) # 80004cc6 <fileclose>
    fileclose(wf);
    800062f8:	fc843503          	ld	a0,-56(s0)
    800062fc:	fffff097          	auipc	ra,0xfffff
    80006300:	9ca080e7          	jalr	-1590(ra) # 80004cc6 <fileclose>
    return -1;
    80006304:	57fd                	li	a5,-1
}
    80006306:	853e                	mv	a0,a5
    80006308:	70e2                	ld	ra,56(sp)
    8000630a:	7442                	ld	s0,48(sp)
    8000630c:	74a2                	ld	s1,40(sp)
    8000630e:	6121                	addi	sp,sp,64
    80006310:	8082                	ret
	...

0000000080006320 <kernelvec>:
    80006320:	7111                	addi	sp,sp,-256
    80006322:	e006                	sd	ra,0(sp)
    80006324:	e40a                	sd	sp,8(sp)
    80006326:	e80e                	sd	gp,16(sp)
    80006328:	ec12                	sd	tp,24(sp)
    8000632a:	f016                	sd	t0,32(sp)
    8000632c:	f41a                	sd	t1,40(sp)
    8000632e:	f81e                	sd	t2,48(sp)
    80006330:	fc22                	sd	s0,56(sp)
    80006332:	e0a6                	sd	s1,64(sp)
    80006334:	e4aa                	sd	a0,72(sp)
    80006336:	e8ae                	sd	a1,80(sp)
    80006338:	ecb2                	sd	a2,88(sp)
    8000633a:	f0b6                	sd	a3,96(sp)
    8000633c:	f4ba                	sd	a4,104(sp)
    8000633e:	f8be                	sd	a5,112(sp)
    80006340:	fcc2                	sd	a6,120(sp)
    80006342:	e146                	sd	a7,128(sp)
    80006344:	e54a                	sd	s2,136(sp)
    80006346:	e94e                	sd	s3,144(sp)
    80006348:	ed52                	sd	s4,152(sp)
    8000634a:	f156                	sd	s5,160(sp)
    8000634c:	f55a                	sd	s6,168(sp)
    8000634e:	f95e                	sd	s7,176(sp)
    80006350:	fd62                	sd	s8,184(sp)
    80006352:	e1e6                	sd	s9,192(sp)
    80006354:	e5ea                	sd	s10,200(sp)
    80006356:	e9ee                	sd	s11,208(sp)
    80006358:	edf2                	sd	t3,216(sp)
    8000635a:	f1f6                	sd	t4,224(sp)
    8000635c:	f5fa                	sd	t5,232(sp)
    8000635e:	f9fe                	sd	t6,240(sp)
    80006360:	c81fc0ef          	jal	ra,80002fe0 <kerneltrap>
    80006364:	6082                	ld	ra,0(sp)
    80006366:	6122                	ld	sp,8(sp)
    80006368:	61c2                	ld	gp,16(sp)
    8000636a:	7282                	ld	t0,32(sp)
    8000636c:	7322                	ld	t1,40(sp)
    8000636e:	73c2                	ld	t2,48(sp)
    80006370:	7462                	ld	s0,56(sp)
    80006372:	6486                	ld	s1,64(sp)
    80006374:	6526                	ld	a0,72(sp)
    80006376:	65c6                	ld	a1,80(sp)
    80006378:	6666                	ld	a2,88(sp)
    8000637a:	7686                	ld	a3,96(sp)
    8000637c:	7726                	ld	a4,104(sp)
    8000637e:	77c6                	ld	a5,112(sp)
    80006380:	7866                	ld	a6,120(sp)
    80006382:	688a                	ld	a7,128(sp)
    80006384:	692a                	ld	s2,136(sp)
    80006386:	69ca                	ld	s3,144(sp)
    80006388:	6a6a                	ld	s4,152(sp)
    8000638a:	7a8a                	ld	s5,160(sp)
    8000638c:	7b2a                	ld	s6,168(sp)
    8000638e:	7bca                	ld	s7,176(sp)
    80006390:	7c6a                	ld	s8,184(sp)
    80006392:	6c8e                	ld	s9,192(sp)
    80006394:	6d2e                	ld	s10,200(sp)
    80006396:	6dce                	ld	s11,208(sp)
    80006398:	6e6e                	ld	t3,216(sp)
    8000639a:	7e8e                	ld	t4,224(sp)
    8000639c:	7f2e                	ld	t5,232(sp)
    8000639e:	7fce                	ld	t6,240(sp)
    800063a0:	6111                	addi	sp,sp,256
    800063a2:	10200073          	sret
    800063a6:	00000013          	nop
    800063aa:	00000013          	nop
    800063ae:	0001                	nop

00000000800063b0 <timervec>:
    800063b0:	34051573          	csrrw	a0,mscratch,a0
    800063b4:	e10c                	sd	a1,0(a0)
    800063b6:	e510                	sd	a2,8(a0)
    800063b8:	e914                	sd	a3,16(a0)
    800063ba:	6d0c                	ld	a1,24(a0)
    800063bc:	7110                	ld	a2,32(a0)
    800063be:	6194                	ld	a3,0(a1)
    800063c0:	96b2                	add	a3,a3,a2
    800063c2:	e194                	sd	a3,0(a1)
    800063c4:	4589                	li	a1,2
    800063c6:	14459073          	csrw	sip,a1
    800063ca:	6914                	ld	a3,16(a0)
    800063cc:	6510                	ld	a2,8(a0)
    800063ce:	610c                	ld	a1,0(a0)
    800063d0:	34051573          	csrrw	a0,mscratch,a0
    800063d4:	30200073          	mret
	...

00000000800063da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800063da:	1141                	addi	sp,sp,-16
    800063dc:	e422                	sd	s0,8(sp)
    800063de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800063e0:	0c0007b7          	lui	a5,0xc000
    800063e4:	4705                	li	a4,1
    800063e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800063e8:	c3d8                	sw	a4,4(a5)
}
    800063ea:	6422                	ld	s0,8(sp)
    800063ec:	0141                	addi	sp,sp,16
    800063ee:	8082                	ret

00000000800063f0 <plicinithart>:

void
plicinithart(void)
{
    800063f0:	1141                	addi	sp,sp,-16
    800063f2:	e406                	sd	ra,8(sp)
    800063f4:	e022                	sd	s0,0(sp)
    800063f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800063f8:	ffffc097          	auipc	ra,0xffffc
    800063fc:	80c080e7          	jalr	-2036(ra) # 80001c04 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006400:	0085171b          	slliw	a4,a0,0x8
    80006404:	0c0027b7          	lui	a5,0xc002
    80006408:	97ba                	add	a5,a5,a4
    8000640a:	40200713          	li	a4,1026
    8000640e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006412:	00d5151b          	slliw	a0,a0,0xd
    80006416:	0c2017b7          	lui	a5,0xc201
    8000641a:	97aa                	add	a5,a5,a0
    8000641c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006420:	60a2                	ld	ra,8(sp)
    80006422:	6402                	ld	s0,0(sp)
    80006424:	0141                	addi	sp,sp,16
    80006426:	8082                	ret

0000000080006428 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006428:	1141                	addi	sp,sp,-16
    8000642a:	e406                	sd	ra,8(sp)
    8000642c:	e022                	sd	s0,0(sp)
    8000642e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006430:	ffffb097          	auipc	ra,0xffffb
    80006434:	7d4080e7          	jalr	2004(ra) # 80001c04 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006438:	00d5151b          	slliw	a0,a0,0xd
    8000643c:	0c2017b7          	lui	a5,0xc201
    80006440:	97aa                	add	a5,a5,a0
  return irq;
}
    80006442:	43c8                	lw	a0,4(a5)
    80006444:	60a2                	ld	ra,8(sp)
    80006446:	6402                	ld	s0,0(sp)
    80006448:	0141                	addi	sp,sp,16
    8000644a:	8082                	ret

000000008000644c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000644c:	1101                	addi	sp,sp,-32
    8000644e:	ec06                	sd	ra,24(sp)
    80006450:	e822                	sd	s0,16(sp)
    80006452:	e426                	sd	s1,8(sp)
    80006454:	1000                	addi	s0,sp,32
    80006456:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006458:	ffffb097          	auipc	ra,0xffffb
    8000645c:	7ac080e7          	jalr	1964(ra) # 80001c04 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006460:	00d5151b          	slliw	a0,a0,0xd
    80006464:	0c2017b7          	lui	a5,0xc201
    80006468:	97aa                	add	a5,a5,a0
    8000646a:	c3c4                	sw	s1,4(a5)
}
    8000646c:	60e2                	ld	ra,24(sp)
    8000646e:	6442                	ld	s0,16(sp)
    80006470:	64a2                	ld	s1,8(sp)
    80006472:	6105                	addi	sp,sp,32
    80006474:	8082                	ret

0000000080006476 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006476:	1141                	addi	sp,sp,-16
    80006478:	e406                	sd	ra,8(sp)
    8000647a:	e022                	sd	s0,0(sp)
    8000647c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000647e:	479d                	li	a5,7
    80006480:	04a7cc63          	blt	a5,a0,800064d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006484:	0001c797          	auipc	a5,0x1c
    80006488:	99c78793          	addi	a5,a5,-1636 # 80021e20 <disk>
    8000648c:	97aa                	add	a5,a5,a0
    8000648e:	0187c783          	lbu	a5,24(a5)
    80006492:	ebb9                	bnez	a5,800064e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006494:	00451693          	slli	a3,a0,0x4
    80006498:	0001c797          	auipc	a5,0x1c
    8000649c:	98878793          	addi	a5,a5,-1656 # 80021e20 <disk>
    800064a0:	6398                	ld	a4,0(a5)
    800064a2:	9736                	add	a4,a4,a3
    800064a4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800064a8:	6398                	ld	a4,0(a5)
    800064aa:	9736                	add	a4,a4,a3
    800064ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800064b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800064b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800064b8:	97aa                	add	a5,a5,a0
    800064ba:	4705                	li	a4,1
    800064bc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800064c0:	0001c517          	auipc	a0,0x1c
    800064c4:	97850513          	addi	a0,a0,-1672 # 80021e38 <disk+0x18>
    800064c8:	ffffc097          	auipc	ra,0xffffc
    800064cc:	0ba080e7          	jalr	186(ra) # 80002582 <wakeup>
}
    800064d0:	60a2                	ld	ra,8(sp)
    800064d2:	6402                	ld	s0,0(sp)
    800064d4:	0141                	addi	sp,sp,16
    800064d6:	8082                	ret
    panic("free_desc 1");
    800064d8:	00002517          	auipc	a0,0x2
    800064dc:	42050513          	addi	a0,a0,1056 # 800088f8 <syscalls+0x318>
    800064e0:	ffffa097          	auipc	ra,0xffffa
    800064e4:	060080e7          	jalr	96(ra) # 80000540 <panic>
    panic("free_desc 2");
    800064e8:	00002517          	auipc	a0,0x2
    800064ec:	42050513          	addi	a0,a0,1056 # 80008908 <syscalls+0x328>
    800064f0:	ffffa097          	auipc	ra,0xffffa
    800064f4:	050080e7          	jalr	80(ra) # 80000540 <panic>

00000000800064f8 <virtio_disk_init>:
{
    800064f8:	1101                	addi	sp,sp,-32
    800064fa:	ec06                	sd	ra,24(sp)
    800064fc:	e822                	sd	s0,16(sp)
    800064fe:	e426                	sd	s1,8(sp)
    80006500:	e04a                	sd	s2,0(sp)
    80006502:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006504:	00002597          	auipc	a1,0x2
    80006508:	41458593          	addi	a1,a1,1044 # 80008918 <syscalls+0x338>
    8000650c:	0001c517          	auipc	a0,0x1c
    80006510:	a3c50513          	addi	a0,a0,-1476 # 80021f48 <disk+0x128>
    80006514:	ffffa097          	auipc	ra,0xffffa
    80006518:	6fa080e7          	jalr	1786(ra) # 80000c0e <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000651c:	100017b7          	lui	a5,0x10001
    80006520:	4398                	lw	a4,0(a5)
    80006522:	2701                	sext.w	a4,a4
    80006524:	747277b7          	lui	a5,0x74727
    80006528:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000652c:	14f71b63          	bne	a4,a5,80006682 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006530:	100017b7          	lui	a5,0x10001
    80006534:	43dc                	lw	a5,4(a5)
    80006536:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006538:	4709                	li	a4,2
    8000653a:	14e79463          	bne	a5,a4,80006682 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000653e:	100017b7          	lui	a5,0x10001
    80006542:	479c                	lw	a5,8(a5)
    80006544:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006546:	12e79e63          	bne	a5,a4,80006682 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000654a:	100017b7          	lui	a5,0x10001
    8000654e:	47d8                	lw	a4,12(a5)
    80006550:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006552:	554d47b7          	lui	a5,0x554d4
    80006556:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000655a:	12f71463          	bne	a4,a5,80006682 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000655e:	100017b7          	lui	a5,0x10001
    80006562:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006566:	4705                	li	a4,1
    80006568:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000656a:	470d                	li	a4,3
    8000656c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000656e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006570:	c7ffe6b7          	lui	a3,0xc7ffe
    80006574:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc7ff>
    80006578:	8f75                	and	a4,a4,a3
    8000657a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000657c:	472d                	li	a4,11
    8000657e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006580:	5bbc                	lw	a5,112(a5)
    80006582:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006586:	8ba1                	andi	a5,a5,8
    80006588:	10078563          	beqz	a5,80006692 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000658c:	100017b7          	lui	a5,0x10001
    80006590:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006594:	43fc                	lw	a5,68(a5)
    80006596:	2781                	sext.w	a5,a5
    80006598:	10079563          	bnez	a5,800066a2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000659c:	100017b7          	lui	a5,0x10001
    800065a0:	5bdc                	lw	a5,52(a5)
    800065a2:	2781                	sext.w	a5,a5
  if(max == 0)
    800065a4:	10078763          	beqz	a5,800066b2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800065a8:	471d                	li	a4,7
    800065aa:	10f77c63          	bgeu	a4,a5,800066c2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800065ae:	ffffa097          	auipc	ra,0xffffa
    800065b2:	5b4080e7          	jalr	1460(ra) # 80000b62 <kalloc>
    800065b6:	0001c497          	auipc	s1,0x1c
    800065ba:	86a48493          	addi	s1,s1,-1942 # 80021e20 <disk>
    800065be:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800065c0:	ffffa097          	auipc	ra,0xffffa
    800065c4:	5a2080e7          	jalr	1442(ra) # 80000b62 <kalloc>
    800065c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800065ca:	ffffa097          	auipc	ra,0xffffa
    800065ce:	598080e7          	jalr	1432(ra) # 80000b62 <kalloc>
    800065d2:	87aa                	mv	a5,a0
    800065d4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800065d6:	6088                	ld	a0,0(s1)
    800065d8:	cd6d                	beqz	a0,800066d2 <virtio_disk_init+0x1da>
    800065da:	0001c717          	auipc	a4,0x1c
    800065de:	84e73703          	ld	a4,-1970(a4) # 80021e28 <disk+0x8>
    800065e2:	cb65                	beqz	a4,800066d2 <virtio_disk_init+0x1da>
    800065e4:	c7fd                	beqz	a5,800066d2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800065e6:	6605                	lui	a2,0x1
    800065e8:	4581                	li	a1,0
    800065ea:	ffffa097          	auipc	ra,0xffffa
    800065ee:	7b0080e7          	jalr	1968(ra) # 80000d9a <memset>
  memset(disk.avail, 0, PGSIZE);
    800065f2:	0001c497          	auipc	s1,0x1c
    800065f6:	82e48493          	addi	s1,s1,-2002 # 80021e20 <disk>
    800065fa:	6605                	lui	a2,0x1
    800065fc:	4581                	li	a1,0
    800065fe:	6488                	ld	a0,8(s1)
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	79a080e7          	jalr	1946(ra) # 80000d9a <memset>
  memset(disk.used, 0, PGSIZE);
    80006608:	6605                	lui	a2,0x1
    8000660a:	4581                	li	a1,0
    8000660c:	6888                	ld	a0,16(s1)
    8000660e:	ffffa097          	auipc	ra,0xffffa
    80006612:	78c080e7          	jalr	1932(ra) # 80000d9a <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006616:	100017b7          	lui	a5,0x10001
    8000661a:	4721                	li	a4,8
    8000661c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000661e:	4098                	lw	a4,0(s1)
    80006620:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006624:	40d8                	lw	a4,4(s1)
    80006626:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000662a:	6498                	ld	a4,8(s1)
    8000662c:	0007069b          	sext.w	a3,a4
    80006630:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006634:	9701                	srai	a4,a4,0x20
    80006636:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000663a:	6898                	ld	a4,16(s1)
    8000663c:	0007069b          	sext.w	a3,a4
    80006640:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006644:	9701                	srai	a4,a4,0x20
    80006646:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000664a:	4705                	li	a4,1
    8000664c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000664e:	00e48c23          	sb	a4,24(s1)
    80006652:	00e48ca3          	sb	a4,25(s1)
    80006656:	00e48d23          	sb	a4,26(s1)
    8000665a:	00e48da3          	sb	a4,27(s1)
    8000665e:	00e48e23          	sb	a4,28(s1)
    80006662:	00e48ea3          	sb	a4,29(s1)
    80006666:	00e48f23          	sb	a4,30(s1)
    8000666a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000666e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006672:	0727a823          	sw	s2,112(a5)
}
    80006676:	60e2                	ld	ra,24(sp)
    80006678:	6442                	ld	s0,16(sp)
    8000667a:	64a2                	ld	s1,8(sp)
    8000667c:	6902                	ld	s2,0(sp)
    8000667e:	6105                	addi	sp,sp,32
    80006680:	8082                	ret
    panic("could not find virtio disk");
    80006682:	00002517          	auipc	a0,0x2
    80006686:	2a650513          	addi	a0,a0,678 # 80008928 <syscalls+0x348>
    8000668a:	ffffa097          	auipc	ra,0xffffa
    8000668e:	eb6080e7          	jalr	-330(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006692:	00002517          	auipc	a0,0x2
    80006696:	2b650513          	addi	a0,a0,694 # 80008948 <syscalls+0x368>
    8000669a:	ffffa097          	auipc	ra,0xffffa
    8000669e:	ea6080e7          	jalr	-346(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    800066a2:	00002517          	auipc	a0,0x2
    800066a6:	2c650513          	addi	a0,a0,710 # 80008968 <syscalls+0x388>
    800066aa:	ffffa097          	auipc	ra,0xffffa
    800066ae:	e96080e7          	jalr	-362(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    800066b2:	00002517          	auipc	a0,0x2
    800066b6:	2d650513          	addi	a0,a0,726 # 80008988 <syscalls+0x3a8>
    800066ba:	ffffa097          	auipc	ra,0xffffa
    800066be:	e86080e7          	jalr	-378(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800066c2:	00002517          	auipc	a0,0x2
    800066c6:	2e650513          	addi	a0,a0,742 # 800089a8 <syscalls+0x3c8>
    800066ca:	ffffa097          	auipc	ra,0xffffa
    800066ce:	e76080e7          	jalr	-394(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800066d2:	00002517          	auipc	a0,0x2
    800066d6:	2f650513          	addi	a0,a0,758 # 800089c8 <syscalls+0x3e8>
    800066da:	ffffa097          	auipc	ra,0xffffa
    800066de:	e66080e7          	jalr	-410(ra) # 80000540 <panic>

00000000800066e2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800066e2:	7119                	addi	sp,sp,-128
    800066e4:	fc86                	sd	ra,120(sp)
    800066e6:	f8a2                	sd	s0,112(sp)
    800066e8:	f4a6                	sd	s1,104(sp)
    800066ea:	f0ca                	sd	s2,96(sp)
    800066ec:	ecce                	sd	s3,88(sp)
    800066ee:	e8d2                	sd	s4,80(sp)
    800066f0:	e4d6                	sd	s5,72(sp)
    800066f2:	e0da                	sd	s6,64(sp)
    800066f4:	fc5e                	sd	s7,56(sp)
    800066f6:	f862                	sd	s8,48(sp)
    800066f8:	f466                	sd	s9,40(sp)
    800066fa:	f06a                	sd	s10,32(sp)
    800066fc:	ec6e                	sd	s11,24(sp)
    800066fe:	0100                	addi	s0,sp,128
    80006700:	8aaa                	mv	s5,a0
    80006702:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006704:	00c52d03          	lw	s10,12(a0)
    80006708:	001d1d1b          	slliw	s10,s10,0x1
    8000670c:	1d02                	slli	s10,s10,0x20
    8000670e:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    80006712:	0001c517          	auipc	a0,0x1c
    80006716:	83650513          	addi	a0,a0,-1994 # 80021f48 <disk+0x128>
    8000671a:	ffffa097          	auipc	ra,0xffffa
    8000671e:	584080e7          	jalr	1412(ra) # 80000c9e <acquire>
  for(int i = 0; i < 3; i++){
    80006722:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006724:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006726:	0001bb97          	auipc	s7,0x1b
    8000672a:	6fab8b93          	addi	s7,s7,1786 # 80021e20 <disk>
  for(int i = 0; i < 3; i++){
    8000672e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006730:	0001cc97          	auipc	s9,0x1c
    80006734:	818c8c93          	addi	s9,s9,-2024 # 80021f48 <disk+0x128>
    80006738:	a08d                	j	8000679a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000673a:	00fb8733          	add	a4,s7,a5
    8000673e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006742:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006744:	0207c563          	bltz	a5,8000676e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006748:	2905                	addiw	s2,s2,1
    8000674a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000674c:	05690c63          	beq	s2,s6,800067a4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006750:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006752:	0001b717          	auipc	a4,0x1b
    80006756:	6ce70713          	addi	a4,a4,1742 # 80021e20 <disk>
    8000675a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000675c:	01874683          	lbu	a3,24(a4)
    80006760:	fee9                	bnez	a3,8000673a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006762:	2785                	addiw	a5,a5,1
    80006764:	0705                	addi	a4,a4,1
    80006766:	fe979be3          	bne	a5,s1,8000675c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000676a:	57fd                	li	a5,-1
    8000676c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000676e:	01205d63          	blez	s2,80006788 <virtio_disk_rw+0xa6>
    80006772:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006774:	000a2503          	lw	a0,0(s4)
    80006778:	00000097          	auipc	ra,0x0
    8000677c:	cfe080e7          	jalr	-770(ra) # 80006476 <free_desc>
      for(int j = 0; j < i; j++)
    80006780:	2d85                	addiw	s11,s11,1
    80006782:	0a11                	addi	s4,s4,4
    80006784:	ff2d98e3          	bne	s11,s2,80006774 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006788:	85e6                	mv	a1,s9
    8000678a:	0001b517          	auipc	a0,0x1b
    8000678e:	6ae50513          	addi	a0,a0,1710 # 80021e38 <disk+0x18>
    80006792:	ffffc097          	auipc	ra,0xffffc
    80006796:	d8c080e7          	jalr	-628(ra) # 8000251e <sleep>
  for(int i = 0; i < 3; i++){
    8000679a:	f8040a13          	addi	s4,s0,-128
{
    8000679e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    800067a0:	894e                	mv	s2,s3
    800067a2:	b77d                	j	80006750 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067a4:	f8042503          	lw	a0,-128(s0)
    800067a8:	00a50713          	addi	a4,a0,10
    800067ac:	0712                	slli	a4,a4,0x4

  if(write)
    800067ae:	0001b797          	auipc	a5,0x1b
    800067b2:	67278793          	addi	a5,a5,1650 # 80021e20 <disk>
    800067b6:	00e786b3          	add	a3,a5,a4
    800067ba:	01803633          	snez	a2,s8
    800067be:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800067c0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800067c4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800067c8:	f6070613          	addi	a2,a4,-160
    800067cc:	6394                	ld	a3,0(a5)
    800067ce:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800067d0:	00870593          	addi	a1,a4,8
    800067d4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800067d6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800067d8:	0007b803          	ld	a6,0(a5)
    800067dc:	9642                	add	a2,a2,a6
    800067de:	46c1                	li	a3,16
    800067e0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800067e2:	4585                	li	a1,1
    800067e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800067e8:	f8442683          	lw	a3,-124(s0)
    800067ec:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800067f0:	0692                	slli	a3,a3,0x4
    800067f2:	9836                	add	a6,a6,a3
    800067f4:	058a8613          	addi	a2,s5,88
    800067f8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800067fc:	0007b803          	ld	a6,0(a5)
    80006800:	96c2                	add	a3,a3,a6
    80006802:	40000613          	li	a2,1024
    80006806:	c690                	sw	a2,8(a3)
  if(write)
    80006808:	001c3613          	seqz	a2,s8
    8000680c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006810:	00166613          	ori	a2,a2,1
    80006814:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006818:	f8842603          	lw	a2,-120(s0)
    8000681c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006820:	00250693          	addi	a3,a0,2
    80006824:	0692                	slli	a3,a3,0x4
    80006826:	96be                	add	a3,a3,a5
    80006828:	58fd                	li	a7,-1
    8000682a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000682e:	0612                	slli	a2,a2,0x4
    80006830:	9832                	add	a6,a6,a2
    80006832:	f9070713          	addi	a4,a4,-112
    80006836:	973e                	add	a4,a4,a5
    80006838:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000683c:	6398                	ld	a4,0(a5)
    8000683e:	9732                	add	a4,a4,a2
    80006840:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006842:	4609                	li	a2,2
    80006844:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006848:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000684c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006850:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006854:	6794                	ld	a3,8(a5)
    80006856:	0026d703          	lhu	a4,2(a3)
    8000685a:	8b1d                	andi	a4,a4,7
    8000685c:	0706                	slli	a4,a4,0x1
    8000685e:	96ba                	add	a3,a3,a4
    80006860:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006864:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006868:	6798                	ld	a4,8(a5)
    8000686a:	00275783          	lhu	a5,2(a4)
    8000686e:	2785                	addiw	a5,a5,1
    80006870:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006874:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006878:	100017b7          	lui	a5,0x10001
    8000687c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006880:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006884:	0001b917          	auipc	s2,0x1b
    80006888:	6c490913          	addi	s2,s2,1732 # 80021f48 <disk+0x128>
  while(b->disk == 1) {
    8000688c:	4485                	li	s1,1
    8000688e:	00b79c63          	bne	a5,a1,800068a6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006892:	85ca                	mv	a1,s2
    80006894:	8556                	mv	a0,s5
    80006896:	ffffc097          	auipc	ra,0xffffc
    8000689a:	c88080e7          	jalr	-888(ra) # 8000251e <sleep>
  while(b->disk == 1) {
    8000689e:	004aa783          	lw	a5,4(s5)
    800068a2:	fe9788e3          	beq	a5,s1,80006892 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800068a6:	f8042903          	lw	s2,-128(s0)
    800068aa:	00290713          	addi	a4,s2,2
    800068ae:	0712                	slli	a4,a4,0x4
    800068b0:	0001b797          	auipc	a5,0x1b
    800068b4:	57078793          	addi	a5,a5,1392 # 80021e20 <disk>
    800068b8:	97ba                	add	a5,a5,a4
    800068ba:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800068be:	0001b997          	auipc	s3,0x1b
    800068c2:	56298993          	addi	s3,s3,1378 # 80021e20 <disk>
    800068c6:	00491713          	slli	a4,s2,0x4
    800068ca:	0009b783          	ld	a5,0(s3)
    800068ce:	97ba                	add	a5,a5,a4
    800068d0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800068d4:	854a                	mv	a0,s2
    800068d6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800068da:	00000097          	auipc	ra,0x0
    800068de:	b9c080e7          	jalr	-1124(ra) # 80006476 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800068e2:	8885                	andi	s1,s1,1
    800068e4:	f0ed                	bnez	s1,800068c6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800068e6:	0001b517          	auipc	a0,0x1b
    800068ea:	66250513          	addi	a0,a0,1634 # 80021f48 <disk+0x128>
    800068ee:	ffffa097          	auipc	ra,0xffffa
    800068f2:	464080e7          	jalr	1124(ra) # 80000d52 <release>
}
    800068f6:	70e6                	ld	ra,120(sp)
    800068f8:	7446                	ld	s0,112(sp)
    800068fa:	74a6                	ld	s1,104(sp)
    800068fc:	7906                	ld	s2,96(sp)
    800068fe:	69e6                	ld	s3,88(sp)
    80006900:	6a46                	ld	s4,80(sp)
    80006902:	6aa6                	ld	s5,72(sp)
    80006904:	6b06                	ld	s6,64(sp)
    80006906:	7be2                	ld	s7,56(sp)
    80006908:	7c42                	ld	s8,48(sp)
    8000690a:	7ca2                	ld	s9,40(sp)
    8000690c:	7d02                	ld	s10,32(sp)
    8000690e:	6de2                	ld	s11,24(sp)
    80006910:	6109                	addi	sp,sp,128
    80006912:	8082                	ret

0000000080006914 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006914:	1101                	addi	sp,sp,-32
    80006916:	ec06                	sd	ra,24(sp)
    80006918:	e822                	sd	s0,16(sp)
    8000691a:	e426                	sd	s1,8(sp)
    8000691c:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000691e:	0001b497          	auipc	s1,0x1b
    80006922:	50248493          	addi	s1,s1,1282 # 80021e20 <disk>
    80006926:	0001b517          	auipc	a0,0x1b
    8000692a:	62250513          	addi	a0,a0,1570 # 80021f48 <disk+0x128>
    8000692e:	ffffa097          	auipc	ra,0xffffa
    80006932:	370080e7          	jalr	880(ra) # 80000c9e <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006936:	10001737          	lui	a4,0x10001
    8000693a:	533c                	lw	a5,96(a4)
    8000693c:	8b8d                	andi	a5,a5,3
    8000693e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006940:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006944:	689c                	ld	a5,16(s1)
    80006946:	0204d703          	lhu	a4,32(s1)
    8000694a:	0027d783          	lhu	a5,2(a5)
    8000694e:	04f70863          	beq	a4,a5,8000699e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006952:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006956:	6898                	ld	a4,16(s1)
    80006958:	0204d783          	lhu	a5,32(s1)
    8000695c:	8b9d                	andi	a5,a5,7
    8000695e:	078e                	slli	a5,a5,0x3
    80006960:	97ba                	add	a5,a5,a4
    80006962:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006964:	00278713          	addi	a4,a5,2
    80006968:	0712                	slli	a4,a4,0x4
    8000696a:	9726                	add	a4,a4,s1
    8000696c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006970:	e721                	bnez	a4,800069b8 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006972:	0789                	addi	a5,a5,2
    80006974:	0792                	slli	a5,a5,0x4
    80006976:	97a6                	add	a5,a5,s1
    80006978:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000697a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000697e:	ffffc097          	auipc	ra,0xffffc
    80006982:	c04080e7          	jalr	-1020(ra) # 80002582 <wakeup>

    disk.used_idx += 1;
    80006986:	0204d783          	lhu	a5,32(s1)
    8000698a:	2785                	addiw	a5,a5,1
    8000698c:	17c2                	slli	a5,a5,0x30
    8000698e:	93c1                	srli	a5,a5,0x30
    80006990:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006994:	6898                	ld	a4,16(s1)
    80006996:	00275703          	lhu	a4,2(a4)
    8000699a:	faf71ce3          	bne	a4,a5,80006952 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000699e:	0001b517          	auipc	a0,0x1b
    800069a2:	5aa50513          	addi	a0,a0,1450 # 80021f48 <disk+0x128>
    800069a6:	ffffa097          	auipc	ra,0xffffa
    800069aa:	3ac080e7          	jalr	940(ra) # 80000d52 <release>
}
    800069ae:	60e2                	ld	ra,24(sp)
    800069b0:	6442                	ld	s0,16(sp)
    800069b2:	64a2                	ld	s1,8(sp)
    800069b4:	6105                	addi	sp,sp,32
    800069b6:	8082                	ret
      panic("virtio_disk_intr status");
    800069b8:	00002517          	auipc	a0,0x2
    800069bc:	02850513          	addi	a0,a0,40 # 800089e0 <syscalls+0x400>
    800069c0:	ffffa097          	auipc	ra,0xffffa
    800069c4:	b80080e7          	jalr	-1152(ra) # 80000540 <panic>
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
