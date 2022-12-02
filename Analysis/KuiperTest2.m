function [h,p,dstat] = KuiperTest2(s1,s2, plt)
    % Adapted and expanded from https://www.mathworks.com/matlabcentral/fileexchange/72908-kuipertest2
    % This function compares input samples one and two based on the 
    % Kuiper Test and Kuiper Statistic. It creates two empirical cdfs 
    % based on the two samples and then returns the Kuiper statistic.
    % Also has the option to plot the cdfs as well as the D- and D+ values 
    % that determined the Kuiper statistic.
    %
    % Inputs:
    % s1 - sample set 1
    % s2 - sample set 2
    % res - resolution for cdf
    % plt - true or false for plotting
    
    if nargin < 3
        plt = 0;
    end
    
    n=length(s1(:));
    m=length(s2(:));
    % like ecdf function but with a fixed resolution (easier to compare
    % ecdfs this way)
    x=linspace(0,max(max(s1),max(s2)),100);
    f1=zeros([100,1]);f2=zeros([100,1]);
    for nn=1:100
        f1(nn)= sum(s1<=x(nn))/n;% this is the cumulative dist func for s1
        f2(nn)=sum(s2<=x(nn))/m;
    end
    [dplus, dpind]=max([0 ; f1-f2]);
    [dminus,dmind]=max([0 ; f2-f1]);
    dstat=dplus+dminus;
    if plt
        plot(x,[f1,f2],'.-'); hold on
        plot([x(dpind-1),x(dpind-1)],[f1(dpind-1),f2(dpind-1)],'k-') % plotting vertical lines
        plot([x(dmind-1),x(dmind-1)],[f1(dmind-1),f2(dmind-1)],'k-') % plotting vertical lines
        legend({'sample1 ecdf','sample2 ecdf','dplus','dminus'})
        legend('Location','northwest') 
        title('Kuiper Test Results')
    end
    
    n1     =  length(s1);
    n2     =  length(s2);
    n      =  n1 * n2 /(n1 + n2);
    lambda =  max((sqrt(n) + 0.12 + 0.11/sqrt(n)) * dstat , 0);
    
    j       =  (1:101)';
    pValue  =  2 * sum((-1).^(j-1).*exp(-2*lambda*lambda*j.^2));
    pValue  =  min(max(pValue, 0), 1);
    
    if pValue < 0.05
        h = true;
    else 
        h = false;
    end
    
    p = pValue;
end