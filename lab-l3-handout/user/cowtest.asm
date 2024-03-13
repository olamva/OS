
user/_cowtest:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <testcase5>:

int global_array[16777216] = {0};
int global_var = 0;

void testcase5()
{
   0:	7179                	addi	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	1800                	addi	s0,sp,48
    int pid[3];

    printf("\n----- Test case 5 -----\n");
   c:	00001517          	auipc	a0,0x1
  10:	e2450513          	addi	a0,a0,-476 # e30 <malloc+0xe8>
  14:	00001097          	auipc	ra,0x1
  18:	c7c080e7          	jalr	-900(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
  1c:	00001517          	auipc	a0,0x1
  20:	e3450513          	addi	a0,a0,-460 # e50 <malloc+0x108>
  24:	00001097          	auipc	ra,0x1
  28:	c6c080e7          	jalr	-916(ra) # c90 <printf>
    print_free_frame_cnt();
  2c:	00001097          	auipc	ra,0x1
  30:	982080e7          	jalr	-1662(ra) # 9ae <pfreepages>

    for (int i = 0; i < 3; ++i)
  34:	fd040493          	addi	s1,s0,-48
  38:	fdc40913          	addi	s2,s0,-36
    {
        if ((pid[i] = fork()) == 0)
  3c:	00001097          	auipc	ra,0x1
  40:	8a2080e7          	jalr	-1886(ra) # 8de <fork>
  44:	c088                	sw	a0,0(s1)
  46:	c531                	beqz	a0,92 <testcase5+0x92>
            // PARENT
            break;
        }
    }

    sleep(100);
  48:	06400513          	li	a0,100
  4c:	00001097          	auipc	ra,0x1
  50:	932080e7          	jalr	-1742(ra) # 97e <sleep>
  54:	448d                	li	s1,3

    for (int i = 0; i < 3; ++i)
    {
        int _pid = wait(0);
  56:	4501                	li	a0,0
  58:	00001097          	auipc	ra,0x1
  5c:	89e080e7          	jalr	-1890(ra) # 8f6 <wait>
        for (int j = 0; j < 3; ++j)
        {
            if (pid[j] == _pid)
  60:	fd042783          	lw	a5,-48(s0)
  64:	02a78b63          	beq	a5,a0,9a <testcase5+0x9a>
  68:	fd442783          	lw	a5,-44(s0)
  6c:	02a78763          	beq	a5,a0,9a <testcase5+0x9a>
  70:	fd842783          	lw	a5,-40(s0)
  74:	02a78363          	beq	a5,a0,9a <testcase5+0x9a>
            {
                break;
            }
            if (j == 2)
            {
                printf("wait() error!");
  78:	00001517          	auipc	a0,0x1
  7c:	de850513          	addi	a0,a0,-536 # e60 <malloc+0x118>
  80:	00001097          	auipc	ra,0x1
  84:	c10080e7          	jalr	-1008(ra) # c90 <printf>
                exit(1);
  88:	4505                	li	a0,1
  8a:	00001097          	auipc	ra,0x1
  8e:	864080e7          	jalr	-1948(ra) # 8ee <exit>
    for (int i = 0; i < 3; ++i)
  92:	0491                	addi	s1,s1,4
  94:	fb2494e3          	bne	s1,s2,3c <testcase5+0x3c>
  98:	bf45                	j	48 <testcase5+0x48>
    for (int i = 0; i < 3; ++i)
  9a:	34fd                	addiw	s1,s1,-1
  9c:	fccd                	bnez	s1,56 <testcase5+0x56>
            }
        }
    }

    printf("[prnt] v7 --> ");
  9e:	00001517          	auipc	a0,0x1
  a2:	dd250513          	addi	a0,a0,-558 # e70 <malloc+0x128>
  a6:	00001097          	auipc	ra,0x1
  aa:	bea080e7          	jalr	-1046(ra) # c90 <printf>
    print_free_frame_cnt();
  ae:	00001097          	auipc	ra,0x1
  b2:	900080e7          	jalr	-1792(ra) # 9ae <pfreepages>
}
  b6:	70a2                	ld	ra,40(sp)
  b8:	7402                	ld	s0,32(sp)
  ba:	64e2                	ld	s1,24(sp)
  bc:	6942                	ld	s2,16(sp)
  be:	6145                	addi	sp,sp,48
  c0:	8082                	ret

00000000000000c2 <testcase4>:

