title: Power-On Process
published: 2019-01-20
tag: electronics
tag: computing
tag: notes

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

The power-switch debouncer is part of your power supply.
Odds are that switch is too inconvenient for you to use on a daily basis, so you use a momentary button on the front of your case.
I'm not talking about that one, though if your have an actual switch on the front of your case, that's rad!

In any case, the power supply takes mains power and adapts it into a form usable by the computer.
That means converting AC to DC (if necessary), cleaning up any power fluctuations (the debouncer it part of that), likely lowering the voltage (esp. if the supply is mains power), and splitting incoming current into multiple separate streams which then provide each component with its own (more) independent power supply.

Now, odds are that the computer does nothing without a clock, and that's a good thing for us.
On power-up, the computer can begin in an arbitrary state: i.e. it might be just about to destroy all your important data and brick the machine.
So, after the power-on, we need to _absolutely not_ give power to the clock.
Instead, the first place we send power is to a master reset signal line (if the master reset is active-low, then we first ensure this is grounded, which is easier).
Once the reset is stable, then we can supply power to the oscillator.
It won't take long for the oscillator to stabilize; once it does, we can de-assert the master reset, and the machine begins doing work.


```
PWR ---++++++++++++++
RST ----++++++++++---
CLK ---------++++++++
```

The requisite delays at this point are still not implemented with a clock and a counter.
These delays happen because of a delay line---exactly the kind of basic passive electrical component your physics class simplified out.
Though, now that we have a stable clock, any further switch debouncing and timing adjustments can be done with flip-flops.

!!!warning "TODO"
    I actually have no idea what's powered while your computer is shut down, what listens for the boot switch, or how that boot signal is sent anywhere.

    Probably, at this point there's a cpu zero (hardwired to zero) that has microcode flashed into it.
    That microcode would start execution by setting the instruction pointer to the start of the BIOS, then entering the main loop.

    I guess the question is what happens when shut down occurs?
    Surely not even cpu zero wants to be powered here, but would there really be another chip on the mobo that would take over listening for that momentary button?
