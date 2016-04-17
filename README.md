#sp-i586
soft processor core compatible with i586 instruction set(Intel Pentium) developped on Nexys4 board boots linux kernel with a ramdisk contained in the SPI flash.
<p align="center">
<img src="https://cloud.githubusercontent.com/assets/3256544/14413785/80194934-ff39-11e5-89e2-39df688d1c5c.png" width="480"></br>
</p>
##Intel Pentium Architecture
<a href="https://en.wikipedia.org/wiki/P5_(microarchitecture)">Overall</a>
<p align="center">
<img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/Intel_Pentium_arch.svg/800px-Intel_Pentium_arch.svg.png" width="480">
</p>

##to flash
    use iMPACT in ISE
##to generate and upload .bit
    use Vivado
##to interact

### Linux
    sudo screen /dev/ttyUSB1 115200
  
###Windows
  use <a href="http://www.putty.org/">PuTTY</a>

###Install cable drivers on Linux
        cd <Vivado dir>/data/xicom/cable_drivers/lin64/install_script/install_drivers/
        sudo ./install_drivers