void testcase4()
{
  c2:	1101                	addi	sp,sp,-32
  c4:	ec06                	sd	ra,24(sp)
  c6:	e822                	sd	s0,16(sp)
  c8:	e426                	sd	s1,8(sp)
  ca:	e04a                	sd	s2,0(sp)
  cc:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 4 -----\n");
  ce:	00001517          	auipc	a0,0x1
  d2:	db250513          	addi	a0,a0,-590 # e80 <malloc+0x138>
  d6:	00001097          	auipc	ra,0x1
  da:	bba080e7          	jalr	-1094(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
  de:	00001517          	auipc	a0,0x1
  e2:	d7250513          	addi	a0,a0,-654 # e50 <malloc+0x108>
  e6:	00001097          	auipc	ra,0x1
  ea:	baa080e7          	jalr	-1110(ra) # c90 <printf>
    print_free_frame_cnt();
  ee:	00001097          	auipc	ra,0x1
  f2:	8c0080e7          	jalr	-1856(ra) # 9ae <pfreepages>

    if ((pid = fork()) == 0)
  f6:	00000097          	auipc	ra,0x0
  fa:	7e8080e7          	jalr	2024(ra) # 8de <fork>
  fe:	c161                	beqz	a0,1be <testcase4+0xfc>
 100:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 102:	00001517          	auipc	a0,0x1
 106:	eae50513          	addi	a0,a0,-338 # fb0 <malloc+0x268>
 10a:	00001097          	auipc	ra,0x1
 10e:	b86080e7          	jalr	-1146(ra) # c90 <printf>
        print_free_frame_cnt();
 112:	00001097          	auipc	ra,0x1
 116:	89c080e7          	jalr	-1892(ra) # 9ae <pfreepages>

        global_array[0] = 111;
 11a:	00002917          	auipc	s2,0x2
 11e:	ef690913          	addi	s2,s2,-266 # 2010 <global_array>
 122:	06f00793          	li	a5,111
 126:	00f92023          	sw	a5,0(s2)
        printf("[prnt] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 12a:	06f00593          	li	a1,111
 12e:	00001517          	auipc	a0,0x1
 132:	e9250513          	addi	a0,a0,-366 # fc0 <malloc+0x278>
 136:	00001097          	auipc	ra,0x1
 13a:	b5a080e7          	jalr	-1190(ra) # c90 <printf>

        printf("[prnt] v3 --> ");
 13e:	00001517          	auipc	a0,0x1
 142:	eca50513          	addi	a0,a0,-310 # 1008 <malloc+0x2c0>
 146:	00001097          	auipc	ra,0x1
 14a:	b4a080e7          	jalr	-1206(ra) # c90 <printf>
        print_free_frame_cnt();
 14e:	00001097          	auipc	ra,0x1
 152:	860080e7          	jalr	-1952(ra) # 9ae <pfreepages>
        printf("[prnt] pa3 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 156:	4581                	li	a1,0
 158:	854a                	mv	a0,s2
 15a:	00001097          	auipc	ra,0x1
 15e:	84c080e7          	jalr	-1972(ra) # 9a6 <va2pa>
 162:	85aa                	mv	a1,a0
 164:	00001517          	auipc	a0,0x1
 168:	eb450513          	addi	a0,a0,-332 # 1018 <malloc+0x2d0>
 16c:	00001097          	auipc	ra,0x1
 170:	b24080e7          	jalr	-1244(ra) # c90 <printf>
    }

    if (wait(0) != pid)
 174:	4501                	li	a0,0
 176:	00000097          	auipc	ra,0x0
 17a:	780080e7          	jalr	1920(ra) # 8f6 <wait>
 17e:	12951763          	bne	a0,s1,2ac <testcase4+0x1ea>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] global_array[0] --> %d\n", global_array[0]);
 182:	00002597          	auipc	a1,0x2
 186:	e8e5a583          	lw	a1,-370(a1) # 2010 <global_array>
 18a:	00001517          	auipc	a0,0x1
 18e:	ea650513          	addi	a0,a0,-346 # 1030 <malloc+0x2e8>
 192:	00001097          	auipc	ra,0x1
 196:	afe080e7          	jalr	-1282(ra) # c90 <printf>

    printf("[prnt] v7 --> ");
 19a:	00001517          	auipc	a0,0x1
 19e:	cd650513          	addi	a0,a0,-810 # e70 <malloc+0x128>
 1a2:	00001097          	auipc	ra,0x1
 1a6:	aee080e7          	jalr	-1298(ra) # c90 <printf>
    print_free_frame_cnt();
 1aa:	00001097          	auipc	ra,0x1
 1ae:	804080e7          	jalr	-2044(ra) # 9ae <pfreepages>
}
 1b2:	60e2                	ld	ra,24(sp)
 1b4:	6442                	ld	s0,16(sp)
 1b6:	64a2                	ld	s1,8(sp)
 1b8:	6902                	ld	s2,0(sp)
 1ba:	6105                	addi	sp,sp,32
 1bc:	8082                	ret
        sleep(50);
 1be:	03200513          	li	a0,50
 1c2:	00000097          	auipc	ra,0x0
 1c6:	7bc080e7          	jalr	1980(ra) # 97e <sleep>
        printf("[chld] pa1 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 1ca:	00002497          	auipc	s1,0x2
 1ce:	e4648493          	addi	s1,s1,-442 # 2010 <global_array>
 1d2:	4581                	li	a1,0
 1d4:	8526                	mv	a0,s1
 1d6:	00000097          	auipc	ra,0x0
 1da:	7d0080e7          	jalr	2000(ra) # 9a6 <va2pa>
 1de:	85aa                	mv	a1,a0
 1e0:	00001517          	auipc	a0,0x1
 1e4:	cc050513          	addi	a0,a0,-832 # ea0 <malloc+0x158>
 1e8:	00001097          	auipc	ra,0x1
 1ec:	aa8080e7          	jalr	-1368(ra) # c90 <printf>
        printf("[chld] v4 --> ");
 1f0:	00001517          	auipc	a0,0x1
 1f4:	cc850513          	addi	a0,a0,-824 # eb8 <malloc+0x170>
 1f8:	00001097          	auipc	ra,0x1
 1fc:	a98080e7          	jalr	-1384(ra) # c90 <printf>
        print_free_frame_cnt();
 200:	00000097          	auipc	ra,0x0
 204:	7ae080e7          	jalr	1966(ra) # 9ae <pfreepages>
        global_array[0] = 222;
 208:	0de00793          	li	a5,222
 20c:	c09c                	sw	a5,0(s1)
        printf("[chld] modified one element in the 1st page, global_array[0]=%d\n", global_array[0]);
 20e:	0de00593          	li	a1,222
 212:	00001517          	auipc	a0,0x1
 216:	cb650513          	addi	a0,a0,-842 # ec8 <malloc+0x180>
 21a:	00001097          	auipc	ra,0x1
 21e:	a76080e7          	jalr	-1418(ra) # c90 <printf>
        printf("[chld] pa2 --> 0x%x\n", va2pa((uint64)&global_array[0], 0));
 222:	4581                	li	a1,0
 224:	8526                	mv	a0,s1
 226:	00000097          	auipc	ra,0x0
 22a:	780080e7          	jalr	1920(ra) # 9a6 <va2pa>
 22e:	85aa                	mv	a1,a0
 230:	00001517          	auipc	a0,0x1
 234:	ce050513          	addi	a0,a0,-800 # f10 <malloc+0x1c8>
 238:	00001097          	auipc	ra,0x1
 23c:	a58080e7          	jalr	-1448(ra) # c90 <printf>
        printf("[chld] v5 --> ");
 240:	00001517          	auipc	a0,0x1
 244:	ce850513          	addi	a0,a0,-792 # f28 <malloc+0x1e0>
 248:	00001097          	auipc	ra,0x1
 24c:	a48080e7          	jalr	-1464(ra) # c90 <printf>
        print_free_frame_cnt();
 250:	00000097          	auipc	ra,0x0
 254:	75e080e7          	jalr	1886(ra) # 9ae <pfreepages>
        global_array[2047] = 333;
 258:	14d00793          	li	a5,333
 25c:	00004717          	auipc	a4,0x4
 260:	daf72823          	sw	a5,-592(a4) # 400c <global_array+0x1ffc>
        printf("[chld] modified two elements in the 2nd page, global_array[2047]=%d\n", global_array[2047]);
 264:	14d00593          	li	a1,333
 268:	00001517          	auipc	a0,0x1
 26c:	cd050513          	addi	a0,a0,-816 # f38 <malloc+0x1f0>
 270:	00001097          	auipc	ra,0x1
 274:	a20080e7          	jalr	-1504(ra) # c90 <printf>
        printf("[chld] v6 --> ");
 278:	00001517          	auipc	a0,0x1
 27c:	d0850513          	addi	a0,a0,-760 # f80 <malloc+0x238>
 280:	00001097          	auipc	ra,0x1
 284:	a10080e7          	jalr	-1520(ra) # c90 <printf>
        print_free_frame_cnt();
 288:	00000097          	auipc	ra,0x0
 28c:	726080e7          	jalr	1830(ra) # 9ae <pfreepages>
        printf("[chld] global_array[0] --> %d\n", global_array[0]);
 290:	408c                	lw	a1,0(s1)
 292:	00001517          	auipc	a0,0x1
 296:	cfe50513          	addi	a0,a0,-770 # f90 <malloc+0x248>
 29a:	00001097          	auipc	ra,0x1
 29e:	9f6080e7          	jalr	-1546(ra) # c90 <printf>
        exit(0);
 2a2:	4501                	li	a0,0
 2a4:	00000097          	auipc	ra,0x0
 2a8:	64a080e7          	jalr	1610(ra) # 8ee <exit>
        printf("wait() error!");
 2ac:	00001517          	auipc	a0,0x1
 2b0:	bb450513          	addi	a0,a0,-1100 # e60 <malloc+0x118>
 2b4:	00001097          	auipc	ra,0x1
 2b8:	9dc080e7          	jalr	-1572(ra) # c90 <printf>
        exit(1);
 2bc:	4505                	li	a0,1
 2be:	00000097          	auipc	ra,0x0
 2c2:	630080e7          	jalr	1584(ra) # 8ee <exit>

00000000000002c6 <testcase3>:

void testcase3()
{
 2c6:	1101                	addi	sp,sp,-32
 2c8:	ec06                	sd	ra,24(sp)
 2ca:	e822                	sd	s0,16(sp)
 2cc:	e426                	sd	s1,8(sp)
 2ce:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 3 -----\n");
 2d0:	00001517          	auipc	a0,0x1
 2d4:	d8050513          	addi	a0,a0,-640 # 1050 <malloc+0x308>
 2d8:	00001097          	auipc	ra,0x1
 2dc:	9b8080e7          	jalr	-1608(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 2e0:	00001517          	auipc	a0,0x1
 2e4:	b7050513          	addi	a0,a0,-1168 # e50 <malloc+0x108>
 2e8:	00001097          	auipc	ra,0x1
 2ec:	9a8080e7          	jalr	-1624(ra) # c90 <printf>
    print_free_frame_cnt();
 2f0:	00000097          	auipc	ra,0x0
 2f4:	6be080e7          	jalr	1726(ra) # 9ae <pfreepages>

    if ((pid = fork()) == 0)
 2f8:	00000097          	auipc	ra,0x0
 2fc:	5e6080e7          	jalr	1510(ra) # 8de <fork>
 300:	cd35                	beqz	a0,37c <testcase3+0xb6>
 302:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 304:	00001517          	auipc	a0,0x1
 308:	cac50513          	addi	a0,a0,-852 # fb0 <malloc+0x268>
 30c:	00001097          	auipc	ra,0x1
 310:	984080e7          	jalr	-1660(ra) # c90 <printf>
        print_free_frame_cnt();
 314:	00000097          	auipc	ra,0x0
 318:	69a080e7          	jalr	1690(ra) # 9ae <pfreepages>

        printf("[prnt] read global_var, global_var=%d\n", global_var);
 31c:	00002597          	auipc	a1,0x2
 320:	ce45a583          	lw	a1,-796(a1) # 2000 <global_var>
 324:	00001517          	auipc	a0,0x1
 328:	d7c50513          	addi	a0,a0,-644 # 10a0 <malloc+0x358>
 32c:	00001097          	auipc	ra,0x1
 330:	964080e7          	jalr	-1692(ra) # c90 <printf>

        printf("[prnt] v3 --> ");
 334:	00001517          	auipc	a0,0x1
 338:	cd450513          	addi	a0,a0,-812 # 1008 <malloc+0x2c0>
 33c:	00001097          	auipc	ra,0x1
 340:	954080e7          	jalr	-1708(ra) # c90 <printf>
        print_free_frame_cnt();
 344:	00000097          	auipc	ra,0x0
 348:	66a080e7          	jalr	1642(ra) # 9ae <pfreepages>
    }

    if (wait(0) != pid)
 34c:	4501                	li	a0,0
 34e:	00000097          	auipc	ra,0x0
 352:	5a8080e7          	jalr	1448(ra) # 8f6 <wait>
 356:	08951663          	bne	a0,s1,3e2 <testcase3+0x11c>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v6 --> ");
 35a:	00001517          	auipc	a0,0x1
 35e:	d6e50513          	addi	a0,a0,-658 # 10c8 <malloc+0x380>
 362:	00001097          	auipc	ra,0x1
 366:	92e080e7          	jalr	-1746(ra) # c90 <printf>
    print_free_frame_cnt();
 36a:	00000097          	auipc	ra,0x0
 36e:	644080e7          	jalr	1604(ra) # 9ae <pfreepages>
}
 372:	60e2                	ld	ra,24(sp)
 374:	6442                	ld	s0,16(sp)
 376:	64a2                	ld	s1,8(sp)
 378:	6105                	addi	sp,sp,32
 37a:	8082                	ret
        sleep(50);
 37c:	03200513          	li	a0,50
 380:	00000097          	auipc	ra,0x0
 384:	5fe080e7          	jalr	1534(ra) # 97e <sleep>
        printf("[chld] v4 --> ");
 388:	00001517          	auipc	a0,0x1
 38c:	b3050513          	addi	a0,a0,-1232 # eb8 <malloc+0x170>
 390:	00001097          	auipc	ra,0x1
 394:	900080e7          	jalr	-1792(ra) # c90 <printf>
        print_free_frame_cnt();
 398:	00000097          	auipc	ra,0x0
 39c:	616080e7          	jalr	1558(ra) # 9ae <pfreepages>
        global_var = 100;
 3a0:	06400793          	li	a5,100
 3a4:	00002717          	auipc	a4,0x2
 3a8:	c4f72e23          	sw	a5,-932(a4) # 2000 <global_var>
        printf("[chld] modified global_var, global_var=%d\n", global_var);
 3ac:	06400593          	li	a1,100
 3b0:	00001517          	auipc	a0,0x1
 3b4:	cc050513          	addi	a0,a0,-832 # 1070 <malloc+0x328>
 3b8:	00001097          	auipc	ra,0x1
 3bc:	8d8080e7          	jalr	-1832(ra) # c90 <printf>
        printf("[chld] v5 --> ");
 3c0:	00001517          	auipc	a0,0x1
 3c4:	b6850513          	addi	a0,a0,-1176 # f28 <malloc+0x1e0>
 3c8:	00001097          	auipc	ra,0x1
 3cc:	8c8080e7          	jalr	-1848(ra) # c90 <printf>
        print_free_frame_cnt();
 3d0:	00000097          	auipc	ra,0x0
 3d4:	5de080e7          	jalr	1502(ra) # 9ae <pfreepages>
        exit(0);
 3d8:	4501                	li	a0,0
 3da:	00000097          	auipc	ra,0x0
 3de:	514080e7          	jalr	1300(ra) # 8ee <exit>
        printf("wait() error!");
 3e2:	00001517          	auipc	a0,0x1
 3e6:	a7e50513          	addi	a0,a0,-1410 # e60 <malloc+0x118>
 3ea:	00001097          	auipc	ra,0x1
 3ee:	8a6080e7          	jalr	-1882(ra) # c90 <printf>
        exit(1);
 3f2:	4505                	li	a0,1
 3f4:	00000097          	auipc	ra,0x0
 3f8:	4fa080e7          	jalr	1274(ra) # 8ee <exit>

00000000000003fc <testcase2>:

void testcase2()
{
 3fc:	1101                	addi	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	e426                	sd	s1,8(sp)
 404:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 2 -----\n");
 406:	00001517          	auipc	a0,0x1
 40a:	cd250513          	addi	a0,a0,-814 # 10d8 <malloc+0x390>
 40e:	00001097          	auipc	ra,0x1
 412:	882080e7          	jalr	-1918(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 416:	00001517          	auipc	a0,0x1
 41a:	a3a50513          	addi	a0,a0,-1478 # e50 <malloc+0x108>
 41e:	00001097          	auipc	ra,0x1
 422:	872080e7          	jalr	-1934(ra) # c90 <printf>
    print_free_frame_cnt();
 426:	00000097          	auipc	ra,0x0
 42a:	588080e7          	jalr	1416(ra) # 9ae <pfreepages>

    if ((pid = fork()) == 0)
 42e:	00000097          	auipc	ra,0x0
 432:	4b0080e7          	jalr	1200(ra) # 8de <fork>
 436:	c531                	beqz	a0,482 <testcase2+0x86>
 438:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v2 --> ");
 43a:	00001517          	auipc	a0,0x1
 43e:	b7650513          	addi	a0,a0,-1162 # fb0 <malloc+0x268>
 442:	00001097          	auipc	ra,0x1
 446:	84e080e7          	jalr	-1970(ra) # c90 <printf>
        print_free_frame_cnt();
 44a:	00000097          	auipc	ra,0x0
 44e:	564080e7          	jalr	1380(ra) # 9ae <pfreepages>
    }

    if (wait(0) != pid)
 452:	4501                	li	a0,0
 454:	00000097          	auipc	ra,0x0
 458:	4a2080e7          	jalr	1186(ra) # 8f6 <wait>
 45c:	08951263          	bne	a0,s1,4e0 <testcase2+0xe4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v5 --> ");
 460:	00001517          	auipc	a0,0x1
 464:	cd050513          	addi	a0,a0,-816 # 1130 <malloc+0x3e8>
 468:	00001097          	auipc	ra,0x1
 46c:	828080e7          	jalr	-2008(ra) # c90 <printf>
    print_free_frame_cnt();
 470:	00000097          	auipc	ra,0x0
 474:	53e080e7          	jalr	1342(ra) # 9ae <pfreepages>
}
 478:	60e2                	ld	ra,24(sp)
 47a:	6442                	ld	s0,16(sp)
 47c:	64a2                	ld	s1,8(sp)
 47e:	6105                	addi	sp,sp,32
 480:	8082                	ret
        sleep(50);
 482:	03200513          	li	a0,50
 486:	00000097          	auipc	ra,0x0
 48a:	4f8080e7          	jalr	1272(ra) # 97e <sleep>
        printf("[chld] v3 --> ");
 48e:	00001517          	auipc	a0,0x1
 492:	c6a50513          	addi	a0,a0,-918 # 10f8 <malloc+0x3b0>
 496:	00000097          	auipc	ra,0x0
 49a:	7fa080e7          	jalr	2042(ra) # c90 <printf>
        print_free_frame_cnt();
 49e:	00000097          	auipc	ra,0x0
 4a2:	510080e7          	jalr	1296(ra) # 9ae <pfreepages>
        printf("[chld] read global_var, global_var=%d\n", global_var);
 4a6:	00002597          	auipc	a1,0x2
 4aa:	b5a5a583          	lw	a1,-1190(a1) # 2000 <global_var>
 4ae:	00001517          	auipc	a0,0x1
 4b2:	c5a50513          	addi	a0,a0,-934 # 1108 <malloc+0x3c0>
 4b6:	00000097          	auipc	ra,0x0
 4ba:	7da080e7          	jalr	2010(ra) # c90 <printf>
        printf("[chld] v4 --> ");
 4be:	00001517          	auipc	a0,0x1
 4c2:	9fa50513          	addi	a0,a0,-1542 # eb8 <malloc+0x170>
 4c6:	00000097          	auipc	ra,0x0
 4ca:	7ca080e7          	jalr	1994(ra) # c90 <printf>
        print_free_frame_cnt();
 4ce:	00000097          	auipc	ra,0x0
 4d2:	4e0080e7          	jalr	1248(ra) # 9ae <pfreepages>
        exit(0);
 4d6:	4501                	li	a0,0
 4d8:	00000097          	auipc	ra,0x0
 4dc:	416080e7          	jalr	1046(ra) # 8ee <exit>
        printf("wait() error!");
 4e0:	00001517          	auipc	a0,0x1
 4e4:	98050513          	addi	a0,a0,-1664 # e60 <malloc+0x118>
 4e8:	00000097          	auipc	ra,0x0
 4ec:	7a8080e7          	jalr	1960(ra) # c90 <printf>
        exit(1);
 4f0:	4505                	li	a0,1
 4f2:	00000097          	auipc	ra,0x0
 4f6:	3fc080e7          	jalr	1020(ra) # 8ee <exit>

00000000000004fa <testcase1>:

void testcase1()
{
 4fa:	1101                	addi	sp,sp,-32
 4fc:	ec06                	sd	ra,24(sp)
 4fe:	e822                	sd	s0,16(sp)
 500:	e426                	sd	s1,8(sp)
 502:	1000                	addi	s0,sp,32
    int pid;

    printf("\n----- Test case 1 -----\n");
 504:	00001517          	auipc	a0,0x1
 508:	c3c50513          	addi	a0,a0,-964 # 1140 <malloc+0x3f8>
 50c:	00000097          	auipc	ra,0x0
 510:	784080e7          	jalr	1924(ra) # c90 <printf>
    printf("[prnt] v1 --> ");
 514:	00001517          	auipc	a0,0x1
 518:	93c50513          	addi	a0,a0,-1732 # e50 <malloc+0x108>
 51c:	00000097          	auipc	ra,0x0
 520:	774080e7          	jalr	1908(ra) # c90 <printf>
    print_free_frame_cnt();
 524:	00000097          	auipc	ra,0x0
 528:	48a080e7          	jalr	1162(ra) # 9ae <pfreepages>

    if ((pid = fork()) == 0)
 52c:	00000097          	auipc	ra,0x0
 530:	3b2080e7          	jalr	946(ra) # 8de <fork>
 534:	c531                	beqz	a0,580 <testcase1+0x86>
 536:	84aa                	mv	s1,a0
        exit(0);
    }
    else
    {
        // parent
        printf("[prnt] v3 --> ");
 538:	00001517          	auipc	a0,0x1
 53c:	ad050513          	addi	a0,a0,-1328 # 1008 <malloc+0x2c0>
 540:	00000097          	auipc	ra,0x0
 544:	750080e7          	jalr	1872(ra) # c90 <printf>
        print_free_frame_cnt();
 548:	00000097          	auipc	ra,0x0
 54c:	466080e7          	jalr	1126(ra) # 9ae <pfreepages>
    }

    if (wait(0) != pid)
 550:	4501                	li	a0,0
 552:	00000097          	auipc	ra,0x0
 556:	3a4080e7          	jalr	932(ra) # 8f6 <wait>
 55a:	04951a63          	bne	a0,s1,5ae <testcase1+0xb4>
    {
        printf("wait() error!");
        exit(1);
    }

    printf("[prnt] v4 --> ");
 55e:	00001517          	auipc	a0,0x1
 562:	c1250513          	addi	a0,a0,-1006 # 1170 <malloc+0x428>
 566:	00000097          	auipc	ra,0x0
 56a:	72a080e7          	jalr	1834(ra) # c90 <printf>
    print_free_frame_cnt();
 56e:	00000097          	auipc	ra,0x0
 572:	440080e7          	jalr	1088(ra) # 9ae <pfreepages>
}
 576:	60e2                	ld	ra,24(sp)
 578:	6442                	ld	s0,16(sp)
 57a:	64a2                	ld	s1,8(sp)
 57c:	6105                	addi	sp,sp,32
 57e:	8082                	ret
        sleep(50);
 580:	03200513          	li	a0,50
 584:	00000097          	auipc	ra,0x0
 588:	3fa080e7          	jalr	1018(ra) # 97e <sleep>
        printf("[chld] v2 --> ");
 58c:	00001517          	auipc	a0,0x1
 590:	bd450513          	addi	a0,a0,-1068 # 1160 <malloc+0x418>
 594:	00000097          	auipc	ra,0x0
 598:	6fc080e7          	jalr	1788(ra) # c90 <printf>
        print_free_frame_cnt();
 59c:	00000097          	auipc	ra,0x0
 5a0:	412080e7          	jalr	1042(ra) # 9ae <pfreepages>
        exit(0);
 5a4:	4501                	li	a0,0
 5a6:	00000097          	auipc	ra,0x0
 5aa:	348080e7          	jalr	840(ra) # 8ee <exit>
        printf("wait() error!");
 5ae:	00001517          	auipc	a0,0x1
 5b2:	8b250513          	addi	a0,a0,-1870 # e60 <malloc+0x118>
 5b6:	00000097          	auipc	ra,0x0
 5ba:	6da080e7          	jalr	1754(ra) # c90 <printf>
        exit(1);
 5be:	4505                	li	a0,1
 5c0:	00000097          	auipc	ra,0x0
 5c4:	32e080e7          	jalr	814(ra) # 8ee <exit>

00000000000005c8 <main>:

int main(int argc, char *argv[])
{
 5c8:	1101                	addi	sp,sp,-32
 5ca:	ec06                	sd	ra,24(sp)
 5cc:	e822                	sd	s0,16(sp)
 5ce:	e426                	sd	s1,8(sp)
 5d0:	1000                	addi	s0,sp,32
 5d2:	84ae                	mv	s1,a1
    if (argc < 2)
 5d4:	4785                	li	a5,1
 5d6:	02a7d863          	bge	a5,a0,606 <main+0x3e>
    {
        printf("Usage: cowtest test_id");
    }
    switch (atoi(argv[1]))
 5da:	6488                	ld	a0,8(s1)
 5dc:	00000097          	auipc	ra,0x0
 5e0:	210080e7          	jalr	528(ra) # 7ec <atoi>
 5e4:	478d                	li	a5,3
 5e6:	04f50c63          	beq	a0,a5,63e <main+0x76>
 5ea:	02a7c763          	blt	a5,a0,618 <main+0x50>
 5ee:	4785                	li	a5,1
 5f0:	02f50d63          	beq	a0,a5,62a <main+0x62>
 5f4:	4789                	li	a5,2
 5f6:	04f51a63          	bne	a0,a5,64a <main+0x82>
    case 1:
        testcase1();
        break;

    case 2:
        testcase2();
 5fa:	00000097          	auipc	ra,0x0
 5fe:	e02080e7          	jalr	-510(ra) # 3fc <testcase2>

    default:
        printf("Error: No test with index %s", argv[1]);
        return 1;
    }
    return 0;
 602:	4501                	li	a0,0
        break;
 604:	a805                	j	634 <main+0x6c>
        printf("Usage: cowtest test_id");
 606:	00001517          	auipc	a0,0x1
 60a:	b7a50513          	addi	a0,a0,-1158 # 1180 <malloc+0x438>
 60e:	00000097          	auipc	ra,0x0
 612:	682080e7          	jalr	1666(ra) # c90 <printf>
 616:	b7d1                	j	5da <main+0x12>
    switch (atoi(argv[1]))
 618:	4791                	li	a5,4
 61a:	02f51863          	bne	a0,a5,64a <main+0x82>
        testcase4();
 61e:	00000097          	auipc	ra,0x0
 622:	aa4080e7          	jalr	-1372(ra) # c2 <testcase4>
    return 0;
 626:	4501                	li	a0,0
        break;
 628:	a031                	j	634 <main+0x6c>
        testcase1();
 62a:	00000097          	auipc	ra,0x0
 62e:	ed0080e7          	jalr	-304(ra) # 4fa <testcase1>
    return 0;
 632:	4501                	li	a0,0
 634:	60e2                	ld	ra,24(sp)
 636:	6442                	ld	s0,16(sp)
 638:	64a2                	ld	s1,8(sp)
 63a:	6105                	addi	sp,sp,32
 63c:	8082                	ret
        testcase3();
 63e:	00000097          	auipc	ra,0x0
 642:	c88080e7          	jalr	-888(ra) # 2c6 <testcase3>
    return 0;
 646:	4501                	li	a0,0
        break;
 648:	b7f5                	j	634 <main+0x6c>
        printf("Error: No test with index %s", argv[1]);
 64a:	648c                	ld	a1,8(s1)
 64c:	00001517          	auipc	a0,0x1
 650:	b4c50513          	addi	a0,a0,-1204 # 1198 <malloc+0x450>
 654:	00000097          	auipc	ra,0x0
 658:	63c080e7          	jalr	1596(ra) # c90 <printf>
        return 1;
 65c:	4505                	li	a0,1
 65e:	bfd9                	j	634 <main+0x6c>

0000000000000660 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 660:	1141                	addi	sp,sp,-16
 662:	e406                	sd	ra,8(sp)
 664:	e022                	sd	s0,0(sp)
 666:	0800                	addi	s0,sp,16
  extern int main();
  main();
 668:	00000097          	auipc	ra,0x0
 66c:	f60080e7          	jalr	-160(ra) # 5c8 <main>
  exit(0);
 670:	4501                	li	a0,0
 672:	00000097          	auipc	ra,0x0
 676:	27c080e7          	jalr	636(ra) # 8ee <exit>

000000000000067a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 67a:	1141                	addi	sp,sp,-16
 67c:	e422                	sd	s0,8(sp)
 67e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 680:	87aa                	mv	a5,a0
 682:	0585                	addi	a1,a1,1
 684:	0785                	addi	a5,a5,1
 686:	fff5c703          	lbu	a4,-1(a1)
 68a:	fee78fa3          	sb	a4,-1(a5)
 68e:	fb75                	bnez	a4,682 <strcpy+0x8>
    ;
  return os;
}
 690:	6422                	ld	s0,8(sp)
 692:	0141                	addi	sp,sp,16
 694:	8082                	ret

