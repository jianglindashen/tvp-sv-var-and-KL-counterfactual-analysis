
classdef StackedBarPlotter
    %--------------------------------------------------------------------------
    % @Author: 好玩的Matlab
    % @公众号：好玩的Matlab
    % @Created: 09,10,2023
    % @Email:2377389590@qq.com
    % @【尊重作者劳动成果，转载请注明推文链接和公众号名】
    % @Disclaimer: This code is provided as-is without any warranty.
    %--------------------------------------------------------------------------

    properties
        PosX       % 正数部分数据
        NegX       % 负数部分数据
        Colors     % 柱状图颜色
        TickNames  % 坐标轴标签名称
        Type       % 图的方向（纵向或横向）
    end

    methods
        % 构造函数
        function obj = StackedBarPlotter(varargin)
            % 获取默认参数值
            defValues = obj.getDefaultValues();

            % 解析输入参数
            p = obj.parseInput(defValues, varargin{:});

            % 从解析结果中设置对象属性
            obj.PosX = p.Results.PosX;
            obj.NegX = p.Results.NegX;
            obj.Colors = p.Results.Colors;
            obj.TickNames = p.Results.TickNames;
            obj.Type = p.Results.Type;
        end

        % 绘图函数
        function plot(obj)
            [rows, cols] = size(obj.PosX);
            hold on;
            if strcmp(obj.Type, 'ver')
                % 使用 bar 绘制纵向图
                poxB = bar(obj.PosX, 'stacked', 'EdgeColor', 'none');
                negB = bar(obj.NegX, 'stacked','EdgeColor','none');
            elseif strcmp(obj.Type, 'hor')
                % 使用 barh 绘制横向图
                poxB = barh(obj.PosX, 'stacked', 'EdgeColor', 'none');
                negB = barh(obj.NegX, 'stacked','EdgeColor','none');
                set(gca, 'YTick', 1:rows, 'YTickLabel', obj.TickNames);
            else
                error('Invalid orientation. Choose either "vertical" or "horizontal".');
            end
            % 设置颜色
            for i = 1:cols
                poxB(i).FaceColor = obj.Colors(i, :);
                negB(i).FaceColor = obj.Colors(i, :);
            end
        end
    end

    methods (Access = private)
        % 获取默认值的私有方法
        function defValues = getDefaultValues(~)
            % 在这里定义默认值
            defValues = struct('PosX', [], 'NegX', [], 'Colors', [], 'TickNames', {}, 'Type', 'ver');
        end

        % 解析输入参数的私有方法
        function p = parseInput(~, defValues, varargin)
            p = inputParser;
            p.CaseSensitive = false;
            % 添加参数、默认值和验证函数
            addParameter(p, 'PosX', defValues.PosX, @isnumeric);
            addParameter(p, 'NegX', defValues.NegX, @isnumeric);
            addParameter(p, 'Colors', defValues.Colors, @isnumeric);
            addParameter(p, 'TickNames', defValues.TickNames, @iscellstr);
            addParameter(p, 'Type', defValues.Type, @(x) any(validatestring(x, {'ver', 'hor'})));
            % 解析输入参数
            parse(p, varargin{:});
        end
    end
end