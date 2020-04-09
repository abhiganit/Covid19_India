WR = [1,2,3,4,5]; % which Red Light Area
R0 = [1.75,2,2.25]; % Different values of R0
TF = [1,5,10,15,20]; % Different level of relative transmissibility


TM0 = {}; YM0 = {}; TM={}; YM={}; TML={}; YML ={};
i = 1;
for wr = WR;
    j = 1;
    for r0 = R0;
        k = 1;
        for tm = TF;
            [TM0{i}{j}{k},YM0{i}{j}{k},TM{i}{j}{k},...
             YM{i}{j}{k},TML{i}{j}{k},YML{i}{j}{k}] = ...
                RunSimA(wr,r0,tm);
            k=k+1;
        end
        j=j+1;
    end
    i=i+1;
end


%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;
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


% Calculate delay in peaks under different scenarios
st = 1; en = 365;
stl = 15; enl = 50;

Dl = {}; %zeros(5,5);
for k = 1:3;
    for i = 1:5; % varying over RLAs
        for j = 1:5;
            yM = YM{i}{k}{j};
            yML = YML{i}{k}{j};
            [v0,ix0] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
            [vL,ixL] = max(sum(yML(st:en,[IA IH IN QH QN]),2));
            Dl{k}(i,j) = ixL - ix0;
        end
    end
end


% Cases averted originating from Red Light Areas
Cs = {};
for k = 1:3;
    for i = 1:5; % varying over RLAs
        for j = 1:5;
            yM = YM{i}{k}{j};
            yML = YML{i}{k}{j};
            [v0,ix0] = max(sum(yM(st:en,[CC]),2));
            [vL,ixL] = max(sum(yML(st:en,[CC]),2));
            Cs{k}(i,j) = v0 - vL;
        end
    end
end




%% Plots

% For each RLA seperately
% For a fixed R0 and fixed transmissibility (1)
rang = {'#636363','#fdbb84','#bf5b17','#beaed4','#386cb0'};

for i = 1:5
    tM0 = TM0{i}{2}{1}; tM = TM{i}{2}{1}; tML = TML{i}{2}{1};
    yM0 = YM0{i}{2}{1}; yM = YM{i}{2}{1}; yML = YML{i}{2}{1};

    fig = figure('position',[300,200,1400,1200],'visible','off');
    subplot(2,1,1)
    plot(tM0(st:en),sum(yM0(st:en,[IA IH IN QH QN])/1000000,2),'k', ...
         'LineWidth',2.5); hold on;
    plot(tM(st:en),sum(yM(st:en,[IA IH IN QH QN])/1000000,2),'b', ...
         'LineWidth',2.5);hold on;
    plot(tML(st:en),sum(yML(st:en,[IA IH IN QH QN])/1000000,2),'g', ...
         'LineWidth',2.5);hold on;
    box off;
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Infections');
    ylabel('Cases(in millions)','Fontsize',16);
    legend('No lockdown','Lockdown','Continued closure of RLA');
    legend boxoff
    subplot(2,1,2)
    plot(tM(st:en),sum(yM(st:en,[CC]),2),...
         'color',hex2rgb(rang(3)),...
         'LineWidth',2.5);
    hold on;
    plot(tML(st:en),sum(yML(st:en,[CC]),2),...
         'color',hex2rgb(rang(4)),...
         'LineWidth',2.5);
    box off;
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Cases attibutable to Red Light Areas');
    ylabel('Cases','Fontsize',16);
    lg = legend('No continued closure','Continued closure');
    lg.FontSize =16;
    lg.Location = 'northwest';
    legend boxoff;
    hold off;
    filename = strcat('RLA',int2str(i));
    print(filename,'-dpng');
end


rang= {'#fef0d9','#fdcc8a','#fc8d59','#e34a33','#b30000'};


% Plot delays in peak
titles = {'R_0 = 1.75','R_0 = 2','R_0=2.5'};
close all;
fig = figure('position',[300,200,1400,1200]);%%,'visible','off');
for i =1:3
    subplot(3,1,i)
    colormap(hex2rgb(rang));
    bar(Dl{i});
    title(titles{i},'FontSize',12)
    set(gca,'fontsize',16)
    if i <3
        set(gca,'XTickLabel',[])
    end
    if i ==1
        hleg = legend('1','2','3','4','5');
        htitle = get(hleg,'Title');
        set(htitle,'String','Relative transmissibility at RLA')
        legend boxoff
    end
    box off;
end
[ax,h] = suplabel('Red light areas','x');
set(h,'FontSize',18);
[ax,h] = suplabel('Delay in peak','y');
set(h,'FontSize',18);
print('Delays','-dpng');

% Plot averted cases originating from RLA
close all;
fig = figure('position',[300,200,1400,1200]);%%,'visible','off');
for i =1:3
    subplot(3,1,i)
    colormap(hex2rgb(rang));
    bar(Cs{i}/1000);
    title(titles{i},'FontSize',12)
    set(gca,'fontsize',16)
    if i <3
        set(gca,'XTickLabel',[])
    end
    if i ==1
        hleg = legend('1','2','3','4','5');
        htitle = get(hleg,'Title');
        set(htitle,'String','Relative transmissibility at RLA')
        legend boxoff
    end
    box off;
end
[ax,h] = suplabel('Red light areas','x');
set(h,'FontSize',18);
[ax,h] = suplabel('Cases linked to Red Light Area (in thousands)','y');
set(h,'FontSize',18);
print('Averted','-dpng');