0000000000000696 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 696:	1141                	addi	sp,sp,-16
 698:	e422                	sd	s0,8(sp)
 69a:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 69c:	00054783          	lbu	a5,0(a0)
 6a0:	cb91                	beqz	a5,6b4 <strcmp+0x1e>
 6a2:	0005c703          	lbu	a4,0(a1)
 6a6:	00f71763          	bne	a4,a5,6b4 <strcmp+0x1e>
    p++, q++;
 6aa:	0505                	addi	a0,a0,1
 6ac:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 6ae:	00054783          	lbu	a5,0(a0)
 6b2:	fbe5                	bnez	a5,6a2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 6b4:	0005c503          	lbu	a0,0(a1)
}
 6b8:	40a7853b          	subw	a0,a5,a0
 6bc:	6422                	ld	s0,8(sp)
 6be:	0141                	addi	sp,sp,16
 6c0:	8082                	ret

00000000000006c2 <strlen>:

uint
strlen(const char *s)
{
 6c2:	1141                	addi	sp,sp,-16
 6c4:	e422                	sd	s0,8(sp)
 6c6:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 6c8:	00054783          	lbu	a5,0(a0)
 6cc:	cf91                	beqz	a5,6e8 <strlen+0x26>
 6ce:	0505                	addi	a0,a0,1
 6d0:	87aa                	mv	a5,a0
 6d2:	4685                	li	a3,1
 6d4:	9e89                	subw	a3,a3,a0
 6d6:	00f6853b          	addw	a0,a3,a5
 6da:	0785                	addi	a5,a5,1
 6dc:	fff7c703          	lbu	a4,-1(a5)
 6e0:	fb7d                	bnez	a4,6d6 <strlen+0x14>
    ;
  return n;
}
 6e2:	6422                	ld	s0,8(sp)
 6e4:	0141                	addi	sp,sp,16
 6e6:	8082                	ret
  for(n = 0; s[n]; n++)
 6e8:	4501                	li	a0,0
 6ea:	bfe5                	j	6e2 <strlen+0x20>

