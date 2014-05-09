#include <stdio.h>
#include <stdlib.h> 
#include <time.h>

int main(int argc,char* argv[])
{
if(argv[1] && argv[2])
{
   clock_t start,end;
   start = clock();
   FILE* fsrc;
   fsrc = fopen(argv[1],"rb");
   if(!fsrc)
   {
    printf("can't open your src file\n");
    return 1;
   }
   fseek(fsrc,0,SEEK_END);
   long filesize = ftell(fsrc);              //ftell:get the size of file
   printf("the src file's size is %d M\n",filesize/(1024*1024));
   fseek(fsrc,0,SEEK_SET); 					//  important, Make the * point to the begain of file again;
   FILE* fdest;
   fdest = fopen(argv[2],"ab");
   if(!fdest)
   {
    printf("can't create your dest file\n");
    return 1;
   }
   if(filesize>4096)                  //copy many times by block
   {
    int n = filesize/4096;// n ?
    int leavesize = filesize%4096;
    char* buf = new char[4096];
    for(int i=0;i<n;i++)
    {
     fread(buf,sizeof(char),4096,fsrc);
     fwrite(buf,sizeof(char),4096,fdest);
    }
    fread(buf,sizeof(char),leavesize,fsrc);
    fwrite(buf,sizeof(char),leavesize,fdest);
    delete buf;
    buf = 0;
   }
   else    // or copy directly.
   {
    char* buf = new char[filesize];
    fread(buf,sizeof(char),filesize,fsrc);
    fwrite(buf,sizeof(char),filesize,fdest);
    delete buf;
    buf = 0;
   }
   fseek(fdest,0,SEEK_END);
   long filesize2 = ftell(fdest);
   printf("the dest file's size is %d M\n",filesize2/(1024*1024));
   fclose(fdest);
   fclose(fsrc);
   end = clock();
   printf("the duration is %f S\n ",(double)(end - start)/1000);
}
else
   printf("no file\n");
system("pause");
return 0;
}

