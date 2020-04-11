function[] =  national_plots(A,Ss,TM0,TM,TMS,TMW,TMSW,YM0,YM,YMS,YMW,YMSW)
close all;
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

%% Plots
rang = {'#636363','#fdbb84','#bf5b17','#beaed4','#386cb0'};
st = 1; en = 365;
stl = 1; enl = 50;

% Impact of lockdown
fig1 = figure('position',[300,200,800,900]);
% total cases
subplot(3,1,1)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IA IH IN QH QN]),2),...
     'color',hex2rgb(rang(1)),'LineWidth',2.5);
hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IA IH IN QH QN]),2),...
     'color',hex2rgb(rang(2)), 'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');
lg = legend('No lockdown','With lockdown');
lg.FontSize = 16;
lg.Location = 'northwest';
legend boxoff;
% need hospitalization
subplot(3,1,2)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IH QH]),2),...
     'color',hex2rgb(rang(1)),'LineWidth',2.5);
hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IH QH]),2),...
     'color',hex2rgb(rang(2)), 'LineWidth',2.5);hold on;

box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Need Hospitalization');

% death
subplot(3,1,3)
plot(TM0(stl:enl),sum(YM0(stl:enl,[D]),2),...
     'color',hex2rgb(rang(1)),'LineWidth',2.5);
hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[D]),2),...
     'color',hex2rgb(rang(2)), ...
     'LineWidth',2.5);hold on;
box off;
xlabel('Days','Fontsize',18);
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Deaths');

[ax,h] = suplabel('Cases','y');
set(h,'FontSize',18);
hold off

print('Lockdown','-dpng')

close all
% Total infections, Need hospitalization, Dealths
fig2 = figure('position',[300,200,800,900]);

% CASES
subplot(3,1,1)
% Status Quo
plot(TM0(st:en),sum(YM0(st:en,[IA IH IN QH QN])/1000000,2),...
     'color',hex2rgb(rang(1)), 'LineWidth',2.5);
hold on;
% lockdown followed by status quo
plot(TM(st:en),sum(YM(st:en,[IA IH IN QH QN])/1000000,2),...
     'color',hex2rgb(rang(2)),'LineWidth',2.5);
hold on;
% lockdown followed by school closure
plot(TMS(st:en),sum(YMS(st:en,[IA IH IN QH QN])/1000000,2),...
     'color',hex2rgb(rang(3)),'LineWidth',2.5);
hold on;
% lockdown followed by work from home
plot(TMW(st:en),sum(YMW(st:en,[IA IH IN QH QN])/1000000,2),...
     'color',hex2rgb(rang(4)),'LineWidth',2.5);
hold on;
% lockdown followed byboth school closure and work from home
plot(TMSW(st:en),sum(YMSW(st:en,[IA IH IN QH QN])/1000000,2),...
     'color',hex2rgb(rang(5)),'LineWidth',2.5);
hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');

lg = legend('No lockdown','Return to status quo','School closure (SC)',...
            'Work from home (WFH)','Both SC & WFH');
lg.FontSize = 16;
lg.Location = 'northwest';
legend boxoff;


% HOSPITALIZATION
subplot(3,1,2)
% status quo
plot(TM0(st:en),sum(YM0(st:en,[IH QH])/1000000,2),...
     'color',hex2rgb(rang(1)),'LineWidth',2.5);
hold on;
% lockdown followed by status quo
plot(TM(st:en),sum(YM(st:en,[IH QH])/1000000,2),...
     'color',hex2rgb(rang(2)),'LineWidth',2.5);
hold on;
% lockdown followed by school closure
plot(TMS(st:en),sum(YMS(st:en,[IH QH])/1000000,2),...
     'color',hex2rgb(rang(3)),'LineWidth',2.5);
hold on;
% lockdown followed by work from home
plot(TMW(st:en),sum(YMW(st:en,[IH QH])/1000000,2),...
     'color',hex2rgb(rang(4)),'LineWidth',2.5);
hold on;
% lockdown followed by both school closure and work from home
plot(TMSW(st:en),sum(YMSW(st:en,[IH QH])/1000000,2),...
     'color',hex2rgb(rang(5)),'LineWidth',2.5);
hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Need Hospitalization');

% DEATHS
subplot(3,1,3)
% staus quo
plot(TM0(st:en),sum(YM0(st:en,[D])/1000000,2),...
     'color',hex2rgb(rang(1)),'LineWidth',2.5);
hold on;
% lockdown followed by status quo
plot(TM(st:en),sum(YM(st:en,[D])/1000000,2),...
     'color',hex2rgb(rang(2)),'LineWidth',2.5);
hold on;
% lockdown followed by school closure
plot(TMS(st:en),sum(YMS(st:en,[D])/1000000,2),...
     'color',hex2rgb(rang(3)),'LineWidth',2.5);
hold on;
% lockdown followed by work from home
plot(TMW(st:en),sum(YMW(st:en,[D])/1000000,2),...
     'color',hex2rgb(rang(4)),'LineWidth',2.5);
hold on;
plot(TMSW(st:en),sum(YMSW(st:en,[D])/1000000,2),...
     'color',hex2rgb(rang(5)),'LineWidth',2.5);
hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Deaths');

xlabel('Days','Fontsize',18);

set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);

[ax,h] = suplabel('Cases(in millions)','y');
set(h,'FontSize',18);
hold off
print('National','-dpng')

end