00000000000006ec <memset>:

void*
memset(void *dst, int c, uint n)
{
 6ec:	1141                	addi	sp,sp,-16
 6ee:	e422                	sd	s0,8(sp)
 6f0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 6f2:	ca19                	beqz	a2,708 <memset+0x1c>
 6f4:	87aa                	mv	a5,a0
 6f6:	1602                	slli	a2,a2,0x20
 6f8:	9201                	srli	a2,a2,0x20
 6fa:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 6fe:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 702:	0785                	addi	a5,a5,1
 704:	fee79de3          	bne	a5,a4,6fe <memset+0x12>
  }
  return dst;
}
 708:	6422                	ld	s0,8(sp)
 70a:	0141                	addi	sp,sp,16
 70c:	8082                	ret

000000000000070e <strchr>:

char*
strchr(const char *s, char c)
{
 70e:	1141                	addi	sp,sp,-16
 710:	e422                	sd	s0,8(sp)
 712:	0800                	addi	s0,sp,16
  for(; *s; s++)
 714:	00054783          	lbu	a5,0(a0)
 718:	cb99                	beqz	a5,72e <strchr+0x20>
    if(*s == c)
 71a:	00f58763          	beq	a1,a5,728 <strchr+0x1a>
  for(; *s; s++)
 71e:	0505                	addi	a0,a0,1
 720:	00054783          	lbu	a5,0(a0)
 724:	fbfd                	bnez	a5,71a <strchr+0xc>
      return (char*)s;
  return 0;
 726:	4501                	li	a0,0
}
 728:	6422                	ld	s0,8(sp)
 72a:	0141                	addi	sp,sp,16
 72c:	8082                	ret
  return 0;
 72e:	4501                	li	a0,0
 730:	bfe5                	j	728 <strchr+0x1a>

