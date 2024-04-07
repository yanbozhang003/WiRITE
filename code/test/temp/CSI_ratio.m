clear;
close all

load('CSI_atheros_CH149_static.mat');

CSI_r = zeros(1,1000);

%%
% for i = 1:1:1000
%     CSI = squeeze(CSI_mat(:,:,:,i));
%     
%     CSI_tmp = squeeze(CSI(2,2,:) ./ CSI(2,1,:));
%     
%     CSI_r(i) = mean(CSI_tmp);
% %     CSI_r(i) = mean(squeeze(CSI_mat(1,1,:,i)));
% end
% 
% % plot(wrapTo2Pi(angle(CSI_r)))
% % ylim([0 2*pi])
% 
% plot(abs(CSI_r))
% ylim([0 2])

%%
for sc = 1:56
    CSI_plt = zeros(1,1000);
    for i = 1:1:1000
        CSI = squeeze(CSI_mat(:,:,:,i));

        CSI_tmp = squeeze(CSI(2,2,:) ./ CSI(2,1,:));

        CSI_plt(i) = CSI_tmp(sc);
    %     CSI_r(i) = mean(squeeze(CSI_mat(1,1,:,i)));
    end
    
    subplot(1,2,1)
    plot(db(abs(CSI_plt)))
    ylim([-30 30])
    hold off
    subplot(1,2,2)
    plot(angle(CSI_plt))
    ylim([-pi pi])
    hold off
    
    waitforbuttonpress()
end