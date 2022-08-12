%
%function plotMPSContour(MPS_type,MPS,pwp,removeDC,dBimagesc)
%	
%	FILE NAME 	: plotMPSContour
%	DESCRIPTION : plot the MPS image and the contour of a given power level
%
%	MPS_type    : Which type of the MPS is:
%             	  Three options: 'RipSpecFourier', 'RipSpecCochlear' and 'RipSpecMidbrain'
%	MPS         : The MPS used for plotting
%
%Optional Parameters
%	pwp         : Power level for contour
%                 Default: 0.9 (90 percent of the power falls in the contour)
%	removeDC	: Whether remove the channels where Fm == 0 or RD == 0
%                 Default: 'y'
%   dBimagesc   : Whether plot the image in dB
%                 Default: 'y'
%
% (C) Monty A. Escabi, 2022

function plotMPSContour(MPS_type,MPS,pwp,removeDC,dBimagesc)
if nargin<5 || isempty(dBimagesc)
    dBimagesc = 'y';
end
if nargin<4 || isempty(removeDC)
    removeDC = 'y';
end
if nargin<3 || isempty(pwp)
    pwp = .9;
end


%% RipSpecMidbrain
if strcmp(MPS_type,'RipSpecMidbrain')
    fm = MPS.LogFmAxis;
    rd = MPS.LogRDAxis;
    Z = MPS.En;
    
    DCidx = [1,(size(Z,2)-1)/2+1];
    if strcmp(removeDC,'y')
        rd(DCidx(1)) = [];
        fm(DCidx(2)) = [];
        Z(DCidx(1),:) = [];
        Z(:,DCidx(2)) = [];
    else
        rd(DCidx(1)) = 0;
        fm(DCidx(2)) = 0;
    end
    
    Z = Z/max(max(Z));
    if strcmp(dBimagesc,'y')
        imagesc(fm,rd,10*log10(Z))
    else
        imagesc(fm,rd,Z)
    end
    
    hold on;
    
    % Contour
    z = Z;
    z = z/sum(sum(z));
    Max=max(max(z));
    
    % Find points inside contour
    g=.9999;
    I=find(z>g*Max);
    while sum(z(I))<pwp
        g=g-0.0001;
        I=find(z>g*Max);
    end
    
    [X,Y] = meshgrid(fm,rd);
    hold on;
    contour(X,Y,z,[g g]*Max,'k');
    
    xlabel('');
    ylabel('');
    if strcmp(removeDC,'y')
        set(gca,'XTick',-8:4:8);
        set(gca,'XTickLabel',[-256 -16 1 16 256]);
        set(gca,'YTick',1:2:5);
        set(gca,'YTickLabel',[0.2 0.8 3.2]);
    else
        set(gca,'XTick',-8:4:8);
        set(gca,'XTickLabel',[-256 -16 0 16 256]);
        set(gca,'YTick',1:2:5);
        set(gca,'YTickLabel',[0.2 0.8 3.2]);
    end
    set(gca,'TickLength',[0.02 0.02]);
    set(gca,'YDir','normal');
    if strcmp(dBimagesc,'y')
        caxis([-50 0])
    else
        caxis([0 1])
    end
end
%% RipSpecCochlear
if strcmp(MPS_type,'RipSpecCochlear')
    fm = MPS.FmAxis;
    rd = MPS.RDAxis;
    
    % Cut Loglinear: xlim([-500 500]), ylim([-10 10])
    % Just roughly remove the low energy parts, otherwise it will take forever
    [~,ix] = min(abs(fm-(-500)));
    x = ix;
    [~,ix] = min(abs(fm-500));
    x = [x,ix];
    [~,ix] = min(abs(rd-(-10)));
    y = ix;
    [~,ix] = min(abs(rd-10));
    y = [y,ix];
    
    fm = fm(x(1):x(2));
    rd = rd(y(1):y(2));
    Z  = MPS.P3(y(1):y(2),x(1):x(2));
    
    % Remove DC parts
    if strcmp(removeDC,'y')
        I = find(abs(fm)<.5);
        tDC = [min(I) max(I)];
        I = find(abs(rd)<.5);
        sDC = [min(I) max(I)];
        fm(tDC(1):tDC(2)) = [];
        rd(sDC(1):sDC(2)) = [];
        Z(sDC(1):sDC(2),:)=[];
        Z(:,tDC(1):tDC(2))=[];
        clear I;
    end
    
    Z = Z/max(max(Z));
    if strcmp(dBimagesc,'y')
        imagesc(fm,rd,10*log10(Z))
    else
        imagesc(fm,rd,Z)
    end
    
    % Contour
    z = Z;
    z = z/sum(sum(z));
    Max=max(max(z));
    
    % Find points inside contour
    g=.9999;
    I=find(z>g*Max);
    while sum(z(I))<pwp
        g=g-0.0001;
        I=find(z>g*Max);
    end
    
    [X,Y] = meshgrid(fm,rd);
    hold on;
    contour(X,Y,z,[g g]*Max,'k');
    
    %     xlim([-60 60]);
    ylim([0 10]);
    %     xticks(-40:20:40);
    yticks(0:5:10);
    set(gca,'YDir','normal');
    set(gca,'TickLength',[0.02 0.02]);
    if strcmp(dBimagesc,'y')
        caxis([-50 0])
    else
        caxis([0 1])
    end
end
%% RipSpecFourier
if strcmp(MPS_type,'RipSpecFourier')
    fm = MPS.FmAxis;
    rd = MPS.RDAxis;
    
    % Cut Linearlinear: xlim([-100 100]), ylim([-20 20])
    % Just roughly remove the low energy parts, otherwise it will take forever
    [~,ix] = min(abs(fm-(-500)));
    x = ix;
    [~,ix] = min(abs(fm-500));
    x = [x,ix];
    [~,ix] = min(abs(rd-(-20)));
    y = ix;
    [~,ix] = min(abs(rd-20));
    y = [y,ix];
    
    fm = fm(x(1):x(2));
    rd = rd(y(1):y(2));
    
    Z = MPS.P3(y(1):y(2),x(1):x(2));
    
    % Remove DC parts
    if strcmp(removeDC,'y')
        I = find(abs(fm)<.5);
        tDC = [min(I) max(I)];
        I = find(abs(rd)<.5);
        sDC = [min(I) max(I)];
        fm(tDC(1):tDC(2)) = [];
        rd(sDC(1):sDC(2)) = [];
        Z(sDC(1):sDC(2),:)=[];
        Z(:,tDC(1):tDC(2))=[];
        clear I;
    end
    
    Z = Z/max(max(Z));
    if strcmp(dBimagesc,'y')
        imagesc(fm,rd,10*log10(Z))
    else
        imagesc(fm,rd,Z)
    end
    
    % Contour
    z = Z;
    z = z/sum(sum(z));
    Max=max(max(z));
    
    % Find points inside contour
    g=.9999;
    I=find(z>g*Max);
    while sum(z(I))<pwp
        g=g-0.0001;
        I=find(z>g*Max);
    end
    
    [X,Y] = meshgrid(fm,rd);
    hold on;
    contour(X,Y,z,[g g]*Max,'k');
    
    xlim([-60 60]);
    ylim([0 20]);
    xticks(-60:20:60);
    yticks(0:5:20);
    set(gca,'YDir','normal');
    set(gca,'TickLength',[0.02 0.02]);
    if strcmp(dBimagesc,'y')
        caxis([-50 0])
    else
        caxis([0 1])
    end
end
end
