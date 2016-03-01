/@file maths library

/@desc factorial function
/@example .maths.fact[12]
.maths.fact:{prd "f"$1_til x+1};

/@desc integer power funcion
/@example .maths.power[2;10]
.maths.power:{prd "f"$y#x};

/@desc poisson function, returns the Poisson distribution
/@example .maths.poisson[10;10;0b]
.maths.poisson:{[mean;x;cumulative]
  poisson:{[mean;x](exp[neg mean] * .maths.power[mean;x])%.maths.fact x};
  :$[cumulative;sum(poisson[mean;]each til x+1);poisson[mean;x]];
 };


/@desc combin(number,number_chosen), returns the number of combinations for a given number of items
/.maths.combin[100;2]
.maths.combin:{[n;k]t:(n-k)_1+til n;r:1f;l,:((i:count t)-count l:reverse -1_2+til k)#1;do[i;r:r*t[i-1]%l[i-1];i-:1];r};

/@desc binomdist(number_s,trials,probability_s,cumulative), returns the individual term binomial distribution probability
/@example .maths.binomidist[10;100;0.5;1b]
.maths.binomidist:{[x;n;p;cumulative] 
  binomdist:{[n;p;x].maths.combin[n;x]*.maths.power[p;x]*.maths.power[1-p;n-x]};
  :$[cumulative;sum(binomdist[n;p;]each til x+1);binomdist[n;p;x]];
 };

/@desc weighted moving average,in an n-day WMA the latest day has weight n, the second latest n . 1, etc, down to zero
/@example update wma:.maths.wma[20;price] from select size wavg price by time.minute from trade where date=max date,sym=`VOD.L will give you 20 mins weighted moving average of VOD.L vwap price
.maths.wma:{{(1+til x) wavg y(z+til x)}[x;y;]each til count y};

/@desc exponential moving average function,applies weighting factors which decrease exponentially
/@example: update ewma:.maths.ewma[20;price] from select size wavg price by time.minute from trade where date=max date,sym=`VOD.L will give you 20 mins weighted moving average of VOD.L vwap price
.maths.ewma:{{y+x*z-y}[x:2%1+x]\[y]};

/@desc autocorrelation function, returns the correlation of a data set with itself, offset by n-values.
/@example: .maths.acf[12;exec price from  select price from trade where date=max date,sym=`VOD.L],returns the autocorrelation value up to lag 12
.maths.acf:{{(sum prd each(( x _y)-m),'(((neg x)_y)-m:avg y))% (var y) * count y}[;y] each til 1+x};

/@desc partial autocorrelation function, estimated using the Yule Walker Equations
.maths.pacf:{p:.maths.acf[x;y];{[x;p]((p@1+til x) lsq {[x;y;p] p@reverse {(y _ reverse x), (y-z) _ x - 1}[x;;y]each 1+til y} [1+til x;x;p])@x-1}[;p]each 1+til x};

/@desc the value of PI
.maths.pi:{2*asin 1}[];

/@desc simple Exponential Smooting Function
.maths.es:{{y+x*z-y}[x]\[y]}; 

/@desc fit an autoregressive time series model to the data by ordinary least squares, returns the parameter vector
.maths.arOLS:{[x;p;intercept] X:{[x;p;y] p _ y xprev x}[x;p;] each 1+til p;Y:p _ x;if[intercept;X,:(count Y)#1f];Y lsq X};

/@desc function to generate log normal distribution
.maths.logNorm:{[m;v;x] mu:log((m*m)%sqrt(v+m*m)); sigma:sqrt(log(1+v%(m*m)));:exp(mu+sigma*(sqrt(-2*log(x?1f)))*cos(2*.maths.pi*x?1f))};

/@desc function to generate beta distribution
.maths.betaRand:{[a;b;n] x:prd each (n,a)#(n*a)?1f; y:prd each (n,b)#(n*b)?1f;:log[x]%log[x]+log[y]};