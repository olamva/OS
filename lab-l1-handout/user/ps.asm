
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(void)
{
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    return ola();
   8:	00000097          	auipc	ra,0x0
   c:	336080e7          	jalr	822(ra) # 33e <ola>
  10:	60a2                	ld	ra,8(sp)
  12:	6402                	ld	s0,0(sp)
  14:	0141                	addi	sp,sp,16
  16:	8082                	ret

0000000000000018 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  18:	1141                	addi	sp,sp,-16
  1a:	e406                	sd	ra,8(sp)
  1c:	e022                	sd	s0,0(sp)
  1e:	0800                	addi	s0,sp,16
  extern int main();
  main();
  20:	00000097          	auipc	ra,0x0
  24:	fe0080e7          	jalr	-32(ra) # 0 <main>
  exit(0);
  28:	4501                	li	a0,0
  2a:	00000097          	auipc	ra,0x0
  2e:	274080e7          	jalr	628(ra) # 29e <exit>

0000000000000032 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  32:	1141                	addi	sp,sp,-16
  34:	e422                	sd	s0,8(sp)
  36:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  38:	87aa                	mv	a5,a0
  3a:	0585                	addi	a1,a1,1
  3c:	0785                	addi	a5,a5,1
  3e:	fff5c703          	lbu	a4,-1(a1)
  42:	fee78fa3          	sb	a4,-1(a5)
  46:	fb75                	bnez	a4,3a <strcpy+0x8>
    ;
  return os;
}
  48:	6422                	ld	s0,8(sp)
  4a:	0141                	addi	sp,sp,16
  4c:	8082                	ret

000000000000004e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  4e:	1141                	addi	sp,sp,-16
  50:	e422                	sd	s0,8(sp)
  52:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  54:	00054783          	lbu	a5,0(a0)
  58:	cb91                	beqz	a5,6c <strcmp+0x1e>
  5a:	0005c703          	lbu	a4,0(a1)
  5e:	00f71763          	bne	a4,a5,6c <strcmp+0x1e>
    p++, q++;
  62:	0505                	addi	a0,a0,1
  64:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  66:	00054783          	lbu	a5,0(a0)
  6a:	fbe5                	bnez	a5,5a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  6c:	0005c503          	lbu	a0,0(a1)
}
  70:	40a7853b          	subw	a0,a5,a0
  74:	6422                	ld	s0,8(sp)
  76:	0141                	addi	sp,sp,16
  78:	8082                	ret

000000000000007a <strlen>:

uint
strlen(const char *s)
{
  7a:	1141                	addi	sp,sp,-16
  7c:	e422                	sd	s0,8(sp)
  7e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  80:	00054783          	lbu	a5,0(a0)
  84:	cf91                	beqz	a5,a0 <strlen+0x26>
  86:	0505                	addi	a0,a0,1
  88:	87aa                	mv	a5,a0
  8a:	4685                	li	a3,1
  8c:	9e89                	subw	a3,a3,a0
  8e:	00f6853b          	addw	a0,a3,a5
  92:	0785                	addi	a5,a5,1
  94:	fff7c703          	lbu	a4,-1(a5)
  98:	fb7d                	bnez	a4,8e <strlen+0x14>
    ;
  return n;
}
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret
  for(n = 0; s[n]; n++)
  a0:	4501                	li	a0,0
  a2:	bfe5                	j	9a <strlen+0x20>

00000000000000a4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  a4:	1141                	addi	sp,sp,-16
  a6:	e422                	sd	s0,8(sp)
  a8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  aa:	ca19                	beqz	a2,c0 <memset+0x1c>
  ac:	87aa                	mv	a5,a0
  ae:	1602                	slli	a2,a2,0x20
  b0:	9201                	srli	a2,a2,0x20
  b2:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  b6:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  ba:	0785                	addi	a5,a5,1
  bc:	fee79de3          	bne	a5,a4,b6 <memset+0x12>
  }
  return dst;
}
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret

00000000000000c6 <strchr>:

char*
strchr(const char *s, char c)
{
  c6:	1141                	addi	sp,sp,-16
  c8:	e422                	sd	s0,8(sp)
  ca:	0800                	addi	s0,sp,16
  for(; *s; s++)
  cc:	00054783          	lbu	a5,0(a0)
  d0:	cb99                	beqz	a5,e6 <strchr+0x20>
    if(*s == c)
  d2:	00f58763          	beq	a1,a5,e0 <strchr+0x1a>
  for(; *s; s++)
  d6:	0505                	addi	a0,a0,1
  d8:	00054783          	lbu	a5,0(a0)
  dc:	fbfd                	bnez	a5,d2 <strchr+0xc>
      return (char*)s;
  return 0;
  de:	4501                	li	a0,0
}
  e0:	6422                	ld	s0,8(sp)
  e2:	0141                	addi	sp,sp,16
  e4:	8082                	ret
  return 0;
  e6:	4501                	li	a0,0
  e8:	bfe5                	j	e0 <strchr+0x1a>

00000000000000ea <gets>:

