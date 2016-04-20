##kernel configure
We use [buildroot](https://buildroot.org/) to create our kernel. Follow this tutorial if you would like to configure the kernel. Current version of the VM has `.config` that adds python.

###manual
Only tested using Ubuntu 12.04

1.  `apt-get update`
2.  `apt-get install build-essentials`
3.  `wget --no-check-certificate https://buildroot.org/downloads/buildroot-2016.02.tar.gz`
4.  `cd buildroot*`
5.  `make menuconfig`
  * Save your work ~ this will generate a `.config` file
6.  `make`
  
Output files compressed and uncompressed will be in `/output/images/`
  
###Ubuntu 12.04 VM 

Click [here](http://lmeshoo.net/services/buildroot2016.html)

##Preload data

###Preload your personal files/folders

1. Do into `./bin/` directory in the project 
2. `cp root.bin initramfs.cpio.gz`
3. `gunzip initram.cpio.gz`
4. `mkdir temp && cd temp`
5. `cpio -idv < ../initramfs.cpio`
6. Do what ever you want to add/modify file 
  * Make sure permisions are `+rwx` everywhere `chmod -cR 777 *`
8. `find . | cpio -H newc -o > ../initramfs.cpio.new`
9. `cd ..`
10. `cat initramfs.cpio.new | gzip > root.bin.new`

###Rebuild `.mcs` file

using `.bit` + `.vmlinux.bin` + `root.bin.new` lets prepare a PROM.

#####Configure:

1.  Open iMPACT tool using ISE
2.  Open a new project
3.  Select **Prepare a PROM File** and click **Ok**
4.  Select **Configure A Single FPGA** and click the arrow
5.  Slect **128M** (this is 128... chip, then the size will be 16 (MB).)
6.  **Add Storage** and click the arrow
7.  Give the second field **Output File Name** a name
8.  Check **No** on **Add Non-Configuration Data Files**
9.  Click **Ok**
 
#####Pick Files

1.  Click **Ok** on the pop up screen
  * Find `.bit` file of the project
2.  When it asks you to `Add a Device`
  * Click **No**
3.  When it asks you to `Add Data Files`
  * Click **Yes**
  * Give Start Address at `400000`
  * Find your `vmlinux` file *
4.  When it asks you to `Add Data Files`
  * Click **Yes**
  * Give Start Address at `800000`
  * Find your `initramfs` file *
5.  When it asks you to `Add Data Files`
  * Click **No**
6.  When it asks you to `Add Device`
  * Click **No**
  * Click **Ok**
7.  Click on **Generate File**
  * Click **No**
8.  `MCS` File should be generated, exit and re-enter ISE then [Flash the SPI](https://github.com/lmEshoo/sp-i586/blob/master/howto.md#to-flash)

* TO CHECK
