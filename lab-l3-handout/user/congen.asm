
user/_congen:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <print>:
#include "user/user.h"

#define N 5

void print(const char *s)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    write(1, s, strlen(s));
   c:	00000097          	auipc	ra,0x0
  10:	13c080e7          	jalr	316(ra) # 148 <strlen>
  14:	0005061b          	sext.w	a2,a0
  18:	85a6                	mv	a1,s1
  1a:	4505                	li	a0,1
  1c:	00000097          	auipc	ra,0x0
  20:	378080e7          	jalr	888(ra) # 394 <write>
}
  24:	60e2                	ld	ra,24(sp)
  26:	6442                	ld	s0,16(sp)
  28:	64a2                	ld	s1,8(sp)
  2a:	6105                	addi	sp,sp,32
  2c:	8082                	ret

000000000000002e <forktest>:

void forktest(void)
{
  2e:	7139                	addi	sp,sp,-64
  30:	fc06                	sd	ra,56(sp)
  32:	f822                	sd	s0,48(sp)
  34:	f426                	sd	s1,40(sp)
  36:	f04a                	sd	s2,32(sp)
  38:	ec4e                	sd	s3,24(sp)
  3a:	e852                	sd	s4,16(sp)
  3c:	e456                	sd	s5,8(sp)
  3e:	e05a                	sd	s6,0(sp)
  40:	0080                	addi	s0,sp,64
    int n, pid;

    print("fork test\n");
  42:	00001517          	auipc	a0,0x1
  46:	87e50513          	addi	a0,a0,-1922 # 8c0 <malloc+0xf2>
  4a:	00000097          	auipc	ra,0x0
  4e:	fb6080e7          	jalr	-74(ra) # 0 <print>

    for (n = 0; n < N; n++)
  52:	4a01                	li	s4,0
  54:	4495                	li	s1,5
    {
        pid = fork();
  56:	00000097          	auipc	ra,0x0
  5a:	30e080e7          	jalr	782(ra) # 364 <fork>
  5e:	892a                	mv	s2,a0
        if (pid < 0)
            break;
        if (pid == 0)
  60:	00a05563          	blez	a0,6a <forktest+0x3c>
    for (n = 0; n < N; n++)
  64:	2a05                	addiw	s4,s4,1
  66:	fe9a18e3          	bne	s4,s1,56 <forktest+0x28>
            break;
    }

    for (unsigned long long i = 0; i < 1000; i++)
  6a:	4481                	li	s1,0
        {
            printf("CHILD %d: %d\n", n, i);
        }
        else
        {
            printf("PARENT: %d\n", i);
  6c:	00001b17          	auipc	s6,0x1
  70:	874b0b13          	addi	s6,s6,-1932 # 8e0 <malloc+0x112>
            printf("CHILD %d: %d\n", n, i);
  74:	00001a97          	auipc	s5,0x1
  78:	85ca8a93          	addi	s5,s5,-1956 # 8d0 <malloc+0x102>
    for (unsigned long long i = 0; i < 1000; i++)
  7c:	3e800993          	li	s3,1000
  80:	a811                	j	94 <forktest+0x66>
            printf("PARENT: %d\n", i);
  82:	85a6                	mv	a1,s1
  84:	855a                	mv	a0,s6
  86:	00000097          	auipc	ra,0x0
  8a:	690080e7          	jalr	1680(ra) # 716 <printf>
    for (unsigned long long i = 0; i < 1000; i++)
  8e:	0485                	addi	s1,s1,1
  90:	01348c63          	beq	s1,s3,a8 <forktest+0x7a>
        if (pid == 0)
  94:	fe0917e3          	bnez	s2,82 <forktest+0x54>
            printf("CHILD %d: %d\n", n, i);
  98:	8626                	mv	a2,s1
  9a:	85d2                	mv	a1,s4
  9c:	8556                	mv	a0,s5
  9e:	00000097          	auipc	ra,0x0
  a2:	678080e7          	jalr	1656(ra) # 716 <printf>
  a6:	b7e5                	j	8e <forktest+0x60>
        }
    }

    print("fork test OK\n");
  a8:	00001517          	auipc	a0,0x1
  ac:	84850513          	addi	a0,a0,-1976 # 8f0 <malloc+0x122>
  b0:	00000097          	auipc	ra,0x0
  b4:	f50080e7          	jalr	-176(ra) # 0 <print>
}
  b8:	70e2                	ld	ra,56(sp)
  ba:	7442                	ld	s0,48(sp)
  bc:	74a2                	ld	s1,40(sp)
  be:	7902                	ld	s2,32(sp)
  c0:	69e2                	ld	s3,24(sp)
  c2:	6a42                	ld	s4,16(sp)
  c4:	6aa2                	ld	s5,8(sp)
  c6:	6b02                	ld	s6,0(sp)
  c8:	6121                	addi	sp,sp,64
  ca:	8082                	ret

00000000000000cc <main>:

