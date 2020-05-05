/************************************************************************
Lab 9 Nios Software

Dong Kai Wang, Fall 2017
Christine Chen, Fall 2013

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "aes.h"
#include <string.h>
// Pointer to base address of AES module, make sure it matches Qsys
volatile unsigned int * AES_PTR = (unsigned int *) 0x00000100;

// Execution mode: 0 for testing, 1 for benchmarking
int run_mode = 0;

/** charToHex
 *  Convert a single character to the 4-bit value it represents.
 *
 *  Input: a character c (e.g. 'A')
 *  Output: converted 4-bit value (e.g. 0xA)
 */
char charToHex(char c)
{
	char hex = c;

	if (hex >= '0' && hex <= '9')
		hex -= '0';
	else if (hex >= 'A' && hex <= 'F')
	{
		hex -= 'A';
		hex += 10;
	}
	else if (hex >= 'a' && hex <= 'f')
	{
		hex -= 'a';
		hex += 10;
	}
	return hex;
}

/** charsToHex
 *  Convert two characters to byte value it represents.
 *  Inputs must be 0-9, A-F, or a-f.
 *
 *  Input: two characters c1 and c2 (e.g. 'A' and '7')
 *  Output: converted byte value (e.g. 0xA7)
 */
char charsToHex(char c1, char c2)
{
	char hex1 = charToHex(c1);
	char hex2 = charToHex(c2);
	return (hex1 << 4) + hex2;
}

/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */

void KeyExpansion(unsigned char key[4][4], unsigned char schedule[4][44]) {
	for(int i = 0; i < 4; i++) {
		for(int j = 0; j < 4; j++) {
			schedule[j][i] = key[j][i];
		}
	}
	for(int i = 4; i < 44; i++) {
		if(i % 4 == 0) {
			unsigned char t0 = schedule[0][i-1];
			unsigned char t1 = schedule[1][i-1];
			unsigned char t2 = schedule[2][i-1];
			unsigned char t3 = schedule[3][i-1];
			schedule[0][i] = (int)(aes_sbox[((int)(t1))]) ^ (int)(schedule[0][i-4]) ^ (int)(Rcon[i/4] >> 24);
			schedule[1][i] = (int)(aes_sbox[((int)(t2))]) ^ (int)(schedule[1][i-4]) ^ (0);
			schedule[2][i] = (int)(aes_sbox[((int)(t3))]) ^ (int)(schedule[2][i-4]) ^ (0);
			schedule[3][i] = (int)(aes_sbox[((int)(t0))]) ^ (int)(schedule[3][i-4]) ^ (0);
		}
		else {
			schedule[0][i] = (int)(schedule[0][i-4]) ^ (int)(schedule[0][i-1]);
			schedule[1][i] = (int)(schedule[1][i-4]) ^ (int)(schedule[1][i-1]);
			schedule[2][i] = (int)(schedule[2][i-4]) ^ (int)(schedule[2][i-1]);
			schedule[3][i] = (int)(schedule[3][i-4]) ^ (int)(schedule[3][i-1]);
		}
	}
}

void AddRoundKey(unsigned char state[4][4], unsigned char RoundKey[4][4], unsigned char schedule[4][44], int count) {
	int temp = (count * 4);
	for(int i = temp; i < (temp + 4); i++) {
		for(int j = 0; j < 4; j++) {
			RoundKey[j][i % 4] = schedule[j][i];
		}
	}
	for(int i = 0; i < 4; i++) {
		for(int j = 0; j < 4; j++) {
			state[j][i] = (int)(state[j][i]) ^ (int)(RoundKey[j][i]);
		}
	}
}


void SubBytes(unsigned char state[4][4]) {
	int temp = 0;
	for(int i = 0; i < 4; i++) {
		for(int j = 0; j < 4; j++) {
			temp = (int)(state[j][i]);
			state[j][i] = aes_sbox[temp];
		}
	}
}

