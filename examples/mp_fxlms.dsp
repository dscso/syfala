declare name    "MultiPoint FxLMS algorithm";
declare version "1.0";
declare author  "Pierre Lecomte";
declare author  "Loic Alexandre";
declare license "CC-BY-NC-SA-4.0";

import("stdfaust.lib");

N = 8;
coeffs = si.bus(N);
in = 4;
out = 4;
in_out = si.bus(in*out);

freq_band = fi.bandpass(4,hslider("s:[0]Signal/s:[2]Noise/[2]Low frequency cut", 100,50,10000,1), hslider("s:[0]Signal/s:[2]Noise/[3]High frequency cut", 500,50,10000,1));
noise = (no.noise:freq_band)*hslider("s:[0]Signal/s:[2]Noise/[1]Volume" , 1,0,10,0.1);
sine_freq = hslider("s:[0]Signal/s:[1]Sine/[2]Frequency",300,50,10000,10);
sine = os.osc(sine_freq)*hslider("s:[0]Signal/s:[1]Sine/[1]Volume" , 1,0,10,0.1);
signal = (sine*checkbox("s:[0]Signal/s:[1]Sine/[0]On/Off"), noise*checkbox("s:[0]Signal/s:[2]Noise/[0]On/Off")):>_*(1-checkbox("s:[0]Signal/[0]Mute")); // Reference signal
x = (signal:_<:(_,_,_)); // Input signal

// Convergence coefficients
mu = -0.001*checkbox("a:[1]ANC/[0]On/Off"); 
lambda = 0.9;
delta = 1e-5;

reset = 1-button("a:[1]ANC/[1]reset");

// Adapted filters
filter_adapt(n) = (si.bus(n),(_<:(si.bus(n)))):ro.interleave(n,2):sum(i, n, (_,@(i):*));

H = (si.bus(in*N):par(i,in*N,_*reset)),(_<:par(i, in, _)):seq(i,in-1,si.bus(N*(i+1)+i), ro.crossn1(N*in-N*(i+1)), si.bus(out-(i+1))):par(i,in,((si.bus(N)<:si.bus(2*N)),_):(si.bus(N),filter_adapt(N))):seq(i,out-1, si.bus(N*in - (N*(i+1)) + out-(i+1)-1), ro.cross1n(N*(i+1)), si.bus(1+i));

