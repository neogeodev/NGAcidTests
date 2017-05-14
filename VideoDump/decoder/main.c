#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <unistd.h>

typedef struct {
   unsigned short int type;                 /* Magic identifier            */
   unsigned int size;                       /* File size in bytes          */
   unsigned short int reserved1, reserved2;
   unsigned int offset;                     /* Offset to image data, bytes */
} header_t;

typedef struct {
   unsigned int size;               /* Header size in bytes      */
   int width, height;                /* Width and height of image */
   unsigned short int planes;       /* Number of colour planes   */
   unsigned short int bits;         /* Bits per pixel            */
   unsigned int compression;        /* Compression type          */
   unsigned int imagesize;          /* Image size in bytes       */
   int xresolution,yresolution;     /* Pixels per meter          */
   unsigned int ncolours;           /* Number of colours         */
   unsigned int importantcolors;   	/* Important colours         */
} infoheader_t;

header_t bmp_header;
infoheader_t bmp_info;
unsigned char * data;

unsigned char str_black[] = "BLACK";
unsigned char str_white[] = "WHITE";
unsigned char str_red[] = "RED";
unsigned char str_green[] = "GREEN";
unsigned char str_blue[] = "BLUE";
unsigned char str_error[] = "ERROR";

unsigned char * color_str[6] = {
	str_black,
	str_red,
	str_green,
	str_blue,
	str_white,
	str_error
};

unsigned char getcolor(unsigned int x, unsigned int y) {
	unsigned int padded;
	unsigned long int bx, by;
	unsigned int red, green, blue;
	unsigned long int lum;
	
	padded = ((bmp_info.width * 3) + 3) & (~3);
	bx = (x * 3) + 0x36;
	by = (bmp_info.height - 2 - y) * padded;
	
	// Average on a 2 pixel block
	blue = data[bx + by];
	blue += data[bx + 3 + by];
	blue /= 2;
	
	// Average on a 2 pixel block
	green = data[bx + by + 1];
	green += data[bx + 3 + by + 1];
	green /= 2;
	
	// Average on a 2 pixel block
	red = data[bx + by + 2];
	red += data[bx + 3 + by + 2];
	red /= 2;
	
	lum = (red + green + blue) / 3;
	
	//printf("lum=%u addr=%lX rx=%u ry=%u - ", lum, bx + by, x, y);
	
	if (lum > 180) {
		return 4;		// White
	} else if (lum < 30) {
		return 0;		// Black
	} else if (red > ((blue + green) / 2) + 10) {
		return 1;		// Red
	} else if (green > ((blue + red) / 2) + 10) {
		return 2;		// Green
	} else if (blue > ((red + green) / 2) + 10) {
		return 3;		// Blue
	} else {
		return 0;		// Black
	}
}

int main(int argc, char *argv[]) {
	char filepath[256];
	unsigned int frame = 0, line, block, col;
	unsigned long int datasize;
	unsigned long int x_offset, y_offset;
	unsigned int color_a, color_b, frame_empty, clock_state, osc;
	unsigned long int latched, latched_col[4], addr = 0, flipped;
	unsigned char dibit;
	FILE * f;
	FILE * fout;
	
	if (argc < 3) {
		puts("Usage: program (frames directory) (output file)\n");
		return 1;
	}
	
	fout = fopen(argv[2], "wb");
	
	sprintf(filepath, "%s\\%04u.bmp", argv[1], frame);
	
	while ((f = fopen(filepath, "rb"))) {
		//printf("Opened %s\n", filepath);
		
		fread(&bmp_header, 1, sizeof(bmp_header), f);
		fseek(f, 14, SEEK_SET);
		fread(&bmp_info, 1, sizeof(bmp_info), f);
		
        datasize = (bmp_info.width * bmp_info.bits + 7) / 8 * bmp_info.height;

	    if ((data = malloc(datasize)) == NULL) {
			puts("malloc failed.\n");
	        fclose(f);
	        fclose(fout);
	        return 1;
	    }
	
		fseek(f, 0, SEEK_SET);
		
	    if (fread(data, 1, datasize, f) < datasize) {
			puts("fread failed.\n");
	        free(data);
	        fclose(f);
	        fclose(fout);
	        return 1;
	    }
	    
		x_offset = 10 << 8;	// Start at 10th pixel
		y_offset = 0 << 8;
	
		// Clock line
	    frame_empty = 1;
	    clock_state = 1;
	    //osc = 0;
	    for (block = 0; block < 8; block++) {
	    	color_a = getcolor(x_offset >> 8, y_offset >> 8);
			x_offset += ((310 << 8) / 70);
	    	color_b = getcolor(x_offset >> 8, y_offset >> 8);
			x_offset += ((310 << 8) / 70);
	    	
			if (color_b) frame_empty = 0;
			
			if ((color_a != 3) && (color_b != 1))
				clock_state = 0;
		}
		
		if (frame_empty) {
			printf("%04u: Black frame\n", frame);
		} else {
			if (!clock_state) {
			//	printf("%04u: Clk:0\n", frame);
			} else {
			//	printf("%04u: Clk:1\n", frame);
				y_offset += ((172 << 8) / 21);
				
			    for (line = 0; line < 40; line++) {
			    	x_offset = 10 << 8;	// Start at 10th pixel
			    	
			    	for (col = 0; col < 4; col++) {
			    		
						latched = 0;
					    for (block = 0; block < 8; block++) {
					    	color_a = getcolor(x_offset >> 8, y_offset >> 8);
							//printf("A:x=%u,y=%u: %s ", block + (col * 9), line, color_str[color_a]);
							x_offset += ((312 << 8) / 70);
							
					    	color_b = getcolor(x_offset >> 8, y_offset >> 8);
							//printf("B:x=%u,y=%u: %s\n", block + (col * 9), line, color_str[color_b]);
							x_offset += ((312 << 8) / 70);
							
							if ((color_a == 0) && (color_b == 4))
								dibit = 0;
							else if ((color_a == 3) && (color_b == 1))
								dibit = 3;
							else if ((color_a == 1) && (color_b == 2))
								dibit = 1;
							else if ((color_a == 2) && (color_b == 3))
								dibit = 2;
							
							latched >>= 4;
							latched |= (dibit << 30);
						}
						
						x_offset += ((312 << 8) / 70);
						x_offset += ((312 << 8) / 70);
						
						if (line & 1) {
							latched_col[col] |= latched;
							flipped = (latched_col[col] >> 24) +
										((latched_col[col] & 0xFF0000) >> 8) +
										((latched_col[col] & 0xFF00) << 8) +
										((latched_col[col] & 0xFF) << 24);
							fwrite(&flipped, 1, 4, fout);
							//printf("%08lX ", latched_col[col]);
						} else {
							latched_col[col] = latched >> 2;
						}
					}
					
					addr += 8;
					
					//if (line & 1) printf("\n");
					
					y_offset += ((172 << 8) / 43);
				}
			}
		}
		
		fclose(f);
	    free(data);
	    
		//if (frame == 8) return 0;
		printf("%04u %08lX\r", frame, addr);
	    
		frame++;
		sprintf(filepath, "%s\\%04u.bmp", argv[1], frame);
	}
	
	fclose(fout);

	return 0;
}
