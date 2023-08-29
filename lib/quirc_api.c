#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "quirc.h"
#include "quirc_api.h"

struct quirc *qr;

void init(int width, int height){
    qr = quirc_new();
	if(!qr) {
        perror("Error during creation");
        exit(1);
	}
    if(quirc_resize(qr, width, height) < 0){
        perror("Error allocating");
        exit(1);
    }
}

void decode(int img[], int width, int height, int *out){
    /*
     * Receives an int output vector of size=271 (30QRs + size) and writes on it the following information:
     * v[0] = N_QRs
     * After that the following repeats N_QRs times
     * 0. corner0 X of QR i
     * 1. corner0 Y of QR i
     * 2. corner1 X of QR i
     * 3. corner1 Y of QR i
     * 4. corner2 X of QR i
     * 5. corner2 Y of QR i
     * 6. corner3 X of QR i
     * 7. corner3 Y of QR i
     * 8. QR_data
     * */
    unsigned char uCharImage[width * height];
    for(size_t i = 0; i < width * height; i++){
        uCharImage[i] = (char)img[i];
    }
    uint8_t *image;
    image = quirc_begin(qr, &width, &height);
    memcpy(image, &uCharImage, width * height * sizeof(uint8_t));
    quirc_end(qr);

    int num_codes = quirc_count(qr);
    if(num_codes > 30){
        num_codes = 30;
    }

    printf("Found %d qrs\n", num_codes);

    out[0] = num_codes;
    for(int i = 0; i < num_codes; i++){
        struct quirc_code code;
        struct quirc_data data;
        quirc_decode_error_t err;

        quirc_extract(qr, i, &code);
        /* Decoding stage */
        err = quirc_decode(&code, &data);
        if (err)
            printf("DECODE FAILED: %s\n", quirc_strerror(err));
        else
            printf("Data: %s\n", data.payload);

        int id = atoi(data.payload);

        printf(
                "points: (%d, %d), (%d, %d), (%d, %d), (%d, %d)\n",
                code.corners[0].x, code.corners[0].y,
                code.corners[1].x, code.corners[1].y,
                code.corners[2].x, code.corners[2].y,
                code.corners[3].x, code.corners[3].y
              );
        out[1 + (i*9) + 0] = code.corners[0].x;
        out[1 + (i*9) + 1] = code.corners[0].y;
        out[1 + (i*9) + 2] = code.corners[1].x;
        out[1 + (i*9) + 3] = code.corners[1].y;
        out[1 + (i*9) + 4] = code.corners[2].x;
        out[1 + (i*9) + 5] = code.corners[2].y;
        out[1 + (i*9) + 6] = code.corners[3].x;
        out[1 + (i*9) + 7] = code.corners[3].y;
        out[1 + (i*9) + 8] = id;
    }
}


void destroy(int dummy){
    if(dummy == -3)
        return;
    quirc_destroy(qr);
}