C11 = fi.fir((0.15426163621023734,0.13990026583297194,0.3419448213631925,-0.08147998658519595,-1.4323239839194681,0.17556805486637117,0.02613819048862478,-0.21812066850963366,-0.3171735506873301,-0.29448115138838665,0.0802860847983312,-0.1880481314785973,0.4858874113271277,0.39602445743367076,0.1573725754545663,0.09997056217282939,0.11325260555188824,-0.007982253198280576,-0.00115520267938809,-0.2972004835130559));
C12 = fi.fir((0.03780310849938437,0.22163268988397747,-0.03879051784955264,0.5210354827503156,-0.25049625564422984,-0.8931238656470573,0.2723427944095396,0.07376972055940362,-0.10755564953825623,-0.3102237117627864,-0.04564230381297856,0.13902600773635954,0.29153019878348285,0.19458492178366546,0.1496687642002132,0.29077637768500697,0.18863261439314344,0.023911449509532546,-0.021232476740983854,-0.05702819311744575));
C13 = fi.fir((-0.10638297605146899,0.33734869557486125,-0.13760338294008975,0.5846709363147123,-0.39242597593765005,-0.8246977432459265,0.37254102266156797,-0.03135426357448811,-0.09948961841944677,-0.1451029344865057,-0.12990034700015549,0.0276192711466825,0.32396558287164273,0.06557207609692343,0.12982060549711252,0.356631342324756,0.04981130507022007,0.022052445376414112,-0.12493617018897557,-0.02877739909089169));
C14 = fi.fir((-0.17174361053304715,0.47782370509086514,0.0009718291000705981,0.6751679340429494,-0.3080307980749689,-1.0199111687356635,0.3413798360539741,0.1703587265494544,-0.3571846616554922,-0.16299842928613995,0.01906514932072645,-0.08006430607207694,0.7274043107295661,0.1213674871095215,0.3231846885719528,0.2797943120280541,0.1779574691309212,-0.030935807011217877,0.03015302300706324,0.010856371439442137));
C21 = fi.fir((0.03780310849938437,0.22163268988397747,-0.03879051784955264,0.5210354827503156,-0.25049625564422984,-0.8931238656470573,0.2723427944095396,0.07376972055940362,-0.10755564953825623,-0.3102237117627864,-0.04564230381297856,0.13902600773635954,0.29153019878348285,0.19458492178366546,0.1496687642002132,0.29077637768500697,0.18863261439314344,0.023911449509532546,-0.021232476740983854,-0.05702819311744575));
C22 = fi.fir((-0.10638297605146899,0.33734869557486125,-0.13760338294008975,0.5846709363147123,-0.39242597593765005,-0.8246977432459265,0.37254102266156797,-0.03135426357448811,-0.09948961841944677,-0.1451029344865057,-0.12990034700015549,0.0276192711466825,0.32396558287164273,0.06557207609692343,0.12982060549711252,0.356631342324756,0.04981130507022007,0.022052445376414112,-0.12493617018897557,-0.02877739909089169));
C23 = fi.fir((-0.17174361053304715,0.47782370509086514,0.0009718291000705981,0.6751679340429494,-0.3080307980749689,-1.0199111687356635,0.3413798360539741,0.1703587265494544,-0.3571846616554922,-0.16299842928613995,0.01906514932072645,-0.08006430607207694,0.7274043107295661,0.1213674871095215,0.3231846885719528,0.2797943120280541,0.1779574691309212,-0.030935807011217877,0.03015302300706324,0.010856371439442137));
C24 = fi.fir((-0.22763473623777328,0.09612096165207512,-0.04129638149914681,0.022034978982099464,-0.06633501113800817,-0.12767508581695483,0.862238785758715,0.06363764228707743,0.49301285195393274,0.7158611043018355,0.3064465301459277,-0.01491106723611113,-0.17418753058273115,0.05335480972613289,-0.056222046520141025,-0.19324720248499094,0.32952822221710704,0.0020471693236077115,-0.06582877938917835,-0.018503989844062502));
C31 = fi.fir((-0.10638297605146899,0.33734869557486125,-0.13760338294008975,0.5846709363147123,-0.39242597593765005,-0.8246977432459265,0.37254102266156797,-0.03135426357448811,-0.09948961841944677,-0.1451029344865057,-0.12990034700015549,0.0276192711466825,0.32396558287164273,0.06557207609692343,0.12982060549711252,0.356631342324756,0.04981130507022007,0.022052445376414112,-0.12493617018897557,-0.02877739909089169));
C32 = fi.fir((-0.17174361053304715,0.47782370509086514,0.0009718291000705981,0.6751679340429494,-0.3080307980749689,-1.0199111687356635,0.3413798360539741,0.1703587265494544,-0.3571846616554922,-0.16299842928613995,0.01906514932072645,-0.08006430607207694,0.7274043107295661,0.1213674871095215,0.3231846885719528,0.2797943120280541,0.1779574691309212,-0.030935807011217877,0.03015302300706324,0.010856371439442137));
C33 = fi.fir((-0.22763473623777328,0.09612096165207512,-0.04129638149914681,0.022034978982099464,-0.06633501113800817,-0.12767508581695483,0.862238785758715,0.06363764228707743,0.49301285195393274,0.7158611043018355,0.3064465301459277,-0.01491106723611113,-0.17418753058273115,0.05335480972613289,-0.056222046520141025,-0.19324720248499094,0.32952822221710704,0.0020471693236077115,-0.06582877938917835,-0.018503989844062502));
C34 = fi.fir((-0.008074675445644885,0.05335844949370954,0.09347478934809252,0.03268196091139201,-0.09588717007433799,0.5924451897332562,0.20904594937954638,0.05749359118405339,0.5261434764451411,-0.09010122541780516,0.1596039769479708,0.030309237786168536,-0.01867340116769727,0.0070668270489425596,-0.17656162344230086,0.0032246237128353786,-0.03952089146646609,0.04750488459802345,0.004396452269050633,-0.10221461211128618));
C41 = fi.fir((-0.17174361053304715,0.47782370509086514,0.0009718291000705981,0.6751679340429494,-0.3080307980749689,-1.0199111687356635,0.3413798360539741,0.1703587265494544,-0.3571846616554922,-0.16299842928613995,0.01906514932072645,-0.08006430607207694,0.7274043107295661,0.1213674871095215,0.3231846885719528,0.2797943120280541,0.1779574691309212,-0.030935807011217877,0.03015302300706324,0.010856371439442137));
C42 = fi.fir((-0.22763473623777328,0.09612096165207512,-0.04129638149914681,0.022034978982099464,-0.06633501113800817,-0.12767508581695483,0.862238785758715,0.06363764228707743,0.49301285195393274,0.7158611043018355,0.3064465301459277,-0.01491106723611113,-0.17418753058273115,0.05335480972613289,-0.056222046520141025,-0.19324720248499094,0.32952822221710704,0.0020471693236077115,-0.06582877938917835,-0.018503989844062502));
C43 = fi.fir((-0.008074675445644885,0.05335844949370954,0.09347478934809252,0.03268196091139201,-0.09588717007433799,0.5924451897332562,0.20904594937954638,0.05749359118405339,0.5261434764451411,-0.09010122541780516,0.1596039769479708,0.030309237786168536,-0.01867340116769727,0.0070668270489425596,-0.17656162344230086,0.0032246237128353786,-0.03952089146646609,0.04750488459802345,0.004396452269050633,-0.10221461211128618));
C44 = fi.fir((0.007688745372912309,0.0364270504547291,-0.008398074436020054,0.001767904175039259,-0.024205193685800444,-0.1533003193292018,0.6141737147441828,0.1716614602737368,0.287926071867546,0.5738403845921116,0.03442628828702332,0.1613055983835583,0.024656463192004853,0.03560694233842785,-0.0722974370752899,-0.01825922942350815,-0.1267935072355967,0.1165769913064513,0.07862075575034765,-0.19031735778146));