char*
gets(char *buf, int max)
{
  ea:	711d                	addi	sp,sp,-96
  ec:	ec86                	sd	ra,88(sp)
  ee:	e8a2                	sd	s0,80(sp)
  f0:	e4a6                	sd	s1,72(sp)
  f2:	e0ca                	sd	s2,64(sp)
  f4:	fc4e                	sd	s3,56(sp)
  f6:	f852                	sd	s4,48(sp)
  f8:	f456                	sd	s5,40(sp)
  fa:	f05a                	sd	s6,32(sp)
  fc:	ec5e                	sd	s7,24(sp)
  fe:	1080                	addi	s0,sp,96
 100:	8baa                	mv	s7,a0
 102:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 104:	892a                	mv	s2,a0
 106:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 108:	4aa9                	li	s5,10
 10a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 10c:	89a6                	mv	s3,s1
 10e:	2485                	addiw	s1,s1,1
 110:	0344d863          	bge	s1,s4,140 <gets+0x56>
    cc = read(0, &c, 1);
 114:	4605                	li	a2,1
 116:	faf40593          	addi	a1,s0,-81
 11a:	4501                	li	a0,0
 11c:	00000097          	auipc	ra,0x0
 120:	19a080e7          	jalr	410(ra) # 2b6 <read>
    if(cc < 1)
 124:	00a05e63          	blez	a0,140 <gets+0x56>
    buf[i++] = c;
 128:	faf44783          	lbu	a5,-81(s0)
 12c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 130:	01578763          	beq	a5,s5,13e <gets+0x54>
 134:	0905                	addi	s2,s2,1
 136:	fd679be3          	bne	a5,s6,10c <gets+0x22>
  for(i=0; i+1 < max; ){
 13a:	89a6                	mv	s3,s1
 13c:	a011                	j	140 <gets+0x56>
 13e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 140:	99de                	add	s3,s3,s7
 142:	00098023          	sb	zero,0(s3)
  return buf;
}
 146:	855e                	mv	a0,s7
 148:	60e6                	ld	ra,88(sp)
 14a:	6446                	ld	s0,80(sp)
 14c:	64a6                	ld	s1,72(sp)
 14e:	6906                	ld	s2,64(sp)
 150:	79e2                	ld	s3,56(sp)
 152:	7a42                	ld	s4,48(sp)
 154:	7aa2                	ld	s5,40(sp)
 156:	7b02                	ld	s6,32(sp)
 158:	6be2                	ld	s7,24(sp)
 15a:	6125                	addi	sp,sp,96
 15c:	8082                	ret

000000000000015e <stat>:

int
stat(const char *n, struct stat *st)
{
 15e:	1101                	addi	sp,sp,-32
 160:	ec06                	sd	ra,24(sp)
 162:	e822                	sd	s0,16(sp)
 164:	e426                	sd	s1,8(sp)
 166:	e04a                	sd	s2,0(sp)
 168:	1000                	addi	s0,sp,32
 16a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 16c:	4581                	li	a1,0
 16e:	00000097          	auipc	ra,0x0
 172:	170080e7          	jalr	368(ra) # 2de <open>
  if(fd < 0)
 176:	02054563          	bltz	a0,1a0 <stat+0x42>
 17a:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 17c:	85ca                	mv	a1,s2
 17e:	00000097          	auipc	ra,0x0
 182:	178080e7          	jalr	376(ra) # 2f6 <fstat>
 186:	892a                	mv	s2,a0
  close(fd);
 188:	8526                	mv	a0,s1
 18a:	00000097          	auipc	ra,0x0
 18e:	13c080e7          	jalr	316(ra) # 2c6 <close>
  return r;
}
 192:	854a                	mv	a0,s2
 194:	60e2                	ld	ra,24(sp)
 196:	6442                	ld	s0,16(sp)
 198:	64a2                	ld	s1,8(sp)
 19a:	6902                	ld	s2,0(sp)
 19c:	6105                	addi	sp,sp,32
 19e:	8082                	ret
    return -1;
 1a0:	597d                	li	s2,-1
 1a2:	bfc5                	j	192 <stat+0x34>

00000000000001a4 <atoi>:

int
atoi(const char *s)
{
 1a4:	1141                	addi	sp,sp,-16
 1a6:	e422                	sd	s0,8(sp)
 1a8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1aa:	00054683          	lbu	a3,0(a0)
 1ae:	fd06879b          	addiw	a5,a3,-48
 1b2:	0ff7f793          	zext.b	a5,a5
 1b6:	4625                	li	a2,9
 1b8:	02f66863          	bltu	a2,a5,1e8 <atoi+0x44>
 1bc:	872a                	mv	a4,a0
  n = 0;
 1be:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1c0:	0705                	addi	a4,a4,1
 1c2:	0025179b          	slliw	a5,a0,0x2
 1c6:	9fa9                	addw	a5,a5,a0
 1c8:	0017979b          	slliw	a5,a5,0x1
 1cc:	9fb5                	addw	a5,a5,a3
 1ce:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1d2:	00074683          	lbu	a3,0(a4)
 1d6:	fd06879b          	addiw	a5,a3,-48
 1da:	0ff7f793          	zext.b	a5,a5
 1de:	fef671e3          	bgeu	a2,a5,1c0 <atoi+0x1c>
  return n;
}
 1e2:	6422                	ld	s0,8(sp)
 1e4:	0141                	addi	sp,sp,16
 1e6:	8082                	ret
  n = 0;
 1e8:	4501                	li	a0,0
 1ea:	bfe5                	j	1e2 <atoi+0x3e>

00000000000001ec <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1ec:	1141                	addi	sp,sp,-16
 1ee:	e422                	sd	s0,8(sp)
 1f0:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 1f2:	02b57463          	bgeu	a0,a1,21a <memmove+0x2e>
    while(n-- > 0)
 1f6:	00c05f63          	blez	a2,214 <memmove+0x28>
 1fa:	1602                	slli	a2,a2,0x20
 1fc:	9201                	srli	a2,a2,0x20
 1fe:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 202:	872a                	mv	a4,a0
      *dst++ = *src++;
 204:	0585                	addi	a1,a1,1
 206:	0705                	addi	a4,a4,1
 208:	fff5c683          	lbu	a3,-1(a1)
 20c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 210:	fee79ae3          	bne	a5,a4,204 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 214:	6422                	ld	s0,8(sp)
 216:	0141                	addi	sp,sp,16
 218:	8082                	ret
    dst += n;
 21a:	00c50733          	add	a4,a0,a2
    src += n;
 21e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 220:	fec05ae3          	blez	a2,214 <memmove+0x28>
 224:	fff6079b          	addiw	a5,a2,-1
 228:	1782                	slli	a5,a5,0x20
 22a:	9381                	srli	a5,a5,0x20
 22c:	fff7c793          	not	a5,a5
 230:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 232:	15fd                	addi	a1,a1,-1
 234:	177d                	addi	a4,a4,-1
 236:	0005c683          	lbu	a3,0(a1)
 23a:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 23e:	fee79ae3          	bne	a5,a4,232 <memmove+0x46>
 242:	bfc9                	j	214 <memmove+0x28>

0000000000000244 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 244:	1141                	addi	sp,sp,-16
 246:	e422                	sd	s0,8(sp)
 248:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 24a:	ca05                	beqz	a2,27a <memcmp+0x36>
 24c:	fff6069b          	addiw	a3,a2,-1
 250:	1682                	slli	a3,a3,0x20
 252:	9281                	srli	a3,a3,0x20
 254:	0685                	addi	a3,a3,1
 256:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 258:	00054783          	lbu	a5,0(a0)
 25c:	0005c703          	lbu	a4,0(a1)
 260:	00e79863          	bne	a5,a4,270 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 264:	0505                	addi	a0,a0,1
    p2++;
 266:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 268:	fed518e3          	bne	a0,a3,258 <memcmp+0x14>
  }
  return 0;
 26c:	4501                	li	a0,0
 26e:	a019                	j	274 <memcmp+0x30>
      return *p1 - *p2;
 270:	40e7853b          	subw	a0,a5,a4
}
 274:	6422                	ld	s0,8(sp)
 276:	0141                	addi	sp,sp,16
 278:	8082                	ret
  return 0;
 27a:	4501                	li	a0,0
 27c:	bfe5                	j	274 <memcmp+0x30>

