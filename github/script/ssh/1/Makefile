ssh2_exec:ssh2_exec.o
	gcc -o ssh2_exec -g ssh2_exec.o -lssh2 
ssh2_exec.o:ssh2_exec.c
	gcc -o ssh2_exec.o -c ssh2_exec.c -I/nas/home/quwang/c/lib/libssh2-1.4.3/src -Wall
clean:
	rm ssh2_exec.o ssh2_exec
