clear;
close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
% Reproduction number (Change this to assume different R0)
R0E=1.7;
% State to run
State = 'JHARKHAND';

%% Get parameters and set up initial conditions
% Get parameters
[beta,sigma,tau,M,M2,gamma,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State);

IC=zeros(8*A,1);
IC(1:A)=P;  % Susceptible population
IC(2)=IC(2)-5;  % Seeding number of infections from age-group 2
IC(A+2)=5;  % Seeding number of infections


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(8*A));

[TM1,YM1]=ode15s(@(t,y)SODE(t,y,beta,sigma,tau,M,M2,gamma,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                 [0:1000],IC,options);

%% Hospital beds/ICUS etc
% How many beds are available?
%BedsR=round(round(sum(P)*2.2/1000)*0.06);
% Index for dxdt and x to make readability of code easier
S=[1:A]; % Susceptible
E=A+[1:A]; % Incubation and non-vaccinated
IH=2*A+[1:A]; % Incubation andvaccinated after infection
IN=3*A+[1:A]; %Symptomatic and non-vaccinated
QH=4*A+[1:A]; %Observation in incubation and non-vaccinated
QN=5*A+[1:A]; %Quaratine and non-vaccinated
H=6*A+[1:A]; % Quaratine to hosptial and non-vaccinated
C=7*A+[1:A]; % Not quaratined previosuly to hosptial and non-vaccinated


%% Plots
fig = figure('position',[300,200,900,1200])

subplot(3,1,1);
plot(TM1,sum(YM1(:,[IH IN])/1000000,2),'r','LineWidth',2.5); hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16,'xticklabel',{[]});
title('Not isolated');

subplot(3,1,2)
plot(TM1,sum(YM1(:,[QH QN])/1000000,2),'b','LineWidth',2.5); hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16,'xticklabel',{[]});
title('Isolated');

subplot(3,1,3)
plot(TM1,sum(YM1(:,[H C])/1000000,2),'color',[0,0,0.7],'LineWidth',2.5);
%hold on
%plot(TM1,BedsR.*ones(size(TM1)),'color',[0 0.7 0],'LineWidth',2);
%legend({'Hospitalized','Threshold'});
%legend box off;
box off;
xlabel('Day','Fontsize',18);
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Hosptialized');

[ax,h] = suplabel('Cases (in millions)','y');
set(h,'FontSize',18);
