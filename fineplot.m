%x,y are the variables to be plotted.
%titlename,xaxisname,yaxisname,legendname are the labels in their respective areas
%size is in pixels 
%holdstate = 'on' is equivalent to "hold on"
%xlimits and ylimits are xlim and ylim
%style is the specifiying string for color linestyle etc. like 'k--' 
function plot_n = fineplot(x,y,titlename,xaxisname,yaxisname,xlimits,ylimits,holdstate,size,legendName,style)
    arguments
        x
        y
        titlename string = ''
        xaxisname string = ''
        yaxisname string = ''
        xlimits double = []
        ylimits double = []
        holdstate string = 'off'
        size (1,2) double = [400 400];
        legendName string = ''
        style = '-'
    end

    %parameters
    difference_x = max(x) - min(x);
    difference_y = max(y) - min(y);
    pos = gca().Position;
    figpos = gcf().Position;
    scale = min(figpos(3), figpos(4)) / 500;   % 400 is a reference size
    

    %========================
    %automatically set limits
    %========================
    if isempty(xlimits)
        xlimits = [min(x)-difference_x/10 max(x)+difference_x/10];
        if xlimits(1) > -arrow_length_x && min(x) > 0
            xlimits(1) = 0;
        end
        if xlimits(2) < arrow_length_y && max(x) < 0
            xlimits(2) = 0;
        end
    end

    if isempty(ylimits)
        ylimits = [min(y)-difference_y/10 max(y)+difference_y/10];
        if ylimits(2) < arrow_length_y && max(y) < 0
            ylimits(2) = 0;
        end
        if ylimits(1) > -arrow_length_y && min(y) > 0
            ylimits(1) = 0;
        end
    end

    ylimits = sort(ylimits); %makes it so that order does not matter
    xlimits = sort(xlimits); %makes it so that order does not matter    
    
    %=======================================================================
    %prevent secondary exponential axis labels from messing with the scaling
    %=======================================================================
    expX = max(floor(log10(abs(xlimits))));
    expY = max(floor(log10(abs(ylimits))));
    if expX < 3
        expX = 0;
    end
    if expY < 3
        expY = 0;
    end

    if expX ~= 0
        x = x / (10^expX);
        xlimits = xlimits / (10^expX);
    end
    if expY ~= 0
        y = y / (10^expY);
        ylimits = ylimits / (10^expY);
    end

    difference_x = xlimits(2) - xlimits(1);
    difference_y = ylimits(2) - ylimits(1);
    arrow_length_x = difference_x * 0.03;
    arrow_length_y = difference_y * 0.03;
    %==================================================
    %this section is responsible for axis configuration
    %==================================================
    plot_n = plot(x,y,style,'displayName',legendName);

    xlim(xlimits);
    ylim(ylimits);
    set(get(gca,'XLabel'),'Visible','on');
    set(gca,'XAxisLocation','origin', 'box','off');
    set(gca,'YAxisLocation','origin');
    set(get(gca, 'XAxis'), 'FontWeight', 'bold');
    set(get(gca, 'YAxis'), 'FontWeight', 'bold');
    set(get(gca,'YLabel'),'Visible','on');
    set(gca,'Layer','top');

    scr = get(0,'ScreenSize');
    set(gcf,'position',[(scr(3)-size(1))/2, (scr(4)-size(2))/2, size(1) , size(2)]);
    
    
    %===============================================================================
    %arrows for axes. makes sure we dont plot arrows on the wrong side of the origin
    %===============================================================================
    origin = [map_0(xlimits(2),xlimits(1),pos(1)+pos(3),pos(1)) map_0(ylimits(2),ylimits(1),pos(2)+pos(4),pos(2))];
    
    if xlimits(2) > arrow_length_x
        if xlimits(1) < -arrow_length_x
            a1 = annotation(gcf,"arrow",[pos(1)+0.5*pos(3) pos(1)+pos(3)],[origin(2) origin(2)]);%east
        else
            a1 = annotation(gcf,"arrow",[pos(1) pos(1)+pos(3)],[origin(2) origin(2)]);%east
        end
        a1.HeadLength = 10 * scale;
        a1.HeadWidth  = 10 * scale;
        a1.LineWidth  = 1.5 * scale;
    end
    if ylimits(2) > arrow_length_y
        if ylimits(1) < -arrow_length_y
            a2 = annotation(gcf,"arrow",[origin(1) origin(1)],[pos(2)+0.5*pos(4) pos(2)+pos(4)]);%north
        else
            a2 = annotation(gcf,"arrow",[origin(1) origin(1)],[pos(2) pos(2)+pos(4)]);%north
        end
        a2.HeadLength = 10 * scale;
        a2.HeadWidth  = 10 * scale;
        a2.LineWidth  = 1.5 * scale;
    end
    if xlimits(1) < -arrow_length_x
        if xlimits(2) > arrow_length_x
            a3 = annotation(gcf,"arrow",[pos(1)+pos(3)*0.5 pos(1)],[origin(2) origin(2)]);%west
        else
            a3 = annotation(gcf,"arrow",[pos(1)+pos(3) pos(1)],[origin(2) origin(2)]);%west
        end
        a3.HeadLength = 10 * scale;
        a3.HeadWidth  = 10 * scale;
        a3.LineWidth  = 1.5 * scale;
    end
    if ylimits(1) < -arrow_length_y
        if ylimits(2) > arrow_length_y
            a4 = annotation(gcf,"arrow",[origin(1) origin(1)],[pos(2)+pos(4)*0.5 pos(2)]);%south
        else
            a4 = annotation(gcf,"arrow",[origin(1) origin(1)],[pos(2)+pos(4) pos(2)]);%south
        end
        a4.HeadLength = 10 * scale;
        a4.HeadWidth  = 10 * scale;
        a4.LineWidth  = 1.5 * scale;
    end
    
    %=============================================
    %prevent axis ticks from colliding with arrows
    %=============================================
    xticks('auto');
    xt = xticks;
    yticks('auto');
    yt = yticks;
    
    if max(x) > 0 && abs(xt(end)-xlimits(2)) < arrow_length_x
        xt = xt(1:end-1);
    end
    if max(y) > 0 && abs(yt(end)-ylimits(2)) < arrow_length_y
        yt = yt(1:end-1);
    end
    if min(x) < 0 && abs(xt(1)-xlimits(1)) < arrow_length_x
        xt = xt(2:end);
    end
    if min(y) < 0 && abs(yt(1)-ylimits(1)) < arrow_length_y
        yt = yt(2:end);
    end
    xticks(xt);
    yticks(yt);

    %=
    %axis exponents secondary label corrections
    %= 
    if expX ~= 0
        xaxisname = strcat(xaxisname + "$\ \times 10^{" ,num2str(expX) , "}$");
    end
    if expY ~= 0
        yaxisname = strcat(yaxisname + "$\ \times 10^{" ,num2str(expY) , "}$");
    end
    
    ax = gca;
    ax.XAxis.SecondaryLabel.Color = ax.Color;
    ax.YAxis.SecondaryLabel.Color = ax.Color;
    %=================================
    %axis labels/title and their positioning 
    %=================================
    multiplier_x = 1;
    if abs(xlimits(2)) < abs(xlimits(1))
        multiplier_x = -1;
    end

    multiplier_y = 1;
    if abs(ylimits(2)) < abs(ylimits(1))
        multiplier_y = -1;
    end

    %set positions
    xlabel_x = xlimits((xlimits(2)>0) + 1)*1.02;
    xlabel_y = multiplier_y*difference_y*0.035 +  difference_y * 0.007 + clip(0,ylimits(1)+difference_y*0.03,ylimits(2)-difference_y*0.03);
    xlabelpos = [xlabel_x,xlabel_y];

    ylabel_x = clip(0,xlimits(1),xlimits(2)) + multiplier_x*difference_x*0.02;
    ylabel_y = ylimits((ylimits(2)>0) + 1)*0.95 + difference_y*0.04*(sign((ylimits(2)>0)-0.5)-1);
    ylabelpos = [ylabel_x, ylabel_y];
    
    %repositioning title & label locations
    
    x_boundary = ((1 - (pos(1)+pos(3))) * xlimits(2)) / (pos(1)+pos(3)-origin(1)) + xlimits(2);
    label_x = text(xlabelpos(1),xlabelpos(2),xaxisname,"FontSize",8 + min(size)*0.005,"HorizontalAlignment","center","VerticalAlignment","middle","Interpreter","latex");
    ext = label_x.Extent;
    if x_boundary < ext(1) + ext(3)
         label_x.Position = [x_boundary,xlabelpos(2)];
         label_x.HorizontalAlignment = "right"; %,xaxisname,"FontSize",8 + min(size)*0.005,"HorizontalAlignment","right","VerticalAlignment","middle","Interpreter","latex");
    end
    % end
    if multiplier_x > 0
        label_y = text(ylabelpos(1),ylabelpos(2),yaxisname,"FontSize",8 + min(size)*0.005,"Interpreter","latex");
    else
        label_y = text(ylabelpos(1),ylabelpos(2),yaxisname,"FontSize",8 + min(size)*0.005,"HorizontalAlignment","right","Interpreter","latex");
    end
    
    
    

    t = title(titlename,"Interpreter","latex");
    if ylimits(2) < 0
        set(get(gca,'title'),'Position', [mean(xlimits),ylimits(1)-0.1*difference_y]) %prevents the title from colliding with ylabel
    else
        set(get(gca,'title'),'Position', [mean(xlimits),ylimits(2)+0.01*difference_y]) %prevents the title from colliding with ylabel
    end
    
    
    

    grid on

    if strcmp(holdstate,'off')
        hold off
    else 
        hold on
    end
end