void ShiftRows(unsigned char state[4][4]) {
	unsigned char copy[4][4];
	for(int i = 0; i < 4; i++) {
		for(int j = 0; j < 4; j++) {
			copy[j][i] = state[j][i];
		}
	}
	state[1][0] = copy[1][1];
	state[1][1] = copy[1][2];
	state[1][2] = copy[1][3];
	state[1][3] = copy[1][0];

	state[2][0] = copy[2][2];
	state[2][1] = copy[2][3];
  state[2][2] = copy[2][0];
	state[2][3] = copy[2][1];

	state[3][0] = copy[3][3];
	state[3][1] = copy[3][0];
	state[3][2] = copy[3][1];
	state[3][3] = copy[3][2];
}

void MixColumns(unsigned char state[4][4]) {
	unsigned char copy[4][4];
	for(int i = 0; i < 4; i++) {
		for(int j = 0; j < 4; j++) {
			copy[j][i] = state[j][i];
		}
	}
	for(int i = 0; i < 4; i++) {
		state[0][i] = (gf_mul[copy[0][i]][0] ^ gf_mul[copy[1][i]][1] ^ copy[2][i] ^ copy[3][i]);
		state[1][i] = (copy[0][i] ^ gf_mul[copy[1][i]][0] ^ gf_mul[copy[2][i]][1] ^ copy[3][i]);
		state[2][i] = (copy[0][i] ^ copy[1][i] ^ gf_mul[copy[2][i]][0] ^ gf_mul[copy[3][i]][1]);
		state[3][i] = (gf_mul[copy[0][i]][1] ^ copy[1][i] ^ copy[2][i] ^ gf_mul[copy[3][i]][0]);
	}
}

void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	//create state matrix from msg_ascii
	unsigned char state[4][4];
	unsigned char keyMatrix[4][4];
	unsigned char keySchedule[4][44];
	unsigned char roundKey[4][4];
	int j = 0;
	int i = 0;
	for(int k = 0;k < 31;k+=2)
	{
			 state[i][j] = charsToHex(msg_ascii[k], msg_ascii[k+1]);
			 i++;
			 if(i == 4)
			 {
				 j++;
			 }
			 i = i%4;
	}
	i = 0;
	j = 0;
	for(int k = 0;k < 31;k+=2)
	{
			 keyMatrix[i][j] = charsToHex(key_ascii[k], key_ascii[k+1]);
			 i++;
			 if(i == 4)
			 {
				 j++;
			 }
			 i = i%4;
	}
	KeyExpansion(keyMatrix, keySchedule);
	AddRoundKey(state, roundKey, keySchedule, 0);
	for(int i = 1; i < 10; i++) {
		SubBytes(state);
		ShiftRows(state);
		MixColumns(state);
		AddRoundKey(state, roundKey, keySchedule, i);
	}
	SubBytes(state);
	ShiftRows(state);
	AddRoundKey(state, roundKey, keySchedule, 10);

	msg_enc[0] = ((state[0][0] << 24) ^ (state[1][0] << 16) ^ (state[2][0] << 8) ^ (state[3][0]));
	msg_enc[1] = ((state[0][1] << 24) ^ (state[1][1] << 16) ^ (state[2][1] << 8) ^ (state[3][1]));
	msg_enc[2] = ((state[0][2] << 24) ^ (state[1][2] << 16) ^ (state[2][2] << 8) ^ (state[3][2]));
	msg_enc[3] = ((state[0][3] << 24) ^ (state[1][3] << 16) ^ (state[2][3] << 8) ^ (state[3][3]));

	key[0] = ((keyMatrix[0][0] << 24) ^ (keyMatrix[1][0] << 16) ^ (keyMatrix[2][0] << 8) ^ (keyMatrix[3][0]));
	key[1] = ((keyMatrix[0][1] << 24) ^ (keyMatrix[1][1] << 16) ^ (keyMatrix[2][1] << 8) ^ (keyMatrix[3][1]));
	key[2] = ((keyMatrix[0][2] << 24) ^ (keyMatrix[1][2] << 16) ^ (keyMatrix[2][2] << 8) ^ (keyMatrix[3][2]));
	key[3] = ((keyMatrix[0][3] << 24) ^ (keyMatrix[1][3] << 16) ^ (keyMatrix[2][3] << 8) ^ (keyMatrix[3][3]));
}


