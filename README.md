# Welcome
Welcome to the Mandelbrot Operating System, a community driven OS by the youth. 
This OS is built by a humble group of teenagers over at [Discord](https://discord.gg/W523cD3Q3P). 
We do this solely to have fun and to learn. 
We are not organized and are here to enjoy ourselves. 
Sounds appealing? Create a pull request!

# About 
This project is made for fun and learning.
It's like tracing OS history, but with modern knowledge and without a lot of budget lol

# Where are we in the project
- A filesystem is being developed. ATA is somewhat functional but still needs testing.
- We have our own fork of limine which can boot from the flatfs.

# Build Requirements

### Arch/Manjaro
- `sudo pacman -S base-devel qemu nasm xorriso mtools wget`

### Debian/Ubuntu
- `sudo apt-get install build-essential qemu nasm xorriso wget mtools uuid-dev parted`

# Cloning the repo
In order to MandelbrotOS run, you have to clone the repository recursively via the command `git clone https://github.com/MandelbrotOS/MandelbrotOS --recursive`. This will initialize the submodules containing the tools our build system is using. Otherwise, youll have to initialize the submodules manually.


# Building the Toolchain
Mandelbrot depends on some tools, like `limine-install`, `echfs-utils` and the GNU Toolchain.  
If you are on an x86\_64 system, or you have a cross-compiler able to produce binaries for x86_64-elf target, you can skip this step and go to [Building and Running](#building-and-running).
 
If you are not, run
```
cd scripts
./cross-compiler.sh
```  
After it's done, you can head over to [Building and Running](#building-and-running).

# Building and Running
To build the OS itself, make sure you have [built the toolchain](#building-the-toolchain) if necessary. After that, you can:

```
$ make
```

# Testing
By default, the `make` command produces a bootable RAW image. To test MandelbrotOS without creating it issue `make test`.

# Using
By default the OS does nothing as we don't have a userland but stuff can be added to the kernel for testing purposes. There will often be remaining test code that is left over.

# Commiting
We code using GCC so any clang standards that may affect GCC will be ignored.   
We also format our code in clang format so make sure to clang format the code before commiting.  
We code in gnu99 standards. So this is C99 with GNU extensions. It is automatically set in the makefile. Just beware of that when coding.  
When returning an error code from a function: make sure that returning 0 is success code. All other return codes are errors/failures and can be used to show what went wrong.  
Name variables in snake case (`uint64_t name_of_var`)  
Give types \_t's (`typedef long int name_of_type_t`). Make sure this is in snake case too!  
Constants must be in screaming snake case (All capitals snake case) (`#define SOME_CONSTANT 0x1000`)    
Macros follow the same laws as constants. (`#define MAX(a, b) ({int \_a = (a), \_b = (b); \_a > \_b ? \_a : \_b; })`)  
All comments are allowed but I would prefer if you used `//` instead of `/**/`  
All header files must have an ifndef  with the file name in screaming snake case with double underscores on each side of them like this:  
```c
#ifndef __SOME_FILE_NAME_H__
#define __SOME_FILE_NAME_H__

// Code

#endif
```

# Using code
This is an open source project. Reuse code. Just follow the license terms and we are good. :)
