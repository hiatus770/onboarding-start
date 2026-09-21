<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB. 
-->

## How it works

Takes in SPI data, can write to a set amount of registers. Data is stored in a shift register. For metastability 2 flip flops are chained together.

## How to test

Once all required deps are installed and venv is setup
```cd test && make -B``` 

## External hardware

N/A
