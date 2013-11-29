all:
	gcc -m32 -o inject inject.c
	nasm -f bin -o host host.asm
	nasm -f bin -o injection injection.asm
	nasm -f bin -o shellcode shellcode.asm
	chmod +x host
	
clean:
	rm -f host inject injection shellcode *~