int main(void)
{
  cc:	1141                	addi	sp,sp,-16
  ce:	e406                	sd	ra,8(sp)
  d0:	e022                	sd	s0,0(sp)
  d2:	0800                	addi	s0,sp,16
    forktest();
  d4:	00000097          	auipc	ra,0x0
  d8:	f5a080e7          	jalr	-166(ra) # 2e <forktest>
    exit(0);
  dc:	4501                	li	a0,0
  de:	00000097          	auipc	ra,0x0
  e2:	296080e7          	jalr	662(ra) # 374 <exit>

00000000000000e6 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  e6:	1141                	addi	sp,sp,-16
  e8:	e406                	sd	ra,8(sp)
  ea:	e022                	sd	s0,0(sp)
  ec:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ee:	00000097          	auipc	ra,0x0
  f2:	fde080e7          	jalr	-34(ra) # cc <main>
  exit(0);
  f6:	4501                	li	a0,0
  f8:	00000097          	auipc	ra,0x0
  fc:	27c080e7          	jalr	636(ra) # 374 <exit>

0000000000000100 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 100:	1141                	addi	sp,sp,-16
 102:	e422                	sd	s0,8(sp)
 104:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 106:	87aa                	mv	a5,a0
 108:	0585                	addi	a1,a1,1
 10a:	0785                	addi	a5,a5,1
 10c:	fff5c703          	lbu	a4,-1(a1)
 110:	fee78fa3          	sb	a4,-1(a5)
 114:	fb75                	bnez	a4,108 <strcpy+0x8>
    ;
  return os;
}
 116:	6422                	ld	s0,8(sp)
 118:	0141                	addi	sp,sp,16
 11a:	8082                	ret

000000000000011c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 11c:	1141                	addi	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 122:	00054783          	lbu	a5,0(a0)
 126:	cb91                	beqz	a5,13a <strcmp+0x1e>
 128:	0005c703          	lbu	a4,0(a1)
 12c:	00f71763          	bne	a4,a5,13a <strcmp+0x1e>
    p++, q++;
 130:	0505                	addi	a0,a0,1
 132:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 134:	00054783          	lbu	a5,0(a0)
 138:	fbe5                	bnez	a5,128 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 13a:	0005c503          	lbu	a0,0(a1)
}
 13e:	40a7853b          	subw	a0,a5,a0
 142:	6422                	ld	s0,8(sp)
 144:	0141                	addi	sp,sp,16
 146:	8082                	ret

0000000000000148 <strlen>:

uint
strlen(const char *s)
{
 148:	1141                	addi	sp,sp,-16
 14a:	e422                	sd	s0,8(sp)
 14c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 14e:	00054783          	lbu	a5,0(a0)
 152:	cf91                	beqz	a5,16e <strlen+0x26>
 154:	0505                	addi	a0,a0,1
 156:	87aa                	mv	a5,a0
 158:	4685                	li	a3,1
 15a:	9e89                	subw	a3,a3,a0
 15c:	00f6853b          	addw	a0,a3,a5
 160:	0785                	addi	a5,a5,1
 162:	fff7c703          	lbu	a4,-1(a5)
 166:	fb7d                	bnez	a4,15c <strlen+0x14>
    ;
  return n;
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret
  for(n = 0; s[n]; n++)
 16e:	4501                	li	a0,0
 170:	bfe5                	j	168 <strlen+0x20>

0000000000000172 <memset>:

void*
memset(void *dst, int c, uint n)
{
 172:	1141                	addi	sp,sp,-16
 174:	e422                	sd	s0,8(sp)
 176:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 178:	ca19                	beqz	a2,18e <memset+0x1c>
 17a:	87aa                	mv	a5,a0
 17c:	1602                	slli	a2,a2,0x20
 17e:	9201                	srli	a2,a2,0x20
 180:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 184:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 188:	0785                	addi	a5,a5,1
 18a:	fee79de3          	bne	a5,a4,184 <memset+0x12>
  }
  return dst;
}
 18e:	6422                	ld	s0,8(sp)
 190:	0141                	addi	sp,sp,16
 192:	8082                	ret

0000000000000194 <strchr>:

char*
strchr(const char *s, char c)
{
 194:	1141                	addi	sp,sp,-16
 196:	e422                	sd	s0,8(sp)
 198:	0800                	addi	s0,sp,16
  for(; *s; s++)
 19a:	00054783          	lbu	a5,0(a0)
 19e:	cb99                	beqz	a5,1b4 <strchr+0x20>
    if(*s == c)
 1a0:	00f58763          	beq	a1,a5,1ae <strchr+0x1a>
  for(; *s; s++)
 1a4:	0505                	addi	a0,a0,1
 1a6:	00054783          	lbu	a5,0(a0)
 1aa:	fbfd                	bnez	a5,1a0 <strchr+0xc>
      return (char*)s;
  return 0;
 1ac:	4501                	li	a0,0
}
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	addi	sp,sp,16
 1b2:	8082                	ret
  return 0;
 1b4:	4501                	li	a0,0
 1b6:	bfe5                	j	1ae <strchr+0x1a>

00000000000001b8 <gets>:

