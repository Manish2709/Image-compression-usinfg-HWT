image_name = rgb2gray(imread('cameraman1.jpg'));
delta = 0.01;
disp(delta)
if (delta>1 || delta<0)
    error('harr_wt: Delta must be a value between 0 and 1');
end
H1=[0.5 0 0 0 0.5 0 0 0;0.5 0 0 0 -0.5 0 0 0;0 0.5 0 0 0 0.5 0 0 ;0 0.5 0 0 0 -0.5 0 0 ;0 0 0.5 0 0 0 0.5 0;0 0 0.5 0 0 0 -0.5 0;0 0 0 0.5 0 0 0 0.5;0 0 0 0.5 0 0 0 -0.5;];
H2=[0.5 0 0.5 0 0 0 0 0;0.5 0 -0.5 0 0 0 0 0;0 0.5 0 0.5 0 0 0 0;0 0.5 0 -0.5 0 0 0 0;0 0 0 0 1 0 0 0;0 0 0 0 0 1 0 0;0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 1;];
H3=[0.5 0.5 0 0 0 0 0 0;0.5 -0.5 0 0 0 0 0 0;0 0 1 0 0 0 0 0;0 0 0 1 0 0 0 0;0 0 0 0 1 0 0 0;0 0 0 0 0 1 0 0;0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 1;];
H1o = (H1.*(2^0.5));
H2o = (H2.*(2^0.5));
H3o = (H3.*(2^0.5));
Ho=normc(H1o*H2o*H3o); %Resultant transformation matrix
H = H1*H2*H3;
x=double((image_name));
len=length(size(x));
if len~=2
    error('ERROR');
end
yo = zeros(size(x));
y = zeros(size(x));
[r,c]=size(x);
%Above 8x8 transformation matrix(H) is multiplied by each 8x8 block in the image
for i=0:8:r-8
    for j=0:8:c-8
        p=i+1;
        q=j+1;
        yo(p:p+7,q:q+7)=(Ho')*x(p:p+7,q:q+7)*Ho;
        y(p:p+7,q:q+7)=(H')*x(p:p+7,q:q+7)*H;
    end
end
figure;
imshow(x/255);
n1=nnz(y);                         
zo=yo;
m=max(max(yo));
yo=yo/m;
yo(abs(yo)<delta)=0;% Values within +delta and -delta in 'y' are replaced by zeros(This is the command that result in compression)
yo=yo*m;
z=y;
y=y/m;
y(abs(y)<delta)=0;                  
y=y*m;
n2=nnz(y);                          
for i=0:8:r-8
    for j=0:8:c-8
        p=i+1;
        q=j+1;
        zo(p:p+7,q:q+7)=Ho*yo(p:p+7,q:q+7)*Ho';
        z(p:p+7,q:q+7)=inv(H')*y(p:p+7,q:q+7)*inv(H);
    end
end
figure;
subplot(121);
imshow(zo/255);% Show the compressed image
title("normalised compression");
subplot(122)
imshow(z/255);
title("standard compression");
imwrite(x/255,'orginal1.tif');           %Check the size difference of the two images to see the compression
imwrite(z/255,'compressed1.tif');
% Below value is a measure of compression ratio, not the exact ratio
compression_ratio = n2/n1
