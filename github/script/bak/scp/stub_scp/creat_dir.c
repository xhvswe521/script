#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define err(msg) perror(msg)


static void mkdirs(const char *dir)
{
        char tmp[1024];
        char *p;

        if (strlen(dir) == 0 || dir == NULL) {
                printf("strlen(dir) is 0 or dir is NULL.\n");
                return;
        }

        memset(tmp, 0, sizeof(tmp));
        strncpy(tmp, dir, strlen(dir));
        if (tmp[0] == '/' && tmp[1]== '/') 
                p = strchr(tmp + 1, '/');
        else 
                p = strchr(tmp, '/');

        if (p) {
                *p = '/0';
                mkdir(tmp,0777);
  chdir(tmp);
        } else {
                mkdir(tmp,0777);
                chdir(tmp);
                return;
        }

        mkdirs(p + 1);
}

int main(void)
{
        mkdirs("//home//1//2//3//4//");

        return 0;
}
