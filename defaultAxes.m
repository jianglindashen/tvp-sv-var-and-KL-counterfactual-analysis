
function defaultAxes(type, tickNames)
%--------------------------------------------------------------------------
% @Author: 好玩的Matlab
% @公众号：好玩的Matlab
% @Created: 09,10,2023
% @Email: 2377389590@qq.com
% @【尊重作者劳动成果，转载请注明推文链接和公众号名】
% @Disclaimer: This code is provided as-is without any warranty.
%--------------------------------------------------------------------------
    % 获取当前的坐标轴
    ax = gca;

    % 基本坐标轴设置
    ax.Box = 'off';
    ax.Color = [1, 1, 1];             % 背景颜色设置为白色
    ax.LineWidth = 1;                 % 坐标轴线宽度
    ax.FontSize = 16;                 % 坐标轴字体大小
    ax.FontName = 'Times New Roman';  % 设置字体类型

    % 网格线设置
    ax.GridLineStyle = '-';           % 主网格线样式
    ax.GridColor = 'k';               % 主网格线颜色（黑色）
    ax.GridAlpha = 0.2;               % 主网格线透明度
    ax.MinorGridLineStyle = '-';      % 次网格线样式
    ax.MinorGridColor = [0 0 0];      % 次网格线颜色（黑色）
    ax.MinorGridAlpha = 0.3;          % 次网格线透明度

    % 刻度设置
    ax.XMinorTick = 'off';            % x轴次刻度关闭
    ax.YMinorTick = 'off';            % y轴次刻度关闭
    ax.TickDir = 'out';               % 刻度线方向向外

    % 调整坐标轴范围
    ax.XLim = [min(ax.XLim) * 1.03, max(ax.XLim) * 1.03];
    ax.YLim = [min(ax.YLim) * 1.03, max(ax.YLim) * 1.03];

    % 根据图的类型（纵向或横向）进行不同设置
    if strcmp(type, 'ver')
        ax.XGrid = 'off';
        ax.YGrid = 'on';
        ax.XTick = 1:length(tickNames);
        ax.XTickLabel = tickNames;
        line([xlim], [0 0], 'Color', 'k', 'LineWidth', 1);
    elseif strcmp(type, 'hor')
        ax.XGrid = 'on';
        ax.YGrid = 'off';
        ax.YTick = 1:length(tickNames);
        ax.YTickLabel = tickNames;
        line([0 0], [ylim], 'Color', 'k', 'LineWidth', 1);
    else
        error('Invalid orientation. Choose either "ver" or "hor".');
    end

    % 添加额外的坐标轴（右侧和顶部）
    axur = axes('Units', ax.Units, ...
                'Position', ax.Position, ...
                'XAxisLocation', 'top', ...
                'YAxisLocation', 'right', ...
                'Color', 'none', ...
                'XColor', ax.XColor, ...
                'YColor', ax.YColor);

    axur.LineWidth = 1;
    axur.XTick = [];
    axur.YTick = [];
end