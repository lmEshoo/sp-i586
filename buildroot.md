##kernel configure
We use [buildroot](https://buildroot.org/) to create our kernel. Follow this tutorial if you would like to configure the kernel. Current version of the VM has `.config` that adds python.

###manual
Only tested using Ubuntu 12.04

  `apt-get update`
  
  `apt-get install build-essentials`
  
  `wget --no-check-certificate https://buildroot.org/downloads/buildroot-2016.02.tar.gz`
  
  `cd buildroot*`
  
  `make menuconfig`
  
  Save your work ~ this will generate a `.config` file
  
  `make`
  
  Output files compressed and uncompressed will be in `/output/images/`
  
###Ubuntu 12.04 VM 

Click [here](http://lmeshoo.net/services/buildroot2016.html)

##Preload data

###Preload your personal files/folders

- Do into `./bin/` directory in the project and do:

- `cp root.bin initramfs.cpio.gz`

- `gunzip initram.cpio.gz`

- `mkdir temp && cd temp`

- `cpio -idv < ../initramfs.cpio`

- Do what ever you want to add/modify file 

- Make sure permisions are `+rwx` everywhere `chmod -cR 777 *`

- `find . | cpio -H newc -o > ../initramfs.cpio.new`

- `cd ..`

- `cat initramfs.cpio.new | gzip > root.bin.new`

###Rebuild `.mcs` file

using `.bit` + `.vmlinux.bin` + `root.bin.new` lets prepare a PROM.

#####Configure:

- Open iMPACT tool using ISE
- Open a new project
- Select **Prepare a PROM File** and click **Ok**
- Select **Configure A Single FPGA** and click the arrow
- Slect **128M** (this is 128... chip, then the size will be 16 (MB).)
- **Add Storage** and click the arrow
- Give the second field **Output File Name** a name
- Check **No** on **Add Non-Configuration Data Files**
- Click **Ok**
 
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
8.  `MCS` File should be generated, exit and re-enter ISE then Flash the SPI

* TO CHECK
