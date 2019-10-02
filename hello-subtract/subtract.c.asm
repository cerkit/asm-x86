
subtract.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <notmain>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	c7 45 f4 05 00 00 00 	movl   $0x5,-0xc(%rbp)
   b:	c7 45 f8 02 00 00 00 	movl   $0x2,-0x8(%rbp)
  12:	8b 45 f4             	mov    -0xc(%rbp),%eax
  15:	2b 45 f8             	sub    -0x8(%rbp),%eax
  18:	89 45 fc             	mov    %eax,-0x4(%rbp)
  1b:	8b 45 fc             	mov    -0x4(%rbp),%eax
  1e:	5d                   	pop    %rbp
  1f:	c3                   	retq   
