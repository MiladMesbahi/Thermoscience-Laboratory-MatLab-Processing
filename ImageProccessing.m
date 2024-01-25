%% Clearing
clc; clear; close;
%% Image Reading
imag_org=imread('600+50000.jpg');
imshow(imag_org);
%% Image Rescaling
imag_org=imag_org(1:90,:);
imshow(imag_org)
%% Image Preprocessing
imag_shrp=imsharpen(imag_org);
imag_haze=imreducehaze(imag_org);
imag_adjst=imadjust(imag_org);
imag_shrp_adjst=imsharpen(imag_adjst);
imag_adjst_shrp=imsharpen(imag_shrp);
imag_equalize=histeq(imag_shrp);
figure (1)
imshow(imag_shrp);
figure (2)
imshow(imag_shrp_adjst);
figure (8)
imshow(imag_adjst);
%% Image Binarization
imag_binary_method1=imbinarize(imag_shrp_adjst,'adaptive','ForegroundPolarity',...
    'dark','Sensitivity',0.2);
threshold=75;
imag_binary_method2= imag_shrp_adjst>threshold;
figure (3)
imshow(imag_binary_method1);
figure (9)
imshow(imag_binary_method2);
%% Noise Reduction
imag_boundary1=wiener2(imag_binary_method1,[5 5]);
Connectivity = bwconncomp(imag_boundary1, 8);
Objects = regionprops(Connectivity, 'Area');
Label = labelmatrix(Connectivity);
imag_boundary2 = ismember(Label, find([Objects.Area] >= 5000));

imshow(imag_boundary2);

%% Bead Spacing

[m,n]=size(imag_boundary2);
finisher=0;

for j=1:m
    for i=1:n/2
        if imag_boundary2(j,i)==0
            x1=i;
            y1=j;
            finisher=1;
            for k=x1+50:n
                if (imag_boundary2(y1,k)==0)&(finisher==1)
                          x2=k;
                          finisher=2;
                          for s=x2+50:n
                              if (imag_boundary2(y1,s)==0)&(finisher==2)
                                  x3=s;
                                  finisher=3;
                              end
                              if finisher==3
                                  break;
                              end
                          end
                end
         
                if finisher==3
                    break;
                end
            end
        end
    if finisher==3
    break;
    end
    end
if finisher==3
    break;
end
end

imshow(imag_boundary2);

hold on

x_line1=linspace(x1,x2);
y_line1=y1*ones(size(x_line1));
plot(x_line1,y_line1,'-b','LineWidth',2);

x_line2=linspace(x2,x3);
y_line2=y1*ones(size(x_line2));
plot(x_line2,y_line2,'-r','LineWidth',2);

BeadSpacing1=x2-x1;
BeadSpacing2=x3-x2;

text((3*x1+x2)/4,m-30,['Bead Spacing 1 = ' num2str(BeadSpacing1) 'pixels'],'Color','Red');
text((3*x2+x3)/4,m-30,['Bead Spacing 2 = ' num2str(BeadSpacing2) 'pixels'],'Color','Red');