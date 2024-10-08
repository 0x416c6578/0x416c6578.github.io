# Converting To LVGL Fonts in p8-firmware
Until now I have been using the same font used in [ATCwatch](https://github.com/atc1441/atcwatch) before the switch to LVGL. This has worked fine for a while, and using my improved text rendering routine, I can create simple text based screens. I implemented 'images' by replacing the characters stored in the _unprintable_ ascii characters (up to but not including 0x20 - " ") with my own designed glyphs for different features of the watch.  
The problem with this approach is the font is quite basic looking, and looks very blocky scaled up. Also being monospace, it can sometimes look strange and is difficult to read.  

To remedy this, I would like to implement a font rendering engine that can use LVGL format fonts. This will allow me to use many different (better looking) fonts, with the added benefit of reduced RAM usage.
## Understanding How LVGL Fonts work
- LVGL uses a compressed format for storing fonts, meaning that only useful data is stored in memory
- This means if a character is mainly whitespace, for example a fullstop, that a lot of the pointless data of the empty space is removed
  - Currently, fonts in p8-firmware store 8*FONT_WIDTH bits per character, whereas LVGL fonts are variable
- A font is stored as a big bitmap array of bytes
```c
static LV_ATTRIBUTE_LARGE_CONST const uint8_t gylph_bitmap[] = {
    /* U+20 " " */

    /* U+21 "!" */
    0xf2,

    /* U+22 "\"" */
    0x99, 0x90,

    /* U+23 "#" */
    0x49, 0x2f, 0xd2, 0xfd, 0x24, 0x80, //... and so on ...
```

- There is also a corresponding array of font metadata that stores information about each character in the font
  - The UNICODE value of a character can be put into this array as an index (subtracting an offset of 32 to skip the unprintable characters) to get the corresponding character font information
- From this struct, the offset of the character in the bitmap array can be found, as well as other information about the bounding box
```c
typedef struct {
    uint32_t bitmap_index;  <- Start index of the bitmap. A font can be max 4 GB. 
    uint32_t adv_w;         <- Draw the next glyph after this width. 28.4 format (real_value * 16 is stored)
    uint8_t box_w;  <- Width of the glyph's bounding box
    uint8_t box_h;  <- Height of the glyph's bounding box
    int8_t ofs_x;   <- x offset of the bounding box
    int8_t ofs_y;   <- y offset of the bounding box. Measured from the top of the line
} lv_font_fmt_txt_glyph_dsc_t;
```
- The array looks like 
```c
...
    {.bitmap_index = 0, .adv_w = 0, .box_h = 0, .box_w = 0, .ofs_x = 0, .ofs_y = 0}      /* id = 0 reserved */,
    {.bitmap_index = 0, .adv_w = 128, .box_h = 0, .box_w = 0, .ofs_x = 0, .ofs_y = 0},   //Space
    {.bitmap_index = 0, .adv_w = 128, .box_h = 7, .box_w = 1, .ofs_x = 3, .ofs_y = -1},  //!
    {.bitmap_index = 1, .adv_w = 128, .box_h = 3, .box_w = 4, .ofs_x = 2, .ofs_y = 3},   //Backslash
    {.bitmap_index = 3, .adv_w = 128, .box_h = 7, .box_w = 6, .ofs_x = 1, .ofs_y = -1},  //#
...
```
- This font data is for a monospace font (hence the width to advance per char is 128/16 = 8 pixels (look at struct for info))
- For the exclamation mark, the character bounding box dimensions are 7 down * 1 accross
- As you can see, there is a tradeoff of having to store metadata (and the calculations that go with that), however it greatly reduces the font size in memory
## Reading Font Bitmap Data
- The only part of a character that is written to is the bounding box area, meaning that the data stored in the bitmap correlates to only that part of the character in the bounding box
- For '!', the data stored is 0xf2, or 0b1111001(0) (the thing in brackets is just padding)
- Data is read into the bounding box starting in the top-left and working along, then down
  - The bounding box is a 7 down * 1 accross box, meaning the letter looks like:
```
___
|@|
|@|
|@|
|@|
| |
| |
|@|
---
```
- Data is read into the bounding box starting in the top-left and working down before accross
- Another example is the pound (#), its data being 0x49, 0x2f, 0xd2, 0xfd, 0x24, 0x80, or 0b01001001\|00101111\|11010010\|11111101\|00100100\|10(000000)
- This looks like:
```
_____________
| |@| | |@| |
| |@| | |@| |
|@|@|@|@|@|@|
| |@| | |@| |
|@|@|@|@|@|@|
| |@| | |@| |
| |@| | |@| |
-------------
```
- To calculate the number of bytes that should be read for a character, find the bounding box area with width*height, then find the next multiple of 8 greater than it, finally dividing that by 8 to find the number of bytes to read into the bounding box
  - So for example '#', the bounding box area is 7\*6=42, the next highest multiple of 8 is 48, which is 6\*8, meaning you should read indexes offset+0, offset+1,...,offset+5 of the bitmap array
  - This also means the last 6 bits of the last byte are unused

## Bounding Box Offsets
- Along with the bounding box width and height, there is also the bounding box's x and y offset inside the character window:
```
@---------------@
|               |
|...............|
|   *------*    | Offset = (4,-1) 
|   |      |    |
|   |      |    |
|   |      |    |
|   *------*    |
|               |
|               |
@---------------@
```
- So each character's bounding box (represented by the \*s) has an x and y offset inside the character box
- To make life more difficult, the y offset is measured from the top of the text line, rather than the character to draw x,y position (represented by the dotted line)
- Adding to the confusion, this offset is inverse to what you would think, with more negative values being a downwards push of the character bounding box
- This means that logically, things like diacritics work as follows:
  - For a 'ÿ', the bounding box y offset would be the negative of the height of the diacritics only, meaning that the top of the letter logically lines up with the top of the text line (NOT the character box (@s in the diagram))
  - And so for 'y', the bounding box offset will be 0 since you want the top of the letter to line up with the top of other


## LVGL Font Engine
- So now that we know how LVGL fonts work, we must figure out how to implement them into `p8-firmware`
- To start off with, I implemented a very simple font viewer in c that allowed me to see any character of a font:
```c
void displayChar(char toWrite) {
  int index = toWrite - 32;                                 //Get the offset relative to 0x20 (' ')
  index = index + 1;                                        //Add 1 since id=0 is reserved
  lv_font_fmt_txt_glyph_dsc_t charInfo = glyph_dsc[index];  //Get character info
  //Start writing the character from the bounding box origin rather than the character origin
  int byteNumber; //Current byte NUMBER of font
  int byteOffset; //Current bit of the current byte
  for (int y = 0; y < charInfo.box_h; y++) {
    for (int x = 0; x < charInfo.box_w; x++) {
      byteNumber = ((y * charInfo.box_w) + x) / 8;
      byteOffset = ((y * charInfo.box_w) + x) % 8;
      printf("%c ", ((font[charInfo.bitmap_index + byteNumber] << byteOffset) & 0x80) >> 7 ? '@' : '.'); //'@' if pixel there, else '.'
    }
    printf("\n"); //Move to next line
  }
}
```
- This code is a bit messy but it shows how you can get pixel data for any font
  - This code will draw a character's bounding box only, meaning that the characters have variable widths and heights
- This logic will of course be simplified and improved in `p8-firmware`

___

- All this information was gained only from the font files; I didn't look at the actual LVGL source code so there is a good chance I am wrong with some parts
