function DispChannelProgress(N,pp,cc)

persistent rev;
persistent CC;

if pp==0
    tic;
    msg = sprintf('Rendered 0/%d endpoint pairs. Remaining time = ??\n',N);
    fprintf(msg);
    rev = sprintf('%c',8*ones(1,length(msg)));   
    CC = 0;
else   
    CC=CC+cc;
    t = toc;
    msg = sprintf('Rendered %d/%d endpoint pairs @ %d kCoeff/sec. Passed=%dmin. Estd Total=%dmin. Estd Remaining=%dmin\n',pp,N,round(CC/t/1e3),round(t/60),round(t/pp*N/60),round(t/pp*(N-pp)/60));
    fprintf([rev msg]);
    rev = sprintf('%c',8*ones(1,length(msg)));
end
