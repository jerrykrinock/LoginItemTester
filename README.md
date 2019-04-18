# LoginItemTester

## Overview

This project demonstrates a *Service Management Login Item* which communicates to a main GUI app via *XPC*.

Note that these two demos are actually orthogonal.

* The method of interprocess communication need not be XPC.  It could be bare-metal Mach ports or `CFMessagePort`.  But, as of 2019, XPC is recommended by Apple for new designs. 

* The agent could be *XPC Service helper* instead of a *Service Management Login Item*.  The difference is that *Service Management Login Items* are launched by the system when the user logs in and continue running until the user logs out, while *XPC Service helpers* only service their owning GUI app and only run when needed.  

## Notes

When running the demo, note that it is necessary to first enable the service and *then* connect to it.  If you *connect* the service before enabling it, you must disconnect and re-connect.