char*
gets(char *buf, int max)
{
 1b8:	711d                	addi	sp,sp,-96
 1ba:	ec86                	sd	ra,88(sp)
 1bc:	e8a2                	sd	s0,80(sp)
 1be:	e4a6                	sd	s1,72(sp)
 1c0:	e0ca                	sd	s2,64(sp)
 1c2:	fc4e                	sd	s3,56(sp)
 1c4:	f852                	sd	s4,48(sp)
 1c6:	f456                	sd	s5,40(sp)
 1c8:	f05a                	sd	s6,32(sp)
 1ca:	ec5e                	sd	s7,24(sp)
 1cc:	1080                	addi	s0,sp,96
 1ce:	8baa                	mv	s7,a0
 1d0:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1d2:	892a                	mv	s2,a0
 1d4:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1d6:	4aa9                	li	s5,10
 1d8:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1da:	89a6                	mv	s3,s1
 1dc:	2485                	addiw	s1,s1,1
 1de:	0344d863          	bge	s1,s4,20e <gets+0x56>
    cc = read(0, &c, 1);
 1e2:	4605                	li	a2,1
 1e4:	faf40593          	addi	a1,s0,-81
 1e8:	4501                	li	a0,0
 1ea:	00000097          	auipc	ra,0x0
 1ee:	1a2080e7          	jalr	418(ra) # 38c <read>
    if(cc < 1)
 1f2:	00a05e63          	blez	a0,20e <gets+0x56>
    buf[i++] = c;
 1f6:	faf44783          	lbu	a5,-81(s0)
 1fa:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1fe:	01578763          	beq	a5,s5,20c <gets+0x54>
 202:	0905                	addi	s2,s2,1
 204:	fd679be3          	bne	a5,s6,1da <gets+0x22>
  for(i=0; i+1 < max; ){
 208:	89a6                	mv	s3,s1
 20a:	a011                	j	20e <gets+0x56>
 20c:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 20e:	99de                	add	s3,s3,s7
 210:	00098023          	sb	zero,0(s3)
  return buf;
}
 214:	855e                	mv	a0,s7
 216:	60e6                	ld	ra,88(sp)
 218:	6446                	ld	s0,80(sp)
 21a:	64a6                	ld	s1,72(sp)
 21c:	6906                	ld	s2,64(sp)
 21e:	79e2                	ld	s3,56(sp)
 220:	7a42                	ld	s4,48(sp)
 222:	7aa2                	ld	s5,40(sp)
 224:	7b02                	ld	s6,32(sp)
 226:	6be2                	ld	s7,24(sp)
 228:	6125                	addi	sp,sp,96
 22a:	8082                	ret

000000000000022c <stat>:

int
stat(const char *n, struct stat *st)
{
 22c:	1101                	addi	sp,sp,-32
 22e:	ec06                	sd	ra,24(sp)
 230:	e822                	sd	s0,16(sp)
 232:	e426                	sd	s1,8(sp)
 234:	e04a                	sd	s2,0(sp)
 236:	1000                	addi	s0,sp,32
 238:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23a:	4581                	li	a1,0
 23c:	00000097          	auipc	ra,0x0
 240:	178080e7          	jalr	376(ra) # 3b4 <open>
  if(fd < 0)
 244:	02054563          	bltz	a0,26e <stat+0x42>
 248:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 24a:	85ca                	mv	a1,s2
 24c:	00000097          	auipc	ra,0x0
 250:	180080e7          	jalr	384(ra) # 3cc <fstat>
 254:	892a                	mv	s2,a0
  close(fd);
 256:	8526                	mv	a0,s1
 258:	00000097          	auipc	ra,0x0
 25c:	144080e7          	jalr	324(ra) # 39c <close>
  return r;
}
 260:	854a                	mv	a0,s2
 262:	60e2                	ld	ra,24(sp)
 264:	6442                	ld	s0,16(sp)
 266:	64a2                	ld	s1,8(sp)
 268:	6902                	ld	s2,0(sp)
 26a:	6105                	addi	sp,sp,32
 26c:	8082                	ret
    return -1;
 26e:	597d                	li	s2,-1
 270:	bfc5                	j	260 <stat+0x34>

0000000000000272 <atoi>:

int
atoi(const char *s)
{
 272:	1141                	addi	sp,sp,-16
 274:	e422                	sd	s0,8(sp)
 276:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 278:	00054683          	lbu	a3,0(a0)
 27c:	fd06879b          	addiw	a5,a3,-48
 280:	0ff7f793          	zext.b	a5,a5
 284:	4625                	li	a2,9
 286:	02f66863          	bltu	a2,a5,2b6 <atoi+0x44>
 28a:	872a                	mv	a4,a0
  n = 0;
 28c:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 28e:	0705                	addi	a4,a4,1
 290:	0025179b          	slliw	a5,a0,0x2
 294:	9fa9                	addw	a5,a5,a0
 296:	0017979b          	slliw	a5,a5,0x1
 29a:	9fb5                	addw	a5,a5,a3
 29c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2a0:	00074683          	lbu	a3,0(a4)
 2a4:	fd06879b          	addiw	a5,a3,-48
 2a8:	0ff7f793          	zext.b	a5,a5
 2ac:	fef671e3          	bgeu	a2,a5,28e <atoi+0x1c>
  return n;
}
 2b0:	6422                	ld	s0,8(sp)
 2b2:	0141                	addi	sp,sp,16
 2b4:	8082                	ret
  n = 0;
 2b6:	4501                	li	a0,0
 2b8:	bfe5                	j	2b0 <atoi+0x3e>

00000000000002ba <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2ba:	1141                	addi	sp,sp,-16
 2bc:	e422                	sd	s0,8(sp)
 2be:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2c0:	02b57463          	bgeu	a0,a1,2e8 <memmove+0x2e>
    while(n-- > 0)
 2c4:	00c05f63          	blez	a2,2e2 <memmove+0x28>
 2c8:	1602                	slli	a2,a2,0x20
 2ca:	9201                	srli	a2,a2,0x20
 2cc:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2d0:	872a                	mv	a4,a0
      *dst++ = *src++;
 2d2:	0585                	addi	a1,a1,1
 2d4:	0705                	addi	a4,a4,1
 2d6:	fff5c683          	lbu	a3,-1(a1)
 2da:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2de:	fee79ae3          	bne	a5,a4,2d2 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2e2:	6422                	ld	s0,8(sp)
 2e4:	0141                	addi	sp,sp,16
 2e6:	8082                	ret
    dst += n;
 2e8:	00c50733          	add	a4,a0,a2
    src += n;
 2ec:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2ee:	fec05ae3          	blez	a2,2e2 <memmove+0x28>
 2f2:	fff6079b          	addiw	a5,a2,-1
 2f6:	1782                	slli	a5,a5,0x20
 2f8:	9381                	srli	a5,a5,0x20
 2fa:	fff7c793          	not	a5,a5
 2fe:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 300:	15fd                	addi	a1,a1,-1
 302:	177d                	addi	a4,a4,-1
 304:	0005c683          	lbu	a3,0(a1)
 308:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 30c:	fee79ae3          	bne	a5,a4,300 <memmove+0x46>
 310:	bfc9                	j	2e2 <memmove+0x28>

0000000000000312 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 318:	ca05                	beqz	a2,348 <memcmp+0x36>
 31a:	fff6069b          	addiw	a3,a2,-1
 31e:	1682                	slli	a3,a3,0x20
 320:	9281                	srli	a3,a3,0x20
 322:	0685                	addi	a3,a3,1
 324:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 326:	00054783          	lbu	a5,0(a0)
 32a:	0005c703          	lbu	a4,0(a1)
 32e:	00e79863          	bne	a5,a4,33e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 332:	0505                	addi	a0,a0,1
    p2++;
 334:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 336:	fed518e3          	bne	a0,a3,326 <memcmp+0x14>
  }
  return 0;
 33a:	4501                	li	a0,0
 33c:	a019                	j	342 <memcmp+0x30>
      return *p1 - *p2;
 33e:	40e7853b          	subw	a0,a5,a4
}
 342:	6422                	ld	s0,8(sp)
 344:	0141                	addi	sp,sp,16
 346:	8082                	ret
  return 0;
 348:	4501                	li	a0,0
 34a:	bfe5                	j	342 <memcmp+0x30>