0000000000000732 <gets>:

char*
gets(char *buf, int max)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec86                	sd	ra,88(sp)
 736:	e8a2                	sd	s0,80(sp)
 738:	e4a6                	sd	s1,72(sp)
 73a:	e0ca                	sd	s2,64(sp)
 73c:	fc4e                	sd	s3,56(sp)
 73e:	f852                	sd	s4,48(sp)
 740:	f456                	sd	s5,40(sp)
 742:	f05a                	sd	s6,32(sp)
 744:	ec5e                	sd	s7,24(sp)
 746:	1080                	addi	s0,sp,96
 748:	8baa                	mv	s7,a0
 74a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 74c:	892a                	mv	s2,a0
 74e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 750:	4aa9                	li	s5,10
 752:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 754:	89a6                	mv	s3,s1
 756:	2485                	addiw	s1,s1,1
 758:	0344d863          	bge	s1,s4,788 <gets+0x56>
    cc = read(0, &c, 1);
 75c:	4605                	li	a2,1
 75e:	faf40593          	addi	a1,s0,-81
 762:	4501                	li	a0,0
 764:	00000097          	auipc	ra,0x0
 768:	1a2080e7          	jalr	418(ra) # 906 <read>
    if(cc < 1)
 76c:	00a05e63          	blez	a0,788 <gets+0x56>
    buf[i++] = c;
 770:	faf44783          	lbu	a5,-81(s0)
 774:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 778:	01578763          	beq	a5,s5,786 <gets+0x54>
 77c:	0905                	addi	s2,s2,1
 77e:	fd679be3          	bne	a5,s6,754 <gets+0x22>
  for(i=0; i+1 < max; ){
 782:	89a6                	mv	s3,s1
 784:	a011                	j	788 <gets+0x56>
 786:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 788:	99de                	add	s3,s3,s7
 78a:	00098023          	sb	zero,0(s3)
  return buf;
}
 78e:	855e                	mv	a0,s7
 790:	60e6                	ld	ra,88(sp)
 792:	6446                	ld	s0,80(sp)
 794:	64a6                	ld	s1,72(sp)
 796:	6906                	ld	s2,64(sp)
 798:	79e2                	ld	s3,56(sp)
 79a:	7a42                	ld	s4,48(sp)
 79c:	7aa2                	ld	s5,40(sp)
 79e:	7b02                	ld	s6,32(sp)
 7a0:	6be2                	ld	s7,24(sp)
 7a2:	6125                	addi	sp,sp,96
 7a4:	8082                	ret

00000000000007a6 <stat>:

int
stat(const char *n, struct stat *st)
{
 7a6:	1101                	addi	sp,sp,-32
 7a8:	ec06                	sd	ra,24(sp)
 7aa:	e822                	sd	s0,16(sp)
 7ac:	e426                	sd	s1,8(sp)
 7ae:	e04a                	sd	s2,0(sp)
 7b0:	1000                	addi	s0,sp,32
 7b2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 7b4:	4581                	li	a1,0
 7b6:	00000097          	auipc	ra,0x0
 7ba:	178080e7          	jalr	376(ra) # 92e <open>
  if(fd < 0)
 7be:	02054563          	bltz	a0,7e8 <stat+0x42>
 7c2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 7c4:	85ca                	mv	a1,s2
 7c6:	00000097          	auipc	ra,0x0
 7ca:	180080e7          	jalr	384(ra) # 946 <fstat>
 7ce:	892a                	mv	s2,a0
  close(fd);
 7d0:	8526                	mv	a0,s1
 7d2:	00000097          	auipc	ra,0x0
 7d6:	144080e7          	jalr	324(ra) # 916 <close>
  return r;
}
 7da:	854a                	mv	a0,s2
 7dc:	60e2                	ld	ra,24(sp)
 7de:	6442                	ld	s0,16(sp)
 7e0:	64a2                	ld	s1,8(sp)
 7e2:	6902                	ld	s2,0(sp)
 7e4:	6105                	addi	sp,sp,32
 7e6:	8082                	ret
    return -1;
 7e8:	597d                	li	s2,-1
 7ea:	bfc5                	j	7da <stat+0x34>

00000000000007ec <atoi>:

int
atoi(const char *s)
{
 7ec:	1141                	addi	sp,sp,-16
 7ee:	e422                	sd	s0,8(sp)
 7f0:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 7f2:	00054683          	lbu	a3,0(a0)
 7f6:	fd06879b          	addiw	a5,a3,-48
 7fa:	0ff7f793          	zext.b	a5,a5
 7fe:	4625                	li	a2,9
 800:	02f66863          	bltu	a2,a5,830 <atoi+0x44>
 804:	872a                	mv	a4,a0
  n = 0;
 806:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 808:	0705                	addi	a4,a4,1
 80a:	0025179b          	slliw	a5,a0,0x2
 80e:	9fa9                	addw	a5,a5,a0
 810:	0017979b          	slliw	a5,a5,0x1
 814:	9fb5                	addw	a5,a5,a3
 816:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 81a:	00074683          	lbu	a3,0(a4)
 81e:	fd06879b          	addiw	a5,a3,-48
 822:	0ff7f793          	zext.b	a5,a5
 826:	fef671e3          	bgeu	a2,a5,808 <atoi+0x1c>
  return n;
}
 82a:	6422                	ld	s0,8(sp)
 82c:	0141                	addi	sp,sp,16
 82e:	8082                	ret
  n = 0;
 830:	4501                	li	a0,0
 832:	bfe5                	j	82a <atoi+0x3e>

0000000000000834 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 834:	1141                	addi	sp,sp,-16
 836:	e422                	sd	s0,8(sp)
 838:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 83a:	02b57463          	bgeu	a0,a1,862 <memmove+0x2e>
    while(n-- > 0)
 83e:	00c05f63          	blez	a2,85c <memmove+0x28>
 842:	1602                	slli	a2,a2,0x20
 844:	9201                	srli	a2,a2,0x20
 846:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 84a:	872a                	mv	a4,a0
      *dst++ = *src++;
 84c:	0585                	addi	a1,a1,1
 84e:	0705                	addi	a4,a4,1
 850:	fff5c683          	lbu	a3,-1(a1)
 854:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 858:	fee79ae3          	bne	a5,a4,84c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 85c:	6422                	ld	s0,8(sp)
 85e:	0141                	addi	sp,sp,16
 860:	8082                	ret
    dst += n;
 862:	00c50733          	add	a4,a0,a2
    src += n;
 866:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 868:	fec05ae3          	blez	a2,85c <memmove+0x28>
 86c:	fff6079b          	addiw	a5,a2,-1
 870:	1782                	slli	a5,a5,0x20
 872:	9381                	srli	a5,a5,0x20
 874:	fff7c793          	not	a5,a5
 878:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 87a:	15fd                	addi	a1,a1,-1
 87c:	177d                	addi	a4,a4,-1
 87e:	0005c683          	lbu	a3,0(a1)
 882:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 886:	fee79ae3          	bne	a5,a4,87a <memmove+0x46>
 88a:	bfc9                	j	85c <memmove+0x28>

000000000000088c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 88c:	1141                	addi	sp,sp,-16
 88e:	e422                	sd	s0,8(sp)
 890:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 892:	ca05                	beqz	a2,8c2 <memcmp+0x36>
 894:	fff6069b          	addiw	a3,a2,-1
 898:	1682                	slli	a3,a3,0x20
 89a:	9281                	srli	a3,a3,0x20
 89c:	0685                	addi	a3,a3,1
 89e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 8a0:	00054783          	lbu	a5,0(a0)
 8a4:	0005c703          	lbu	a4,0(a1)
 8a8:	00e79863          	bne	a5,a4,8b8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 8ac:	0505                	addi	a0,a0,1
    p2++;
 8ae:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 8b0:	fed518e3          	bne	a0,a3,8a0 <memcmp+0x14>
  }
  return 0;
 8b4:	4501                	li	a0,0
 8b6:	a019                	j	8bc <memcmp+0x30>
      return *p1 - *p2;
 8b8:	40e7853b          	subw	a0,a5,a4
}
 8bc:	6422                	ld	s0,8(sp)
 8be:	0141                	addi	sp,sp,16
 8c0:	8082                	ret
  return 0;
 8c2:	4501                	li	a0,0
 8c4:	bfe5                	j	8bc <memcmp+0x30>

