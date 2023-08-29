#ifndef QUIRC_API_H
#define QUIRC_API_H

void init(int width, int height);
void decode(int img[], int width, int height, int* out);
void destroy(int dummy);

#endif