000000000000034c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 34c:	1141                	addi	sp,sp,-16
 34e:	e406                	sd	ra,8(sp)
 350:	e022                	sd	s0,0(sp)
 352:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 354:	00000097          	auipc	ra,0x0
 358:	f66080e7          	jalr	-154(ra) # 2ba <memmove>
}
 35c:	60a2                	ld	ra,8(sp)
 35e:	6402                	ld	s0,0(sp)
 360:	0141                	addi	sp,sp,16
 362:	8082                	ret

0000000000000364 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 364:	4885                	li	a7,1
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <vfork>:
.global vfork
vfork:
 li a7, SYS_vfork
 36c:	4885                	li	a7,1
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <exit>:
.global exit
exit:
 li a7, SYS_exit
 374:	4889                	li	a7,2
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <wait>:
.global wait
wait:
 li a7, SYS_wait
 37c:	488d                	li	a7,3
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 384:	4891                	li	a7,4
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <read>:
.global read
read:
 li a7, SYS_read
 38c:	4895                	li	a7,5
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <write>:
.global write
write:
 li a7, SYS_write
 394:	48c1                	li	a7,16
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <close>:
.global close
close:
 li a7, SYS_close
 39c:	48d5                	li	a7,21
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3a4:	4899                	li	a7,6
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <exec>:
.global exec
exec:
 li a7, SYS_exec
 3ac:	489d                	li	a7,7
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <open>:
.global open
open:
 li a7, SYS_open
 3b4:	48bd                	li	a7,15
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 3bc:	48c5                	li	a7,17
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3c4:	48c9                	li	a7,18
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3cc:	48a1                	li	a7,8
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <link>:
.global link
link:
 li a7, SYS_link
 3d4:	48cd                	li	a7,19
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3dc:	48d1                	li	a7,20
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3e4:	48a5                	li	a7,9
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <dup>:
.global dup
dup:
 li a7, SYS_dup
 3ec:	48a9                	li	a7,10
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3f4:	48ad                	li	a7,11
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3fc:	48b1                	li	a7,12
 ecall
 3fe:	00000073          	ecall
 ret
 402:	8082                	ret

0000000000000404 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 404:	48b5                	li	a7,13
 ecall
 406:	00000073          	ecall
 ret
 40a:	8082                	ret

000000000000040c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 40c:	48b9                	li	a7,14
 ecall
 40e:	00000073          	ecall
 ret
 412:	8082                	ret

0000000000000414 <ps>:
.global ps
ps:
 li a7, SYS_ps
 414:	48d9                	li	a7,22
 ecall
 416:	00000073          	ecall
 ret
 41a:	8082                	ret

000000000000041c <schedls>:
.global schedls
schedls:
 li a7, SYS_schedls
 41c:	48dd                	li	a7,23
 ecall
 41e:	00000073          	ecall
 ret
 422:	8082                	ret

0000000000000424 <schedset>:
.global schedset
schedset:
 li a7, SYS_schedset
 424:	48e1                	li	a7,24
 ecall
 426:	00000073          	ecall
 ret
 42a:	8082                	ret

000000000000042c <va2pa>:
.global va2pa
va2pa:
 li a7, SYS_va2pa
 42c:	48e9                	li	a7,26
 ecall
 42e:	00000073          	ecall
 ret
 432:	8082                	ret

0000000000000434 <pfreepages>:
.global pfreepages
pfreepages:
 li a7, SYS_pfreepages
 434:	48e5                	li	a7,25
 ecall
 436:	00000073          	ecall
 ret
 43a:	8082                	ret

