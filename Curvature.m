%% Clearing
clc; clear; close;

%% Image Reading
IP=104; %pixel/mm;
string_dia=0.76; %mm
y_str=IP*string_dia/2;

path=['IMG_4635'];
path1=[path '.jpg'];
imag_org=imread(path1);
imag_org=imrotate(imag_org,90);
imshow(imag_org);
impixelinfo
%% Image Rescaling
imag_org=rgb2gray(imag_org);
% resiz_im_x=1450:3350;
resiz_im_y=1960:2160;
imag_org=imag_org(resiz_im_y,:);
imshow(imag_org);
impixelinfo
%% Image Binarization

imag_bin=imbinarize(imag_org,"adaptive","ForegroundPolarity",...
    "bright","Sensitivity",0.5);
imshow(imag_bin);
%% Finding the String

% Thresh=110;
for Thresh=90:5:135
    [m n]=size(imag_org);
    
    for i=1:n
        counter=0;
        for j=2:m-1
            if (counter<2)&&(imag_org(j,i)<Thresh)&&(imag_org(j-1,i)>=Thresh)
                String_y1(i)=j;
                counter=counter+1;
            elseif (counter<2)&&(imag_org(j+1,i)>=Thresh)&&(imag_org(j,i)<Thresh)
                 if abs(j-String_y1(i))<5
                        for q=j+3:m-1
                            if(counter<2)&&(imag_org(q+1,i)>=Thresh)&&(imag_org(q,i)<Thresh)
                                    String_y2(i)=q;
                                    counter=counter+1;
                            end
                        end
                 else
                     String_y2(i)=j;
                    counter=counter+1;
                 end
            end
        end
    end
    x=1:n;
    figure(1)
    imshow(imag_org)
    hold on
    text(100,50,['Threshold = ' num2str(Thresh)],'Color','red','FontSize',14);
    plot(x,String_y1,'-w',x,String_y2,'-w','LineWidth',2);
    impixelinfo
    pause(1)
end
%% IP with Edge Detection

imag_edge=edge(imag_org,'Canny',0.05);
imshow(imag_edge);
%% Refinement Image
refin_size=1450:3350;
x_r=refin_size;
imag_org=imag_org(:,refin_size);
String_y1=String_y1(:,refin_size);
String_y2=String_y2(:,refin_size);

imshow(imag_org)
hold on
plot(x_r,String_y1(:,refin_size),'-w',x_r,String_y2(:,refin_size),'-w','LineWidth',1);
%% Finding the string centerline
[w z]=size(imag_org);
x_r=1:z;

y_mid1=(String_y2(1)+String_y1(1))/2;
y_mid2=(String_y2(end)+String_y1(end))/2;
m_line=(y_mid2-y_mid1)/(x(end)-x(1));
y_ave_str=mean((String_y2-String_y1)/2);

centerline=m_line*x_r+(y_mid1-m_line*x(1));
y_up1=y_mid1-y_str;
y_down1=y_mid1+y_str;

y_up=m_line*x_r+(y_up1-m_line*x(1));
y_down=m_line*x_r+(y_down1-m_line*x(1));

y=y_up-String_y1;
y2=String_y2-y_down;
y3=String_y2-String_y1;

imshow(imag_org);
hold on
plot(x_r,String_y1,'-w',x_r,String_y2,'-w','LineWidth',1);
plot(x_r,y_down,'-r',x_r,y_up,'-r','LineWidth',1);
impixelinfo
%% Result
figure(1)
imshow(imag_org)
hold on
plot(x_r,String_y1,'-w',x_r,String_y2,'-w','LineWidth',1);
plot(x_r,centerline,'-r');

figure (2)
plot(x_r,y,'-r');
fig_name=[path '_red_curve' '.jpg'];
% saveas(gcf,fig_name)

figure (3)
plot(x_r,y2,'-b');
fig_name=[path '_blue_curve' '.jpg'];
% saveas(gcf,fig_name)

figure (4)
plot(x_r,y3,'-g');
fig_name=[path '_green_curve' '.jpg'];
% saveas(gcf,fig_name)
%% Digital to Analog!

y_opt=y2;

n=40;
% for n=60:90
    clear x_peak
    clear y_peak
    con=1;
    y_ave=movmean(y_opt,n);
    y_ave=movmean(y_ave,40);
    length_str=length(y_ave);
    figure (5)
    plot(x_r,y_ave,'-g','LineWidth',2);
    hold on
    plot(x_r,y_opt,'-r');
    
    for q=1:length_str
        if (con==1)&&(y_ave(q+1)<y_ave(q))
            y_peak(con)=y_opt(q);
            x_peak(con)=x_r(q);
            con=con+1;
        elseif (q<length_str-1)&&(con~=1)&&(y_ave(q-1)<y_ave(q))&&(y_ave(q+1)<y_ave(q))&&(abs(x_r(q)-x_peak(con-1))>50)
            y_peak(con)=y_opt(q);
            x_peak(con)=x_r(q);
            con=con+1;
        elseif (con~=1)&&(q==length_str)&&(y_ave(q-1)<y_ave(q))
            y_peak(con)=y_opt(q);
            x_peak(con)=x_r(q);
            con=con+1;
        end
    end
    S1=text(2000,37,['n= ' num2str(n)],'FontSize',16);
    scatter(x_peak,y_peak,'Filled',"blue");
    xlabel("x (pixel)");
    ylabel("String Dev (pixel)");
    pause(2);
    delete(S1);
    hold off
% end
%% Wave amplitude/period

for z=1:con-2
    period(z)=(x_peak(z+1)-x_peak(z));
end
period_ave=mean(period)
amplitude_wave=mean(y_peak)
%% Fitting Sine function

myfittype = fittype("a+b*sin(c*x)",...
    dependent="y",independent="x",...
    coefficients=["a" "b" "c"]);
myfit = fit(x_r',y_ave',myfittype)
%%
y_manual=32+5*sin(1e-2*x_r);
plot(myfit,x_r,y)
hold on
plot(x_r,y_manual)
%% Curvature calculation

String_dia=abs(String_y2-String_y1);
String_avedia=mean(String_dia);
String_std=std(String_dia);

String_curve=100*String_std/String_avedia;

%% Visualisation
figure (1)
imshow(imag_org);
hold on
text(10,30,['String Curvature= ', num2str(String_curve) ' %']...
    ,'FontSize', 10,'Color','blue');
fig_name=[name '_curve' '.png'];
saveas(gcf,fig_name)