function[] =  states_plots(A,Ss,TM0,TM,TMS,TMW,TMSW,YM0,YM,YMS,YMW,YMSW,States)
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
rang = {'#636363','#fdbb84','#bf5b17','#beaed4','#386cb0'};
st = 1; en = 365;
stl = 1; enl = 50;

for id = 1:Ss
    titlename = States{id}
    % Impact of lockdown
    fig1 = figure('position',[300,200,800,900],'Visible','off');
    % total cases
    subplot(3,1,1)
    plot(TM0(stl:enl),sum(YM0(stl:enl,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}]),2),...
         'color',hex2rgb(rang(1)),'LineWidth',2.5);
    hold on;
    plot(TM(stl:enl),sum(YM(stl:enl,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}]),2),...
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
    plot(TM0(stl:enl),sum(YM0(stl:enl,[IHD{id} QHD{id}]),2),...
         'color',hex2rgb(rang(1)),'LineWidth',2.5);
    hold on;
    plot(TM(stl:enl),sum(YM(stl:enl,[IHD{id} QHD{id}]),2),...
         'color',hex2rgb(rang(2)), 'LineWidth',2.5);hold on;

    box off;
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Need Hospitalization');

    % death
    subplot(3,1,3)
    plot(TM0(stl:enl),sum(YM0(stl:enl,[DD{id}]),2),...
         'color',hex2rgb(rang(1)),'LineWidth',2.5);
    hold on;
    plot(TM(stl:enl),sum(YM(stl:enl,[DD{id}]),2),...
         'color',hex2rgb(rang(2)), ...
         'LineWidth',2.5);hold on;
    box off;
    xlabel('Days','Fontsize',18);
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Deaths');

    [ax,h] = suplabel('Cases','y');
    set(h,'FontSize',18);
    [ax,h] = suplabel(titlename,'t')
    set(h,'FontSize',16)
    hold off
    filename = strcat('plots/',titlename,'_','lockdown')
    print(filename,'-dpng')

    close all
    % Total infections, Need hospitalization, Dealths
    fig2 = figure('position',[300,200,800,900],'Visible','off');

    % CASES
    subplot(3,1,1)
    % Status Quo
    plot(TM0(st:en),sum(YM0(st:en,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}])/1000000,2),...
         'color',hex2rgb(rang(1)), 'LineWidth',2.5);
    hold on;
    % lockdown followed by status quo
    plot(TM(st:en),sum(YM(st:en,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}])/1000000,2),...
         'color',hex2rgb(rang(2)),'LineWidth',2.5);
    hold on;
    % lockdown followed by school closure
    plot(TMS(st:en),sum(YMS(st:en,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}])/1000000,2),...
         'color',hex2rgb(rang(3)),'LineWidth',2.5);
    hold on;
    % lockdown followed by work from home
    plot(TMW(st:en),sum(YMW(st:en,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}])/1000000,2),...
         'color',hex2rgb(rang(4)),'LineWidth',2.5);
    hold on;
    % lockdown followed byboth school closure and work from home
    plot(TMSW(st:en),sum(YMSW(st:en,[IAD{id} IHD{id} IND{id} QHD{id} QND{id}])/1000000,2),...
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
    plot(TM0(st:en),sum(YM0(st:en,[IHD{id} QHD{id}])/1000000,2),...
         'color',hex2rgb(rang(1)),'LineWidth',2.5);
    hold on;
    % lockdown followed by status quo
    plot(TM(st:en),sum(YM(st:en,[IHD{id} QHD{id}])/1000000,2),...
         'color',hex2rgb(rang(2)),'LineWidth',2.5);
    hold on;
    % lockdown followed by school closure
    plot(TMS(st:en),sum(YMS(st:en,[IHD{id} QHD{id}])/1000000,2),...
         'color',hex2rgb(rang(3)),'LineWidth',2.5);
    hold on;
    % lockdown followed by work from home
    plot(TMW(st:en),sum(YMW(st:en,[IHD{id} QHD{id}])/1000000,2),...
         'color',hex2rgb(rang(4)),'LineWidth',2.5);
    hold on;
    % lockdown followed by both school closure and work from home
    plot(TMSW(st:en),sum(YMSW(st:en,[IHD{id} QHD{id}])/1000000,2),...
         'color',hex2rgb(rang(5)),'LineWidth',2.5);
    hold on;
    box off;
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Need Hospitalization');

    % DEATHS
    subplot(3,1,3)
    % staus quo
    plot(TM0(st:en),sum(YM0(st:en,[DD{id}])/1000000,2),...
         'color',hex2rgb(rang(1)),'LineWidth',2.5);
    hold on;
    % lockdown followed by status quo
    plot(TM(st:en),sum(YM(st:en,[DD{id}])/1000000,2),...
         'color',hex2rgb(rang(2)),'LineWidth',2.5);
    hold on;
    % lockdown followed by school closure
    plot(TMS(st:en),sum(YMS(st:en,[DD{id}])/1000000,2),...
         'color',hex2rgb(rang(3)),'LineWidth',2.5);
    hold on;
    % lockdown followed by work from home
    plot(TMW(st:en),sum(YMW(st:en,[DD{id}])/1000000,2),...
         'color',hex2rgb(rang(4)),'LineWidth',2.5);
    hold on;
    plot(TMSW(st:en),sum(YMSW(st:en,[DD{id}])/1000000,2),...
         'color',hex2rgb(rang(5)),'LineWidth',2.5);
    hold on;
    box off;
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Deaths');

    xlabel('Days','Fontsize',18);

    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);

    [ax,h] = suplabel('Cases(in millions)','y');
    set(h,'FontSize',18);
    [ax,h] = suplabel(titlename,'t')
    set(h,'FontSize',16)
    hold off
    filename = strcat('plots/',titlename,'_','overall')
    print(filename,'-dpng')
end

end