000000000000027e <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 27e:	1141                	addi	sp,sp,-16
 280:	e406                	sd	ra,8(sp)
 282:	e022                	sd	s0,0(sp)
 284:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 286:	00000097          	auipc	ra,0x0
 28a:	f66080e7          	jalr	-154(ra) # 1ec <memmove>
}
 28e:	60a2                	ld	ra,8(sp)
 290:	6402                	ld	s0,0(sp)
 292:	0141                	addi	sp,sp,16
 294:	8082                	ret

0000000000000296 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 296:	4885                	li	a7,1
 ecall
 298:	00000073          	ecall
 ret
 29c:	8082                	ret

000000000000029e <exit>:
.global exit
exit:
 li a7, SYS_exit
 29e:	4889                	li	a7,2
 ecall
 2a0:	00000073          	ecall
 ret
 2a4:	8082                	ret

00000000000002a6 <wait>:
.global wait
wait:
 li a7, SYS_wait
 2a6:	488d                	li	a7,3
 ecall
 2a8:	00000073          	ecall
 ret
 2ac:	8082                	ret

00000000000002ae <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2ae:	4891                	li	a7,4
 ecall
 2b0:	00000073          	ecall
 ret
 2b4:	8082                	ret

00000000000002b6 <read>:
.global read
read:
 li a7, SYS_read
 2b6:	4895                	li	a7,5
 ecall
 2b8:	00000073          	ecall
 ret
 2bc:	8082                	ret

00000000000002be <write>:
.global write
write:
 li a7, SYS_write
 2be:	48c1                	li	a7,16
 ecall
 2c0:	00000073          	ecall
 ret
 2c4:	8082                	ret

