function dxdt = SODE(t,x,beta,sigma,tau,M,M2,gamma,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P,A)
%% dxdt = SODE()
% System of ODE to run the model for vaccination and contact tracing
%% Input parameters
%t - time variable
%x - State variable
%     S=[1:A]; % Susceptible
%     E=A+[1:A]; % Incubation
%     IH=2*A+[1:A]; %Symptomatic and will be hospitalized
%     IN=3*A+[1:A]; %Symptomatic and will not be hospitalized
%     QH=4*A+[1:A]; %Isolation and will be hospitalized
%     QN=5*A+[1:A]; %Isolation and will not be hospitalized
%     H=6*A+[1:A]; % Hospitalized
%     C=7*A+[1:A]; % ICU
%beta - probability of infection
%sigma - Rate from infection to symptoms
%tau - Contact tracing rate
%M - contact matrix (Size: AxA)
%M2 - contact matrix home (Size: AxA)
%gamma - rate to recovery symptomatic individual
%q - rate percentage of unvaccinated syptomatic case self-quaratine
%h - rate percentage of unvaccinated symptatic case being hospitalized
%delta - hospitalization rate
%mh - rate percentage for mortality in hospital
%mueH - mortality rate in hospital
%psiH - recover rate from hosptial
%mc - rate percentage for mortality in ICU
%mueC - mortality rate in ICU
%psiC - recover rate from ICU
%P -Population size
%A - Number of ages classes considered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the vector and specify the index equations
dxdt=zeros(length(x),1);
% Index for dxdt and x to make readability of code easier
S=[1:A]; % Susceptible
E=A+[1:A]; % Incubation and non-vaccinated
IH=2*A+[1:A]; % Incubation andvaccinated after infection
IN=3*A+[1:A]; %Symptomatic and non-vaccinated
QH=4*A+[1:A]; %Observation in incubation and non-vaccinated
QN=5*A+[1:A]; %Quaratine and non-vaccinated
H=6*A+[1:A]; % Quaratine to hosptial and non-vaccinated
C=7*A+[1:A]; % Not quaratined previosuly to hosptial and non-vaccinated

%% Susceptible and vaccinated population
dxdt(S)= -beta.*(M*x(IN)./P+M*x(IH)./P+M2*x(QN)./P+M2*x(QH)./P).*x(S);
%% Incubation period population
dxdt(E)= beta.*(M*x(IN)./P+M*x(IH)./P+M2*x(QN)./P+M2*x(QH)./P).*x(S)-sigma.*x(E);
%% Symptomatic and infectious
dxdt(IH)=(1-q).*h.*sigma.*x(E)-delta.*x(IH);
dxdt(IN)=(1-q).*(1-h).*sigma.*x(E)-(1-f).*gamma.*x(IN)-f.*tau.*x(IN);
%% Isolation
dxdt(QH)=q.*h.*sigma.*x(E)-delta.*x(QH);
dxdt(QN)=q.*(1-h).*sigma.*x(E)-gamma.*x(QN)+f.*tau.*x(IN);
%% Hospital
dxdt(H)=(1-c).*delta.*x(QH)+(1-c).*delta.*x(IH)-(1-mh).*psiH.*x(H)-mh.*mueH.*x(H);
%% ICU
dxdt(C)=c.*delta.*x(QH)+c.*delta.*x(IH)-(1-mc).*psiC.*x(C)-mc.*mueC.*x(C);


end
