clear all;
close all;

my = xlsread('tvpvar_ex111.xlsx');  % load data
Time=datetime(importdata('tvpvar_ex_time111.xlsx')); % 载入时间标签并存储变量，请保证其列数为1，行数与时间序列数据的样本数相符，并且置于左上角
%my = [ diff(my(1:end,1)) diff(log(my(1:end,2)))  diff(log(my(:,3))) ];
%Time = Time(2:end)
asvar = {'GPR'; 'REMX'; 'NEW'};    % variable names

lag_max = 5;
type = 'const';
season = 12;
exogen = []; % 没有外生变量
select_var_lag(my, lag_max, type, season, exogen)
result = select_var_lag(my, lag_max, type, season, exogen)
disp('Selected lags for each criterion:');
disp('AIC: '), disp(result.selection(1));
disp('HQ: '), disp(result.selection(2));
disp('SC: '), disp(result.selection(3));
disp('FPE: '), disp(result.selection(4));
disp('Criteria matrix:');
disp(result.criteria);
[h, pValue, stat, cValue] = adftest(my(:,1), 'alpha', 0.05)
%%
nlag = 2;                   % # of lags
setvar('data', my, asvar, nlag); % set data
setvar('fastimp', 1);       % fast computing of response1
mcmc(5000,Time,'yyyy');                % MCMC，输入时间标签变量以调整显示格式，第三个参数用来调整坐标轴时间格式
%% 
drawimp(1,[0  2 4], '个月',Time,'','yyyy/mm');       % draw impulse reponse(1)，画脉冲相应图形，第一个参数为1表示输出等间距脉冲响应图形，第二个参数用于指定冲击发生后要观察的间距，第三个参数用来修改显示的时间间隔的标签，第四个参数输入时间标签变量,此处不适用可以随意输入，第五个参数调整坐标轴的时间显示格式
                            
drawimp(2,[62  112 134], '个月',Time,'yyyy/mm','yyyy');		% draw impulse response(2)，画脉冲相应图形，第一个参数为2表示输出分时点脉冲响应图形，第二个参数用于指定冲击发生的时点，第三个参数不适用于此种情形可随意输入，第四个参数输入时间标签变量，第五个参数用来指定标签的时间格式，第六个参数调整坐标轴的时间显示格式
                            
drawimp(3,[30 60 90], '个月',Time,'yyyy/qq','yyyy');     %画三维脉冲响应图形，第一个参数不为1和2即可，后面几个参数不适用于此种情形可随意输入     
%% 画图
clear all;
close all;
load gpr2new.mat 
load remx2new.mat
load time_date.mat
%你也可以直接复制excel的数据进来操作，如下：2026.1.27修改
%time_date = time_date(end-102:end,:) %取最后105个值 因为有市场发布日期太晚了
A=0; %gpr2new是第3列，remx2new是第6列

col = 3;
gpr2new = reshape(A(:, col ), 13, size(A,1)/13)';
col= 6;
remx2new = reshape(A(:, col ), 13, size(A,1)/13)';
%% 3d TIAN JIA LU JIN 
subplot(2,2,3)
x = [0:12]; %horizon
y = datenum(datetime(time_date))'; % time
[X, Y] = meshgrid(x, y);

threshold =0.01;
A36 = remx2new;
ccclim = [quantile(reshape(A36,1,[]),threshold)  -quantile(reshape(A36,1,[]),threshold)]

