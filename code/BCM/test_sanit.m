clear;
close all

load('data/mat/bcm_write_test1.mat');
[n_rx, n_tx, n_s, n_pkt] = size(CSI_struct);

csi_11 = zeros(1,1);
csi_33 = zeros(1,1);
for i = 1:1:n_pkt
    csi = squeeze(CSI_struct(:,:,1:56,i));
    
    csi_11(i) = mean(csi(1,1,:)./csi(1,2,:));
    csi_33(i) = mean(csi(2,1,:)./csi(2,2,:));
    
    i
end

csi_sample = movmean(csi_11,20);
plot(angle(csi_sample),'k.-');