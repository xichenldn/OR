/@desc discrete event simulation library
.des.add:{[typ;st;func;args]                         / [type of job;time;string name of function;inverval ms]
  .des.jobs,:(jb:.des.id;typ;st;func;enlist args);   / add job to jobs table (no scheduling in past)
  .des.id+:1j;                                       / iterate job counter
 };                                                  / return job id (so it can be deleted in future)

.des.addBulk:{[typ;st;func;args]                          / [type of job;time;string name of function;inverval ms]
  jb:.des.id+til max count each (typ;st;func;args);
  `.des.jobs insert (jb;typ;st;func;enlist each args);    / add job to jobs table (no scheduling in past)
  .des.id:1j+max jb;                                      / iterate job counter
 };      

.des.addB:{[st;func;args]              
  .des.add[`B;st;func;args]
 };                                

.des.addC:{[func;args]              
  .des.add[`C;-0w;func;args]
 };                                

.des.run:{                                        / job runner
  st:.z.P;                                        / capture 'now'
  $[count (x`args)0; r:.[get x`f;raze x`args;::]; r:.[get x`f; enlist ();::]];    / protected execution of job
  sr:$[10h=type r;(`$r;());(`OK;enlist r)];                        / status and return value
  .des.status,:(x`id;st;.z.P;x`f;x`args),sr;                        / append to status table
  :$[-1h=type r;r;0b];
 };                                                                 / if boolean, return actual, else, return 0b

.des.ts:{                                                        
  if[count jb:select from .des.jobs where typ=`B,start=min start;        / only process if there are B jobs to fire now
     r:enlist(.des.run@)each jb;                                         /   fire jobs,get results
     jb:flip(flip jb),(enlist `r)!r;                                     /   append results
     .des.jobs:update `g#typ from delete from .des.jobs where typ=`B,start=min start;                /   delete end timed jobs
     jb:select from .des.jobs where typ=`C;                              / always run C events after B events
     r:enlist(.des.run@)each jb;                                         /   fire jobs,get results
     jb:flip(flip jb),(enlist `r)!r;
  ];                                                                     /   append results
 };       

.des.init:{
  .des.id:0j;                                                             / iterator for unique job ids
  .des.jobs:([]id:();typ:`g#();start:();f:();args:());                       / table to contain jobs
  .des.status:([]id:();jobstart:0#0Np;jobend:0#0Np;f:();args:();status:();return:()); / track status of jobs
 };