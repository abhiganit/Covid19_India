function [TM0,YM0,TM,YM,TML,YML] = RunSimA(wr,r0,tm)
close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'RLAC1','RLAC2','RLAC3','RLAC4','RLAC5'};
%wr = 1;
%% Get parameters
% Getting model parameters along with calculating transmission
% parameter (\beta) for India that will be applied to each state.
State = RLA{wr};
% Reproduction number (Change this to assume different R0)
R0E=r0;
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);
% Note: population parameter (P) we get here is for all India. The
% P vector that has population for each state being considered will
% be constructed.

%% Parameterization and Initialization of state-specific model
load IndiaDemo
names = Pop_Dist.Properties.VariableNames;
Pop = [];
States = names(:,2*wr:2*wr+1);
%[M,M2,Popt] = DemoIndia(Amin,States(1),0);
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end

MA = M; MH = M2;
% Number of states being cosnidered
Ss = length(States);

% Incorporate connectivity between states among general contact
% patterns
CP = [0.021605997,0.08710681,0.039846154,...
      0.142222222,0.123698899]; % Corresponding contact rates
cpd = CP(5);
CM = [1,cpd;cpd,1]; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among states for people in isolation
M2 = kron(eye(Ss),M2);


noi = [1,0];% Number of infections seeding infection
IC=zeros(11*A*Ss,1);        % Initialzing initial conditions
IC(1:A*Ss)=Pop;             % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)=noi';   % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(11*A*Ss));

%% without any lockdown (If no intervention)
tl = 365; % total time to run
[TM0,YM0]=ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run initial period without 21 days lockdown
tbl = 20; % time before lockdown
[TM1,YM1]=ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [0:tbl],IC,options);

% Run 21 days lockdown
% Get parameters with lockdown
Mx = M2;
M2x = M2;
IC = YM1(end,:);
ttl = 21; % time till lockdown
[TM2,YM2] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown
IC = YM2(end,:);
tal = 324;

[TM3,YM3] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
CM = [1,0;0,1]; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(MA,Ss);
M = CM.*M;

IC = YM2(end,:);
tal = 324;
[TM4,YM4] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));

% continuing lockdown in red light area
TML = vertcat(TM1,TM2(2:end),TM4(2:end));
YML = vertcat(YM1,YM2(2:end,:),YM4(2:end,:));
end
