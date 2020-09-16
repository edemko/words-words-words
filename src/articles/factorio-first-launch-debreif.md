title: Launch Debrief
tag: factorio
published: 2020-09-16

After hours of blueprinting and spreadsheet, I've finally launched my first rocket in Factorio.
I was rushing to get it done, and it happened just after 2:00 in the morning, so there are a lot of ntoes about the experience I need to get out of my head.

My special goals, in addition to launching a rocket, was to test my 75SPM science build, try a jump start base capable of blue science (to rush personal bots), to test a massive multitool design, to play with heterogeneous train, and to try my design for a belt-based logistics system and matching modular mall, all using a T-shaped bus design.


## Trains

### Schedules for Mixed Trains

The plan was to have trains that carry several types of cargo.
One thing that bit me was the inability to reorder wait conditions on trains or do anything more complex than sum-of-products logic.

Unloading multiple types of items at base is dangerous because the train might arrive with plenty of one resource but almost nothing of another.
I ended up using conditions that looked like:

  * OR
    * AND
      * iron ore = 0
      * 2s inactivity
    * AND
      * iron plates = 0
      * 2s inactivity
    * AND
      * steel plates = 0
      * 2s inactivity

Further, supplying fuel (or acid for uranium) to outposts was a bit tricky.
Large trains would end up waiting too long to fill completely even though my bus was a fraction of its final size.
I ended up starting with a much lower fill requirement for copper plates and tweaked them upwards as the factory grew.
It could be good to measure an approximate time-to-complete-fill and set a condition to depart if the train has already been there too long.

The plan was to have a train that would do water+stone+uranium, and another at the same station for just water.
I am expecting the separate water train to block an intersection (at the rail crossing gate).
I'm not sure if I'll change the water train to be a duplicate of my misc train, or make a separate water station (I even have a spare station set built from before I designed my train cargo layouts).


### Grand Central

As designed, the rail crossing gate requires a signal before it, which allows a train to pull forward from parking and block all other parking.

I think a tiny two-headed passenger train is a better choice than a long one-headed train passenger+rolling mall design.
Such a train can be placed outside the normal rail parking.unloading area, and so doesn't even need a rail-crossing (and neither would the loading/unloading warehouse area.

### Specialized Trains

I've kept my expansions purposefully minimal because I don't have a munitions/repair supply train.
This should be rectified at once.
At the same time, refueling at a terminus really doesn't make much sense.

### Train Unloading

I initially ignored the need for balancing, assuming MadZuri's smart inserters on unload would handle it.
Unfortunately, as soon as some belts back up to a wagon, the associated chests can't empty properly, and the train will sit around with non-empty cargo and nowhere to put it.
Since I designed the base with non-power-of-two belt widths, I resorted to some "good enough" balancers that haven't caused a problem at the throughput I have so far.

In a design world, I've played around far too much with circuits to try to rebalance input weights based on output backups, but to no avail (not scalably at least).
Instead, I think I have to bow to research and just use the in-game mechanism: bot unloaders.

Since I had so much bot-less success elsewhere in the playthrough, I was really hoping for another bot-less approach here.
However realistically you'll only be pre-bot or post-bot state in a normal game for any length of time.
If pre-bots, then your input requirements are low enough that you can use a small balancer, probably 4x4.
If post-bots, then just use bots since it's otherwise either design a massive balancer, or create a likely UPS-intensive system that simulates bot balance logic.
And you know what, the potential of bots+trains is enormous; I quickly made a design and it unload six lanes from a single wagon for an average of just under 6MW (okay, so it.s 0.07% less than a full six belt, I might even care...).

There is one botless option though: 1 wagon per train.
There are definite advantages for trains being small: faster acceleration and breaking, smaller run-outs from intersections, simpler train schedule conditions, and smaller stations.
When 40 stacks of items isn't enough, add more trains; when traffic gets congested, add another lane.

### Circuit Conditions

One thing I've noticed about myself is that I don't want to stop in the middle of a game to create circuits.
Therefore I should really put the time in to create a book of circuit setups.
In particular, I'm thinking:

  * a multi-item load/unloader using filter inserters and min/max configuration
  * enable train stop based on local buffer contents

