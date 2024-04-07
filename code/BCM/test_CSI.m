clear;
close all

load('data/mat/bcm_write_test1.mat');
[n_rx, n_tx, n_s, n_pkt] = size(CSI_struct);

CSI_angle = angle(CSI_struct);
for i = 1:1:n_pkt
    for j = 1:1:n_rx
        for k = 1:1:n_tx
            csi_plt_angle = squeeze(CSI_angle(j,k,:,i));
            
            plot(unwrap(csi_plt_angle),'k.-');
%             ylim([-pi pi]);
            title(['pkt: ', num2str(i),'rx: ', num2str(j), 'tx: ', num2str(k)]);
            hold off
            
            waitforbuttonpress();
        end
    end
end
