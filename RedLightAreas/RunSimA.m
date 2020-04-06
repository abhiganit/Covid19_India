close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);

%% Get parameters
% Getting model parameters along with calculating transmission
% parameter (\beta) for India that will be applied to each state.
State = 'Delhi';
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
States = names(:,2:3);
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end

MA = M; MH = M2;
% Number of states being considered
Ss = length(States);

% Incorporate connectivity between states among general contact
% patterns
cpd = 0.0216;
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

% Run after lockdown
IC = YM2(end,:);
tal = 324;

[TM3,YM3] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
CM = [1,0;0,1]; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(MA,Ss);
M = CM.*M;

IC = YM2(end,:);
tal = 324;
[TM4,YM4] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));

% continuing lockdown in red light area
TML = vertcat(TM1,TM2(2:end),TM4(2:end));
YML = vertcat(YM1,YM2(2:end,:),YM4(2:end,:));


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
CC = 10*A*Ss+[1:A*Ss]; % Cumulative cases due to RLA

S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
IA1 = IA(1:4); IA2 = IA(5:end);
IH1 = IH(1:4); IH2 = IH(5:end);
IN1 = IN(1:4); IN2 = IN(5:end);
QH1 = QH(1:4); QH2 = QH(5:end);
QN1 = QN(1:4); QN2 = QN(5:end);
H1 = H(1:4); H2 = H(5:end);
C1 = C(1:4); C2 = C(5:end);
D1 = D(1:4); D2 = D(5:end);


%% Plots
fig = figure('position',[300,200,1600,700]);
st = 1; en = 365;
stl = 15; enl = 50;
subplot(2,1,1)
plot(TM0(st:en),sum(YM0(st:en,[IA IH IN QH QN])/1000000,2),'k', ...
     'LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[IA IH IN QH QN])/1000000,2),'b', ...
    'LineWidth',2.5);hold on;
plot(TML(st:en),sum(YML(st:en,[IA IH IN QH QN])/1000000,2),'g', ...
    'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');
ylabel('Cases(in millions)','Fontsize',16);
legend('No lockdown','lockdown','RLA lockdown');
legend boxoff
subplot(2,1,2)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IA IH IN QH QN]),2),'k','LineWidth',2.5); hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IA IH IN QH QN]),2),'b', ...
     'LineWidth',2.5);hold on;
plot(TML(stl:enl),sum(YML(stl:enl,[IA IH IN QH QN]),2),'g', ...
     'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
ylabel('Cases','Fontsize',16);

hold off

print('Delhi','-dpng')

fig1 = figure('position',[300,200,1600,700])
plot(TM0(st:en),sum(YM0(st:en,[CC]),2),'k', ...
     'LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[CC]),2),'b', ...
    'LineWidth',2.5);hold on;
plot(TML(st:en),sum(YML(st:en,[CC]),2),'g', ...
    'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');
ylabel('Cases','Fontsize',16);
legend('No lockdown','lockdown','RLA lockdown');
legend boxoff

rang = {'#636363','#fdbb84','#bf5b17','#beaed4','#386cb0'}
close all;
fig = figure('position',[300,200,1600,700]);
plot(TM(st:en),sum(YM(st:en,[CC]),2),...
     'color',hex2rgb(rang(3)),...
     'LineWidth',2.5);
hold on;
plot(TML(st:en),sum(YML(st:en,[CC]),2),...
     'color',hex2rgb(rang(4)),...
     'LineWidth',2.5);
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Cases attibutable to Red Light Areas');
ylabel('Cases','Fontsize',16);
lg = legend('No continued closure','Continued closure');
lg.Fontsize =16;
lg.Location = 'northwest';
legend boxoff;
hold off;

print('Lockdown','-dpng')