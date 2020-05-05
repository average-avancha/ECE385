/* SpriteParser.c - Parses the t files from matlab into an MIF file format
 */

#include <stdio.h>
#include <stdlib.h>

#define INPUT_FILE "sprite_bytes/PACMAN_spritesheet.txt"			// Input filename
#define OUTPUT_FILE "spritesheet.ram"		// Name of file to output to
#define NUM_COLORS 	13								// Total number of different colors
#define WIDTH		8								
#define DEPTH		3072

// Use this to define value of each color in the palette
const long Palette_Colors []= {000000000, 222222255, 255000000, 255183174, 222151081, 255183081, 255255000, 000255000, 71183174, 000255255, 71183255, 033033255, 255183255};
int addr = 0;

int main()
{
	char line[21];
	FILE *in = fopen(INPUT_FILE, "r");
	FILE *out = fopen(OUTPUT_FILE, "w");
	size_t num_chars = 20;
	long value = 0;
	int i;
	int *p;

	if(!in)
	{
		printf("Unable to open input file!");
		return -1;
	}
                    
	// Get a line, convert it to an integer, and compare it to the palette values.
	while(fgets(line, num_chars, in) != NULL)
	{
		value = (char)strtol(line, NULL, 10);
		p = (int *)&value;
		printf("Value: %d is being written into ram\n", *p);
		fwrite(p, 2, 1, out);
	}

	fclose(out);
	fclose(in);
	return 0;
}