00000000000008c6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 8c6:	1141                	addi	sp,sp,-16
 8c8:	e406                	sd	ra,8(sp)
 8ca:	e022                	sd	s0,0(sp)
 8cc:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 8ce:	00000097          	auipc	ra,0x0
 8d2:	f66080e7          	jalr	-154(ra) # 834 <memmove>
}
 8d6:	60a2                	ld	ra,8(sp)
 8d8:	6402                	ld	s0,0(sp)
 8da:	0141                	addi	sp,sp,16
 8dc:	8082                	ret

00000000000008de <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 8de:	4885                	li	a7,1
 ecall
 8e0:	00000073          	ecall
 ret
 8e4:	8082                	ret

00000000000008e6 <vfork>:
.global vfork
vfork:
 li a7, SYS_vfork
 8e6:	4885                	li	a7,1
 ecall
 8e8:	00000073          	ecall
 ret
 8ec:	8082                	ret

00000000000008ee <exit>:
.global exit
exit:
 li a7, SYS_exit
 8ee:	4889                	li	a7,2
 ecall
 8f0:	00000073          	ecall
 ret
 8f4:	8082                	ret

00000000000008f6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 8f6:	488d                	li	a7,3
 ecall
 8f8:	00000073          	ecall
 ret
 8fc:	8082                	ret

00000000000008fe <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 8fe:	4891                	li	a7,4
 ecall
 900:	00000073          	ecall
 ret
 904:	8082                	ret

0000000000000906 <read>:
.global read
read:
 li a7, SYS_read
 906:	4895                	li	a7,5
 ecall
 908:	00000073          	ecall
 ret
 90c:	8082                	ret

000000000000090e <write>:
.global write
write:
 li a7, SYS_write
 90e:	48c1                	li	a7,16
 ecall
 910:	00000073          	ecall
 ret
 914:	8082                	ret

0000000000000916 <close>:
.global close
close:
 li a7, SYS_close
 916:	48d5                	li	a7,21
 ecall
 918:	00000073          	ecall
 ret
 91c:	8082                	ret

000000000000091e <kill>:
.global kill
kill:
 li a7, SYS_kill
 91e:	4899                	li	a7,6
 ecall
 920:	00000073          	ecall
 ret
 924:	8082                	ret

0000000000000926 <exec>:
.global exec
exec:
 li a7, SYS_exec
 926:	489d                	li	a7,7
 ecall
 928:	00000073          	ecall
 ret
 92c:	8082                	ret

000000000000092e <open>:
.global open
open:
 li a7, SYS_open
 92e:	48bd                	li	a7,15
 ecall
 930:	00000073          	ecall
 ret
 934:	8082                	ret

0000000000000936 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 936:	48c5                	li	a7,17
 ecall
 938:	00000073          	ecall
 ret
 93c:	8082                	ret

000000000000093e <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 93e:	48c9                	li	a7,18
 ecall
 940:	00000073          	ecall
 ret
 944:	8082                	ret

0000000000000946 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 946:	48a1                	li	a7,8
 ecall
 948:	00000073          	ecall
 ret
 94c:	8082                	ret

000000000000094e <link>:
.global link
link:
 li a7, SYS_link
 94e:	48cd                	li	a7,19
 ecall
 950:	00000073          	ecall
 ret
 954:	8082                	ret

0000000000000956 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 956:	48d1                	li	a7,20
 ecall
 958:	00000073          	ecall
 ret
 95c:	8082                	ret

000000000000095e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 95e:	48a5                	li	a7,9
 ecall
 960:	00000073          	ecall
 ret
 964:	8082                	ret

0000000000000966 <dup>:
.global dup
dup:
 li a7, SYS_dup
 966:	48a9                	li	a7,10
 ecall
 968:	00000073          	ecall
 ret
 96c:	8082                	ret

000000000000096e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 96e:	48ad                	li	a7,11
 ecall
 970:	00000073          	ecall
 ret
 974:	8082                	ret

0000000000000976 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 976:	48b1                	li	a7,12
 ecall
 978:	00000073          	ecall
 ret
 97c:	8082                	ret

000000000000097e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 97e:	48b5                	li	a7,13
 ecall
 980:	00000073          	ecall
 ret
 984:	8082                	ret

0000000000000986 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 986:	48b9                	li	a7,14
 ecall
 988:	00000073          	ecall
 ret
 98c:	8082                	ret

000000000000098e <ps>:
.global ps
ps:
 li a7, SYS_ps
 98e:	48d9                	li	a7,22
 ecall
 990:	00000073          	ecall
 ret
 994:	8082                	ret

0000000000000996 <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 996:	48dd                	li	a7,23
 ecall
 998:	00000073          	ecall
 ret
 99c:	8082                	ret

000000000000099e <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 99e:	48e1                	li	a7,24
 ecall
 9a0:	00000073          	ecall
 ret
 9a4:	8082                	ret

00000000000009a6 <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 9a6:	48e9                	li	a7,26
 ecall
 9a8:	00000073          	ecall
 ret
 9ac:	8082                	ret

00000000000009ae <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 9ae:	48e5                	li	a7,25
 ecall
 9b0:	00000073          	ecall
 ret
 9b4:	8082                	ret

00000000000009b6 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 9b6:	1101                	addi	sp,sp,-32
 9b8:	ec06                	sd	ra,24(sp)
 9ba:	e822                	sd	s0,16(sp)
 9bc:	1000                	addi	s0,sp,32
 9be:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 9c2:	4605                	li	a2,1
 9c4:	fef40593          	addi	a1,s0,-17
 9c8:	00000097          	auipc	ra,0x0
 9cc:	f46080e7          	jalr	-186(ra) # 90e <write>
}
 9d0:	60e2                	ld	ra,24(sp)
 9d2:	6442                	ld	s0,16(sp)
 9d4:	6105                	addi	sp,sp,32
 9d6:	8082                	ret

00000000000009d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 9d8:	7139                	addi	sp,sp,-64
 9da:	fc06                	sd	ra,56(sp)
 9dc:	f822                	sd	s0,48(sp)
 9de:	f426                	sd	s1,40(sp)
 9e0:	f04a                	sd	s2,32(sp)
 9e2:	ec4e                	sd	s3,24(sp)
 9e4:	0080                	addi	s0,sp,64
 9e6:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 9e8:	c299                	beqz	a3,9ee <printint+0x16>
 9ea:	0805c963          	bltz	a1,a7c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 9ee:	2581                	sext.w	a1,a1
  neg = 0;
 9f0:	4881                	li	a7,0
 9f2:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 9f6:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 9f8:	2601                	sext.w	a2,a2
 9fa:	00001517          	auipc	a0,0x1
 9fe:	81e50513          	addi	a0,a0,-2018 # 1218 <digits>
 a02:	883a                	mv	a6,a4
 a04:	2705                	addiw	a4,a4,1
 a06:	02c5f7bb          	remuw	a5,a1,a2
 a0a:	1782                	slli	a5,a5,0x20
 a0c:	9381                	srli	a5,a5,0x20
 a0e:	97aa                	add	a5,a5,a0
 a10:	0007c783          	lbu	a5,0(a5)
 a14:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 a18:	0005879b          	sext.w	a5,a1
 a1c:	02c5d5bb          	divuw	a1,a1,a2
 a20:	0685                	addi	a3,a3,1
 a22:	fec7f0e3          	bgeu	a5,a2,a02 <printint+0x2a>
  if(neg)
 a26:	00088c63          	beqz	a7,a3e <printint+0x66>
    buf[i++] = '-';
 a2a:	fd070793          	addi	a5,a4,-48
 a2e:	00878733          	add	a4,a5,s0
 a32:	02d00793          	li	a5,45
 a36:	fef70823          	sb	a5,-16(a4)
 a3a:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 a3e:	02e05863          	blez	a4,a6e <printint+0x96>
 a42:	fc040793          	addi	a5,s0,-64
 a46:	00e78933          	add	s2,a5,a4
 a4a:	fff78993          	addi	s3,a5,-1
 a4e:	99ba                	add	s3,s3,a4
 a50:	377d                	addiw	a4,a4,-1
 a52:	1702                	slli	a4,a4,0x20
 a54:	9301                	srli	a4,a4,0x20
 a56:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 a5a:	fff94583          	lbu	a1,-1(s2)
 a5e:	8526                	mv	a0,s1
 a60:	00000097          	auipc	ra,0x0
 a64:	f56080e7          	jalr	-170(ra) # 9b6 <putc>
  while(--i >= 0)
 a68:	197d                	addi	s2,s2,-1
 a6a:	ff3918e3          	bne	s2,s3,a5a <printint+0x82>
}
 a6e:	70e2                	ld	ra,56(sp)
 a70:	7442                	ld	s0,48(sp)
 a72:	74a2                	ld	s1,40(sp)
 a74:	7902                	ld	s2,32(sp)
 a76:	69e2                	ld	s3,24(sp)
 a78:	6121                	addi	sp,sp,64
 a7a:	8082                	ret
    x = -xx;
 a7c:	40b005bb          	negw	a1,a1
    neg = 1;
 a80:	4885                	li	a7,1
    x = -xx;
 a82:	bf85                	j	9f2 <printint+0x1a>

