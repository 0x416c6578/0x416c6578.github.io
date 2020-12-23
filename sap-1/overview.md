<img src="../Images/sap1Finished.png" alt=" " width=""/>
- This was a project I did for school
- It was mostly based on the work of [Ben Eater](eater.net) and is amazing YouTube series on the work of A.P.Malvino in _Digital Computer Electronics_
- All components were sourced off of Aliexpress over about 2 months, and the build process took about 4 months (delivery times could take up to a month)
- Using a full bus-width memory bus (for 256 bytes memory) would be quite easy to implement and is something I would like to do in the future
- I used an Arduino to write a program into RAM on bootup; the code can be found below, or the repo [here](https://github.com/0x416c6578/sap1-programmer)
```c++
/*
  Pin definitions:
  const int address3 = 5; upper bit
  const int address2 = 4;
  const int address1 = 3;
  const int address0 = 2; lower bit
  const int instruction3 = 9; upper bit
  const int instruction2 = 8;
  const int instruction1 = 7;
  const int instruction0 = 6; lower bit
  const int operand3 = 13; upper bit
  const int operand2 = 12;
  const int operand1 = 11;
  const int operand0 = 10; lower bit
  Programming:
  0000            NOP       - No operation
  0001 [Addr]     LDA       - Load value at address [Addr] into A register
  0010 [Addr]     ADD       - Add value at address [Addr] to A register and put result in A register
  0011 [Addr]     SUB       - Subtract value at address [Addr] from A register and put result in A register
  0100 [Addr]     STA       - Store value in A register in address [Addr]
  0101 num        LDI       - Load num immediately into A register
  0110 [Addr]     JMP       - Unconditional jump to [Addr]
  ...
  ...
  1110            OUT       - Output value in A register to display
  1111            HLT       - Halt execution
*/

#define NOP 0b00000000
#define LDA 0b00000001
#define ADD 0b00000010
#define SUB 0b00000011
#define STA 0b00000100
#define LDI 0b00000101
#define JMP 0b00000110
#define OUT 0b00001110
#define HLT 0b00001111

char PROGRAM[][32] = {{LDI, 0x1, STA, 0xD, LDI, 0x0, STA, 0xE, STA, 0xF, LDA, 0xE, ADD, 0xD, STA, 0xE, LDA, 0xF, ADD, 0xE, OUT, 0x0, STA, 0xF, JMP, 0x5, 0x0, 0x1, 0x0, 0x0, 0x0, 0x0},  //triangle numbers
  {LDI, 0x1, STA, 0xE, LDI, 0x0, OUT, 0x0, ADD, 0xE, STA, 0xF, LDA, 0xE, STA, 0xD, LDA, 0xF, STA, 0xE, LDA, 0xD, JMP, 0x3, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0},  //fibonacci
  {LDI, 0x1, STA, 0xF, OUT, 0x0, ADD, 0xF, JMP, 0x2, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0},  //simple counter
  {LDI, 0x1, STA, 0xE, LDI, 0xF, STA, 0xF, LDA, 0xE, ADD, 0xF, OUT, 0x0, HLT, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0}  //simple adder
};

const int DELAYTIME = 50;
//const int PROGNUM = 0;

void setup() {
  for (int i = 2; i <= 13; i++) {
    pinMode(i, OUTPUT);   //make pins outputs
  }
  pinMode(A0, OUTPUT);
  char PROGNUM = getProgram();
  Serial.begin(115200);
  Serial.println();
  //writeProgram(PROGNUM);
}

void writeProgram(char PROGNUM) {
  char tempInst, tempOperand, tempAddr;
  for (char i = 0; i <= 15; i += 1) {
    tempAddr = i;  //address
    tempInst = PROGRAM[PROGNUM][i * 2];  //gets instruction from program array
    tempOperand = PROGRAM[PROGNUM][(i * 2) + 1];  //gets operand from program array
    tempInst = tempInst << 4;  //bit shifts instruction so that the instruction word is in the highest 4 bits of the byte
    char tempByteToWrite = tempInst | tempOperand;  //oring the instruction with the operand yields a byte that can then be written into RAM
    writeThis(tempAddr, tempByteToWrite);  //write the byte to its corresponding address
    delay(DELAYTIME);
  }
}

void writeThis(char address, char byteToWrite) {
  /*
       address = 0b0000[0000], lower 4 bits read
       byteToWrite = 0b[0000]{0000}, [INSTRUCTION] and {OPERAND}
       byteToWrite pin order = [9,8,7,6]{13,12,11,10}
       address pin order = [5,4,3,2]
  */
  digitalWrite(5, address & 0b00001000);  //address upper bit
  digitalWrite(4, address & 0b00000100);
  digitalWrite(3, address & 0b00000010);
  digitalWrite(2, address & 0b00000001);  //address lower bit

  digitalWrite(9, byteToWrite & 0b10000000);  //instruction upper bit
  digitalWrite(8, byteToWrite & 0b01000000);
  digitalWrite(7, byteToWrite & 0b00100000);
  digitalWrite(6, byteToWrite & 0b00010000);  //instruction lower bit

  digitalWrite(13, byteToWrite & 0b00001000);  //operand upper bit
  digitalWrite(12, byteToWrite & 0b00000100);
  digitalWrite(11, byteToWrite & 0b00000010);
  digitalWrite(10, byteToWrite & 0b00000001);  //operand lower bit

  digitalWrite(A0, LOW);
  delay(DELAYTIME);
  digitalWrite(A0, HIGH);
}

/* It is ok to write a non boolean value (ie not LOW or HIGH) to digitalWrite as the internal function will only set a pin LOW
   if the argument is a 0, else it will set it high, so when we and say address [0010] with 0100, digitalWrite will write
   LOW to the pin as the result of or'ing those together is 0000, whereas say if we were to and it with 0010, we would effectively
   be saying digitalWrite(pin, 0010), however as 0010 is a non zero value, digitalWrite will pull the pin high regardless, as 0010 is
   a non zero value.
   We can see this by looking at the line:
   if (val == LOW) {
               out &= ~bit;
       } else {
               out |= bit;
       }
   from the source code. 
   Without worrying about the variable names, you can see that an else statement is used, rather than an else if,
   meaning that any non zero value will pull the pin high.
*/
char getProgram() {
  pinMode(A1, INPUT);
  pinMode(A2, INPUT);
  pinMode(A3, INPUT);
  pinMode(A4, INPUT);
  char programNumber = 0b00000000;
  programNumber += digitalRead(A1);
  programNumber = programNumber << 1;
  programNumber += digitalRead(A2);
  programNumber = programNumber << 1;
  programNumber += digitalRead(A3);
  programNumber = programNumber << 1;
  programNumber += digitalRead(A4);
  programNumber = programNumber << 1;
  return programNumber;
}

void loop() {

}
```