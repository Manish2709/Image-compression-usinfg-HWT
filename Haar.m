clc;close all;clear all;
warning off;
bs=4; % block size
im_name='D8.png'
delta=0.01;
in=double(imread(im_name));
rgb=double(imread(im_name));
len=length(size(rgb));
for j1 = 1:3
t=rgb(:,:,j1);
n=bs;
Level=log2(n);
if 2^Level<n, error('block size should be 2,4,8,16');end 
H=[1];
NC=1/sqrt(2);
LP=[1 1]; 
HP=[1 -1];
for i=1:Level
    H=NC*[kron(H,LP);kron(eye(size(H)),HP)];
end
H1=H;
H2=H;
H3=H;
H1=normc(H1);
H2=normc(H2);
H3=normc(H3);
H=H1*H2*H3;
x=t;
y=zeros(size(x));
[r,c]=size(x);
for i=0:bs:r-bs
    for j=0:bs:c-bs
        p=i+1;
        q=j+1;
        y(p:p+bs-1,q:q+bs-1)=(H')*x(p:p+bs-1,q:q+bs-1)*H;
    end
end
n1=nnz(y);                          
z=y;
m=max(max(y));
y=y/m;
y(abs(y)<delta)=0;  %replace too low value to zero.                
y=y*m;
n2=nnz(y);                          
for i=0:bs:r-bs
    for j=0:bs:c-bs
        p=i+1;
        q=j+1;
        z(p:p+bs-1,q:q+bs-1)=H*y(p:p+bs-1,q:q+bs-1)*H';
    end
end
rgb(:,:,j1)=z;
end
disp('block size:');bs
figure;
subplot(1,2,1)
imshow(uint8(in)),title('Original image');
subplot(1,2,2)
imshow(uint8(rgb)),title('Compressed image');
title('Haar Transfromation- Image Compression');
% Find the error in pixel values
DIF=imsubtract(in,rgb);
mse=mean(mean(DIF.*DIF));
rmse=sqrt(mse);
rmse=(rmse(:,:,1)+rmse(:,:,1)+rmse(:,:,1))/3;
psnr=20*log(255/rmse);
comp_name='compressed_rgb.png'
imwrite(uint8(rgb),comp_name)
%calculating the compression ratio
im_file=imfinfo(im_name);
input_file_sz=im_file.FileSize;
comp_file=imfinfo(comp_name);
comp_file_sz=comp_file.FileSize;
x=1/(nnz(im_name)/nnz(comp_name));
cr=input_file_sz/comp_file_sz;
filesz = [input_file_sz comp_file_sz cr];
fprintf('HAAR Transformation..');
fprintf('im_name: %s  COMPRESSED_IMAGE_NAME: %s\n\n',im_name,comp_name)
formatSpec = 'INPUT FILE SIZE is %f, COMPRESSED FILE SIZE %f CR is %f\n\n';
fprintf(formatSpec,filesz)
ansrs = [rmse psnr];
formatSpec = 'RMSE is %f,  PSNR is %f \n';
fprintf(formatSpec,ansrs)