00000000000002c6 <close>:
.global close
close:
 li a7, SYS_close
 2c6:	48d5                	li	a7,21
 ecall
 2c8:	00000073          	ecall
 ret
 2cc:	8082                	ret

00000000000002ce <kill>:
.global kill
kill:
 li a7, SYS_kill
 2ce:	4899                	li	a7,6
 ecall
 2d0:	00000073          	ecall
 ret
 2d4:	8082                	ret

00000000000002d6 <exec>:
.global exec
exec:
 li a7, SYS_exec
 2d6:	489d                	li	a7,7
 ecall
 2d8:	00000073          	ecall
 ret
 2dc:	8082                	ret

00000000000002de <open>:
.global open
open:
 li a7, SYS_open
 2de:	48bd                	li	a7,15
 ecall
 2e0:	00000073          	ecall
 ret
 2e4:	8082                	ret

00000000000002e6 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 2e6:	48c5                	li	a7,17
 ecall
 2e8:	00000073          	ecall
 ret
 2ec:	8082                	ret

00000000000002ee <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 2ee:	48c9                	li	a7,18
 ecall
 2f0:	00000073          	ecall
 ret
 2f4:	8082                	ret

00000000000002f6 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 2f6:	48a1                	li	a7,8
 ecall
 2f8:	00000073          	ecall
 ret
 2fc:	8082                	ret

00000000000002fe <link>:
.global link
link:
 li a7, SYS_link
 2fe:	48cd                	li	a7,19
 ecall
 300:	00000073          	ecall
 ret
 304:	8082                	ret

0000000000000306 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 306:	48d1                	li	a7,20
 ecall
 308:	00000073          	ecall
 ret
 30c:	8082                	ret

000000000000030e <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 30e:	48a5                	li	a7,9
 ecall
 310:	00000073          	ecall
 ret
 314:	8082                	ret

0000000000000316 <dup>:
.global dup
dup:
 li a7, SYS_dup
 316:	48a9                	li	a7,10
 ecall
 318:	00000073          	ecall
 ret
 31c:	8082                	ret

000000000000031e <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 31e:	48ad                	li	a7,11
 ecall
 320:	00000073          	ecall
 ret
 324:	8082                	ret

0000000000000326 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 326:	48b1                	li	a7,12
 ecall
 328:	00000073          	ecall
 ret
 32c:	8082                	ret

000000000000032e <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 32e:	48b5                	li	a7,13
 ecall
 330:	00000073          	ecall
 ret
 334:	8082                	ret

0000000000000336 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 336:	48b9                	li	a7,14
 ecall
 338:	00000073          	ecall
 ret
 33c:	8082                	ret

000000000000033e <ola>:
.global ola
ola:
 li a7, SYS_ola
 33e:	48d9                	li	a7,22
 ecall
 340:	00000073          	ecall
 ret
 344:	8082                	ret

0000000000000346 <putc>:
  
static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 346:	1101                	addi	sp,sp,-32
 348:	ec06                	sd	ra,24(sp)
 34a:	e822                	sd	s0,16(sp)
 34c:	1000                	addi	s0,sp,32
 34e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 352:	4605                	li	a2,1
 354:	fef40593          	addi	a1,s0,-17
 358:	00000097          	auipc	ra,0x0
 35c:	f66080e7          	jalr	-154(ra) # 2be <write>
}
 360:	60e2                	ld	ra,24(sp)
 362:	6442                	ld	s0,16(sp)
 364:	6105                	addi	sp,sp,32
 366:	8082                	ret

