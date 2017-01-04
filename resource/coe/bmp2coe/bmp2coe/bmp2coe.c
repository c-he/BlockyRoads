#include <stdio.h>
#include <windows.h>

int loadBitmap(const char *fileIn, const char *fileOut)
{
	FILE *fp;
	BITMAPFILEHEADER bitmapFileHeader;
	BITMAPINFOHEADER bitmapInfoHeader;
	char *data;
	fp = fopen(fileIn, "rb");
	if (!fp) return -1;
	fread(&bitmapFileHeader, sizeof(BITMAPFILEHEADER), 1, fp);
	if (bitmapFileHeader.bfType != 0x4d42) return -2;
	fread(&bitmapInfoHeader, sizeof(BITMAPINFOHEADER), 1, fp);
	fseek(fp, bitmapFileHeader.bfOffBits, SEEK_SET);
	data = (char*)malloc(bitmapInfoHeader.biSizeImage);
	if (!data) return -3;
	fread(data, 1, bitmapInfoHeader.biSizeImage, fp);
	fclose(fp);

	fp = fopen(fileOut, "w");
	if (!fp) return -4;
	int i, r, g, b, color;
	for (i = 0; i < bitmapInfoHeader.biSizeImage; i += 3)
	{
		r = data[i + 2];
		g = data[i + 1];
		b = data[i];
		r &= 0xff;
		g &= 0xff;
		b &= 0xff;
		color = ((b << 4) & 0xf00) | (g & 0xf0) | ((r >> 4) & 0xf);
		if (i % 48 == 0)
			fprintf(fp, "\n\t.half\t0x%04x", color);
		else
			fprintf(fp, ", 0x%04x", color);
	}
	fclose(fp);

	free(data);
	return 0;
}
int loadBitmapBW(const char *fileIn, const char *fileOut) // 0 for black 1 for white
{
	FILE *fp;
	BITMAPFILEHEADER bitmapFileHeader;
	BITMAPINFOHEADER bitmapInfoHeader;
	char *data;
	fp = fopen(fileIn, "rb");
	if (!fp) return -1;
	fread(&bitmapFileHeader, sizeof(BITMAPFILEHEADER), 1, fp);
	if (bitmapFileHeader.bfType != 0x4d42) return -2;
	fread(&bitmapInfoHeader, sizeof(BITMAPINFOHEADER), 1, fp);
	fseek(fp, bitmapFileHeader.bfOffBits, SEEK_SET);
	data = (char*)malloc(bitmapInfoHeader.biSizeImage);
	if (!data) return -3;
	//printf("%s", data); // use for debug
	fread(data, 1, bitmapInfoHeader.biSizeImage, fp);
	fclose(fp);

	fp = fopen(fileOut, "w");
	if (!fp) return -4;
	int i, r, g, b, color;
	unsigned int d = 0;
	fprintf(fp, "memory_initialization_radix=16;\nmemory_initialization_vector = \n");
	for (i = 0; i < bitmapInfoHeader.biSizeImage; i += 3)
	{
		r = data[i + 2];
		g = data[i + 1];
		b = data[i];
		r &= 0xff;
		g &= 0xff;
		b &= 0xff;
		color = ((b << 4) & 0xf00) | (g & 0xf0) | ((r >> 4) & 0xf);
		fprintf(fp, "%04x", color);
		if (i + 3 < bitmapInfoHeader.biSizeImage)
			fprintf(fp, ",\n");
	}
	fprintf(fp, ";");
	fclose(fp);
	free(data);
	return 0;
}


int main(void)
{
	loadBitmapBW("explosion.bmp", "explosion.coe");
	
	//return 0;
}