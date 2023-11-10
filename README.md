# SGB_Packet_Buffer_Tests
Test Roms to demonstrate a hardware quirk with the SGB packet buffer.
ROMs are based on the excellent [GB-Starter-Kit](https://github.com/ISSOtm/gb-starter-kit) by ISSOtm.

The command packet buffer (at $7000 on the SNES side) is not written to immediately as bits come in. There is an internal byte sized buffer that incoming transfers are written to. And only once 8 bits are transferred and that buffer is full, it gets written to $7000+.

This quirk never comes up in official (or existing homebrew) software because the BIOS only reads the packet once the full 16 bytes are transferred and the "packet available" flag is set. 
I am working on a SGB demo that jumps out of the BIOS and runs custom SNES code. Part of the demo is synchronised music playback between GB and SPC, with the GB being the part that dictates the speed. To save CPU time I was looking for the smallest possible amount of data i could transfer to indicate a new engine tick and tried just transferring the reset pulse and a single bit. This worked on Mesen2 and Higan, but not on hardware (PAL SNES 2/1/3, SGB1, EZFlash Jr cart). It only started working when I transfered a full byte. 

I could not find any documentation about this. Currently, no emulator handles this correctly.




