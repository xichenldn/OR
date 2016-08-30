show "loading maths library..."; 
system"l lib/maths.q";
show "loading dtm library..."; 
system"l lib/dtm.q";
.dtm.datapath:` sv hsym[`$"/"sv "\\"vs (-1_raze system"echo %CD%")],`data;
.dtm.t:60;
.dtm.T:60;
.dtm.persistData:{(` sv .dtm.datapath,`$y,"/") set x};
/t:([]arrival:0.6 0.2 0.7 0.8;service:0.2 0.2 0.2 0.2;space:100;exhaustive:0b;tsf:0;sla:0.8);
t:([]arrival:0.2 0.2 0.5 0.6 0.7 0.8 0.9 0.4 0.5 0.2 0.4 0.5 0.6 0.6 0.3 0.2;service:16#0.2;space:100;exhaustive:0b;tsf:0;sla:0.8);
show "input table as...";
show t;
show "output result as...";
/show select avg sl,avg s by 18000 xbar i from .dtm.GeomDTMISA t;
show select avg sl,avg s by 3600 xbar i from res:.dtm.GeomDTMISA t; / to display hourly summary
/.dtm.persistData[res;"test1"]