## T-Bus

I'm unreasonably satisfied with the squaricity.
However, I noticed that the T-junction was tricky, and ended up with more spaghetti than I'd like.
The two output busses should have their items permuted relative to each other so that the t-junction can be built of branch-offs.
That said, here's a wonderful [4-to-2+2 balancer](https://www.reddit.com/r/factorio/comments/ig573p/trying_to_split_the_belts_evenly_to_the_left_side/)

I noticed that commonly-used-together items should not be adjacent on the bus it they each have only one lane.
It's definitely possible to take a half-half belt in these cases, but I find it a bit ugly (though I find any complex branching off a belt ugly anyway).
I organized this bus to have the most-commonly-used things closer to one side, but the cost of having something on the other side of the bus is practically nil.

I tried a bit of gapless bus, but I think I need more experience using it to make it more enjoyable.
In particular, I need to commit to it, whereas this time I kinda tried gapless as an afterthought.
If I can avoid the annoyance of finding gaps


## Mega Multitool

A while back, someone posted their rediscovery of a 4-asm multitool accessible immediately after automation 1 tech.
In the comments, someone mentioned using a cargo wagon and circuit logic to beef it up.
Their circuit idea was modded-only, but it got me thinking.
So I designed a multitool that takes iron plates, copper plates, iron ore, stone, coal, water, and crude, and produces all sorts of stuff up through using blue circuits and LDS: just about anything except nuclear.

I didn't set it up early-game enough, it probably needs to be part of the jump-start base.
Essentially, I'd like it to construct my first bots for me, but that means building it without bots.
As such, I think I should simplify it somewhat.

In retrospect, producing lubricant from crude in the tool was probably not a good choice.
Instead, if the jump start has oil processing and plastic production in it, that simplifies a lot of the design.
I might not even make the sulfur on site (though probably yes to sulfuric acid), since I'll need sulfur on a belt for blue science anyway.

What I was impressed by was how well it was able to bootstrap new processes.
Before I had my production mall up, I could create centrifuges through the multitool.
It also excelled at personal equipment: solar panels, batteries, lasers, shields, and so on.
I know it'll do a fusion reactor too, I just have to unlock the research.


## Blue Jump Start

My starter ore patch got me through nearly all of red, green, black, and blue science.
It probably could have gotten me all the way if I had used my ore patches more efficiently (but I decided to focus on expansion before they ran out).

I build it on-the-fly, which is good and bad.
The good part is that the items are created in the order in which they are actually needed to bootstrap itself.
The bad part is that there's rather some spaghetti that could have been avoided with some planning.

Here are some things I think could use better design:

  * add explosives
  * tidy up science wing
  * put a path through the base (b/t smelters&rest, b/t basic mall&extended mall)
  * add a mega multitool
  * a basic oil blueprint, extensible to advanced, and eventually for conversion into fuel
  * columns are iron, copper, steel, plastic, stone
  * an optional pathing module (brick storage, concrete, reinforced concrete)



## 75SPM

Up to launching the rocket, I only really hit 22.5, which I expected given that I'm only supplying yellow belts worth of copper to circuit fabs designed for blue belts.
I suppose it's no surprise that blue circuits were the bottleneck, thanks to insufficient copper for green circuits.
I suppose it's a good sign that so the design tracks known gameplay patterns.

It will take time to expand to its full theoretical capacity.

## Belt-based "Logistic System"

Worked like a charm!
I was super fun when the sushi got dense but I could watch the belt thin out as everything got sorted into place.

My only complaint is that you get way more items than you asked for of certain products.
Green/red wire stands out to me, but I don't think I care about that.
On the other hand, I loaded bricks in directly from the bus, and it overwhelmed my flimsy inserter.
Loading from bus should absolutely go through an inserter first, and probably a _slow_ inserter.

I could experiment with different geometries to make it non-linear, but it fit very nicely next to my processing columns and doubled as a spare path.
I could definitely do it again, but I'm interested in trying a train-based logistics system... or perhaps just using logistics bots ;)
I might even make walk-through make-everything as is traditional, but try to integrate better paths for human convenience.

