function [bins,pval]=cdf(x,bins,linetype)

percentiles = [5 50 95];

% Find bins for all values
if ~exist('bins','var') || isempty(bins) 
    [~,bins] = histcounts(x,'BinWidth',1);
end

centers = (bins(1:end-1)+bins(2:end))/2;

B = length(bins)-1;
[N,M]=size(x);
n = zeros(B,M);
for m=1:M
    n(:,m) = histcounts(x(~isnan(x(:,m)),m),bins)';
end

cn=cumsum(n,1)./repmat(sum(n,1),B,1);

if nargin==3
    plot(centers,cn,linetype,'LineWidth',2);
else
    plot(centers,cn,'LineWidth',2);
end

hold on;
np = numel(percentiles);
nc = size(cn,2);
a=axis;line(repmat(a(1:2),np,1)',repmat(percentiles(:)/100,1,2)','LineStyle',':','Color','k')
pval = nan(np,nc);
for pi = 1:np
    for ci=1:nc
        yval = percentiles(pi)/100;
        ind0 = find(cn(:,ci) <yval,1,'last');
        ind1 = find(cn(:,ci)>=yval,1,'first');
        if ~isempty(ind0)&& ~isempty(ind1)
            y0 = cn(ind0,ci); x0=centers(ind0);
            y1 = cn(ind1,ci); x1=centers(ind1);
            pval(pi,ci) = x0+(x1-x0)/(y1-y0)*(yval-y0);
        end
    end
    line(repmat(pval(pi,:),2,1),repmat([0,percentiles(pi)/100],nc,1)','LineStyle','--')
end
grid on;
xlabel('Value of x')
ylabel('Probability of sample smaller than x')
