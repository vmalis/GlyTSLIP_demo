function [FitPara, PH4a, TTP4a, MTT4a, MBV4a, MBF4a,x,Stest4] = perfusionFitDemo(BBTI,Intensity, id,slice)


xdata=BBTI./1000;   % BBTI times
yinput=Intensity*100;
ymax=max(yinput)*1.2;  % max y range for plotting

x=0:0.01:max(xdata);  % interpolated for smoother plot
xmax=max(xdata);

% perfusion curve fitting 
lb4 = [0.1 0.1 0.01 0];   
ub4 = [50000 100 100 0.3];
p4=[10 3 0.3 0.05]; 
options = optimset('display','off','TolFun',1e-18);

for z1=1:size(yinput,1)
   ydata=yinput(z1,:);
    
    [fittest4,resnorm,residual,exitflag,output,lambda,J]=lsqcurvefit ...
        (@PerfCurv4,p4,xdata,ydata,lb4,ub4,options);
    Stest4=PerfCurv4(fittest4,x);   
    FitPara(z1,:)=fittest4;
    % PerfCurv4 is   y = p(1).*x.^p(2).*exp(-x./p(3))+p(4); 
    % fittest4 has 4 fitted parameters p(1) to p(4)
    
    
    % Perfusion metrics calculated on fitted curve
    [PH4a(z1),idx]=max(Stest4); % Peak Height, (%)
    TTP4a(z1)=x(idx(1));   % Time to Peak, (s)
    %TTP4a(z1)=x(find(Stest4==PH4a(z1)))

    figure(1)
    plot(xdata,ydata,'b.','MarkerSize',25)
    hold on
    plot(x,Stest4,'-','Color',[0.8,0,0],'linewidth',2)
    
    legend('raw data','curve fit', 'FontSize',24)
    %title([id ' % SI increase vs TI'],'FontSize',14);
    ylim([0 1.2*max(ydata,[],'all')]);
    xlim([0 3.1]);
    xlabel('Inversion time (s)', 'FontSize',34);
    ylabel('Signal Increase %', 'FontSize',34);
    text(xmax*0.8,ymax.*0.7,['PH (%)=',num2str(PH4a(z1))],'FontSize',7)
    text(xmax*0.8,ymax.*0.65,['TTP (s)=',num2str(TTP4a(z1))],'FontSize',7)
    
    ax = gca;
    ax.FontSize = 24; 
       
    try
       MTT4a(z1)=fwhm(x,Stest4);               % Mean Transit Time, (s)  full width half maximum of curve
       text(xmax*0.8,ymax.*0.6,['MMT (s)=',num2str(MTT4a(z1))],'FontSize',7)
    catch 
       MTT4a=[]; 
    end

    
    MBV4a(z1)=max(cumtrapz(x,Stest4));      % Muscle Blood Volume, (%*s)
    
    try
        MBF4a(z1)=MBV4a(z1)/MTT4a(z1);          % Muscle Blood Flow, (%)
        text(xmax*0.8,ymax.*0.55,['rCFF (%)=',num2str(MBF4a(z1))],'FontSize',7)
    catch 
        MBF4a=[];
    end
    
    
    text(xmax*0.8,ymax.*0.5,['rCFV (%*s)=',num2str(MBV4a(z1))],'FontSize',7)

    hold off
    
    set(gcf,'color','white')
    saveas(gcf,['fitPlot', id, '.pdf'])
%     
    %saveas(1,strcat([id '_Perfusion_Fit at ROI # ',num2str(z1),'.png']));
    close(1)

end

%dataout=[FitPara PH4a' TTP4a' MTT4a' MBV4a' MBF4a']; % fit & perfusion parameters

end