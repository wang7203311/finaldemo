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


/*
RotWord
input word    - 1 word
output retval - 1 word
*/
unsigned int RotWord(unsigned int word)
{
	unsigned int temp = word & 0xF000; //get the first byte
	unsigned int retval = word << 8;
	retval |= temp;
	return retval; 
}

/*
SubWord
input word - 32bits
output retval - 32bits
*/
unsigned int SubWord(unsigned int word)
{
	unsigned char first,second,third,fourth;
	first = (unsigned char)((word & 0xF000)>> 24);
	second = (unsigned char)((word & 0x0F00) >> 16);
	third = (unsigned char)((word & 0x00F0) >> 8);
	fourth = (unsigned char)(word & 0x000F);
	unsigned int retval = (aes_sbox[first] << 24) | (aes_sbox[second] << 16) | (aes_sbox[third] << 8) | aes_sbox[fourth];
	return retval;
}


/*
keyexpansion
input: Cipher-Key - Pointer to 32x 8-bit char array that contains the input key in ASCII format
		NK        - is the number of 32-bit words in the cipher key
output: KeySchedule - 32*4*(10+1) array 
*/
void keyExpansion(unsigned char* key, unsigned int*w, int Nk)
{
	unsigned int temp;
	int i = 0;
	while(i < Nk)
	{
		w[i] = (key[4*i] <<24 ) | (key[4*i] << 16) | (key[4*i] << 8) | (key[4*i]);
		i ++;
	}
	i = Nk;
	while( i < 4*11)
	{
		temp = w[i - 1];
		if( i % Nk == 0)
		{
			temp = SubWord(RotWord(temp)) ^ Rcon[i/Nk];
		}
		w[i] = w[i-Nk] ^ temp;
		i++;
	}
}

/*
AddRoundKey
input state        - 4x 32bit array
	   roundkey    - 4x 32bit array
output: none
*/
void AddRoundKey(unsigned int* state, unsigned int* roundkey)
{
	for(int i = 0; i < 4; i++)
	{
		state[i] |= roundkey[i];
	}
}

/*
SubBytes
input state        - 4x 32bit array
output none
*/
void SubBytes(unsigned int* state)
{
	for(int i = 0; i < 4; i++)
	{
		state[i] = SubWord(state[i]);
	}
}

/*
ShiftRows
input state        - 4x32 bit array
output none
*/
void ShiftRows(unsigned int* state)
{
	unsigned int temp0 = state[0];
	unsigned int temp1 = state[1];
	unsigned int temp2 = state[2];
	unsigned int temp3 = state[3];
	state[0] = (temp0 & 0xF000) | (temp1 & 0x0F00) | (temp2 & 0x00F0) | (temp3 & 0x000F);
	state[1] = (temp1 & 0xF000) | (temp2 & 0x0F00) | (temp3 & 0x00F0) | (temp0 & 0x000F);
	state[2] = (temp2 & 0xF000) | (temp3 & 0x0F00) | (temp0 & 0x00F0) | (temp1 & 0x000F);
	state[3] = (temp3 & 0xF000) | (temp0 & 0x0F00) | (temp1 & 0x00F0) | (temp2 & 0x000F);
}


/*
MixColumns
input state        - 4x32 bit array
output none
*/
void MixColumns(unsigned int* state)
{
	unsigned char b0,b1,b2,b3,a0,a1,a2,a3;
	for(int i  =0; i < 4; i++)
	{
		a0 = (state[i] & 0xF000) >>24;
		a1 = (state[i] & 0x0F00) >> 16;
		a2 = (state[i] & 0x00F0) >> 8;
		a3 = state[i] & 0x000F;
		b0 = gf_mul[a0][0] ^ gf_mul[a1][1] ^ a2 ^ a3;
		b1 = a0 ^ gf_mul[a1][0] ^ gf_mul[a2][1] ^ a3;
		b2 = a0 ^ a1 ^ gf_mul[a2][0] ^ gf_mul[a3][1];
		b3 = gf_mul[a0][1] ^ a1 ^ a2 ^ gf_mul[a3][0];
		state[i] = (b0 << 24) | (b1 << 16) | (b2 << 8) | b3;
	}

}




/** encrypt
 *  Perform AES encryption in software.
 *
 *  Input: msg_ascii - Pointer to 32x 8-bit char array that contains the input message in ASCII format
 *         key_ascii - Pointer to 32x 8-bit char array that contains the input key in ASCII format
 *  Output:  msg_enc - Pointer to 4x 32-bit int array that contains the encrypted message
 *               key - Pointer to 4x 32-bit int array that contains the input key
 */
void encrypt(unsigned char * msg_ascii, unsigned char * key_ascii, unsigned int * msg_enc, unsigned int * key)
{
	// Implement this function
	unsigned int[4] state,key = {0};
	unsigned int[11*4] KeySchedule;
	int i = 0;
	int order;
	int counter = 0
	while(i < 32)
	{
		temp = charsToHex(msg_ascii[i], msg_ascii[i+1])
		temp_k = charsToHex(key_ascii[i], key_ascii[i+1])
		order = (int)(i/8);
		state[order] |= temp << (((counter % 4) * -1 + 3) * 8);
		key[order] |= temp << (((counter % 4) * -1 + 3) * 8);
		i += 2;
		counter ++;
	}
	for(i = 0; i < 4; i++){
		printf("%08x", key[i]);
	}
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