000000000000043c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 43c:	1101                	addi	sp,sp,-32
 43e:	ec06                	sd	ra,24(sp)
 440:	e822                	sd	s0,16(sp)
 442:	1000                	addi	s0,sp,32
 444:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 448:	4605                	li	a2,1
 44a:	fef40593          	addi	a1,s0,-17
 44e:	00000097          	auipc	ra,0x0
 452:	f46080e7          	jalr	-186(ra) # 394 <write>
}
 456:	60e2                	ld	ra,24(sp)
 458:	6442                	ld	s0,16(sp)
 45a:	6105                	addi	sp,sp,32
 45c:	8082                	ret

000000000000045e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 45e:	7139                	addi	sp,sp,-64
 460:	fc06                	sd	ra,56(sp)
 462:	f822                	sd	s0,48(sp)
 464:	f426                	sd	s1,40(sp)
 466:	f04a                	sd	s2,32(sp)
 468:	ec4e                	sd	s3,24(sp)
 46a:	0080                	addi	s0,sp,64
 46c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 46e:	c299                	beqz	a3,474 <printint+0x16>
 470:	0805c963          	bltz	a1,502 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 474:	2581                	sext.w	a1,a1
  neg = 0;
 476:	4881                	li	a7,0
 478:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 47c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 47e:	2601                	sext.w	a2,a2
 480:	00000517          	auipc	a0,0x0
 484:	4e050513          	addi	a0,a0,1248 # 960 <digits>
 488:	883a                	mv	a6,a4
 48a:	2705                	addiw	a4,a4,1
 48c:	02c5f7bb          	remuw	a5,a1,a2
 490:	1782                	slli	a5,a5,0x20
 492:	9381                	srli	a5,a5,0x20
 494:	97aa                	add	a5,a5,a0
 496:	0007c783          	lbu	a5,0(a5)
 49a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 49e:	0005879b          	sext.w	a5,a1
 4a2:	02c5d5bb          	divuw	a1,a1,a2
 4a6:	0685                	addi	a3,a3,1
 4a8:	fec7f0e3          	bgeu	a5,a2,488 <printint+0x2a>
  if(neg)
 4ac:	00088c63          	beqz	a7,4c4 <printint+0x66>
    buf[i++] = '-';
 4b0:	fd070793          	addi	a5,a4,-48
 4b4:	00878733          	add	a4,a5,s0
 4b8:	02d00793          	li	a5,45
 4bc:	fef70823          	sb	a5,-16(a4)
 4c0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4c4:	02e05863          	blez	a4,4f4 <printint+0x96>
 4c8:	fc040793          	addi	a5,s0,-64
 4cc:	00e78933          	add	s2,a5,a4
 4d0:	fff78993          	addi	s3,a5,-1
 4d4:	99ba                	add	s3,s3,a4
 4d6:	377d                	addiw	a4,a4,-1
 4d8:	1702                	slli	a4,a4,0x20
 4da:	9301                	srli	a4,a4,0x20
 4dc:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4e0:	fff94583          	lbu	a1,-1(s2)
 4e4:	8526                	mv	a0,s1
 4e6:	00000097          	auipc	ra,0x0
 4ea:	f56080e7          	jalr	-170(ra) # 43c <putc>
  while(--i >= 0)
 4ee:	197d                	addi	s2,s2,-1
 4f0:	ff3918e3          	bne	s2,s3,4e0 <printint+0x82>
}
 4f4:	70e2                	ld	ra,56(sp)
 4f6:	7442                	ld	s0,48(sp)
 4f8:	74a2                	ld	s1,40(sp)
 4fa:	7902                	ld	s2,32(sp)
 4fc:	69e2                	ld	s3,24(sp)
 4fe:	6121                	addi	sp,sp,64
 500:	8082                	ret
    x = -xx;
 502:	40b005bb          	negw	a1,a1
    neg = 1;
 506:	4885                	li	a7,1
    x = -xx;
 508:	bf85                	j	478 <printint+0x1a>

