clear;
close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
% Reproduction number (Change this to assume different R0)
R0E=2;
% State to run
State = 'India';

%% Set up initial conditions
% Get parameters
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);

noi = 5;              % Number of infections seeding infection
IC=zeros(10*A,1);     % Initialzing initial conditions
IC(1:A)=P;            % Susceptible population
IC(2)=IC(2)-noi;      % Seeding infections in age-group 2
IC(A+2)=noi;          % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(10*A));

%% without any lockdown (If no intervention)
tl = 700; % total time to run
[TM0,YM0]=ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run initial period without 21 days lockdown
tbl = 20; % time before lockdown
[TM1,YM1]=ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [0:tbl],IC,options);

% Run 21 days lockdown
% Get parameters with lockdown
[Mx,M2x,Px] = DemoIndia(Amin,State,1);
IC = YM1(end,:);
ttl = 21; % time till lockdown
[TM2,YM2] = ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown
IC = YM2(end,:);
tal = 659;
[TM3,YM3] = ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);
% Joining all results
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));



%% Hospital beds/ICUS etc
% How many beds are available?
%BedsR=round(round(sum(P)*2.2/1000)*0.06);
% % Index for dxdt and x to make readability of code easier
S=     [1:A]; % Susceptible
E=   A+[1:A]; % Incubation
IA=2*A+[1:A]; % Asymptomatic infections
IH=3*A+[1:A]; % Symptomatic severe infections (not isolated)
IN=4*A+[1:A]; % Symptomatic mild infections (not isolated)
QH=5*A+[1:A]; % Symptomatic severe infections (isolated)
QN=6*A+[1:A]; % Symptomatic mild infections (not isolated)
H= 7*A+[1:A]; % Hospitalization
C= 8*A+[1:A]; % Need ICU
D= 9*A+[1:A]; % Deaths

%% Plots

a = 1; b = 700;
subplot(2,1,1)
plot(TM0(a:b),sum(YM0(a:b,[IA IH IN QH QN])/1000000,2),'k','LineWidth',2.5); hold on;
plot(TM(a:b),sum(YM(a:b,[IA IH IN QH QN])/1000000,2),'r', ...
     'LineWidth',2.5);hold on;
a = 15; b = 50;
subplot(2,1,2)
plot(TM0(a:b),sum(YM0(a:b,[IA IH IN QH QN]),2),'k','LineWidth',2.5); hold on;
plot(TM(a:b),sum(YM(a:b,[IA IH IN QH QN]),2),'r', ...
     'LineWidth',2.5);
hold off


% fig = figure('position',[300,200,900,1200])
% a = 1; b = 700;
% subplot(3,1,1);
% plot(TM0(a:b),sum(YM0(a:b,[IH IN])/1000000,2),'k','LineWidth',2.5); hold on;
% plot(TM(a:b),sum(YM(a:b,[IH IN])/1000000,2),'r','LineWidth',2.5); hold on;
% box off;
% set(gca,'LineWidth',2,'tickdir','out','Fontsize',16,'xticklabel',{[]});
% title('Not isolated');

% subplot(3,1,2)
% plot(TM0(a:b),sum(YM0(a:b,[QH QN])/1000000,2),'k','LineWidth',2.5); hold on;
% plot(TM(a:b),sum(YM(a:b,[QH QN])/1000000,2),'m','LineWidth',2.5); hold on;
% box off;
% set(gca,'LineWidth',2,'tickdir','out','Fontsize',16,'xticklabel',{[]});
% title('Isolated');

% subplot(3,1,3)
% plot(TM0(a:b),sum(YM0(a:b,[H C])/1000000,2),'k','LineWidth',2.5); hold on;
% plot(TM(a:b),sum(YM(a:b,[H C])/1000000,2),'c','LineWidth',2.5);
% %hold on
% %plot(TM1,BedsR.*ones(size(TM1)),'color',[0 0.7 0],'LineWidth',2);
% %legend({'Hospitalized','Threshold'});
% %legend box off;
% box off;
% xlabel('Day','Fontsize',18);
% set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
% title('Need Hospitalzation');

% [ax,h] = suplabel('Cases (in millions)','y');
% set(h,'FontSize',18);

print(State,'-dpng')