Oh, one thing I wish I had was a recycling system.
I'm overflowing with yellow belts now that I'm upgrading to red

## Future Design Opportunities

I use 4-wide paths without thinking too much.
It turned out too narrow for reliable car use without the vehicle snap mod.
I should put some work into creating my own style of path and surrounding standards.

I should design a bus cross section that lets roboports and power poles reach across.
Bonus points for lighting and obstacle-safe paths.

Having worked with some mixed trains, I want to push myself for a train bus base.

I don't like my uranium processing column.
Or my LDS column.

There are several oddball ingredients that I'd like to run down a bus, but not each on their own lane.
Instead, I should work with a sushi belt down the bus, or a bloodbus.
If sushi, can I load new items at different points on the belt?
Also, can I use one "sushi slot" for both crude and empty barrels?

Concrete is produced very much in bulk.
As far as a mall (storefront) goes, it's more like brick than anything else.
Perhaps I should put some work into integrating concrete columns into brick columns.

I want a Kovarex setup to start all the machines as quickly as possible: i.e. no buffer in the machine.

I used 4-wide paths just because I'm watching some Nilaus at the moment, but I think it's too narrow for not having Vehicle Snap.
In my first map, I planned for much wider paths, and perhaps I should go back to that and develop my style.
There are a lot of considerations to balance
  * Where does power and lighting go?
  * How big should an intersection be to turn easily?
  * Should there be turnarounds at intervals to allow me to double-back more easily?
  * What should the road shoulders looks like aesthetically?
  * How do items and fluids cross the path?

## General Clean-up

These are specific notes about problems in my blueprints.

  * Smelting columns should have separate head and bulk pieces to allow re-configuring i/o directions.
    Icon layout could be `coal, ore, l/r, l/r`.
    Also, an input underground built-in would be nice, even if it's two tiles wider (they'll tile away for god's sake!).
  * In the station-enabler, I could use an inserter loop instead of a belt loop, which would increase responsiveness.
    Alternately, I may be able to just use a constant combinator instead of the inserter(s).
  * I dunno how I mucked up my stone smelting ratio.
    Regardless, I should design something that takes two belts of stone in and produces one belt of brick out.
    Perhaps coal and bricks on one belt, stone on another, but that has implications for how it can connect to other columns.
    Perhaps connection with other columns is not a design consideration except early-game.
  * Storefront inserters didn't pick up underground pipes correctly.
  * Munitions factory needed a _gears_ input, no thank you!
  * Storefront need a small circuit to serve as inventory management (see how many are still requested by mousing over a combinator).
  * Pipes&Power mall should use blue assemblers.
  * Miner assembler in the Automation mall doesn't have its output condition set.
  * Central train station could use a maintenance path near the train heads.
    In the same place should be chests for recycling train input materials (or a single set of chests that gets routed in).
  * I don't need so many stack inserters to compress a belt [see link](https://www.reddit.com/r/factorio/comments/imyqw2/compressed_blue_belt_and_stack_insesrters_stack/).
  * Sushi science entrance had strange behavior: mistake in blueprint, or problem when downgrading blue to red belts?
  * Multitool could use a hook-up to the storefront.
  * There's space for another assembler in the multitool behind the cargo wagon: could be very helpful for pipes->engines->electric engines->bot frames.
  * The multitool could use a chest on the front for additional items --- made in bulk elsewhere, or oddly-specific.
  * Double-check stack override is set correctly, including on asm outputs.
  * Starter multitool should not have spare gear/GC chests: they're too expensive to stockpile with hand-feeding.
  * There's a weird spare splitter and undergrounds in one of the science modules.
  * The station load/unloaders don't actually tessellate well---mostly b/c they put their chest contents onto the station-wide network.
  * Blue science is missing a steel belt for the engines!
  * Outputs from gold science's engines are backwards (I swear I tested these <.<).
  * Science build needs fast inserters in places; there's no reason to not use them everywhere.
  * Purple science was unable to deliver enough rails, so I upgraded that belt to red, and then also expanded rail assemblers.
  * Munitions mall makes too few munitions esp. of rockets and uranium ammo; split into multiple modules
