##Download and install the latest ISE and Vivado Webpack
  - [ISE](http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/design-tools.html)
  
  - [Vivado](http://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2015-4.html)
  
###Install cable drivers on Linux
        cd <Vivado dir>/data/xicom/cable_drivers/lin64/install_script/install_drivers/
        sudo ./install_drivers

##to flash
  `use iMPACT in ISE`
  
  check out this [video](https://www.youtube.com/watch?v=aL9yMcLY_74)
##Uploading the bitstream
  -   Add all `./rtl/` and `./xdc/`files to a new Vivado project
  -   Generate the `.bit` file 
  -   Implement the project and run hardware manger
  
##to interact

###Linux
    sudo screen /dev/ttyUSB1 115200
  
###Windows
  use the serial option in <a href="http://www.putty.org/">PuTTY</a>

