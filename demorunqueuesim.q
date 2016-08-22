show "loading discrete event simulation library..."; 
system"l lib/des.q";
show "loading queueing simulation library..."; 
system"l lib/queue.q";
t:([]arrival:0.6 0.2 0.7 0.8;service:0.2 0.2 0.2 0.2;servers:5 5 5 5);
.queue.simInterval:1200f;
.queue.runTimes:10;
show "input table as...";
show t;
show "output result as...";
res:.queue.runSim t;
show res;
show "output summary"
show select serviceLevel:(sum waitTime<=0)%count i,avgWaitTime:avg waitTime,avgServTime:avg servTime,numArrivals:count[arrivalTime]%count distinct r by 1200 xbar arrivalTime from select arrivalTime:t[0],waitTime:t[1]-t[0],servTime:t[2]-t[1] by id,r from res where not null t