0000000000000a84 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 a84:	7119                	addi	sp,sp,-128
 a86:	fc86                	sd	ra,120(sp)
 a88:	f8a2                	sd	s0,112(sp)
 a8a:	f4a6                	sd	s1,104(sp)
 a8c:	f0ca                	sd	s2,96(sp)
 a8e:	ecce                	sd	s3,88(sp)
 a90:	e8d2                	sd	s4,80(sp)
 a92:	e4d6                	sd	s5,72(sp)
 a94:	e0da                	sd	s6,64(sp)
 a96:	fc5e                	sd	s7,56(sp)
 a98:	f862                	sd	s8,48(sp)
 a9a:	f466                	sd	s9,40(sp)
 a9c:	f06a                	sd	s10,32(sp)
 a9e:	ec6e                	sd	s11,24(sp)
 aa0:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 aa2:	0005c903          	lbu	s2,0(a1)
 aa6:	18090f63          	beqz	s2,c44 <vprintf+0x1c0>
 aaa:	8aaa                	mv	s5,a0
 aac:	8b32                	mv	s6,a2
 aae:	00158493          	addi	s1,a1,1
  state = 0;
 ab2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 ab4:	02500a13          	li	s4,37
 ab8:	4c55                	li	s8,21
 aba:	00000c97          	auipc	s9,0x0
 abe:	706c8c93          	addi	s9,s9,1798 # 11c0 <malloc+0x478>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 ac2:	02800d93          	li	s11,40
  putc(fd, 'x');
 ac6:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ac8:	00000b97          	auipc	s7,0x0
 acc:	750b8b93          	addi	s7,s7,1872 # 1218 <digits>
 ad0:	a839                	j	aee <vprintf+0x6a>
        putc(fd, c);
 ad2:	85ca                	mv	a1,s2
 ad4:	8556                	mv	a0,s5
 ad6:	00000097          	auipc	ra,0x0
 ada:	ee0080e7          	jalr	-288(ra) # 9b6 <putc>
 ade:	a019                	j	ae4 <vprintf+0x60>
    } else if(state == '%'){
 ae0:	01498d63          	beq	s3,s4,afa <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 ae4:	0485                	addi	s1,s1,1
 ae6:	fff4c903          	lbu	s2,-1(s1)
 aea:	14090d63          	beqz	s2,c44 <vprintf+0x1c0>
    if(state == 0){
 aee:	fe0999e3          	bnez	s3,ae0 <vprintf+0x5c>
      if(c == '%'){
 af2:	ff4910e3          	bne	s2,s4,ad2 <vprintf+0x4e>
        state = '%';
 af6:	89d2                	mv	s3,s4
 af8:	b7f5                	j	ae4 <vprintf+0x60>
      if(c == 'd'){
 afa:	11490c63          	beq	s2,s4,c12 <vprintf+0x18e>
 afe:	f9d9079b          	addiw	a5,s2,-99
 b02:	0ff7f793          	zext.b	a5,a5
 b06:	10fc6e63          	bltu	s8,a5,c22 <vprintf+0x19e>
 b0a:	f9d9079b          	addiw	a5,s2,-99
 b0e:	0ff7f713          	zext.b	a4,a5
 b12:	10ec6863          	bltu	s8,a4,c22 <vprintf+0x19e>
 b16:	00271793          	slli	a5,a4,0x2
 b1a:	97e6                	add	a5,a5,s9
 b1c:	439c                	lw	a5,0(a5)
 b1e:	97e6                	add	a5,a5,s9
 b20:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 b22:	008b0913          	addi	s2,s6,8
 b26:	4685                	li	a3,1
 b28:	4629                	li	a2,10
 b2a:	000b2583          	lw	a1,0(s6)
 b2e:	8556                	mv	a0,s5
 b30:	00000097          	auipc	ra,0x0
 b34:	ea8080e7          	jalr	-344(ra) # 9d8 <printint>
 b38:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 b3a:	4981                	li	s3,0
 b3c:	b765                	j	ae4 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 b3e:	008b0913          	addi	s2,s6,8
 b42:	4681                	li	a3,0
 b44:	4629                	li	a2,10
 b46:	000b2583          	lw	a1,0(s6)
 b4a:	8556                	mv	a0,s5
 b4c:	00000097          	auipc	ra,0x0
 b50:	e8c080e7          	jalr	-372(ra) # 9d8 <printint>
 b54:	8b4a                	mv	s6,s2
      state = 0;
 b56:	4981                	li	s3,0
 b58:	b771                	j	ae4 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 b5a:	008b0913          	addi	s2,s6,8
 b5e:	4681                	li	a3,0
 b60:	866a                	mv	a2,s10
 b62:	000b2583          	lw	a1,0(s6)
 b66:	8556                	mv	a0,s5
 b68:	00000097          	auipc	ra,0x0
 b6c:	e70080e7          	jalr	-400(ra) # 9d8 <printint>
 b70:	8b4a                	mv	s6,s2
      state = 0;
 b72:	4981                	li	s3,0
 b74:	bf85                	j	ae4 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 b76:	008b0793          	addi	a5,s6,8
 b7a:	f8f43423          	sd	a5,-120(s0)
 b7e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 b82:	03000593          	li	a1,48
 b86:	8556                	mv	a0,s5
 b88:	00000097          	auipc	ra,0x0
 b8c:	e2e080e7          	jalr	-466(ra) # 9b6 <putc>
  putc(fd, 'x');
 b90:	07800593          	li	a1,120
 b94:	8556                	mv	a0,s5
 b96:	00000097          	auipc	ra,0x0
 b9a:	e20080e7          	jalr	-480(ra) # 9b6 <putc>
 b9e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 ba0:	03c9d793          	srli	a5,s3,0x3c
 ba4:	97de                	add	a5,a5,s7
 ba6:	0007c583          	lbu	a1,0(a5)
 baa:	8556                	mv	a0,s5
 bac:	00000097          	auipc	ra,0x0
 bb0:	e0a080e7          	jalr	-502(ra) # 9b6 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 bb4:	0992                	slli	s3,s3,0x4
 bb6:	397d                	addiw	s2,s2,-1
 bb8:	fe0914e3          	bnez	s2,ba0 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 bbc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 bc0:	4981                	li	s3,0
 bc2:	b70d                	j	ae4 <vprintf+0x60>
        s = va_arg(ap, char*);
 bc4:	008b0913          	addi	s2,s6,8
 bc8:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 bcc:	02098163          	beqz	s3,bee <vprintf+0x16a>
        while(*s != 0){
 bd0:	0009c583          	lbu	a1,0(s3)
 bd4:	c5ad                	beqz	a1,c3e <vprintf+0x1ba>
          putc(fd, *s);
 bd6:	8556                	mv	a0,s5
 bd8:	00000097          	auipc	ra,0x0
 bdc:	dde080e7          	jalr	-546(ra) # 9b6 <putc>
          s++;
 be0:	0985                	addi	s3,s3,1
        while(*s != 0){
 be2:	0009c583          	lbu	a1,0(s3)
 be6:	f9e5                	bnez	a1,bd6 <vprintf+0x152>
        s = va_arg(ap, char*);
 be8:	8b4a                	mv	s6,s2
      state = 0;
 bea:	4981                	li	s3,0
 bec:	bde5                	j	ae4 <vprintf+0x60>
          s = "(null)";
 bee:	00000997          	auipc	s3,0x0
 bf2:	5ca98993          	addi	s3,s3,1482 # 11b8 <malloc+0x470>
        while(*s != 0){
 bf6:	85ee                	mv	a1,s11
 bf8:	bff9                	j	bd6 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 bfa:	008b0913          	addi	s2,s6,8
 bfe:	000b4583          	lbu	a1,0(s6)
 c02:	8556                	mv	a0,s5
 c04:	00000097          	auipc	ra,0x0
 c08:	db2080e7          	jalr	-590(ra) # 9b6 <putc>
 c0c:	8b4a                	mv	s6,s2
      state = 0;
 c0e:	4981                	li	s3,0
 c10:	bdd1                	j	ae4 <vprintf+0x60>
        putc(fd, c);
 c12:	85d2                	mv	a1,s4
 c14:	8556                	mv	a0,s5
 c16:	00000097          	auipc	ra,0x0
 c1a:	da0080e7          	jalr	-608(ra) # 9b6 <putc>
      state = 0;
 c1e:	4981                	li	s3,0
 c20:	b5d1                	j	ae4 <vprintf+0x60>
        putc(fd, '%');
 c22:	85d2                	mv	a1,s4
 c24:	8556                	mv	a0,s5
 c26:	00000097          	auipc	ra,0x0
 c2a:	d90080e7          	jalr	-624(ra) # 9b6 <putc>
        putc(fd, c);
 c2e:	85ca                	mv	a1,s2
 c30:	8556                	mv	a0,s5
 c32:	00000097          	auipc	ra,0x0
 c36:	d84080e7          	jalr	-636(ra) # 9b6 <putc>
      state = 0;
 c3a:	4981                	li	s3,0
 c3c:	b565                	j	ae4 <vprintf+0x60>
        s = va_arg(ap, char*);
 c3e:	8b4a                	mv	s6,s2
      state = 0;
 c40:	4981                	li	s3,0
 c42:	b54d                	j	ae4 <vprintf+0x60>
    }
  }
}
 c44:	70e6                	ld	ra,120(sp)
 c46:	7446                	ld	s0,112(sp)
 c48:	74a6                	ld	s1,104(sp)
 c4a:	7906                	ld	s2,96(sp)
 c4c:	69e6                	ld	s3,88(sp)
 c4e:	6a46                	ld	s4,80(sp)
 c50:	6aa6                	ld	s5,72(sp)
 c52:	6b06                	ld	s6,64(sp)
 c54:	7be2                	ld	s7,56(sp)
 c56:	7c42                	ld	s8,48(sp)
 c58:	7ca2                	ld	s9,40(sp)
 c5a:	7d02                	ld	s10,32(sp)
 c5c:	6de2                	ld	s11,24(sp)
 c5e:	6109                	addi	sp,sp,128
 c60:	8082                	ret

0000000000000c62 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 c62:	715d                	addi	sp,sp,-80
 c64:	ec06                	sd	ra,24(sp)
 c66:	e822                	sd	s0,16(sp)
 c68:	1000                	addi	s0,sp,32
 c6a:	e010                	sd	a2,0(s0)
 c6c:	e414                	sd	a3,8(s0)
 c6e:	e818                	sd	a4,16(s0)
 c70:	ec1c                	sd	a5,24(s0)
 c72:	03043023          	sd	a6,32(s0)
 c76:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 c7a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 c7e:	8622                	mv	a2,s0
 c80:	00000097          	auipc	ra,0x0
 c84:	e04080e7          	jalr	-508(ra) # a84 <vprintf>
}
 c88:	60e2                	ld	ra,24(sp)
 c8a:	6442                	ld	s0,16(sp)
 c8c:	6161                	addi	sp,sp,80
 c8e:	8082                	ret

0000000000000c90 <printf>:

void
printf(const char *fmt, ...)
{
 c90:	711d                	addi	sp,sp,-96
 c92:	ec06                	sd	ra,24(sp)
 c94:	e822                	sd	s0,16(sp)
 c96:	1000                	addi	s0,sp,32
 c98:	e40c                	sd	a1,8(s0)
 c9a:	e810                	sd	a2,16(s0)
 c9c:	ec14                	sd	a3,24(s0)
 c9e:	f018                	sd	a4,32(s0)
 ca0:	f41c                	sd	a5,40(s0)
 ca2:	03043823          	sd	a6,48(s0)
 ca6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 caa:	00840613          	addi	a2,s0,8
 cae:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 cb2:	85aa                	mv	a1,a0
 cb4:	4505                	li	a0,1
 cb6:	00000097          	auipc	ra,0x0
 cba:	dce080e7          	jalr	-562(ra) # a84 <vprintf>
}
 cbe:	60e2                	ld	ra,24(sp)
 cc0:	6442                	ld	s0,16(sp)
 cc2:	6125                	addi	sp,sp,96
 cc4:	8082                	ret

0000000000000cc6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 cc6:	1141                	addi	sp,sp,-16
 cc8:	e422                	sd	s0,8(sp)
 cca:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 ccc:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 cd0:	00001797          	auipc	a5,0x1
 cd4:	3387b783          	ld	a5,824(a5) # 2008 <freep>
 cd8:	a02d                	j	d02 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 cda:	4618                	lw	a4,8(a2)
 cdc:	9f2d                	addw	a4,a4,a1
 cde:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 ce2:	6398                	ld	a4,0(a5)
 ce4:	6310                	ld	a2,0(a4)
 ce6:	a83d                	j	d24 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 ce8:	ff852703          	lw	a4,-8(a0)
 cec:	9f31                	addw	a4,a4,a2
 cee:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 cf0:	ff053683          	ld	a3,-16(a0)
 cf4:	a091                	j	d38 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 cf6:	6398                	ld	a4,0(a5)
 cf8:	00e7e463          	bltu	a5,a4,d00 <free+0x3a>
 cfc:	00e6ea63          	bltu	a3,a4,d10 <free+0x4a>
{
 d00:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 d02:	fed7fae3          	bgeu	a5,a3,cf6 <free+0x30>
 d06:	6398                	ld	a4,0(a5)
 d08:	00e6e463          	bltu	a3,a4,d10 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 d0c:	fee7eae3          	bltu	a5,a4,d00 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 d10:	ff852583          	lw	a1,-8(a0)
 d14:	6390                	ld	a2,0(a5)
 d16:	02059813          	slli	a6,a1,0x20
 d1a:	01c85713          	srli	a4,a6,0x1c
 d1e:	9736                	add	a4,a4,a3
 d20:	fae60de3          	beq	a2,a4,cda <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 d24:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 d28:	4790                	lw	a2,8(a5)
 d2a:	02061593          	slli	a1,a2,0x20
 d2e:	01c5d713          	srli	a4,a1,0x1c
 d32:	973e                	add	a4,a4,a5
 d34:	fae68ae3          	beq	a3,a4,ce8 <free+0x22>
    p->s.ptr = bp->s.ptr;
 d38:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 d3a:	00001717          	auipc	a4,0x1
 d3e:	2cf73723          	sd	a5,718(a4) # 2008 <freep>
}
 d42:	6422                	ld	s0,8(sp)
 d44:	0141                	addi	sp,sp,16
 d46:	8082                	ret

0000000000000d48 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 d48:	7139                	addi	sp,sp,-64
 d4a:	fc06                	sd	ra,56(sp)
 d4c:	f822                	sd	s0,48(sp)
 d4e:	f426                	sd	s1,40(sp)
 d50:	f04a                	sd	s2,32(sp)
 d52:	ec4e                	sd	s3,24(sp)
 d54:	e852                	sd	s4,16(sp)
 d56:	e456                	sd	s5,8(sp)
 d58:	e05a                	sd	s6,0(sp)
 d5a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 d5c:	02051493          	slli	s1,a0,0x20
 d60:	9081                	srli	s1,s1,0x20
 d62:	04bd                	addi	s1,s1,15
 d64:	8091                	srli	s1,s1,0x4
 d66:	0014899b          	addiw	s3,s1,1
 d6a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 d6c:	00001517          	auipc	a0,0x1
 d70:	29c53503          	ld	a0,668(a0) # 2008 <freep>
 d74:	c515                	beqz	a0,da0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 d76:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 d78:	4798                	lw	a4,8(a5)
 d7a:	02977f63          	bgeu	a4,s1,db8 <malloc+0x70>
 d7e:	8a4e                	mv	s4,s3
 d80:	0009871b          	sext.w	a4,s3
 d84:	6685                	lui	a3,0x1
 d86:	00d77363          	bgeu	a4,a3,d8c <malloc+0x44>
 d8a:	6a05                	lui	s4,0x1
 d8c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 d90:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 d94:	00001917          	auipc	s2,0x1
 d98:	27490913          	addi	s2,s2,628 # 2008 <freep>
  if(p == (char*)-1)
 d9c:	5afd                	li	s5,-1
 d9e:	a895                	j	e12 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 da0:	04001797          	auipc	a5,0x4001
 da4:	27078793          	addi	a5,a5,624 # 4002010 <base>
 da8:	00001717          	auipc	a4,0x1
 dac:	26f73023          	sd	a5,608(a4) # 2008 <freep>
 db0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 db2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 db6:	b7e1                	j	d7e <malloc+0x36>
      if(p->s.size == nunits)
 db8:	02e48c63          	beq	s1,a4,df0 <malloc+0xa8>
        p->s.size -= nunits;
 dbc:	4137073b          	subw	a4,a4,s3
 dc0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 dc2:	02071693          	slli	a3,a4,0x20
 dc6:	01c6d713          	srli	a4,a3,0x1c
 dca:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 dcc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 dd0:	00001717          	auipc	a4,0x1
 dd4:	22a73c23          	sd	a0,568(a4) # 2008 <freep>
      return (void*)(p + 1);
 dd8:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 ddc:	70e2                	ld	ra,56(sp)
 dde:	7442                	ld	s0,48(sp)
 de0:	74a2                	ld	s1,40(sp)
 de2:	7902                	ld	s2,32(sp)
 de4:	69e2                	ld	s3,24(sp)
 de6:	6a42                	ld	s4,16(sp)
 de8:	6aa2                	ld	s5,8(sp)
 dea:	6b02                	ld	s6,0(sp)
 dec:	6121                	addi	sp,sp,64
 dee:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 df0:	6398                	ld	a4,0(a5)
 df2:	e118                	sd	a4,0(a0)
 df4:	bff1                	j	dd0 <malloc+0x88>
  hp->s.size = nu;
 df6:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 dfa:	0541                	addi	a0,a0,16
 dfc:	00000097          	auipc	ra,0x0
 e00:	eca080e7          	jalr	-310(ra) # cc6 <free>
  return freep;
 e04:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 e08:	d971                	beqz	a0,ddc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e0a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e0c:	4798                	lw	a4,8(a5)
 e0e:	fa9775e3          	bgeu	a4,s1,db8 <malloc+0x70>
    if(p == freep)
 e12:	00093703          	ld	a4,0(s2)
 e16:	853e                	mv	a0,a5
 e18:	fef719e3          	bne	a4,a5,e0a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 e1c:	8552                	mv	a0,s4
 e1e:	00000097          	auipc	ra,0x0
 e22:	b58080e7          	jalr	-1192(ra) # 976 <sbrk>
  if(p == (char*)-1)
 e26:	fd5518e3          	bne	a0,s5,df6 <malloc+0xae>
        return 0;
 e2a:	4501                	li	a0,0
 e2c:	bf45                	j	ddc <malloc+0x94>