C_stack = (_:C11), (_:C12), (_:C13), (_:C14), (_:C21), (_:C22), (_:C23), (_:C24), (_:C31), (_:C32), (_:C33), (_:C34), (_:C41), (_:C42), (_:C43), (_:C44);

C_hat = _<:par(i,in*out,_):C_stack:par(i,in*out,buffer):ro.interleave(N,in*out):par(i,N,ro.interleave(in,out):par(i,out,(par(i,in,_):>_))); 

buffer = _<:par(i,N,@(i)); // To obtain x_n the reference signal at time n

norm2(n) = par(i,n,^(2)):>sqrt:_^(2); 

E = par(i,in,_<:(_,_)):par(i,in,(((_':_^(2):_*(1-lambda)),(*(lambda))):>_));

LMS = ((par(i,in*N,_<:(_,_)):ro.interleave(2,N*in):(si.bus(N*in),norm2(in*N))), (par(i,in,_<:(_,_)):ro.interleave(2,in):(si.bus(in),E))):(si.bus(in*N),ro.cross1n(in), si.bus(in)):(si.bus(in*N),par(i,in,_*mu), (((_<:par(i,in,_)), si.bus(in)):ro.interleave(in,2):par(i,in,(_,_):>_):par(i,in,_+delta))):(si.bus(N*in),(ro.interleave(in,2):par(i,in,/))):(si.bus(in*N),par(i,in,_<:par(i,N,_))):(ro.interleave(N*in,2):par(i,in*N,*)):ro.interleave(in,N);

// 4 inputs / 6 outputs
// INPUTS : 4 microphones
// OUTPUTS : 4 Loudspeaker signals, 1 reference signal, 1 rms error signal

process = ((par(i,in,coeffs), x, par(i,in,_)):(H,C_hat,(ro.cross1n(in):((par(i,in,_<:(_,_)):ro.interleave(2,in)),_))):(si.bus(N*in+out),LMS,(par(i,in,_):>_),_):(par(i,in,si.bus(N)),ro.crossNM(in,in*N),_,_):((ro.interleave(in*N,2):par(i,in*N,+)),si.bus(in),_,_))~(par(i,in,coeffs)):(par(i,in*N,!),si.bus(in),ro.cross1n(1));


