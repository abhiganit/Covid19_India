close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);

%% Get parameters
% Getting model parameters along with calculating transmission
% parameter (\beta) for India that will be applied to each state.
State = 'India';
% Reproduction number (Change this to assume different R0)
R0E=2;
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);
% Note: population parameter (P) we get here is for all India. The
% P vector that has population for each state being considered will
% be constructed.

%% Parameterization and Initialization of state-specific model
load IndiaDemo
names = Pop_Dist.Properties.VariableNames;
Pop = [];
States = names(:,3:end);
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end
% Number of states being considered
Ss = length(States);

% Incorporate connectivity between states among general contact patterns
load spatial
sm = S;
clear S
CM = sm; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among states for people in isolation
M2 = kron(eye(Ss),M2);


% Which states to seed in? (Delhi, Maharashtra, Kerala)
idx = find(contains(States,{'ANDHRAPRADESH','NCTOFDELHI',...
                    'HARYANA', 'JAMMU_KASHMIR',...
                    'KARNATAKA','MAHARASHTRA',...
                    'PUNJAB','RAJASTHAN',...
                    'TAMILNADU','TELANGANA'...
                    'UTTARPRADESH'}));
%noi = ones(1,Ss);% Number of infections seeding infection
                 %noi(1,8) = 5;
noi = zeros(1,Ss);% Number of infections seeding infection
noi(idx) =1;
                 %noi(1,8) = 5;
IC=zeros(10*A*Ss,1);        % Initialzing initial conditions
IC(1:A*Ss)=Pop;             % Susceptible population
IC(2:4:A*Ss)= IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)=noi';   % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(10*A*Ss));

%% without any lockdown (If no intervention)
tl = 365; % total time to run
[TM0,YM0]=ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run initial period without 21 days lockdown
tbl = 20; % time before lockdown
[TM1,YM1]=ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss),...
                  [0:tbl],IC,options);

% Run 21 days lockdown
% Get parameters with lockdown
Mx = M2;
M2x = M2;
IC = YM1(end,:);
ttl = 21; % time till lockdown
[TM2,YM2] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl:tbl+ttl],IC,options);

%% After lockdown
% Back to status quo
IC = YM2(end,:);
tal = 324;
[TM3,YM3] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);


% Continue school closure (lockdown=2)
[M,M2,Popt] = DemoIndia(Amin,State,2);
CM = sm; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among states for people in isolation
M2 = kron(eye(Ss),M2);
IC = YM2(end,:);
tal = 324;
[TM4,YM4] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Continue Work from home (for 50% of workforce) (lockdown=3)
[M,M2,Popt] = DemoIndia(Amin,State,3);
CM = sm; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among states for people in isolation
M2 = kron(eye(Ss),M2);
IC = YM2(end,:);
tal = 324;
[TM5,YM5] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);


% Continue school closure and work from home for 50% of workforce (lockdown=4)
[M,M2,Popt] = DemoIndia(Amin,State,4);
CM = sm; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among states for people in isolation
M2 = kron(eye(Ss),M2);
IC = YM2(end,:);
tal = 324;
[TM6,YM6] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);


% Joining all results
% Only 21 days lockdown
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));
% School closure followed by 21 days lockdown
TMS = vertcat(TM1,TM2(2:end),TM4(2:end));
YMS = vertcat(YM1,YM2(2:end,:),YM4(2:end,:));
% Work from home followed by 21 days lockdown
TMW = vertcat(TM1,TM2(2:end),TM5(2:end));
YMW = vertcat(YM1,YM2(2:end,:),YM5(2:end,:));
% Both school closure and work form home followed by 21 days lockdown
TMSW = vertcat(TM1,TM2(2:end),TM6(2:end));
YMSW = vertcat(YM1,YM2(2:end,:),YM6(2:end,:));

%% Index for dxdt and x to make readability of code easier
S=     [1:A*Ss];    % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
IA=2*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=3*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=4*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=5*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=6*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 7*A*Ss+[1:A*Ss]; % Hospitalization
C= 8*A*Ss+[1:A*Ss]; % Need ICU
D= 9*A*Ss+[1:A*Ss]; % Deaths


%% Save state wise data for infections over time, hospitalization,
%% deaths
SD = {}; ED ={};
IAD={}; IHD = {}; IND={}; QHD = {}; QND = {};
HD = {}; CD = {};
DD = {};
for i = 1:Ss
    SD{i} = S((i-1)*4+1:(i-1)*4+4);
    ED{i} = E((i-1)*4+1:(i-1)*4+4);
    IAD{i} = IA((i-1)*4+1:(i-1)*4+4);
    IHD{i} = IH((i-1)*4+1:(i-1)*4+4);
    IND{i} = IN((i-1)*4+1:(i-1)*4+4);
    QHD{i} = QH((i-1)*4+1:(i-1)*4+4);
    QND{i} = QN((i-1)*4+1:(i-1)*4+4);
    HD{i} = H((i-1)*4+1:(i-1)*4+4);
    CD{i} = C((i-1)*4+1:(i-1)*4+4);
    DD{i} = D((i-1)*4+1:(i-1)*4+4);
end





%% Plots
national_plots(A,Ss,TM0,TM,TMS,TMW,TMSW,YM0,YM,YMS,YMW,YMSW)

states_plots(A,Ss,TM0,TM,TMS,TMW,TMSW,YM0,YM,YMS,YMW,YMSW,States)