000000000000050a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 50a:	7119                	addi	sp,sp,-128
 50c:	fc86                	sd	ra,120(sp)
 50e:	f8a2                	sd	s0,112(sp)
 510:	f4a6                	sd	s1,104(sp)
 512:	f0ca                	sd	s2,96(sp)
 514:	ecce                	sd	s3,88(sp)
 516:	e8d2                	sd	s4,80(sp)
 518:	e4d6                	sd	s5,72(sp)
 51a:	e0da                	sd	s6,64(sp)
 51c:	fc5e                	sd	s7,56(sp)
 51e:	f862                	sd	s8,48(sp)
 520:	f466                	sd	s9,40(sp)
 522:	f06a                	sd	s10,32(sp)
 524:	ec6e                	sd	s11,24(sp)
 526:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 528:	0005c903          	lbu	s2,0(a1)
 52c:	18090f63          	beqz	s2,6ca <vprintf+0x1c0>
 530:	8aaa                	mv	s5,a0
 532:	8b32                	mv	s6,a2
 534:	00158493          	addi	s1,a1,1
  state = 0;
 538:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 53a:	02500a13          	li	s4,37
 53e:	4c55                	li	s8,21
 540:	00000c97          	auipc	s9,0x0
 544:	3c8c8c93          	addi	s9,s9,968 # 908 <malloc+0x13a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 548:	02800d93          	li	s11,40
  putc(fd, 'x');
 54c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 54e:	00000b97          	auipc	s7,0x0
 552:	412b8b93          	addi	s7,s7,1042 # 960 <digits>
 556:	a839                	j	574 <vprintf+0x6a>
        putc(fd, c);
 558:	85ca                	mv	a1,s2
 55a:	8556                	mv	a0,s5
 55c:	00000097          	auipc	ra,0x0
 560:	ee0080e7          	jalr	-288(ra) # 43c <putc>
 564:	a019                	j	56a <vprintf+0x60>
    } else if(state == '%'){
 566:	01498d63          	beq	s3,s4,580 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 56a:	0485                	addi	s1,s1,1
 56c:	fff4c903          	lbu	s2,-1(s1)
 570:	14090d63          	beqz	s2,6ca <vprintf+0x1c0>
    if(state == 0){
 574:	fe0999e3          	bnez	s3,566 <vprintf+0x5c>
      if(c == '%'){
 578:	ff4910e3          	bne	s2,s4,558 <vprintf+0x4e>
        state = '%';
 57c:	89d2                	mv	s3,s4
 57e:	b7f5                	j	56a <vprintf+0x60>
      if(c == 'd'){
 580:	11490c63          	beq	s2,s4,698 <vprintf+0x18e>
 584:	f9d9079b          	addiw	a5,s2,-99
 588:	0ff7f793          	zext.b	a5,a5
 58c:	10fc6e63          	bltu	s8,a5,6a8 <vprintf+0x19e>
 590:	f9d9079b          	addiw	a5,s2,-99
 594:	0ff7f713          	zext.b	a4,a5
 598:	10ec6863          	bltu	s8,a4,6a8 <vprintf+0x19e>
 59c:	00271793          	slli	a5,a4,0x2
 5a0:	97e6                	add	a5,a5,s9
 5a2:	439c                	lw	a5,0(a5)
 5a4:	97e6                	add	a5,a5,s9
 5a6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5a8:	008b0913          	addi	s2,s6,8
 5ac:	4685                	li	a3,1
 5ae:	4629                	li	a2,10
 5b0:	000b2583          	lw	a1,0(s6)
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	ea8080e7          	jalr	-344(ra) # 45e <printint>
 5be:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5c0:	4981                	li	s3,0
 5c2:	b765                	j	56a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5c4:	008b0913          	addi	s2,s6,8
 5c8:	4681                	li	a3,0
 5ca:	4629                	li	a2,10
 5cc:	000b2583          	lw	a1,0(s6)
 5d0:	8556                	mv	a0,s5
 5d2:	00000097          	auipc	ra,0x0
 5d6:	e8c080e7          	jalr	-372(ra) # 45e <printint>
 5da:	8b4a                	mv	s6,s2
      state = 0;
 5dc:	4981                	li	s3,0
 5de:	b771                	j	56a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 5e0:	008b0913          	addi	s2,s6,8
 5e4:	4681                	li	a3,0
 5e6:	866a                	mv	a2,s10
 5e8:	000b2583          	lw	a1,0(s6)
 5ec:	8556                	mv	a0,s5
 5ee:	00000097          	auipc	ra,0x0
 5f2:	e70080e7          	jalr	-400(ra) # 45e <printint>
 5f6:	8b4a                	mv	s6,s2
      state = 0;
 5f8:	4981                	li	s3,0
 5fa:	bf85                	j	56a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 5fc:	008b0793          	addi	a5,s6,8
 600:	f8f43423          	sd	a5,-120(s0)
 604:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 608:	03000593          	li	a1,48
 60c:	8556                	mv	a0,s5
 60e:	00000097          	auipc	ra,0x0
 612:	e2e080e7          	jalr	-466(ra) # 43c <putc>
  putc(fd, 'x');
 616:	07800593          	li	a1,120
 61a:	8556                	mv	a0,s5
 61c:	00000097          	auipc	ra,0x0
 620:	e20080e7          	jalr	-480(ra) # 43c <putc>
 624:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 626:	03c9d793          	srli	a5,s3,0x3c
 62a:	97de                	add	a5,a5,s7
 62c:	0007c583          	lbu	a1,0(a5)
 630:	8556                	mv	a0,s5
 632:	00000097          	auipc	ra,0x0
 636:	e0a080e7          	jalr	-502(ra) # 43c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 63a:	0992                	slli	s3,s3,0x4
 63c:	397d                	addiw	s2,s2,-1
 63e:	fe0914e3          	bnez	s2,626 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 642:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 646:	4981                	li	s3,0
 648:	b70d                	j	56a <vprintf+0x60>
        s = va_arg(ap, char*);
 64a:	008b0913          	addi	s2,s6,8
 64e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 652:	02098163          	beqz	s3,674 <vprintf+0x16a>
        while(*s != 0){
 656:	0009c583          	lbu	a1,0(s3)
 65a:	c5ad                	beqz	a1,6c4 <vprintf+0x1ba>
          putc(fd, *s);
 65c:	8556                	mv	a0,s5
 65e:	00000097          	auipc	ra,0x0
 662:	dde080e7          	jalr	-546(ra) # 43c <putc>
          s++;
 666:	0985                	addi	s3,s3,1
        while(*s != 0){
 668:	0009c583          	lbu	a1,0(s3)
 66c:	f9e5                	bnez	a1,65c <vprintf+0x152>
        s = va_arg(ap, char*);
 66e:	8b4a                	mv	s6,s2
      state = 0;
 670:	4981                	li	s3,0
 672:	bde5                	j	56a <vprintf+0x60>
          s = "(null)";
 674:	00000997          	auipc	s3,0x0
 678:	28c98993          	addi	s3,s3,652 # 900 <malloc+0x132>
        while(*s != 0){
 67c:	85ee                	mv	a1,s11
 67e:	bff9                	j	65c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 680:	008b0913          	addi	s2,s6,8
 684:	000b4583          	lbu	a1,0(s6)
 688:	8556                	mv	a0,s5
 68a:	00000097          	auipc	ra,0x0
 68e:	db2080e7          	jalr	-590(ra) # 43c <putc>
 692:	8b4a                	mv	s6,s2
      state = 0;
 694:	4981                	li	s3,0
 696:	bdd1                	j	56a <vprintf+0x60>
        putc(fd, c);
 698:	85d2                	mv	a1,s4
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	da0080e7          	jalr	-608(ra) # 43c <putc>
      state = 0;
 6a4:	4981                	li	s3,0
 6a6:	b5d1                	j	56a <vprintf+0x60>
        putc(fd, '%');
 6a8:	85d2                	mv	a1,s4
 6aa:	8556                	mv	a0,s5
 6ac:	00000097          	auipc	ra,0x0
 6b0:	d90080e7          	jalr	-624(ra) # 43c <putc>
        putc(fd, c);
 6b4:	85ca                	mv	a1,s2
 6b6:	8556                	mv	a0,s5
 6b8:	00000097          	auipc	ra,0x0
 6bc:	d84080e7          	jalr	-636(ra) # 43c <putc>
      state = 0;
 6c0:	4981                	li	s3,0
 6c2:	b565                	j	56a <vprintf+0x60>
        s = va_arg(ap, char*);
 6c4:	8b4a                	mv	s6,s2
      state = 0;
 6c6:	4981                	li	s3,0
 6c8:	b54d                	j	56a <vprintf+0x60>
    }
  }
}
 6ca:	70e6                	ld	ra,120(sp)
 6cc:	7446                	ld	s0,112(sp)
 6ce:	74a6                	ld	s1,104(sp)
 6d0:	7906                	ld	s2,96(sp)
 6d2:	69e6                	ld	s3,88(sp)
 6d4:	6a46                	ld	s4,80(sp)
 6d6:	6aa6                	ld	s5,72(sp)
 6d8:	6b06                	ld	s6,64(sp)
 6da:	7be2                	ld	s7,56(sp)
 6dc:	7c42                	ld	s8,48(sp)
 6de:	7ca2                	ld	s9,40(sp)
 6e0:	7d02                	ld	s10,32(sp)
 6e2:	6de2                	ld	s11,24(sp)
 6e4:	6109                	addi	sp,sp,128
 6e6:	8082                	ret

00000000000006e8 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 6e8:	715d                	addi	sp,sp,-80
 6ea:	ec06                	sd	ra,24(sp)
 6ec:	e822                	sd	s0,16(sp)
 6ee:	1000                	addi	s0,sp,32
 6f0:	e010                	sd	a2,0(s0)
 6f2:	e414                	sd	a3,8(s0)
 6f4:	e818                	sd	a4,16(s0)
 6f6:	ec1c                	sd	a5,24(s0)
 6f8:	03043023          	sd	a6,32(s0)
 6fc:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 700:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 704:	8622                	mv	a2,s0
 706:	00000097          	auipc	ra,0x0
 70a:	e04080e7          	jalr	-508(ra) # 50a <vprintf>
}
 70e:	60e2                	ld	ra,24(sp)
 710:	6442                	ld	s0,16(sp)
 712:	6161                	addi	sp,sp,80
 714:	8082                	ret

0000000000000716 <printf>:

void
printf(const char *fmt, ...)
{
 716:	711d                	addi	sp,sp,-96
 718:	ec06                	sd	ra,24(sp)
 71a:	e822                	sd	s0,16(sp)
 71c:	1000                	addi	s0,sp,32
 71e:	e40c                	sd	a1,8(s0)
 720:	e810                	sd	a2,16(s0)
 722:	ec14                	sd	a3,24(s0)
 724:	f018                	sd	a4,32(s0)
 726:	f41c                	sd	a5,40(s0)
 728:	03043823          	sd	a6,48(s0)
 72c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 730:	00840613          	addi	a2,s0,8
 734:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 738:	85aa                	mv	a1,a0
 73a:	4505                	li	a0,1
 73c:	00000097          	auipc	ra,0x0
 740:	dce080e7          	jalr	-562(ra) # 50a <vprintf>
}
 744:	60e2                	ld	ra,24(sp)
 746:	6442                	ld	s0,16(sp)
 748:	6125                	addi	sp,sp,96
 74a:	8082                	ret

000000000000074c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 74c:	1141                	addi	sp,sp,-16
 74e:	e422                	sd	s0,8(sp)
 750:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 752:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 756:	00001797          	auipc	a5,0x1
 75a:	8aa7b783          	ld	a5,-1878(a5) # 1000 <freep>
 75e:	a02d                	j	788 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 760:	4618                	lw	a4,8(a2)
 762:	9f2d                	addw	a4,a4,a1
 764:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 768:	6398                	ld	a4,0(a5)
 76a:	6310                	ld	a2,0(a4)
 76c:	a83d                	j	7aa <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 76e:	ff852703          	lw	a4,-8(a0)
 772:	9f31                	addw	a4,a4,a2
 774:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 776:	ff053683          	ld	a3,-16(a0)
 77a:	a091                	j	7be <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 77c:	6398                	ld	a4,0(a5)
 77e:	00e7e463          	bltu	a5,a4,786 <free+0x3a>
 782:	00e6ea63          	bltu	a3,a4,796 <free+0x4a>
{
 786:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	fed7fae3          	bgeu	a5,a3,77c <free+0x30>
 78c:	6398                	ld	a4,0(a5)
 78e:	00e6e463          	bltu	a3,a4,796 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 792:	fee7eae3          	bltu	a5,a4,786 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 796:	ff852583          	lw	a1,-8(a0)
 79a:	6390                	ld	a2,0(a5)
 79c:	02059813          	slli	a6,a1,0x20
 7a0:	01c85713          	srli	a4,a6,0x1c
 7a4:	9736                	add	a4,a4,a3
 7a6:	fae60de3          	beq	a2,a4,760 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7aa:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7ae:	4790                	lw	a2,8(a5)
 7b0:	02061593          	slli	a1,a2,0x20
 7b4:	01c5d713          	srli	a4,a1,0x1c
 7b8:	973e                	add	a4,a4,a5
 7ba:	fae68ae3          	beq	a3,a4,76e <free+0x22>
    p->s.ptr = bp->s.ptr;
 7be:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7c0:	00001717          	auipc	a4,0x1
 7c4:	84f73023          	sd	a5,-1984(a4) # 1000 <freep>
}
 7c8:	6422                	ld	s0,8(sp)
 7ca:	0141                	addi	sp,sp,16
 7cc:	8082                	ret

00000000000007ce <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7ce:	7139                	addi	sp,sp,-64
 7d0:	fc06                	sd	ra,56(sp)
 7d2:	f822                	sd	s0,48(sp)
 7d4:	f426                	sd	s1,40(sp)
 7d6:	f04a                	sd	s2,32(sp)
 7d8:	ec4e                	sd	s3,24(sp)
 7da:	e852                	sd	s4,16(sp)
 7dc:	e456                	sd	s5,8(sp)
 7de:	e05a                	sd	s6,0(sp)
 7e0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7e2:	02051493          	slli	s1,a0,0x20
 7e6:	9081                	srli	s1,s1,0x20
 7e8:	04bd                	addi	s1,s1,15
 7ea:	8091                	srli	s1,s1,0x4
 7ec:	0014899b          	addiw	s3,s1,1
 7f0:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 7f2:	00001517          	auipc	a0,0x1
 7f6:	80e53503          	ld	a0,-2034(a0) # 1000 <freep>
 7fa:	c515                	beqz	a0,826 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7fc:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7fe:	4798                	lw	a4,8(a5)
 800:	02977f63          	bgeu	a4,s1,83e <malloc+0x70>
 804:	8a4e                	mv	s4,s3
 806:	0009871b          	sext.w	a4,s3
 80a:	6685                	lui	a3,0x1
 80c:	00d77363          	bgeu	a4,a3,812 <malloc+0x44>
 810:	6a05                	lui	s4,0x1
 812:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 816:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 81a:	00000917          	auipc	s2,0x0
 81e:	7e690913          	addi	s2,s2,2022 # 1000 <freep>
  if(p == (char*)-1)
 822:	5afd                	li	s5,-1
 824:	a895                	j	898 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 826:	00000797          	auipc	a5,0x0
 82a:	7ea78793          	addi	a5,a5,2026 # 1010 <base>
 82e:	00000717          	auipc	a4,0x0
 832:	7cf73923          	sd	a5,2002(a4) # 1000 <freep>
 836:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 838:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 83c:	b7e1                	j	804 <malloc+0x36>
      if(p->s.size == nunits)
 83e:	02e48c63          	beq	s1,a4,876 <malloc+0xa8>
        p->s.size -= nunits;
 842:	4137073b          	subw	a4,a4,s3
 846:	c798                	sw	a4,8(a5)
        p += p->s.size;
 848:	02071693          	slli	a3,a4,0x20
 84c:	01c6d713          	srli	a4,a3,0x1c
 850:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 852:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 856:	00000717          	auipc	a4,0x0
 85a:	7aa73523          	sd	a0,1962(a4) # 1000 <freep>
      return (void*)(p + 1);
 85e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 862:	70e2                	ld	ra,56(sp)
 864:	7442                	ld	s0,48(sp)
 866:	74a2                	ld	s1,40(sp)
 868:	7902                	ld	s2,32(sp)
 86a:	69e2                	ld	s3,24(sp)
 86c:	6a42                	ld	s4,16(sp)
 86e:	6aa2                	ld	s5,8(sp)
 870:	6b02                	ld	s6,0(sp)
 872:	6121                	addi	sp,sp,64
 874:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 876:	6398                	ld	a4,0(a5)
 878:	e118                	sd	a4,0(a0)
 87a:	bff1                	j	856 <malloc+0x88>
  hp->s.size = nu;
 87c:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 880:	0541                	addi	a0,a0,16
 882:	00000097          	auipc	ra,0x0
 886:	eca080e7          	jalr	-310(ra) # 74c <free>
  return freep;
 88a:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 88e:	d971                	beqz	a0,862 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 890:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 892:	4798                	lw	a4,8(a5)
 894:	fa9775e3          	bgeu	a4,s1,83e <malloc+0x70>
    if(p == freep)
 898:	00093703          	ld	a4,0(s2)
 89c:	853e                	mv	a0,a5
 89e:	fef719e3          	bne	a4,a5,890 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8a2:	8552                	mv	a0,s4
 8a4:	00000097          	auipc	ra,0x0
 8a8:	b58080e7          	jalr	-1192(ra) # 3fc <sbrk>
  if(p == (char*)-1)
 8ac:	fd5518e3          	bne	a0,s5,87c <malloc+0xae>
        return 0;
 8b0:	4501                	li	a0,0
 8b2:	bf45                	j	862 <malloc+0x94>
