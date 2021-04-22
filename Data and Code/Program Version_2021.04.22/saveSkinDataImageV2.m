 function [filtSurface,SurfaceTrue] = saveSkinDataImageV2(surfaceLocation,depth,r,savePath,name)


%*******************************************************

%功能：计算厚度、粗糙度以及成图留存
%完成度:整体已完成，Rm的区域性分析已完成
%码农：Zhao Ruihang
%时间：2020.02.03
%Matlab版本：2019a

%*******************************************************

%   UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

%%  验证数据传输



%% 进行数据处理

% x=(-512:511)*0.00684;
% y=(-512:511)*0.00684;
% x=(-512:511)*0.00879; %x轴的像素大小以及分布
% y=(-512:511)*0.00879; %y轴的像素大小以及分布
x=(-r:r)*0.009; %x轴的像素大小以及分布
y=(-r:r)*0.009; %y轴的像素大小以及分布
% x=(-r:r)*0.00684; %x轴的像素大小以及分布
% y=(-r:r)*0.00684; %y轴的像素大小以及分布

%进行平滑处理--用以成图美观
w2=fspecial('average',[9 9]); 
averageDepth=imfilter(depth,w2,'replicate');  %平滑过后的厚度值
% averageDepth=depth;

% w2=fspecial('average',[5 5]); 
% surfaceLocation = imfilter(surfaceLocation,w2,'replicate');
%% 厚度、粗糙度的计算

s=surfaceLocation*0.003493/1.38*10^3;
[X,Y] = meshgrid(x,y);
[fitresult, ~] = createFit(X, Y, s);  %二元三次拟合以减去曲率
fitSurface = fitresult(X,Y);
% flatData=(s-fitSurface);
filtSurface = (s-fitSurface);
% 
% w2=fspecial('average',[3 3]); %% 定义一个滤波器 
% averageSurface=imfilter(filtSurface,w2,'replicate');
% filtSurface = abs(averageSurface-max(averageSurface(:)));  %最终提取到的表面
% 
%  
Ra = 0 ; sum = 0;count = 0;thickness=0;st=0;
for i=1:2*r
    for j=1:2*r
        if ~isnan(averageDepth(i,j))
            sum =sum + filtSurface(i,j);
            thickness = thickness+averageDepth(i,j);
            count = count+1;
        else
            filtSurface(i,j)=nan;  %绘图需要
        end
    end   
end
thickness = thickness/(count)  %平均厚度
% averageDepth存储的厚度信息
% %%
% meanDepth = mean(averageDepth);


%%
% 分布范围间距（RD）、大于均值占比(MP)以及频数峰值处厚度（PT）

num = 0;
for i=1:2*r
    for j=1:2*r
        if ~isnan(averageDepth(i,j))%(~isnan(filtSurface(i,j))&(filtSurface(i,j)~=0))%
            st = st+(averageDepth(i,j)-thickness).^2;
           if averageDepth(i,j)>=thickness
               num = num +1;
           end
        end
    end   
end
rateBig = num/count   
st = sqrt(1/(count)*st)  %厚度标准差
 
DepthMin = min(averageDepth);
DepthMin = min(DepthMin);
DepthMax = max(averageDepth);
DepthMax = max(DepthMax);
Depthm = DepthMax - DepthMin

%对区域性的粗糙度进行计算

%＃＃＃＃＃＃＃＃＃＃＃皮肤表面粗糙度＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　

%平均粗糙度Ra

meanSueface=sum/(count);
Ra=0;Rsk=0;Rku=0;q=0;sk=0;ku=0;

for i=1:2*r
    for j=1:2*r
        if ~isnan(filtSurface(i,j))
             SurfaceTrue(i,j) = abs(filtSurface(i,j)-meanSueface);
             Ra = Ra + SurfaceTrue(i,j);
        end
    end   
end
Ra = 1/(count)*Ra     %粗糙度
% Rast = std(RaNum)
[a,b]=size(SurfaceTrue);
num = 0;
for i=1:a
    for j=1:b
        if SurfaceTrue(i,j) ~= 0
              q = q + SurfaceTrue(i,j).^2;  %来计算Rq，距离的平方/A
              sk = sk + SurfaceTrue(i,j).^3; %来计算Rsk，距离的三次方/A
              ku = ku + SurfaceTrue(i,j).^4; %来计算Rku，距离的四次方/A
              num=num+1;
        end
    end   