/** decrypt
 *  Perform AES decryption in hardware.
 *
 *  Input:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *              key - Pointer to 4x 32-bit int array that contains the input key
 *  Output: msg_dec - Pointer to 4x 32-bit int array that contains the decrypted message
 */
void decrypt(unsigned int * msg_enc, unsigned int * msg_dec, unsigned int * key)
{
	// Implement this function
	//Make sure to reset AES decryption core so that tracker is set to 0;

	AES_PTR[0] = key[0];
	AES_PTR[1] = key[1];
	AES_PTR[2] = key[2];
	AES_PTR[3] = key[3];
	AES_PTR[4] = msg_enc[0];
	AES_PTR[5] = msg_enc[1];
	AES_PTR[6] = msg_enc[2];
	AES_PTR[7] = msg_enc[3];


	AES_PTR[14] = 1;
	AES_PTR[14] = 0;//MAKE SURE U SET TO ZERO RIGHT AFTER SETTING 1 or NO REPETITION
	while(AES_PTR[15] == 0){}
	msg_dec[0] = AES_PTR[8];
	msg_dec[1] = AES_PTR[9];
	msg_dec[2] = AES_PTR[10];
	msg_dec[3] = AES_PTR[11];
}

/** main
 *  Allows the user to enter the message, key, and select execution mode
 *
 */
int main()
{
	// Input Message and Key as 32x 8-bit ASCII Characters ([33] is for NULL terminator)
	unsigned char msg_ascii[33];
	unsigned char key_ascii[33];
	// Key, Encrypted Message, and Decrypted Message in 4x 32-bit Format to facilitate Read/Write to Hardware
	unsigned int key[4];
	unsigned int msg_enc[4];
	unsigned int msg_dec[4];

	printf("Select execution mode: 0 for testing, 1 for benchmarking: ");
	scanf("%d", &run_mode);

	if (run_mode == 0) {
		// Continuously Perform Encryption and Decryption
		while (1) {
			int i = 0;
			printf("\nEnter Message:\n");
			scanf("%s", msg_ascii);
			printf("\n");
			printf("\nEnter Key:\n");
			scanf("%s", key_ascii);
			printf("\n");
			encrypt(msg_ascii, key_ascii, msg_enc, key);
			printf("\nEncrpted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_enc[i]);
			}
			printf("\n");
			decrypt(msg_enc, msg_dec, key);
			printf("\nDecrypted message is: \n");
			for(i = 0; i < 4; i++){
				printf("%08x", msg_dec[i]);
			}
			printf("\n");
		}
	}
	else {
		// Run the Benchmark
		int i = 0;
		int size_KB = 2;
		// Choose a random Plaintext and Key
		for (i = 0; i < 32; i++) {
			msg_ascii[i] = 'a';
			key_ascii[i] = 'b';
		}
		// Run Encryption
		clock_t begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			encrypt(msg_ascii, key_ascii, msg_enc, key);
		clock_t end = clock();
		double time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		double speed = size_KB / time_spent;
		printf("Software Encryption Speed: %f KB/s \n", speed);
		// Run Decryption
		begin = clock();
		for (i = 0; i < size_KB * 64; i++)
			decrypt(msg_enc, msg_dec, key);
		end = clock();
		time_spent = (double)(end - begin) / CLOCKS_PER_SEC;
		speed = size_KB / time_spent;
		printf("Hardware Encryption Speed: %f KB/s \n", speed);
	}
	return 0;
}

/*
 *
Encrypted Message
daec3055df058e1c39e814ea76f6747e
Key
000102030405060708090a0b0c0d0e0f
Last Expanded Round Key
13111d7fe3944a17f307a78b4d2b30c5
Decrypted Message
ece298dcece298dcece298dcece298dc


Encrypted Message
439d619920ce415661019634f59fcf63
Key
3b280014beaac269d613a16bfdc2be03
Last Expanded Round Key
9915cfa2913edd62c645ddee2367395b
Decrypted Message
dbe429ca8610ea6275b100476d87a2c5
 *
 *
 *
 * */
