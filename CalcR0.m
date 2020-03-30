function betaE=CalcR0(R0E,N,sigma,h,gamma,delta,M)
    betav=linspace(0.01,0.1,1001);
    R0=zeros(1001,1);

    for rr=1:1001
        beta=betav(rr);
        F=[];
        for ii=1:4
            F=[F; 0 0 0 0 beta*M(ii,1)*N(ii)/N(1)  beta*M(ii,2)*N(ii)/N(2) beta*M(ii,3)*N(ii)/N(3) beta*M(ii,4)*N(ii)/N(4) beta*M(ii,1)*N(ii)/N(1)  beta*M(ii,2)*N(ii)/N(2) beta*M(ii,3)*N(ii)/N(3) beta*M(ii,4)*N(ii)/N(4)];
        end

        F=[F; zeros(8,length(F(1,:)))];

        V=zeros(size(F));
        for ii=1:4
            V(ii,ii)=sigma;
            V(4+ii,ii)=-sigma.*(1-h(ii));
            V(8+ii,ii)=-sigma.*h(ii);
        end

        for ii=5:8
            V(ii,ii)=gamma;
            V(ii+4,ii+4)=delta;
        end

        test=abs(eig(F*inv(V)));
        R0(rr)=max(test);
    end
    betaE=pchip(R0,betav,R0E);
end

  