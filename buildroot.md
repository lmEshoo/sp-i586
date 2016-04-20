##kernel configure
We use buildroot to create our kernel.  Follow this tutorial if you would like to configure the kernel. current version of the VM has `.config` that adds python.

###manual
only tested using Ubuntu 12.04

  `apt-get update`
  
  `apt-get install build-essentials`
  
  `wget --no-check-certificate https://buildroot.org/downloads/buildroot-2016.02.tar.gz`
  
  `cd buildroot*`
  
  `make menuconfig`
  
  save your work ~ this will generate a `.config` file
  
  `make`
  
  output files compressed and uncompressed will be in `/output/images/`
  
###Ubuntu 12.04 VM 

Click [here](http://lmeshoo.net/services/buildroot2016.html)

##Preload data

preload your personal files/folders

- go into `./bin` directory in the project and do:

- `cp root.bin initramfs.cpio.gz`

- `gunzip initram.cpio.gz`

- `mkdir temp && cd temp`

- `cpio -idv < ../initramfs.cpio`

-  do what ever you want to add/modify file 

-  make sure permisions are `+rwx` everywhere `chmod -cR 777 *`

- `find . | cpio -H newc -o > ../initramfs.cpio.new`

- `cd ..`

- `cat initramfs.cpio.new | gzip > root.bin.new`

- rebuild `.mcs` file with `.bit` + `.vmlinux.bin` + `root.bin.new`