0000000000000368 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 368:	7139                	addi	sp,sp,-64
 36a:	fc06                	sd	ra,56(sp)
 36c:	f822                	sd	s0,48(sp)
 36e:	f426                	sd	s1,40(sp)
 370:	f04a                	sd	s2,32(sp)
 372:	ec4e                	sd	s3,24(sp)
 374:	0080                	addi	s0,sp,64
 376:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 378:	c299                	beqz	a3,37e <printint+0x16>
 37a:	0805c963          	bltz	a1,40c <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 37e:	2581                	sext.w	a1,a1
  neg = 0;
 380:	4881                	li	a7,0
 382:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 386:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 388:	2601                	sext.w	a2,a2
 38a:	00000517          	auipc	a0,0x0
 38e:	49650513          	addi	a0,a0,1174 # 820 <digits>
 392:	883a                	mv	a6,a4
 394:	2705                	addiw	a4,a4,1
 396:	02c5f7bb          	remuw	a5,a1,a2
 39a:	1782                	slli	a5,a5,0x20
 39c:	9381                	srli	a5,a5,0x20
 39e:	97aa                	add	a5,a5,a0
 3a0:	0007c783          	lbu	a5,0(a5)
 3a4:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3a8:	0005879b          	sext.w	a5,a1
 3ac:	02c5d5bb          	divuw	a1,a1,a2
 3b0:	0685                	addi	a3,a3,1
 3b2:	fec7f0e3          	bgeu	a5,a2,392 <printint+0x2a>
  if(neg)
 3b6:	00088c63          	beqz	a7,3ce <printint+0x66>
    buf[i++] = '-';
 3ba:	fd070793          	addi	a5,a4,-48
 3be:	00878733          	add	a4,a5,s0
 3c2:	02d00793          	li	a5,45
 3c6:	fef70823          	sb	a5,-16(a4)
 3ca:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3ce:	02e05863          	blez	a4,3fe <printint+0x96>
 3d2:	fc040793          	addi	a5,s0,-64
 3d6:	00e78933          	add	s2,a5,a4
 3da:	fff78993          	addi	s3,a5,-1
 3de:	99ba                	add	s3,s3,a4
 3e0:	377d                	addiw	a4,a4,-1
 3e2:	1702                	slli	a4,a4,0x20
 3e4:	9301                	srli	a4,a4,0x20
 3e6:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 3ea:	fff94583          	lbu	a1,-1(s2)
 3ee:	8526                	mv	a0,s1
 3f0:	00000097          	auipc	ra,0x0
 3f4:	f56080e7          	jalr	-170(ra) # 346 <putc>
  while(--i >= 0)
 3f8:	197d                	addi	s2,s2,-1
 3fa:	ff3918e3          	bne	s2,s3,3ea <printint+0x82>
}
 3fe:	70e2                	ld	ra,56(sp)
 400:	7442                	ld	s0,48(sp)
 402:	74a2                	ld	s1,40(sp)
 404:	7902                	ld	s2,32(sp)
 406:	69e2                	ld	s3,24(sp)
 408:	6121                	addi	sp,sp,64
 40a:	8082                	ret
    x = -xx;
 40c:	40b005bb          	negw	a1,a1
    neg = 1;
 410:	4885                	li	a7,1
    x = -xx;
 412:	bf85                	j	382 <printint+0x1a>

