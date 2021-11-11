// Dedicated to the public domain by Christopher Diggins

#ifndef YARD_IO_HPP
#define YARD_IO_HPP

int FileSize(const char* filename)
{
    int r = 0;
    FILE* f = fopen(filename, "r");
    if (f == NULL) {
        return 0;
    }
    while (!feof(f))
    {
        fgetc(f);
        ++r;
    }
    fclose(f);
    return r - 1;
}

char* ReadFile(const char* filename, int filesize)
{    
    char* result = (char*)malloc(filesize + 1);
    char* p = result;
    FILE* f = fopen(filename, "r");
    if (f == NULL)
        return NULL;
    char c = fgetc(f);
    while (!feof(f))
    {
        *p++ = c;
        c = fgetc(f);
    }        
    *p = '\0';
    fclose(f);
    return result;
}        



#endif
