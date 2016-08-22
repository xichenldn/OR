/.des.init[];
/.queue.init[];
/.queue.run[`servers`rates`interval!((1#12;1#0f);(10#720f),'(10#240f);1200)]
/.des.status


/@desc queueing model simulation based on discrete event simulation library
/ init function 
.queue.init:{[]
  .queue.server:0N;
  .queue.status:([]id:0Nj;t:0n;event:`g#enlist `;queue:0;serv_idle:0);
 };

/B events registry
.queue.arrival:{[x;y] /.queue.arrival is a B event 
   /insert the arrival calls into the status table, increment the queue  
  `.queue.status upsert update id:x,t:y, event:`.queue.arrival, queue:queue+1 from last .queue.status;
 };

.queue.abandon:{[x;y] /.queue.abandon is a B event
   /insert the arrival calls into the status table, increment the queue
  `.queue.status upsert update id:x,t:y, event:`.queue.abandon, queue:queue-1 from last .queue.status;
 };


.queue.setServ:{.queue.st:x}; /B event - set service time
.queue.setArr:{.queue.iat:x}; /B event - set arrival time

.queue.finishserv:{[x;y] `.queue.status upsert update id:x, t:y,event:`.queue.finishserv, serv_idle:serv_idle+1 from last .queue.status;};
.queue.finishservExhaustive:{[x;y] `.queue.status upsert update id:x, t:y,event:`.queue.finishservExhaustive from last .queue.status;};


/C event registry
.queue.beginserv:{[x] 
   .queue.lstatus:last .queue.status;
   if[b:get string x; /x is the evaluation rules for the C event
      n:count t:(min (q;srv))#0!select from (select by id from .queue.status) where event=`.queue.arrival;
      `.queue.status upsert update t:.queue.lstatus[`t],event:`.queue.beginserv,queue:q-n,serv_idle:srv-n from t;
      st:.queue.lstatus[`t]+exec st from .queue.calls where id in t[`id];
      .des.jobs:update `g#typ from delete from .des.jobs where f in `.queue.abandon,(first each args[;;0]) in t[`id];
      .des.addBulk[`B;st;`.queue.finishserv;flip(t[`id];st)];                /schedule service finish time
   ];
 };

.queue.setServer:{[x]
  .queue.server:$[not null .queue.server;.queue.server;0];
  .queue.lstatus:last .queue.status;     /set for exhaustive policy
   /check if there are any exhausitive servers
   if[0>s:.queue.lstatus[`serv_idle] - .queue.server-x;
      /if yes, randomly pick from the serving servers, and apply exhaustive policy, .e.g. get the server offline after the last serving.
      t:select from .des.jobs where `.queue.finishserv=f;
      while[(neg s)>count distinct n:(neg s)?count t];
       t:update f:`.queue.finishservExhaustive from t where i in n;
      .des.jobs:update `g#typ from t,delete from .des.jobs where id in t`id;     /update the .des.jobs table, TODO need to add an interface in des.q to do so
     ];
    s:0|s;
  .queue.status:update serv_idle:s from .queue.status where i=last i;
  .queue.server:x;
 };

.queue.run:{[a]
  .des.addBulk[`B;a[`servers;1];`.queue.setServer;a[`servers;0]];  
  .des.addC[`.queue.beginserv;`$"(0<q:.queue.lstatus[`queue]) & (0<srv:.queue.lstatus[`serv_idle])"];  
  .queue.calls:.queue.genCalls[a];
  .queue.calls:update id:.des.id+til count i from .queue.calls;
  .des.addBulk[`B;.queue.calls[`at];`.queue.arrival;flip .queue.calls[`id`at]];
   while[count select from .des.jobs where not `C=typ;.des.ts[]];     /run until no `B jobs left
  };

.queue.genCalls:{[a]
   thin:max (a`rates)[;0];
   interval:a`interval;
   n:count (a`rates)[;0];
   res:enlist 0f;
   while[(max res)<n*interval;res,:(max res)+sums neg(interval%thin)*(log (ceiling n*interval%thin)?1f)];
   res:1_res[where res<n*interval]; /get all arrival times
   i:((a`rates)[(`float$interval*til n) bin res]);           /bin the arrival times based on the interval
   res:res,'(neg interval%i[;1])* log 1 - (c:count res)?1f;  /get service time based on the rate
   res*:not (c?1f)>i[;0]%thin; /apply thinning method
   :flip `at`st!flip res@where not res[;0]=0f;               /return as table
 };