0000000000000414 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 414:	7119                	addi	sp,sp,-128
 416:	fc86                	sd	ra,120(sp)
 418:	f8a2                	sd	s0,112(sp)
 41a:	f4a6                	sd	s1,104(sp)
 41c:	f0ca                	sd	s2,96(sp)
 41e:	ecce                	sd	s3,88(sp)
 420:	e8d2                	sd	s4,80(sp)
 422:	e4d6                	sd	s5,72(sp)
 424:	e0da                	sd	s6,64(sp)
 426:	fc5e                	sd	s7,56(sp)
 428:	f862                	sd	s8,48(sp)
 42a:	f466                	sd	s9,40(sp)
 42c:	f06a                	sd	s10,32(sp)
 42e:	ec6e                	sd	s11,24(sp)
 430:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 432:	0005c903          	lbu	s2,0(a1)
 436:	18090f63          	beqz	s2,5d4 <vprintf+0x1c0>
 43a:	8aaa                	mv	s5,a0
 43c:	8b32                	mv	s6,a2
 43e:	00158493          	addi	s1,a1,1
  state = 0;
 442:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 444:	02500a13          	li	s4,37
 448:	4c55                	li	s8,21
 44a:	00000c97          	auipc	s9,0x0
 44e:	37ec8c93          	addi	s9,s9,894 # 7c8 <malloc+0xf0>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 452:	02800d93          	li	s11,40
  putc(fd, 'x');
 456:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 458:	00000b97          	auipc	s7,0x0
 45c:	3c8b8b93          	addi	s7,s7,968 # 820 <digits>
 460:	a839                	j	47e <vprintf+0x6a>
        putc(fd, c);
 462:	85ca                	mv	a1,s2
 464:	8556                	mv	a0,s5
 466:	00000097          	auipc	ra,0x0
 46a:	ee0080e7          	jalr	-288(ra) # 346 <putc>
 46e:	a019                	j	474 <vprintf+0x60>
    } else if(state == '%'){
 470:	01498d63          	beq	s3,s4,48a <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 474:	0485                	addi	s1,s1,1
 476:	fff4c903          	lbu	s2,-1(s1)
 47a:	14090d63          	beqz	s2,5d4 <vprintf+0x1c0>
    if(state == 0){
 47e:	fe0999e3          	bnez	s3,470 <vprintf+0x5c>
      if(c == '%'){
 482:	ff4910e3          	bne	s2,s4,462 <vprintf+0x4e>
        state = '%';
 486:	89d2                	mv	s3,s4
 488:	b7f5                	j	474 <vprintf+0x60>
      if(c == 'd'){
 48a:	11490c63          	beq	s2,s4,5a2 <vprintf+0x18e>
 48e:	f9d9079b          	addiw	a5,s2,-99
 492:	0ff7f793          	zext.b	a5,a5
 496:	10fc6e63          	bltu	s8,a5,5b2 <vprintf+0x19e>
 49a:	f9d9079b          	addiw	a5,s2,-99
 49e:	0ff7f713          	zext.b	a4,a5
 4a2:	10ec6863          	bltu	s8,a4,5b2 <vprintf+0x19e>
 4a6:	00271793          	slli	a5,a4,0x2
 4aa:	97e6                	add	a5,a5,s9
 4ac:	439c                	lw	a5,0(a5)
 4ae:	97e6                	add	a5,a5,s9
 4b0:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4b2:	008b0913          	addi	s2,s6,8
 4b6:	4685                	li	a3,1
 4b8:	4629                	li	a2,10
 4ba:	000b2583          	lw	a1,0(s6)
 4be:	8556                	mv	a0,s5
 4c0:	00000097          	auipc	ra,0x0
 4c4:	ea8080e7          	jalr	-344(ra) # 368 <printint>
 4c8:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4ca:	4981                	li	s3,0
 4cc:	b765                	j	474 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4ce:	008b0913          	addi	s2,s6,8
 4d2:	4681                	li	a3,0
 4d4:	4629                	li	a2,10
 4d6:	000b2583          	lw	a1,0(s6)
 4da:	8556                	mv	a0,s5
 4dc:	00000097          	auipc	ra,0x0
 4e0:	e8c080e7          	jalr	-372(ra) # 368 <printint>
 4e4:	8b4a                	mv	s6,s2
      state = 0;
 4e6:	4981                	li	s3,0
 4e8:	b771                	j	474 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 4ea:	008b0913          	addi	s2,s6,8
 4ee:	4681                	li	a3,0
 4f0:	866a                	mv	a2,s10
 4f2:	000b2583          	lw	a1,0(s6)
 4f6:	8556                	mv	a0,s5
 4f8:	00000097          	auipc	ra,0x0
 4fc:	e70080e7          	jalr	-400(ra) # 368 <printint>
 500:	8b4a                	mv	s6,s2
      state = 0;
 502:	4981                	li	s3,0
 504:	bf85                	j	474 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 506:	008b0793          	addi	a5,s6,8
 50a:	f8f43423          	sd	a5,-120(s0)
 50e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 512:	03000593          	li	a1,48
 516:	8556                	mv	a0,s5
 518:	00000097          	auipc	ra,0x0
 51c:	e2e080e7          	jalr	-466(ra) # 346 <putc>
  putc(fd, 'x');
 520:	07800593          	li	a1,120
 524:	8556                	mv	a0,s5
 526:	00000097          	auipc	ra,0x0
 52a:	e20080e7          	jalr	-480(ra) # 346 <putc>
 52e:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 530:	03c9d793          	srli	a5,s3,0x3c
 534:	97de                	add	a5,a5,s7
 536:	0007c583          	lbu	a1,0(a5)
 53a:	8556                	mv	a0,s5
 53c:	00000097          	auipc	ra,0x0
 540:	e0a080e7          	jalr	-502(ra) # 346 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 544:	0992                	slli	s3,s3,0x4
 546:	397d                	addiw	s2,s2,-1
 548:	fe0914e3          	bnez	s2,530 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 54c:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 550:	4981                	li	s3,0
 552:	b70d                	j	474 <vprintf+0x60>
        s = va_arg(ap, char*);
 554:	008b0913          	addi	s2,s6,8
 558:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 55c:	02098163          	beqz	s3,57e <vprintf+0x16a>
        while(*s != 0){
 560:	0009c583          	lbu	a1,0(s3)
 564:	c5ad                	beqz	a1,5ce <vprintf+0x1ba>
          putc(fd, *s);
 566:	8556                	mv	a0,s5
 568:	00000097          	auipc	ra,0x0
 56c:	dde080e7          	jalr	-546(ra) # 346 <putc>
          s++;
 570:	0985                	addi	s3,s3,1
        while(*s != 0){
 572:	0009c583          	lbu	a1,0(s3)
 576:	f9e5                	bnez	a1,566 <vprintf+0x152>
        s = va_arg(ap, char*);
 578:	8b4a                	mv	s6,s2
      state = 0;
 57a:	4981                	li	s3,0
 57c:	bde5                	j	474 <vprintf+0x60>
          s = "(null)";
 57e:	00000997          	auipc	s3,0x0
 582:	24298993          	addi	s3,s3,578 # 7c0 <malloc+0xe8>
        while(*s != 0){
 586:	85ee                	mv	a1,s11
 588:	bff9                	j	566 <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 58a:	008b0913          	addi	s2,s6,8
 58e:	000b4583          	lbu	a1,0(s6)
 592:	8556                	mv	a0,s5
 594:	00000097          	auipc	ra,0x0
 598:	db2080e7          	jalr	-590(ra) # 346 <putc>
 59c:	8b4a                	mv	s6,s2
      state = 0;
 59e:	4981                	li	s3,0
 5a0:	bdd1                	j	474 <vprintf+0x60>
        putc(fd, c);
 5a2:	85d2                	mv	a1,s4
 5a4:	8556                	mv	a0,s5
 5a6:	00000097          	auipc	ra,0x0
 5aa:	da0080e7          	jalr	-608(ra) # 346 <putc>
      state = 0;
 5ae:	4981                	li	s3,0
 5b0:	b5d1                	j	474 <vprintf+0x60>
        putc(fd, '%');
 5b2:	85d2                	mv	a1,s4
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	d90080e7          	jalr	-624(ra) # 346 <putc>
        putc(fd, c);
 5be:	85ca                	mv	a1,s2
 5c0:	8556                	mv	a0,s5
 5c2:	00000097          	auipc	ra,0x0
 5c6:	d84080e7          	jalr	-636(ra) # 346 <putc>
      state = 0;
 5ca:	4981                	li	s3,0
 5cc:	b565                	j	474 <vprintf+0x60>
        s = va_arg(ap, char*);
 5ce:	8b4a                	mv	s6,s2
      state = 0;
 5d0:	4981                	li	s3,0
 5d2:	b54d                	j	474 <vprintf+0x60>
    }
  }
}
 5d4:	70e6                	ld	ra,120(sp)
 5d6:	7446                	ld	s0,112(sp)
 5d8:	74a6                	ld	s1,104(sp)
 5da:	7906                	ld	s2,96(sp)
 5dc:	69e6                	ld	s3,88(sp)
 5de:	6a46                	ld	s4,80(sp)
 5e0:	6aa6                	ld	s5,72(sp)
 5e2:	6b06                	ld	s6,64(sp)
 5e4:	7be2                	ld	s7,56(sp)
 5e6:	7c42                	ld	s8,48(sp)
 5e8:	7ca2                	ld	s9,40(sp)
 5ea:	7d02                	ld	s10,32(sp)
 5ec:	6de2                	ld	s11,24(sp)
 5ee:	6109                	addi	sp,sp,128
 5f0:	8082                	ret

00000000000005f2 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 5f2:	715d                	addi	sp,sp,-80
 5f4:	ec06                	sd	ra,24(sp)
 5f6:	e822                	sd	s0,16(sp)
 5f8:	1000                	addi	s0,sp,32
 5fa:	e010                	sd	a2,0(s0)
 5fc:	e414                	sd	a3,8(s0)
 5fe:	e818                	sd	a4,16(s0)
 600:	ec1c                	sd	a5,24(s0)
 602:	03043023          	sd	a6,32(s0)
 606:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 60a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 60e:	8622                	mv	a2,s0
 610:	00000097          	auipc	ra,0x0
 614:	e04080e7          	jalr	-508(ra) # 414 <vprintf>
}
 618:	60e2                	ld	ra,24(sp)
 61a:	6442                	ld	s0,16(sp)
 61c:	6161                	addi	sp,sp,80
 61e:	8082                	ret

0000000000000620 <printf>:

void
printf(const char *fmt, ...)
{
 620:	711d                	addi	sp,sp,-96
 622:	ec06                	sd	ra,24(sp)
 624:	e822                	sd	s0,16(sp)
 626:	1000                	addi	s0,sp,32
 628:	e40c                	sd	a1,8(s0)
 62a:	e810                	sd	a2,16(s0)
 62c:	ec14                	sd	a3,24(s0)
 62e:	f018                	sd	a4,32(s0)
 630:	f41c                	sd	a5,40(s0)
 632:	03043823          	sd	a6,48(s0)
 636:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 63a:	00840613          	addi	a2,s0,8
 63e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 642:	85aa                	mv	a1,a0
 644:	4505                	li	a0,1
 646:	00000097          	auipc	ra,0x0
 64a:	dce080e7          	jalr	-562(ra) # 414 <vprintf>
}
 64e:	60e2                	ld	ra,24(sp)
 650:	6442                	ld	s0,16(sp)
 652:	6125                	addi	sp,sp,96
 654:	8082                	ret

0000000000000656 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 656:	1141                	addi	sp,sp,-16
 658:	e422                	sd	s0,8(sp)
 65a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 65c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 660:	00001797          	auipc	a5,0x1
 664:	9a07b783          	ld	a5,-1632(a5) # 1000 <freep>
 668:	a02d                	j	692 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 66a:	4618                	lw	a4,8(a2)
 66c:	9f2d                	addw	a4,a4,a1
 66e:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 672:	6398                	ld	a4,0(a5)
 674:	6310                	ld	a2,0(a4)
 676:	a83d                	j	6b4 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 678:	ff852703          	lw	a4,-8(a0)
 67c:	9f31                	addw	a4,a4,a2
 67e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 680:	ff053683          	ld	a3,-16(a0)
 684:	a091                	j	6c8 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 686:	6398                	ld	a4,0(a5)
 688:	00e7e463          	bltu	a5,a4,690 <free+0x3a>
 68c:	00e6ea63          	bltu	a3,a4,6a0 <free+0x4a>
{
 690:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 692:	fed7fae3          	bgeu	a5,a3,686 <free+0x30>
 696:	6398                	ld	a4,0(a5)
 698:	00e6e463          	bltu	a3,a4,6a0 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 69c:	fee7eae3          	bltu	a5,a4,690 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6a0:	ff852583          	lw	a1,-8(a0)
 6a4:	6390                	ld	a2,0(a5)
 6a6:	02059813          	slli	a6,a1,0x20
 6aa:	01c85713          	srli	a4,a6,0x1c
 6ae:	9736                	add	a4,a4,a3
 6b0:	fae60de3          	beq	a2,a4,66a <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6b4:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6b8:	4790                	lw	a2,8(a5)
 6ba:	02061593          	slli	a1,a2,0x20
 6be:	01c5d713          	srli	a4,a1,0x1c
 6c2:	973e                	add	a4,a4,a5
 6c4:	fae68ae3          	beq	a3,a4,678 <free+0x22>
    p->s.ptr = bp->s.ptr;
 6c8:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6ca:	00001717          	auipc	a4,0x1
 6ce:	92f73b23          	sd	a5,-1738(a4) # 1000 <freep>
}
 6d2:	6422                	ld	s0,8(sp)
 6d4:	0141                	addi	sp,sp,16
 6d6:	8082                	ret

00000000000006d8 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6d8:	7139                	addi	sp,sp,-64
 6da:	fc06                	sd	ra,56(sp)
 6dc:	f822                	sd	s0,48(sp)
 6de:	f426                	sd	s1,40(sp)
 6e0:	f04a                	sd	s2,32(sp)
 6e2:	ec4e                	sd	s3,24(sp)
 6e4:	e852                	sd	s4,16(sp)
 6e6:	e456                	sd	s5,8(sp)
 6e8:	e05a                	sd	s6,0(sp)
 6ea:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6ec:	02051493          	slli	s1,a0,0x20
 6f0:	9081                	srli	s1,s1,0x20
 6f2:	04bd                	addi	s1,s1,15
 6f4:	8091                	srli	s1,s1,0x4
 6f6:	0014899b          	addiw	s3,s1,1
 6fa:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 6fc:	00001517          	auipc	a0,0x1
 700:	90453503          	ld	a0,-1788(a0) # 1000 <freep>
 704:	c515                	beqz	a0,730 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 706:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 708:	4798                	lw	a4,8(a5)
 70a:	02977f63          	bgeu	a4,s1,748 <malloc+0x70>
 70e:	8a4e                	mv	s4,s3
 710:	0009871b          	sext.w	a4,s3
 714:	6685                	lui	a3,0x1
 716:	00d77363          	bgeu	a4,a3,71c <malloc+0x44>
 71a:	6a05                	lui	s4,0x1
 71c:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 720:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 724:	00001917          	auipc	s2,0x1
 728:	8dc90913          	addi	s2,s2,-1828 # 1000 <freep>
  if(p == (char*)-1)
 72c:	5afd                	li	s5,-1
 72e:	a895                	j	7a2 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 730:	00001797          	auipc	a5,0x1
 734:	8e078793          	addi	a5,a5,-1824 # 1010 <base>
 738:	00001717          	auipc	a4,0x1
 73c:	8cf73423          	sd	a5,-1848(a4) # 1000 <freep>
 740:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 742:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 746:	b7e1                	j	70e <malloc+0x36>
      if(p->s.size == nunits)
 748:	02e48c63          	beq	s1,a4,780 <malloc+0xa8>
        p->s.size -= nunits;
 74c:	4137073b          	subw	a4,a4,s3
 750:	c798                	sw	a4,8(a5)
        p += p->s.size;
 752:	02071693          	slli	a3,a4,0x20
 756:	01c6d713          	srli	a4,a3,0x1c
 75a:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 75c:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 760:	00001717          	auipc	a4,0x1
 764:	8aa73023          	sd	a0,-1888(a4) # 1000 <freep>
      return (void*)(p + 1);
 768:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 76c:	70e2                	ld	ra,56(sp)
 76e:	7442                	ld	s0,48(sp)
 770:	74a2                	ld	s1,40(sp)
 772:	7902                	ld	s2,32(sp)
 774:	69e2                	ld	s3,24(sp)
 776:	6a42                	ld	s4,16(sp)
 778:	6aa2                	ld	s5,8(sp)
 77a:	6b02                	ld	s6,0(sp)
 77c:	6121                	addi	sp,sp,64
 77e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 780:	6398                	ld	a4,0(a5)
 782:	e118                	sd	a4,0(a0)
 784:	bff1                	j	760 <malloc+0x88>
  hp->s.size = nu;
 786:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 78a:	0541                	addi	a0,a0,16
 78c:	00000097          	auipc	ra,0x0
 790:	eca080e7          	jalr	-310(ra) # 656 <free>
  return freep;
 794:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 798:	d971                	beqz	a0,76c <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 79a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 79c:	4798                	lw	a4,8(a5)
 79e:	fa9775e3          	bgeu	a4,s1,748 <malloc+0x70>
    if(p == freep)
 7a2:	00093703          	ld	a4,0(s2)
 7a6:	853e                	mv	a0,a5
 7a8:	fef719e3          	bne	a4,a5,79a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7ac:	8552                	mv	a0,s4
 7ae:	00000097          	auipc	ra,0x0
 7b2:	b78080e7          	jalr	-1160(ra) # 326 <sbrk>
  if(p == (char*)-1)
 7b6:	fd5518e3          	bne	a0,s5,786 <malloc+0xae>
        return 0;
 7ba:	4501                	li	a0,0
 7bc:	bf45                	j	76c <malloc+0x94>
