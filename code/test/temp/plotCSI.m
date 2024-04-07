clear;
close all

load('CSI_atheros_CH40_tx2.mat');

for pkt_i = 1:2:1000
    pkt_i
    CSI = squeeze(CSI_mat(:,:,:,pkt_i));
    
    subplot(2,1,1)
    plot(squeeze(db(abs(CSI(1,1,:)))));
    hold off
    subplot(2,1,2)
    plot(squeeze(db(abs(CSI(3,1,:)))));
    hold off
    waitforbuttonpress();
end