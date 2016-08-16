show "loading maths library..."; 
system"l lib/maths.q";
show "loading dtm library..."; 
system"l lib/dtm.q";
.dtm.t:60;
.dtm.T:30;
/t:([]arrival:0.6 0.2 0.7 0.8;service:0.2 0.2 0.2 0.2;space:100;exhaustive:0b;tsf:0;sla:0.8);
t:([]arrival:0.2 0.2 0.5 0.6 0.7 0.8 0.9 0.4 0.5 0.2 0.4 0.5 0.6 0.6 0.3 0.2;service:16#0.2;space:100;exhaustive:0b;tsf:0;sla:0.8);
show "input table as...";
show t;
show "output result as...";
/show select avg sl,avg s by 18000 xbar i from .dtm.GeomDTMISA t;
show select avg sl,avg s by 1800 xbar i from .dtm.GeomDTMISA t; / to display half-hourly summary