end
Rq = sqrt(1/(num)*q)  % 均方根高度
Rsk = (sk/num)/(Rq^3) % 偏斜度
Rku = (ku/num)/(Rq^4) % 尖锐度

%极大粗糙度Rm
% 进行平滑处理

w2=fspecial('average',[5 5]); %% 定义一个滤波器 
filtSurfaceAll=imfilter(filtSurface,w2,'replicate');
RmMin = min(filtSurfaceAll);
RmMin = min(RmMin);
RmMax = max(filtSurfaceAll);
RmMax = max(RmMax);
Rm = RmMax - RmMin



%   
% %% 成图留存
% 
% % w2=fspecial('average',[5 5]); 
% % averageDepth=imfilter(averageDepth,w2,'replicate');  
% % 
% % ＃＃＃＃＃＃＃＃＃＃＃2D厚度分布＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　
% % 
w2=fspecial('average',[3 3]); %% 定义一个滤波器 
averageDepth=imfilter(averageDepth,w2,'replicate');

fig2 = figure(2);
mesh(x,y,averageDepth);
set(gca,'FontSize',32);%,'FontSize',16
set(gca,'tickdir','in');
set(gca,'GridAlpha',0.8);
set(gca,'LineWidth',0.8);
% zlim([30,80]);
axis([-2.5,2.5,-2.5,2.5,15,150])
colorbar;
colormap(jet);
caxis([0,150]);
xlabel('mm','FontName','Times New Roman','FontSize',40,'color','k');%x轴坐标
ylabel('mm','FontName','Times New Roman','FontSize',40,'color','k');%y轴坐标
zlabel('Thickness\um','FontName','Times New Roman','FontSize',40,'color','k');%z轴坐标
title('SkinDepth','FontName','Times New Roman','FontSize',40,'color','k'); %标题

set(fig2,'position',[100 100 1000 800]);

