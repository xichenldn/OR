/@desc function to generate arrival transition matrix
/@example .dtm.arr[L;lamda]
/@example .dtm.arr[200;0.5]
.dtm.arr:{0^{:v,1-sum v:y xprev x}[.maths.poisson[y;;0b]'[til x]]'[til x+1]}; 

/@desc function to generate departure transition matrix
/@example .dtm.dep[L;s;mu]
/@example .dtm.dep[100;5;0.8]
.dtm.dep:{(x,x)#{@[(n:count m)#0f;i;:;.maths.binomidist[;;z;0b]'[d i;m[i:where (d>=0)&(d:(-). x)<=m:first[x]&y]]]}[flip cross/[2#enlist til x:x+1];y;z]};


/@desc function to generate abandon transition matrix
/@example .dtm.abn[L;s;q]
/@example .dtm.abn[100;5;0.8]
.dtm.abn:{(x,x)#{@[(n:count d)#0f;i;:;.maths.binomidist[;;z;0b]'[d i;((y|first[x])-y) i:where((last[x]>=y)&0<=d:(-). x)|(=). x]]}[flip cross/[2#enlist til x:x+1];y;z]};


/@desc basic Geometrix DTM function 
/@desc see http://link.springer.com/article/10.1007/s10479-015-2058-3/fulltext.html
/@args use a dictionary argument `space`servers`arr`serv`abn`t`T`tsf`state
/@args space, maximum size allowed in the queueing system
/@args servers, number of servers
/@args arr, arrival rate per period T*t
/@args serv, service rate per period T*t
/@args abn, abandoment rate per period T*t
/@args t, number of steps per minute
/@args T, number of minutes per period
/@args tsf, target service level factor 
/@args state, initial state of the system
/@example 
.dtm.geomDTM:{[a] 
  /get varible from dictionary
  L:a`space; s:a`servers;  lamda:a`arr; T:a`T; t:a`t; mu:a`serv; q:a`abn; tsf:a`tsf; exh:a`exhaustive ; pState:a`state;
  /generate arrival transition matrix
  arr:.dtm.arr[L;lamda%t]; 
  /generate departure transition matrix
  dep:.dtm.dep[L;s;mu%t];
  /generate departure transition matrix for calculating virtual service level and virtual waiting time, TODO: code can be improved
  deps:.dtm.dep[L;s;mu%60];
  if[not null q; /if abandon rate is provided
    /generate abandon transition matrix
    abn:.dtm.abn[L;s;q%t];                
    /generate abandon transition matrix for calculatding virtual service level and virtual waiting time, code can be improved
    abns:.dtm.abn[L;s;q%60]; 
    /calcuate virtual departure transition matrix based on tsf (service + abandon)
    dp:{(mmu/)(z#enlist x mmu y)}[abns;deps;tsf];
  ];
  /calcuate virtual departure transition matrix based on tsf (service only)
  if[null q;dp:{(mmu/)(y#enlist x)}[deps;tsf]];
  /if null states, init states space
  if[all null pState`states;pState[`states]:1.,L#0f];
  /this is for the exhaustive policy adjustment
  if[exh & s<pState`s;
     pState[`states]:{[x;y;z] (x til z),(sum x z +  til 1+y-z),(0f^ (neg y-z) xprev (1+z) _ x)}[pState`states;pState`s;s];
  ]; 
  v:$[not null q;(3*t*T)#((`float$abn);(`float$dep);(`float$arr));(2*t*T)#((`float$dep);(`float$arr))];
  /apply all transition matrix, calculate the pState->state
  states:mmu\[pState`states;v];
  res:select from (flip `sl`sl_states`tsf`s`g`lamda`a`n`states!(sum each r[;til s];r:{[x;dp;tsf]$[tsf>0;r:x mmu dp;r:x];r}[;dp;tsf] each states;tsf;s;lamda;mu;q;(til L+1) wsum/:states; states))where 1=i mod 2;
  :res;           
 };


/@desc use Geometrix DTM function to generate the system states
/@args use a table argument 
/@example .dtm.runGeomDTM ([]arrival:0.6 0.2 0.7 0.8;service:0.2 0.2 0.2 0.2;servers:2 5 10 2;space:100;exhaustive:0b;tsf:0)
.dtm.runGeomDTM:{[t]
  raze(enlist(`sl`s`n`states!(0n;0N;0n;0n))){.dtm.geomDTM[`space`servers`arr`serv`abn`t`T`tsf`exhaustive`state!(y`space;y`servers;y`arrival;y`servers;y`abandoment;60;300;y`tsf;y`exhaustive;last x)]}\t
 };

/@desc use Geometrix DTM function + ISA algorithm to generate the server suggestions
/@args use a table argument 
/@example .dtm.GeomDTMISA ([]arrival:0.6 0.2 0.7 0.8;service:0.2 0.2 0.2 0.2;space:100;exhaustive:0b;tsf:0)
.dtm.GeomDTMISA:{[t]
   :raze (enlist (`sl`s`n`states!(0n;0N;0n;0n)))
   {
   /initial server set as 800 (a very large value)
    s_d:s:800;
    a:b:1b;
    asl:()!();
    while[a;
     r:.dtm.geomDTM[`space`servers`arr`serv`abn`t`T`tsf`exhaustive`state!(y`space;s;y`arrival;y`service;y`abandoment;.dtm.t;.dtm.T;y`tsf;y`exhaustive;last x)];
     asl:asl,(enlist s)!(enlist avg r[`sl]);
     if[not b;a:0b];
     m:2+max -1,where y[`sla]>=sums avg r[`sl_states];
     n:ceiling avg m,s;
     o:min (where (asc asl)>=y[`sla]);
     p:max (where (desc asl)<y[`sla]);
     /$[(s_d<>m)&s<>m;[s_d:s;s:m];(s_d=m)&1<abs(s-m);[s:ceiling avg m,s];-1=s-m;[s_d:s;s:m];a:0b];
     $[not m in key asl;s:m;not n in key asl;s:n;1<o-p;s:o-1;[s:o;b:0b]];
     ];r}\t;
 };



