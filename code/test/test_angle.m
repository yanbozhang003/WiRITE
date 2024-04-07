clear;
close all

load('../csi_log/yanbo/uppercase/trace1/B_1.mat');
n_pkt = length(CSI_st_all);

plt_config = {'k.-','r.-','b.-'};
for i = 1:1:n_pkt
    CSI = CSI_st_all(1,i).csi;
    
    for rx_idx = 1:2:3
%         for tx_idx = 1:1:3
%             CSI_angle = squeeze(angle(CSI(rx_idx,tx_idx,:)));
%             
%             plot(unwrap(CSI_angle),'k.-');ylim([-2*pi 2*pi]);
%             title(['pkt: ', num2str(i), ' rx: ', num2str(rx_idx),...
%                 ' tx: ', num2str(tx_idx)]);
%             waitforbuttonpress();
%         end
        CSI_angle = squeeze(angle(CSI(rx_idx,:,:)));
        for tx_idx = 1:1:3
            csi_plot = unwrap(squeeze(CSI_angle(tx_idx,:)));
            plot(csi_plot,plt_config{tx_idx});hold on
            title(['pkt: ', num2str(i), ' rx: ', num2str(rx_idx)]);
        end
        xlabel('subcarrier');ylabel('phase (unwrapped)');
        ylim([-2*pi 2*pi]);
        legend('tx1','tx2','tx3');
        hold off
        waitforbuttonpress();
    end
end