print(fig2,'-dbitmap',strcat(savePath,'\',name,'_Depth.bmp'));
print(fig2,'-dbitmap',strcat(savePath,'\',name,'_Depth.fig'));
% saves(fig2,'-dbitmap',strcat(savePath,'\',name,'_Depth.fig'))


%＃＃＃＃＃＃＃＃＃＃＃3D厚度分布＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　

fig3 = figure(3);
contour3(x,y,depth);  
% view(3);
set(gca,'FontSize',32);%,'FontSize',16
set(gca,'tickdir','in');
set(gca,'GridAlpha',0.8);
set(gca,'LineWidth',0.8);
colorbar;
colormap(jet);
caxis([0,150]);
% xlim([20,120]);
% xlim([20,120]);
zlim([15,150]);
xlabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
zlabel('Thickness\um','FontName','Times New Roman','FontSize',32,'color','k');%z轴坐标
title('3D Thickness distribution','FontName','Times New Roman','FontSize',32,'color','k'); %标题
set(fig3,'position',[150 150 1000 800]);
print(fig3,'-dbitmap',strcat(savePath,'\',name,'_Depth3D.bmp'));
print(fig3,'-dbitmap',strcat(savePath,'\',name,'_Depth3D.fig'));

%＃＃＃＃＃＃＃＃＃＃＃厚度频数分布＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　

fig4 = figure(4);
h=histogram(averageDepth,'binwidth',1);
set(gca,'FontSize',24);%,'FontSize',16
xlabel('Thickness\um','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('Frequency','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
title('Thickness frequency distribution','FontName','Times New Roman','FontSize',28,'color','k');%z轴坐标
% axis([35,80,0,8000])
xlim([15,150]);
set(fig4,'position',[200 200 1000 800]);
print(fig4,'-dbitmap',strcat(savePath,'\',name,'_DepthHistogram.bmp'));
print(fig4,'-dbitmap',strcat(savePath,'\',name,'_DepthHistogram.fig'));

% 厚度进行归一化处理
fig5 = figure(5);clf;
h = histogram(averageDepth,'Normalization','probability','binwidth',1.5);
set(gca,'FontSize',24);%,'FontSize',16
% set(gca,'LineWidth',1.5);
xlabel('um','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('Frequency','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
title('Depth frequency distribution','FontName','Times New Roman','FontSize',32,'color','k'); %标题
xlim([15,150]);
ylim([0,0.2]);
set(fig5,'position',[350 350 1000 800]);
print(fig5,'-dbitmap',strcat(savePath,'\',name,'_DepthHistogramOne.bmp'));
print(fig5,'-dbitmap',strcat(savePath,'\',name,'_DepthHistogramOne.fig'));

[~,valusY] = max(h.Values);
DepthMax =(h.BinEdges(valusY)+h.BinEdges(valusY+1))/2
%＃＃＃＃＃＃＃＃＃＃＃2D皮肤表面形态＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　
% 
fig6 = figure(6);
[~,~]=contourf(x,y,filtSurface);%等高线
set(gca,'FontSize',32);%,'FontSize',16
set(gca,'LineWidth',1.5);
colorbar;
colormap(jet);
caxis([-20,20]);
% axis([-3.5,3.5,-3.5,3.5])
xlabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
title('Surface distribution','FontName','Times New Roman','FontSize',32,'color','k'); %标题
set(fig6,'position',[350 350 1000 800]);
% text(2.5,3,num2str(Ra),'FontSize',20,'color','r' );
print(fig6,'-dbitmap',strcat(savePath,'\',name,'_Surface.bmp'));
print(fig6,'-dbitmap',strcat(savePath,'\',name,'_Surface.fig'));



%＃＃＃＃＃＃＃＃＃＃＃3D皮肤表面形态＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　
% 
% fig7 = figure(7);
% contour3(x,y,filtSurface);  
% % view(3);
% set(gca,'FontSize',32);%,'FontSize',16
% set(gca,'tickdir','in');
% set(gca,'GridAlpha',0.8);
% set(gca,'LineWidth',0.8);
% % axis([-3.5,3.5,-3.5,3.5,20,60]);
% colorbar;
% colormap(jet);
% caxis([-20,20]);
% xlabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
% ylabel('mm','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
% zlabel('Thickness\um','FontName','Times New Roman','FontSize',32,'color','k');%z轴坐标
% title('Surface 3D','FontName','Times New Roman','FontSize',32,'color','k'); %标题
% set(fig7,'position',[300 300 1000 800]);
% print(fig7,'-dbitmap',strcat(savePath,'\',name,'_Surface3D.bmp'));
% print(fig7,'-dbitmap',strcat(savePath,'\',name,'_Surface3D.fig'));

%＃＃＃＃＃＃＃＃＃＃＃粗糙度的频数统计＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃＃　


fig8 = figure(8);clf;
h = histogram(filtSurface-meanSueface,'binwidth',1.5);
set(gca,'FontSize',32);%,'FontSize',16
set(gca,'LineWidth',1.5);
xlabel('um','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('Frequency','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
title('Ra frequency distribution','FontName','Times New Roman','FontSize',32,'color','k'); %标题
% axis([-25,25,0,40000]);
xlim([-20,20]);
set(fig8,'position',[350 350 1000 800]);
print(fig8,'-dbitmap',strcat(savePath,'\',name,'_RaHistogram.bmp'));
print(fig8,'-dbitmap',strcat(savePath,'\',name,'_RaHistogram.fig'));
% saves(fig7,'-dbitmap',strcat(savePath,'\',name,'_RaHistogram.fig'))

% 粗糙度进行归一化处理
fig9 = figure(9);clf;
h = histogram(filtSurface-meanSueface,'Normalization','probability','binwidth',1);
set(gca,'FontSize',24);%,'FontSize',16
% set(gca,'LineWidth',1.5);
xlabel('um','FontName','Times New Roman','FontSize',32,'color','k');%x轴坐标
ylabel('Frequency','FontName','Times New Roman','FontSize',32,'color','k');%y轴坐标
title('Ra frequency distribution','FontName','Times New Roman','FontSize',32,'color','k'); %标题
xlim([-20,20]);
ylim([0,0.2]);
set(fig9,'position',[350 350 1000 800]);
print(fig9,'-dbitmap',strcat(savePath,'\',name,'_RaHistogramOne.bmp'));
print(fig9,'-dbitmap',strcat(savePath,'\',name,'_RaHistogramOne.fig'));

close all

end

