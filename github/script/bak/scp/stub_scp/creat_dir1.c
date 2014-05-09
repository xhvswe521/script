#include<stdio.h>
#include<stdlib.h>
#include<string.h>
int CreateDir(const   char   *sPathName)    
{    
   char   DirName[1024];    
   strcpy(DirName,   sPathName);    
   int   i,len   =   strlen(DirName);    
   if(DirName[len-1]!='/')    
   strcat(DirName,   "/");      
   len   =   strlen(DirName);     
   for(i=1;i<len;i++)    
   {    
      if(DirName[i]=='/')    
       {    
          DirName[i]   =   0;    
          if(access(DirName,NULL)!=0)     		//check file :exit return 0;noexit return 1    
           {    
               if(mkdir(DirName,0755)==-1)    		//sucess,return 0;or -1
                 {     
                      perror("mkdir   error");     
                      return   -1;     
                 }    
           }    
          DirName[i]   =   '/';    
       }    
    }    
    return   0;    
 }

int main(void)
{
        CreateDir("/nas/home/1/2/3/4/");

        return 0;
}
