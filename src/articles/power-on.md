title: Power-On Process

When you turn your computer on, the very first thing that happens is that the incoming power wire gets voltage:

```
Vcc         /--------
           /
0V  ------/

          ^
          |
        switch is turned on
```

Other guides will tell you that a Power-On Self-Test (POST) happens, but actually that's still at least a few nanoseconds away.
I mean, if you're writing code for existing hardware, that's a fine place to start, but it's not completely true.

Then again, the graph I've drawn also isn't completely true.
In reality, the incoming power line is subject to switch bounce.
Therefore, the clean, straight signal curve I've drawn actually comes after a debouncing circuit.
A simple debouncing circuit can be made from a D-flip-flop, but this requiers a clock, and since our computer's oscillator doesn't yet have stable power, we don't have a stable clock signal.
I found a clockless debouncer [here](http://www.labbookpages.co.uk/electronics/debounce.html).
TODO: investigate clockless debouncing more.

Honestly, the power-switch debouncer is probably part of your power supply.
The power supply takes mains power and adapts it into a form usable by the computer.
That means converting AC to DC (if necessary), cleaning up any power fluctuations (the debouncer it part of that), likely lowering the voltage (esp. if the supply is mains power), and splitting incoming current into multiple separate streams which then provide each component with its own (more) independent power supply.


Now, odds are that the computer does nothing without a clock, and that's a good thing for us.
On power-up, the computer can begin in an arbitrary state: i.e. it might be just about to destroy all your important data and brick the machine.
So, after the powwer-on, we need to _absolutely not_ give power to the clock.
Instead, the first place we send power is to a master reset signal line (if the master rest is active-low, then we first ensure this is grounded, which is easier).
Once the reset is stable, then we can supply power to the oscillator.
It won't take long for the oscillator to stabilize; once it does, we can de-assert the master reset, and the machine begins doing work.


```
PWR ---++++++++++++++
RST ----++++++++++---
CLK ---------++++++++
```

Oh yeah, and now that we have a stable clock, any further switch debouncing can be done with flip-flops.
Which brings me to a clarification: when I said "power switch", I didn't mean the push button on the front of your case every day (or every once in a while); I meant the two-position switch on the back of your case that's too inconvenient to use to turn your computer onn and off.
If your computer actually boots up as soon as power is applied, that's rad!; move straight on down to where the CPU gets kicked off.

TODO: I actually have no idea what's powered while your computer is shut down, what listens for the boot switch, or how that boot signal is sent anywhere

