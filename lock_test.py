#!/usr/bin/python
import sys
import Quartz
d = Quartz.CGSessionCopyCurrentDictionary()
sys.exit(d and 
         d.get("CGSSessionScreenIsLocked", 0) == 0 and 
         d.get("kCGSSessionOnConsoleKey", 0) == 1)