surf(X, Y, remx2new, 'FaceColor', 'interp');set(gca,'Clim',ccclim);
colormap(slanCM('RdBu'));
shading interp
xlim([0 12]);xticks(0:1:12)
ylim([y(1) y(end)])
datetick('y','yy','keeplimits');
xlabel('Horizon');ylabel('Year');%zlabel('Z轴');
%colorbar;
title(['$\varepsilon_{', 'REMX','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex')
subplot(2,2,4)
imagesc(0:12,datenum(y),remx2new);
set(gca,'Clim',ccclim)
colormap(slanCM('RdBu'))
%colormap('parula')
ylim(datenum([y(1),y(end)]));datetick('y','yy','keeplimits');
colorbar;
xticks(0:1:12)
xlabel('Horizon');ylabel('Year');
title(['$\varepsilon_{', 'REMX','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex')


subplot(2,2,1)
A36 = gpr2new;
ccclim = [quantile(reshape(A36,1,[]),threshold)  -quantile(reshape(A36,1,[]),threshold)]
surf(X, Y, gpr2new, 'FaceColor', 'interp');set(gca,'Clim',ccclim);
colormap(slanCM('RdBu'));
shading interp
xlim([0 12]);xticks(0:1:12)
ylim([y(1) y(end)])
datetick('y','yy','keeplimits');
xlabel('Horizon');ylabel('Year');%zlabel('Z轴');
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex')
%colorbar;
subplot(2,2,2)
imagesc(0:12,datenum(y),gpr2new);
set(gca,'Clim',ccclim)
colormap(slanCM('RdBu'))
%colormap('parula')
ylim(datenum([y(1),y(end)]));datetick('y','yy','keeplimits');
colorbar;
xticks(0:1:12)
xlabel('Horizon');ylabel('Year');
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex')
%% irf的0 1 2 3 horizon
subplot(2,1,1)
plot(y,gpr2new(:,[1 ]) ,'LineWidth',1.5,'LineStyle','-','Color','r')
hold on
plot(y,gpr2new(:,[ 2 ]) ,'LineWidth',1.5,'LineStyle','-.','Color',[0 0.4470 0.7410])
plot(y,gpr2new(:,[ 3 ]) ,'LineWidth',1.5,'LineStyle',':','Color',[0.4660 0.6740 0.1880])
plot(y,gpr2new(:,[ 4 ]) ,'LineWidth',1.5,'LineStyle','--','Color',[0.4940 0.1840 0.5560])

 plot(y,zeros(size(y,2),1),'-k','LineWidth',1)
xlim([y(1) y(end)])
datetick('x','yyyy','keeplimits');
legend('Contemporary','1-month ahead','2-month ahead','3-month ahead','box','off')
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)

subplot(2,1,2)
plot(y,remx2new(:,[1 ]) ,'LineWidth',1.5,'LineStyle','-','Color','r')
hold on
plot(y,remx2new(:,[ 2 ]) ,'LineWidth',1.5,'LineStyle','-.','Color',[0 0.4470 0.7410])
plot(y,remx2new(:,[ 3 ]) ,'LineWidth',1.5,'LineStyle',':','Color',[0.4660 0.6740 0.1880])
plot(y,remx2new(:,[ 4 ]) ,'LineWidth',1.5,'LineStyle','--','Color',[0.4940 0.1840 0.5560])

 plot(y,zeros(size(y,2),1),'-k','LineWidth',1)
xlim([y(1) y(end)])
datetick('x','yyyy','keeplimits');
legend('Contemporary','1-month ahead','2-month ahead','3-month ahead','box','off')
title(['$\varepsilon_{', 'REMX','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
%% 特定时点脉冲
time_point = [37 87 112]; tt=datestr(y,'yyyy-mm');
subplot(1,2,1)
plot(0:12,mean(gpr2new) ,'LineWidth',2, 'DisplayName',['t= Full sample'],...
    'LineStyle','-','Color','k')%,'Marker','o','MarkerFaceColor','k')%全样本平均
hold on
plot(0:12,gpr2new(time_point(1),:)' ,'LineWidth',2, 'DisplayName',['t=' num2str(time_date(time_point(1),1)) '-' num2str(time_date(time_point(1),2))],...
    'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
plot(0:12,gpr2new(time_point(2),:)','LineWidth',2, 'DisplayName',['t=' num2str(time_date(time_point(2),1)) '-0' num2str(time_date(time_point(2),2))],...
         'LineStyle','-','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
plot(0:12,gpr2new(time_point(3),:)' ,'LineWidth',2, 'DisplayName',['t=' num2str(time_date(time_point(3),1)) '-0' num2str(time_date(time_point(3),2))],...
          'LineStyle','-','Color',[0.4660 0.6740 0.1880],'Marker','v','MarkerFaceColor',[0.4660 0.6740 0.1880])
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
legend('show')
xlabel('Horizon');

subplot(1,2,2)
plot(0:12,mean(remx2new) ,'LineWidth',2, 'DisplayName',['t= Full sample'],...
    'LineStyle','-','Color','k')%,'Marker','o','MarkerFaceColor','k')%全样本平均
hold on
plot(0:12,remx2new(time_point(1),:)' ,'LineWidth',2,'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
plot(0:12,remx2new(time_point(2),:)','LineWidth',2,...
            'LineStyle','-','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
plot(0:12,remx2new(time_point(3),:)' ,'LineWidth',2,...
            'LineStyle','-','Color',[0.4660 0.6740 0.1880],'Marker','v','MarkerFaceColor',[0.4660 0.6740 0.1880])
title(['$\varepsilon_{', 'REMX','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
xlabel('Horizon');
%% 
load gpr2remx.mat
subplot(1,2,1)
x = [0:12]; %horizon
y = datenum(datetime(time_date))'; % time
[X, Y] = meshgrid(x, y);

threshold =0.01;
A36 = gpr2remx;
ccclim = [quantile(reshape(A36,1,[]),threshold)  -quantile(reshape(A36,1,[]),threshold)]

surf(X, Y, gpr2remx, 'FaceColor', 'interp');set(gca,'Clim',ccclim);
colormap(slanCM('RdBu'));
shading interp
xlim([0 12]);xticks(0:1:12)
ylim([y(1) y(end)])
datetick('y','yy','keeplimits');
xlabel('Horizon');ylabel('Year');%zlabel('Z轴');
%colorbar;
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','REMX', '$'], 'interpreter', 'latex')
subplot(1,2,2)
imagesc(0:12,datenum(y),gpr2remx);
set(gca,'Clim',ccclim)
colormap(slanCM('RdBu'))
%colormap('parula')
ylim(datenum([y(1),y(end)]));datetick('y','yy','keeplimits');
colorbar;
xticks(0:1:12)
xlabel('Horizon');ylabel('Year');
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','REMX', '$'], 'interpreter', 'latex')
%% fanshishi_动态
load('kldiff.mat', 'jj')
load('bgwdiff.mat', 'jj1')
load('irf_gpr2new_kl.mat') %第一列为原始 第二列 反事实 134*13
load('irf_gpr2new_bgw.mat')

kl = reshape(irf_gpr2new_kl(:,2),13,134)';
bgw = reshape(irf_gpr2new_bgw(:,2),13,134)';
minzi = {'Contemporary','1-month ahead','2-month ahead','3-month ahead'};
for i =1:4
subplot(2,2,i)
plot(y,gpr2new(:,[i]) ,'LineWidth',1.5,'LineStyle','-','Color','r')
hold on
plot(y,kl(:,[ i ]) ,'LineWidth',1.5,'LineStyle','-.','Color',[0 0.4470 0.7410])
ylim([ -0.35 0.35  ])
xlim([y(1) y(end)])
datetick('x','yyyy','keeplimits');
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
title(minzi{i})
end
lgd=legend('Unrestricted','Counterfactual','FontSize',12);
lgd.NumColumns = 4;%图列列数

figure(2)
for i =1:4
subplot(2,2,i)
plot(y,gpr2new(:,[i]) ,'LineWidth',1.5,'LineStyle','-','Color','r')
hold on
plot(y,bgw(:,[ i ]) ,'LineWidth',1.5,'LineStyle','-.','Color',[0 0.4470 0.7410])
ylim([ -0.35 0.35  ])
xlim([y(1) y(end)])
datetick('x','yyyy','keeplimits');
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
title(minzi{i})
end
lgd=legend('Unrestricted','Counterfactual','FontSize',12);
lgd.NumColumns = 4;%图列列数
%% 在前一小节的时变反事实图中添加差值对比
load('kldiff.mat', 'jj')
load('bgwdiff.mat', 'jj1')
load('irf_gpr2new_kl.mat') %第一列为原始 第二列 反事实 134*13
load('irf_gpr2new_bgw.mat')

kl = reshape(irf_gpr2new_kl(:,2),13,134)';
bgw = reshape(irf_gpr2new_bgw(:,2),13,134)';
minzi = {'Contemporary','1-month ahead','2-month ahead','3-month ahead'};
for i = 1:4
    subplot(2,2,i)
    % 第一个y轴 - 原始数据
    yyaxis left
    plot(y, gpr2new(:, i), 'LineWidth', 1.5, 'LineStyle', '-', 'Color', 'r')
    hold on
    plot(y, kl(:, i), 'LineWidth', 1.5, 'LineStyle', '-.', 'Color', [0 0.4470 0.7410])
    ylim([-0.35 0.35])
    xlim([y(1) y(end)])
    % 设置y轴刻度，每隔0.1一个标签
    yticks(-0.3:0.1:0.3)
    % 计算差值
    diff_data = gpr2new(:, i) - kl(:, i);
    % 第二个y轴 - 差值
    yyaxis right
    plot(y, diff_data, 'LineWidth', 1.5, 'LineStyle',':', 'Color', [0.4660 0.6740 0.1880])
    ylim([-0.25 0.25])
    % 图形设置
    datetick('x','yyyy','keeplimits')
    set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')
    title(minzi{i})
    % 设置两个y轴的颜色
    ax = gca;
    ax.YAxis(1).Color = [0 0 0];  % 左边y轴黑色
    ax.YAxis(2).Color = [0.4660 0.6740 0.1880];  % 右边y轴灰色
end
% 图例（只显示原始数据的线条）
lgd = legend('Unrestricted', 'Counterfactual', 'Difference', 'FontSize', 10);
lgd.NumColumns = 3;  % 图例列数

%% fanshishi_静态三定点-KL
time_point = [37 87 112]; tt=datestr(y,'yyyy-mm');

for i=1:3
subplot(2,2,i)
plot(0:12,gpr2new(time_point(i),:)' ,'LineWidth',1.5,...
    'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
hold on
plot(0:12,kl(time_point(i),:)','LineWidth',1.5,...
         'LineStyle','--','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
%xlabel('Horizon');
title(['t=' num2str(time_date(time_point(i),1)) '-' num2str(time_date(time_point(i),2),'%02d')])
end
subplot(2,2,4)
plot(0:12,mean(gpr2new)' ,'LineWidth',1.5,...
    'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
hold on
plot(0:12,mean(kl)','LineWidth',1.5,...
         'LineStyle','--','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
title(['t= Full sample'])
%xlabel('Horizon');

lgd=legend('Unrestricted','Counterfactual','FontSize',12);
lgd.NumColumns = 4;%图列列数
cum4 = cumsum(gpr2new(time_point,:)');
cum44 = cumsum( kl(time_point,:)');
cum_change = (cum44-cum4)./cum4;
disp('最后1期的累积变化率真实情况:');disp(cum4(end,:));
disp('最后1期的累积变化率反事实:');disp(cum44(end,:));
disp('最后1期的累积变化率为:');disp(cum_change(4,:));%maic脉冲主要集中在前三期
%% 特定时点的反事实，添加了差值线
time_point = [37 87 112]; tt=datestr(y,'yyyy-mm');

for i=1:3
subplot(2,2,i)
 % 第一个y轴 - 原始数据
yyaxis left
plot(0:12,gpr2new(time_point(i),:)' ,'LineWidth',1.5,...
    'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
hold on
plot(0:12,kl(time_point(i),:)','LineWidth',1.5,...
         'LineStyle','--','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
%ylim([-0.2 0.2])
 % 计算差值
diff_data = gpr2new(time_point(i), :)' - kl(time_point(i), :)';
yyaxis right
plot(0:12, diff_data, 'LineWidth', 1.5, ...
    'LineStyle', ':', 'Color', [0.4660 0.6740 0.1880], 'Marker', '^', 'MarkerFaceColor', [0.4660 0.6740 0.1880])

set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
%xlabel('Horizon');
title(['t=' num2str(time_date(time_point(i),1)) '-' num2str(time_date(time_point(i),2),'%02d')])
ax = gca;
ax.YAxis(1).Color = [0 0 0];  % 左边y轴黑色
ax.YAxis(2).Color = [0.4660 0.6740 0.1880];  % 右边y轴灰色
end
subplot(2,2,4)
yyaxis left
plot(0:12,mean(gpr2new)' ,'LineWidth',1.5,...
    'LineStyle','-','Color','r','Marker','o','MarkerFaceColor','r')
hold on
plot(0:12,mean(kl)','LineWidth',1.5,...
         'LineStyle','--','Color',[0 0.4470 0.7410],'Marker','s','MarkerFaceColor',[0 0.4470 0.7410])
% 计算差值
mean_diff = mean(gpr2new)' - mean(kl)';
yyaxis right
plot(0:12, mean_diff, 'LineWidth', 1.5, ...
    'LineStyle', ':', 'Color', [0.4660 0.6740 0.1880], 'Marker', '^', 'MarkerFaceColor', [0.4660 0.6740 0.1880])
title(['$\varepsilon_{', 'GPR','}\uparrow\ \rightarrow\ ','Clean', '$'], 'interpreter', 'latex',...
    'FontSize',15)
xlim([0 12])
set(gca,'GridAlpha', 0.5, 'YGrid', 'on', 'XGrid','on')%y坐标线
ax = gca;
ax.YAxis(1).Color = [0 0 0];  % 左边y轴黑色
ax.YAxis(2).Color = [0.4660 0.6740 0.1880];  % 右边y轴灰色
title(['t= Full sample'])
%% 
load('other2new.mat')
new2new = reshape(other2new(:,3),13,134)';
fevd_new = nan(13,3,134);%13h*3nvar*t;
for t=1:size(fevd_new,3)
    t0= [gpr2new(t,:)'.^2 remx2new(t,:)'.^2 new2new(t,:)'.^2 ];
    t00=cumsum(t0);
    t00_sum = sum(t00,2);
    fevd_new(:,:,t) = (t00./t00_sum)*100;
end

FillColor   =[1,0,0;...
    0 0.4470 0.7410;...
    119/255,119/255,119/255;
    ]; % 颜色
fevd_new_y= reshape(fevd_new(4,[1 2 ],:),[],size(fevd_new,3)); % h var
h=bar( y  ,fevd_new_y' ,0.9,'stacked','EdgeColor','none')%
ylim([0 100])
datetick('x','yyyy','keeplimits');
xlabel('Year');ylabel('FEVD')
legend('GPR shock','REMX shock','Location','northwest','edgecolor','none')
for k = 1:length(h)
    h(k).FaceColor = FillColor(k, :);
end
%% 定时的预测误差方差分解
fevd_time1 = fevd_new(:,:,time_point(1));
fevd_time2 = fevd_new(:,:,time_point(2));
fevd_time3 = fevd_new(:,:,time_point(3));
fevd_time4 = mean(fevd_new,3);


%% 所有系数table3
load('all_xishu.mat')
ii = [1 4:9 22 2 10:15 23 3 16:21 24 ];
ii_label = {'A_{21}','B1_{11}','B1_{12}','B1_{13}','B2_{11}','B2_{12}','B2_{13}','SV_{1}',...
            'A_{31}','B1_{21}','B1_{22}','B1_{23}','B2_{21}','B2_{22}','B2_{23}','SV_{2}',...
            'A_{32}','B1_{31}','B1_{32}','B1_{33}','B2_{31}','B2_{32}','B2_{33}','SV_{3}'};
for i=1:24
subplot(3,8,i)
plot(y,all_xishu(:,ii(i)))
datetick('x','yy');
title(ii_label{i})
end

table_coef = nan(8,3);table_coef1 = nan(8,3);table_coef2 = nan(8,3);
table_coef_mean = mean(all_xishu);
table_coef_min = min(all_xishu);
table_coef_max = max(all_xishu);
for i=1:24
    table_coef(i)=table_coef_mean(ii(i));
    table_coef1(i)=table_coef_min(ii(i));
    table_coef2(i)=table_coef_max(ii(i));
end