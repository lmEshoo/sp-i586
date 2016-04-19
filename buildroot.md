##Using buildroot

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

  
